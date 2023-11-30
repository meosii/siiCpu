`timescale 1ns/1ns
`include "../rtl/define.v"
module tb_soc ();

reg                         CPU_EN;
reg                         CLK_IN;
reg                         RST_N;
reg                         RX;
wire                        TX;

wire [7 : 0]                DTUBE_HEX0;
wire [7 : 0]                DTUBE_HEX1;
wire [7 : 0]                DTUBE_HEX2;
wire [7 : 0]                DTUBE_HEX3;
wire [7 : 0]                DTUBE_HEX4;
wire [7 : 0]                DTUBE_HEX5;

soc_top u_soc_top(
    .CPU_EN         (CPU_EN         ),
    .CLK_IN         (CLK_IN         ),
    .RST_N          (RST_N          ),
    .RX             (RX             ),
    .TX             (TX             ),
    .DTUBE_HEX0     (DTUBE_HEX0     ),
    .DTUBE_HEX1     (DTUBE_HEX1     ),
    .DTUBE_HEX2     (DTUBE_HEX2     ),
    .DTUBE_HEX3     (DTUBE_HEX3     ),
    .DTUBE_HEX4     (DTUBE_HEX4     ),
    .DTUBE_HEX5     (DTUBE_HEX5     )
);

//////////// pc tx ////////////////////////////////////////////////////////
localparam BPS_115200           = 434;
localparam UART_START_WIDTH     = 1;
localparam UART_DATA_WIDTH      = 8;
localparam UART_CHECK_WIDTH     = 1;
localparam UART_STOP_WIDTH      = 1;
localparam UART_SYMBOL_WIDTH    = UART_START_WIDTH + UART_DATA_WIDTH + UART_CHECK_WIDTH + UART_STOP_WIDTH;

wire                            one_bit_finish;
wire                            one_trans_finish;
wire                            PcTx_data_check;
reg                             one_trans_start;    //
reg [UART_DATA_WIDTH-1 : 0]     PcTx_data;          //
reg [UART_SYMBOL_WIDTH - 1 :0]  PcTx_symbol;
reg                             one_transing_en;
reg [8:0]                       bps_cnt;
reg [4:0]                       bit_cnt; 
assign  one_bit_finish      = one_transing_en && (bps_cnt == (BPS_115200-1));
assign  one_trans_finish    = (bit_cnt == (UART_SYMBOL_WIDTH-1)) && one_bit_finish;
assign  PcTx_data_check     = ^PcTx_data[7:0];

always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
        one_transing_en <= 1'b0;
    end else if(one_trans_start) begin
        one_transing_en <= 1'b1;
    end else if(one_trans_finish) begin
        one_transing_en <= 1'b0;
    end
end

// bps_cnt: the transmission time of a bit in a set of symbols
always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
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
always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
        bit_cnt <= 5'd0;
    end else if(one_bit_finish) begin
        if (bit_cnt == (UART_SYMBOL_WIDTH-1)) begin   // one_trans finish(all bits trans finish)
            bit_cnt <= 5'd0;
        end else begin
            bit_cnt <= bit_cnt + 5'd1;
        end
    end
end

always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
        PcTx_symbol <= 8'b0;
    end else if (one_trans_start) begin
        PcTx_symbol <= {1'b1, PcTx_data_check, PcTx_data[7:0] , 1'b0};   // {stop bit, check bit, data, start bit}
    end
end

always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
        RX <= 1'b1;
    end else if (bps_cnt == 9'd1) begin  // When bps_cnt = 1, the transmitted bit value is updated
        RX <= PcTx_symbol[bit_cnt];
    end
end
//////////////////////////////////////////////////////////

parameter TIME_CLK_IN = 20;

always #(TIME_CLK_IN/2) CLK_IN = ~CLK_IN;

initial begin
    #0 begin
        CLK_IN = 0;
        CPU_EN = 0;
        RST_N = 0;
        one_trans_start = 1'b0;
        PcTx_data = 8'b0000_0000;
    end
    #22 begin
        RST_N = 1;
    end
    #20 begin
       CPU_EN = 1; 
    end
    #60 begin
        one_trans_start = 1'b1;
        PcTx_data = 8'b1001_0011;
    end
    #20 begin
        one_trans_start = 1'b0;
    end
    #50000
    $finish;
end

initial begin
    $dumpfile("soc.vcd");
    $dumpvars(0,tb_soc);
end

endmodule