`ifndef CACHE_TOP
`define CACHE_TOP
`include "cache_define.v"
`include "cache_decoder.v"
`include "tag_ram.v"
`include "replace_data_ctrl.v"
`include "reg1.v"
`include "data_ram.v"
module cache_top (
    // cpu
    input wire clk,
    input wire rst_n,
    input wire                              cache_en,
    input wire                              wr,
    input wire [`ADDR_WIDTH - 1 : 0]        cachein_addr,
    input wire [`WORD_WIDTH - 1 : 0]        store_data,
    output wire [`WORD_WIDTH - 1 : 0]       load_data,

    // to write_buffer
    output wire                              write_buffer_en,
    output wire [`ADDR_WIDTH - 1 : 0]        addr_to_write_buffer,
    output wire  [`CACHELINE_WIDTH - 1 : 0]  data_to_write_buffer,
    
    // main_memory
    output wire                              read_main_memory_en,
    output wire [`ADDR_WIDTH - 1 : 0]        addr_to_main_memory,
    input wire [`CACHELINE_WIDTH - 1 : 0]    rdata_from_main_memory
);

wire [`TAG_WIDTH - 1 : 0]        tag;
wire [`INDEX_WIDTH - 1 : 0]      index;
wire [`OFFSET_WIDTH - 1 : 0]     offset;
wire [`WAY_NUM - 1 : 0]          hit_en;
wire [$clog2(`WAY_NUM) : 0] replaced_way;
wire [`CACHELINE_WIDTH - 1 : 0]  data_from_main_memory;
wire                             wr_r1;
wire [`INDEX_WIDTH - 1 : 0]      index_r1;
wire [`OFFSET_WIDTH - 1 : 0]     offset_r1; 
wire [`WORD_WIDTH - 1 : 0]       store_data_r1; 
wire [`WAY_NUM - 1 : 0]          hit_en_r1;
wire                             way0_replace_en_r1;
wire                             way1_replace_en_r1;
wire                             way2_replace_en_r1;
wire                             way3_replace_en_r1;

cache_decoder u_cache_decoder(
    .cachein_addr(cachein_addr),
    .tag(tag),
    .index(index),
    .offset(offset)
);

tag_ram u_tag_ram(
    .clk(clk),
    .rst_n(rst_n),
    .cache_en(cache_en),
    .tag(tag),
    .index(index),
    .hit_en(hit_en),
    .read_main_memory_en(read_main_memory_en),
    .addr_to_main_memory(addr_to_main_memory),
    .way0_replace_en(way0_replace_en),
    .way1_replace_en(way1_replace_en),
    .way2_replace_en(way2_replace_en),
    .way3_replace_en(way3_replace_en)
);

replace_data_ctrl u_replace_data_ctrl(
    .cache_en(cache_en),
    .cachein_addr(cachein_addr),
    .hit_en(hit_en),
    .rdata_from_main_memory(rdata_from_main_memory), 
    .read_main_memory_en(read_main_memory_en),
    .addr_to_main_memory(addr_to_main_memory),
    .data_from_main_memory(data_from_main_memory)
);

reg1 u_reg1(
    .clk(clk),
    .rst_n(rst_n),
    .wr(wr),
    .index(index),
    .offset(offset),
    .store_data(store_data),
    .hit_en(hit_en),
    .way0_replace_en(way0_replace_en),
    .way1_replace_en(way1_replace_en),
    .way2_replace_en(way2_replace_en),
    .way3_replace_en(way3_replace_en),
    .wr_r1(wr_r1),
    .index_r1(index_r1),
    .offset_r1(offset_r1),
    .store_data_r1(store_data_r1),
    .hit_en_r1(hit_en_r1),
    .way0_replace_en_r1(way0_replace_en_r1),
    .way1_replace_en_r1(way1_replace_en_r1),
    .way2_replace_en_r1(way2_replace_en_r1),
    .way3_replace_en_r1(way3_replace_en_r1)
);

data_ram u_data_ram(
    .clk(clk),
    .rst_n(rst_n),
    .cachein_addr(cachein_addr),
    .wr_r1(wr_r1),
    .index_r1(index_r1),
    .offset_r1(offset_r1),
    .store_data_r1(store_data_r1),
    .hit_en_r1(hit_en_r1),
    .way0_replace_en_r1(way0_replace_en_r1),
    .way1_replace_en_r1(way1_replace_en_r1),
    .way2_replace_en_r1(way2_replace_en_r1),
    .way3_replace_en_r1(way3_replace_en_r1),
    .data_from_main_memory(data_from_main_memory), 
    .write_buffer_en(write_buffer_en),
    .addr_to_write_buffer(addr_to_write_buffer),
    .data_to_write_buffer(data_to_write_buffer),
    .load_data(load_data)
);
    
endmodule
`endif