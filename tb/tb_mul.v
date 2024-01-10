`timescale 1ps/1ps
`include "../rtl/define.v"
module tb_mul ();

localparam SIGNED_WORD_WIDTH = `WORD_WIDTH + 1;
localparam PARTIAL_PRODUCT_WIDTH = SIGNED_WORD_WIDTH + SIGNED_WORD_WIDTH;

reg                                  clk;
reg [2:0]                            mul_opcode;
reg [`WORD_WIDTH-1 : 0]              mul_data1;
reg [`WORD_WIDTH-1 : 0]              mul_data2;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_add_a;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_add_b;

wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_result;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_actual_result;
wire mul_okay;
assign mul_result = mul_add_a + mul_add_b;

assign mul_actual_result =  (mul_opcode == `MUL_OP_MUL      )? $signed({{34{mul_data1[`WORD_WIDTH-1]}}, mul_data1})*$signed({{34{mul_data2[`WORD_WIDTH-1]}}, mul_data2})    :
                            (mul_opcode == `MUL_OP_MULH     )? $signed({{34{mul_data1[`WORD_WIDTH-1]}}, mul_data1})*$signed({{34{mul_data2[`WORD_WIDTH-1]}}, mul_data2})    :
                            (mul_opcode == `MUL_OP_MULHU    )? mul_data1*mul_data2                                                                                          :
                            (mul_opcode == `MUL_OP_MULHSU   )? $signed({{34{mul_data1[`WORD_WIDTH-1]}}, mul_data1})*mul_data2                                               : 0;

assign mul_okay = mul_result == mul_actual_result;

mul u_mul(
    .mul_opcode (mul_opcode ),
    .mul_data1  (mul_data1  ),
    .mul_data2  (mul_data2  ),
    .mul_add_a  (mul_add_a  ),
    .mul_add_b  (mul_add_b  )
);

parameter TIME_CLK = 10;

always #(TIME_CLK/2) clk = ~clk;

always @(posedge clk) begin
    mul_data1  = $random();
    mul_data2  = $random();
end

initial begin
    #0 begin
        clk = 0;
        mul_opcode = `MUL_OP_NOP;
        mul_data1  = 32'd0;
        mul_data2  = 32'd0;
    end
    #10 begin
        mul_opcode = `MUL_OP_MUL;
    end
    #5000 begin
        mul_opcode = `MUL_OP_MULH;
    end
    #5000 begin
        mul_opcode = `MUL_OP_MULHU;
    end
    #5000 begin
        mul_opcode = `MUL_OP_MULHSU;
    end
    #5000
    $finish;
end

initial begin
    $dumpfile("mul.vcd");
    $dumpvars(0,tb_mul);
end

endmodule