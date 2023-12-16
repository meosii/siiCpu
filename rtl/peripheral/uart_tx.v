`ifndef UART_TX
`define UART_TX
`include "define.v"
module uart_tx #(
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
    input wire                          hsel_tx,
    input wire [`WORD_WIDTH - 1 : 0]    HADDR,
    input wire                          HWRITE,
    input wire [2 : 0]                  HSIZE,
    input wire [2 : 0]                  HBURST,     // not used
    input wire [1 : 0]                  HTRANS,
    input wire                          HMASTLOCK,  // not used
    input wire [`WORD_WIDTH - 1 : 0]    HWDATA,
    // int clear
    input wire                          uartTx_int_clear,
    // outputs
    //ahb-lite
    output reg [`WORD_WIDTH - 1 : 0]    HRDATA,
    output reg                          HREADY,
    output reg [1 : 0]                  HRESP,
    // outputs
    output reg                          TX,
    output reg                          irq_uartTx   // read the WO-reg
);

// ahb write or read
wire                            uart_tx_wen;
wire                            uart_tx_ren;
// uart_TransData register
wire                            uart_TransData_wen;
wire                            uart_TransData_ren;
reg                             uart_TransData_wen_r1;
reg [`WORD_WIDTH - 1 : 0]       uart_TransData; // ahb_data to uart_tx, write only
// uart_tx_fifo: data width - 32bits, data depth - 4
wire                            tx_fifo_sclr;
wire                            tx_fifo_empty;
wire                            tx_fifo_full;
wire [31:0]                     tx_fifo_rdata;
wire [2:0]                      tx_fifo_usedw;
reg                             tx_fifo_rdreq;
reg                             tx_fifo_rdreq_r1;

// HWDATA has 32bits, while the tx_data only has 8 bits, transmit it in 4 times
// Respectively are tx_symbol_1, tx_symbol_2, tx_symbol_3, tx_symbol_4. 
wire                            tx_data_1_check;    // odd
wire                            tx_data_2_check;    // odd
wire                            tx_data_3_check;    // odd
wire                            tx_data_4_check;    // odd
reg [UART_SYMBOL_WIDTH - 1 :0]  tx_symbol_1;
reg [UART_SYMBOL_WIDTH - 1 :0]  tx_symbol_2;
reg [UART_SYMBOL_WIDTH - 1 :0]  tx_symbol_3;
reg [UART_SYMBOL_WIDTH - 1 :0]  tx_symbol_4;
// four tx transmission
reg                             tx_4trans_start;
wire                            tx_4trans_finish;
reg                             tx_4transing_en;
reg [2:0]                       tx_4trans_count; // trans which one, 1:data_1; 2:data_2; 3:data_3; 4:data_4
// One tx transmission
wire                            one_bit_finish;
wire                            one_trans_1_start;
wire                            one_trans_2_start;
wire                            one_trans_3_start;
wire                            one_trans_4_start;
wire                            one_trans_finish;
reg                             one_transing_en; // Indicates the start to the end of a transmission
reg [8:0]                       bps_cnt;
reg [4:0]                       bit_cnt;    // The number of bits that have been transmitted

ip_uart_tx_fifo u_uart_tx_fifo(
	.clock      (clk                    ),
	.data       (HWDATA                 ),
	.rdreq      (tx_fifo_rdreq          ),
	.sclr       (tx_fifo_sclr           ),
	.wrreq      (uart_TransData_wen_r1  ),
	.empty      (tx_fifo_empty          ),
	.full       (tx_fifo_full           ),
	.q          (tx_fifo_rdata          ),
	.usedw      (tx_fifo_usedw          )
);

assign  uart_tx_wen         = hsel_tx &&  HWRITE && (HTRANS == `HTRANS_NONSEQ);
assign  uart_tx_ren         = hsel_tx && !HWRITE && (HTRANS == `HTRANS_NONSEQ);
assign  uart_TransData_wen  = (HADDR == `BUS_ADDR_UART_TRANSDATA) && uart_tx_wen;
assign  uart_TransData_ren  = (HADDR == `BUS_ADDR_UART_TRANSDATA) && uart_tx_ren;
assign  tx_fifo_sclr        = !rst_n; // flush the tx_fifo

// tx_fifo
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_fifo_rdreq <= 1'b0;
    end else if (!tx_fifo_empty && !tx_fifo_rdreq && !tx_fifo_rdreq_r1 && !tx_4trans_start && !tx_4transing_en) begin
        tx_fifo_rdreq <= 1'b1;
    end else begin
        tx_fifo_rdreq <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_fifo_rdreq_r1 <= 1'b0;
    end else begin
        tx_fifo_rdreq_r1 <= tx_fifo_rdreq;
    end
end

// uart_tx interrupt: read the WO register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        irq_uartTx <= 1'b0;
    end else if (uartTx_int_clear) begin
        irq_uartTx <= 1'b0;
    end else if (uart_TransData_ren) begin
        irq_uartTx <= 1'b1;
    end
end

// ahb write
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_TransData_wen_r1 <= 1'b0;
    end else begin
        uart_TransData_wen_r1 <= uart_TransData_wen;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_TransData <= 32'b0;
    end else if (uart_TransData_wen_r1) begin
        uart_TransData <= HWDATA;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        HREADY  <= 1'b0;
        HRESP   <= `HRESP_ERROR;
    end else if (uart_TransData_wen) begin
        HREADY  <= 1'b1;
        HRESP   <= `HRESP_OKAY;
    end else if (uart_TransData_ren) begin // uart_TransData cannt read, error
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
    end else begin
        HRDATA <= `WORD_WIDTH'b0;
    end
end

// TX transing: 4 tx transmissions for a HWDATA

assign  one_bit_finish      = one_transing_en && (bps_cnt == (BPS_115200-1));
assign  one_trans_finish    = (bit_cnt == (UART_SYMBOL_WIDTH-1)) && one_bit_finish;   // all bits trans finish
assign  one_trans_1_start   = tx_4trans_start;
assign  one_trans_2_start   = one_trans_finish && (tx_4trans_count == 3'd1);
assign  one_trans_3_start   = one_trans_finish && (tx_4trans_count == 3'd2);
assign  one_trans_4_start   = one_trans_finish && (tx_4trans_count == 3'd3);
assign  tx_4trans_finish    = one_trans_finish && (tx_4trans_count == 3'd4);

assign tx_data_1_check = ^tx_fifo_rdata[7:0];
assign tx_data_2_check = ^tx_fifo_rdata[15:8];
assign tx_data_3_check = ^tx_fifo_rdata[23:16];
assign tx_data_4_check = ^tx_fifo_rdata[31:24];

// four trans
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_4trans_start <= 1'b0;
    end else if (tx_fifo_rdreq_r1) begin
        tx_4trans_start <= 1'b1;            // Synchronizing with fifo_rdata
    end else begin
        tx_4trans_start <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_4transing_en <= 1'b0;
    end else if (tx_4trans_start) begin
        tx_4transing_en <= 1'b1;
    end else if (tx_4trans_finish) begin
        tx_4transing_en <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_4trans_count <= 3'd0;
    end else if (one_trans_1_start) begin
        tx_4trans_count <= 3'd1;            // trans_1
    end else if (one_trans_finish) begin
        if (tx_4trans_count == 3'd4) begin  // trans_4 finish
            tx_4trans_count <= 3'd0;
        end else begin
            tx_4trans_count <= tx_4trans_count + 3'd1;
        end
    end
end

// one trans
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        one_transing_en <= 1'b0;
    end else if(one_trans_1_start || one_trans_2_start || one_trans_3_start || one_trans_4_start) begin
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

// tx output

// without check_bit
//always @(posedge clk or negedge rst_n) begin
//    if (!rst_n) begin
//        tx_symbol_1 <= 8'b0;
//        tx_symbol_2 <= 8'b0;
//        tx_symbol_3 <= 8'b0;
//        tx_symbol_4 <= 8'b0;
//    end else if (tx_fifo_rdreq_r1) begin    // hold in one 4transing
//        tx_symbol_1 <= {1'b1, tx_fifo_rdata[7:0]  , 1'b0};   // Concatenate stop bit and start bit
//        tx_symbol_2 <= {1'b1, tx_fifo_rdata[15:8] , 1'b0};   // {stop bit, data, start bit}
//        tx_symbol_3 <= {1'b1, tx_fifo_rdata[23:16], 1'b0};   // Small endian transmission
//        tx_symbol_4 <= {1'b1, tx_fifo_rdata[31:24], 1'b0};
//    end
//end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_symbol_1 <= 8'b0;
        tx_symbol_2 <= 8'b0;
        tx_symbol_3 <= 8'b0;
        tx_symbol_4 <= 8'b0;
    end else if (tx_fifo_rdreq_r1) begin    // hold in one 4transing
        tx_symbol_1 <= {1'b1, tx_data_1_check, tx_fifo_rdata[7:0]  , 1'b0};   // Concatenate stop bit, check bit and start bit
        tx_symbol_2 <= {1'b1, tx_data_2_check, tx_fifo_rdata[15:8] , 1'b0};   // {stop bit, check bit, data, start bit}
        tx_symbol_3 <= {1'b1, tx_data_3_check, tx_fifo_rdata[23:16], 1'b0};   // Small endian transmission
        tx_symbol_4 <= {1'b1, tx_data_4_check, tx_fifo_rdata[31:24], 1'b0};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        TX <= 1'b1;
    end else if (bps_cnt == 9'd1) begin  // When bps_cnt = 1, the transmitted bit value is updated
        if (tx_4trans_count == 3'd1) begin              // WDATA[7:0]
            TX <= tx_symbol_1[bit_cnt];
        end else if (tx_4trans_count == 3'd2) begin     // WDATA[15:8]
            TX <= tx_symbol_2[bit_cnt];
        end else if (tx_4trans_count == 3'd3) begin     // WDATA[23:16]
            TX <= tx_symbol_3[bit_cnt];
        end else if (tx_4trans_count == 3'd4) begin     // WDATA[31:24]
            TX <= tx_symbol_4[bit_cnt];
        end
    end
end

endmodule
`endif