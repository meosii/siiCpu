`ifndef siicpu_decoder
`define siicpu_decoder

module decoder (
    //from if
    input wire [`DATA_WIDTH_INSN - 1:0] if_insn,
    input wire [`WORD_ADDR_BUS] if_pc,
    //to gpr
    output reg [$clog2(`DATA_HIGH_GPR) - 1:0] gpr_rd_addr_0,
    output reg [$clog2(`DATA_HIGH_GPR) - 1:0] gpr_rd_addr_1,
    output reg [$clog2(`DATA_HIGH_GPR) - 1:0] dst_addr,
    output reg gpr_we_,
    //from gpr
    input wire [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_0,
    input wire [`DATA_WIDTH_GPR - 1:0] gpr_rd_data_1,
    //to alu
    output reg [`DATA_WIDTH_ALU_OP - 1:0] alu_op,
    output reg [`DATA_WIDTH_GPR - 1:0] alu_in_0,
    output reg [`DATA_WIDTH_GPR - 1:0] alu_in_1,
    //to "break"
    output reg [`WORD_ADDR_BUS] br_addr,
    output reg br_taken,
    //to mem
    output reg [`DATA_WIDTH_MEM_OP - 1:0] mem_op,
    output reg [`DATA_WIDTH_GPR - 1:0] gpr_data,
    //to "ctrl"
    output reg [`DATA_WIDTH_CTRL_OP - 1:0] ctrl_op,
    output reg [`DATA_WIDTH_ISA_EXP - 1:0] exp_code

);

wire [`DATA_WIDTH_OPCODE - 1:0] opcode;
reg [`WORD_ADDR_BUS] br_target; //BRANCH
reg [`WORD_ADDR_BUS] jr_offset; //JAL/JALR
reg [`WORD_ADDR_BUS] jr_target;

assign opcode = if_insn[`DATA_WIDTH_OPCODE - 1:0];
wire signed [`DATA_WIDTH_GPR - 1:0] s_gpr_rd_data_0 = $signed(gpr_rd_data_0);
wire signed [`DATA_WIDTH_GPR - 1:0] s_gpr_rd_data_1 = $signed(gpr_rd_data_1);
reg [31:0] imm;
reg signed [31:0] store_data;

always @* begin
    alu_op = `ALU_OP_NOP; //default, not initial, every cycle
    alu_in_0 = gpr_rd_data_0;
    alu_in_1 = gpr_rd_data_1;
    br_taken = 1'b0;
    br_addr = `WORD_ADDR_WIDTH'b0;
    mem_op = `MEM_OP_NOP;
    ctrl_op = `CTRL_OP_NOP;
    dst_addr = 0;
    gpr_we_ = 1'b1; // not write to gpr
    exp_code = `ISA_EXP_NO_EXP;
    case (opcode)
        `OP_IMM: begin
            if (if_insn[31] == 1) begin //The immediate number is sign extended to XLEN bits
                imm = {20'b1111_1111_1111_1111_1111,if_insn[31:20]};
            end else begin
                imm = {20'b0000_0000_0000_0000_0000,if_insn[31:20]};
            end
            alu_in_0 = $signed(imm);
            gpr_rd_addr_0 = if_insn[19:15];
            dst_addr = if_insn[11:7];
            gpr_we_ = 1'b0; // Have the signal of "dst_addr": need write
            case (if_insn[14:12])
                `FUNCT3_ADDI: begin //rd = ra + imm
                    alu_op = `ALU_OP_ADDI;
                    alu_in_1 = s_gpr_rd_data_0;
                end
                `FUNCT3_SLTI: begin //rd = (ra < imm)?1:0
                    alu_op = `ALU_OP_SLTI;
                    alu_in_1 = s_gpr_rd_data_0;
                end
                `FUNCT3_SLTIU: begin //rd = (ra < imm)?1:0 
                    alu_in_0 = $unsigned(imm); //The immediate number is sign extended to XLEN bits 
                                               //and then treated as an unsigned number.
                    alu_op = `ALU_OP_SLTIU;
                    alu_in_1 = gpr_rd_data_0;
                end
                `FUNCT3_ANDI: begin //rd = ra & imm
                    alu_op = `ALU_OP_ANDI;
                    alu_in_1 = s_gpr_rd_data_0;
                end
                `FUNCT3_ORI: begin //rd = ra | imm
                    alu_op = `ALU_OP_ORI;
                    alu_in_1 = s_gpr_rd_data_0;
                end
                `FUNCT3_XORI: begin //rd = ra ˆ imm
                    alu_op = `ALU_OP_XORI;
                    alu_in_1 = s_gpr_rd_data_0;
                end
                `FUNCT3_SLLI: begin //rd = ra << imm[0:4]
                    alu_op = `ALU_OP_SLLI;
                    alu_in_1 = gpr_rd_data_0;
                end
                `FUNCT3_SRLI_SRAI: begin //rd = ra >> imm[0:4]
                    if (if_insn[31:25] == 7'b0000000) begin
                        alu_op = `ALU_OP_SRLI; 
                        alu_in_0 = $unsigned(alu_in_0);
                        alu_in_1 = gpr_rd_data_0;
                    end else if (if_insn[31:25] == 7'b0100000) begin
                        alu_op = `ALU_OP_SRAI;
                        alu_in_1 = s_gpr_rd_data_0;
                    end else begin
                        alu_op = `ALU_OP_NOP;
                        exp_code = `ISA_EXP_UNDEF_INSN;
                    end
                end
                default: begin
                    alu_op = `ALU_OP_NOP;
                    exp_code = `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP_LUI: begin //load upper immediate
            alu_op = `ALU_OP_LUI;
            alu_in_0 = {12'b0,if_insn[31:12]};
            dst_addr = if_insn[11:7]; //rd = imm << 12
            gpr_we_ = 1'b0;
        end
        `OP_AUIPC: begin //add upper immediate to pc
            alu_op = `ALU_OP_AUIPC;
            alu_in_0 = {12'b0,if_insn[31:12]};
            alu_in_1 = if_pc;
            dst_addr = if_insn[11:7]; //rd = PC + (imm << 12)
            gpr_we_ = 1'b0;
        end
        `OP: begin
            gpr_rd_addr_0 = if_insn[19:15];
            gpr_rd_addr_1 = if_insn[24:20];
            dst_addr = if_insn[11:7];
            gpr_we_ = 1'b0;
            case (if_insn[31:25])
                7'b0000000: begin
                    case (if_insn[14:12])
                        `FUNCT3_ADD: begin //performs the addition of ra and rb
                            alu_op = `ALU_OP_ADD; //rd = ra + rb
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        `FUNCT3_SLT: begin //perform signed compares, writing 1 to rd if ra < rb, 0 otherwise.
                            alu_op = `ALU_OP_SLT; //rd = (ra < rb)?1:0
                            alu_in_0 = s_gpr_rd_data_0;
                            alu_in_1 = s_gpr_rd_data_1;
                        end
                        `FUNCT3_SLTU: begin //perform unsigned compares, writing 1 to rd if ra < rb, 0 otherwise.
                            alu_op = `ALU_OP_SLTU; //rd = (ra < rb)?1:0
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        `FUNCT3_AND: begin //perform AND bitwise logical operations.
                            alu_op = `ALU_OP_AND; //rd = ra & rb
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        `FUNCT3_OR: begin //perform OR bitwise logical operations.
                            alu_op = `ALU_OP_OR; //rd = ra | rb
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        `FUNCT3_XOR: begin //perform XOR bitwise logical operations.
                            alu_op = `ALU_OP_XOR; //rd = ra ˆ rb
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        `FUNCT3_SLL: begin //perform logical left shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op = `ALU_OP_SLL; //rd = ra << rb[4:0]
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        `FUNCT3_SRL: begin // logical right shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op = `ALU_OP_SRL; //rd = ra >> rb[4:0]
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        default: begin
                            alu_op = `ALU_OP_NOP;
                            exp_code = `ISA_EXP_UNDEF_INSN;
                        end
                    endcase
                end
                7'b0100000: begin
                    case (if_insn[14:12])
                        `FUNCT3_SUB: begin //performs the subtraction of rb from ra.
                            alu_op = `ALU_OP_SUB; //rd = ra - rb
                            alu_in_0 = gpr_rd_data_0;
                            alu_in_1 = gpr_rd_data_1;
                        end
                        `FUNCT3_SRA: begin //arithmetic right shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op = `ALU_OP_SRA; //rd = ra >> rb
                            alu_in_0 = s_gpr_rd_data_0;
                            alu_in_1 = s_gpr_rd_data_1;
                        end
                        default: begin
                            alu_op = `ALU_OP_NOP;
                            exp_code = `ISA_EXP_UNDEF_INSN;
                        end
                    endcase
                end
                default: begin
                    alu_op = `ALU_OP_NOP;
                    exp_code = `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP_JAL: begin //jump and link; rd = PC+4; PC += imm
            jr_offset = {if_insn[31],if_insn[19:12],if_insn[20],if_insn[30:21],1'b0}; //Lowest bit setting 0,realize signed offset for multiples of 2
            if (if_insn[31] == 1) begin
                jr_target = if_pc - jr_offset[19:0];
            end else begin
                jr_target = if_pc + jr_offset[19:0];
            end
            br_addr = jr_target;
            br_taken = 1'b1;
            gpr_we_ = 1'b0;
            alu_op = `ALU_OP_ADD; //rd = pc + 4
            alu_in_0 = if_pc;
            alu_in_1 = 4;
            dst_addr = if_insn[11:7];
        end
        `OP_JALR: begin //jump and link register; rd = PC+4; PC = ra + imm
            gpr_we_ = 1'b0;
            gpr_rd_addr_0 = if_insn[19:15];
            if (if_insn[31] == 1) begin
                jr_target = gpr_rd_data_0 - if_insn[30:20];
            end else begin
                jr_target = gpr_rd_data_0 + if_insn[30:20];
            end
            br_addr = {jr_target[`WORD_ADDR_WIDTH - 1:1],1'b0};
            br_taken = 1'b1;
            alu_op = `ALU_OP_ADD; //rd = pc + 4
            alu_in_0 = if_pc;
            alu_in_1 = 4;
            dst_addr = if_insn[11:7];
        end
        `OP_BRANCH: begin
            gpr_rd_addr_0 = if_insn[19:15];
            gpr_rd_addr_1 = if_insn[24:20];
            imm = {if_insn[31],if_insn[7],if_insn[30:25],if_insn[11:8],1'b0};
            if (if_insn[31] == 1) begin
                br_target = if_pc - imm[11:0];
            end else begin
                br_target = if_pc + imm[11:0];
            end
            br_addr = br_target;
            case (if_insn[14:12])
                `FUNCT3_BEQ: begin //branch if equal
                    br_taken = (gpr_rd_data_0 == gpr_rd_data_1)? 1'b1:1'b0;
                end
                `FUNCT3_BNE: begin //branch if not equal
                    br_taken = (gpr_rd_data_0 != gpr_rd_data_1)? 1'b1:1'b0;
                end
                `FUNCT3_BLT: begin //branch if less than
                    br_taken = (s_gpr_rd_data_0 < s_gpr_rd_data_1)? 1'b1:1'b0;
                end
                `FUNCT3_BLTU: begin //branch if less than，unsigned
                    br_taken = (gpr_rd_data_0 < gpr_rd_data_1)? 1'b1:1'b0;
                end
                `FUNCT3_BGE: begin //branch if greater than or equal
                    br_taken = (s_gpr_rd_data_0 >= s_gpr_rd_data_1)? 1'b1:1'b0;
                end
                `FUNCT3_BGEU: begin //branch if greater than or equal，unsigned
                    br_taken = (gpr_rd_data_0 >= gpr_rd_data_1)? 1'b1:1'b0;
                end
                default: br_taken = 1'b0;
            endcase
        end
        `OP_LOAD: begin //Loads copy a value from memory to register rd
            gpr_we_ = 1'b0;
            gpr_rd_addr_1 = if_insn[19:15]; 
            if (if_insn[31] == 1) begin
                alu_op = `ALU_OP_SUB;
                alu_in_0 = gpr_rd_data_1;
                alu_in_1 = if_insn[30:20]; //imm = $signed(if_insn[31:20]);
            end else begin
                alu_op = `ALU_OP_ADD;
                alu_in_0 = gpr_rd_data_1;
                alu_in_1 = if_insn[30:20];
            end // "alu_out" is the  effective address in memory
            dst_addr = if_insn[11:7];
            case (if_insn[14:12])
                `FUNCT3_LW: begin // loads a 32-bit value from memory into rd
                    mem_op = `MEM_OP_LOAD_LW; //rd = M[ra+imm][0:31]
                end
                `FUNCT3_LH: begin //loads a 16-bit value from memory, then sign-extends to 32-bits before storing in rd.
                    mem_op = `MEM_OP_LOAD_LH; //rd = M[ra+imm][0:15]
                end
                `FUNCT3_LHU: begin
                    mem_op = `MEM_OP_LOAD_LHU; //rd = M[ra+imm][0:15] 
                end
                `FUNCT3_LB: begin
                    mem_op = `MEM_OP_LOAD_LB; //rd = M[ra+imm][0:7]
                end
                `FUNCT3_LBU: begin
                    mem_op = `MEM_OP_LOAD_LBU; //rd = M[ra+imm][0:7] 
                end
                default: begin
                    mem_op = `MEM_OP_NOP;
                    exp_code = `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP_STORE: begin // Stores copy the value in register rb to memory.
            mem_op = `MEM_OP_STORE;
            imm = {if_insn[31:25],if_insn[11:7]};
            gpr_rd_addr_0 = if_insn[19:15];
            if (if_insn[31] == 1) begin
                alu_op = `ALU_OP_SUB;
                alu_in_0 = gpr_rd_data_0;
                alu_in_1 = imm[10:0]; //imm = {if_insn[31:25],if_insn[11:7]};
            end else begin
                alu_op = `ALU_OP_ADD;
                alu_in_0 = gpr_rd_data_0;
                alu_in_1 = imm[10:0];
            end // "alu_out" is the  effective address in memory
            gpr_rd_addr_1 = if_insn[24:20]; //rb
            case (if_insn[14:12])
                `FUNCT3_SW: begin // store 32-bit values from the low bits of register rb to memory.
                    gpr_data = gpr_rd_data_1; //M[ra+imm][0:31] = rb[0:31]
                end
                `FUNCT3_SH: begin // store 16-bit values from the low bits of register rb to memory.
                    if (gpr_rd_data_1[15] == 1) begin
                        store_data = {16'b1111_1111_1111_1111,gpr_rd_data_1[15:0]};
                    end else begin
                        store_data = {16'b0000_0000_0000_0000,gpr_rd_data_1[15:0]};
                    end
                    gpr_data = $signed(store_data); //M[ra+imm][0:15] = rb[0:15]
                end
                `FUNCT3_SB: begin // store 8-bit values from the low bits of register rb to memory.
                    if (gpr_rd_data_1[7] == 1) begin
                        store_data = {24'b1111_1111_1111_1111_1111_1111,gpr_rd_data_1[7:0]};
                    end else begin
                        store_data = {24'b0000_0000_0000_0000_0000_0000,gpr_rd_data_1[7:0]};
                    end
                    gpr_data = $signed(store_data); //M[ra+imm][0:7] = rb[0:7]
                end
            default: gpr_data = 0;
            endcase
        end
        // `OP_MISC_MEM: begin
            
        // end
        // `OP_SYSTEM: begin
            
        // end
        default: begin
            alu_op = `ALU_OP_NOP;
            mem_op = `MEM_OP_NOP;
            ctrl_op = `CTRL_OP_NOP;
            exp_code = `ISA_EXP_UNDEF_INSN;
        end
    endcase
end

endmodule

`endif