`ifndef siicpu_mem_ctrl
`define siicpu_mem_ctrl

`include "unit/define.v"

module mem_ctrl (
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0] mem_op,     //from decoder
    output reg                              rw,
    // LOAD: mem -> gpr
    input wire [`WORD_WIDTH - 1 : 0]    alu_out,        // alu_out -> addr_to_mem
    output wire [`WORD_ADDR_BUS]        addr_to_mem,    // addr -> mem_data(rd_data_from_mem)
    input wire [`WORD_WIDTH - 1 : 0]    mem_data,       // mem_data -> mem_data_to_gpr
    output reg [`WORD_WIDTH - 1 : 0]    mem_data_to_gpr,
    // STORE: gpr -> mem
    input wire [`WORD_WIDTH - 1 : 0]    gpr_data,       //from decoder(from "gpr_rd_data_1")
    output wire [`WORD_WIDTH - 1 : 0]   wr_data,

    output reg                          mem_op_as_,
    output reg                          miss_align
);
    
wire    [`DATA_WIDTH_OFFSET - 1 : 0]    offset;
reg     [31 : 0]                        load_data;

assign wr_data      = gpr_data;
assign addr_to_mem  = alu_out[`WORD_ADDR_BUS]; // 29:0
assign offset       = alu_out[`BYTE_OFFSET_LOC];

always @* begin
    miss_align      = 0;
    mem_op_as_      = 1;
    mem_data_to_gpr = 0;
    rw              = `READ;
    if (offset == `BYTE_OFFSET_WORD) begin
        miss_align = 0;
    end else begin
        miss_align = 1;
    end
    case (mem_op)
        `MEM_OP_LOAD_LW: begin
            mem_op_as_      = 0;
            rw              = `READ;
            mem_data_to_gpr = $signed(mem_data[`WORD_WIDTH - 1 : 0]);
        end
        `MEM_OP_LOAD_LH: begin
            mem_op_as_  = 0;
            rw          = `READ;
            if (mem_data[(`WORD_WIDTH/2) - 1] == 1) begin
                load_data = {16'b1111_1111_1111_1111, mem_data[(`WORD_WIDTH/2) - 1 : 0]};
            end else begin
                load_data = mem_data[(`WORD_WIDTH/2) - 1:0];
            end
            mem_data_to_gpr = $signed(load_data); //Take the halfword width first, then sign extend
        end
        `MEM_OP_LOAD_LHU: begin
            mem_op_as_      = 0;
            rw              = `READ;
            mem_data_to_gpr = mem_data[(`WORD_WIDTH/2) - 1 : 0]; //zero extension
        end
        `MEM_OP_LOAD_LB: begin
            mem_op_as_  = 0;
            rw          = `READ;
            if (mem_data[(`WORD_WIDTH/4) - 1] == 1) begin
                load_data = {24'b1111_1111_1111_1111_1111_1111,mem_data[(`WORD_WIDTH/4) - 1 : 0]};
            end else begin
                load_data = mem_data[(`WORD_WIDTH/4) - 1 : 0];
            end
            mem_data_to_gpr = $signed(load_data); //sign extension
        end
        `MEM_OP_LOAD_LBU: begin
            mem_op_as_      = 0;
            rw              = `READ;
            mem_data_to_gpr = mem_data[(`WORD_WIDTH/4) - 1 : 0]; //zero extension
        end
        `MEM_OP_STORE: begin
            mem_op_as_  = 0;
            rw          = `WRITE;
        end
        default: begin //Reads and writes of memory are not performed
            mem_op_as_ = 1;
        end
    endcase
end

endmodule

`endif 