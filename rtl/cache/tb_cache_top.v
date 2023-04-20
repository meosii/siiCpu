`include "cache_top.v"
`include "cache_define.v"
module tb_cache_top ();
// from cpu
reg clk;
reg rst_n;
reg cache_en;
reg wr;
reg  [`ADDR_WIDTH - 1 : 0]       cachein_addr;
reg  [`WORD_WIDTH - 1 : 0]       store_data;
// from main_memory
reg  [`CACHELINE_WIDTH - 1 : 0]  rdata_from_main_memory;
// to cpu
wire [`WORD_WIDTH - 1 : 0]       load_data;
// to write_buffer
wire                             write_buffer_en;
wire [`ADDR_WIDTH - 1 : 0]       addr_to_write_buffer;
wire [`CACHELINE_WIDTH - 1 : 0]  data_to_write_buffer;
// to memory
wire                             read_main_memory_en;
wire [`ADDR_WIDTH - 1 : 0]       addr_to_main_memory;

cache_top u_cache_top(
    .clk(clk),
    .rst_n(rst_n),
    .cache_en(cache_en),
    .wr(wr),
    .cachein_addr(cachein_addr),
    .store_data(store_data),
    .rdata_from_main_memory(rdata_from_main_memory),
    .load_data(load_data),
    .write_buffer_en(write_buffer_en),
    .addr_to_write_buffer(addr_to_write_buffer),
    .data_to_write_buffer(data_to_write_buffer),
    .read_main_memory_en(read_main_memory_en),
    .addr_to_main_memory(addr_to_main_memory)
);

localparam TIME_CLK = 10;

always #(TIME_CLK/2) clk = ~clk;

reg [`CACHELINE_WIDTH - 1 : 0] small_main_memory [255 : 0]; // 256 cachelines = 4 caches

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 255; i ++) begin
            small_main_memory[i] <= i*(2 << 95) + i*(2 << 63) + i*(2 << 31) + i; //cacheline1 = 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rdata_from_main_memory <= 0;
    end else if (read_main_memory_en == 1) begin
        rdata_from_main_memory <= small_main_memory[addr_to_main_memory[31:4]];
    end
end

task test_cache_top(
    input test_wr,
    input [`TAG_WIDTH - 1 : 0]       test_cachein_addr_tag,
    input [`INDEX_WIDTH  - 1 : 0]    test_cachein_addr_index,
    input [`OFFSET_WIDTH - 1 : 0]    test_cachein_addr_offset,
    input [`WORD_WIDTH - 1 : 0]       test_store_data
);
begin
    @(posedge clk)
    begin
        wr                      = test_wr;
        cachein_addr            = {test_cachein_addr_tag, test_cachein_addr_index, test_cachein_addr_offset};
        store_data              = test_store_data;
        $display("when wr = %b, addr = %b, addr_to_main_memory = %h,load_data: %h", test_wr, cachein_addr, addr_to_main_memory, load_data);
    end
end
endtask

initial begin
    #0 begin
        clk = 0;
        rst_n = 0;
        cache_en = 0;
        wr = 0;
        cachein_addr = {22'd0, 4'd0, 4'd0};
        store_data = 0;
    end
    #2 begin
        rst_n = 1;
        cache_en = 1;
    end
    // load
    #1 begin
        // way3
            for (i = 1; i <= 15; i ++) begin
                test_cache_top(`READ, 24'd0, i, 4'd0, 32'b0);
            end
        // way1
            for (i = 0; i <= 15; i ++) begin
                test_cache_top(`READ, 24'd1, i, 4'd0, 32'b0);
            end
        // way2
            for (i = 0; i <= 15; i ++) begin
                test_cache_top(`READ, 24'd2, i, 4'd0, 32'b0);
            end
        // way0
            for (i = 0; i <= 15; i ++) begin
                test_cache_top(`READ, 24'd3, i, 4'd0, 32'b0);
            end
    end
    #1 begin
        $display("small_main_memory[1]: %h", small_main_memory[1]);
        $display("small_main_memory[2]: %h", small_main_memory[2]);
        $display("small_main_memory[3]: %h", small_main_memory[3]);
        $display("small_main_memory[10]: %h", small_main_memory[10]);
        $display("small_main_memory[12]: %h", small_main_memory[12]);
        $display("small_main_memory[32]: %h", small_main_memory[32]);
    end
    $finish();
end

initial begin
    $dumpfile("wave_cache_top.vcd");
    $dumpvars(0,tb_cache_top);
end

endmodule