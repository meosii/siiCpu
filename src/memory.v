module memory(
    input wire clk,
    input wire rst_,
    input wire [29:0] memory_addr,
    input wire memory_as_,
    input wire memory_rw,
    input wire [31:0] memory_wr_data,
    output wire [31:0] memory_rd_data
);

parameter READ = 1;
parameter WRITE = 0;
reg [7:0] memory [0:(2^30 - 1)];
integer i;

assign memory_rd_data = (!memory_as_ && (memory_rw == READ))? 
                        {memory[memory_addr],memory[memory_addr + 1],memory[memory_addr + 2],memory[memory_addr + 3]} : 0;

always @(posedge clk or negedge rst_) begin
    if (!rst_) begin
        for (i = 0;i < (2^30 - 1);i++) begin
            memory[i] <= 0;
        end
    end else if (!memory_as_ && (memory_rw == WRITE)) begin
        memory[memory_addr] <= memory_wr_data[31:24];
        memory[memory_addr + 1] <= memory_wr_data[23:16];
        memory[memory_addr + 2] <= memory_wr_data[15:8];
        memory[memory_addr + 3] <= memory_wr_data[7:0];
    end
end

endmodule