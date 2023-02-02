# Pipeline

对于单周期处理器，虽然一个时间周期可以执行完一条指令，但是由于不同指令的执行时间有差异，CPU 的时钟周期需要满足最长指令的执行时间，导致时钟频率会比较慢，而当引入流水线后，虽然执行单条指令的时间不会变短，反而由于加入寄存器会有所增加，但是在一条指令还未执行完，取指单元便可以开始取第二条指令。例如五级流水线，将一条指令的执行分为取指令、解码、执行、内存访问、写回寄存器五个阶段，此时当第一条指令还处于写回寄存器阶段时，取指已经进行到第五条指令，提高了每一模块的利用率，同时此时的时钟周期只需选取时间最长的阶段的处理时间，而不用选择时间最长的指令的执行时间，大大提高的主频。

流水线的设计实际上就是在各个组合逻辑之间加入寄存器，使每个组合逻辑在每个周期可以独立进行，那么对于各个寄存器的输入输出信号如何考虑？

在此设计五级流水线的 CPU：
1. 第一阶段作为取指阶段，其后加上：包含 `pc` 和 `insn` 寄存器，当一个上升沿到来，`pc` 变为下一地址值 `pc + 4` 或 `br_addr`，而 `insn` 取出的是 `pc` 对应的指令，因此会出现指令落后地址一个周期的情况。
2. 第二阶段为解码阶段：在解码器与 ALU 之间加上寄存器，由于在解码之后还要执行内存访问和寄存器写回，除了 ALU 的信号，其余对应信号都要存入寄存器。
3. 第三阶段为算术逻辑运算阶段：在 ALU 与 内存访问之间加入寄存器，此时寄存 ALU 的输出 `alu_out` 和解码中的 `gpr_data` 、`dst_addr` 等。
4. 第四阶段为内存访问阶段：此时通用寄存器中的值 `gpr_data` 存入内存，在此之后只有 WB，因此将 `dst_addr`、`mem_data`信号寄存。
5. 最后一阶段为寄存器写回阶段：通过 `mem_insn` 指令判断当前将什么数据写回寄存器。


ps: 每一级寄存器都要将 `pc` 和 `insn` 打一拍寄存，确保每一阶段都能知道当前执行的是哪一条指令，比如在 WB 阶段写回谁的值，就需要用到当前指令。

## 1. if_reg

取指与解码之间的寄存器堆：

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

由于指令寄存器的存在，每一个周期的 `pc` 并不是当前解码时的指令地址，对于跳转指令会使用到跳转指令对应的 `pc`，而当前周期的 `pc` 确实跳转指令之后的指令的 `pc`，因此想要取到这一条指令的 `pc`，需要 `if_pc - 4` 才是正确值，因此 decoder 需要更改。例如：

``` verilog
// decoder
if (if_insn[31] == 1) begin
    jr_target = (if_pc - 4) - jr_offset[19:0];
end else begin
    jr_target = (if_pc - 4) + jr_offset[19:0];
end
```

## 2. id_reg
 
例如在 decoder 后面加上一个寄存器， decoder 的输出有：
1. 提供给 gpr 的读写地址和写使能，由于读是在 decoder 就需要读的，不用寄存器寄存，而写需要等到 alu 执行完，或者等待 mem_ctrl 将内存中的数据取回，因此 `dst_addr` 与 `gpr_we_` 需要先用寄存器寄存，等待之后周期再执行 alu 与 mem_ctrl。
2. 提供给 alu 的输入信号，全部存入寄存器。
3. 提供给 mem_ctrl 的操作信号与写入内存的数据，全部存入寄存器。
4. 对于跳转信号，直接由 decoder 和 gpr 在该周期产生，需要输出给 `if_reg`，而什么时候进行跳转，是跳转指令执行完还是跳转指令在译码时就使 `pc` 跳转？由不同设计决定，在此译码完直接跳转，减少流水线冒泡。

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

## 3. ex_reg

将 alu 与 mem_ctrl 之间加上 ex_reg，除了将 alu 的输出寄存（如果输出是写入 gpr 的），还有 decoder 阶段关于内存访问的数据寄存。

