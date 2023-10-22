`ifndef SIICPU_MEM_REG
`define SIICPU_MEM_REG

`include "define.v"

module mem_reg (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire                                  mem_stall,
    input wire                                  mem_flush,
    input wire [`PC_WIDTH - 1 : 0]              ex_pc,
    input wire [`WORD_WIDTH - 1 : 0]            ex_insn,
    input wire                                  ex_en,
    input wire [`WORD_WIDTH - 1 : 0]            ex_alu_out,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        ex_dst_addr,
    input wire                                  ex_gpr_we_,
//    input wire [`WORD_WIDTH - 1 : 0]            load_data,
    output reg [`PC_WIDTH - 1 : 0]              mem_pc,
    output reg [`WORD_WIDTH - 1 : 0]            mem_insn,
    output reg                                  mem_en,
    output reg [`WORD_WIDTH - 1 : 0]            mem_alu_out,
    output reg                                  mem_gpr_we_,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        mem_dst_addr
//    output reg [`WORD_WIDTH - 1 : 0]            mem_load_data
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_pc              <= `PC_WIDTH'b0;
        mem_insn            <= `WORD_WIDTH'b0;
        mem_en              <= 1'b0;
        mem_alu_out         <= `WORD_WIDTH'b0;
        mem_gpr_we_         <= 1'b0;
        mem_dst_addr        <= `GPR_ADDR_WIDTH'b0;
//        mem_load_data       <= `WORD_WIDTH'b0;
    end else if (mem_flush) begin
        mem_pc              <= `PC_WIDTH'b0;
        mem_insn            <= `WORD_WIDTH'b0;
        mem_en              <= 1'b0;
        mem_alu_out         <= `WORD_WIDTH'b0;
        mem_gpr_we_         <= 1'b0;
        mem_dst_addr        <= `GPR_ADDR_WIDTH'b0;
//        mem_load_data       <= `WORD_WIDTH'b0;      
    end else if (!mem_stall) begin
        mem_pc              <= ex_pc;
        mem_insn            <= ex_insn;
        mem_en              <= ex_en;
        mem_alu_out         <= ex_alu_out;
        mem_gpr_we_         <= ex_gpr_we_;
        mem_dst_addr        <= ex_dst_addr;
//        mem_load_data       <= load_data;
    end
end

endmodule
`endif