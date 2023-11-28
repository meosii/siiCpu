`ifndef SIICPU_DEFINE
`define SIICPU_DEFINE

`define WORD_WIDTH          32
`define PC_WIDTH            32
`define DATA_HIGH_GPR       32
`define GPR_ADDR_WIDTH      5

`define DATA_WIDTH_ALU_OP   5
`define DATA_WIDTH_MEM_OP   4
`define DATA_WIDTH_CTRL_OP  2
`ifndef SIICPU_DEFINE
`define SIICPU_DEFINE

`define WORD_WIDTH          32
`define PC_WIDTH            32
`define DATA_HIGH_GPR       32
`define GPR_ADDR_WIDTH      5

`define DATA_WIDTH_ALU_OP   5
`define DATA_WIDTH_MEM_OP   4
`define DATA_WIDTH_CTRL_OP  2
`define DATA_WIDTH_OFFSET   2
`define DATA_WIDTH_ISA_EXP  5

// In memory, each address stores 8 bits(1 byte),
// While, in a 32-bit cpu, each instruction has 32 bits(4 bytes)
`define BYTE_OFFSET_LOC     1 : 0 // the low 2 bits as a byte shift
`define BYTE_OFFSET_WORD    2'b00 // to judge "miss_align"

`define GPR_READ            1'b1
`define GPR_WRITE           1'b0
`define DIS_GPR_WRITE       1'b1
`define DISABLE             1'b0
`define ENABLE              1'b1

//define by "RISC_V"
`define OP_IMM              7'b0010011
`define OP_LUI              7'b0110111
`define OP_AUIPC            7'b0010111
`define OP                  7'b0110011
`define OP_JAL              7'b1101111
`define OP_JALR             7'b1100111
`define OP_BRANCH           7'b1100011
`define OP_LOAD             7'b0000011
`define OP_STORE            7'b0100011
`define OP_SYSTEM           7'b1110011

`define FUNCT3_ADDI         3'b000
`define FUNCT3_SLTI         3'b010
`define FUNCT3_SLTIU        3'b011
`define FUNCT3_ANDI         3'b111
`define FUNCT3_ORI          3'b110
`define FUNCT3_XORI         3'b100
`define FUNCT3_SLLI         3'b001
`define FUNCT3_SRLI_SRAI    3'b101

`define FUNCT3_ADD          3'b000
`define FUNCT3_SLT          3'b010
`define FUNCT3_SLTU         3'b011
`define FUNCT3_AND          3'b111
`define FUNCT3_OR           3'b110
`define FUNCT3_XOR          3'b100
`define FUNCT3_SLL          3'b001
`define FUNCT3_SRL          3'b101
`define FUNCT3_SUB          3'b000
`define FUNCT3_SRA          3'b101

`define FUNCT3_BEQ          3'b000
`define FUNCT3_BNE          3'b001
`define FUNCT3_BLT          3'b100
`define FUNCT3_BLTU         3'b110
`define FUNCT3_BGE          3'b101
`define FUNCT3_BGEU         3'b111

`define FUNCT3_LW           3'b010
`define FUNCT3_LH           3'b001
`define FUNCT3_LHU          3'b101
`define FUNCT3_LB           3'b000
`define FUNCT3_LBU          3'b100

`define FUNCT3_SW           3'b010
`define FUNCT3_SH           3'b001
`define FUNCT3_SB           3'b000

`define FUNCT3_CSRRW        3'b001
`define FUNCT3_CSRRS        3'b010
`define FUNCT3_CSRRC        3'b011
`define FUNCT3_CSRRWI       3'b101
`define FUNCT3_CSRRSI       3'b110
`define FUNCT3_CSRRCI       3'b111

`define FUNCT3_ECALL_EBREAK 3'b000

`define EBREAK_INSN         32'b000000000001_00000_000_00000_1110011
`define ECALL_INSN          32'b000000000000_00000_000_00000_1110011
`define MRET_INSN           32'b0011000_00010_00000_000_00000_1110011

//define by myself
`define ALU_OP_NOP          5'd0
`define ALU_OP_ADDI         5'd1
`define ALU_OP_SLTI         5'd2
`define ALU_OP_SLTIU        5'd3
`define ALU_OP_ANDI         5'd4
`define ALU_OP_ORI          5'd5
`define ALU_OP_XORI         5'd6
`define ALU_OP_SLLI         5'd7
`define ALU_OP_SRLI         5'd8
`define ALU_OP_SRAI         5'd9
`define ALU_OP_LUI          5'd10
`define ALU_OP_AUIPC        5'd11
`define ALU_OP_ADD          5'd12
`define ALU_OP_SLT          5'd13
`define ALU_OP_SLTU         5'd14
`define ALU_OP_AND          5'd15
`define ALU_OP_OR           5'd16
`define ALU_OP_XOR          5'd17
`define ALU_OP_SLL          5'd18
`define ALU_OP_SRL          5'd19
`define ALU_OP_SUB          5'd20
`define ALU_OP_SRA          5'd21

`define MEM_OP_NOP          4'd0
`define MEM_OP_LOAD_LW      4'd1
`define MEM_OP_LOAD_LH      4'd2
`define MEM_OP_LOAD_LHU     4'd3
`define MEM_OP_LOAD_LB      4'd4
`define MEM_OP_LOAD_LBU     4'd5
`define MEM_OP_SW           4'd6
`define MEM_OP_SH           4'd7
`define MEM_OP_SB           4'd8

