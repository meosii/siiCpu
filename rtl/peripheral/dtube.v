`ifndef DTUBE
`define DTUBE
`include "define.v"
module dtube (
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
    // outputs
    //ahb-lite
    output reg [`WORD_WIDTH - 1 : 0]    HRDATA,
    output reg                          HREADY,
    output reg [1 : 0]                  HRESP,
    // outputs
    output wire [7 : 0]                 DTUBE_HEX0,
    output wire [7 : 0]                 DTUBE_HEX1,
    output wire [7 : 0]                 DTUBE_HEX2,
    output wire [7 : 0]                 DTUBE_HEX3,
    output wire [7 : 0]                 DTUBE_HEX4,
    output wire [7 : 0]                 DTUBE_HEX5
);

localparam ZERO_DISPLAY     = 8'b11000000;
localparam ONE_DISPLAY      = 8'b11111001;
localparam TWO_DISPLAY      = 8'b10100100;
localparam THREE_DISPLAY    = 8'b10110000;
localparam FOUR_DISPLAY     = 8'b10011001;
localparam FIVE_DISPLAY     = 8'b10010010;
localparam SIX_DISPLAY      = 8'b10000010;
localparam SEVEN_DISPLAY    = 8'b11111000;
localparam EIGHT_DISPLAY    = 8'b10000000;
localparam NINE_DISPLAY     = 8'b10010000;
localparam A_DISPLAY        = 8'b10001000;
localparam B_DISPLAY        = 8'b10000011;
localparam C_DISPLAY        = 8'b11000110;
localparam D_DISPLAY        = 8'b10100001;
localparam E_DISPLAY        = 8'b10000110;
localparam F_DISPLAY        = 8'b10001110;


wire dtube_wen;
wire dtube_ren;
wire dtube_Hex0Num_wen;
wire dtube_Hex0Num_ren;
wire dtube_Hex1Num_wen;
wire dtube_Hex1Num_ren;
wire dtube_Hex2Num_wen;
wire dtube_Hex2Num_ren;
wire dtube_Hex3Num_wen;
wire dtube_Hex3Num_ren;
wire dtube_Hex4Num_wen;
wire dtube_Hex4Num_ren;
wire dtube_Hex5Num_wen;
wire dtube_Hex5Num_ren;

reg dtube_Hex0Num_wen_r1;
reg dtube_Hex1Num_wen_r1;
reg dtube_Hex2Num_wen_r1;
reg dtube_Hex3Num_wen_r1;
reg dtube_Hex4Num_wen_r1;
reg dtube_Hex5Num_wen_r1;

reg [`WORD_WIDTH - 1 :0] dtube_Hex0Num;
reg [`WORD_WIDTH - 1 :0] dtube_Hex1Num;
reg [`WORD_WIDTH - 1 :0] dtube_Hex2Num;
reg [`WORD_WIDTH - 1 :0] dtube_Hex3Num;
reg [`WORD_WIDTH - 1 :0] dtube_Hex4Num;
reg [`WORD_WIDTH - 1 :0] dtube_Hex5Num;

assign  dtube_wen    = HSELx &&  HWRITE && (HTRANS == `HTRANS_NONSEQ);
assign  dtube_ren    = HSELx && !HWRITE && (HTRANS == `HTRANS_NONSEQ);
assign  dtube_Hex0Num_wen  = (HADDR == `BUS_ADDR_DTUBE_HEX0NUM) && dtube_wen;
assign  dtube_Hex0Num_ren  = (HADDR == `BUS_ADDR_DTUBE_HEX0NUM) && dtube_ren;
assign  dtube_Hex1Num_wen  = (HADDR == `BUS_ADDR_DTUBE_HEX1NUM) && dtube_wen;
assign  dtube_Hex1Num_ren  = (HADDR == `BUS_ADDR_DTUBE_HEX1NUM) && dtube_ren;
assign  dtube_Hex2Num_wen  = (HADDR == `BUS_ADDR_DTUBE_HEX2NUM) && dtube_wen;
assign  dtube_Hex2Num_ren  = (HADDR == `BUS_ADDR_DTUBE_HEX2NUM) && dtube_ren;
assign  dtube_Hex3Num_wen  = (HADDR == `BUS_ADDR_DTUBE_HEX3NUM) && dtube_wen;
assign  dtube_Hex3Num_ren  = (HADDR == `BUS_ADDR_DTUBE_HEX3NUM) && dtube_ren;
assign  dtube_Hex4Num_wen  = (HADDR == `BUS_ADDR_DTUBE_HEX4NUM) && dtube_wen;
assign  dtube_Hex4Num_ren  = (HADDR == `BUS_ADDR_DTUBE_HEX4NUM) && dtube_ren;
assign  dtube_Hex5Num_wen  = (HADDR == `BUS_ADDR_DTUBE_HEX5NUM) && dtube_wen;
assign  dtube_Hex5Num_ren  = (HADDR == `BUS_ADDR_DTUBE_HEX5NUM) && dtube_ren;

