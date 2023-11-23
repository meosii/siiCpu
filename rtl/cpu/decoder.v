`ifndef SIICPU_DECODER
`define SIICPU_DECODER
`include "define.v"
module decoder (
    input wire [`PC_WIDTH-1 : 0]                pc, // pc = (if_pc + 4) or br_addr_tmp
    //from if
    input wire                                  if_en,
    input wire [`PC_WIDTH-1 : 0]                if_pc,
    input wire [`WORD_WIDTH - 1 : 0]            if_insn,
    // branch prediction
    input wire                                  if_predt_br_taken,
    //from gpr
    input wire [`WORD_WIDTH - 1 : 0]            gpr_rd_data_0,
    input wire [`WORD_WIDTH - 1 : 0]            gpr_rd_data_1,
    //to gpr
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        gpr_rd_addr_0,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        gpr_rd_addr_1,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        dst_addr,
    output reg                                  gpr_we_n,
    //csr to gpr
    output reg [`WORD_WIDTH - 1 : 0]            csr_to_gpr_data,
    //to csr
    output reg                                  csr_rd_en,
    output reg [`CSR_ADDR_WIDTH - 1 :0]         csr_rd_addr,
    output reg                                  csr_w_en,
    output reg [`CSR_ADDR_WIDTH - 1 :0]         csr_w_addr,
    output reg [`WORD_WIDTH - 1 : 0]            csr_w_data,
    // to cpu ctrl
    output wire                                 ebreak_en,
    output wire                                 ecall_en,
    //from csr
    input wire [`WORD_WIDTH - 1 : 0]            csr_rd_data,
    //to alu
    output wire [`DATA_WIDTH_ALU_OP - 1 : 0]    alu_op,
    output reg [`WORD_WIDTH - 1 : 0]            alu_in_0,
    output reg [`WORD_WIDTH - 1 : 0]            alu_in_1,
    //to pc
    output wire [`PC_WIDTH-1 : 0]               br_addr,
    output wire                                 br_taken,
    //to mem
    output wire [`DATA_WIDTH_MEM_OP - 1 : 0]    mem_op,
    output wire                                 memory_we_en,
    output wire                                 memory_rd_en,
    output wire [`WORD_WIDTH - 1 : 0]           store_data,
    output wire [3 : 0]                         store_byteena,

    // forwarding
    // EX data
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        id_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]            id_csr_to_gpr_data,
    input wire [`WORD_WIDTH - 1 : 0]            alu_out,
    // MEM data
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        ex_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]            ex_alu_out,
    input wire [`WORD_WIDTH - 1 : 0]            ex_csr_to_gpr_data,
    input wire                                  load_after_storing_en,  // store in mem_stage, load in ex_stage
    input wire                                  loading_after_store_en, // load in mem_stage
    input wire [`WORD_WIDTH - 1 : 0]            ex_store_data,
    input wire [`WORD_WIDTH - 1 : 0]            prev_ex_store_data,
    // hazard
    input wire                                  load_in_id_ex,
    input wire                                  load_in_ex_mem,
    input wire                                  alu2gpr_in_id_ex,
    input wire                                  csr2gpr_in_id_ex,
    input wire                                  alu2gpr_in_ex_mem,
    input wire                                  csr2gpr_in_ex_mem,
    
    // exception
    output wire [`DATA_WIDTH_ISA_EXP - 1 : 0]   exp_code,
    // load hazard
    output wire                                 load_hazard_in_id_ex,
    output wire                                 load_hazard_in_ex_mem,
    // contral hazard
    output wire                                 contral_hazard
);

localparam SIGN_PC_WIDTH = `PC_WIDTH + 1;

wire        [`ALL_TYPE_OPCODE]          opcode;
wire        [`WORD_WIDTH - 1 : 0]       rs1_data;
wire        [`WORD_WIDTH - 1 : 0]       rs2_data;
wire                                    rs1_data_valid;
wire                                    rs2_data_valid;
wire        [`PC_WIDTH : 0]             jr_target;
reg         [`WORD_WIDTH - 1 : 0]       imm;
reg                                     gpr_rd_en;

