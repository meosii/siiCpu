`include "mem_ctrl.v"
`include "define.v"
`include "memory.v"

module test_mem_ctrl ();
reg ex_en;
reg [`DATA_WIDTH_MEM_OP - 1:0] ex_mem_op;
reg [`DATA_WIDTH_GPR - 1:0] ex_mem_wr_data;
reg [`DATA_WIDTH_GPR - 1:0] ex_out;
wire [`DATA_WIDTH_GPR - 1:0] rd_data;
wire [`WORD_ADDR_BUS] addr;
wire as_;
wire rw;
wire [`DATA_WIDTH_GPR - 1:0] wr_data;
wire [`DATA_WIDTH_GPR - 1:0] out;
wire miss_align;

reg clk;
reg rst_;

integer i;

always #5 clk = ~clk;

mem_ctrl u_mem_ctrl(
    .ex_en(ex_en),
    .ex_mem_op(ex_mem_op),
    .ex_mem_wr_data(ex_mem_wr_data),
    .ex_out(ex_out),
    .rd_data(rd_data),
    .addr(addr),
    .as_(as_),
    .rw(rw),
    .wr_data(wr_data),
    .out(out),
    .miss_align(miss_align)
);

memory u_memory(
    .clk(clk),
    .rst_(rst_),
    .memory_addr(addr),
    .memory_as_(as_),
    .memory_rw(rw),
    .memory_wr_data(wr_data),
    .memory_rd_data(rd_data)
);

initial begin
    #0 begin
        clk = 0;
        rst_ = 0;
    end
    #1 begin
        rst_ = 1;
    end
    #1 begin
        ex_en = 1;
        ex_mem_op = `MEM_OP_STORE;
        for (i = 0; i < 40; i ++) begin
            @(posedge clk);
            #1 begin
                ex_out = i * 4 * 4;
                ex_mem_wr_data = 32'b0000_0001_0010_0011_0100_0101_0110_0111;
            end
        end
    end
    #10 begin
        ex_mem_wr_data = 0;
        ex_out = 0;
        ex_mem_op = `MEM_OP_LOAD_LH;
        for (i = 0; i < 40; i ++) begin
            @(posedge clk);
            #1 begin
                ex_out = i * 4;
            end
        end
    end
    #10
    $finish;
end

initial begin
    $dumpfile("wave_mem_ctrl.vcd");
    $dumpvars(0,test_mem_ctrl);
end

endmodule