`ifndef WRITE_BUFFER
`define WRITE_BUFFER
`include "cache_define.v"
module write_buffer #(
    parameter WRITE_BUFFER_LINE_NUM = 16
)(
    input wire clk,
    input wire rst_n,
    // cache to write_buffer
    input wire                              write_buffer_en,
    input wire [`ADDR_WIDTH - 1 : 0]        win_addr, // {tag, index, offset}
    input wire [`CACHELINE_WIDTH - 1 : 0]   win_data,
    // write_buffer to main memory
    output wire [`ADDR_WIDTH - 1 : 0]       wout_addr,
    output wire [`CACHELINE_WIDTH - 1 : 0]  wout_data
);

// Storing data
reg [`CACHELINE_WIDTH - 1 : 0] write_buffer [WRITE_BUFFER_LINE_NUM - 1 : 0];
// Storing address of data
reg [`ADDR_WIDTH - 1 : 0] addr [WRITE_BUFFER_LINE_NUM - 1 : 0]; 

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wout_addr <= 0;
        wout_data <= 0;
    end else if () begin
        
    end
end

endmodule
`endif