assign opcode = if_insn[`ALL_TYPE_OPCODE];

always @(*) begin
    case(opcode)
        `OP_IMM,`OP_JALR,`OP_LOAD: begin
            gpr_we_n        = (if_en) ? `GPR_WRITE : `DIS_GPR_WRITE;
            gpr_rd_en       = (if_en)?  `GPR_READ  : `DISABLE;
            gpr_rd_addr_0   = if_insn[`I_TYPE_RS1];
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = if_insn[`I_TYPE_RD];
            imm             = {{20{if_insn[`INSN_MSB]}}, if_insn[`I_TYPE_IMM]};
        end
        `OP_LUI,`OP_AUIPC: begin
            gpr_we_n        = (if_en) ? `GPR_WRITE : `DIS_GPR_WRITE;
            gpr_rd_en       = `DISABLE;
            gpr_rd_addr_0   = `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = if_insn[`U_TYPE_RD];
            imm             = {if_insn[`U_TYPE_IMM], 12'b0};
        end
        `OP: begin
            gpr_we_n        = (if_en) ? `GPR_WRITE : `DIS_GPR_WRITE;
            gpr_rd_en       = (if_en)?  `GPR_READ  : `DISABLE;
            gpr_rd_addr_0   = if_insn[`R_TYPE_RS1];
            gpr_rd_addr_1   = if_insn[`R_TYPE_RS2];
            dst_addr        = if_insn[`R_TYPE_RD];
            imm             = `WORD_WIDTH'b0;
        end
        `OP_JAL: begin
            gpr_we_n        = (if_en) ? `GPR_WRITE : `DIS_GPR_WRITE;
            gpr_rd_en       = (if_en)?  `GPR_READ  : `DISABLE;
            gpr_rd_addr_0   = `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = if_insn[`J_TYPE_RD];
            imm             = {{12{if_insn[`J_TYPE_IMM_20]}}, if_insn[`J_TYPE_IMM_19_12], if_insn[`J_TYPE_IMM_11], if_insn[`J_TYPE_IMM_10_1], 1'b0};
        end
        `OP_BRANCH: begin
            gpr_we_n        = `DIS_GPR_WRITE;
            gpr_rd_en       = (if_en)?  `GPR_READ  : `DISABLE;
            gpr_rd_addr_0   = if_insn[`B_TYPE_RS1];
            gpr_rd_addr_1   = if_insn[`B_TYPE_RS2];
            dst_addr        = `GPR_ADDR_WIDTH'b0;
            imm             = {{20{if_insn[`B_TYPE_IMM_12]}}, if_insn[`B_TYPE_IMM_11], if_insn[`B_TYPE_IMM_10_5], if_insn[`B_TYPE_IMM_4_1], 1'b0 };
        end
        `OP_STORE: begin
            gpr_we_n        = `DIS_GPR_WRITE;
            gpr_rd_en       = (if_en)?  `GPR_READ  : `DISABLE;
            gpr_rd_addr_0   = if_insn[`S_TYPE_RS1];
            gpr_rd_addr_1   = if_insn[`S_TYPE_RS2];
            dst_addr        = `GPR_ADDR_WIDTH'b0;
            imm             = {{20{if_insn[`S_TYPE_IMM_11]}}, if_insn[`S_TYPE_IMM_11_5], if_insn[`S_TYPE_IMM_4_0]};
        end
        `OP_SYSTEM: begin
            gpr_we_n        = ((if_insn[`I_TYPE_FUNCT3] != 3'b000) && if_en) ? `GPR_WRITE : `DIS_GPR_WRITE;
            gpr_rd_en       = ((if_insn[`I_TYPE_FUNCT3] != 3'b000) && if_en)?  `GPR_READ  : `DISABLE;
            gpr_rd_addr_0   = (if_insn[`I_TYPE_FUNCT3] != 3'b000)? if_insn[`I_TYPE_RS1] : `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = (if_insn[`I_TYPE_FUNCT3] != 3'b000)? if_insn[`I_TYPE_RD] : `GPR_ADDR_WIDTH'b0;
            imm             = (if_insn[`I_TYPE_FUNCT3] != 3'b000)? {{20{if_insn[`INSN_MSB]}}, if_insn[`I_TYPE_IMM]} : `WORD_WIDTH'b0;
        end
        default: begin
            gpr_we_n        = `DIS_GPR_WRITE;
            gpr_rd_en       = `DISABLE;
            gpr_rd_addr_0   = `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = `GPR_ADDR_WIDTH'b0;
            imm             = `WORD_WIDTH'b0;
        end
    endcase
end

always @(*) begin
    if (opcode == `OP_SYSTEM) begin
        case (if_insn[`I_TYPE_FUNCT3])
            `FUNCT3_CSRRW: begin //t = CSRs[csr]; CSRs[csr] = x[rs1]; x[rd] = t
                csr_rd_en       = (if_en)? `ENABLE : `DISABLE;
                csr_rd_addr     = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_en        = (if_en && rs1_data_valid)? `ENABLE : `DISABLE;
                csr_w_addr      = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_data      = rs1_data;
                csr_to_gpr_data = csr_rd_data;
            end
            `FUNCT3_CSRRS: begin //t = CSRs[csr]; CSRs[csr] = t | x[rs1]; x[rd] = t
                csr_rd_en       = (if_en)? `ENABLE : `DISABLE;
                csr_rd_addr     = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_en        = (if_en && rs1_data_valid)? `ENABLE : `DISABLE;
                csr_w_addr      = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_data      = csr_rd_data | rs1_data;
                csr_to_gpr_data = csr_rd_data;
            end
            `FUNCT3_CSRRC: begin //t = CSRs[csr]; CSRs[csr] = t &~x[rs1]; x[rd] = t
                csr_rd_en       = (if_en)? `ENABLE : `DISABLE;
                csr_rd_addr     = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_en        = (if_en && rs1_data_valid)? `ENABLE : `DISABLE;
                csr_w_addr      = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_data      = csr_rd_data & ~rs1_data;
                csr_to_gpr_data = csr_rd_data;
            end
            `FUNCT3_CSRRWI: begin //x[rd] = CSRs[csr]; CSRs[csr] = zimm
                csr_rd_en       = (if_en)? `ENABLE : `DISABLE;
                csr_rd_addr     = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_en        = (if_en)? `ENABLE : `DISABLE;
                csr_w_addr      = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_data      = {27'b0,if_insn[`I_TYPE_RS1]};
                csr_to_gpr_data = csr_rd_data;
            end
            `FUNCT3_CSRRSI: begin //t = CSRs[csr]; CSRs[csr] = t | zimm; x[rd] = t
                csr_rd_en       = (if_en)? `ENABLE : `DISABLE;
                csr_rd_addr     = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_en        = (if_en)? `ENABLE : `DISABLE;
                csr_w_addr      = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_data      = csr_rd_data | {27'b0,if_insn[`I_TYPE_RS1]};
                csr_to_gpr_data = csr_rd_data;
            end
            `FUNCT3_CSRRCI: begin //t = CSRs[csr]; CSRs[csr] = t &~zimm; x[rd] = t
                csr_rd_en       = (if_en)? `ENABLE : `DISABLE;
                csr_rd_addr     = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_en        = (if_en)? `ENABLE : `DISABLE;
                csr_w_addr      = imm[`CSR_ADDR_WIDTH - 1 : 0];
                csr_w_data      = csr_rd_data & ~{27'b0,if_insn[`I_TYPE_RS1]};
                csr_to_gpr_data = csr_rd_data;
            end
            `FUNCT3_ECALL_EBREAK: begin // deal in csr
                csr_rd_en       = `DISABLE;
                csr_rd_addr     = `CSR_ADDR_WIDTH'b0;
                csr_w_en        = `DISABLE;
                csr_w_addr      = `CSR_ADDR_WIDTH'b0;
                csr_w_data      = `WORD_WIDTH'b0;
                csr_to_gpr_data = `WORD_WIDTH'b0; // rd_addr = 5'b00000;
            end
            default: begin
                csr_rd_en       = `DISABLE;
                csr_rd_addr     = `CSR_ADDR_WIDTH'b0;
                csr_w_en        = `DISABLE;
                csr_w_addr      = `CSR_ADDR_WIDTH'b0;
                csr_w_data      = `WORD_WIDTH'b0;
                csr_to_gpr_data = `WORD_WIDTH'b0;
            end
        endcase
    end else begin
        csr_rd_en       = `DISABLE;
        csr_rd_addr     = `CSR_ADDR_WIDTH'b0;
        csr_w_en        = `DISABLE;
        csr_w_addr      = `CSR_ADDR_WIDTH'b0;
        csr_w_data      = `WORD_WIDTH'b0;
        csr_to_gpr_data = `WORD_WIDTH'b0;
    end
end

always @* begin
    alu_in_0    =   `WORD_WIDTH'b0;
    alu_in_1    =   `WORD_WIDTH'b0;
    case (opcode)
        `OP_IMM: begin
            alu_in_0    =   imm;
            alu_in_1    =   rs1_data;
        end
        `OP_LUI: begin
            alu_in_0    =   imm;
            alu_in_1    =   `WORD_WIDTH'b0;
        end
        `OP_AUIPC: begin
            alu_in_0    =   imm;
            alu_in_1    =   if_pc;
        end
        `OP: begin
            alu_in_0    =   rs1_data;
            alu_in_1    =   rs2_data;
        end
        `OP_JAL: begin
            alu_in_0    =   if_pc;
            alu_in_1    =   4;
        end
        `OP_JALR: begin
            alu_in_0    =   if_pc;
            alu_in_1    =   4;
        end
        `OP_BRANCH: begin
            alu_in_0    =   `WORD_WIDTH'b0;
            alu_in_1    =   `WORD_WIDTH'b0;
        end
        `OP_LOAD: begin
            alu_in_0    =   rs1_data;
            alu_in_1    =   imm;
        end
        `OP_STORE: begin
            alu_in_0    =   rs1_data;
            alu_in_1    =   imm;
        end
        default: begin
            alu_in_0    =   `WORD_WIDTH'b0;
            alu_in_1    =   `WORD_WIDTH'b0;
        end
    endcase
end

assign alu_op = (!if_en)? `ALU_OP_NOP :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_ADDI)                                                   )? `ALU_OP_ADDI     :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SLTI)                                                   )? `ALU_OP_SLTI     :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SLTIU)                                                  )? `ALU_OP_SLTIU    :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_ANDI)                                                   )? `ALU_OP_ANDI     :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_ORI)                                                    )? `ALU_OP_ORI      :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_XORI)                                                   )? `ALU_OP_XORI     :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SLLI)                                                   )? `ALU_OP_SLLI     :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SRLI_SRAI) && if_insn[`I_TYPE_IMM_11_5] == 7'b0000000   )? `ALU_OP_SRLI     :
                ((opcode == `OP_IMM) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SRLI_SRAI) && if_insn[`I_TYPE_IMM_11_5] == 7'b0100000   )? `ALU_OP_SRAI     :
                ((opcode == `OP_LUI)                                                                                                )? `ALU_OP_LUI      :
                ((opcode == `OP_AUIPC)                                                                                              )? `ALU_OP_AUIPC    :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_ADD)             )? `ALU_OP_ADD      :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SLT)             )? `ALU_OP_SLT      :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SLTU)            )? `ALU_OP_SLTU     :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_AND)             )? `ALU_OP_AND      :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_OR)              )? `ALU_OP_OR       :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_XOR)             )? `ALU_OP_XOR      :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SLL)             )? `ALU_OP_SLL      :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SRL)             )? `ALU_OP_SRL      :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0100000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SUB)             )? `ALU_OP_SUB      :
                ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0100000) && (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SRA)             )? `ALU_OP_SRA      :
                ((opcode == `OP_JAL) || (opcode == `OP_JALR) || (opcode == `OP_LOAD) || (opcode == `OP_STORE)                       )? `ALU_OP_ADD      : `ALU_OP_NOP;

