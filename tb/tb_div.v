`timescale 1ps/1ps
`include "../rtl/define.v"
module tb_div ();
reg                      clk;
reg                      rst_n;
reg                      div_start;
reg [2:0]                div_opcode;
reg [`WORD_WIDTH-1 : 0]  div_divident;
reg [`WORD_WIDTH-1 : 0]  div_divisor;
wire [`WORD_WIDTH-1 : 0] div_quotient;
wire [`WORD_WIDTH-1 : 0] div_remainder;
wire                     div_finish;

wire signed [`WORD_WIDTH-1 : 0] real_div_quotient_div;
wire        [`WORD_WIDTH-1 : 0] real_div_quotient_divu;
wire signed [`WORD_WIDTH-1 : 0] real_div_remainder_div;
wire        [`WORD_WIDTH-1 : 0] real_div_remainder_divu;
wire result_right_quotient; // 1:right
wire result_right_remainder; // 1:right
reg [7:0] cnt;

assign real_div_quotient_div =  $signed(div_divident) / $signed(div_divisor);
assign real_div_remainder_div =  $signed(div_divident) % $signed(div_divisor);

assign real_div_quotient_divu =  div_divident / div_divisor;
assign real_div_remainder_divu =  div_divident % div_divisor;

assign result_right_quotient = (((div_opcode == `DIV_OP_DIVU) && (div_quotient == real_div_quotient_divu)) ||
                                ((div_opcode == `DIV_OP_DIV) && (div_quotient == real_div_quotient_div))      && div_finish) || !div_finish;
assign result_right_remainder = (((div_opcode == `DIV_OP_DIVU) && (div_remainder == real_div_remainder_divu)) ||
                                ((div_opcode == `DIV_OP_DIV) && (div_remainder == real_div_remainder_div))    && div_finish) || !div_finish;

div u_div(
    .clk            (clk            ),                        
    .rst_n          (rst_n          ),
    .div_start      (div_start      ),
    .div_opcode     (div_opcode     ),
    .div_divident   (div_divident   ),
    .div_divisor    (div_divisor    ),
    .div_quotient   (div_quotient   ),
    .div_remainder  (div_remainder  ),
    .div_finish     (div_finish     )
);

parameter TIME_CLK = 10;

always #(TIME_CLK/2) clk = ~clk;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_divident <= 32'b0;
        div_divisor <= 32'b0;
    end else if (cnt == 8'd40) begin
        div_divident <= $random();
        //div_divident <= {1'b1,{31{1'b0}}};
        div_divisor <= $random();
        //div_divisor <= {32{1'b1}};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'b0;
    end else begin
        cnt <= cnt + TIME_CLK;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_start <= 1'b0;
    end else if (cnt == 8'd40) begin
        div_start <= 1'b1;
    end else if (cnt == 8'd50) begin
        div_start <= 1'b0;
    end
end

initial begin
    #0 begin
        clk         = 0;
        rst_n       = 0;
        div_opcode  = `DIV_OP_NOP;
    end
    #12 begin
        rst_n       = 1;
    end
    #10 begin
        div_opcode  = `DIV_OP_DIV;
    end
    #1000000 begin
        div_opcode  = `DIV_OP_DIVU;
    end
    #1000000
    $finish;
end

initial begin
    $dumpfile("div.vcd");
    $dumpvars(0,tb_div);
end

endmodule