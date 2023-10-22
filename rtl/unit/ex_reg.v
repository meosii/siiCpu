`ifndef SIICPU_EX_REG
`define SIICPU_EX_REG

`include "define.v"

module ex_reg (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire                                  ex_stall,
    input wire                                  ex_flush,
    input wire [`PC_WIDTH - 1 : 0]              id_pc,
    input wire [`WORD_WIDTH - 1 : 0]            id_insn,
    input wire                                  id_en,
    input wire [`WORD_WIDTH - 1 : 0]            alu_out,
    input wire                                  id_gpr_we_,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        id_dst_addr,
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0]     id_mem_op,
    input wire [`WORD_WIDTH - 1 : 0]            id_store_data,
    input wire [3 : 0]                          id_store_byteena,
    output reg [`PC_WIDTH - 1 : 0]              ex_pc,
    output reg [`WORD_WIDTH - 1 : 0]            ex_insn,
    output reg                                  ex_en,
    output reg [`WORD_WIDTH - 1 : 0]            ex_alu_out,
    output reg                                  ex_gpr_we_,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        ex_dst_addr,
    output reg [`DATA_WIDTH_MEM_OP - 1 : 0]     ex_mem_op,
    output reg [`WORD_WIDTH - 1 : 0]            ex_store_data,
    output reg [3 : 0]                          ex_store_byteena
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ex_pc               <= `PC_WIDTH'b0;
        ex_insn             <= `WORD_WIDTH'b0;
        ex_en               <= 1'b0;
        ex_alu_out          <= `DATA_WIDTH_ALU_OP'b0;
        ex_gpr_we_          <= 1'b0;
        ex_dst_addr         <= `GPR_ADDR_WIDTH'b0;
        ex_mem_op           <= `DATA_WIDTH_MEM_OP'b0;
        ex_store_data       <= `WORD_WIDTH'b0;
        ex_store_byteena    <= 4'b0000;
    end else if (ex_flush) begin
        ex_pc               <= `PC_WIDTH'b0;
        ex_insn             <= `WORD_WIDTH'b0;
        ex_en               <= 1'b0;
        ex_alu_out          <= `DATA_WIDTH_ALU_OP'b0;
        ex_gpr_we_          <= 1'b0;
        ex_dst_addr         <= `GPR_ADDR_WIDTH'b0;
        ex_mem_op           <= `DATA_WIDTH_MEM_OP'b0;
        ex_store_data       <= `WORD_WIDTH'b0;
        ex_store_byteena    <= 4'b0000;    
    end else if (!ex_stall) begin
        ex_pc               <= id_pc;
        ex_insn             <= id_insn;
        ex_en               <= id_en;
        ex_alu_out          <= alu_out;
        ex_gpr_we_          <= id_gpr_we_;
        ex_dst_addr         <= id_dst_addr;
        ex_mem_op           <= id_mem_op;
        ex_store_data       <= id_store_data;
        ex_store_byteena    <= id_store_byteena;
    end
end

endmodule
`endif