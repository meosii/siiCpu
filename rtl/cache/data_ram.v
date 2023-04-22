`ifndef DATA_RAM
`define DATA_RAM
`include "cache_define.v"
module data_ram (
    input wire                              clk,
    input wire                              rst_n,
    input wire [`ADDR_WIDTH - 1 : 0]        cachein_addr,
    input wire [`INDEX_WIDTH - 1 : 0]       index,
    
    // tag_ram
    // for writting to write buffer
    input wire [`WAY_NUM - 1 : 0]           hit_en,         // Determine which way is hit
    input wire                              way0_replace_en,
    input wire                              way1_replace_en,
    input wire                              way2_replace_en,
    input wire                              way3_replace_en,

    // from replace_data_ctrl (main_memory data)
    input wire [`CACHELINE_WIDTH - 1 : 0]   data_from_main_memory,
    // from reg1
        // from decoder
    input wire                              wr_r1,          // wr = 1: write
    input wire [`INDEX_WIDTH - 1 : 0]       index_r1,
    input wire [`OFFSET_WIDTH - 1 : 0]      offset_r1,      // offset[3:2] = which word, offset[1:0] = which byte
    input wire [`WORD_WIDTH - 1 : 0]        store_data_r1,  // STORE a word
        // from tag_ram
    input wire [`WAY_NUM - 1 : 0]           hit_en_r1,      // Determine which way is hit
    input wire                              way0_replace_en_r1,
    input wire                              way1_replace_en_r1,
    input wire                              way2_replace_en_r1,
    input wire                              way3_replace_en_r1,
    
    // to write_buffer
    output reg                              write_buffer_en,
    output reg [`ADDR_WIDTH - 1 : 0]        addr_to_write_buffer, // cacheline tag
    output reg [`CACHELINE_WIDTH - 1 : 0]   data_to_write_buffer, 
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

// if data_from_main_memory needs a clock to read in memory, 
// then all the signals of the following "always" need a beat
integer i;
// write in cache(data ram)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < `LINE_NUM; i = i + 1) begin
            way0_data_ram[i]    <= 0;
            way1_data_ram[i]    <= 0;
            way2_data_ram[i]    <= 0;
            way3_data_ram[i]    <= 0;
            way0_dirty[i]       <= `NON_DIRTY;
            way1_dirty[i]       <= `NON_DIRTY;
            way2_dirty[i]       <= `NON_DIRTY;
            way3_dirty[i]       <= `NON_DIRTY;
        end
    end else if (wr_r1 == `WRITE) begin
    // 1. STORE
        if (hit_en_r1[0] == 1) begin
        // 1.1 way0 is hit
            case (offset_r1[3:2])          // which word will be write
                `OFFSET_WORD0:  way0_data_ram[index_r1][31  : 0 ] <= store_data_r1;
                `OFFSET_WORD1:  way0_data_ram[index_r1][63  : 32] <= store_data_r1;
                `OFFSET_WORD2:  way0_data_ram[index_r1][95  : 64] <= store_data_r1;
                `OFFSET_WORD3:  way0_data_ram[index_r1][127 : 96] <= store_data_r1;
            endcase
            way0_dirty[index_r1] <= `DIRTY;
        end else if (hit_en_r1[1] == 1) begin
        // 1.2 way1 is hit
            case (offset_r1[3:2])
                `OFFSET_WORD0:  way1_data_ram[index_r1][31  : 0 ] <= store_data_r1;
                `OFFSET_WORD1:  way1_data_ram[index_r1][63  : 32] <= store_data_r1;
                `OFFSET_WORD2:  way1_data_ram[index_r1][95  : 64] <= store_data_r1;
                `OFFSET_WORD3:  way1_data_ram[index_r1][127 : 96] <= store_data_r1;
            endcase
            way1_dirty[index_r1] <= `DIRTY;
        end else if (hit_en_r1[2] == 1) begin
        // 1.3 way2 is hit
            case (offset_r1[3:2])
                `OFFSET_WORD0:  way2_data_ram[index_r1][31  : 0 ] <= store_data_r1;
                `OFFSET_WORD1:  way2_data_ram[index_r1][63  : 32] <= store_data_r1;
                `OFFSET_WORD2:  way2_data_ram[index_r1][95  : 64] <= store_data_r1;
                `OFFSET_WORD3:  way2_data_ram[index_r1][127 : 96] <= store_data_r1;
            endcase
            way2_dirty[index_r1] <= `DIRTY;
        end else if (hit_en_r1[3] == 1) begin
        // 1.4 way3 is hit
            case (offset_r1[3:2])
                `OFFSET_WORD0:  way3_data_ram[index_r1][31  : 0 ] <= store_data_r1;
                `OFFSET_WORD1:  way3_data_ram[index_r1][63  : 32] <= store_data_r1;
                `OFFSET_WORD2:  way3_data_ram[index_r1][95  : 64] <= store_data_r1;
                `OFFSET_WORD3:  way3_data_ram[index_r1][127 : 96] <= store_data_r1;
            endcase
            way3_dirty[index_r1] <= `DIRTY;
        end else begin 
        // 1.5 no way is hit (hit_en_r1 = 4'b0000) 
            // First judge the current line, then judge which way on this line can be replaced, 
            // and then replace the data of this cacheline with the combined value of store_data and main_data.
            // 1.5.1 way0 could be replaced
            if (way0_replace_en_r1 == 1) begin
                case (offset_r1[3:2])
                    `OFFSET_WORD0:  way0_data_ram[index_r1] <= {data_from_main_memory[127:32], store_data_r1};
                    `OFFSET_WORD1:  way0_data_ram[index_r1] <= {data_from_main_memory[127:64], store_data_r1, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way0_data_ram[index_r1] <= {data_from_main_memory[127:96], store_data_r1, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way0_data_ram[index_r1] <= {store_data_r1, data_from_main_memory[95:0]};
                endcase
                way0_dirty[index_r1]   <= `NON_DIRTY;
            // 1.5.2 way1 could be replaced
            end else if (way1_replace_en_r1 == 1) begin
                case (offset_r1[3:2])
                    `OFFSET_WORD0:  way1_data_ram[index_r1] <= {data_from_main_memory[127:32], store_data_r1};
                    `OFFSET_WORD1:  way1_data_ram[index_r1] <= {data_from_main_memory[127:64], store_data_r1, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way1_data_ram[index_r1] <= {data_from_main_memory[127:96], store_data_r1, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way1_data_ram[index_r1] <= {store_data_r1, data_from_main_memory[95:0]};
                endcase
                way1_dirty[index_r1]   <= `NON_DIRTY;
            // 1.5.3 way2 could be replaced
            end else if (way2_replace_en_r1 == 1) begin
                case (offset_r1[3:2])
                    `OFFSET_WORD0:  way2_data_ram[index_r1] <= {data_from_main_memory[127:32], store_data_r1};
                    `OFFSET_WORD1:  way2_data_ram[index_r1] <= {data_from_main_memory[127:64], store_data_r1, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way2_data_ram[index_r1] <= {data_from_main_memory[127:96], store_data_r1, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way2_data_ram[index_r1] <= {store_data_r1, data_from_main_memory[95:0]};
                endcase
                way2_dirty[index_r1]   <= `NON_DIRTY;
            // 1.5.4 way3 could be replaced
            end else if (way3_replace_en_r1 == 1) begin
                case (offset_r1[3:2])
                    `OFFSET_WORD0:  way3_data_ram[index_r1] <= {data_from_main_memory[127:32], store_data_r1};
                    `OFFSET_WORD1:  way3_data_ram[index_r1] <= {data_from_main_memory[127:64], store_data_r1, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way3_data_ram[index_r1] <= {data_from_main_memory[127:96], store_data_r1, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way3_data_ram[index_r1] <= {store_data_r1, data_from_main_memory[95:0]};
                endcase 
                way3_dirty[index_r1]   <= `NON_DIRTY;
            end
        end
    end else begin
    // 2. LOAD
        if (hit_en_r1 == 4'b0000) begin
        // When loading, if the cache is not hit, we also need to write data to the cache.
        // At this time, the data being written is the main_data.
            if (way0_replace_en_r1 == 1) begin
                way0_data_ram[index_r1]    <= data_from_main_memory;
                way0_dirty[index_r1]       <= `NON_DIRTY;
            end else if (way1_replace_en_r1 == 1) begin
                way1_data_ram[index_r1]    <= data_from_main_memory;
                way1_dirty[index_r1]       <= `NON_DIRTY;
            end else if (way2_replace_en_r1 == 1) begin
                way2_data_ram[index_r1]    <= data_from_main_memory;
                way2_dirty[index_r1]       <= `NON_DIRTY;
            end else if (way3_replace_en_r1 == 1) begin
                way3_data_ram[index_r1]    <= data_from_main_memory;
                way3_dirty[index_r1]       <= `NON_DIRTY;
            end
        end
    end
end

// hit: first clock edge
// no hit: third clock edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_data <= 0;
    end else if (wr_r1 == `READ) begin // LOAD
        if (hit_en_r1[0] == 1) begin
            case (offset_r1[3:2])
                `OFFSET_WORD0:  load_data <= way0_data_ram[index_r1][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way0_data_ram[index_r1][63  : 32];
                `OFFSET_WORD2:  load_data <= way0_data_ram[index_r1][95  : 64];
                `OFFSET_WORD3:  load_data <= way0_data_ram[index_r1][127 : 96];
            endcase
        end else if (hit_en_r1[1] == 1) begin
            case (offset_r1[3:2])
                `OFFSET_WORD0:  load_data <= way1_data_ram[index_r1][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way1_data_ram[index_r1][63  : 32];
                `OFFSET_WORD2:  load_data <= way1_data_ram[index_r1][95  : 64];
                `OFFSET_WORD3:  load_data <= way1_data_ram[index_r1][127 : 96];
            endcase
        end else if (hit_en_r1[2] == 1) begin
            case (offset_r1[3:2])
                `OFFSET_WORD0:  load_data <= way2_data_ram[index_r1][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way2_data_ram[index_r1][63  : 32];
                `OFFSET_WORD2:  load_data <= way2_data_ram[index_r1][95  : 64];
                `OFFSET_WORD3:  load_data <= way2_data_ram[index_r1][127 : 96];
            endcase
        end else if (hit_en_r1[3] == 1) begin
            case (offset_r1[3:2])
                `OFFSET_WORD0:  load_data <= way3_data_ram[index_r1][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way3_data_ram[index_r1][63  : 32];
                `OFFSET_WORD2:  load_data <= way3_data_ram[index_r1][95  : 64];
                `OFFSET_WORD3:  load_data <= way3_data_ram[index_r1][127 : 96];
            endcase
        end else begin
            case (offset_r1[3:2])
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

// dirty: cache data -> write buffer
// here, we use hit_en rather than hit_en_r1
// the second clock edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_buffer_en      <= 0;
        addr_to_write_buffer <= 0;
        data_to_write_buffer <= 0;
    end else if (hit_en == 4'b0000) begin
    // no way is hit
        write_buffer_en      <= 1;
        addr_to_write_buffer <= cachein_addr;
        // write cache_data to write_buffer
        if ((way0_replace_en == 1) && (way0_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way0_data_ram[index];
        end else if ((way1_replace_en == 1) && (way1_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way1_data_ram[index];
        end else if ((way2_replace_en == 1) && (way2_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way2_data_ram[index];
        end else if ((way3_replace_en == 1) && (way3_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way3_data_ram[index];
        end
    end else begin
    // cache hit
        write_buffer_en         <= 0;
        addr_to_write_buffer    <= 0;
        data_to_write_buffer    <= 0;
    end
end

endmodule
`endif