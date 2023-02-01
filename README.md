# siiCpu
This is a project created by sii, a wonderful CPU would be generated.

## 1. Supported instrcutions
Here, we describe a basic instruction set which is named RV32I base integer instruction set belongs to RISC-V. Following, we describe the source regiester as "rs", destination register as "rd", and immediates as "imm". RISC-V has four base instruction formats (R/I/S/U) and two variants (B/J).

### 1.1 Integer Computational Instructions

- Integer Register-Immediate Instructions

| imm[11:0] | rs1 | funct3 | rd | opcode |
| :----: | :----: | :----: | :----: | :----: |
| 31 ··· 20 | 19 ··· 15 | 14 ··· 12 | 11 ··· 7 | 6 ··· 0 |
| 12 | 5 | 3 | 5 | 7 | 
| I-immediate[11:0] |  src | ADDI/SLTI[U] | dest |  OP-IMM |
| I-immediate[11:0] |  src | ANDI/ORI/XORI | dest |  OP-IMM |

  > ADDI: Adds sign-extended 12-bit immediate to "rs1", ignore the arithmetic overflow.

  > SLTI: Put value  "1" to "rd", when "rs1" >= sign-extended immediate 

  > SLTIU: Put value  "1" to "rd", when "rs1" >= unsigned-extended immediate

  > XORI: Perform XOR operation between imm and "rs1", then put the result to "rd".(same as ANDI, ORI, XORI)

| imm[11:5] | imm[4:0] | rs1 | funct3 | rd | opcode |
| :----: | :----: | :----: | :----: | :----: | :----: |
| 31 ··· 25 | 24 ··· 20 | 19 ··· 15 | 14 ··· 12 | 11 ··· 7 | 6 ··· 0 |
| 7 | 5 | 5 | 3 | 5 | 7 |
| 0000000 |   shamt[4:0] | scr | SLLI |  dest |  OP-IMM |
| 0000000 |   shamt[4:0] | scr | SRLI |  dest | OP-IMM |
| 0000000 |   shamt[4:0] | scr | SRAI |  dest | OP-IMM |

The operand to be shifted is in "rs1", and the shift amount is encoded in the lower 5 bits of the I-immediate field.

  > SLLI: A logical left shift (zeros are shifted into the lower bits).
  
  > SRLI: A logical right shift (zeros are shifted into the upper bits).

  > SRAI: An arithmetic right shift (the original sign bit is copied into the vacated upper bits)

  | imm[31:12] | rd | opcode |
  | :----: | :----: | :----: |
  | 20 | 5 | 7 |
  | U-immediate[31:12] | dest | LUI |
  | U-immediate[31:12] | dest | AUIPC |

  > LUI: Load upper immediate, place the U-immediate value in the top 20 bits of the destination register rd, filling in the lowest 12 bits with zeros.

  > AUIPC: Add upper immediate to pc, using U-immediate as high 20 bits, lowest 12 bits with zero, this 32 bits forms as a offset, add this offset to the address of AUIPC instruction, then places to the "rd". 

- Integer Register-Register Operations

| funct7 | rs2 | rs1 | funct3 | rd | opcode |
| :----: | :----: | :----: | :----: | :----: | :----: |
| 31 ··· 25 | 24 ··· 20 | 19 ··· 15 | 14 ··· 12 | 11 ··· 7 | 6 ··· 0 |
| 7 | 5 | 5 | 3 | 5 | 7 |
| 0000000 | scr2 | scr1 | ADD/SLT/SLTU | dest | OP |
| 0000000 | scr2 | scr1 | AND/OR/XOR | dest | OP |
| 0000000 | scr2 | scr1 | SLL/SRL | dest | OP |
| 0100000 | scr2 | scr1 | SUB/SRA | dest | OP |

  > ADD: Performs the addition of "rs1" and rs2, ignore the overflows.

  > SUB: Performs the subtraction of rs2 from "rs1", ignore the overflows.

  > SLT/SLTU: Perform signed and unsigned compares respectively, if "rs1" < rs2, writing 1 to "rd", otherwise set rd to zero.

  > AND/OR/XOR: Perform bitwise logical operations.

  > SLL/SRL/SRA: Perform logical left, logical right, and arithmetic right shifts, the shife amount held in the lower 5 bits of rs2.

