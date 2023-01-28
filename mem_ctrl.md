# MEM_CTRL - 内存访问

在 RV32I 指令集中，较重要的有 Load，Store 指令，需要对内存进行读写访问，在此设计一个内存访问模块，从 "decoder" 得到操作码 mem_op、写数据 mem_wr_data，从 "alu" 得到 $32$ 位地址 out。

## 内存访问的字节对齐

内存实际上是通过基址（base）+偏移量（offset）来给出具体地址，对于内存的访问我们需要考虑内存对齐的问题，由于内存一个地址(chip0)存放 $8$ bits，而对于 CPU 的读写数据均为 $32$ bits，因此一次读写需要返回 $4$ 个地址的值，而这 $4$ 个地址不能是任意的，需要从 0x00 开始访问 $4$ 个地址，他们具有同样的偏移量(offset)，而当从 0x01开始访问 $4$ 个地址，前三个字节具有相同的偏移量，而最后一个字节的偏移量为 $1$，因此，要保证 $32$ bits 数据被读写，需要提供两个偏移量，而在 CPU 中，一次只提供一个偏移量，从而在此我们考虑，仅当地址对齐时进行数据的传输。

| memory chip | 0 | 1 | 2 | 3 |
| :----: | :----: | :----: | :----: | :----: |
|0| 8 bits | 8 bits | 8 bits | 8 bits |
|1| 8 bits | 8 bits | 8 bits | 8 bits |
|2| 8 bits | 8 bits | 8 bits | 8 bits |
|···| 8 bits | 8 bits | 8 bits | 8 bits |

通过 "alu" 得到的 $32$ 位地址 out 实际上是按照字节分配的，其中后 $2$ 位作为字节偏移（offset），前 $30$ 位作为内存地址。在此考虑的内存只需提供首字节地址即可得到四字节的值，而首字节的  offset 必须为 $0$，才说明此时地址对齐。

``` verilog
module mem_ctrl (
input wire [`DATA_WIDTH_GPR - 1:0] ex_out,
output wire [`WORD_ADDR_BUS] addr,
output reg miss_align,
···
);
wire [`DATA_WIDTH_OFFSET - 1:0] offset;

assign addr = ex_out[`WORD_ADDR_LOC]; //[31:2]
assign offset = ex_out[`BYTE_OFFSET_LOC]; //[1:0]
```

## 操作码解码与对齐判断

通过操作码 mem_op 判断当前的读写操作 rw，在 RV32I 指令集中，对内存的读操作可以是 $4$ 字节，$2$ 字节，也可以是 $1$ 字节，分别对应 MEM_OP_LOAD_LW，MEM_OP_LOAD_LH，MEM_OP_LOAD_LB，对内存的写操作为 MEM_OP_STORE，将输出 out 转化为对应比特的 rd_data。

通过 offset 判断是否字节对齐，若没对齐，将 miss_align 置高，表明当前的内存访问出错。

对于内存的访问，需要提供使能（由操作码解码正确得到，表明当前操作为内存访问操作）、地址、读写、写数据，输出读数据。

``` verilog
assign wr_data = ex_mem_wr_data;
always @* begin
    miss_align = 0;
    out = 0;
    as_ = 1;
    rw = `READ;
    if (ex_en == 1) begin
        case (ex_mem_op)
            `MEM_OP_LOAD_LW: begin
                as_ = 0;
                rw = `READ;
                if (offset == `BYTE_OFFSET_WORD) begin //align
                    miss_align = 0;
                    out = rd_data[`WORD_WIDTH - 1:0];
                end else begin
                    miss_align = 1;
                end
            end
            `MEM_OP_LOAD_LH: begin
                as_ = 0;
                rw = `READ;
                if (offset == `BYTE_OFFSET_WORD) begin
                    miss_align = 0;
                    out = rd_data[(`WORD_WIDTH/2) - 1:0];
                end else begin
                    miss_align = 1;
                end
            end
            `MEM_OP_LOAD_LHU: begin
                as_ = 0;
                rw = `READ;
                if (offset == `BYTE_OFFSET_WORD) begin
                    miss_align = 0;
                    out = $signed(rd_data[(`WORD_WIDTH/2) - 1:0]);
                end else begin
                    miss_align = 1;
                end
            end
            `MEM_OP_LOAD_LB: begin
                as_ = 0;
                rw = `READ;
                if (offset == `BYTE_OFFSET_WORD) begin
                    miss_align = 0;
                    out = rd_data[(`WORD_WIDTH/4) - 1:0];
                end else begin
                    miss_align = 1;
                end
            end
            `MEM_OP_LOAD_LBU: begin
                as_ = 0;
                rw = `READ;
                if (offset == `BYTE_OFFSET_WORD) begin
                    miss_align = 0;
                    out = $signed(rd_data[(`WORD_WIDTH/4) - 1:0]);
                end else begin
                    miss_align = 1;
                end
            end
            `MEM_OP_STORE: begin
                as_ = 0;
                rw = `WRITE;
                if (offset == `BYTE_OFFSET_WORD) begin
                    miss_align = 0;
                end else begin
                    miss_align = 1;
                end
            end
            default: begin //Reads and writes of memory are not performed
                out = ex_out;
            end
        endcase
    end
end
```

## 测试

在输入地址时，注意最后两位是字节偏移量，正常情况置零，前三十位用来输入给内存，因此对于 $32$ 位的地址，每次 + 4 来对应内存地址的 + 1，而一个地址会访问 $4$ 个地址的值，因此要得到每次内存地址 + 4，才不会对内存写覆盖，因此对于 $32$ 位的地址，每次 + 4 * 4，实现每次 $32$ bits 的内存访问且没有重叠。

``` verilog 
// 写操作
#1 begin
        ex_en = 1;
        ex_mem_op = `MEM_OP_STORE;
        for (i = 0; i < 40; i ++) begin
            @(posedge clk);
            #1 begin
                ex_out = i * 4 * 4;
                ex_mem_wr_data = ;
            end
        end
    end
// 读操作
#10 begin
        ex_mem_wr_data = 0;
        ex_out = 0;
        ex_mem_op = `MEM_OP_LOAD_LH;
        for (i = 0; i < 40; i ++) begin
            @(posedge clk);
            #1 begin
                ex_out = i * 4; 
            end
        end
    end
```