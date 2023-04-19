`include "LRU_replace.v"
`include "cache_define.v"
module tb_LRU_replace ();
reg                           clk;
reg                           rst_n;
reg  [`WAY_NUM - 1 : 0]       hit_en;
reg  [`INDEX_WIDTH - 1 : 0]   index;
wire                          way0_replace_en;
wire                          way1_replace_en;
wire                          way2_replace_en;
wire                          way3_replace_en;

LRU_replace u_LRU_replace(
    .clk(clk),
    .rst_n(rst_n),
    .hit_en(hit_en),
    .index(index),
    .way0_replace_en(way0_replace_en),
    .way1_replace_en(way1_replace_en),
    .way2_replace_en(way2_replace_en),
    .way3_replace_en(way3_replace_en)
);

localparam TIME_CLK = 10;

always #(TIME_CLK/2) clk = ~clk;

task hit_and_index(
    input [`WAY_NUM - 1 : 0]        test_hit_en,
    input [`INDEX_WIDTH - 1 : 0]    test_index
);
begin
    @(posedge clk)
    #1 begin
        hit_en = test_hit_en;
        index  = test_index;
    end
end
endtask

initial begin
    #0 begin
        clk     = 0;
        rst_n   = 0;
        hit_en  = `NO_HIT;
        index   = `INDEX_LINE0;
    end
    #3 begin
        rst_n   = 1;
    end
    #1 begin
        // line0 
        hit_and_index(`HIT_WAY0,`INDEX_LINE0);
        hit_and_index(`HIT_WAY1,`INDEX_LINE0);
        hit_and_index(`HIT_WAY2,`INDEX_LINE0);
        hit_and_index(`HIT_WAY1,`INDEX_LINE0);
        // test replace
        hit_and_index(`NO_HIT,`INDEX_LINE0);
        hit_and_index(`HIT_WAY1,`INDEX_LINE0);
        hit_and_index(`HIT_WAY2,`INDEX_LINE0);
        hit_and_index(`HIT_WAY1,`INDEX_LINE0);
        // line1
        hit_and_index(`HIT_WAY0,`INDEX_LINE1);
        hit_and_index(`HIT_WAY3,`INDEX_LINE1);
        hit_and_index(`HIT_WAY2,`INDEX_LINE1);
        hit_and_index(`HIT_WAY1,`INDEX_LINE1);
        hit_and_index(`HIT_WAY2,`INDEX_LINE1);
        // test replace
        hit_and_index(`NO_HIT,`INDEX_LINE1);
        // line2
        hit_and_index(`HIT_WAY3,`INDEX_LINE2);
        hit_and_index(`HIT_WAY2,`INDEX_LINE2);
        hit_and_index(`HIT_WAY1,`INDEX_LINE2);
        hit_and_index(`HIT_WAY1,`INDEX_LINE2);
        hit_and_index(`HIT_WAY0,`INDEX_LINE2);
        // line3
        hit_and_index(`HIT_WAY2,`INDEX_LINE3);
        hit_and_index(`HIT_WAY1,`INDEX_LINE3);
        hit_and_index(`HIT_WAY0,`INDEX_LINE3);
        hit_and_index(`HIT_WAY2,`INDEX_LINE3);
        hit_and_index(`HIT_WAY1,`INDEX_LINE3);
        hit_and_index(`HIT_WAY3,`INDEX_LINE3);
        // line4 
        hit_and_index(`HIT_WAY2,`INDEX_LINE4);
        hit_and_index(`HIT_WAY1,`INDEX_LINE4);
        hit_and_index(`HIT_WAY2,`INDEX_LINE4);
        hit_and_index(`HIT_WAY1,`INDEX_LINE4);
        hit_and_index(`HIT_WAY3,`INDEX_LINE4);
        hit_and_index(`HIT_WAY0,`INDEX_LINE4);
        // line5
        hit_and_index(`HIT_WAY3,`INDEX_LINE5);
        hit_and_index(`HIT_WAY2,`INDEX_LINE5);
        hit_and_index(`HIT_WAY2,`INDEX_LINE5);
        hit_and_index(`HIT_WAY3,`INDEX_LINE5);
        hit_and_index(`HIT_WAY0,`INDEX_LINE5);
        hit_and_index(`HIT_WAY1,`INDEX_LINE5);
        hit_and_index(`HIT_WAY1,`INDEX_LINE5);
        hit_and_index(`HIT_WAY2,`INDEX_LINE5);
        // line6
        hit_and_index(`HIT_WAY3,`INDEX_LINE6);
        hit_and_index(`HIT_WAY1,`INDEX_LINE6);
        hit_and_index(`HIT_WAY1,`INDEX_LINE6);
        hit_and_index(`HIT_WAY2,`INDEX_LINE6);
        hit_and_index(`HIT_WAY1,`INDEX_LINE6);
        hit_and_index(`HIT_WAY0,`INDEX_LINE6);
        // line7
        hit_and_index(`HIT_WAY2,`INDEX_LINE7);
        hit_and_index(`HIT_WAY2,`INDEX_LINE7);
        hit_and_index(`HIT_WAY1,`INDEX_LINE7);
        hit_and_index(`HIT_WAY3,`INDEX_LINE7);
        hit_and_index(`HIT_WAY1,`INDEX_LINE7);
        // line8 
        hit_and_index(`HIT_WAY2,`INDEX_LINE8);
        hit_and_index(`HIT_WAY1,`INDEX_LINE8);
        hit_and_index(`HIT_WAY3,`INDEX_LINE8);
        hit_and_index(`HIT_WAY3,`INDEX_LINE8);
        hit_and_index(`HIT_WAY1,`INDEX_LINE8);
        hit_and_index(`HIT_WAY1,`INDEX_LINE8);
        // line9
        hit_and_index(`HIT_WAY3,`INDEX_LINE9);
        hit_and_index(`HIT_WAY0,`INDEX_LINE9);
        hit_and_index(`HIT_WAY1,`INDEX_LINE9);
        hit_and_index(`HIT_WAY3,`INDEX_LINE9);
        hit_and_index(`HIT_WAY1,`INDEX_LINE9);
        hit_and_index(`HIT_WAY2,`INDEX_LINE9);
        // line10
        hit_and_index(`HIT_WAY3,`INDEX_LINE10);
        hit_and_index(`HIT_WAY1,`INDEX_LINE10);
        hit_and_index(`HIT_WAY1,`INDEX_LINE10);
        hit_and_index(`HIT_WAY0,`INDEX_LINE10);
        hit_and_index(`HIT_WAY2,`INDEX_LINE10);
        hit_and_index(`HIT_WAY1,`INDEX_LINE10);
        // line11
        hit_and_index(`HIT_WAY2,`INDEX_LINE11);
        hit_and_index(`HIT_WAY0,`INDEX_LINE11);
        hit_and_index(`HIT_WAY1,`INDEX_LINE11);
        hit_and_index(`HIT_WAY0,`INDEX_LINE11);
        hit_and_index(`HIT_WAY1,`INDEX_LINE11);
        // line12
        hit_and_index(`HIT_WAY3,`INDEX_LINE12);
        hit_and_index(`HIT_WAY1,`INDEX_LINE12);
        hit_and_index(`HIT_WAY0,`INDEX_LINE12);
        hit_and_index(`HIT_WAY2,`INDEX_LINE12);
        hit_and_index(`HIT_WAY1,`INDEX_LINE12);
        hit_and_index(`HIT_WAY0,`INDEX_LINE12);
        // line13
        hit_and_index(`HIT_WAY2,`INDEX_LINE13);
        hit_and_index(`HIT_WAY1,`INDEX_LINE13);
        hit_and_index(`HIT_WAY2,`INDEX_LINE13);
        hit_and_index(`HIT_WAY3,`INDEX_LINE13);
        hit_and_index(`HIT_WAY0,`INDEX_LINE13);
        hit_and_index(`HIT_WAY3,`INDEX_LINE13);
        hit_and_index(`HIT_WAY3,`INDEX_LINE13);
        // line14
        hit_and_index(`HIT_WAY3,`INDEX_LINE14);
        hit_and_index(`HIT_WAY1,`INDEX_LINE14);
        hit_and_index(`HIT_WAY0,`INDEX_LINE14);
        hit_and_index(`HIT_WAY2,`INDEX_LINE14);
        hit_and_index(`HIT_WAY1,`INDEX_LINE14);
        hit_and_index(`HIT_WAY0,`INDEX_LINE14);
        // line15
        hit_and_index(`HIT_WAY2,`INDEX_LINE15);
        hit_and_index(`HIT_WAY1,`INDEX_LINE15);
        hit_and_index(`HIT_WAY2,`INDEX_LINE15);
        hit_and_index(`HIT_WAY3,`INDEX_LINE15);
        hit_and_index(`HIT_WAY0,`INDEX_LINE15);
        hit_and_index(`HIT_WAY3,`INDEX_LINE15);
        hit_and_index(`HIT_WAY3,`INDEX_LINE15);
    end
    $finish;
end

initial begin
    $dumpfile("wave_LRU_replace.vcd");
    $dumpvars(0,tb_LRU_replace);
end

endmodule