``` verilog
// ex_reg
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        ex_pc <= 0;
        ex_insn <= 0;
        ex_alu_out <= 0;
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
在 top 中例化：

``` verilog
// top
wire [`WORD_ADDR_BUS] ex_pc;
wire [`DATA_WIDTH_INSN - 1:0] ex_insn;
wire [`DATA_WIDTH_GPR - 1:0] ex_alu_out;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] ex_dst_addr;
wire [`DATA_WIDTH_MEM_OP - 1:0] ex_mem_op;
wire [`DATA_WIDTH_GPR - 1:0] ex_gpr_data;

ex_reg u_ex_reg(
    .clk(clk),
    .reset(reset),
    .id_pc(id_pc),
    .ex_pc(ex_pc),
    .id_insn(id_insn),
    .ex_insn(ex_insn),
    .alu_out(alu_out),
    .ex_alu_out(ex_alu_out),
    .id_gpr_we_(id_gpr_we_),
    .id_dst_addr(id_dst_addr),
    .ex_gpr_we_(ex_gpr_we_),
    .ex_dst_addr(ex_dst_addr),
    .id_mem_op(id_mem_op),
    .id_gpr_data(id_gpr_data),
    .ex_mem_op(ex_mem_op),
    .ex_gpr_data(ex_gpr_data)
);

mem_ctrl u_mem_ctrl(
    .mem_op(ex_mem_op),
    .alu_out(ex_alu_out),
    .gpr_data(ex_gpr_data),
    ···
);
```

## 4. mem_reg

将写回寄存器单独作为一个阶段，实现五级流水线。内存写入在 mem_ctrl 完成，将 gpr 写入放至第五阶段，将 `mem_alu_out` 和 `mem_mem_data_to_gpr` 通过 `mem_insn` 做选择写入 gpr，`mem_gpr_we_` 和 `mem_dst_addr` 记得也打一拍使它们在同一周期。

``` verilog
// mem_reg
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        mem_pc <= 0;
        mem_insn <= 0;
        mem_alu_out <= 0;
        mem_gpr_we_ <= 0;
        mem_dst_addr <= 0;
        mem_mem_data_to_gpr <= 0;
    end else begin
        mem_pc <= ex_pc;
        mem_insn <= ex_insn;
        mem_alu_out <= ex_alu_out;
        mem_gpr_we_ <= ex_gpr_we_;
        mem_dst_addr <= ex_dst_addr;
        mem_mem_data_to_gpr <= mem_data_to_gpr;
    end
end
```
在 top 中将 gpr 的写入信号改为 mem_reg 之后的信号：

``` verilog
// top
gpr u_gpr(
    .we_(mem_gpr_we_),
    .wr_addr(mem_dst_addr),
    .wr_data(gpr_wr_data),
    ···
);
//WB
assign gpr_wr_data = (mem_insn[`DATA_WIDTH_OPCODE - 1:0] == `OP_LOAD)? mem_mem_data_to_gpr:mem_alu_out;

wire [`WORD_ADDR_BUS] mem_pc;
wire [`DATA_WIDTH_INSN - 1:0] mem_insn;
wire [`DATA_WIDTH_GPR - 1:0] mem_alu_out;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] mem_dst_addr;
wire [`DATA_WIDTH_GPR - 1:0] mem_mem_data_to_gpr;

mem_reg u_mem_reg (
    .clk(clk),
    .reset(reset),
    .ex_pc(ex_pc),
    .mem_pc(mem_pc),
    .ex_insn(ex_insn),
    .mem_insn(mem_insn),
    .ex_alu_out(ex_alu_out),
    .mem_alu_out(mem_alu_out),
    .ex_gpr_we_(ex_gpr_we_),
    .ex_dst_addr(ex_dst_addr),
    .mem_gpr_we_(mem_gpr_we_),
    .mem_dst_addr(mem_dst_addr),
    .mem_data_to_gpr(mem_data_to_gpr),
    .mem_mem_data_to_gpr(mem_mem_data_to_gpr)
);
```

## 流水线冒险

- 控制冒险

由于流水线的加入，在前一条指令还未执行完就执行其后一条指令，对于跳转指令，该指令的正确执行应该是在其后执行跳转地址所对应的指令，而假设第一时钟上升沿取指为跳转指令，等到下一时钟沿，解码阶段产生了跳转地址与跳转使能时，此时`pc` 已经指向第二条指令，若选择在解码时将跳转地址 `br_addr` 送给取指阶段，最早也在第三时钟上升沿，开始执行跳转指令（有条件跳转不要等到 ALU 执行去判断是否跳转，在解码阶段判断可以缩短流水线停顿周期），然后需要将第二条指令清除（排空流水线），等到跳转执行完后再重新执行第二条指令。在软件中，可以将跳转指令之前的一条指令（不会影响跳转地址等），放置于跳转指令之后，此时不需要将第二条指令清空，避免了流水线冒泡。


- 结构冒险

如果一条指令需要的硬件部件还在为之前的指令工作，而无法为这条指令提供服务，那就导致了结构冒险（这里结构是指硬件当中的某个部件）。`spm` 在某一周期的一指令中处于 `write to spm` 阶段，而后一指令处于取值阶段，就会发生结构冲突。

- 数据冒险

如果一条指令需要某数据而该数据正在被之前的指令操作，那这条指令就无法执行，就导致了数据冒险。

由于寄存器的写入安排在第五阶段，只有第五个时钟上升沿才会将需要的值写入寄存器，而在第二个时钟上升沿就有第二条指令被取到，第三个时钟沿第二条指令译码，开始取寄存器中的值，如果此时所取的地址与前一条指令到读写的地址相同，此时的数据还未更新，便产生了数据冒险。

|1| IF | ID | EX | MEM | WB | | | | |
| :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: |:----: | :----: |
|2|   | IF | ID | EX | MEM | WB |     |     |
|3|   |    | IF | ID | EX | MEM | WB  |     |
|4|   |    |    | IF | ID | EX  | MEM | WB  |

解决方法：在解码中加入直通，比如第二条指令要用到第一条指令写的值，该值在 EX 就已经产生，便可以直接将 EX 中产生的值直接传给 `gpr_rd_data`，这样不用等第一条指令执行完，也可以保证取到正确的寄存器值；比如第三条指令要用到第一条指令写入寄存器的值，则将 MEM 阶段保存的写入寄存器的值直接传给 `gpr_rd_data` 作为解码器的输入，从而不利用地址读出数据。

那么对于一条指令在解码时，是在 EX 还是 MEM 取值呢？

在此以第四条指令为例，在 4 解码时，其上还有三条指令没有执行完成，分别是 3 处于 EX，2 处于 MEM，1 处于 WB，由于 3 的值是有可能受到 1，2 的影响的，因此，先判断 3，也就是先判断 EX，判断 `id_en`， `id_gpr_we_`， `id_dst_addr`，如果地址相同使能有效，再判断当前指令 `id_insn`，如果此时执行将 ALU 输出存入寄存器，则将此时的 `alu_out` 作为直通数据（不是 `ex_alu_out`），传输给 `gpr_rd_data`作为输入（那么如果此时是要读取内存数据呢？此时上一条指令还没取到值，可以通过流水线停顿解决问题，在此先不考虑，不考虑情况下，若第一条指令写入内存，第三条指令可以取到，即 ID 取 MEM）。判断完 3 后，我们再判断 2 指令，也就是 MEM，判断 `ex_en`， `ex_gpr_we_`， `ex_dst_addr`，如果地址相同使能有效，再判断当前指令 `ex_insn`，如果此时执行将内存中数据存入寄存器，则将此时的 `mem_data` 作为直通数据（不是 `mem_mem_data···`），传输给 `gpr_rd_data`作为输入；如果此时执行将 ALU 输出存入寄存器，则将此时的 `ex_alu_out` 作为直通数据。

注意：ALU 的执行是和 `id_en`， `id_gpr_we_`， `id_dst_addr` 的产生同步进行的，MEM 的执行是和 `ex_en`， `ex_gpr_we_`， `ex_dst_addr` 的产生同步进行的。

``` verilog
always @(*) begin
    // gpr_rd_data_0
    if (id_en && !id_gpr_we_ && (id_dst_addr == gpr_rd_addr_0)) begin
        if (id_insn[`DATA_WIDTH_OPCODE - 1:0] != `OP_LOAD) begin
            ra_data <= alu_out;
        end else begin
            ra_data <= 0; // error, need to be reviewd
        end
    end else if (ex_en && !ex_gpr_we_ && (ex_dst_addr == gpr_rd_addr_0)) begin
        if (ex_insn[`DATA_WIDTH_OPCODE - 1:0] != `OP_LOAD) begin
            ra_data <= ex_alu_out;
        end else begin
            ra_data <= mem_data_to_gpr;
        end
    end else begin
        ra_data <= gpr_rd_data_0;
    end
    // gpr_rd_data_1
    if (id_en && !id_gpr_we_ && (id_dst_addr == gpr_rd_addr_1)) begin
        if (id_insn[`DATA_WIDTH_OPCODE - 1:0] != `OP_LOAD) begin
            rb_data <= alu_out;
        end else begin
            rb_data <= 0; // error, need to be reviewd
        end
    end else if (ex_en && !ex_gpr_we_ && (ex_dst_addr == gpr_rd_addr_1)) begin
        if (ex_insn[`DATA_WIDTH_OPCODE - 1:0] != `OP_LOAD) begin
            rb_data <= ex_alu_out;
        end else begin
            rb_data <= mem_data_to_gpr;
        end
    end else begin
        rb_data <= gpr_rd_data_1;
    end
end
```

## 测试

要检查加入流水线后每一条指令是否被正确执行，通过比较单周期处理器与流水线处理器的波形，关键看以下几类信号：
1. 算数逻辑单元：alu_in_0，alu_in_1，alu_out；
2. 写入 gpr：wr_addr，wr_data；
3. 写入 memory：addr_to_mem，gpr_data；
4. 跳转：if_pc