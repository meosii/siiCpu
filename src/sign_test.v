module test;

reg signed [7:0] a;
reg [7:0] b;
wire signed [11:0] c;
reg signed [7:0] d;

assign c = $signed(a);

initial
begin
    #10 begin
    a = 8'b1111_0001;
    b = -1;
    d = -1;
    $display("a>b? :%d, a = %d, b = %d, %b",a>b,a,b,b);
    $display("a>c? :%d, a = %d, %b , c = %d, %b",a>c,a,a,c,c);
    $display("d = %d, %b",d,d);
  end
end

initial
begin
  $dumpfile("wave_sign_test.vcd");
  $dumpvars(0,test);
end

endmodule
