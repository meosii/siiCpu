/* Least Recently Used
When the CPU needs to access an address that does not exist in the cache, 
it needs to write the data of that address in memory into the cache.
At this time, one cacheline in the cache needs to be replaced. So, 
which cacheline to choose requires a certain replacement strategy.

Here we adopt LRU(least recently used)
`way0_replace_en`, `way1_replace_en`, `way2_replace_en`, `way3_replace_en`
Only indicate that the way in current index can be replaced.
That is to say, it has not been decided whether to hit and whether to replace
*/
`ifndef LRU_REPLACE
`define LRU_REPLACE
`include "cache_define.v"
// Record the way that will be replaced first for each line
module LRU_replace (
    input wire                          clk,
    input wire                          rst_n,
    input wire [`WAY_NUM - 1 : 0]       hit_en,
    input wire [`INDEX_WIDTH - 1 : 0]   index,
    // Used to indicate which way of the current index can be replaced
    output reg                         way0_replace_en,
    output reg                         way1_replace_en,
    output reg                         way2_replace_en,
    output reg                         way3_replace_en
);

// age[15][0] -> cacheline15 age[0]
reg [2:0] age [`LINE_NUM - 1 : 0];
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
    end else if (way0_replace_en) begin
    // no hit
        age[index][0] = 1'b1; 
        age[index][1] = 1'b1;
    end else if (way1_replace_en) begin
        age[index][0] = 1'b1; 
        age[index][1] = 1'b0;
    end else if (way2_replace_en) begin
        age[index][0] = 1'b0; 
        age[index][2] = 1'b1;
    end else if (way3_replace_en) begin
        age[index][0] = 1'b0; 
        age[index][2] = 1'b0;
    end
end


