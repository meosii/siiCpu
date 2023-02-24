`ifndef siicpu_ex_reg
`define siicpu_ex_reg

`include "unit/define.v"

module ex_reg (
    input wire clk,
    input wire reset,
    // pc
    input wire [`WORD_ADDR_BUS] id_pc,
    output reg [`WORD_ADDR_BUS] ex_pc,
    // insn
    input wire [`DATA_WIDTH_INSN - 1 : 0] id_insn,
    output reg [`DATA_WIDTH_INSN - 1 : 0] ex_insn,
    // en
    input wire id_en,
    output reg ex_en,
    // from "alu" (to "mem_ctrl" or "gpr")
    input wire [`DATA_WIDTH_GPR - 1 : 0] alu_out,
    output reg [`DATA_WIDTH_GPR - 1 : 0] ex_alu_out,
    // to gpr
    input wire id_gpr_we_,
    input wire [$clog2(`DATA_HIGH_GPR) - 1 : 0] id_dst_addr,
    output reg ex_gpr_we_,
    output reg [$clog2(`DATA_HIGH_GPR) - 1 : 0] ex_dst_addr,
    // to mem
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0] id_mem_op,
    input wire [`DATA_WIDTH_GPR - 1 : 0] id_gpr_data,
    output reg [`DATA_WIDTH_MEM_OP - 1 : 0] ex_mem_op,
    output reg [`DATA_WIDTH_GPR - 1 : 0] ex_gpr_data
);

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        ex_pc <= 0;
        ex_insn <= 0;
        ex_en <= 0;
        ex_alu_out <= 0;
        ex_gpr_we_ <= 0;
        ex_dst_addr <= 0;
        ex_mem_op <= 0;
        ex_gpr_data <= 0;
    end else begin
        ex_pc <= id_pc;
        ex_insn <= id_insn;
        ex_en <= id_en;
        ex_alu_out <= alu_out;
        ex_gpr_we_ <= id_gpr_we_;
        ex_dst_addr <= id_dst_addr;
        ex_mem_op <= id_mem_op;
        ex_gpr_data <= id_gpr_data;
    end
end

endmodule

`endif