`ifndef DATA_RAM
`define DATA_RAM
`include "cache_define.v"
`include "LRU_replace.v"
module data_ram (
    input wire                              clk,
    input wire                              rst_n,
    // from decoder
    input wire                              wr, // wr = 1: write
    input wire [`TAG_WIDTH - 1 : 0]         tag,
    input wire [`INDEX_WIDTH - 1 : 0]       index,
    input wire [`OFFSET_WIDTH - 1 : 0]      offset, // offset[3:2] = which word, offset[1:0] = which byte
    input wire [`WORD_WIDTH - 1 : 0]        store_data, // STORE a word
    
    // from tag_ram
    input wire [`WAY_NUM - 1 : 0]           hit_en, // Determine which way is hit

    // to write_buffer
    // if dirty, cache -> write_buffer
    output reg                             write_buffer_en,
    output wire [`ADDR_WIDTH - 1 : 0]      addr_to_write_buffer, // cacheline tag
    output reg [`CACHELINE_WIDTH - 1 : 0]  data_to_write_buffer, 

    // main memory
    // if not hit, main memory -> cache
    output reg                              read_main_memory_en,
    output wire [`ADDR_WIDTH - 1 : 0]       addr_to_main_memory, // instruction tag
    output wire [$clog2(`WAY_NUM) : 0]      replaced_way, // to tag_ram
    input wire [`CACHELINE_WIDTH - 1 : 0]   data_from_main_memory, 

    // LOAD: to cpu
    output reg [`WORD_WIDTH - 1 : 0]        load_data // LOAD a word
);

// Each way has 2^(INDEX_WIDTH) cacheline, each cacheline has CACHELINE_WIDTH bits
reg [`CACHELINE_WIDTH - 1 : 0] way0_data_ram [`LINE_NUM - 1 : 0]; 
reg [`CACHELINE_WIDTH - 1 : 0] way1_data_ram [`LINE_NUM - 1 : 0]; 
reg [`CACHELINE_WIDTH - 1 : 0] way2_data_ram [`LINE_NUM - 1 : 0]; 
reg [`CACHELINE_WIDTH - 1 : 0] way3_data_ram [`LINE_NUM - 1 : 0]; 

// When data is written to the cacheline but not to memory, the line is marked as dirty
// Here, we have 2^(INDEX_WIDTH) cacheline in each way.
reg way0_dirty [`LINE_NUM - 1 : 0]; // 1: dirty
reg way1_dirty [`LINE_NUM - 1 : 0]; 
reg way2_dirty [`LINE_NUM - 1 : 0]; 
reg way3_dirty [`LINE_NUM - 1 : 0]; 

// if no hit, the data in main memory needs to be stored in cahce, 
// and then it is replaced by the way selected by LRU module.
wire [$clog2(`WAY_NUM) : 0]   line0_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line1_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line2_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line3_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line4_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line5_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line6_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line7_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line8_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line9_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line10_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line11_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line12_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line13_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line14_replace_way;
wire [$clog2(`WAY_NUM) : 0]   line15_replace_way;

LRU_replace u_LRU_replace(
    .clk(clk),
    .rst_n(rst_n),
    .hit_en(hit_en),
    .index(index),
    .line0_replace_way(line0_replace_way),
    .line1_replace_way(line1_replace_way),
    .line2_replace_way(line2_replace_way),
    .line3_replace_way(line3_replace_way),
    .line4_replace_way(line4_replace_way),
    .line5_replace_way(line5_replace_way),
    .line6_replace_way(line6_replace_way),
    .line7_replace_way(line7_replace_way),
    .line8_replace_way(line8_replace_way),
    .line9_replace_way(line9_replace_way),
    .line10_replace_way(line10_replace_way),
    .line11_replace_way(line11_replace_way),
    .line12_replace_way(line12_replace_way),
    .line13_replace_way(line13_replace_way),
    .line14_replace_way(line14_replace_way),
    .line15_replace_way(line15_replace_way)
);

// Used to indicate which way of the current index can be replaced
wire way0_replace_en;
wire way1_replace_en;
wire way2_replace_en;
wire way3_replace_en;

assign way0_replace_en = ( ((index == `INDEX_LINE0)  && (line0_replace_way  == `REPLACE_WAY0)) 
                        || ((index == `INDEX_LINE1)  && (line1_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE2)  && (line2_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE3)  && (line3_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE4)  && (line4_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE5)  && (line5_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE6)  && (line6_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE7)  && (line7_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE8)  && (line8_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE9)  && (line9_replace_way  == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE10) && (line10_replace_way == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE11) && (line11_replace_way == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE12) && (line12_replace_way == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE13) && (line13_replace_way == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE14) && (line14_replace_way == `REPLACE_WAY0))
                        || ((index == `INDEX_LINE15) && (line15_replace_way == `REPLACE_WAY0)) )? 1:0;

assign way1_replace_en = (  ((index == `INDEX_LINE0)  && (line0_replace_way  == `REPLACE_WAY1)) 
                        || ((index == `INDEX_LINE1)  && (line1_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE2)  && (line2_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE3)  && (line3_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE4)  && (line4_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE5)  && (line5_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE6)  && (line6_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE7)  && (line7_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE8)  && (line8_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE9)  && (line9_replace_way  == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE10) && (line10_replace_way == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE11) && (line11_replace_way == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE12) && (line12_replace_way == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE13) && (line13_replace_way == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE14) && (line14_replace_way == `REPLACE_WAY1))
                        || ((index == `INDEX_LINE15) && (line15_replace_way == `REPLACE_WAY1)) )? 1:0;

assign way2_replace_en = (  ((index == `INDEX_LINE0)  && (line0_replace_way  == `REPLACE_WAY2)) 
                        || ((index == `INDEX_LINE1)  && (line1_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE2)  && (line2_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE3)  && (line3_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE4)  && (line4_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE5)  && (line5_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE6)  && (line6_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE7)  && (line7_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE8)  && (line8_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE9)  && (line9_replace_way  == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE10) && (line10_replace_way == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE11) && (line11_replace_way == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE12) && (line12_replace_way == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE13) && (line13_replace_way == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE14) && (line14_replace_way == `REPLACE_WAY2))
                        || ((index == `INDEX_LINE15) && (line15_replace_way == `REPLACE_WAY2)) )? 1:0;

assign way3_replace_en = (  ((index == `INDEX_LINE0)  && (line0_replace_way  == `REPLACE_WAY3)) 
                        || ((index == `INDEX_LINE1)  && (line1_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE2)  && (line2_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE3)  && (line3_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE4)  && (line4_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE5)  && (line5_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE6)  && (line6_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE7)  && (line7_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE8)  && (line8_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE9)  && (line9_replace_way  == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE10) && (line10_replace_way == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE11) && (line11_replace_way == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE12) && (line12_replace_way == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE13) && (line13_replace_way == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE14) && (line14_replace_way == `REPLACE_WAY3))
                        || ((index == `INDEX_LINE15) && (line15_replace_way == `REPLACE_WAY3)) )? 1:0;

assign addr_to_write_buffer = {tag, index, offset};
assign addr_to_main_memory  = {tag, index, offset};
assign main_memory_tag      =  tag;

always @(*) begin
    if (hit_en == 0) begin
        read_main_memory_en <= 0;
    end else begin
        read_main_memory_en <= 1;
    end
end

integer i;
// write in cache(data ram)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < (`LINE_NUM - 1); i++) begin
            way0_data_ram[i]    <= 0;
            way1_data_ram[i]    <= 0;
            way2_data_ram[i]    <= 0;
            way3_data_ram[i]    <= 0;
            way0_dirty[i]       <= `NON_DIRTY;
            way1_dirty[i]       <= `NON_DIRTY;
            way2_dirty[i]       <= `NON_DIRTY;
            way3_dirty[i]       <= `NON_DIRTY;
        end
    end else if (wr == `WRITE) begin
    // 1. STORE
        if (hit_en[0] == 1) begin
        // 1.1 way0 is hit
            case (offset[3:2])          // which word will be write
                `OFFSET_WORD0:  way0_data_ram[index][31  : 0 ] <= store_data;
                `OFFSET_WORD1:  way0_data_ram[index][63  : 32] <= store_data;
                `OFFSET_WORD2:  way0_data_ram[index][95  : 64] <= store_data;
                `OFFSET_WORD3:  way0_data_ram[index][127 : 96] <= store_data;
            endcase
            way0_dirty[index] <= `DIRTY;
        end else if (hit_en[1] == 1) begin
        // 1.2 way1 is hit
            case (offset[3:2])
                `OFFSET_WORD0:  way1_data_ram[index][31  : 0 ] <= store_data;
                `OFFSET_WORD1:  way1_data_ram[index][63  : 32] <= store_data;
                `OFFSET_WORD2:  way1_data_ram[index][95  : 64] <= store_data;
                `OFFSET_WORD3:  way1_data_ram[index][127 : 96] <= store_data;
            endcase
            way1_dirty[index] <= `DIRTY;
        end else if (hit_en[2] == 1) begin
        // 1.3 way2 is hit
            case (offset[3:2])
                `OFFSET_WORD0:  way2_data_ram[index][31  : 0 ] <= store_data;
                `OFFSET_WORD1:  way2_data_ram[index][63  : 32] <= store_data;
                `OFFSET_WORD2:  way2_data_ram[index][95  : 64] <= store_data;
                `OFFSET_WORD3:  way2_data_ram[index][127 : 96] <= store_data;
            endcase
            way2_dirty[index] <= `DIRTY;
        end else if (hit_en[3] == 1) begin
        // 1.4 way3 is hit
            case (offset[3:2])
                `OFFSET_WORD0:  way3_data_ram[index][31  : 0 ] <= store_data;
                `OFFSET_WORD1:  way3_data_ram[index][63  : 32] <= store_data;
                `OFFSET_WORD2:  way3_data_ram[index][95  : 64] <= store_data;
                `OFFSET_WORD3:  way3_data_ram[index][127 : 96] <= store_data;
            endcase
            way3_dirty[index] <= `DIRTY;
        end else begin 
        // 1.5 no way is hit (hit_en = 4'b0000) 
            // First judge the current line, then judge which way on this line can be replaced, 
            // and then replace the data of this cacheline with the combined value of store_data and main_data.
            // 1.5.1 way0 could be replaced
            if (way0_replace_en == 1) begin
                case (offset[3:2])
                    `OFFSET_WORD0:  way0_data_ram[index] <= {data_from_main_memory[255:32], store_data};
                    `OFFSET_WORD1:  way0_data_ram[index] <= {data_from_main_memory[255:64], store_data, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way0_data_ram[index] <= {data_from_main_memory[255:96], store_data, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way0_data_ram[index] <= {data_from_main_memory[255:128], store_data, data_from_main_memory[95:0]};
                endcase
                way0_dirty[index] <= `NON_DIRTY;
            // 1.5.2 way1 could be replaced
            end else if (way1_replace_en == 1) begin
                case (offset[3:2])
                    `OFFSET_WORD0:  way1_data_ram[index] <= {data_from_main_memory[255:32], store_data};
                    `OFFSET_WORD1:  way1_data_ram[index] <= {data_from_main_memory[255:64], store_data, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way1_data_ram[index] <= {data_from_main_memory[255:96], store_data, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way1_data_ram[index] <= {data_from_main_memory[255:128], store_data, data_from_main_memory[95:0]};
                endcase
                way1_dirty[index] <= `NON_DIRTY;
            // 1.5.3 way2 could be replaced
            end else if (way2_replace_en == 1) begin
                case (offset[3:2])
                    `OFFSET_WORD0:  way2_data_ram[index] <= {data_from_main_memory[255:32], store_data};
                    `OFFSET_WORD1:  way2_data_ram[index] <= {data_from_main_memory[255:64], store_data, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way2_data_ram[index] <= {data_from_main_memory[255:96], store_data, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way2_data_ram[index] <= {data_from_main_memory[255:128], store_data, data_from_main_memory[95:0]};
                endcase
                way2_dirty[index] <= `NON_DIRTY;
            // 1.5.4 way3 could be replaced
            end else if (way3_replace_en == 1) begin
                case (offset[3:2])
                    `OFFSET_WORD0:  way3_data_ram[index] <= {data_from_main_memory[255:32], store_data};
                    `OFFSET_WORD1:  way3_data_ram[index] <= {data_from_main_memory[255:64], store_data, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way3_data_ram[index] <= {data_from_main_memory[255:96], store_data, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way3_data_ram[index] <= {data_from_main_memory[255:128], store_data, data_from_main_memory[95:0]};
                endcase 
                way3_dirty[index] <= `NON_DIRTY;
            end
        end
    end else begin
    // 2. LOAD
        // When loading, if the cache is not hit, we also need to write data to the cache.
        // At this time, the data written is the main_data.
        if (way0_replace_en == 1) begin
            way0_data_ram[index]    <= data_from_main_memory;
            way0_dirty[index]       <= `NON_DIRTY;
        end else if (way1_replace_en == 1) begin
            way1_data_ram[index]    <= data_from_main_memory;
            way1_dirty[index]       <= `NON_DIRTY;
        end else if (way2_replace_en == 1) begin
            way2_data_ram[index]    <= data_from_main_memory;
            way2_dirty[index]       <= `NON_DIRTY;
        end else if (way3_replace_en == 1) begin
            way3_data_ram[index]    <= data_from_main_memory;
            way3_dirty[index]       <= `NON_DIRTY;
        end
    end
end

// dirty: cache data -> write buffer
always @(*) begin
    if (hit_en == 4'b0000) begin
    // no way is hit
        // write cache_data to write_buffer
        if ((way0_replace_en == 1) && (way0_dirty[index] == `DIRTY)) begin
            data_to_write_buffer = way0_data_ram[index];
            write_buffer_en      = 1;
        end else if ((way1_replace_en == 1) && (way1_dirty[index] == `DIRTY)) begin
            data_to_write_buffer = way1_data_ram[index];
            write_buffer_en      = 1;
        end else if ((way2_replace_en == 1) && (way2_dirty[index] == `DIRTY)) begin
            data_to_write_buffer = way2_data_ram[index];
            write_buffer_en      = 1;
        end else if ((way3_replace_en == 1) && (way3_dirty[index] == `DIRTY)) begin
            data_to_write_buffer = way3_data_ram[index];
            write_buffer_en      = 1;
        end
    end else begin
    // cache hit
        write_buffer_en         = 0;
        data_to_write_buffer    = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_data <= 0;
    end else if (wr == `READ) begin // LOAD
        if (hit_en[0] == 1) begin
            case (offset[3:2])
                `OFFSET_WORD0:  load_data <= way0_data_ram[index][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way0_data_ram[index][63  : 32];
                `OFFSET_WORD2:  load_data <= way0_data_ram[index][95  : 64];
                `OFFSET_WORD3:  load_data <= way0_data_ram[index][127 : 96];
            endcase
        end else if (hit_en[1] == 1) begin
            case (offset[3:2])
                `OFFSET_WORD0:  load_data <= way1_data_ram[index][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way1_data_ram[index][63  : 32];
                `OFFSET_WORD2:  load_data <= way1_data_ram[index][95  : 64];
                `OFFSET_WORD3:  load_data <= way1_data_ram[index][127 : 96];
            endcase
        end else if (hit_en[2] == 1) begin
            case (offset[3:2])
                `OFFSET_WORD0:  load_data <= way2_data_ram[index][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way2_data_ram[index][63  : 32];
                `OFFSET_WORD2:  load_data <= way2_data_ram[index][95  : 64];
                `OFFSET_WORD3:  load_data <= way2_data_ram[index][127 : 96];
            endcase
        end else if (hit_en[3] == 1) begin
            case (offset[3:2])
                `OFFSET_WORD0:  load_data <= way3_data_ram[index][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way3_data_ram[index][63  : 32];
                `OFFSET_WORD2:  load_data <= way3_data_ram[index][95  : 64];
                `OFFSET_WORD3:  load_data <= way3_data_ram[index][127 : 96];
            endcase
        end else begin
            case (offset[3:2])
                `OFFSET_WORD0:  load_data <= data_from_main_memory[31  : 0 ];
                `OFFSET_WORD1:  load_data <= data_from_main_memory[63  : 32];
                `OFFSET_WORD2:  load_data <= data_from_main_memory[95  : 64];
                `OFFSET_WORD3:  load_data <= data_from_main_memory[127 : 96];
            endcase
        end
    end else begin // STORE
        load_data <= 0;
    end
end

endmodule
`endif