`ifndef SII_POS
`define SII_POS
module sii_pos (
    input wire      clk,
    input wire      rst_n,
    input wire      data,
    output wire     data_pos
);

reg data_r1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_r1     <= 1'b0;
    end else begin
        data_r1     <= data;
    end
end

assign data_pos = data && !data_r1;

endmodule
`endif