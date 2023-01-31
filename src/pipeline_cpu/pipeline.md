# Pipeline

对于单周期处理器，虽然一个时间周期可以执行完一条指令，但是由于不同指令的执行时间有差异，CPU 的时钟周期需要满足最长指令的执行时间，导致时钟频率会比较慢，而当引入流水线后，虽然执行单条指令的时间不会变短，反而由于加入寄存器会有所增加，但是在一条指令还未执行完，取指单元便可以开始取第二条指令。例如五级流水线，将一条指令的执行分为取指令、解码、执行、内存访问、写回寄存器五个阶段，此时当第一条指令还处于写回寄存器阶段时，取指已经进行到第五条指令，提高了每一模块的利用率，同时此时的时钟周期只需选取时间最长的阶段的处理时间，而不用选择时间最长的指令的执行时间，大大提高的主频。

流水线的设计实际上就是在各个组合逻辑之间加入寄存器，使每个组合逻辑在每个周期可以独立进行，那么对于寄存器的输入输出信号如何考虑？

## 1.两级流水线

两级流水线只需要加入一个寄存器堆，例如在 decoder 后面加上一个寄存器， decoder 的输出有：
1. 提供给 gpr 的读写地址和写使能，由于读是在 decoder 就需要读的，不用寄存器寄存，而写需要等到 alu 执行完，或则等待 mem_ctrl 将内存中的数据取回，因此 "dst_addr" 与 "gpr_we_" 需要先用寄存器寄存，等待下一个周期再执行 alu 和 mem_ctrl。
2. 提供给 alu 的输入信号，全部存入寄存器。
3. 提供给 mem_ctrl 的操作信号与写入内存的数据，全部存入寄存器。
4. 对于跳转信号，直接由 decoder 和 gpr 在该周期产生，需要输出给 "if_stage"，而什么时候进行跳转，是跳转指令执行完还是跳转指令在译码时就使 "pc" 跳转？由不同设计决定，在此译码完直接跳转。

``` verilog
// id_reg
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        id_pc <= 0;
        id_insn <= 0;
        id_gpr_we_ <= 0;
        id_dst_addr <= 0;
        id_alu_op <= 0;
        id_alu_in_0 <= 0;
        id_alu_in_1 <= 0;
        id_mem_op <= 0;
        id_gpr_data <= 0;
    end else begin
        id_pc <= if_pc;
        id_insn <= if_insn;
        id_gpr_we_ <= gpr_we_;
        id_dst_addr <= dst_addr;
        id_alu_op <= alu_op;
        id_alu_in_0 <= alu_in_0;
        id_alu_in_1 <= alu_in_1;
        id_mem_op <= mem_op;
        id_gpr_data <= gpr_data;
    end
end
```

除了添加一个寄存器模块，在 top 中加入该寄存器：

``` verilog
//top
wire [`WORD_ADDR_BUS] id_pc;
wire [`DATA_WIDTH_INSN - 1:0] id_insn;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] id_dst_addr;
wire [`DATA_WIDTH_ALU_OP - 1:0] id_alu_op;
wire [`DATA_WIDTH_GPR - 1:0] id_alu_in_0;
wire [`DATA_WIDTH_GPR - 1:0] id_alu_in_1;
wire [`DATA_WIDTH_MEM_OP - 1:0] id_mem_op;
wire [`DATA_WIDTH_GPR - 1:0] id_gpr_data;