// ebreak ecall
assign ebreak_en = ((if_en) && (if_insn == `EBREAK_INSN))?  `ENABLE : `DISABLE;
assign ecall_en  = ((if_en) && (if_insn == `ECALL_INSN) )?  `ENABLE : `DISABLE;

assign exp_code = (!if_en)? `ISA_EXP_NO_EXP :
                (((opcode == `OP_IMM) && ((if_insn[`I_TYPE_FUNCT3] == `FUNCT3_ADDI    ) ||
                                            (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SLTI    ) ||
                                            (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SLTIU   ) ||
                                            (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_ANDI    ) ||
                                            (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_ORI     ) ||
                                            (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_XORI    ) ||
                                            (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SLLI    ) ||
                                            ((if_insn[`I_TYPE_FUNCT3] == `FUNCT3_SRLI_SRAI) && ((if_insn[`I_TYPE_IMM_11_5] == 7'b0000000) || (if_insn[`I_TYPE_IMM_11_5] == 7'b0100000)))
                                            )
                    )
                ||  ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0000000) && ((if_insn[`R_TYPE_FUNCT3] == `FUNCT3_ADD  ) ||
                                                                                   (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SLT  ) ||
                                                                                   (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SLTU ) ||
                                                                                   (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_AND  ) ||
                                                                                   (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_OR   ) ||
                                                                                   (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_XOR  ) ||
                                                                                   (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SLL  ) ||
                                                                                   (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SRL  ))  
                    )
                ||  ((opcode == `OP) && (if_insn[`R_TYPE_FUNCT7] == 7'b0100000) && ((if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SUB) ||
                                                                                    (if_insn[`R_TYPE_FUNCT3] == `FUNCT3_SRA))   
                    )
                ||  (opcode == `OP_LUI      )
                ||  (opcode == `OP_AUIPC    )
                ||  (opcode == `OP_JAL      )
                ||  (opcode == `OP_JALR     )
                ||  (opcode == `OP_BRANCH   )
                ||  (opcode == `OP_LOAD     )
                ||  (opcode == `OP_STORE    )
                ||  (opcode == `OP_SYSTEM   ))? `ISA_EXP_NO_EXP : `ISA_EXP_UNDEF_INSN;

// jump and branch
wire                        br_taken_tmp;
wire [`PC_WIDTH - 1 : 0]    br_addr_tmp;
wire                        predt_br_success;
wire                        predt_br_error;

assign br_taken_tmp =   if_en &&
                        (   opcode == `OP_JAL                                                                                   ) || 
                        (   (opcode == `OP_JALR) && rs1_data_valid                                                              ) ||
                        (   (opcode == `OP_BRANCH) && rs1_data_valid && rs2_data_valid &&
                            (   ((if_insn[`B_TYPE_FUNCT3] == `FUNCT3_BEQ)   && (rs1_data == rs2_data)                   ) ||
                                ((if_insn[`B_TYPE_FUNCT3] == `FUNCT3_BNE)   && (rs1_data != rs2_data)                   ) ||
                                ((if_insn[`B_TYPE_FUNCT3] == `FUNCT3_BLT)   && ($signed(rs1_data) < $signed(rs2_data))  ) ||
                                ((if_insn[`B_TYPE_FUNCT3] == `FUNCT3_BLTU)  && (rs1_data < rs2_data)                    ) ||
                                ((if_insn[`B_TYPE_FUNCT3] == `FUNCT3_BGE)   && ($signed(rs1_data) >= $signed(rs2_data)) ) ||
                                ((if_insn[`B_TYPE_FUNCT3] == `FUNCT3_BGEU)  && (rs1_data >= rs2_data)                   )   )   );

assign jr_target    =   (opcode == `OP_JAL)?    $signed({1'b0,if_pc})       + $signed(imm)  :
                        (opcode == `OP_JALR)?   $signed({1'b0,rs1_data})    + $signed(imm)  :
                        (opcode == `OP_BRANCH)? $signed({1'b0, if_pc})      + $signed(imm)  :   {SIGN_PC_WIDTH{1'b0}};

assign br_addr_tmp  =   (opcode == `OP_JALR)?   {jr_target[`PC_WIDTH-1 : 1], 1'b0}          :   jr_target[`PC_WIDTH-1 : 0];

assign predt_br_success =   ((if_predt_br_taken && br_taken_tmp) && (pc == br_addr_tmp)) || (!if_predt_br_taken && !br_taken_tmp);
assign predt_br_error   =   (if_predt_br_taken && !br_taken_tmp) || (!if_predt_br_taken && br_taken_tmp);

assign br_taken         =   predt_br_error;
assign br_addr          =   (if_predt_br_taken && !br_taken_tmp)?   if_pc + 4   :
                            (!if_predt_br_taken && br_taken_tmp)?   br_addr_tmp : `PC_WIDTH'b0;

// contral hazard, pc != br_addr
assign contral_hazard   =   (predt_br_error)? 1'b1 : 1'b0;

// mem ctrl
assign mem_op = (!if_en)? `MEM_OP_NOP :
                ((opcode == `OP_LOAD) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_LW))?  `MEM_OP_LOAD_LW     :
                ((opcode == `OP_LOAD) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_LH))?  `MEM_OP_LOAD_LH     :
                ((opcode == `OP_LOAD) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_LHU))? `MEM_OP_LOAD_LHU    :
                ((opcode == `OP_LOAD) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_LB))?  `MEM_OP_LOAD_LB     :
                ((opcode == `OP_LOAD) && (if_insn[`I_TYPE_FUNCT3] == `FUNCT3_LBU))? `MEM_OP_LOAD_LBU    :
                ((opcode == `OP_STORE) && (if_insn[`S_TYPE_FUNCT3] == `FUNCT3_SW))? `MEM_OP_SW          :
                ((opcode == `OP_STORE) && (if_insn[`S_TYPE_FUNCT3] == `FUNCT3_SH))? `MEM_OP_SH          :
                ((opcode == `OP_STORE) && (if_insn[`S_TYPE_FUNCT3] == `FUNCT3_SB))? `MEM_OP_SB          : `MEM_OP_NOP;

assign memory_we_en = ((if_en) && (if_insn[`ALL_TYPE_OPCODE] == `OP_STORE))? `ENABLE : `DISABLE;
assign memory_rd_en = ((if_en) && (if_insn[`ALL_TYPE_OPCODE] == `OP_LOAD))?  `ENABLE : `DISABLE;

assign store_byteena =  (mem_op == `MEM_OP_SW)? 4'b1111 :
                        (mem_op == `MEM_OP_SH)? 4'b0011 :
                        (mem_op == `MEM_OP_SB)? 4'b0001 : 4'b0000;

assign store_data = (opcode != `OP_STORE)?                      `WORD_WIDTH'b0              :
                    (if_insn[`S_TYPE_FUNCT3] == `FUNCT3_SW)?    rs2_data                    :
                    (if_insn[`S_TYPE_FUNCT3] == `FUNCT3_SH)?    {16'b0, rs2_data[15 : 0]}   :
                    (if_insn[`S_TYPE_FUNCT3] == `FUNCT3_SB)?    {24'b0, rs2_data[7 : 0]}    : `WORD_WIDTH'b0;

// load hazard, forwarding

assign rs1_data =   (gpr_rd_addr_0 == `GPR_ADDR_WIDTH'b0                        )?  `WORD_WIDTH'b0      :   // resd x0 register in gpr
                    (csr2gpr_in_id_ex && (id_dst_addr == gpr_rd_addr_0)         )?  id_csr_to_gpr_data  :   // forwarding from id_csr
                    (alu2gpr_in_id_ex && (id_dst_addr == gpr_rd_addr_0)         )?  alu_out             :   // forwarding from alu
                    (csr2gpr_in_ex_mem && (ex_dst_addr == gpr_rd_addr_0)        )?  ex_csr_to_gpr_data  :   // forwarding from ex_csr
                    (alu2gpr_in_ex_mem && (ex_dst_addr == gpr_rd_addr_0)        )?  ex_alu_out          :   // forwarding from ex_alu
                    (load_after_storing_en && (id_dst_addr == gpr_rd_addr_0)    )?  ex_store_data       :   // forwarding from mem_store_data
                    (loading_after_store_en && (ex_dst_addr == gpr_rd_addr_0)   )?  prev_ex_store_data  :   // forwarding from wb_stroe_data
                                                                                    gpr_rd_data_0;

assign rs2_data =   (gpr_rd_addr_1 == `GPR_ADDR_WIDTH'b0                        )?  `WORD_WIDTH'b0      :
                    (csr2gpr_in_id_ex && (id_dst_addr == gpr_rd_addr_1)         )?  id_csr_to_gpr_data  :
                    (alu2gpr_in_id_ex && (id_dst_addr == gpr_rd_addr_1)         )?  alu_out             :
                    (csr2gpr_in_ex_mem && (ex_dst_addr == gpr_rd_addr_1)        )?  ex_csr_to_gpr_data  :   
                    (alu2gpr_in_ex_mem && (ex_dst_addr == gpr_rd_addr_1)        )?  ex_alu_out          :
                    (load_after_storing_en && (id_dst_addr == gpr_rd_addr_1)    )?  ex_store_data       :
                    (loading_after_store_en && (ex_dst_addr == gpr_rd_addr_1)   )?  prev_ex_store_data  : gpr_rd_data_1;

// rs1 rs2 data valid
assign rs1_data_valid = (  gpr_rd_addr_0 == `GPR_ADDR_WIDTH'b0                                              ) ||
                        (!(load_in_id_ex  && (id_dst_addr == gpr_rd_addr_0) && !(load_after_storing_en))  &&
                         !(load_in_ex_mem && (ex_dst_addr == gpr_rd_addr_0) && !(loading_after_store_en))   );

assign rs2_data_valid = (  gpr_rd_addr_1 == `GPR_ADDR_WIDTH'b0                                              ) ||
                        (!(load_in_id_ex  && (id_dst_addr == gpr_rd_addr_1) && !(load_after_storing_en) ) &&
                         !(load_in_ex_mem && (ex_dst_addr == gpr_rd_addr_1) && !(loading_after_store_en))   );

// The load_op in id-ex takes 2 cycles before spm_rd_data load to gpr
// if-reg stall, id-reg flush(otherwise error gpr data to id_reg)
assign load_hazard_in_id_ex =  if_en && (gpr_rd_en == `GPR_READ) && load_in_id_ex && !load_after_storing_en && // not store in mem-stage
                               ((id_dst_addr == gpr_rd_addr_0) || (id_dst_addr == gpr_rd_addr_1));

// The load_op in ex-id takes 1 cycles before spm_rd_data load to gpr
// if-reg stall, id-reg flush(otherwise error gpr data to id_reg)
assign load_hazard_in_ex_mem =  if_en && (gpr_rd_en == `GPR_READ) && load_in_ex_mem && !loading_after_store_en && //(store -> load ->  ...    ->  read gpr)
                                ((ex_dst_addr == gpr_rd_addr_0) || (ex_dst_addr == gpr_rd_addr_1));


endmodule
`endif