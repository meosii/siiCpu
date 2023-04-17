`ifndef PIPELINE_CPU_TOP
`define PIPELINE_CPU_TOP

`include "unit/define.v"
`include "unit/id_reg.v"
`include "unit/if_reg.v"
`include "unit/ex_reg.v"
`include "unit/mem_reg.v"
`include "unit/decoder.v"
`include "unit/alu.v"
`include "unit/gpr.v"
`include "unit/mem_ctrl.v"
`include "unit/spm.v"

module pipeline_cpu_top (
    input wire                  cpu_en,
    input wire                  clk,
    input wire                  reset,
    //spm
    input wire [`WORD_ADDR_BUS]         test_spm_addr,
    input wire                          test_spm_as_,
    input wire                          test_spm_rw,
    input wire [`WORD_WIDTH - 1 : 0]    test_spm_wr_data,
    output wire [`WORD_WIDTH - 1 : 0]   test_spm_rd_data
);

//if
wire [`WORD_WIDTH - 1 : 0]  insn;
wire [`WORD_ADDR_BUS]       if_pc;
wire [`WORD_WIDTH - 1 : 0]  if_insn;
wire [`WORD_ADDR_BUS]       br_addr;
// id
wire [`DATA_WIDTH_ALU_OP - 1 : 0]       id_alu_op;
wire [`WORD_WIDTH - 1 : 0]              id_alu_in_0;
wire [`WORD_WIDTH - 1 : 0]              id_alu_in_1;
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       id_mem_op;
wire [`WORD_WIDTH - 1 : 0]              id_gpr_data;
wire [`WORD_WIDTH - 1 : 0]              id_insn;
wire [$clog2(`DATA_HIGH_GPR) - 1 : 0]   id_dst_addr;
//gpr
wire [$clog2(`DATA_HIGH_GPR) - 1 : 0]   gpr_rd_addr_0;
wire [$clog2(`DATA_HIGH_GPR) - 1 : 0]   gpr_rd_addr_1;
wire [`WORD_WIDTH - 1 : 0]              gpr_rd_data_0;
wire [`WORD_WIDTH - 1 : 0]              gpr_rd_data_1;
wire [$clog2(`DATA_HIGH_GPR) - 1 : 0]   dst_addr;
wire [`WORD_WIDTH - 1 : 0]              gpr_wr_data;
wire [`WORD_WIDTH - 1 : 0]              mem_data_to_gpr;
// alu
wire [`DATA_WIDTH_ALU_OP - 1 : 0]       alu_op;
wire [`WORD_WIDTH - 1 : 0]              alu_in_0;
wire [`WORD_WIDTH - 1 : 0]              alu_in_1;
wire [`WORD_WIDTH - 1 : 0]              alu_out;
// exe
wire [`WORD_WIDTH - 1 : 0]              ex_insn;
wire [$clog2(`DATA_HIGH_GPR) - 1 : 0]   ex_dst_addr;
wire [`WORD_ADDR_BUS]                   ex_pc;
wire [`WORD_WIDTH - 1 : 0]              ex_alu_out;
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       ex_mem_op;
wire [`WORD_WIDTH - 1 : 0]              ex_gpr_data;
// mem_ctrl
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       mem_op;
wire [`WORD_WIDTH - 1 : 0]              gpr_data;
wire [`WORD_ADDR_BUS]                   addr_to_mem;
wire [`WORD_WIDTH - 1 : 0]              wr_data; // gpr to mem
wire [`WORD_WIDTH - 1 : 0]              to_spm_wr_data; // gpr to mem
wire [`WORD_WIDTH - 1 : 0]              mem_data; // mem_to gpr
// mem
wire [`WORD_ADDR_BUS]                   mem_pc;
wire [`WORD_WIDTH - 1 : 0]              mem_insn;
wire [`WORD_WIDTH - 1 : 0]              mem_alu_out;
wire [$clog2(`DATA_HIGH_GPR) - 1 : 0]   mem_dst_addr;
wire [`WORD_WIDTH - 1 : 0]              mem_mem_data_to_gpr;
// spm
wire                                    mem_spm_as_;
wire                                    mem_spm_rw;
wire [29 : 0]                           mem_spm_addr;
wire [31 : 0]                           mem_spm_wr_data;
wire [31 : 0]                           mem_spm_rd_data;
// ctrl
wire [`DATA_WIDTH_CTRL_OP - 1 : 0]      ctrl_op;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      exp_code;

// write instructions into spm
assign mem_spm_addr     = (cpu_en) ? addr_to_mem                        : test_spm_addr;
assign mem_spm_as_      = (cpu_en) ? (!(!mem_op_as_ && !miss_align))    : test_spm_as_;
assign mem_spm_rw       = (cpu_en) ? rw                                 : test_spm_rw;
assign mem_spm_wr_data  = (cpu_en) ? to_spm_wr_data                     : test_spm_wr_data;
assign test_spm_rd_data = (cpu_en) ? 0                                  : mem_spm_rd_data;

