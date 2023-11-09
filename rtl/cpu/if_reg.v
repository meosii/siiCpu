`ifndef SIICPU_IF_REG
`define SIICPU_IF_REG

`include "define.v"

module if_reg (
    input wire                          clk,
    input wire                          rst_n,
    input wire                          cpu_en,
    input wire                          if_stall,
    input wire                          if_flush,
    input wire [`PC_WIDTH-1 : 0]        pc,
    input wire [`WORD_WIDTH - 1 : 0]    insn,
    input wire                          predt_br_taken,
    output reg [`PC_WIDTH-1 : 0]        if_pc,
    output reg [`WORD_WIDTH - 1 : 0]    if_insn,
    output reg                          if_en,
    output reg                          if_predt_br_taken
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        if_en               <= 1'b0;
        if_pc               <= `PC_WIDTH'b0;
        if_insn             <= `WORD_WIDTH'b0;
        if_predt_br_taken   <= 1'b0;
    end else if (if_flush) begin
        if_en               <= 1'b0;
        if_pc               <= `PC_WIDTH'b0;
        if_insn             <= `WORD_WIDTH'b0;
        if_predt_br_taken   <= 1'b0;
    end else if (cpu_en && !if_stall) begin
        if_en               <= 1'b1;
        if_pc               <= pc;
        if_insn             <= insn;
        if_predt_br_taken   <= predt_br_taken;
    end
end

endmodule
`endif