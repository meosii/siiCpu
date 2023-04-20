`ifndef TAG_RAM
`define TAG_RAM
`include "cache_define.v"
`include "LRU.v"
module tag_ram (
    input wire                              clk,
    input wire                              rst_n,
    input wire                              cache_en,
    // from decoder
    input wire  [`TAG_WIDTH - 1 : 0]        tag,   // from decoder
    input wire  [`INDEX_WIDTH - 1 : 0]      index, // from decoder
    output reg [`WAY_NUM - 1 : 0]           hit_en,
    // from replace_data_ctrl
    input wire                              read_main_memory_en,
    input wire  [`ADDR_WIDTH - 1 : 0]       addr_to_main_memory,
    // to data_ram
    output wire                             way0_replace_en,
    output wire                             way1_replace_en,
    output wire                             way2_replace_en,
    output wire                             way3_replace_en
    
);

reg [`LINE_NUM - 1 : 0] way0_value; // way0_value[0] -> way0 line0 value
reg [`LINE_NUM - 1 : 0] way1_value;
reg [`LINE_NUM - 1 : 0] way2_value;
reg [`LINE_NUM - 1 : 0] way3_value;

reg [`TAG_WIDTH - 1 : 0] way0_tag_ram [`LINE_NUM - 1 : 0];
reg [`TAG_WIDTH - 1 : 0] way1_tag_ram [`LINE_NUM - 1 : 0];
reg [`TAG_WIDTH - 1 : 0] way2_tag_ram [`LINE_NUM - 1 : 0];
reg [`TAG_WIDTH - 1 : 0] way3_tag_ram [`LINE_NUM - 1 : 0];

wire [`TAG_WIDTH - 1 : 0]    main_memory_tag;
wire [`INDEX_WIDTH - 1 : 0]  main_memory_index;

assign main_memory_tag   = addr_to_main_memory[31 : 8];
assign main_memory_index = addr_to_main_memory[7 : 4];

integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < `LINE_NUM; i ++) begin
            way0_value[i] <= 0;
            way1_value[i] <= 0;
            way2_value[i] <= 0;
            way3_value[i] <= 0;
            way0_tag_ram[i] <= 0;
            way1_tag_ram[i] <= 0;
            way2_tag_ram[i] <= 0;
            way3_tag_ram[i] <= 0;
        end
    end else if (read_main_memory_en == 1) begin
        case (replaced_way)
            `REPLACE_WAY0: begin
                way0_tag_ram[main_memory_index] <= main_memory_tag;
                way0_value[main_memory_index]   <= 1;
            end
            `REPLACE_WAY1: begin
                way1_tag_ram[main_memory_index] <= main_memory_tag;
                way1_value[main_memory_index]   <= 1;
            end
            `REPLACE_WAY2: begin
                way2_tag_ram[main_memory_index] <= main_memory_tag;
                way2_value[main_memory_index]   <= 1;
            end
            `REPLACE_WAY3: begin
                way3_tag_ram[main_memory_index] <= main_memory_tag;
                way3_value[main_memory_index]   <= 1;
            end
            // replaced_way = NO_REPLACE_WAY, do nothing
        endcase
    end
end

always @(*) begin
    if ((way0_tag_ram[index] == tag) && (way0_value[index] == 1)) begin
        hit_en[0] <= 1;
    end else begin
        hit_en[0] <= 0;
    end
    if ((way1_tag_ram[index] == tag) && (way1_value[index] == 1)) begin
        hit_en[1] <= 1;
    end else begin
        hit_en[1] <= 0;
    end
    if ((way2_tag_ram[index] == tag) && (way2_value[index] == 1)) begin
        hit_en[2] <= 1;
    end else begin
        hit_en[2] <= 0;
    end
    if ((way3_tag_ram[index] == tag) && (way3_value[index] == 1)) begin
        hit_en[3] <= 1;
    end else begin
        hit_en[3] <= 0;
    end
end

wire  [$clog2(`WAY_NUM): 0] replaced_way;

LRU u_LRU(
    .clk(clk),
    .rst_n(rst_n),
    .cache_en(cache_en),
    .hit_en(hit_en),
    .index(index),
    .way0_value(way0_value),
    .way1_value(way1_value),
    .way2_value(way2_value),
    .way3_value(way3_value),
    .way0_replace_en(way0_replace_en),
    .way1_replace_en(way1_replace_en),
    .way2_replace_en(way2_replace_en),
    .way3_replace_en(way3_replace_en),
    .replaced_way(replaced_way)
);

endmodule
`endif