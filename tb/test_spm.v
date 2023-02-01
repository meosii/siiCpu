`include "spm.v"

module test_spm ();

reg clk;
reg rst_;
reg [11:0] if_spm_addr;
reg if_spm_as_;
reg if_spm_rw;
reg [31:0] if_spm_wr_data;
reg [11:0] mem_spm_addr;
reg mem_spm_as_;
reg mem_spm_rw;
reg [31:0] mem_spm_wr_data;
wire [31:0] if_spm_rd_data;
wire [31:0] mem_spm_rd_data;

spm u_spm(
.clk(clk),
.rst_(rst_),
.if_spm_addr(if_spm_addr),
.if_spm_as_(if_spm_as_),
.if_spm_rw(if_spm_rw),
.if_spm_wr_data(if_spm_wr_data),
.mem_spm_addr(mem_spm_addr),
.mem_spm_as_(mem_spm_as_),
.mem_spm_rw(mem_spm_rw),
.mem_spm_wr_data(mem_spm_wr_data),
.if_spm_rd_data(if_spm_rd_data),
.mem_spm_rd_data(mem_spm_rd_data)
);

parameter READ = 1;
parameter WRITE = 0;
integer i;

always #5 clk = ~clk;

initial begin
    #0 begin
        clk = 0;
        rst_ = 0;
    end
    #1 begin
        rst_ = 1;
    end
    #10 begin
        mem_spm_as_ = 0;
        mem_spm_rw = WRITE;
        for (i = 0; i < 40; i++) begin
            @(posedge clk);
            #1 begin
                mem_spm_addr = i;
                mem_spm_wr_data = i;
            end
        end
        if_spm_addr = 0;
        if_spm_as_ = 1;
        if_spm_rw = READ;
        if_spm_wr_data = 0;
    end
    #10 begin
        mem_spm_wr_data = 0;
        mem_spm_as_ = 0;
        mem_spm_rw = READ;
        for (i = 0; i < 40; i++) begin
            @(posedge clk);
            #1 begin
                mem_spm_addr = i;
            end
        end
    end
    #10 $finish;
end

initial begin
    $dumpfile("wave_spm.vcd");
    $dumpvars(0,test_spm);
end

endmodule