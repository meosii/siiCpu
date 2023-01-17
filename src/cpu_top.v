`include "define.v"
`include "if_stage.v"
`include "decoder.v"
`include "alu.v"
`include "gpr.v"
`include "mem_ctrl.v"
`include "spm.v"

module cpu_top (
    input wire cpu_en,
    input wire clk,
    input wire reset,
    //spm
    input wire [29:0] test_spm_addr,
    input wire test_spm_as_,
    input wire test_spm_rw,
    input wire [31:0] test_spm_wr_data,
    output wire [31:0] test_spm_rd_data
);

wire [`DATA_WIDTH_GPR - 1:0] gpr_wr_data;
wire [`DATA_WIDTH_GPR - 1:0] spm_to_gpr_wr_data;
wire mem_spm_as_;
wire [`WORD_ADDR_BUS] br_addr;
wire [`DATA_WIDTH_INSN - 1:0] insn;
wire [`WORD_ADDR_BUS] if_pc;
wire [`DATA_WIDTH_INSN - 1:0] if_insn;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] gpr_rd_addr_0;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] gpr_rd_addr_1;
wire [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_0;
wire [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_1;
wire [`DATA_WIDTH_ALU_OP - 1:0] alu_op;
wire [`DATA_WIDTH_GPR - 1:0] alu_in_0;
wire [`DATA_WIDTH_GPR - 1:0] alu_in_1;
wire [`DATA_WIDTH_GPR - 1:0] alu_out;
wire [$clog2(`DATA_HIGH_GPR) - 1:0] dst_addr;
wire [`DATA_WIDTH_MEM_OP - 1:0] mem_op;
wire [`DATA_WIDTH_GPR - 1:0] mem_wr_data;
wire [`DATA_WIDTH_CTRL_OP - 1:0] ctrl_op;
wire [`DATA_WIDTH_ISA_EXP - 1:0] exp_code;
wire [`DATA_WIDTH_MEM_OP - 1:0] ex_mem_op;
wire [`DATA_WIDTH_GPR - 1:0] ex_mem_wr_data;
wire [`DATA_WIDTH_GPR - 1:0] wr_data;
wire [`WORD_ADDR_BUS] addr;
wire [`DATA_WIDTH_GPR - 1:0] rd_data;
wire mem_spm_rw;
wire [29:0] mem_spm_addr;
wire [31:0] mem_spm_wr_data;
wire [31:0] mem_spm_rd_data;
wire [`DATA_WIDTH_GPR - 1:0] to_spm_wr_data;

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
    .br_flag(br_flag),
    .mem_op(mem_op),
    .mem_wr_data(mem_wr_data), //to mem
    .ctrl_op(ctrl_op),
    .exp_code(exp_code)
);

gpr u_gpr(
    .clk(clk),
    .reset(reset),
    .we_(gpr_we_),
    .wr_addr(dst_addr),
    .wr_data(gpr_wr_data),
    .rd_addr_0(gpr_rd_addr_0),
    .rd_addr_1(gpr_rd_addr_1),
    .rd_data_0(gpr_rd_data_0),
    .rd_data_1(gpr_rd_data_1)
);

assign gpr_wr_data = (if_insn[`DATA_WIDTH_OPCODE - 1:0] == 7'b0000011)? spm_to_gpr_wr_data:alu_out;

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
    .rd_data(mem_spm_rd_data), //mem to gpr (rd_data -> out)
    .addr(addr), //from alu_out
    .as_(as_),
    .rw(rw),
    .wr_data(to_spm_wr_data),
    .out(spm_to_gpr_wr_data),
    .miss_align(miss_align)
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

assign mem_spm_addr = (cpu_en)? addr:test_spm_addr;
assign mem_spm_as_ = (cpu_en)? (!(!as_ && !miss_align)):test_spm_as_;
assign mem_spm_rw = (cpu_en)? rw:test_spm_rw;
assign mem_spm_wr_data = (cpu_en)? to_spm_wr_data:test_spm_wr_data;
assign test_spm_rd_data = (cpu_en)? 0:mem_spm_rd_data;

endmodule