// Which way of each line will be replaced
reg [$clog2(`WAY_NUM) : 0] line_replace_way [`LINE_NUM - 1 : 0];

// The generate-for loop produces 16 always instances
// Indicate the "way" that needs to be replaced for each line(16 line).

// With the current logic, the cache is initialized with the order 
// way3 -> way1 -> way 2 -> way0 written to each line.
genvar i;
generate
for (i = 0; i < (`LINE_NUM - 1); i= i + 1) 
    begin: replace
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                line_replace_way[i] <= `REPLACE_WAY3;
            end else if (age[i][0] == 0) begin
            // age[i][0] == 0 
                if (age[i][1] == 0) begin
                    line_replace_way[i] <= `REPLACE_WAY0;
                end else begin  // age[i][1] == 1 or age[i][1] == 1'bx
                    line_replace_way[i] <= `REPLACE_WAY1;
                end
            end else begin
            // age[i][0] == 1
                if (age[i][2] == 0) begin
                    line_replace_way[i] <= `REPLACE_WAY2;
                end else begin  // age[i][2] == 1 or age[i][2] == 1'bx
                    line_replace_way[i] <= `REPLACE_WAY3;
                end
            end
        end
    end
endgenerate

always @(*) begin
    if ( ((index == `INDEX_LINE0)  && (line_replace_way[0]  == `REPLACE_WAY0)) 
    || ((index == `INDEX_LINE1)  && (line_replace_way[1]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE2)  && (line_replace_way[2]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE3)  && (line_replace_way[3]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE4)  && (line_replace_way[4]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE5)  && (line_replace_way[5]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE6)  && (line_replace_way[6]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE7)  && (line_replace_way[7]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE8)  && (line_replace_way[8]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE9)  && (line_replace_way[9]  == `REPLACE_WAY0))
    || ((index == `INDEX_LINE10) && (line_replace_way[10] == `REPLACE_WAY0))
    || ((index == `INDEX_LINE11) && (line_replace_way[11] == `REPLACE_WAY0))
    || ((index == `INDEX_LINE12) && (line_replace_way[12] == `REPLACE_WAY0))
    || ((index == `INDEX_LINE13) && (line_replace_way[13] == `REPLACE_WAY0))
    || ((index == `INDEX_LINE14) && (line_replace_way[14] == `REPLACE_WAY0))
    || ((index == `INDEX_LINE15) && (line_replace_way[15] == `REPLACE_WAY0)) ) begin
        way0_replace_en = 1;
    end else begin
        way0_replace_en = 0;
    end
end

always @(*) begin
    if (((index == `INDEX_LINE0)  && (line_replace_way[0]  == `REPLACE_WAY1)) 
    || ((index == `INDEX_LINE1)  && (line_replace_way[1]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE2)  && (line_replace_way[2]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE3)  && (line_replace_way[3]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE4)  && (line_replace_way[4]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE5)  && (line_replace_way[5]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE6)  && (line_replace_way[6]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE7)  && (line_replace_way[7]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE8)  && (line_replace_way[8]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE9)  && (line_replace_way[9]  == `REPLACE_WAY1))
    || ((index == `INDEX_LINE10) && (line_replace_way[10] == `REPLACE_WAY1))
    || ((index == `INDEX_LINE11) && (line_replace_way[11] == `REPLACE_WAY1))
    || ((index == `INDEX_LINE12) && (line_replace_way[12] == `REPLACE_WAY1))
    || ((index == `INDEX_LINE13) && (line_replace_way[13] == `REPLACE_WAY1))
    || ((index == `INDEX_LINE14) && (line_replace_way[14] == `REPLACE_WAY1))
    || ((index == `INDEX_LINE15) && (line_replace_way[15] == `REPLACE_WAY1))) begin
        way1_replace_en = 1;
    end else begin
        way1_replace_en = 0;
    end
end

always @(*) begin
    if (((index == `INDEX_LINE0)  && (line_replace_way[0]  == `REPLACE_WAY2)) 
    || ((index == `INDEX_LINE1)  && (line_replace_way[1]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE2)  && (line_replace_way[2]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE3)  && (line_replace_way[3]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE4)  && (line_replace_way[4]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE5)  && (line_replace_way[5]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE6)  && (line_replace_way[6]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE7)  && (line_replace_way[7]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE8)  && (line_replace_way[8]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE9)  && (line_replace_way[9]  == `REPLACE_WAY2))
    || ((index == `INDEX_LINE10) && (line_replace_way[10] == `REPLACE_WAY2))
    || ((index == `INDEX_LINE11) && (line_replace_way[11] == `REPLACE_WAY2))
    || ((index == `INDEX_LINE12) && (line_replace_way[12] == `REPLACE_WAY2))
    || ((index == `INDEX_LINE13) && (line_replace_way[13] == `REPLACE_WAY2))
    || ((index == `INDEX_LINE14) && (line_replace_way[14] == `REPLACE_WAY2))
    || ((index == `INDEX_LINE15) && (line_replace_way[15] == `REPLACE_WAY2))) begin
        way2_replace_en = 1;
    end else begin
        way2_replace_en = 0;
    end
end

always @(*) begin
    if (((index == `INDEX_LINE0)  && (line_replace_way[0]  == `REPLACE_WAY3)) 
    || ((index == `INDEX_LINE1)  && (line_replace_way[1]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE2)  && (line_replace_way[2]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE3)  && (line_replace_way[3]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE4)  && (line_replace_way[4]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE5)  && (line_replace_way[5]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE6)  && (line_replace_way[6]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE7)  && (line_replace_way[7]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE8)  && (line_replace_way[8]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE9)  && (line_replace_way[9]  == `REPLACE_WAY3))
    || ((index == `INDEX_LINE10) && (line_replace_way[10] == `REPLACE_WAY3))
    || ((index == `INDEX_LINE11) && (line_replace_way[11] == `REPLACE_WAY3))
    || ((index == `INDEX_LINE12) && (line_replace_way[12] == `REPLACE_WAY3))
    || ((index == `INDEX_LINE13) && (line_replace_way[13] == `REPLACE_WAY3))
    || ((index == `INDEX_LINE14) && (line_replace_way[14] == `REPLACE_WAY3))
    || ((index == `INDEX_LINE15) && (line_replace_way[15] == `REPLACE_WAY3))) begin
        way3_replace_en = 1;
    end else begin
        way3_replace_en = 0;
    end
end

endmodule
`endif