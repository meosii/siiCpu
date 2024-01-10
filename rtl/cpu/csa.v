`ifndef CSA
`define CSA
`include "define.v"
// Carry Save Adder
module csa #(
    parameter SIGNED_WORD_WIDTH = `WORD_WIDTH + 1,
    parameter PARTIAL_PRODUCT_WIDTH = SIGNED_WORD_WIDTH + SIGNED_WORD_WIDTH
)(
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0] in_1,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0] in_2,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0] in_3,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry
);

assign sum = in_1 ^ in_2 ^ in_3;
assign carry = ((in_1 & in_2) | (in_1 & in_3) | (in_2 & in_3))<<1;

endmodule
`endif