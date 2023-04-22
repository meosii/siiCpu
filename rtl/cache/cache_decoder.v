`ifndef CACHE_DECODER
`define CACHE_DECODER
`include "cache_define.v"
module cache_decoder (
    input wire  [`ADDR_WIDTH - 1 : 0]   cachein_addr,
    output wire [`TAG_WIDTH - 1 : 0]    tag,
    output wire [`INDEX_WIDTH - 1 : 0]  index,
    output wire [`OFFSET_WIDTH - 1 : 0] offset
);

assign tag    = cachein_addr[31 : 8];
assign index  = cachein_addr[7 : 4];
assign offset = cachein_addr[3 : 0];
    
endmodule
`endif