`define ISA_EXP_NO_EXP              5'd0 // No exceptions
`define ISA_EXP_PC_MISALIGNED       5'd1 // pc addr is not aligned
`define ISA_EXP_UNDEF_INSN          5'd2 // Undefined instructions
`define ISA_EXP_LOAD_MISALIGNED     5'd4 // Addresses are not aligned
`define ISA_EXP_STORE_MISALIGNED    5'd6 // Addresses are not aligned
`define ISA_EXP_AHB_ERROR_STORE     5'd7 // hresp = error
`define ISA_EXP_AHB_ERROR_LOAD      5'd5 // hresp = error
`define ISA_EXP_ALU_OVERFLOW        5'd16 // alu overflow

// Decoding of different instruction types
`define INSN_MSB            31
//The meaning of the corresponding bit
`define ALL_TYPE_OPCODE     6 : 0
//data width
`define ALL_TYPE_DATA_WIDTH_RS1     5
`define ALL_TYPE_DATA_WIDTH_RS2     5
`define ALL_TYPE_DATA_WIDTH_RD      5
`define ALL_TYPE_DATA_WIDTH_FUNCT3  3
`define ALL_TYPE_DATA_WIDTH_FUNCT7  7

// R-type
//The meaning of the corresponding bit
`define R_TYPE_FUNCT7   31 : 25
`define R_TYPE_RS2      24 : 20 
`define R_TYPE_RS1      19 : 15
`define R_TYPE_FUNCT3   14 : 12
`define R_TYPE_RD       11 : 7

// I-type
//The meaning of the corresponding bit
`define I_TYPE_IMM              31 : 20
`define I_TYPE_RS1              19 : 15
`define I_TYPE_FUNCT3           14 : 12
`define I_TYPE_RD               11 : 7
`define I_TYPE_IMM_11_5         31 : 25 // imm[11 : 5]
//data width
`define I_TYPE_DATA_WIDTH_IMM   12 // imm data width is 12

// S-type
//The meaning of the corresponding bit
`define S_TYPE_IMM_11           31
`define S_TYPE_IMM_11_5         31 : 25
`define S_TYPE_RS2              24 : 20 
`define S_TYPE_RS1              19 : 15
`define S_TYPE_FUNCT3           14 : 12
`define S_TYPE_IMM_4_0          11 : 7
//data width
`define S_TYPE_DATA_WIDTH_IMM_11_5  7
`define S_TYPE_DATA_WIDTH_IMM_4_0   5

// U-type
//The meaning of the corresponding bit
`define U_TYPE_IMM              31 : 12
`define U_TYPE_RD               11 : 7
//data width
`define U_TYPE_DATA_WIDTH_IMM   20 // imm data width is 20

// B-type
//The meaning of the corresponding bit
`define B_TYPE_IMM_12       31 // imm[12]
`define B_TYPE_IMM_10_5     30 : 25 // imm[10 : 5]
`define B_TYPE_RS2          24 : 20
`define B_TYPE_RS1          19 : 15
`define B_TYPE_FUNCT3       14 : 12
`define B_TYPE_IMM_4_1      11 : 8 // imm[4 : 1]
`define B_TYPE_IMM_11       7 // imm[11]
//data width
`define B_TYPE_DATA_WIDTH_IMM_12        1 // imm[12] data width is 1
`define B_TYPE_DATA_WIDTH_IMM_10_5      6 // imm[10 : 5] data width is 6
`define B_TYPE_DATA_WIDTH_IMM_4_1       4
`define B_TYPE_DATA_WIDTH_IMM_11        1

// J-type
//The meaning of the corresponding bit
`define J_TYPE_IMM_20           31 // imm[20]
`define J_TYPE_IMM_10_1         30 : 21 // imm[10 : 1]
`define J_TYPE_IMM_11           20 // imm[11]
`define J_TYPE_IMM_19_12        19 : 12 // imm[19 : 12]
`define J_TYPE_RD               11 : 7 // imm[11 : 7]
//data width
`define J_TYPE_DATA_WIDTH_OFFSET    20 // imm data width

