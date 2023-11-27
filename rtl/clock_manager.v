`ifndef CLOCK_MANAGER
`define CLOCK_MANAGER
module clock_manager (
    input wire                          CLK_IN,
    input wire                          RST_N,
    // outputs
    output wire                         clk_50, // 50MHz
    output wire                         clk_5,  // 5MHz
    output wire                         chip_rst_n,
    output reg                          io_rtcToggle
);

wire    pll_locked;

assign chip_rst_n = RST_N || pll_locked;

ip_soc_pll u_ip_soc_pll(
	.areset     (!RST_N     ),
	.inclk0     (CLK_IN     ),
	.c0         (clk_50     ),  // clk_50 = CLK_IN = 50MHz
	.c1         (clk_5      ),  // clk_5 = 1/10 CLK_IN = 5MHz
	.locked     (pll_locked )
);

always @(posedge clk_5 or negedge RST_N) begin
    if (!RST_N) begin
        io_rtcToggle <= 1'b0;
    end else begin
        io_rtcToggle <= ~io_rtcToggle; // to timer
    end
end

endmodule
`endif