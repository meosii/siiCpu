`include "LRU_replace.v"
`include "cache_define.v"
module tb_LRU_replace ();
reg                           clk;
reg                           rst_n;
reg  [`WAY_NUM - 1 : 0]       hit_en;
reg  [`INDEX_WIDTH - 1 : 0]    index;
wire [$clog2(`WAY_NUM) : 0]   line0_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line1_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line2_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line3_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line4_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line5_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line6_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line7_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line8_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line9_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line10_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line11_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line12_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line13_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line14_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line15_replace_way;

LRU_replace u_LRU_replace(
    .clk(clk),
    .rst_n(rst_n),
    .hit_en(hit_en),
    .index(index),
    .line0_replace_way(line0_replace_way),
    .line1_replace_way(line1_replace_way),
    .line2_replace_way(line2_replace_way),
    .line3_replace_way(line3_replace_way),
    .line4_replace_way(line4_replace_way),
    .line5_replace_way(line5_replace_way),
    .line6_replace_way(line6_replace_way),
    .line7_replace_way(line7_replace_way),
    .line8_replace_way(line8_replace_way),
    .line9_replace_way(line9_replace_way),
    .line10_replace_way(line10_replace_way),
    .line11_replace_way(line11_replace_way),
    .line12_replace_way(line12_replace_way),
    .line13_replace_way(line13_replace_way),
    .line14_replace_way(line14_replace_way),
    .line15_replace_way(line15_replace_way)
);

localparam TIME_CLK = 10;

always #(TIME_CLK/2) clk = ~clk;

task hit_and_index(
    input [`WAY_NUM - 1 : 0] test_hit_en,
    input [`INDEX_WIDTH - 1 : 0] test_index
);
begin
    @(posedge clk)
    #1 begin
        hit_en = test_hit_en;
        index = test_index;
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
        // line1
        hit_and_index(`HIT_WAY0,`INDEX_LINE1);
        hit_and_index(`HIT_WAY3,`INDEX_LINE1);
        hit_and_index(`HIT_WAY2,`INDEX_LINE1);
        hit_and_index(`HIT_WAY1,`INDEX_LINE1);
        hit_and_index(`HIT_WAY2,`INDEX_LINE1);
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
    $monitor(" Time: %t, \n line0: way %d will be replaced.\n line1: way %d will be replaced.\n ", $time, line0_replace_way, line1_replace_way);
end

initial begin
    $dumpfile("wave_LRU_replace.vcd");
    $dumpvars(0,tb_LRU_replace);
end

endmodule