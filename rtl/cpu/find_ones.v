`ifndef FIND_ONES
`define FIND_ONES
// Find the first non-zero digit (1)
// Dichotomy
`include "define.v"
module find_ones (
    input wire [`WORD_WIDTH-1 : 0]  data_in,
    output wire [4:0]               location_one
);

wire [15:0] data_1;
wire [7:0]  data_2;
wire [3:0]  data_3;
wire [1:0]  data_4;

assign location_one[4] = | data_in[31:16];
assign data_1 = (location_one[4])? data_in[31:16] : data_in[15:0];

assign location_one[3] = | data_1[15:8];
assign data_2 = (location_one[3])? data_1[15:8] : data_1[7:0];

assign location_one[2] = | data_2[7:4];
assign data_3 = (location_one[2])? data_2[7:4] : data_2[3:0];

assign location_one[1] = | data_3[3:2];
assign data_4 = (location_one[1])? data_3[3:2] : data_3[1:0];

assign location_one[0] = data_4[1];

endmodule
`endif