`ifndef siicpu_mem_reg
`define siicpu_mem_reg

`include "define.v"
module mem_reg (
    input wire clk,
    input wire reset,
    // pc
    input wire [`WORD_ADDR_BUS] ex_pc,
    output reg [`WORD_ADDR_BUS] mem_pc,
    // insn
    input wire [`DATA_WIDTH_INSN - 1:0] ex_insn,
    output reg [`DATA_WIDTH_INSN - 1:0] mem_insn,
    // en
    input wire ex_en,
    output reg mem_en,
    // from "alu" (to "mem_ctrl" or "gpr")
    input wire [`DATA_WIDTH_GPR - 1:0] ex_alu_out,
    output reg [`DATA_WIDTH_GPR - 1:0] mem_alu_out,
    // to gpr
    input wire ex_gpr_we_,
    input wire [$clog2(`DATA_HIGH_GPR) - 1:0] ex_dst_addr,
    output reg mem_gpr_we_,
    output reg [$clog2(`DATA_HIGH_GPR) - 1:0] mem_dst_addr,
    // from mem
    input wire [`DATA_WIDTH_GPR - 1:0] mem_data_to_gpr,
    output reg [`DATA_WIDTH_GPR - 1:0] mem_mem_data_to_gpr
);

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        mem_pc <= 0;
        mem_insn <= 0;
        mem_en <= 0;
        mem_alu_out <= 0;
        mem_gpr_we_ <= 0;
        mem_dst_addr <= 0;
        mem_mem_data_to_gpr <= 0;
    end else begin
        mem_pc <= ex_pc;
        mem_insn <= ex_insn;
        mem_en <= ex_en;
        mem_alu_out <= ex_alu_out;
        mem_gpr_we_ <= ex_gpr_we_;
        mem_dst_addr <= ex_dst_addr;
        mem_mem_data_to_gpr <= mem_data_to_gpr;
    end
end

endmodule

`endif