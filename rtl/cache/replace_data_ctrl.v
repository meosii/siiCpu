`ifndef REPLACE_DATA_CTRL
`define REPLACE_DATA_CTRL
`include "cache_define.v"
// if not hit, main memory -> cache
module replace_data_ctrl (
    input wire                             cache_en,
    input wire  [`ADDR_WIDTH - 1 : 0]      cachein_addr,
    input wire [`WAY_NUM - 1 : 0]          hit_en,
    // to main_memory
    output reg                             read_main_memory_en,
    output reg [`ADDR_WIDTH - 1 : 0]       addr_to_main_memory,
    output wire [`CACHELINE_WIDTH - 1 : 0] data_from_main_memory,
    // from main_memory
    input wire [`CACHELINE_WIDTH - 1 : 0]  rdata_from_main_memory
);

assign data_from_main_memory = rdata_from_main_memory;

always @(*) begin
    if ((hit_en == 0) && (cache_en == 1)) begin
        read_main_memory_en = 1;
        addr_to_main_memory = cachein_addr;
    end else begin
        read_main_memory_en = 0;
        addr_to_main_memory = 0;
    end
end

endmodule

`endif