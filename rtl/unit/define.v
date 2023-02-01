`ifndef siicpu_define
`define siicpu_define

`define DATA_WIDTH_GPR 32
`define DATA_HIGH_GPR 32
`define DATA_WIDTH_INSN 32
`define DATA_WIDTH_ALU_OP 5
`define DATA_WIDTH_MEM_OP 3
`define DATA_WIDTH_CTRL_OP 2
`define DATA_WIDTH_OPCODE 7
`define DATA_WIDTH_OFFSET 2
`define DATA_WIDTH_ISA_EXP 3
`define WORD_WIDTH 32

`define WORD_ADDR_BUS 29:0
`define WORD_ADDR_WIDTH 30
// In memory, each address stores 8 bits(1 byte),
// While, in a 32-bit cpu, each instruction has 32 bits(4 bytes),
`define WORD_ADDR_LOC 31:2 // So, the cpu internally addresses the high 30 bits as a word 
`define BYTE_OFFSET_LOC 1:0 // and the low 2 bits as a byte shift
`define BYTE_OFFSET_WORD 2'b00 // to judge "miss_align"

//define by "RISC_V"
`define OP_IMM 7'b0010011
`define OP_LUI 7'b0110111
`define OP_AUIPC 7'b0010111
`define OP 7'b0110011
`define OP_JAL 7'b1101111
`define OP_JALR 7'b1100111
`define OP_BRANCH 7'b1100011
`define OP_LOAD 7'b0000011
`define OP_STORE 7'b0100011
//`define OP_MISC_MEM 
`define OP_SYSTEM 7'b1110011

`define FUNCT3_ADDI 3'b000
`define FUNCT3_SLTI 3'b010
`define FUNCT3_SLTIU 3'b011
`define FUNCT3_ANDI 3'b111
`define FUNCT3_ORI 3'b110
`define FUNCT3_XORI 3'b100
`define FUNCT3_SLLI 3'b001
`define FUNCT3_SRLI_SRAI 3'b101

`define FUNCT3_ADD 3'b000
`define FUNCT3_SLT 3'b010
`define FUNCT3_SLTU 3'b011
`define FUNCT3_AND 3'b111
`define FUNCT3_OR 3'b110
`define FUNCT3_XOR 3'b100
`define FUNCT3_SLL 3'b001
`define FUNCT3_SRL 3'b101
`define FUNCT3_SUB 3'b000
`define FUNCT3_SRA 3'b101

`define FUNCT3_BEQ 3'b000
`define FUNCT3_BNE 3'b001
`define FUNCT3_BLT 3'b100
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGE 3'b101
`define FUNCT3_BGEU 3'b111

`define FUNCT3_LW 3'b010
`define FUNCT3_LH 3'b001
`define FUNCT3_LHU 3'b101
`define FUNCT3_LB 3'b000
`define FUNCT3_LBU 3'b100

`define FUNCT3_SW 3'b010
`define FUNCT3_SH 3'b001
`define FUNCT3_SB 3'b000

//define by myself
`define ALU_OP_NOP 0
`define ALU_OP_ADDI 1
`define ALU_OP_SLTI 2
`define ALU_OP_SLTIU 3
`define ALU_OP_ANDI 4
`define ALU_OP_ORI 5
`define ALU_OP_XORI 6
`define ALU_OP_SLLI 7
`define ALU_OP_SRLI 8
`define ALU_OP_SRAI 9
`define ALU_OP_LUI 10
`define ALU_OP_AUIPC 11
`define ALU_OP_ADD 12
`define ALU_OP_SLT 13
`define ALU_OP_SLTU 14
`define ALU_OP_AND 15
`define ALU_OP_OR 16
`define ALU_OP_XOR 17
`define ALU_OP_SLL 18
`define ALU_OP_SRL 19
`define ALU_OP_SUB 20
`define ALU_OP_SRA 21
`define MEM_OP_NOP 0
`define MEM_OP_LOAD_LW 1
`define MEM_OP_LOAD_LH 2
`define MEM_OP_LOAD_LHU 3
`define MEM_OP_LOAD_LB 4
`define MEM_OP_LOAD_LBU 5
`define MEM_OP_STORE 6
`define CTRL_OP_NOP 0

`define READ 1'b1
`define WRITE 1'b0

`define ISA_EXP_NO_EXP 3'b000 // No exceptions
`define ISA_EXP_EXT_INT 3'b001 // External interrupt
`define ISA_EXP_UNDEF_INSN 3'b010 // Undefined instructions
`define ISA_EXP_OVERFLOW 3'b011 // Overfloe
`define ISA_EXP_MISS_ALIGN 3'b100 // Addresses are not aligned

`define spm_write(AS_,RW,ADDR,WDATA)\
        mem_spm_as_ = AS_;\
        mem_spm_rw = RW;\
        @(posedge clk);\
        #1 begin\
            mem_spm_addr = ADDR;\
            mem_spm_wr_data = WDATA;\
        end

`define test_spm_write_OP_IMM(ADDR,imm,rs1,funct3,rd)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {imm,rs1,funct3,rd,`OP_IMM};\
        end

`define test_spm_write_OP_LUI(ADDR,imm,rd)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {imm,rd,`OP_LUI};\
        end

`define test_spm_write_OP_AUIPC(ADDR,imm,rd)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {imm,rd,`OP_AUIPC};\
        end

`define test_spm_write_OP(ADDR,funct7,rs2,rs1,funct3,rd)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {funct7,rs2,rs1,funct3,rd,`OP};\
        end

`define test_spm_write_OP_JAL(ADDR,offset,rd)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {offset,rd,`OP_JAL};\
        end

`define test_spm_write_OP_JALR(ADDR,offset,rs1_base,rd)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {offset,rs1_base,3'b000,rd,`OP_JALR};\
        end

`define test_spm_write_OP_BRANCH(ADDR,offset1,rs2,rs1,funct3,offset2)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {offset1,rs2,rs1,funct3,offset2,`OP_BRANCH};\
        end

`define test_spm_write_OP_LOAD(ADDR,imm,rs1,funct3,rd)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {imm,rs1,funct3,rd,`OP_LOAD};\
        end

`define test_spm_write_OP_STORE(ADDR,offset1,rs2,rs1,funct3,offset2)\
        test_spm_as_ = 0;\
        test_spm_rw = `WRITE;\
        @(posedge clk);\
        #1 begin\
            test_spm_addr = ADDR;\
            test_spm_wr_data = {offset1,rs2,rs1,funct3,offset2,`OP_STORE};\
        end

`endif