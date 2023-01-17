`include "define.v"
module mem_ctrl (
    input wire ex_en,
    input wire [`DATA_WIDTH_MEM_OP - 1:0] ex_mem_op, //from decoder
    input wire [`DATA_WIDTH_GPR - 1:0] ex_mem_wr_data, //from decoder
    input wire [`DATA_WIDTH_GPR - 1:0] ex_out, //from alu
    output wire [`WORD_ADDR_BUS] addr, // addr -> rd_data
    input wire [`DATA_WIDTH_GPR - 1:0] rd_data, // rd_data -> out
    output reg as_,
    output reg rw,
    output wire [`DATA_WIDTH_GPR - 1:0] wr_data,
    output reg [`DATA_WIDTH_GPR - 1:0] out,
    output reg miss_align
);
    
wire [`DATA_WIDTH_OFFSET - 1:0] offset;

assign wr_data = ex_mem_wr_data;
assign addr = ex_out[`WORD_ADDR_LOC];
assign offset = ex_out[`BYTE_OFFSET_LOC];

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

endmodule