`ifndef siicpu_id_reg
`define siicpu_id_reg

`include "unit/define.v"

module id_reg (
    input wire clk,
    input wire reset,
    // pc
    input wire [`WORD_ADDR_BUS] if_pc,
    output reg [`WORD_ADDR_BUS] id_pc,
    // insn
    input wire [`DATA_WIDTH_INSN - 1 : 0] if_insn,
    output reg [`DATA_WIDTH_INSN - 1 : 0] id_insn,
    // en
    input wire if_en,
    output reg id_en,
    // to gpr
    input wire gpr_we_,
    input wire [$clog2(`DATA_HIGH_GPR) - 1 : 0] dst_addr, // only used when "memory" or "alu" write to gpr 
    output reg id_gpr_we_,
    output reg [$clog2(`DATA_HIGH_GPR) - 1 : 0] id_dst_addr,
    // to alu
    input wire [`DATA_WIDTH_ALU_OP - 1 : 0] alu_op,
    input wire [`DATA_WIDTH_GPR - 1 : 0] alu_in_0,
    input wire [`DATA_WIDTH_GPR - 1 : 0] alu_in_1,
    output reg [`DATA_WIDTH_ALU_OP - 1 : 0] id_alu_op,
    output reg [`DATA_WIDTH_GPR - 1 : 0] id_alu_in_0,
    output reg [`DATA_WIDTH_GPR - 1 : 0] id_alu_in_1,
    // to mem
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0] mem_op,
    input wire [`DATA_WIDTH_GPR - 1 : 0] gpr_data,
    output reg [`DATA_WIDTH_MEM_OP - 1 : 0] id_mem_op,
    output reg [`DATA_WIDTH_GPR - 1 : 0] id_gpr_data
);

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        id_pc <= 0;
        id_insn <= 0;
        id_en <= 0;
        id_gpr_we_ <= 0;
        id_dst_addr <= 0;
        id_alu_op <= 0;
        id_alu_in_0 <= 0;
        id_alu_in_1 <= 0;
        id_mem_op <= 0;
        id_gpr_data <= 0;
    end else begin
        id_pc <= if_pc;
        id_insn <= if_insn;
        id_en <= if_en;
        id_gpr_we_ <= gpr_we_;
        id_dst_addr <= dst_addr;
        id_alu_op <= alu_op;
        id_alu_in_0 <= alu_in_0;
        id_alu_in_1 <= alu_in_1;
        id_mem_op <= mem_op;
        id_gpr_data <= gpr_data;
    end
end

endmodule

`endif