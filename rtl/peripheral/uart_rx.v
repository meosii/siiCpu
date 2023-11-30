`ifndef UART_RX
`define UART_RX
`include "define.v"
module uart_rx #(
    parameter BPS_115200        = 434,
    parameter UART_START_WIDTH  = 1,
    parameter UART_DATA_WIDTH   = 8,
    parameter UART_CHECK_WIDTH  = 1,
    parameter UART_STOP_WIDTH   = 1,
    parameter UART_SYMBOL_WIDTH = UART_START_WIDTH + UART_DATA_WIDTH + UART_CHECK_WIDTH + UART_STOP_WIDTH
)(
    input  wire                         clk,
    input  wire                         rst_n,    
    // ahb-lite
    input wire                          hsel_rx,
    input wire [`WORD_WIDTH - 1 : 0]    HADDR,
    input wire                          HWRITE,
    input wire [2 : 0]                  HSIZE,
    input wire [2 : 0]                  HBURST,     // not used
    input wire [1 : 0]                  HTRANS,
    input wire                          HMASTLOCK,  // not used
    input wire [`WORD_WIDTH - 1 : 0]    HWDATA,
    
    input wire                          RX,
    // int clear
    input wire                          uartRx_int_clear,
    // outputs
    //ahb-lite
    output reg [`WORD_WIDTH - 1 : 0]    HRDATA,
    output reg                          HREADY,
    output reg [1 : 0]                  HRESP,
    // outputs
    output reg                          irq_uartRx
);

localparam REG_REMAIN_BIT_WIDTH = `WORD_WIDTH-UART_DATA_WIDTH;

// ahb write or read
wire                            uart_rx_wen;
wire                            uart_rx_ren;
// uart_ReceiveData register
wire                            uart_ReceiveData_wen;
wire                            uart_ReceiveData_ren;
reg [`WORD_WIDTH - 1 : 0]       uart_ReceiveData;   // RO

assign  uart_rx_wen             = hsel_rx &&  HWRITE && (HTRANS == `HTRANS_NONSEQ);
assign  uart_rx_ren             = hsel_rx && !HWRITE && (HTRANS == `HTRANS_NONSEQ);
assign  uart_ReceiveData_wen    = (HADDR == `BUS_ADDR_UART_RECEIVEDATA) && uart_rx_wen;
assign  uart_ReceiveData_ren    = (HADDR == `BUS_ADDR_UART_RECEIVEDATA) && uart_rx_ren;

// RX receive
wire                            rx_start;
wire                            one_bit_finish;
wire                            one_trans_finish;
wire                            rx_sample_en;
wire                            odd_check;
wire                            rx_trans_correct; // {stop bit, check bit, data, start bit} = {1'b1, , , 1'b0}
reg                             one_transing_en; // Indicates the start to the end of a transmission
reg                             RX_r1;
reg [8:0]                       bps_cnt;
reg [4:0]                       bit_cnt;
reg [UART_SYMBOL_WIDTH-1 : 0]   receive_symbol;

assign  rx_start            =   !RX && RX_r1    && !one_transing_en;
assign  one_bit_finish      =   one_transing_en && (bps_cnt == (BPS_115200-1));
assign  one_trans_finish    =   (bit_cnt == (UART_SYMBOL_WIDTH-1)) && one_bit_finish;
assign  rx_sample_en        =   (bps_cnt == (BPS_115200/2)) && one_transing_en;
assign  odd_check           =   ^receive_symbol[UART_SYMBOL_WIDTH-3 : 1];
assign  rx_trans_correct    =   one_trans_finish                                    &&
                                receive_symbol[UART_SYMBOL_WIDTH-1]                 &&  // stop  bit
                                (odd_check == receive_symbol[UART_SYMBOL_WIDTH-2])  &&  // check bit
                                !receive_symbol[0];                                     // start bit

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        RX_r1 <= 1'b1;
    end else begin
        RX_r1 <= RX;
    end
end
// one trans
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        one_transing_en <= 1'b0;
    end else if(rx_start) begin
        one_transing_en <= 1'b1;
    end else if(one_trans_finish) begin
        one_transing_en <= 1'b0;
    end
end

// bps_cnt: the transmission time of a bit in a set of symbols
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bps_cnt <= 8'b0;
    end else if(one_transing_en) begin
        if (bps_cnt == (BPS_115200-1)) begin
            bps_cnt <= 8'b0;
        end else begin
            bps_cnt <= bps_cnt + 8'd1;
        end
    end
end

// bit_cnt: The total number of bits for start, data, check, and end bits
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bit_cnt <= 5'd0;
    end else if(one_bit_finish) begin
        if (bit_cnt == (UART_SYMBOL_WIDTH-1)) begin   // one_trans finish(all bits trans finish)
            bit_cnt <= 5'd0;
        end else begin
            bit_cnt <= bit_cnt + 5'd1;
        end
    end
end

// rx->data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        receive_symbol <= {UART_SYMBOL_WIDTH{1'b0}};
    end else if (rx_sample_en && (bit_cnt == 5'd0)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:1], RX}; // {stop bit, check bit, data, start bit}
    end else if (rx_sample_en && (bit_cnt == 5'd1)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:2], RX, receive_symbol[0]};
    end else if (rx_sample_en && (bit_cnt == 5'd2)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:3], RX, receive_symbol[1:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd3)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:4], RX, receive_symbol[2:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd4)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:5], RX, receive_symbol[3:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd5)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:6], RX, receive_symbol[4:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd6)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:7], RX, receive_symbol[5:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd7)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:8], RX, receive_symbol[6:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd8)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1:9], RX, receive_symbol[7:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd9)) begin
        receive_symbol <= {receive_symbol[UART_SYMBOL_WIDTH-1], RX, receive_symbol[8:0]};
    end else if (rx_sample_en && (bit_cnt == 5'd10)) begin
        receive_symbol <= {RX, receive_symbol[9:0]};
    end
end

// rx_data to uart_ReceiveData
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_ReceiveData <= 32'b0;
    end else if (one_trans_finish && rx_trans_correct) begin
        uart_ReceiveData <= {{REG_REMAIN_BIT_WIDTH{1'b0}}, receive_symbol[UART_START_WIDTH+UART_DATA_WIDTH-1 : UART_START_WIDTH]};
    end
end

// uart_rx interrupt: write the RO register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        irq_uartRx <= 1'b0;
    end else if (uartRx_int_clear) begin
        irq_uartRx <= 1'b0;
    end else if (uart_ReceiveData_wen) begin
        irq_uartRx <= 1'b1;
    end
end

// ahb read
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        HREADY  <= 1'b0;
        HRESP   <= `HRESP_ERROR;
    end else if (uart_ReceiveData_ren) begin
        HREADY  <= 1'b1;
        HRESP   <= `HRESP_OKAY;
    end else if (uart_ReceiveData_wen) begin // uart_ReceiveData cannt write, error
        HREADY  <= 1'b0;
        HRESP   <= `HRESP_ERROR;
    end else begin
        HREADY  <= 1'b1;
        HRESP   <= `HRESP_OKAY;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        HRDATA <= `WORD_WIDTH'b0;
    end else if (uart_ReceiveData_ren) begin
        HRDATA <= uart_ReceiveData;
    end else begin
        HRDATA <= `WORD_WIDTH'b0;
    end
end

endmodule
`endif