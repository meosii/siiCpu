`ifndef AHB_BUS_DECODER
`define AHB_BUS_DECODER
`include "define.v"
module ahb_bus_decoder (
    input wire [`WORD_WIDTH - 1 : 0]    HADDR,
    output wire                         HSEL_1, // clint
    output wire                         HSEL_2, // plic
    output wire                         HSEL_3, // uart0
    output wire                         HSEL_4  // spi0
);

assign HSEL_1 = (HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_CLINT_WIDTH] == `BUS_ADDR_HIGH_CLINT )? 1'b1 : 1'b0;
assign HSEL_2 = (HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_PLIC_WIDTH] == `BUS_ADDR_HIGH_PLIC   )? 1'b1 : 1'b0;
assign HSEL_3 = (HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_UART0_WIDTH] == `BUS_ADDR_HIGH_UART0 )? 1'b1 : 1'b0;
assign HSEL_4 = (HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_SPI0_WIDTH] == `BUS_ADDR_HIGH_SPI0   )? 1'b1 : 1'b0;

endmodule
`endif