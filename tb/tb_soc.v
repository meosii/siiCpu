`timescale 1ns/1ns
`include "../rtl/define.v"
module tb_soc ();

reg                         CPU_EN;
reg                         CLK_IN;
reg                         RST_N;
wire                        rd_insn_en;
wire [`PC_WIDTH - 1 : 0]    pc;
reg [`WORD_WIDTH - 1 : 0]   insn;
wire                        TX;

soc_top u_soc_top(
    .CPU_EN         (CPU_EN         ),
    .CLK_IN         (CLK_IN         ),
    .RST_N          (RST_N          ),
    .rd_insn_en     (rd_insn_en     ),
    .pc             (pc             ),
    .insn           (insn           ),
    .TX             (TX             )
);

parameter TIME_CLK_IN = 20;

always #(TIME_CLK_IN/2) CLK_IN = ~CLK_IN;

reg [31:0] itcm [0:8191];

initial begin
    $readmemh("itcm.hex", itcm);
end

always @(*) begin
    if (rd_insn_en) begin
        insn = itcm[pc[15:2]];
    end else begin
        insn = 0;
    end
end

initial begin
    #0 begin
        CLK_IN = 0;
        CPU_EN = 0;
        RST_N = 0;
    end
    #22 begin
        RST_N = 1;
    end
    // after itcm has insn
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