`include "top/cpu_top.v"
`include "unit/define.v"

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

        // OP_IMM
        // 执行 ADDI，将立即数写入 gpr，地址 0 - 10，写入 0 - 10
        `test_spm_write_OP_IMM(0,12'b0000_0000_0000,5'b11111,`FUNCT3_ADDI,5'b00000) // gpr[rd] = 0
        `test_spm_write_OP_IMM(4,12'b0000_0000_0001,5'b11111,`FUNCT3_ADDI,5'b00001) // gpr[rd] = 1
        `test_spm_write_OP_IMM(8,12'b0000_0000_0010,5'b11111,`FUNCT3_ADDI,5'b00010) // gpr[rd] = 2
        `test_spm_write_OP_IMM(12,12'b0000_0000_0011,5'b11111,`FUNCT3_ADDI,5'b00011) // gpr[rd] = 3
        `test_spm_write_OP_IMM(16,12'b0000_0000_0100,5'b11111,`FUNCT3_ADDI,5'b00100) // gpr[rd] = 4
        `test_spm_write_OP_IMM(20,12'b0000_0000_0101,5'b11111,`FUNCT3_ADDI,5'b00101) // gpr[rd] = 5
        `test_spm_write_OP_IMM(24,12'b0000_0000_0110,5'b11111,`FUNCT3_ADDI,5'b00110) // gpr[rd] = 6
        `test_spm_write_OP_IMM(28,12'b0000_0000_0111,5'b11111,`FUNCT3_ADDI,5'b00111) // gpr[rd] = 7
        `test_spm_write_OP_IMM(32,12'b0111_1111_1111,5'b00111,`FUNCT3_ADDI,5'b01000) // gpr[rd] = 2047 + 7 = 2054 
        `test_spm_write_OP_IMM(36,12'b0000_0000_1001,5'b11111,`FUNCT3_ADDI,5'b01001) // gpr[rd] = 9
        `test_spm_write_OP_IMM(40,12'b1111_1111_1100,5'b00001,`FUNCT3_ADDI,5'b01010) // gpr[rd] = -4 + 1 = -3
        //执行 SLTI，将 rs1 与立即数比较，若立即数大，输出 1
        `test_spm_write_OP_IMM(44,12'b1111_1111_1110,5'b01010,`FUNCT3_SLTI,5'b01011) // gpr[rd] = 1 (imm = -2 > gpr[5'b01010] = -3)
        //执行 ANDI，将 rs1 与立即数做按位与运算
        `test_spm_write_OP_IMM(48,12'b0000_0000_1111,5'b01001,`FUNCT3_ANDI,5'b01100) // gpr[rd] = 9
        //执行 ORI，将 rs1 与立即数做按位或运算
        `test_spm_write_OP_IMM(52,12'b0000_0000_0011,5'b01001,`FUNCT3_ORI,5'b01101) // gpr[rd] = 11
        //执行 XORI，将 rs1 与立即数做按位异或运算
        `test_spm_write_OP_IMM(56,12'b0000_0000_0011,5'b01001,`FUNCT3_XORI,5'b01110) // gpr[rd] = 10
        //执行 SLLI，将 rs1 左移 imm[0:4] 位
        `test_spm_write_OP_IMM(60,12'b0000_0000_0011,5'b01001,`FUNCT3_SLLI,5'b01111) // gpr[rd] = 72
        //执行 SRLI（if_insn[31:25] == 7'b0000000），将 rs1 右移 imm[0:4] 位（5'b00011），左添加0
        `test_spm_write_OP_IMM(64,12'b0000000_00011,5'b01001,`FUNCT3_SRLI_SRAI,5'b10000) // gpr[rd] = 1
        //执行 SRAI（if_insn[31:25] == 7'b0100000），将 rs1 右移 imm[0:4] 位（5'b00011），左添加符号位
        `test_spm_write_OP_IMM(68,12'b0100000_00011,5'b01000,`FUNCT3_SRLI_SRAI,5'b10001) // gpr[rd] = 32'b000_000····100000000 = 256
        
        //OP_LUI
        //执行 LUI，将立即数左移 12 位存入寄存器
        `test_spm_write_OP_LUI(72,20'b1111_1111_1111_1111_1110,5'b10011) // gpr[rd] = 32'b1111_1111_1111_1111_1110_0000_0000_0000，4294959104
        //判断 LUI 操作的结果是否写入寄存器了
        `test_spm_write_OP_IMM(76,12'b0000_0000_0000,5'b10011,`FUNCT3_ADDI,5'b10100) // gpr[rd] = 4294959104

        //OP_AUIPC
        //执行 AUIPC，将立即数左移 12 位再加上当前 pc 后存入寄存器
        `test_spm_write_OP_AUIPC(80,20'b0000_0000_0000_0000_0011,5'b10101) // gpr[rd] = 12288 + 80，12368

        //OP
        //执行 ADD，将两寄存器的值做无符号相加
        `test_spm_write_OP(84,7'b0000000,5'b00001,5'b10101,`FUNCT3_ADD,5'b10110) // gpr[rd] = 12369
        //执行 SLT，有符号比较两寄存器大小，前者大输出1到目标寄存器
        `test_spm_write_OP(88,7'b0000000,5'b10110,5'b00001,`FUNCT3_SLT,5'b10111) // gpr[rd] = 1
        //执行 SLTU，比较两寄存器大小，前者大输出1到目标寄存器
        `test_spm_write_OP(92,7'b0000000,5'b00010,5'b00011,`FUNCT3_SLTU,5'b11000) // gpr[rd] = 0
        //执行 AND，两寄存器做位与
        `test_spm_write_OP(96,7'b0000000,5'b01001,5'b00111,`FUNCT3_AND,5'b11001) // gpr[rd] = 1
        //执行 OR，两寄存器做位或
        `test_spm_write_OP(100,7'b0000000,5'b01001,5'b00111,`FUNCT3_OR,5'b11010) // gpr[rd] = 15
        //执行 XOR，两寄存器做异或
        `test_spm_write_OP(104,7'b0000000,5'b01001,5'b00111,`FUNCT3_XOR,5'b11011) // gpr[rd] = 'b1110 = 14
        //执行 SLL，后寄存器的值左移前寄存器[4:0]位
        `test_spm_write_OP(108,7'b0000000,5'b00010,5'b00011,`FUNCT3_SLL,5'b11110) // gpr[rd] = 'b1100 = 12
        //执行 SRL，后寄存器的值右移前寄存器[4:0]位
        `test_spm_write_OP(112,7'b0000000,5'b00010,5'b00011,`FUNCT3_SRL,5'b11111) // gpr[rd] = 0
        //执行 SUB，后寄存器减前寄存器
        `test_spm_write_OP(116,7'b0100000,5'b00010,5'b00011,`FUNCT3_SUB,5'b00000) // gpr[rd] = 1
        //执行 SRA，后寄存器的值右移前寄存器[4:0]位，左填符号位
        `test_spm_write_OP(120,7'b0100000,5'b00011,5'b00011,`FUNCT3_SRA,5'b11111) // gpr[rd] = 32'b00000_0~0 = 0



        //OP_JAL，跳转到 pc 地址加上 imm，将当前 pc + 4 的值写入目标寄存器（uses x1 as the return address register），以便在跳转程序结束后，继续原指令
        `test_spm_write_OP_JAL(124,20'b0_0000000100_0_00000000,5'b00001) // gpr[5'b00001] = pc + 4 = 128; pc = pc + 'b1000 = pc + 8 = 132
        
        //OP_JALR，跳转到 rs1 地址加上 imm（最后一位置零），将当前pc + 4 的值写入目标寄存器（uses x0 as the return address register）
        `test_spm_write_OP_JALR(132,12'b0000_1000_0011,5'b00101,5'b00000) // gpr[5'b00000] = pc + 4 = 136; pc = 'b1000_0011 + 'b101 = 136 


        //OP_BRANCH，后寄存器与前寄存器比较，满足则发生跳转
        `test_spm_write_OP_BRANCH(136,7'b0000000,5'b00011,5'b00011,`FUNCT3_BEQ,5'b01000) // pc = pc + 'b1000 = pc + 8 = 144 (next_pc)
        `test_spm_write_OP_BRANCH(144,7'b0000000,5'b00011,5'b00010,`FUNCT3_BNE,5'b01000) // pc = pc + 'b100 = pc + 8 = 152
        `test_spm_write_OP_BRANCH(152,7'b0000000,5'b00011,5'b00010,`FUNCT3_BLT,5'b01000) // pc = pc + 'b100 = pc + 8 = 160
        `test_spm_write_OP_BRANCH(160,7'b0000000,5'b00011,5'b00010,`FUNCT3_BLTU,5'b01000) // pc = pc + 'b100 = pc + 8 = 168
        `test_spm_write_OP_BRANCH(168,7'b0000000,5'b00010,5'b00011,`FUNCT3_BGE,5'b01000) // pc = pc + 'b100 = pc + 8 = 176
        `test_spm_write_OP_BRANCH(176,7'b0000000,5'b00010,5'b00011,`FUNCT3_BGEU,5'b01000) // pc = pc + 'b100 = pc + 8 = 184

        //OP_LOAD,将内存的值存入 gpr，将寄存器的值与立即数(12 bits)相加得到 spm 的地址，取出该地址的值写入 gpr 的 rd
        `test_spm_write_OP_LOAD(184,12'b0000_0000_1010,5'b00010,`FUNCT3_LW,5'b00100) //mem_data = spm[10+2] = 'h003F8193, gpr[rd = 5'b00100] = 003F8193
        `test_spm_write_OP_LOAD(188,12'b0000_0000_0101,5'b00011,`FUNCT3_LH,5'b00101) //mem_data = spm[5+3] = 'hFFFF8113, rd = 5'b00101
        `test_spm_write_OP_LOAD(192,12'b0000_0000_0010,5'b00010,`FUNCT3_LHU,5'b00110) //mem_data = spm[2+2] = 'h00008093, rd = 5'b00110
        `test_spm_write_OP_LOAD(196,12'b0000_0000_0010,5'b00010,`FUNCT3_LB,5'b00111) //mem_data = spm[2+2] = 'hFFFFFF93, rd = 5'b00111
        `test_spm_write_OP_LOAD(200,12'b0000_0000_0010,5'b00010,`FUNCT3_LBU,5'b01000) //mem_data = spm[2+2] = 'h00000093, rd = 5'b01000

        // //OP_STORE，将 gpr 中 rs2 的值存入，寄存器的值与立即数(7 bits,5 bits)相加得到 spm 的地址
        // `test_spm_write_OP_STORE(204,7'b0000110,5'b00100,5'b00011,`FUNCT3_SW,5'b01101) //gpr[rs2] = gpr[5'b00100] = 'h003F8193, spm[205 + 3] = 'h003F8193
        //         //因此，在 spm 的 208 地址会执行 register3 = register[5'b11111] + 3 = 0 + 3 = 3

        // `test_spm_write_OP_STORE(212,7'b0000110,5'b00110,5'b01001,`FUNCT3_SB,5'b01111) //gpr[rs2] = gpr[5'b00110] = 'h00008093, spm[207 + 9] = 'hFFFFFF93
        // `test_spm_write_OP_STORE(220,7'b0000110,5'b00100,5'b01001,`FUNCT3_SH,5'b10111) //gpr[rs2] = gpr[5'b00100] = 'h003F8193, spm[215 + 9] = 'hFFFF8193

        `test_spm_write_OP_STORE(228,7'b0000000,5'b00011,5'b01001,`FUNCT3_SW,5'b00111) //先往内存写：spm[7 + 9] = gpr[5'b00011] = 3
        `test_spm_write_OP_LOAD(236,12'b0000_0000_1101,5'b00011,`FUNCT3_LW,5'b00100) //再从内存读往 gpr 中写： gpr[4] = spm[3 + 13] = 3
        `test_spm_write_OP_IMM(240,12'b0000_0000_0000,5'b00100,`FUNCT3_ADDI,5'b00101) //再读 gpr: gpr[5] = 0 + gpr[3] = 3
        `test_spm_write_OP_IMM(244,12'b0000_0000_0000,5'b00100,`FUNCT3_ADDI,5'b00110) //再读 gpr: gpr[6] = 0 + gpr[3] = 3

    end
    // cpu 测试
    #10 begin
        test_spm_as_ = 1;
        cpu_en = 1;
    end
    #550
    $finish;
end

initial begin
    $dumpfile("wave_cpu_top.vcd");
    $dumpvars(0,test_cpu_top);
end

endmodule