//csr addr
`define CSR_ADDR_WIDTH      12
//machine information registers
`define CSR_ADDR_MVENDORID  12'hf11
`define CSR_ADDR_MARCHID    12'hf12
`define CSR_ADDR_MIMPID     12'hf13
`define CSR_ADDR_MHARTID    12'hf14
//machine trap setup
`define CSR_ADDR_MSTATUS    12'h300
`define CSR_ADDR_MISA       12'h301
`define CSR_ADDR_MEDELEG    12'h302
`define CSR_ADDR_MIDELEG    12'h302
`define CSR_ADDR_MIE        12'h304
`define CSR_ADDR_MTVEC      12'h305
`define CSR_ADDR_MCOUNTEREN 12'h306
//machine trap handling
`define CSR_ADDR_MSCRATCH   12'h340
`define CSR_ADDR_MEPC       12'h341
`define CSR_ADDR_MCAUSE     12'h342
`define CSR_ADDR_MTVAL      12'h343
`define CSR_ADDR_MIP        12'h344
//supervisor trap setup
`define CSR_ADDR_SSTATUS    12'h100
`define CSR_ADDR_SEDELEG    12'h102
`define CSR_ADDR_SIDELEG    12'h103
`define CSR_ADDR_SIE        12'h104
`define CSR_ADDR_STVEC      12'h105
`define CSR_ADDR_SCOUNTEREN 12'h106
//supervisor trap handling
`define CSR_ADDR_SSCRATCH   12'h140
`define CSR_ADDR_SEPC       12'h141
`define CSR_ADDR_SCAUSE     12'h142
`define CSR_ADDR_STVAL      12'h143
`define CSR_ADDR_SIP        12'h144

// csr location and its text
// mtvec
`define CSR_LOCA_MTVEC_BASE     31:2
`define CSR_LOCA_MTVEC_MODE     1:0
`define MTVEC_MODE_DIRECT       2'b0
`define MTVEC_MODE_VECTORED     2'b1
// mstatus
`define CSR_LOCA_MSTATUS_MPP    12:11
`define CSR_LOCA_MSTATUS_MPIE   7
`define CSR_LOCA_MSTATUS_MIE    3
`define MSTATUS_MPP_MACHINE     2'b00
`define MSTATUS_MPIE_ON         1'b1
`define MSTATUS_MPIE_OFF        1'b0
`define MSTATUS_MIE_ON          1'b1
`define MSTATUS_MIE_OFF         1'b0
//mip
`define CSR_LOCA_MIP_MEIP       11
`define CSR_LOCA_MIP_MTIP       7
`define CSR_LOCA_MIP_MSIP       3
`define MIP_MEIP_ON             1'b1
`define MIP_MEIP_OFF            1'b0
`define MIP_MTIP_ON             1'b1
`define MIP_MTIP_OFF            1'b0
`define MIP_MSIP_ON             1'b1
`define MIP_MSIP_OFF            1'b0
//mie
`define CSR_LOCA_MIE_MEIE       11  // external interrupts
`define CSR_LOCA_MIE_MTIE       7   // timer interrupt-enable bit
`define CSR_LOCA_MIE_MSIE       3
`define MIE_MEIE_ON             1'b1
`define MIE_MEIE_OFF            1'b0
`define MIE_MTIE_ON             1'b1
`define MIE_MTIE_OFF            1'b0
`define MIE_MSIE_ON             1'b1
`define MIE_MSIE_OFF            1'b0
// mcause
`define MCAUSE_INTERRUPT                1'b1
`define MCAUSE_EXCEPTION                1'b0
`define MCAUSE_USER_SOFTWARE_INT        31'd0
`define MCAUSE_SUPERVISOR_SOFTWARE_INT  31'd1
`define MCAUSE_MACHINE_SOFTWARE_INT     31'd3
`define MCAUSE_USER_TIMER_INT           31'd4
`define MCAUSE_SUPERVISOR_TIMER_INT     31'd5
`define MCAUSE_MACHINE_TIMER_INT        31'd7
`define MCAUSE_USER_EXTERNAL_INT        31'd8
`define MCAUSE_SUPERVISOR_EXTERNAL_INT  31'd9
`define MCAUSE_MACHINE_EXTERNAL_INT     31'd11
`define MCAUSE_INSTRUCTION_ADDRESS_MISALIGNED   31'd0
`define MCAUSE_INSTRUCTION_ACCESS_FAULT         31'd1
`define MCAUSE_ILLEGAL_INSTRUCTION              31'd2
`define MCAUSE_BREAKPOINT                       31'd3
`define MCAUSE_LOAD_ADDRESS_MISALIGNED          31'd4
`define MCAUSE_LOAD_ACCESS_FAULT                31'd5
`define MCAUSE_STORE_ADDRESS_MISALIGNED         31'd6
`define MCAUSE_STORE_ACCESS_FAULT               31'd7
`define MCAUSE_ENVIRONMENT_CALL_FROM_U_MODE     31'd8
`define MCAUSE_ENVIRONMENT_CALL_FROM_S_MODE     31'd9
`define MCAUSE_ENVIRONMENT_CALL_FROM_M_MODE     31'd11
`define MCAUSE_INSTRUCTION_PAGE_FAULT           31'd12
`define MCAUSE_LOAD_PAGE_FAULT                  31'd13
`define MCAUSE_STORE_PAGE_FAULT                 31'd15
`define MCAUSE_ALU_OVERFLOW                     31'd16 // defined by myself

