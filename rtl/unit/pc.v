`ifndef SIICPU_PC
`define SIICPU_PC
`include "define.v"
module pc (
    input wire                          clk,
    input wire                          rst_n,
    input wire                          cpu_en,
    input wire                          pc_stall,
    input wire [`PC_WIDTH-1 : 0]        br_addr,
    input wire                          br_taken,
    output reg [`PC_WIDTH-1 : 0]        pc
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= `PC_WIDTH'b0;
    end else if (cpu_en && !pc_stall) begin
        if (br_taken) begin
            pc <= br_addr;
        end else begin
            pc <= pc + 4;
        end
    end
end

endmodule
`endif