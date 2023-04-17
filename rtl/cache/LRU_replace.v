/* Least Recently Used
When the CPU needs to access an address that does not exist in the cache, 
it needs to write the data of that address in memory into the cache.
At this time, one cacheline in the cache needs to be replaced. So, 
which cacheline to choose requires a certain replacement strategy.

Here we adopt LRU(least recently used)
*/
`ifndef LRU_REPLACE
`define LRU_REPLACE
`include "cache_define.v"
module LRU_replace (
    input wire                           clk,
    input wire                           rst_n,
    input wire [`WAY_NUM - 1 : 0]        hit_en,
    input wire [`INDEX_WIDTH - 1 : 0]    index,
    // Indicates which way is least used in cacheline0/1/2/···
    output wire [$clog2(`WAY_NUM) : 0]   line0_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line1_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line2_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line3_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line4_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line5_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line6_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line7_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line8_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line9_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line10_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line11_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line12_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line13_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line14_replace_way,
    output wire [$clog2(`WAY_NUM) : 0]   line15_replace_way
);

// age[15][0] -> cacheline15 age[0]
reg [2:0] age [15 : 0];
always @(*) begin
    if (hit_en[0]) begin            // way0 hit
        age[index][0] = 1'b1; 
        age[index][1] = 1'b1;
    end else if (hit_en[1]) begin   // way1 hit
        age[index][0] = 1'b1; 
        age[index][1] = 1'b0;
    end else if (hit_en[2]) begin   // way2 hit
        age[index][0] = 1'b0; 
        age[index][2] = 1'b1;
    end else if (hit_en[3]) begin   // way3 hit
        age[index][0] = 1'b0; 
        age[index][2] = 1'b0;
    end else begin
        age[index] = age[index];
    end
end

// Output which cacheine of way will be replaced
reg [$clog2(`WAY_NUM) : 0] line_replace_way [`LINE_NUM - 1 : 0];
assign line0_replace_way = line_replace_way[0]; // line0 choose which way
assign line1_replace_way = line_replace_way[1];
assign line2_replace_way = line_replace_way[2];
assign line3_replace_way = line_replace_way[3];
assign line4_replace_way = line_replace_way[4];
assign line5_replace_way = line_replace_way[5];
assign line6_replace_way = line_replace_way[6];
assign line7_replace_way = line_replace_way[7];
assign line8_replace_way = line_replace_way[8];
assign line9_replace_way = line_replace_way[9];
assign line10_replace_way = line_replace_way[10];
assign line11_replace_way = line_replace_way[11];
assign line12_replace_way = line_replace_way[12];
assign line13_replace_way = line_replace_way[13];
assign line14_replace_way = line_replace_way[14];
assign line15_replace_way = line_replace_way[15];

// The generate-for loop produces 16 always instances
// Indicate the "way" that needs to be replaced for each line(16 line).
genvar i;
generate
for (i = 0; i < (`LINE_NUM - 1); i= i + 1) 
    begin: replace
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                line_replace_way[i] <= `REPLACE_WAY0;
            end else if (age[i][0] == 0) begin
                if (age[i][1] == 0) begin
                    line_replace_way[i] <= `REPLACE_WAY0;
                end else begin  // age[i][1] == 1 or age[i][1] == 1'bx
                    line_replace_way[i] <= `REPLACE_WAY1;
                end
            end else begin      // age[i][0] == 1
                if (age[i][2] == 0) begin
                    line_replace_way[i] <= `REPLACE_WAY2;
                end else begin  // age[i][2] == 1 or age[i][2] == 1'bx
                    line_replace_way[i] <= `REPLACE_WAY3;
                end
            end
        end
    end
endgenerate

endmodule
`endif