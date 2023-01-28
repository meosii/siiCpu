`include "define.v"
module mem_ctrl (
    input wire [`DATA_WIDTH_MEM_OP - 1:0] mem_op, //from decoder
    input wire [`DATA_WIDTH_GPR - 1:0] mem_wr_data, //from decoder
    input wire [`DATA_WIDTH_GPR - 1:0] mem_addr_from_alu, //from alu
    output wire [`WORD_ADDR_BUS] addr_to_mem, // addr -> rd_data_from_mem
    input wire [`DATA_WIDTH_GPR - 1:0] rd_data_from_mem, // rd_data_from_mem -> mem_data_to_gpr
    output reg mem_op_as_,
    output reg rw,
    output wire [`DATA_WIDTH_GPR - 1:0] wr_data,
    output reg [`DATA_WIDTH_GPR - 1:0] mem_data_to_gpr,
    output reg miss_align
);
    
wire [`DATA_WIDTH_OFFSET - 1:0] offset;

assign wr_data = mem_wr_data;
assign addr_to_mem = mem_addr_from_alu[`WORD_ADDR_BUS]; //29:0
assign offset = mem_addr_from_alu[`BYTE_OFFSET_LOC];

always @* begin
    miss_align = 0;
    mem_op_as_ = 1;
    mem_data_to_gpr = 0;
    rw = `READ;
    case (mem_op)
        `MEM_OP_LOAD_LW: begin
            mem_op_as_ = 0;
            rw = `READ;
            if (offset == `BYTE_OFFSET_WORD) begin //align
                miss_align = 0;
                mem_data_to_gpr = rd_data_from_mem[`WORD_WIDTH - 1:0];
            end else begin
                miss_align = 1;
            end
        end
        `MEM_OP_LOAD_LH: begin
            mem_op_as_ = 0;
            rw = `READ;
            if (offset == `BYTE_OFFSET_WORD) begin
                miss_align = 0;
                mem_data_to_gpr = rd_data_from_mem[(`WORD_WIDTH/2) - 1:0];
            end else begin
                miss_align = 1;
            end
        end
        `MEM_OP_LOAD_LHU: begin
            mem_op_as_ = 0;
            rw = `READ;
            if (offset == `BYTE_OFFSET_WORD) begin
                miss_align = 0;
                mem_data_to_gpr = rd_data_from_mem[(`WORD_WIDTH/2) - 1:0];
            end else begin
                miss_align = 1;
            end
        end
        `MEM_OP_LOAD_LB: begin
            mem_op_as_ = 0;
            rw = `READ;
            if (offset == `BYTE_OFFSET_WORD) begin
                miss_align = 0;
                mem_data_to_gpr = rd_data_from_mem[(`WORD_WIDTH/4) - 1:0];
            end else begin
                miss_align = 1;
            end
        end
        `MEM_OP_LOAD_LBU: begin
            mem_op_as_ = 0;
            rw = `READ;
            if (offset == `BYTE_OFFSET_WORD) begin
                miss_align = 0;
                mem_data_to_gpr = rd_data_from_mem[(`WORD_WIDTH/4) - 1:0];
            end else begin
                miss_align = 1;
            end
        end
        `MEM_OP_STORE: begin
            mem_op_as_ = 0;
            rw = `WRITE;
            if (offset == `BYTE_OFFSET_WORD) begin
                miss_align = 0;
            end else begin
                miss_align = 1;
            end
        end
        default: begin //Reads and writes of memory are not performed
            mem_op_as_ = 1;
        end
    endcase
end

endmodule