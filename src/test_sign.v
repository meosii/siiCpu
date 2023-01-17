`include "sign.v"
module test_sign();
reg [7:0] a;
wire [7:0] b;

sign u_sign (
    .a(a),
    .b(b)
);

initial begin
    #0 begin
        a = 8'b1000_0101;
        #1 $display("b = %d",b);
    end
    #1 $finish;
end
endmodule