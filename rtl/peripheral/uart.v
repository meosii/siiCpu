`ifndef UART
`define UART
`include "define.v"
module uart (
    input  wire                         clk,
    input  wire                         rst_n,    
    // ahb-lite
    input wire                          HSELx,
    input wire [`WORD_WIDTH - 1 : 0]    HADDR,
    input wire                          HWRITE,
    input wire [2 : 0]                  HSIZE,
    input wire [2 : 0]                  HBURST,     // not used
    input wire [1 : 0]                  HTRANS,
    input wire                          HMASTLOCK,  // not used
    input wire [`WORD_WIDTH - 1 : 0]    HWDATA,
    
    input wire                          RX,
    // int clear
    input wire                          uartTx_int_clear,
    input wire                          uartRx_int_clear,
    // outputs
    //ahb-lite
    output wire [`WORD_WIDTH - 1 : 0]   HRDATA,
    output wire                         HREADY,
    output wire [1 : 0]                 HRESP,
    // outputs
    output wire                         TX,
    output wire                         irq_uartTx,  // read the WO-reg
    output wire                         irq_uartRx
);

localparam NO_CHOOSE        = 2'd0;
localparam TX_CHOOSE_EN     = 2'd1;
localparam RX_CHOOSE_EN     = 2'd2;

// uart trans data config
localparam BPS_115200       = 434;  //The number of T cycles it takes to send a bit of data
                                    // In serial communication, the bit rate is equal to the baud rate,
                                    // and one symbol is one bit.
localparam UART_START_WIDTH     = 1;
localparam UART_DATA_WIDTH      = 8;
localparam UART_CHECK_WIDTH     = 1;
localparam UART_STOP_WIDTH      = 1;
localparam UART_SYMBOL_WIDTH    = UART_START_WIDTH + UART_DATA_WIDTH + UART_CHECK_WIDTH + UART_STOP_WIDTH;

wire hsel_tx;
wire hsel_rx;
// uart_tx
wire [`WORD_WIDTH - 1 : 0]      TX_HRDATA;
wire                            TX_HREADY;
wire [1 : 0]                    TX_HRESP;
// uart_rx
wire [`WORD_WIDTH - 1 : 0]      RX_HRDATA;
wire                            RX_HREADY;
wire [1 : 0]                    RX_HRESP;

assign hsel_tx = ((HADDR[`BUS_ADDR_LOCA_UART_TXRX] == `BUS_ADDR_UART_TX) && HSELx)? 1'b1 : 1'b0;
assign hsel_rx = ((HADDR[`BUS_ADDR_LOCA_UART_TXRX] == `BUS_ADDR_UART_RX) && HSELx)? 1'b1 : 1'b0;

reg [1:0] TxRx_choose;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        TxRx_choose <= NO_CHOOSE;
    end else if (hsel_tx) begin
        TxRx_choose <= TX_CHOOSE_EN;
    end else if (hsel_rx) begin
        TxRx_choose <= RX_CHOOSE_EN;
    end
end

uart_tx #(
    .BPS_115200         (BPS_115200         ),
    .UART_START_WIDTH   (UART_START_WIDTH   ),
    .UART_DATA_WIDTH    (UART_DATA_WIDTH    ),
    .UART_CHECK_WIDTH   (UART_CHECK_WIDTH   ),
    .UART_STOP_WIDTH    (UART_STOP_WIDTH    ),
    .UART_SYMBOL_WIDTH  (UART_SYMBOL_WIDTH  )
) u_uart_tx (
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .hsel_tx            (hsel_tx            ),
    .HADDR              (HADDR              ),
    .HWRITE             (HWRITE             ),
    .HSIZE              (HSIZE              ),
    .HBURST             (HBURST             ),
    .HTRANS             (HTRANS             ),
    .HMASTLOCK          (HMASTLOCK          ),
    .HWDATA             (HWDATA             ),
    .uartTx_int_clear   (uartTx_int_clear   ),
    // outputs
    .HRDATA             (TX_HRDATA          ),
    .HREADY             (TX_HREADY          ),
    .HRESP              (TX_HRESP           ),
    .TX                 (TX                 ),
    .irq_uartTx         (irq_uartTx         )
);

uart_rx #(
    .BPS_115200         (BPS_115200         ),
    .UART_START_WIDTH   (UART_START_WIDTH   ),
    .UART_DATA_WIDTH    (UART_DATA_WIDTH    ),
    .UART_CHECK_WIDTH   (UART_CHECK_WIDTH   ),
    .UART_STOP_WIDTH    (UART_STOP_WIDTH    ),
    .UART_SYMBOL_WIDTH  (UART_SYMBOL_WIDTH  )
) u_uart_rx(
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .hsel_rx            (hsel_rx            ),
    .HADDR              (HADDR              ),
    .HWRITE             (HWRITE             ),
    .HSIZE              (HSIZE              ),
    .HBURST             (HBURST             ),
    .HTRANS             (HTRANS             ),
    .HMASTLOCK          (HMASTLOCK          ),
    .HWDATA             (HWDATA             ),
    .RX                 (RX                 ),
    .uartRx_int_clear   (uartRx_int_clear   ),
    // outputs
    .HRDATA             (RX_HRDATA          ),
    .HREADY             (RX_HREADY          ),
    .HRESP              (RX_HRESP           ),
    .irq_uartRx         (irq_uartRx         )
);

assign HRDATA = (TxRx_choose == TX_CHOOSE_EN)?  TX_HRDATA   :
                (TxRx_choose == RX_CHOOSE_EN)?  RX_HRDATA   : `WORD_WIDTH'b0;

assign HREADY = (TxRx_choose == TX_CHOOSE_EN)?  TX_HREADY   :
                (TxRx_choose == RX_CHOOSE_EN)?  RX_HREADY   : 1'b0;

assign HRESP =  (TxRx_choose == TX_CHOOSE_EN)?  TX_HRESP    :
                (TxRx_choose == RX_CHOOSE_EN)?  RX_HRESP    : 2'b0;

endmodule
`endif