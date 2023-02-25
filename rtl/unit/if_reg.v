`ifndef siicpu_if_reg
`define siicpu_if_reg

`include "unit/define.v"

module if_reg (
    input wire cpu_en,
    input wire clk,
    input wire reset,
    // when br_taken, jump to br_addr
    input wire br_taken,
    input wire [`WORD_ADDR_BUS] br_addr,
    input wire [`WORD_WIDTH - 1 : 0] insn,
    output reg [`WORD_ADDR_BUS] if_pc,
    output reg [`WORD_WIDTH - 1 : 0] if_insn,
    output reg if_en
);

always @(posedge clk or negedge reset) begin
    if (!reset | !cpu_en) begin
        if_en <= 0;
        if_pc <= 0;
        if_insn <= 0;
    end else if (br_taken) begin
        if_en <= 1;
        if_pc <= br_addr;
        if_insn <= insn;
    end else begin
        if_en <= 1;
        if_pc <= if_pc + 4;
        if_insn <= insn;
    end
end

endmodule

`endif