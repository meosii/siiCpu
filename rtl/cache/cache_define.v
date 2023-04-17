/* 
Here, we will design a two-way set associative cache,
and use an example of a cache with the following specifications:

- The capacity of the design cache is 2048 bytes = 1 KB
- The capacity of the main memory is 2^32 bytes = 4 GB
- The cache is Four-way set associative, meaning that each cache set contains four ways

 There are 4 cacheways, each with 16 cachelines, and each cacheline is 4 words.
 So, we use 24 bits for the tag, 4 bits for the set index and 4 bits for the offset. 
| Tag (24 bits) | Index (4 bits) | Offset (4 bits) |
*/

`ifndef CACHE_DEFINE
`define CACHE_DEFINE

`define ADDR_WIDTH          32 //{tag, index, offset}
`define OFFSET_WIDTH         4  // 2^4-byte= 16-byte
`define INDEX_WIDTH          4  // 16-cacheline
`define TAG_WIDTH            24 // 32 - 4 - 4
`define WAY_NUM             4  // 4-cacheway (2^(`INDEX_WIDTH))
`define LINE_NUM            16 // 16-cacheline
`define WORD_WIDTH          32 // 1 word = 32 bits
`define CACHELINE_WIDTH     128 // a cachelie has 128 bits
`define WRITE   1
`define READ    0

//offset[3:2]
`define OFFSET_WORD0 2'b00
`define OFFSET_WORD1 2'b01
`define OFFSET_WORD2 2'b10
`define OFFSET_WORD3 2'b11

`define DIRTY 1
`define NON_DIRTY 0

// line_replace_way[1:0]
`define REPLACE_WAY0 0
`define REPLACE_WAY1 1
`define REPLACE_WAY2 2
`define REPLACE_WAY3 3

// hit_en[`WAY_NUM - 1 : 0]
`define HIT_WAY0 4'b0001
`define HIT_WAY1 4'b0010
`define HIT_WAY2 4'b0100
`define HIT_WAY3 4'b1000
`define NO_HIT   4'b0000

// index[`INDEX_WIDTH - 1 : 0]
`define INDEX_LINE0 4'b0000
`define INDEX_LINE1 4'b0001
`define INDEX_LINE2 4'b0010
`define INDEX_LINE3 4'b0011
`define INDEX_LINE4 4'b0100
`define INDEX_LINE5 4'b0101
`define INDEX_LINE6 4'b0110
`define INDEX_LINE7 4'b0111
`define INDEX_LINE8 4'b1000
`define INDEX_LINE9 4'b1001
`define INDEX_LINE10 4'b1010
`define INDEX_LINE11 4'b1011
`define INDEX_LINE12 4'b1100
`define INDEX_LINE13 4'b1101
`define INDEX_LINE14 4'b1110
`define INDEX_LINE15 4'b1111

`endif