- NOP Instruction
  
| imm[11:0] | rs1 | funct3 | rd | opcode |
| :----: | :----: | :----: | :----: | :----: |
| 12 | 5 | 3 | 5 | 7 |
| 0 | 0 | ADDI | 0 | OP-IMM |

 > ADDI x0,x0,0: The NOP instruction does not change any architecturally visible state, except for the advancing the pc.

### 1.2 Control Transfer Instructions

RV32I provides two types of control transfer instructions: unconditional jumps and conditional branches. 

- Unconditional Jumps
  
  Here, we named JAL as the jump and link,
 
| imm[20] | imm[10:1] | imm[11] | imm[19:12] | rd | opcode |
| :----: | :----: | :----: | :----: | :----: | :----: |
| 1 | 10 | 1 | 8 | 5 | 7 |
||| offset[20:1] || dest | JAL |

 > JAL: Plain unconditional jumps.

| imm[11:0] | rs1 | funct3 | rd | opcode |
| :----: | :----: | :----: | :----: | :----: |
| 12 | 5 | 3 | 5 | 7 |
| offset[11:0] | base | 0 | dest | JALR |

> JALR: Jump and link register, the target address is obtained by adding the sign-extended 12-bit I-immediate to "rs1", then setting
the least-significant bit of the result to zero.

- Conditional Branches
  
| imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode |
| :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: |
| 1 | 6 | 5 | 5 | 3 | 4 | 1 | 7 |
| offset[12|10:5] | src2 | src1 | BEQ/BNE | offset[4:1] | offset[11] | BRANCH |
| offset[12|10:5] | src2 | src1 | BLT[U] | offset[4:1] | offset[11] | BRANCH |
| offset[12|10:5] | src2 | src1 | BGE[U] | offset[4:1] | offset[11] | BRANCH |

 > BEQ/BNE: Compare two register, if "rs1" == "rs2" or "rs1" != "rs2", take the branch.

 > BLT/BLTU: Using signed and unsigned comparison respectively, if "rs1" < "rs2", take the branch.

 > BGE/BGEU: Using signed and unsigned comparison respectively, if "rs1" >= "rs2", take the branch.

### 1.3 Load and Store Instructions

Load and store instructions transfer a value between the registers and memory. 

| imm[10:0] | rs1 | funct3 | rd | opcade |
| :----: | :----: | :----: | :----: | :----: |
| 31 ··· 20 | 19 ··· 15 | 14 ··· 12 | 11 ··· 7 | 6 ··· 0 |
| 12 | 5 | 3 | 5 | 7 |
| offset[11:0] | base | width | dest | LOAD |

 > LOAD: Copy a value from memory in the address by adding "rs1" to the sign-extended 12-bit offset.

 > STORE: Stores the value in "rs2".

### 1.4 Memory Ordering Instructions

| fm | PI | PO | PR | PW | SI | SO | SR | SW | rs1 | funct3 | rd | opcode |
| :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: |
| 31 ··· 28 | 27 ··· 26 | 25 ··· 24 | 23 ··· 22 | 21 ··· 20 | 19 ··· 15 | 14 ··· 12 | 11 ··· 7 | 6 ··· 0 |
| 4 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 5 | 3 | 5 | 7 |
| FM ||| predecessor ||| successor||| 0 | FENCE | 0 | MISC-MEM |

 > FENCH: Order device I/O and memory accesses. Any combination of device input (I), device output (O), memory reads (R), and memory writes (W) may be ordered with respect to any combination of the same. 

### 1.5 Environment Call and Breakpoints

SYSTEM instructions are used to access system functionality that might require privileged access.

| funct12 | rs1 | funct3 | rd | opcode |
| :----: | :----: | :----: | :----: | :----: |
| 31 ··· 20 | 19 ··· 15 | 14 ··· 12 | 11 ··· 7 | 6 ··· 0 |
| 12 | 5 | 3 | 5 | 7 |
| ECALL | 0 | PRIV | 0 | SYSTEM |
| BREAK | 0 | PRIV | 0 | SYSTEM |

 > ECALL: Make a service request to the execution envirement.

 > EBREAK: Return control to a debugging environment.

### 1.6 HINT Instructions

