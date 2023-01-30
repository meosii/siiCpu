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
Fourth, the immediate numbers in the instruction format are always sign extended and the highest bit of the instruction is the sign bit, so the sign extended operation of the immediate numbers can be performed before decoding.

## 2. Architecher