if_reg u_if_reg(
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

decoder u_decoder(
    .if_insn(if_insn),
    .if_pc(if_pc),
    .if_en(if_en),
    .gpr_rd_data_0(gpr_rd_data_0),
    .gpr_rd_data_1(gpr_rd_data_1),
    .gpr_rd_addr_0(gpr_rd_addr_0),
    .gpr_rd_addr_1(gpr_rd_addr_1),
    .dst_addr(dst_addr),
    .gpr_we_(gpr_we_),
    .alu_op(alu_op),
    .alu_in_0(alu_in_0),
    .alu_in_1(alu_in_1),
    .br_addr(br_addr),
    .br_taken(br_taken),
    .mem_op(mem_op),
    .gpr_data(gpr_data), //to mem
    .ctrl_op(ctrl_op),
    .exp_code(exp_code),
    .id_en(id_en),
    .id_insn(id_insn),
    .id_gpr_we_(id_gpr_we_),
    .id_dst_addr(id_dst_addr),
    .alu_out(alu_out),
    .ex_en(ex_en),
    .ex_insn(ex_insn),
    .ex_gpr_we_(ex_gpr_we_),
    .ex_dst_addr(ex_dst_addr),
    .mem_data_to_gpr(mem_data_to_gpr),
    .ex_alu_out(ex_alu_out)
);

id_reg u_id_reg(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .id_pc(id_pc),
    .if_insn(if_insn),
    .id_insn(id_insn),
    .if_en(if_en),
    .id_en(id_en),
    .gpr_we_(gpr_we_),
    .dst_addr(dst_addr), 
    .id_gpr_we_(id_gpr_we_),
    .id_dst_addr(id_dst_addr),
    .alu_op(alu_op),
    .alu_in_0(alu_in_0),
    .alu_in_1(alu_in_1),
    .id_alu_op(id_alu_op),
    .id_alu_in_0(id_alu_in_0),
    .id_alu_in_1(id_alu_in_1),
    .mem_op(mem_op),
    .gpr_data(gpr_data),
    .id_mem_op(id_mem_op),
    .id_gpr_data(id_gpr_data)
);

gpr u_gpr(
    .clk(clk),
    .reset(reset),
    .we_(mem_gpr_we_),
    .wr_addr(mem_dst_addr),
    .wr_data(gpr_wr_data),
    .rd_addr_0(gpr_rd_addr_0),
    .rd_addr_1(gpr_rd_addr_1),
    .rd_data_0(gpr_rd_data_0),
    .rd_data_1(gpr_rd_data_1)
);

assign gpr_wr_data = (mem_insn[`ALL_TYPE_OPCODE] == `OP_LOAD)? mem_mem_data_to_gpr : mem_alu_out;

alu u_alu(
    .alu_op(id_alu_op),
    .alu_in_0(id_alu_in_0),
    .alu_in_1(id_alu_in_1),
    .alu_out(alu_out)
);

ex_reg u_ex_reg(
    .clk(clk),
    .reset(reset),
    .id_pc(id_pc),
    .ex_pc(ex_pc),
    .id_insn(id_insn),
    .ex_insn(ex_insn),
    .id_en(id_en),
    .ex_en(ex_en),
    .alu_out(alu_out),
    .ex_alu_out(ex_alu_out),
    .id_gpr_we_(id_gpr_we_),
    .id_dst_addr(id_dst_addr),
    .ex_gpr_we_(ex_gpr_we_),
    .ex_dst_addr(ex_dst_addr),
    .id_mem_op(id_mem_op),
    .id_gpr_data(id_gpr_data),
    .ex_mem_op(ex_mem_op),
    .ex_gpr_data(ex_gpr_data)
);

mem_ctrl u_mem_ctrl(
    .mem_op(ex_mem_op),
    .alu_out(ex_alu_out),
    .addr_to_mem(addr_to_mem), //from alu_out
    .gpr_data(ex_gpr_data),
    .mem_op_as_(mem_op_as_),
    .rw(rw),
    .wr_data(to_spm_wr_data),
    .mem_data(mem_spm_rd_data), //mem to gpr (mem_data -> mem_data_to_gpr)
    .mem_data_to_gpr(mem_data_to_gpr),
    .miss_align(miss_align)
);

mem_reg u_mem_reg (
    .clk(clk),
    .reset(reset),
    .ex_pc(ex_pc),
    .mem_pc(mem_pc),
    .ex_insn(ex_insn),
    .mem_insn(mem_insn),
    .ex_en(ex_en),
    .mem_en(mem_en),
    .ex_alu_out(ex_alu_out),
    .mem_alu_out(mem_alu_out),
    .ex_gpr_we_(ex_gpr_we_),
    .ex_dst_addr(ex_dst_addr),
    .mem_gpr_we_(mem_gpr_we_),
    .mem_dst_addr(mem_dst_addr),
    .mem_data_to_gpr(mem_data_to_gpr),
    .mem_mem_data_to_gpr(mem_mem_data_to_gpr)
);

spm u_spm(
    .clk(clk),
    .rst_(reset),
    .if_spm_addr(if_pc),
    .if_spm_as_(!(reset && cpu_en)),
    .if_spm_rw(`READ),
    .if_spm_wr_data(0),
    .if_spm_rd_data(insn),
    .mem_spm_addr(mem_spm_addr),
    .mem_spm_as_(mem_spm_as_),
    .mem_spm_rw(mem_spm_rw),
    .mem_spm_wr_data(mem_spm_wr_data),
    .mem_spm_rd_data(mem_spm_rd_data)
);

endmodule
`endif