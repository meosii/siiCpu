`ifndef REG1
`define REG1
`include "cache_define.v"
module reg1 (
    input wire clk,
    input wire rst_n,
    input wire                          wr,
    input wire [`TAG_WIDTH - 1 : 0]     tag,
    input wire [`INDEX_WIDTH - 1 : 0]   index,
    input wire [`OFFSET_WIDTH - 1 : 0]  offset,
    input wire [`WORD_WIDTH - 1 : 0]    store_data,
    input wire [`WAY_NUM - 1 : 0]       hit_en,
    input wire                          read_main_memory_en,
    input wire                          way0_replace_en,
    input wire                          way1_replace_en,
    input wire                          way2_replace_en,
    input wire                          way3_replace_en,
    output reg                          wr_r1,
    output reg [`TAG_WIDTH - 1 : 0]     tag_r1,
    output reg [`INDEX_WIDTH - 1 : 0]   index_r1,
    output reg [`OFFSET_WIDTH - 1 : 0]  offset_r1,
    output reg [`WORD_WIDTH - 1 : 0]    store_data_r1,
    output reg [`WAY_NUM - 1 : 0]       hit_en_r1,
    output reg                          read_main_memory_en_r1,
    output reg                          way0_replace_en_r1,
    output reg                          way1_replace_en_r1,
    output reg                          way2_replace_en_r1,
    output reg                          way3_replace_en_r1
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_r1                   <= 0;
        tag_r1                  <= 0;
        index_r1                <= 0;
        offset_r1               <= 0;
        store_data_r1           <= 0;
        hit_en_r1               <= 0;
        read_main_memory_en_r1  <= 0;
        way0_replace_en_r1      <= 0;
        way1_replace_en_r1      <= 0;
        way2_replace_en_r1      <= 0;
        way3_replace_en_r1      <= 0;
    end else begin
        wr_r1                   <= wr;
        tag_r1                  <= tag;
        index_r1                <= index;
        offset_r1               <= offset;
        store_data_r1           <= store_data;
        hit_en_r1               <= hit_en;
        read_main_memory_en_r1  <= read_main_memory_en;
        way0_replace_en_r1      <= way0_replace_en;
        way1_replace_en_r1      <= way1_replace_en;
        way2_replace_en_r1      <= way2_replace_en;
        way3_replace_en_r1      <= way3_replace_en;
    end
end

endmodule
`endif