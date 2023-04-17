`ifndef CACHE_TOP
`define CACHE_TOP
`include "cache_define.v"
`include "cache_decoder.v"
`include "tag_ram.v"
`include "data_ram.v"
module cache_top (
    input wire clk,
    input wire rst_n,
    input wire                              wr,
    input wire [`ADDR_WIDTH - 1 : 0]        cachein_addr,
    input wire [`WORD_WIDTH - 1 : 0]        store_data,
    output wire [`WORD_WIDTH - 1 : 0]       load_data,

    // to write_buffer
    output reg                              write_buffer_en,
    output wire [`ADDR_WIDTH - 1 : 0]       addr_to_write_buffer,
    output reg  [`CACHELINE_WIDTH - 1 : 0]  data_to_write_buffer,
    
    // main memory
    output reg                              read_main_memory_en,
    output wire [`ADDR_WIDTH - 1 : 0]       addr_to_main_memory,
    input wire [`CACHELINE_WIDTH - 1 : 0]   data_from_main_memory
);

wire [`TAG_WIDTH - 1 : 0]       tag;
wire [`INDEX_WIDTH - 1 : 0]     index;
wire [`OFFSET_WIDTH - 1 : 0]    offset;
wire [`WAY_NUM - 1 : 0]         hit_en;
wire [`ADDR_WIDTH - 1 : 0]      addr_to_main_memory;
wire [$clog2(`WAY_NUM) : 0]     replaced_way;


cache_decoder u_cache_decoder(
    .cachein_addr(cachein_addr),
    .tag(tag),
    .index(index),
    .offset(offset)
);

tag_ram u_tag_ram(
    .clk(clk),
    .rst_n(rst_n),
    .tag(tag),
    .index(index),
    .hit_en(hit_en),
    .read_main_memory_en(read_main_memory_en),
    .addr_to_main_memory(addr_to_main_memory),
    .replaced_way(replaced_way)
);

data_ram u_data_ram(
    .clk(clk),
    .rst_n(rst_n),
    .wr(wr),
    .tag(tag),
    .index(index),
    .offset(offset),
    .store_data(store_data),
    .hit_en(hit_en),
    .write_buffer_en(write_buffer_en),
    .addr_to_write_buffer(addr_to_write_buffer),
    .data_to_write_buffer(data_to_write_buffer),
    .read_main_memory_en(read_main_memory_en),
    .addr_to_main_memory(addr_to_main_memory),
    .replaced_way(replaced_way),
    .data_from_main_memory(data_from_main_memory), 
    .load_data(load_data)
);
    
endmodule
`endif