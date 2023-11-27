`timescale 1ns/1ns
`include "../rtl/define.v"
module tb_soc ();

reg                         CPU_EN;
reg                         CLK_IN;
reg                         RST_N;
wire                        TX;

soc_top u_soc_top(
    .CPU_EN         (CPU_EN         ),
    .CLK_IN         (CLK_IN         ),
    .RST_N          (RST_N          ),
    .TX             (TX             )
);

parameter TIME_CLK_IN = 20;

always #(TIME_CLK_IN/2) CLK_IN = ~CLK_IN;

initial begin
    #0 begin
        CLK_IN = 0;
        CPU_EN = 0;
        RST_N = 0;
    end
    #22 begin
        RST_N = 1;
    end
    #20 begin
       CPU_EN = 1; 
    end
    #50000
    $finish;
end

initial begin
    $dumpfile("soc.vcd");
    $dumpvars(0,tb_soc);
end

endmodule