`ifndef LRU
`define LRU
`include "cache_define.v"
module LRU (
    input wire                              clk,
    input wire                              rst_n,
    input wire                              cache_en,
    input wire [`WAY_NUM - 1 : 0]           hit_en,
    input wire [`INDEX_WIDTH - 1 : 0]       index, // from decoder
    input wire [`LINE_NUM - 1 : 0]          way0_value,
    input wire [`LINE_NUM - 1 : 0]          way1_value,
    input wire [`LINE_NUM - 1 : 0]          way2_value,
    input wire [`LINE_NUM - 1 : 0]          way3_value,
    output reg                              way0_replace_en,
    output reg                              way1_replace_en,
    output reg                              way2_replace_en,
    output reg                              way3_replace_en,
    output wire [$clog2(`WAY_NUM) : 0]      replaced_way
);

assign replaced_way =   (way0_replace_en)? `REPLACE_WAY0 :
                        (way1_replace_en)? `REPLACE_WAY1 :
                        (way2_replace_en)? `REPLACE_WAY2 :
                        (way3_replace_en)? `REPLACE_WAY3 : `NO_REPLACE_WAY;

integer k;

// Record the least recently used
// The reset value of the asynchronous reset should be kept low to avoid latching
reg [2:0] age [`LINE_NUM - 1 : 0];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (k = 0; k < `LINE_NUM; k = k + 1) begin
            age[k] <= 3'b0;
        end
    end else begin
        if (hit_en[0]) begin            // way0 hit
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b1;
        end else if (hit_en[1]) begin   // way1 hit
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b0;
        end else if (hit_en[2]) begin   // way2 hit
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b1;
        end else if (hit_en[3]) begin   // way3 hit
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b0;
        // no hit
        end else if (way0_replace_en) begin // way0 replace
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b1;
        end else if (way1_replace_en) begin // way1 replace
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b0;
        end else if (way2_replace_en) begin // way2 replace
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b1;
        end else if (way3_replace_en) begin // way3 replace
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b0;
        end
    end
end

always @(*) begin
    way0_replace_en = 0;
    way1_replace_en = 0;
    way2_replace_en = 0;
    way3_replace_en = 0;
    if (hit_en == 4'b0000 && (cache_en == 1)) begin
        if (way0_value[index] == 0) begin
            way0_replace_en = 1;
            way1_replace_en = 0;
            way2_replace_en = 0;
            way3_replace_en = 0;
        end else if (way1_value[index] == 0) begin
            way0_replace_en = 0;
            way1_replace_en = 1;
            way2_replace_en = 0;
            way3_replace_en = 0;
        end else if (way2_value[index] == 0) begin
            way0_replace_en = 0;
            way1_replace_en = 0;
            way2_replace_en = 1;
            way3_replace_en = 0;
        end else if (way3_value[index] == 0) begin
            way0_replace_en = 0;
            way1_replace_en = 0;
            way2_replace_en = 0;
            way3_replace_en = 1;
        end else begin
            if (age[index][0] == 0) begin
                if (age[index][1] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else begin  // age[i][1] == 1 or age[i][1] == 1'bx
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end
            end else begin
                if (age[index][2] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else begin  // age[i][1] == 1 or age[i][1] == 1'bx
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end
            end
        end
    end else begin
        way0_replace_en = 0;
        way1_replace_en = 0;
        way2_replace_en = 0;
        way3_replace_en = 0;
    end
end

endmodule
`endif