RV32I reserves a large encoding space for HINT instructions, which are usually used to communicate performance hints to the microarchitecture

### 1.7 We will know

RISC-V is a more compact instruction set architecture design with high performance and low power consumption as seen from the basic instruction formats. 

1. RISC-V instructions have only 6 basic instruction formats, and each instruction length is 32 bits, unlike X86-32 and ARM-32 which have many instruction formats, which greatly reduces the decoding time of instructions. 
2. The RISC-V instruction format has three register addresses, unlike X86 where the source and destination operands share a single address, and it does not require an additional move instruction to store the destination register value. 
3. For all RISC-V instructions, the read and write register identifiers need to be stored in the same location, which allows the instruction to access the register values in advance of the decode operation.
4. The immediate numbers in the instruction format are always sign extended and the highest bit of the instruction is the sign bit, so the sign extended operation of the immediate numbers can be performed before decoding.

## 2. Architecher

### 2.1 Single Cycle Processor

Single cycle processor is a processor in which one instruction is completed in one clock cycle.To implement a processor to properly process instructions, there are several steps:

1. Setting up a "program counter" to fetch an instruction every cycle;
2. After the instruction fetching, a "decoder" is needed to translate current task (here we have three main types of instructions: arithmetic operations, instruction jump and memory access);
3. Arithmetic operations: the immediate number or gpr's data is passed to the "alu" module;
4. Jump instruction: the decoder pass the jump address and the jump enable signal to "if_stage";
5. Memory access instruction: LOAD: Reads the value in "gpr", then writes this data to "memory", STORE: Reads the value in "memory", then writes the data to "gpr", by "mem_ctrl" module executed.

The basic modules we need are: if_stage (Instruction Fetch), decoder, alu, mem_ctrl, gpr, spm(memory) and cpu_top.

#### 2.1.1 if_stage

In this module, we have two main tasks, one is executing jump instruction, the other is executing pc + 4.

By juding the signal of "br_taken", we choose whether jump or not.(ps: "cpu_en" used to write instructions in memory when "cpu_en" is low)

``` verilog
always @(posedge clk or negedge reset) begin
    if (!reset | !cpu_en) begin
        if_pc <= 0;
    end else if (br_taken) begin
        if_pc <= br_addr;
    end else begin
        if_pc <= if_pc + 4;
    end
end
```

#### 2.1.2 decoder

This module is a combination circuit, the main task is decodering what task will be executed.

Here, we should be careful to the following points:
1. Distinguish between signed and unsigned numbers.In RISC-V, imm usually show as 12 bits or 20 bits, so the signed bit expansion for immediate numbers is important. 
``` verilog
//The immediate number is sign extended to XLEN(32 bits) bits
if (if_insn[31] == 1) begin
    imm = {20'b1111_1111_1111_1111_1111,if_insn[31:20]};
end else begin
    imm = {20'b0000_0000_0000_0000_0000,if_insn[31:20]};
end
```
2. When we should write in gpr, setting "we_" as 0 is needed, "dst_addr" needs to be prepared. While, if we need read from gpr, we only prepare the signal of "gpr_rd_addr".
3. To provide "alu_op" or "mem_op" in time. The operation uses `define.

#### 2.1.3 alu

This module is a combination circuit, the main task is executing arithmetic operations.

#### 2.1.4 mem_ctrl

This module is a combination circuit, the main task is transmitting the signals between "gpr" and "memory". By the signal of "mem_op", we judge LOAD or STORE.

Since memory access requires byte alignment, here we judge "alu_out"'s last two bits, if this two bits is 2'b00, means that align.

``` verilog
assign offset = alu_out[`BYTE_OFFSET_LOC];
if (offset == `BYTE_OFFSET_WORD) begin
    miss_align = 0;
end else begin
    miss_align = 1;