id_reg u_id_reg(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .id_pc(id_pc),
    .if_insn(if_insn),
    .id_insn(id_insn),
    .gpr_we_(gpr_we_),
    .dst_addr(dst_addr), 
    .id_gpr_we_(id_gpr_we_),
    .id_dst_addr(id_dst_addr),
    .alu_op(alu_op),
    .alu_in_0(alu_in_0),
    .alu_in_1(alu_in_1),
    .id_alu_op(id_alu_op),
    .id_alu_in_0(id_alu_in_0),
    .id_alu_in_1(id_alu_in_1),
    .mem_op(mem_op),
    .gpr_data(gpr_data),
    .id_mem_op(id_mem_op),
    .id_gpr_data(id_gpr_data)
);
···
```
由上可以得到两级流水线的处理器，以取指令解码为第一级；以算数逻辑运算和内存访问、寄存器写回为第二级。

注意，第一条指令往 gpr 里写值，第二条指令就可以用到这个值，即往 gpr 写入的值可以在下一时钟沿读出，因为在 gpr 中，会先判断当前是否写入，若写入且和读地址相等，会直接读出此时写入数据；而如果第一条指令往 spm 中写入值，在第二条指令即下一个时钟读不出来，因为对于 if 阶段的读数据，spm 只会判断 if 是否有写入，而没有考虑 mem 的 store。

以上引出流水线的冒险问题：

1. 结构冒险：如果一条指令需要的硬件部件还在为之前的指令工作，而无法为这条指令提供服务，那就导致了结构冒险（这里结构是指硬件当中的某个部件）。"spm" 在某一周期的一指令中处于 "write to spm" 阶段，而后一指令处于取值阶段，就会发生结构冲突。
2. 数据冒险：如果一条指令需要某数据而该数据正在被之前的指令操作，那这条指令就无法执行，就导致了数据冒险。两级流水线的往 gpr 中写入值可以正确的被下一指令读到，但是三级流水线以上就会在数据写入之前，就已经译码得到了读数据，此时的数据还未更新，便产生了数据冒险。
3. 控制冒险：如果现在要执行哪条指令，是由之前指令的运行结果决定，而现在那条之前指令的结果还没产生，就导致了控制冒险。

ps: 在单周期设计时，没有使用指令寄存器，仅仅利用了组合电路将内存中 "pc" 地址对应的值取出进行解码，此时会产生一个问题，由于 "pc" 复位时是从 0 开始的，因此当第一个时钟上升沿到来时，该周期的地址是 pc + 4，指令是第二条指令，也就是说，在时钟上升沿到来的前一个周期内，第一条指令就已经被解码执行了。

若引入指令寄存器，当第一个时钟沿到来时，该周期的地址是 pc + 4，但是指令是第一条指令，也就是说，在每一周期的指令寄存器存着当前指令，而 "pc" 却已经指向下一地址。增加了一级流水线。

## 2.三级流水线

要设计三级流水线，考虑利用指令寄存器，以及 decoder 之后的寄存器堆，即实现了取指、解码、执行三阶段。指令寄存是 "pc" 输出给 "spm"，由 "spm" 读出的数据在寄存器做一次缓存，因此会落后 "pc" 一个时钟周期。

``` verilog
// if_reg
always @(posedge clk or negedge reset) begin
    if (!reset | !cpu_en) begin
        if_pc <= 0;
        if_insn <= 0;
    end else if (br_taken) begin
        if_pc <= br_addr;
        if_insn <= insn;
    end else begin
        if_pc <= if_pc + 4;
        if_insn <= insn;
    end
end
```

对于三级流水线，当第一条指令为跳转指令，在 decoder 产生的跳转地址与跳转使能时，"pc" 已经指向第二条指令，也就是说在第三个时钟上升沿才会跳转到第一条指令指向的跳转地址 "br_addr"，此时的第二条指令就成为了无效指令，产生了一个周期的浪费。

即产生了控制冒险，可以采用延迟分支的方法，在第二条指令执行完之后再跳转，区别在于此时的第二条指令就可以完整执行，此时避免流水线传送无效数据，避免流水线冒泡。

## 3.四级流水线

将 alu 与 mem_ctrl 也分开，加上 ex_reg，除了将 alu 的输出寄存，还有 decoder 阶段关于内存访问的数据寄存。

``` verilog
// ex_reg
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        ex_pc <= 0;
        ex_insn <= 0;
        ex_gpr_we_ <= 0;
        ex_dst_addr <= 0;
        ex_mem_op <= 0;
        ex_gpr_data <= 0;
    end else begin
        ex_pc <= id_pc;
        ex_insn <= id_insn;
        ex_alu_out <= alu_out;
        ex_gpr_we_ <= id_gpr_we_;
        ex_dst_addr <= id_dst_addr;
        ex_mem_op <= id_mem_op;
        ex_gpr_data <= id_gpr_data;
    end
end
```

此时在 decoder 产生的 "dst_addr" 延迟两拍，"alu_out" 延迟一拍，若此时需要把 "alu_out" 写入 "dst_addr" 地址，正好是同一个时钟周期；"gpr_data" 直接由 mem_ctrl 产生，把 "gpr_data" 写入 "dst_addr" 地址，同样也是一个时钟周期。也就是在该指令被取指之后的第四个时钟沿产生 gpr 的写入地址和数据，那么需要通过指令来判断写入的是 alu 的结果还是 mem 中的数据，此时 "if_pc" 并不是写入 gpr 的指令，因此指令也需要存入寄存器。

``` verilog
// top
assign gpr_wr_data = (ex_insn[`DATA_WIDTH_OPCODE - 1:0] == `OP_LOAD)? mem_data_to_gpr:ex_alu_out;
```

在跳转时需要加 "pc"，而加入指令寄存器以后，指令落后于 "pc" 一个周期，因此想要取到这一条指令的 "pc"，需要 "if_pc" - 4 才是正确值，因此 decoder 需要更改。例如：

``` verilog
// decoder
if (if_insn[31] == 1) begin
    jr_target = (if_pc - 4) - jr_offset[19:0];
end else begin
    jr_target = (if_pc - 4) + jr_offset[19:0];
end
```

## 测试

要检查加入流水线后每一条指令是否被正确执行，通过比较单周期处理器与流水线处理器的波形，关键看以下几类信号：
1. 算数逻辑单元：alu_in_0，alu_in_1，alu_out；
2. 写入 gpr：wr_addr，wr_data；
3. 写入 memory：addr_to_mem，gpr_data；
4. 跳转：if_pc（直接看跳转后的结果）