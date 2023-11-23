`ifndef SIICPU_EX_REG
`define SIICPU_EX_REG

`include "define.v"

module ex_reg (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire                                  cpu_en,
    // stall and flush
    input wire                                  ex_stall,
    input wire                                  ex_flush,
    // pc and insn
    input wire [`PC_WIDTH - 1 : 0]              id_pc,
    input wire [`WORD_WIDTH - 1 : 0]            id_insn,
    input wire                                  id_en,
    // to gpr
    input wire                                  id_gpr_we_n,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        id_dst_addr,
    //csr to gpr
    input wire [`WORD_WIDTH - 1 : 0]            id_csr_to_gpr_data,
    //to gpr_data or memory_addr
    input wire [`WORD_WIDTH - 1 : 0]            alu_out,
    //to mem
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0]     id_mem_op,
    input wire                                  id_memory_we_en,
    input wire                                  id_memory_rd_en,
    input wire [`WORD_WIDTH - 1 : 0]            id_store_data,
    input wire [3 : 0]                          id_store_byteena,
    // to cpu_ctrl
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    id_exp_code,
    input wire                                  id_ebreak_en,
    input wire                                  id_ecall_en,
    //outputs
    output reg [`PC_WIDTH - 1 : 0]              ex_pc,
    output reg [`WORD_WIDTH - 1 : 0]            ex_insn,
    output reg                                  ex_en,
    output reg                                  ex_gpr_we_n,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        ex_dst_addr,
    output reg [`WORD_WIDTH - 1 : 0]            ex_csr_to_gpr_data,
    output reg [`WORD_WIDTH - 1 : 0]            ex_alu_out,
    output reg [`DATA_WIDTH_MEM_OP - 1 : 0]     ex_mem_op,
    output reg                                  ex_memory_we_en,
    output reg                                  ex_memory_rd_en,
    output reg [`WORD_WIDTH - 1 : 0]            ex_store_data,
    output reg [3 : 0]                          ex_store_byteena,
    output reg [`DATA_WIDTH_ISA_EXP - 1 : 0]    ex_exp_code,
    output reg                                  ex_ebreak_en,
    output reg                                  ex_ecall_en,
    output wire                                 load_in_ex_mem,
    output wire                                 alu2gpr_in_ex_mem,
    output wire                                 csr2gpr_in_ex_mem
);

assign load_in_ex_mem       = (ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) && ex_en && (ex_gpr_we_n == `GPR_WRITE);
assign alu2gpr_in_ex_mem    = (ex_insn[`ALL_TYPE_OPCODE] != `OP_LOAD) && (ex_insn[`ALL_TYPE_OPCODE] != `OP_SYSTEM) && ex_en && (ex_gpr_we_n == `GPR_WRITE);
assign csr2gpr_in_ex_mem    = (ex_insn[`ALL_TYPE_OPCODE] == `OP_SYSTEM) && ex_en && (ex_gpr_we_n == `GPR_WRITE);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ex_pc               <= `PC_WIDTH'b0;
        ex_insn             <= `WORD_WIDTH'b0;
        ex_en               <= 1'b0;
        ex_gpr_we_n         <= `DIS_GPR_WRITE;
        ex_dst_addr         <= `GPR_ADDR_WIDTH'b0;
        ex_csr_to_gpr_data  <= `WORD_WIDTH'b0;
        ex_alu_out          <= `DATA_WIDTH_ALU_OP'b0;
        ex_mem_op           <= `DATA_WIDTH_MEM_OP'b0;
        ex_memory_we_en     <= 1'b0;
        ex_memory_rd_en     <= 1'b0;
        ex_store_data       <= `WORD_WIDTH'b0;
        ex_store_byteena    <= 4'b0000;
        ex_exp_code         <= `DATA_WIDTH_ISA_EXP'b0;
    end else if (cpu_en) begin
        if (ex_flush) begin
            ex_pc               <= `PC_WIDTH'b0;
            ex_insn             <= `WORD_WIDTH'b0;
            ex_en               <= 1'b0;
            ex_gpr_we_n         <= `DIS_GPR_WRITE;
            ex_dst_addr         <= `GPR_ADDR_WIDTH'b0;
            ex_csr_to_gpr_data  <= `WORD_WIDTH'b0;
            ex_alu_out          <= `DATA_WIDTH_ALU_OP'b0;
            ex_mem_op           <= `DATA_WIDTH_MEM_OP'b0;
            ex_memory_we_en     <= 1'b0;
            ex_memory_rd_en     <= 1'b0;
            ex_store_data       <= `WORD_WIDTH'b0;
            ex_store_byteena    <= 4'b0000;
            ex_exp_code         <= `DATA_WIDTH_ISA_EXP'b0;
        end else if (!ex_stall) begin
            ex_pc               <= id_pc;
            ex_insn             <= id_insn;
            ex_en               <= id_en;
            ex_gpr_we_n         <= id_gpr_we_n;
            ex_dst_addr         <= id_dst_addr;
            ex_csr_to_gpr_data  <= id_csr_to_gpr_data;
            ex_alu_out          <= alu_out;
            ex_mem_op           <= id_mem_op;
            ex_memory_we_en     <= id_memory_we_en;
            ex_memory_rd_en     <= id_memory_rd_en;
            ex_store_data       <= id_store_data;
            ex_store_byteena    <= id_store_byteena;
            ex_exp_code         <= id_exp_code;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ex_ebreak_en        <= `DISABLE;
        ex_ecall_en         <= `DISABLE;
    end else if (cpu_en && !ex_stall) begin
        ex_ebreak_en        <= id_ebreak_en;
        ex_ecall_en         <= id_ecall_en;
    end
end

endmodule
`endif