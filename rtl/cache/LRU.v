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

// Record the least recently used
reg [2:0] age [`LINE_NUM - 1 : 0];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        age[index][0] <= 1'b1; 
        age[index][1] <= 1'b1;
        age[index][2] <= 1'b1;
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
    if (hit_en == 4'b0000 && (cache_en == 1)) begin
        case(index)
            `INDEX_LINE0: begin
                if (way0_value[`INDEX_LINE0] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE0] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE0] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE0] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE0][0] == 0) begin
                        if (age[`INDEX_LINE0][1] == 0) begin
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
                        if (age[`INDEX_LINE0][2] == 0) begin
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
            end
            `INDEX_LINE1: begin
                if (way0_value[`INDEX_LINE1] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE1] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE1] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE1] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE1][0] == 0) begin
                        if (age[`INDEX_LINE1][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE1][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE2: begin
                if (way0_value[`INDEX_LINE2] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE2] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE2] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE2] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE2][0] == 0) begin
                        if (age[`INDEX_LINE2][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE2][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE3: begin
                if (way0_value[`INDEX_LINE3] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE3] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE3] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE3] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE3][0] == 0) begin
                        if (age[`INDEX_LINE3][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE3][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE4:  begin
                if (way0_value[`INDEX_LINE4] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE4] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE4] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE4] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE4][0] == 0) begin
                        if (age[`INDEX_LINE4][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE4][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE5: begin
                if (way0_value[`INDEX_LINE5] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE5] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE5] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE5] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE5][0] == 0) begin
                        if (age[`INDEX_LINE5][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE5][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE6: begin
                if (way0_value[`INDEX_LINE6] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE6] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE6] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE6] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE6][0] == 0) begin
                        if (age[`INDEX_LINE6][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE6][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE7:  begin
                if (way0_value[`INDEX_LINE7] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE7] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE7] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE7] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE7][0] == 0) begin
                        if (age[`INDEX_LINE7][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE7][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE8: begin
                if (way0_value[`INDEX_LINE8] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE8] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE8] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE8] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE8][0] == 0) begin
                        if (age[`INDEX_LINE8][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE8][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE9:  begin
                if (way0_value[`INDEX_LINE9] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE9] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE9] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE9] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE9][0] == 0) begin
                        if (age[`INDEX_LINE9][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE9][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE10: begin
                if (way0_value[`INDEX_LINE10] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE10] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE10] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE10] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE10][0] == 0) begin
                        if (age[`INDEX_LINE10][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE10][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE11:  begin
                if (way0_value[`INDEX_LINE11] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE11] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE11] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE11] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE11][0] == 0) begin
                        if (age[`INDEX_LINE11][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE11][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE12:  begin
                if (way0_value[`INDEX_LINE12] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE12] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE12] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE12] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE12][0] == 0) begin
                        if (age[`INDEX_LINE12][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE12][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE13: begin
                if (way0_value[`INDEX_LINE13] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE13] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE13] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE13] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE13][0] == 0) begin
                        if (age[`INDEX_LINE13][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE13][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE14: begin
                if (way0_value[`INDEX_LINE14] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE14] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE14] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE14] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE14][0] == 0) begin
                        if (age[`INDEX_LINE14][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE14][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
            `INDEX_LINE15: begin
                if (way0_value[`INDEX_LINE15] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way1_value[`INDEX_LINE15] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else if (way2_value[`INDEX_LINE15] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else if (way3_value[`INDEX_LINE15] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end else begin
                    if (age[`INDEX_LINE15][0] == 0) begin
                        if (age[`INDEX_LINE15][1] == 0) begin
                            way0_replace_en = 1;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 1;
                            way2_replace_en = 0;
                            way3_replace_en = 0;
                        end
                    end else begin
                        if (age[`INDEX_LINE15][2] == 0) begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 1;
                            way3_replace_en = 0;
                        end else begin
                            way0_replace_en = 0;
                            way1_replace_en = 0;
                            way2_replace_en = 0;
                            way3_replace_en = 1;
                        end
                    end
                end
            end
        endcase
    end else begin
        way0_replace_en = 0;
        way1_replace_en = 0;
        way2_replace_en = 0;
        way3_replace_en = 0;
    end
end

endmodule
`endif