// AHB define
//HTRANS[1:0]
`define HTRANS_IDLE 2'b00
`define HTRANS_BUSY 2'b01
`define HTRANS_NONSEQ 2'b10
`define HTRANS_SEQ 2'b11
//HBURST[2:0]
`define HBRUST_SINGLE 3'b000
`define HBRUST_INCR 3'b001
`define HBRUST_WRAP4 3'b010
`define HBRUST_INCR4 3'b011
`define HBRUST_WRAP8 3'b100
`define HBRUST_INCR8 3'b101
`define HBRUST_WRAP16 3'b110
`define HBRUST_INCR16 3'b111
//HRESP[1:0]
`define HRESP_OKAY 2'b00
`define HRESP_ERROR 2'b01
`define HRESP_RETRY 2'b10
`define HRESP_SPLIT 2'b11
//HSIZE[2:0]
`define HSIZE_8    3'b000
`define HSIZE_16   3'b001
`define HSIZE_32   3'b010
`define HSIZE_64   3'b011
`define HSIZE_128  3'b100
`define HSIZE_256  3'b101
`define HSIZE_512  3'b110
`define HSIZE_1024 3'b111
//HWRITE
`define HWRITE_WRITE    1'b1
`define HWRITE_READ     1'b0

// config by myself
`define MTVEC_RESET_BASE        30'h1f00    //'d7936; itcm_addr = pc[:2] = BASE[XLEN-1:2]
`define MTVEC_RESET_MODE        2'b0        //DIRECT: All exceptions set pc to BASE

// bus addr

// spm: 0x9000_0000 ~ 0x9000_3fff
`define SPM_ADDR_HIGH_LOCA      31:14
`define SPM_ADDR_LOCA           13:2
`define SPM_ADDR_HIGH           18'b1001_0000_0000_0000_00

// clint: 0x0200_0000 ~ 0x0200_ffff
`define BUS_ADDR_HIGH_CLINT_WIDTH       16
`define BUS_ADDR_HIGH_CLINT             16'h0200
`define BUS_ADDR_CLINT_MSIP             32'h0200_0000
`define BUS_ADDR_CLINT_MTIMECMP_LOW     32'h0200_4000
`define BUS_ADDR_CLINT_MTIMECMP_HIGH    32'h0200_4004
`define BUS_ADDR_CLINT_MTIME_LOW        32'h0200_bff8
`define BUS_ADDR_CLINT_MTIME_HIGH       32'h0200_bfff

// plic: 0x0c00_0000 ~ 0x0cff_ffff
`define BUS_ADDR_HIGH_PLIC_WIDTH    8
`define BUS_ADDR_HIGH_PLIC          8'h0c

// uart: 0x1001_3000 ~ 0x1001_3fff
`define BUS_ADDR_HIGH_UART0_WIDTH   20
`define BUS_ADDR_HIGH_UART0         20'h1001_3
`define BUS_ADDR_UART_TRANSDATA     32'h1001_3000

// spi: 0x1001_4000 ~ 0x1001_4fff
`define BUS_ADDR_HIGH_SPI0_WIDTH    20
`define BUS_ADDR_HIGH_SPI0          20'h1001_4

// dtube: 0x4000_0000 ~0x4000_0fff
`define BUS_ADDR_HIGH_DTUBE_WIDTH   20
`define BUS_ADDR_HIGH_DTUBE         20'h4000_0
`define BUS_ADDR_DTUBE_HEX0NUM      32'h4000_0000
`define BUS_ADDR_DTUBE_HEX1NUM      32'h4000_0004
`define BUS_ADDR_DTUBE_HEX2NUM      32'h4000_0008
`define BUS_ADDR_DTUBE_HEX3NUM      32'h4000_000c
`define BUS_ADDR_DTUBE_HEX4NUM      32'h4000_0010
`define BUS_ADDR_DTUBE_HEX5NUM      32'h4000_0014

`endif