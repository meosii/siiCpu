`include "unit/define.v"
`include "unit/decoder.v"
`include "unit/gpr.v"

module test_decoder ();
reg [`DATA_WIDTH_INSN - 1:0] if_insn;
reg [`WORD_ADDR_BUS] if_pc;
reg if_en;
wire [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_0;
wire [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_1;
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
wire [`DATA_WIDTH_GPR - 1:0] gpr_data;
wire [`DATA_WIDTH_CTRL_OP - 1:0] ctrl_op;
wire [`DATA_WIDTH_ISA_EXP - 1:0] exp_code;
//gpr
reg clk;
reg reset;
reg we_;
reg [4:0] wr_addr;
reg [31:0] wr_data;

decoder u_decoder(
.if_insn(if_insn),
.if_pc(if_pc),
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
.gpr_data(gpr_data),
.ctrl_op(ctrl_op),
.exp_code(exp_code)
);

gpr u_gpr(
    .clk(clk),
    .reset(reset),
    .we_(we_), //gpr_we_,简化不从内存写入数据
    .wr_addr(wr_addr), //dst_addr
    .wr_data(wr_data),
    .rd_addr_0(gpr_rd_addr_0),
    .rd_addr_1(gpr_rd_addr_1),
    .rd_data_0(gpr_rd_data_0),
    .rd_data_1(gpr_rd_data_1)
);

parameter TIMECLK = 10;
integer i;
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
        if_pc = 0;
        if_en = 1;
        if_insn = 32'b1111_0000_0001_0110_1000_0000_1001_0011;
        //imm[11:0]: 1111_0000_0001,rs1: 0110_1,funct3:000ADDI,rd:0000_1,opcode:001_0011 OP-IMM
        #1 begin
            $display("1. OP-IMM,ADDI");
            $display("dst_addr: %b",dst_addr);
            $display("alu_op: %b",alu_op);
            $display("alu_in_0: %b",alu_in_0);
            $display("alu_in_1: %b",alu_in_1);
        end
    end
    #1 begin
        if_pc = 0;
        if_en = 1;
        if_insn = 32'b0000_0000_1111_0110_1010_0000_1001_0011;
        //imm[11:0]: 0000_0000_1111,rs1: 0110_1,funct3:010SLTI,rd:0000_1,opcode:001_0011 OP-IMM
        #1 begin
            $display("2. OP-IMM,SLTI");
            $display("dst_addr: %b",dst_addr);
            $display("alu_op: %b",alu_op);
            $display("alu_in_0: %b",alu_in_0);
            $display("alu_in_1: %b",alu_in_1);
        end
    end
    #1 begin
        if_pc = 0;
        if_en = 1;
        if_insn = 32'b0100_0000_1111_0110_1101_0000_1001_0011;
        //imm[11:5]: 0100_000,imm[4:0]: 0_1111,rs1: 0110_1,funct3:101SRLI_SRAI,rd:0000_1,opcode:001_0011 OP-IMM
        #1 begin
            $display("3. OP-IMM,SRAI");
            $display("dst_addr: %b",dst_addr);
            $display("alu_op: %b",alu_op);
            $display("alu_in_0: %b",alu_in_0);
            $display("alu_in_1: %b",alu_in_1);
        end
    end
    #1 begin
        if_pc = 0;
        if_en = 1;
        if_insn = 32'b0000_0001_1111_0110_1000_0000_1011_0011;
        //funct7[31:25]: 0000_000,rb[24:20]: 1_1111,ra: 0110_1,
        //funct3:000ADD,rd:0000_1,opcode:011_0011 OP
        #1 begin
            $display("4. OP-IMM,ADD");
            $display("dst_addr: %b",dst_addr);
            $display("alu_op: %b",alu_op);
            $display("alu_in_0: %b",alu_in_0);
            $display("alu_in_1: %b",alu_in_1);
        end
    end
    #1 begin
        if_pc = 5;
        if_en = 1;
        if_insn = 32'b0000_0000_1010_0000_0000_0000_1110_1111;
        //imm[20]: 0,imm[10:1]: 000_0000_101,imm[11]: 0,
        //imm[19:12]:0000_0000,rd:0000_1,opcode:110_1111 OP_JAL
        #1 begin
            $display("5. OP-JAL");
            $display("br_addr: %d",br_addr);
            $display("br_taken: %b",br_taken);
            $display("br_flag: %b",br_flag);
            $display("dst_addr: %b",dst_addr);
        end
    end
    #1 begin
        if_pc = 5;
        if_en = 1;
        if_insn = 32'b0000_0000_1011_0111_0000_0000_1110_0111;
        //imm[11:0]: 0000_0000_1011,ra[19:15]: 0111_0,funt3[14:12]: 000,
        //rd[11:7]:0000_1,opcode:110_0111 OP_JALR
        #1 begin
            $display("6. OP-JALR");
            $display("gpr_rd_data_0: %b",gpr_rd_data_0);
            $display("br_addr: %d",br_addr);
            $display("br_taken: %b",br_taken);
            $display("br_flag: %b",br_flag);
            $display("dst_addr: %b",dst_addr);
        end
    end
    #1 begin
        if_pc = 5;
        if_en = 1;
        if_insn = 32'b0000_0111_1000_1100_0000_1111_0110_0011;
        //imm[12]: 0,imm[10:5]: 000_011,rs2: 1_1000,
        //rs1:1100_0,funct3: 000BEQ,imm[4:1]:1111,imm[11]: 0,opcode:110_0011 OP_BRANCH
        #1 begin
            $display("6. OP_BRANCH,BEQ");
            $display("gpr_rd_data_0: %b",gpr_rd_data_0);
            $display("gpr_rd_data_1: %b",gpr_rd_data_1);
            $display("br_addr: %d",br_addr);
            $display("br_taken: %b",br_taken);
            $display("br_flag: %b",br_flag);
        end
    end
    #1 begin
        if_pc = 5;
        if_en = 1;
        if_insn = 32'b0000_0011_1111_1100_0010_0000_1000_0011;
        //imm[11:0]: 0000_0011_1111,rs1: 1100_0,funct3: 010LW
        //rd: 00001,opcode:0000011 OP_LOAD
        #1 begin
            $display("7. OP_LOAD");
            $display("alu_op: %d",alu_op);
            $display("alu_in_0: %b",alu_in_0);
            $display("gpr_rd_addr_1: %b",gpr_rd_addr_1);
            $display("alu_in_1: %b",alu_in_1);
            $display("dst_addr: %b",dst_addr);
            $display("mem_op: %b",mem_op);
        end
    end
    #1 begin
        if_pc = 5;
        if_en = 1;
        if_insn = 32'b0000_0001_1111_0100_0010_0000_1010_0011;
        //imm[11:5]: 0000_000,rs2: 1_1111,rs1: 0100_0
        //funct3: 010 SW,imm[4:0]: 0000_1,opcode:010_0011 OP_STORE
        #1 begin
            $display("8. OP_STORE");
            $display("mem_op: %b",mem_op);
            $display("alu_op: %d",alu_op);
            $display("alu_in_0: %b",alu_in_0);
            $display("gpr_rd_addr_0: %b",gpr_rd_addr_0);
            $display("alu_in_1: %b",alu_in_1);
            $display("gpr_rd_addr_1: %b",gpr_rd_addr_1);
            $display("gpr_rd_data_1: %b",gpr_rd_data_1);
            $display("gpr_data: %b",gpr_data);
        end
    end
    #1
    $finish;
end

endmodule