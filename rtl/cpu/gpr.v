`ifndef SIICPU_GPR
`define SIICPU_GPR

`include "define.v"
//General Purpose Registers
//Here, we use up to three registers as operands, 
//read values from two registers and then write values to the other register.
//Therefore, we need two read ports and one write port.
module gpr(
    input wire                                      clk,
    input wire                                      rst_n,
    input wire                                      we_n,    //we_n = 0, GPR_WRITE
    input wire  [`GPR_ADDR_WIDTH - 1 : 0]           wr_addr,
    input wire  [`WORD_WIDTH - 1:0]                 wr_data,
    input wire  [`GPR_ADDR_WIDTH - 1 : 0]           rd_addr_0,
    input wire  [`GPR_ADDR_WIDTH - 1 : 0]           rd_addr_1,
    output wire [`WORD_WIDTH - 1 : 0]               rd_data_0,
    output wire [`WORD_WIDTH - 1 : 0]               rd_data_1,
    // ra
    output wire [`WORD_WIDTH - 1 : 0]               gpr_x1
);

reg [`WORD_WIDTH - 1 : 0] gpr [0 : `DATA_HIGH_GPR - 1];
integer i;

assign rd_data_0 = ((we_n == `GPR_WRITE) && (wr_addr == rd_addr_0))? wr_data : gpr[rd_addr_0];
assign rd_data_1 = ((we_n == `GPR_WRITE) && (wr_addr == rd_addr_1))? wr_data : gpr[rd_addr_1];
assign gpr_x1    = gpr[1];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < `DATA_HIGH_GPR; i = i + 1) begin
            gpr[i] <= `WORD_WIDTH'b0;
        end
    end else if (we_n == `GPR_WRITE) begin
		    gpr[wr_addr] <= wr_data;
    end
end

endmodule

`endif