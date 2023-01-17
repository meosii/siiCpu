`include "memory.v"

module test_memory ();

reg clk;
reg rst_;
reg [29:0] memory_addr;
reg memory_as_;
reg memory_rw;
reg [31:0] memory_wr_data;
wire [31:0] memory_rd_data;

memory u_memory(
.clk(clk),
.rst_(rst_),
.memory_addr(memory_addr),
.memory_as_(memory_as_),
.memory_rw(memory_rw),
.memory_wr_data(memory_wr_data),
.memory_rd_data(memory_rd_data)
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
        memory_as_ = 0;
        memory_rw = WRITE;
        for (i = 0; i < 40; i++) begin
            @(posedge clk);
            #1 begin
                memory_addr = i * 4;
                memory_wr_data = 32'b0011_0101_1101_1111_0000_1101_1011_0011;
            end
        end
    end
    #10 begin
        memory_wr_data = 0;
        memory_as_ = 0;
        memory_rw = READ;
        for (i = 0; i < 40; i++) begin
            @(posedge clk);
            #1 begin
                memory_addr = i;
            end
        end
    end
    #10 $finish;
end

initial begin
    $dumpfile("wave_memory.vcd");
    $dumpvars(0,test_memory);
end

endmodule