`include "define.v"
module if_reg (
    input wire cpu_en,
    input wire clk,
    input wire reset,
    input wire br_taken,
    input wire [`WORD_ADDR_BUS] br_addr,
    input wire [`DATA_WIDTH_INSN - 1:0] insn,
    output reg [`WORD_ADDR_BUS] if_pc,
    output reg [`DATA_WIDTH_INSN - 1:0] if_insn,
    output wire if_en
);

assign if_en = (cpu_en && reset)? 1:0;

always @(posedge clk or negedge reset) begin
    if (!reset | !cpu_en) begin
        if_pc <= 0;
        if_insn <= 0;
    end else if (br_taken) begin
        if_pc <= br_addr;
        if_insn <= insn;
    end else begin
        if_pc <= if_pc + 4;
        if_insn <= insn;
    end
end

endmodule