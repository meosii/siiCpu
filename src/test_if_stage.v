`include "if_stage.v"
`include "spm.v"
`include "define.v"

module test_if_stage ();
//if_stage
reg cpu_en;
reg clk;
reg reset;
reg br_taken;
reg [`WORD_ADDR_BUS] br_addr;
wire [`DATA_WIDTH_INSN - 1:0] insn; //from spm
wire [`WORD_ADDR_BUS] if_pc;
wire [`DATA_WIDTH_INSN - 1:0] if_insn;
wire if_en;
//write to spm
reg [`WORD_ADDR_BUS] mem_spm_addr;
reg mem_spm_as_;
reg mem_spm_rw;
reg [31:0] mem_spm_wr_data;
wire [31:0] mem_spm_rd_data;

if_stage u_if_stage(
    .cpu_en(cpu_en),
    .clk(clk),
    .reset(reset),
    .br_taken(br_taken),
    .br_addr(br_addr),
    .insn(insn),
    .if_pc(if_pc),
    .if_insn(if_insn),
    .if_en(if_en)
);

spm u_spm(
    .clk(clk),
    .rst_(reset),
    .if_spm_addr(if_pc),
    .if_spm_as_(!if_en),
    .if_spm_rw(`READ),
    .if_spm_wr_data(0),
    .if_spm_rd_data(insn),
    .mem_spm_addr(mem_spm_addr),
    .mem_spm_as_(mem_spm_as_),
    .mem_spm_rw(mem_spm_rw),
    .mem_spm_wr_data(mem_spm_wr_data),
    .mem_spm_rd_data(mem_spm_rd_data)
);

integer i;

always #5 clk = ~clk;

initial begin
    #0 begin
        clk = 0;
        reset = 0;
        cpu_en = 0;
    end
    #1 begin
        reset = 1;
    end
    #10 begin
        `spm_write(0,`WRITE,0,32'b1111_0000_0001_0110_1000_0000_1001_0011)
        `spm_write(0,`WRITE,4,32'b0000_0000_1111_0110_1010_0000_1001_0011)
        `spm_write(0,`WRITE,8,32'b0100_0000_1111_0110_1101_0000_1001_0011)
    end
    #5 begin
        cpu_en = 1;
    end
    #10 begin
        br_taken = 0;
        br_addr = 0;
    end
    #40 begin
        br_taken = 1;
        br_addr = 4;
    end
    #10 begin
        br_taken = 0;
        br_addr = 0;
    end
    #50
    $finish;
end

initial begin
    $dumpfile("wave_if_stage.vcd");
    $dumpvars(0,test_if_stage);
end

endmodule