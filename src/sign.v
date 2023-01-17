module sign(
input wire [7:0] a,
output wire [7:0] b
);

assign b = $signed(a);

endmodule