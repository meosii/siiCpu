`ifndef SIICPU_MEM_REG
`define SIICPU_MEM_REG

`include "define.v"

module mem_reg (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire                                  cpu_en,
    // stall and flush
    input wire                                  mem_stall,
    input wire                                  mem_flush,
    // pc and insn
    input wire [`PC_WIDTH - 1 : 0]              ex_pc,
    input wire [`WORD_WIDTH - 1 : 0]            ex_insn,
    input wire                                  ex_en,
    // to  gpr
    input wire                                  ex_gpr_we_n,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        ex_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]            ex_alu_out,
    input wire                                  bus_ahb_enable, //read or write in ahb bus
    //csr to gpr
    input wire [`WORD_WIDTH - 1 : 0]            ex_csr_to_gpr_data,
    // to cpu_ctrl
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    ex_exp_code_mem_ctrl,
    input wire                                  ex_ebreak_en,
    input wire                                  ex_ecall_en,
    //output
    output reg [`PC_WIDTH - 1 : 0]              mem_pc,
    output reg [`WORD_WIDTH - 1 : 0]            mem_insn,
    output reg                                  mem_en,
    output reg                                  mem_gpr_we_n,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        mem_dst_addr,
    output reg [`WORD_WIDTH - 1 : 0]            mem_alu_out,
    output reg                                  mem_bus_ahb_enable,
    output reg [`WORD_WIDTH - 1 : 0]            mem_csr_to_gpr_data,
    output reg [`DATA_WIDTH_ISA_EXP - 1 : 0]    mem_exp_code,
    output reg                                  mem_ebreak_en,
    output reg                                  mem_ecall_en
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_pc              <= `PC_WIDTH'b0;
        mem_insn            <= `WORD_WIDTH'b0;
        mem_en              <= 1'b0;
        mem_gpr_we_n        <= `DIS_GPR_WRITE;
        mem_dst_addr        <= `GPR_ADDR_WIDTH'b0;
        mem_alu_out         <= `WORD_WIDTH'b0;
        mem_bus_ahb_enable  <= 1'b0;
        mem_csr_to_gpr_data <= `WORD_WIDTH'b0;
        mem_exp_code        <= `DATA_WIDTH_ISA_EXP'b0;
    end else if (cpu_en) begin
        if (mem_flush) begin
            mem_pc              <= `PC_WIDTH'b0;
            mem_insn            <= `WORD_WIDTH'b0;
            mem_en              <= 1'b0;
            mem_gpr_we_n        <= `DIS_GPR_WRITE;
            mem_dst_addr        <= `GPR_ADDR_WIDTH'b0;
            mem_alu_out         <= `WORD_WIDTH'b0;
            mem_bus_ahb_enable  <= 1'b0;
            mem_csr_to_gpr_data <= `WORD_WIDTH'b0; 
            mem_exp_code        <= `DATA_WIDTH_ISA_EXP'b0;
        end else if (!mem_stall) begin
            mem_pc              <= ex_pc;
            mem_insn            <= ex_insn;
            mem_en              <= ex_en;
            mem_gpr_we_n        <= ex_gpr_we_n;
            mem_dst_addr        <= ex_dst_addr;
            mem_alu_out         <= ex_alu_out;
            mem_bus_ahb_enable  <= bus_ahb_enable;
            mem_csr_to_gpr_data <= ex_csr_to_gpr_data;
            mem_exp_code        <= ex_exp_code_mem_ctrl;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_ebreak_en       <= `DISABLE;
        mem_ecall_en        <= `DISABLE;
    end else if (cpu_en && !mem_stall) begin
        mem_ebreak_en       <= ex_ebreak_en;
        mem_ecall_en        <= ex_ecall_en;
    end
end

endmodule
`endif