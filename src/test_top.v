`include "define.v"
`include "decoder.v"
`include "gpr.v"
`include "alu.v"
`include "mem_ctrl.v"
`include "memory.v"

module test_top ();
//decoder
reg [`DATA_WIDTH_INSN - 1:0] if_insn;
reg [`WORD_ADDR_BUS] if_pc;
reg if_en;
reg [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_0;
reg [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_1;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] gpr_rd_addr_0;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] gpr_rd_addr_1;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] dst_addr;
wire gpr_we_;
wire [`DATA_WIDTH_ALU_OP - 1:0] alu_op;
wire [`DATA_WIDTH_GPR - 1:0] alu_in_0;
wire [`DATA_WIDTH_GPR - 1:0] alu_in_1;
wire [`WORD_ADDR_BUS] br_addr;
wire br_taken;
wire br_flag;
wire [`DATA_WIDTH_MEM_OP - 1:0] mem_op;
wire [`DATA_WIDTH_GPR - 1:0] mem_wr_data;
wire [`DATA_WIDTH_CTRL_OP - 1:0] ctrl_op;
wire [`DATA_WIDTH_ISA_EXP - 1:0] exp_code;

//gpr
reg clk;
reg reset;
//alu
wire [`DATA_WIDTH_GPR - 1:0] alu_out;
//mem_ctrl
wire [`WORD_ADDR_BUS] addr;
wire as_;
wire rw;
wire [`DATA_WIDTH_GPR - 1:0] to_mem_wr_data;
wire [`DATA_WIDTH_GPR - 1:0] rd_data;
wire [`DATA_WIDTH_GPR - 1:0] out;

gpr u_gpr(
    .clk(clk),
    .reset(reset),
    .we_(gpr_we_),
    .wr_addr(dst_addr),
    .wr_data(out),
    .rd_addr_0(gpr_rd_addr_0),
    .rd_addr_1(gpr_rd_addr_1),
    .rd_data_0(gpr_rd_data_0),
    .rd_data_1(gpr_rd_data_1)
);

alu u_alu(
    .alu_op(alu_op),
    .alu_in_0(alu_in_0),
    .alu_in_1(alu_in_1),
    .alu_out(alu_out)
);

mem_ctrl u_mem_ctrl(
    .ex_en(ex_en),
    .ex_mem_op(mem_op),
    .ex_mem_wr_data(mem_wr_data),
    .ex_out(alu_out),
    .rd_data(rd_data),
    .addr(addr),
    .as_(as_),
    .rw(rw),
    .wr_data(to_mem_wr_data),
    .out(out),
    .miss_align(miss_align)
);

memory u_memory(
    .clk(clk),
    .rst_(reset),
    .memory_addr(addr),
    .memory_as_(as_),
    .memory_rw(rw),
    .memory_wr_data(to_mem_wr_data),
    .memory_rd_data(rd_data)
);

initial begin
    #0 begin
        if_pc = 0;
        if_en = 1;
    end
end

endmodule