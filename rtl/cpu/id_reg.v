`ifndef SIICPU_ID_REG
`define SIICPU_ID_REG

`include "define.v"

module id_reg (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire                                  cpu_en,
    //stall and flush
    input wire                                  id_stall,
    input wire                                  id_flush,
    // pc and insn
    input wire [`PC_WIDTH-1 : 0]                if_pc,
    input wire [`WORD_WIDTH - 1 : 0]            if_insn,
    input wire                                  if_en,
    // to gpr
    input wire                                  gpr_we_,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        dst_addr,
    // csr to gpr
    input wire [`WORD_WIDTH - 1 : 0]            csr_to_gpr_data,
    // to alu
    input wire [`DATA_WIDTH_ALU_OP - 1 : 0]     alu_op,
    input wire [`WORD_WIDTH - 1 : 0]            alu_in_0,
    input wire [`WORD_WIDTH - 1 : 0]            alu_in_1,
    // to mem
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0]     mem_op,
    input wire                                  memory_we_en,
    input wire                                  memory_rd_en,
    input wire [`WORD_WIDTH - 1 : 0]            store_data,
    input wire [3 : 0]                          store_byteena,
    // to cpu_ctrl
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    exp_code,
    input wire                                  ebreak_en,
    input wire                                  ecall_en,
    //outputs
    output reg [`PC_WIDTH-1 : 0]                id_pc,
    output reg [`WORD_WIDTH - 1 : 0]            id_insn,
    output reg                                  id_en,
    output reg                                  id_gpr_we_,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        id_dst_addr,
    output reg [`WORD_WIDTH - 1 : 0]            id_csr_to_gpr_data,
    output reg [`DATA_WIDTH_ALU_OP - 1 : 0]     id_alu_op,
    output reg [`WORD_WIDTH - 1 : 0]            id_alu_in_0,
    output reg [`WORD_WIDTH - 1 : 0]            id_alu_in_1,
    output reg [`DATA_WIDTH_MEM_OP - 1 : 0]     id_mem_op,
    output reg                                  id_memory_we_en,
    output reg                                  id_memory_rd_en,
    output reg [`WORD_WIDTH - 1 : 0]            id_store_data,
    output reg [3 : 0]                          id_store_byteena,
    output reg [`DATA_WIDTH_ISA_EXP - 1 : 0]    id_exp_code,
    output reg                                  id_ebreak_en,
    output reg                                  id_ecall_en,
    output wire                                 load_in_id_ex,
    output wire                                 alu2gpr_in_id_ex
);

assign load_in_id_ex = (id_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) && id_en && (id_gpr_we_ == `WRITE);
assign alu2gpr_in_id_ex  = (id_insn[`ALL_TYPE_OPCODE] != `OP_LOAD) && id_en && (id_gpr_we_ == `WRITE);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        id_pc               <= `PC_WIDTH'b0;
        id_insn             <= `WORD_WIDTH'b0;
        id_en               <= 1'b0;
        id_gpr_we_          <= 1'b0;
        id_dst_addr         <= `GPR_ADDR_WIDTH'b0;
        id_csr_to_gpr_data  <= `WORD_WIDTH'b0;
        id_alu_op           <= `DATA_WIDTH_ALU_OP'b0;
        id_alu_in_0         <= `WORD_WIDTH'b0;
        id_alu_in_1         <= `WORD_WIDTH'b0;
        id_mem_op           <= `DATA_WIDTH_MEM_OP'b0;
        id_memory_we_en     <= 1'b0;
        id_memory_rd_en     <= 1'b0;
        id_store_data       <= `WORD_WIDTH'b0;
        id_store_byteena    <= 4'b0;
        id_exp_code         <= `DATA_WIDTH_ISA_EXP'b0;
        id_ebreak_en        <= `DISABLE;
        id_ecall_en         <= `DISABLE;
    end else if (id_flush) begin
        id_pc               <= `PC_WIDTH'b0;
        id_insn             <= `WORD_WIDTH'b0;
        id_en               <= 1'b0;
        id_gpr_we_          <= 1'b0;
        id_dst_addr         <= `GPR_ADDR_WIDTH'b0;
        id_csr_to_gpr_data  <= `WORD_WIDTH'b0;
        id_alu_op           <= `DATA_WIDTH_ALU_OP'b0;
        id_alu_in_0         <= `WORD_WIDTH'b0;
        id_alu_in_1         <= `WORD_WIDTH'b0;
        id_mem_op           <= `DATA_WIDTH_MEM_OP'b0;
        id_memory_we_en     <= 1'b0;
        id_memory_rd_en     <= 1'b0;
        id_store_data       <= `WORD_WIDTH'b0;
        id_store_byteena    <= 4'b0;
        id_exp_code         <= `DATA_WIDTH_ISA_EXP'b0;
        id_ebreak_en        <= `DISABLE;
        id_ecall_en         <= `DISABLE;
    end else if (cpu_en && !id_stall) begin
        id_pc               <= if_pc;
        id_insn             <= if_insn;
        id_en               <= if_en;
        id_gpr_we_          <= gpr_we_;
        id_dst_addr         <= dst_addr;
        id_csr_to_gpr_data  <= csr_to_gpr_data;
        id_alu_op           <= alu_op;
        id_alu_in_0         <= alu_in_0;
        id_alu_in_1         <= alu_in_1;
        id_mem_op           <= mem_op;
        id_memory_we_en     <= memory_we_en;
        id_memory_rd_en     <= memory_rd_en;
        id_store_data       <= store_data;
        id_store_byteena    <= store_byteena;
        id_exp_code         <= exp_code;
        id_ebreak_en        <= ebreak_en;
        id_ecall_en         <= ecall_en;
    end
end

endmodule

`endif