end
```

If "miss_align" is high or the "mem_op" is false, we need put the "as_" as low(spm_as).


LOAD:

  Firstly, we gain the memory's addr from "alu", then gain the memory's data from "spm"(memory), using the "dst_addr" from "decoder" we can visit the "gpr" and write "mem_data" to "gpr". This data could be passed as a word(32 bits), a half of a word(16 bits) or a quater of a word(8 bits).

``` verilog
assign addr_to_mem = alu_out[`WORD_ADDR_BUS];
always @* begin
  ···
  case (mem_op)
    `MEM_OP_LOAD_LW: begin
            mem_op_as_ = 0;
            rw = `READ;
            mem_data_to_gpr = $signed(mem_data[`WORD_WIDTH - 1:0]);
        end
        `MEM_OP_LOAD_LH: begin
            mem_op_as_ = 0;
            rw = `READ;
            //Take the halfword width first, then sign extend
            if (mem_data[(`WORD_WIDTH/2) - 1] == 1) begin
                load_data = {16'b1111_1111_1111_1111,mem_data[(`WORD_WIDTH/2) - 1:0]};
            end else begin
                load_data = mem_data[(`WORD_WIDTH/2) - 1:0];
            end
            mem_data_to_gpr = $signed(load_data); 
        end
    ···
  endcase
  ···
end
```

STORE:

  Only need pass the signal of "gpr_data". "decoder" has already generated a word(32 bits), a half of a word(16 bits) or a quater of a word(8 bits).

``` verilog
assign wr_data = gpr_data;
always @* begin
  ···
  case (mem_op)
    `MEM_OP_STORE: begin
        mem_op_as_ = 0;
        rw = `WRITE;
    end
    ···
  endcase
  ···
end
```

#### 2.1.5 spm

In memory, an address holds 8bits, but the siiCpu is a 32-bit processer, which needs four address to store the data, showing as follows:

``` verilog
assign if_spm_rd_data = (!if_spm_as_ && (if_spm_rw == READ))? 
                        {spm[if_spm_addr],spm[if_spm_addr + 1],spm[if_spm_addr + 2],spm[if_spm_addr + 3]} : 32'b0;
assign mem_spm_rd_data = (!mem_spm_as_ && (mem_spm_rw == READ))? 
                        {spm[mem_spm_addr],spm[mem_spm_addr + 1],spm[mem_spm_addr + 2],spm[mem_spm_addr + 3]} : 32'b0;
always @(posedge clk or negedge rst_) begin
    if (!rst_) begin
        for (i = 0;i < 1023;i++) begin
            spm[i] <= 32'b0;
        end
    end else if (!mem_spm_as_ && (mem_spm_rw == WRITE)) begin
        spm[mem_spm_addr] <= mem_spm_wr_data[31:24];
        spm[mem_spm_addr + 1] <= mem_spm_wr_data[23:16];
        spm[mem_spm_addr + 2] <= mem_spm_wr_data[15:8];
        spm[mem_spm_addr + 3] <= mem_spm_wr_data[7:0];
    end else if (!if_spm_as_ && (if_spm_rw == WRITE)) begin
        spm[if_spm_addr] <= if_spm_wr_data[31:24];
        spm[if_spm_addr + 1] <= if_spm_wr_data[23:16];
        spm[if_spm_addr + 2] <= if_spm_wr_data[15:8];
        spm[if_spm_addr + 3] <= if_spm_wr_data[7:0];
    end
end
```

#### 2.1.6 gpr

General Purpose Registers. Here, we use up to three registers as operands, read values from two registers and then write values to the other register.Therefore, we need two read ports and one write port.Showing as follows:

``` verilog
assign rd_data_0 = ((we_ == `WRITE) && (wr_addr == rd_addr_0))? wr_data : gpr[rd_addr_0];
assign rd_data_1 = ((we_ == `WRITE) && (wr_addr == rd_addr_1))? wr_data : gpr[rd_addr_1];
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        for (i = 0; i < `DATA_HIGH_GPR; i++) begin
            gpr[i] <= `DATA_WIDTH_GPR'b0;
        end
    end else if (we_ == `WRITE) begin
            gpr[wr_addr] <= wr_data;
    end
end
```

### 2.1 CPU with pipeline design

For single cycle processer, an instruction could be executed in one cycle, but for different instructions, the executed time is different. We need to select the longest instruction processing time as a cycle, the clock frequency will be very slow. While for the CPU with pipeline design, an instruction will be executed in multi-cycle, but clock frequency will be improved, even more, 1000 cycles also could execute nearly 1000 instructions.


## 3 RUN

### build
use
`
make
`
to build the tests, and all the test files would be generated into `test/bin` dirctory

### clean
use
`
make clean
`
to clean all the test files and vcd files.