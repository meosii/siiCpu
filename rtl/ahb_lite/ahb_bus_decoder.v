`ifndef AHB_BUS_DECODER
`define AHB_BUS_DECODER
`include "define.v"
module ahb_bus_decoder (
    input wire                          clk,
    input wire                          rst_n,
    // cpu
    input wire [`WORD_WIDTH - 1 : 0]    CPU_HADDR,
    // clint
    input wire [`WORD_WIDTH - 1 : 0]    CLINT_HRDATA,
    input wire                          CLINT_HREADY,
    input wire [1 : 0]                  CLINT_HRESP,
    // plic
    input wire [`WORD_WIDTH - 1 : 0]    PLIC_HRDATA,
    input wire                          PLIC_HREADY,
    input wire [1 : 0]                  PLIC_HRESP,
    // uart
    input wire [`WORD_WIDTH - 1 : 0]    UART_HRDATA,
    input wire                          UART_HREADY,
    input wire [1 : 0]                  UART_HRESP,
    // spi
    input wire [`WORD_WIDTH - 1 : 0]    SPI_HRDATA,
    input wire                          SPI_HREADY,
    input wire [1 : 0]                  SPI_HRESP,
    // outputs
    output wire                         HSEL_CLINT, // clint
    output wire                         HSEL_PLIC,  // plic
    output wire                         HSEL_UART,  // uart
    output wire                         HSEL_SPI,   // spi
    output wire [`WORD_WIDTH - 1 : 0]   CPU_HRDATA,
    output wire                         CPU_HREADY,
    output wire [1 : 0]                 CPU_HRESP
);

assign HSEL_CLINT   = (CPU_HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_CLINT_WIDTH] == `BUS_ADDR_HIGH_CLINT )? 1'b1 : 1'b0;
assign HSEL_PLIC    = (CPU_HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_PLIC_WIDTH] == `BUS_ADDR_HIGH_PLIC   )? 1'b1 : 1'b0;
assign HSEL_UART    = (CPU_HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_UART0_WIDTH] == `BUS_ADDR_HIGH_UART0 )? 1'b1 : 1'b0;
assign HSEL_SPI     = (CPU_HADDR[`WORD_WIDTH - 1 : `WORD_WIDTH - `BUS_ADDR_HIGH_SPI0_WIDTH] == `BUS_ADDR_HIGH_SPI0   )? 1'b1 : 1'b0;

localparam NO_CHOOSE        = 3'd0;
localparam CLINT_CHOOSE_EN  = 3'd1;
localparam PLIC_CHOOSE_EN   = 3'd2;
localparam UART_CHOOSE_EN   = 3'd3;
localparam SPI_CHOOSE_EN    = 3'd4;

reg [2:0] slave_choose;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        slave_choose <= NO_CHOOSE;
    end else if (HSEL_CLINT) begin
        slave_choose <= CLINT_CHOOSE_EN;
    end else if (HSEL_PLIC) begin
        slave_choose <= PLIC_CHOOSE_EN;
    end else if (HSEL_UART) begin
        slave_choose <= UART_CHOOSE_EN;
    end else if (HSEL_SPI) begin
        slave_choose <= SPI_CHOOSE_EN;
    end 
end

assign CPU_HRDATA = (slave_choose == CLINT_CHOOSE_EN)?  CLINT_HRDATA    :
                    (slave_choose == PLIC_CHOOSE_EN )?  PLIC_HRDATA     :
                    (slave_choose == UART_CHOOSE_EN )?  UART_HRDATA     :
                    (slave_choose == SPI_CHOOSE_EN  )?  SPI_HRDATA      : `WORD_WIDTH'b0;

assign CPU_HREADY = (slave_choose == CLINT_CHOOSE_EN)?  CLINT_HREADY    :
                    (slave_choose == PLIC_CHOOSE_EN )?  PLIC_HREADY     :
                    (slave_choose == UART_CHOOSE_EN )?  UART_HREADY     :
                    (slave_choose == SPI_CHOOSE_EN  )?  SPI_HREADY      : 1'b0;

assign CPU_HRESP = (slave_choose == CLINT_CHOOSE_EN)?  CLINT_HRESP      :
                    (slave_choose == PLIC_CHOOSE_EN )?  PLIC_HRESP      :
                    (slave_choose == UART_CHOOSE_EN )?  UART_HRESP      :
                    (slave_choose == SPI_CHOOSE_EN  )?  SPI_HRESP       : 2'b0;

endmodule
`endif