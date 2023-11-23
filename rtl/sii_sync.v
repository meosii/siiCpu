`ifndef SII_SYNC
`define SII_SYNC
module sii_sync (
    input wire      clk,
    input wire      rst_n,
    input wire      data,
    output reg      data_sync
);

reg data_r1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_r1     <= 1'b0;
        data_sync   <= 1'b0;
    end else begin
        data_r1     <= data;
        data_sync   <= data_r1;
    end
end

endmodule
`endif