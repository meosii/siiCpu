`include "unit/gpr.v"
`timescale 1ps/1ps
module test_gpr();

reg clk;
reg reset;
reg we_;
reg [4:0] wr_addr;
reg [31:0] wr_data;
reg [4:0] rd_addr_0;
reg [4:0] rd_addr_1;
wire [31:0] rd_data_0;
wire [31:0] rd_data_1;

parameter TIMECLK = 6;
integer i;

gpr u_gpr(
    .clk(clk),
    .reset(reset),
    .we_(we_),
    .wr_addr(wr_addr),
    .wr_data(wr_data),
    .rd_addr_0(rd_addr_0),
    .rd_addr_1(rd_addr_1),
    .rd_data_0(rd_data_0),
    .rd_data_1(rd_data_1)
);

always #(TIMECLK/2) clk = ~clk;

initial begin
    #0 begin
        clk = 0;
        reset = 0;
    end
    #TIMECLK begin
        reset = 1;
        we_ = 0;
    end
    #1 begin
        for (i = 0; i < 32; i++) begin
            @(posedge clk);
            #1 begin
                wr_addr = i;
                wr_data = i;
            end
        end
    end
    #1 begin
        we_ = 1;
        for (i = 0; i < 32; i++) begin
            @(posedge clk);
            #1 begin
                rd_addr_0 = i;
            end
        end
    end
    #1
    $finish;
end

initial begin
    $dumpfile("wave_gpr.vcd");
    $dumpvars(0,test_gpr);
end

endmodule