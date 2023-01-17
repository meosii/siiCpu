`include "cpu_top.v"

module test_cpu_top();
reg cpu_en;
reg clk;
reg reset;
//spm
reg [29:0] test_spm_addr;
reg test_spm_as_;
reg test_spm_rw;
reg [31:0] test_spm_wr_data;
wire [31:0] test_spm_rd_data;

cpu_top u_cpu_top(
.cpu_en(cpu_en),
.clk(clk),
.reset(reset),
.test_spm_addr(test_spm_addr),
.test_spm_as_(test_spm_as_),
.test_spm_rw(test_spm_rw),
.test_spm_wr_data(test_spm_wr_data),
.test_spm_rd_data(test_spm_rd_data)
);

integer i;
parameter TIMECLK = 10;
always #(TIMECLK/2) clk = ~clk;

initial begin
   #0 begin
        clk = 0;
        reset = 0;
        cpu_en = 0;
   end
    #TIMECLK begin
        reset = 1;
    end
    // spm 中写入指令
    #TIMECLK begin
        `test_spm_write(0,`WRITE,0,12'b0000_0000_0000,5'b1111_1,5'b0000_0)
        `test_spm_write(0,`WRITE,4,12'b0000_0000_0001,5'b1111_1,5'b0000_1)
        `test_spm_write(0,`WRITE,8,12'b0000_0000_0010,5'b1111_1,5'b0001_0)
        `test_spm_write(0,`WRITE,12,12'b0000_0000_0011,5'b1111_1,5'b0001_1)
        `test_spm_write(0,`WRITE,16,12'b0000_0000_0100,5'b1111_1,5'b0010_0)
        `test_spm_write(0,`WRITE,20,12'b0000_0000_0101,5'b1111_1,5'b0010_1)
        `test_spm_write(0,`WRITE,24,12'b0000_0000_0110,5'b1111_1,5'b0011_0)
        `test_spm_write(0,`WRITE,28,12'b0000_0000_0111,5'b1111_1,5'b0011_1)
        `test_spm_write(0,`WRITE,32,12'b0000_0000_1000,5'b1111_1,5'b0100_0)
        `test_spm_write(0,`WRITE,36,12'b0000_0000_0001,5'b1111_1,5'b0100_1)
        `test_spm_write(0,`WRITE,40,12'b0000_0000_0010,5'b1111_1,5'b0101_0)
        `test_spm_write(0,`WRITE,44,12'b0000_0000_0011,5'b1111_1,5'b0101_1)
        `test_spm_write(0,`WRITE,48,12'b0000_0000_0111,5'b1111_1,5'b0110_0)
        `test_spm_write(0,`WRITE,52,12'b0000_0000_1000,5'b1111_1,5'b0111_0)
        `test_spm_write(0,`WRITE,56,12'b0000_0000_0001,5'b1111_1,5'b0111_1)
        `test_spm_write(0,`WRITE,60,12'b0000_0000_0010,5'b1111_1,5'b1000_0)
        `test_spm_write(0,`WRITE,64,12'b0000_0000_0011,5'b1111_1,5'b1000_1)
    end
    // 读出 spm 中的指令验证对错
    #TIMECLK begin
        test_spm_wr_data = 0;
        test_spm_addr = 0;
        test_spm_rw = `READ;
        for (i = 0; i < 16; i++) begin
            @(posedge clk);
            #1 begin
                test_spm_addr = i * 4;
            end
        end
    end
    #10
    // // cpu 测试
    // #10 begin
    //     test_spm_as_ = 1;
    //     cpu_en = 1;
    // end
    // #120
    $finish;
end

initial begin
    $dumpfile("wave_cpu_top.vcd");
    $dumpvars(0,test_cpu_top);
end

endmodule