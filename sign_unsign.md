# 有符号数与无符号数的运算

有符号数是二进制中的一种表示，将 n位二进制的首位作为符号位。$signed() 用来进行运算时的位扩展。

## 加法运算
1. 无符号 + 有符号：当作无符号运算得到二进制，输出是否 $signed() 只是该二进制代表的十进制不同，不改变二进制值；
2. 有符号 + 有符号：首位当作符号位，将输出也设置为有符号数，可以正确得到十进制对应结果。
``` verilog
module test;

reg signed [7:0] a;
reg [7:0] b;
wire signed [7:0] c;
wire  [7:0]sum1;
wire signed [7:0]sum2;
wire signed [7:0]sum3;
wire  [8:0]sum_1;
wire signed [8:0]sum_2;
wire signed [8:0]sum_3;

assign sum1 = a+b;
assign sum2 = a+b;
assign sum3 = a+c;
assign sum_1 = a+b;
assign sum_2 = a+b;
assign sum_3 = a+c;
assign c = $signed(b);

initial
begin
    #10 begin
    a = 8'b0111_0001;
    b = 8'b1111_0010;
    $display("signed a     =%b =%d",a,a);
    $display("b            =%b =%d",b,b);
    $display("signed c     =%b =%d",c,c);
    $display("a+b          =%b =%d",sum1,sum1);
    $display("signed a+b   =%b =%d",sum2,sum2);
    $display("signed a+c   =%b =%d",sum3,sum3);
    $display("a+b         =%b =%d",sum_1,sum_1);
    $display("signed a+b  =%b =%d",sum_2,sum_2);
    $display("signed a+c  =%b =%d",sum_3,sum_3);
  end
end

initial
begin
  $dumpfile("wave_sign_test.vcd");
  $dumpvars(0,test);
end

endmodule

```
```
signed a     =01110001 = 113
b            =11110010 =242
signed c     =11110010 = -14
a+b          =01100011 = 99
signed a+b   =01100011 =  99
signed a+c   =01100011 =  99
a+b         =101100011 =355
signed a+b  =101100011 =-157
signed a+c  =001100011 =  99
```

由上可以发现，要进行有符号数的加法，需将加数、被加数与和都设为有符号数，区别在于溢出位的处理（二进制首位的差别）。

比如 a 是一个有符号 8bits 信号，要将其扩展为有符号 32 bits，可以使用 b = $signed(a)，但是，若赋值给 a = 'b100，只给了 3 bits，此时使用 $signed() 并不影响 a 的值(8'b0000_0100)。即，想用 $signed() 来添加符号位 1，只有原来是有符号数，后也是有符号数。而对于没定义的 8 bits 值，需要判断首位，自行往前加1 or 0。

使用 $signed() 的区别在于显示的十进制值可能会不同（由于首位的判断导致值的不同）。