// ahb write
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dtube_Hex0Num_wen_r1 <= 1'b0;
        dtube_Hex1Num_wen_r1 <= 1'b0;
        dtube_Hex2Num_wen_r1 <= 1'b0;
        dtube_Hex3Num_wen_r1 <= 1'b0;
        dtube_Hex4Num_wen_r1 <= 1'b0;
        dtube_Hex5Num_wen_r1 <= 1'b0;
    end else begin
        dtube_Hex0Num_wen_r1 <= dtube_Hex0Num_wen;
        dtube_Hex1Num_wen_r1 <= dtube_Hex1Num_wen;
        dtube_Hex2Num_wen_r1 <= dtube_Hex2Num_wen;
        dtube_Hex3Num_wen_r1 <= dtube_Hex3Num_wen;
        dtube_Hex4Num_wen_r1 <= dtube_Hex4Num_wen;
        dtube_Hex5Num_wen_r1 <= dtube_Hex5Num_wen;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dtube_Hex0Num <= 8'b0;
    end else if (dtube_Hex0Num_wen_r1) begin
        dtube_Hex0Num <= HWDATA;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dtube_Hex1Num <= 8'b0;
    end else if (dtube_Hex1Num_wen_r1) begin
        dtube_Hex1Num <= HWDATA;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dtube_Hex2Num <= 8'b0;
    end else if (dtube_Hex2Num_wen_r1) begin
        dtube_Hex2Num <= HWDATA;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dtube_Hex3Num <= 8'b0;
    end else if (dtube_Hex3Num_wen_r1) begin
        dtube_Hex3Num <= HWDATA;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dtube_Hex4Num <= 8'b0;
    end else if (dtube_Hex4Num_wen_r1) begin
        dtube_Hex4Num <= HWDATA;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dtube_Hex5Num <= 8'b0;
    end else if (dtube_Hex5Num_wen_r1) begin
        dtube_Hex5Num <= HWDATA;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        HREADY  <= 1'b0;
        HRESP   <= `HRESP_ERROR;
    end else if (   dtube_Hex0Num_wen || dtube_Hex1Num_wen || dtube_Hex2Num_wen ||
                    dtube_Hex3Num_wen || dtube_Hex4Num_wen || dtube_Hex5Num_wen ||
                    dtube_Hex0Num_ren || dtube_Hex1Num_ren || dtube_Hex2Num_ren ||
                    dtube_Hex3Num_ren || dtube_Hex4Num_ren || dtube_Hex5Num_ren
                ) begin
        HREADY  <= 1'b1;
        HRESP   <= `HRESP_OKAY;
    end else if (dtube_wen || dtube_ren) begin // address error
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
    end else if (dtube_Hex0Num_ren) begin
        HRDATA <= dtube_Hex0Num;
    end else if (dtube_Hex1Num_ren) begin
        HRDATA <= dtube_Hex1Num;
    end else if (dtube_Hex2Num_ren) begin
        HRDATA <= dtube_Hex2Num;
    end else if (dtube_Hex3Num_ren) begin
        HRDATA <= dtube_Hex3Num;
    end else if (dtube_Hex4Num_ren) begin
        HRDATA <= dtube_Hex4Num;
    end else if (dtube_Hex5Num_ren) begin
        HRDATA <= dtube_Hex5Num;
    end else if (!dtube_ren) begin
        HRDATA <= `WORD_WIDTH'b0;
    end
end

// digital tube display
assign DTUBE_HEX0 = (dtube_Hex0Num[3:0] == 4'd1)?   ONE_DISPLAY     :
                    (dtube_Hex0Num[3:0] == 4'd2)?   TWO_DISPLAY     :
                    (dtube_Hex0Num[3:0] == 4'd3)?   THREE_DISPLAY   :
                    (dtube_Hex0Num[3:0] == 4'd4)?   FOUR_DISPLAY    :
                    (dtube_Hex0Num[3:0] == 4'd5)?   FIVE_DISPLAY    :
                    (dtube_Hex0Num[3:0] == 4'd6)?   SIX_DISPLAY     :
                    (dtube_Hex0Num[3:0] == 4'd7)?   SEVEN_DISPLAY   :
                    (dtube_Hex0Num[3:0] == 4'd8)?   EIGHT_DISPLAY   :
                    (dtube_Hex0Num[3:0] == 4'd9)?   NINE_DISPLAY    :   
                    (dtube_Hex0Num[3:0] == 4'd10)?  A_DISPLAY       :   
                    (dtube_Hex0Num[3:0] == 4'd11)?  B_DISPLAY       :   
                    (dtube_Hex0Num[3:0] == 4'd12)?  C_DISPLAY       :   
                    (dtube_Hex0Num[3:0] == 4'd13)?  D_DISPLAY       :   
                    (dtube_Hex0Num[3:0] == 4'd14)?  E_DISPLAY       :   
                    (dtube_Hex0Num[3:0] == 4'd15)?  F_DISPLAY       :   8'b1111_1111;

assign DTUBE_HEX1 = (dtube_Hex1Num[3:0] == 4'd1)?   ONE_DISPLAY     :
                    (dtube_Hex1Num[3:0] == 4'd2)?   TWO_DISPLAY     :
                    (dtube_Hex1Num[3:0] == 4'd3)?   THREE_DISPLAY   :
                    (dtube_Hex1Num[3:0] == 4'd4)?   FOUR_DISPLAY    :
                    (dtube_Hex1Num[3:0] == 4'd5)?   FIVE_DISPLAY    :
                    (dtube_Hex1Num[3:0] == 4'd6)?   SIX_DISPLAY     :
                    (dtube_Hex1Num[3:0] == 4'd7)?   SEVEN_DISPLAY   :
                    (dtube_Hex1Num[3:0] == 4'd8)?   EIGHT_DISPLAY   :
                    (dtube_Hex1Num[3:0] == 4'd9)?   NINE_DISPLAY    :   
                    (dtube_Hex1Num[3:0] == 4'd10)?  A_DISPLAY       :   
                    (dtube_Hex1Num[3:0] == 4'd11)?  B_DISPLAY       :   
                    (dtube_Hex1Num[3:0] == 4'd12)?  C_DISPLAY       :   
                    (dtube_Hex1Num[3:0] == 4'd13)?  D_DISPLAY       :   
                    (dtube_Hex1Num[3:0] == 4'd14)?  E_DISPLAY       :   
                    (dtube_Hex1Num[3:0] == 4'd15)?  F_DISPLAY       :   8'b1111_1111;


assign DTUBE_HEX2 = (dtube_Hex2Num[3:0] == 4'd1)?   ONE_DISPLAY     :
                    (dtube_Hex2Num[3:0] == 4'd2)?   TWO_DISPLAY     :
                    (dtube_Hex2Num[3:0] == 4'd3)?   THREE_DISPLAY   :
                    (dtube_Hex2Num[3:0] == 4'd4)?   FOUR_DISPLAY    :
                    (dtube_Hex2Num[3:0] == 4'd5)?   FIVE_DISPLAY    :
                    (dtube_Hex2Num[3:0] == 4'd6)?   SIX_DISPLAY     :
                    (dtube_Hex2Num[3:0] == 4'd7)?   SEVEN_DISPLAY   :
                    (dtube_Hex2Num[3:0] == 4'd8)?   EIGHT_DISPLAY   :
                    (dtube_Hex2Num[3:0] == 4'd9)?   NINE_DISPLAY    :   
                    (dtube_Hex2Num[3:0] == 4'd10)?  A_DISPLAY       :   
                    (dtube_Hex2Num[3:0] == 4'd11)?  B_DISPLAY       :   
                    (dtube_Hex2Num[3:0] == 4'd12)?  C_DISPLAY       :   
                    (dtube_Hex2Num[3:0] == 4'd13)?  D_DISPLAY       :   
                    (dtube_Hex2Num[3:0] == 4'd14)?  E_DISPLAY       :   
                    (dtube_Hex2Num[3:0] == 4'd15)?  F_DISPLAY       :   8'b1111_1111;

assign DTUBE_HEX3 = (dtube_Hex3Num[3:0] == 4'd1)?   ONE_DISPLAY     :
                    (dtube_Hex3Num[3:0] == 4'd2)?   TWO_DISPLAY     :
                    (dtube_Hex3Num[3:0] == 4'd3)?   THREE_DISPLAY   :
                    (dtube_Hex3Num[3:0] == 4'd4)?   FOUR_DISPLAY    :
                    (dtube_Hex3Num[3:0] == 4'd5)?   FIVE_DISPLAY    :
                    (dtube_Hex3Num[3:0] == 4'd6)?   SIX_DISPLAY     :
                    (dtube_Hex3Num[3:0] == 4'd7)?   SEVEN_DISPLAY   :
                    (dtube_Hex3Num[3:0] == 4'd8)?   EIGHT_DISPLAY   :
                    (dtube_Hex3Num[3:0] == 4'd9)?   NINE_DISPLAY    :   
                    (dtube_Hex3Num[3:0] == 4'd10)?  A_DISPLAY       :   
                    (dtube_Hex3Num[3:0] == 4'd11)?  B_DISPLAY       :   
                    (dtube_Hex3Num[3:0] == 4'd12)?  C_DISPLAY       :   
                    (dtube_Hex3Num[3:0] == 4'd13)?  D_DISPLAY       :   
                    (dtube_Hex3Num[3:0] == 4'd14)?  E_DISPLAY       :   
                    (dtube_Hex3Num[3:0] == 4'd15)?  F_DISPLAY       :   8'b1111_1111;

assign DTUBE_HEX4 = (dtube_Hex4Num[3:0] == 4'd1)?   ONE_DISPLAY     :
                    (dtube_Hex4Num[3:0] == 4'd2)?   TWO_DISPLAY     :
                    (dtube_Hex4Num[3:0] == 4'd3)?   THREE_DISPLAY   :
                    (dtube_Hex4Num[3:0] == 4'd4)?   FOUR_DISPLAY    :
                    (dtube_Hex4Num[3:0] == 4'd5)?   FIVE_DISPLAY    :
                    (dtube_Hex4Num[3:0] == 4'd6)?   SIX_DISPLAY     :
                    (dtube_Hex4Num[3:0] == 4'd7)?   SEVEN_DISPLAY   :
                    (dtube_Hex4Num[3:0] == 4'd8)?   EIGHT_DISPLAY   :
                    (dtube_Hex4Num[3:0] == 4'd9)?   NINE_DISPLAY    :   
                    (dtube_Hex4Num[3:0] == 4'd10)?  A_DISPLAY       :   
                    (dtube_Hex4Num[3:0] == 4'd11)?  B_DISPLAY       :   
                    (dtube_Hex4Num[3:0] == 4'd12)?  C_DISPLAY       :   
                    (dtube_Hex4Num[3:0] == 4'd13)?  D_DISPLAY       :   
                    (dtube_Hex4Num[3:0] == 4'd14)?  E_DISPLAY       :   
                    (dtube_Hex4Num[3:0] == 4'd15)?  F_DISPLAY       :   8'b1111_1111;

assign DTUBE_HEX5 = (dtube_Hex5Num[3:0] == 4'd1)?   ONE_DISPLAY     :
                    (dtube_Hex5Num[3:0] == 4'd2)?   TWO_DISPLAY     :
                    (dtube_Hex5Num[3:0] == 4'd3)?   THREE_DISPLAY   :
                    (dtube_Hex5Num[3:0] == 4'd4)?   FOUR_DISPLAY    :
                    (dtube_Hex5Num[3:0] == 4'd5)?   FIVE_DISPLAY    :
                    (dtube_Hex5Num[3:0] == 4'd6)?   SIX_DISPLAY     :
                    (dtube_Hex5Num[3:0] == 4'd7)?   SEVEN_DISPLAY   :
                    (dtube_Hex5Num[3:0] == 4'd8)?   EIGHT_DISPLAY   :
                    (dtube_Hex5Num[3:0] == 4'd9)?   NINE_DISPLAY    :   
                    (dtube_Hex5Num[3:0] == 4'd10)?  A_DISPLAY       :   
                    (dtube_Hex5Num[3:0] == 4'd11)?  B_DISPLAY       :   
                    (dtube_Hex5Num[3:0] == 4'd12)?  C_DISPLAY       :   
                    (dtube_Hex5Num[3:0] == 4'd13)?  D_DISPLAY       :   
                    (dtube_Hex5Num[3:0] == 4'd14)?  E_DISPLAY       :   
                    (dtube_Hex5Num[3:0] == 4'd15)?  F_DISPLAY       :   8'b1111_1111;

endmodule
`endif