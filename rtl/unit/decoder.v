`ifndef SIICPU_DECODER
`define SIICPU_DECODER
`include "define.v"
module decoder (
    input wire [`PC_WIDTH-1 : 0]                pc, // pc = (if_pc + 4) or br_addr
    //from if
    input wire                                  if_en,
    input wire [`PC_WIDTH-1 : 0]                if_pc,
    input wire [`WORD_WIDTH - 1 : 0]            if_insn,
    //to gpr
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        gpr_rd_addr_0,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        gpr_rd_addr_1,
    output reg [`GPR_ADDR_WIDTH - 1 : 0]        dst_addr,
    output reg                                  gpr_we_,
    //from gpr
    input wire [`WORD_WIDTH - 1 : 0]            gpr_rd_data_0,
    input wire [`WORD_WIDTH - 1 : 0]            gpr_rd_data_1,
    //to alu
    output reg [`DATA_WIDTH_ALU_OP - 1 : 0]     alu_op,
    output reg [`WORD_WIDTH - 1 : 0]            alu_in_0,
    output reg [`WORD_WIDTH - 1 : 0]            alu_in_1,
    //to pc
    output reg [`PC_WIDTH-1 : 0]                br_addr,
    output reg                                  br_taken,
    //to mem
    output reg [`DATA_WIDTH_MEM_OP - 1 : 0]     mem_op,
    output reg [`WORD_WIDTH - 1 : 0]            store_data,
    output wire [3 : 0]                         store_byteena,

    // forwarding
    // EX data
    input wire                                  id_en,
    input wire [`WORD_WIDTH - 1 : 0]            id_insn,
    input wire                                  id_gpr_we_,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        id_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]            alu_out,
    // MEM data
    input wire                                  ex_en,
    input wire [`WORD_WIDTH - 1 : 0]            ex_insn,
    input wire                                  ex_gpr_we_,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]        ex_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]            ex_alu_out,
    input wire                                  mem_we_en,
    input wire                                  load_after_store_en,
    input wire [`WORD_WIDTH - 1 : 0]            ex_store_data,
    input wire [`WORD_WIDTH - 1 : 0]            prev_ex_store_data,
    
    // exception
    output reg [`DATA_WIDTH_ISA_EXP - 1 : 0]    exp_code,
    // load hazard
    output wire                                 load_hazard_in_id_ex,
    output wire                                 load_hazard_in_ex_mem,
    // contral hazard
    output wire                                 contral_hazard
);

localparam SIGN_PC_WIDTH = `PC_WIDTH + 1;

wire        [`ALL_TYPE_OPCODE]          opcode;
reg         [`WORD_WIDTH - 1 : 0]       ra_data;
reg         [`WORD_WIDTH - 1 : 0]       rb_data;
wire                                    ra_data_valid;
wire                                    rb_data_valid;
reg         [`PC_WIDTH : 0]             jr_target;
reg         [`WORD_WIDTH - 1 : 0]       imm;
reg                                     gpr_rd_en;

assign opcode = if_insn[`ALL_TYPE_OPCODE];

always @(*) begin
    case(opcode)
        `OP_IMM,`OP_JALR,`OP_LOAD: begin
            gpr_we_         = `WRITE;
            gpr_rd_en       = `READ;
            gpr_rd_addr_0   = if_insn[`I_TYPE_RS1];
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = if_insn[`I_TYPE_RD];
            imm             = {{20{if_insn[`INSN_MSB]}}, if_insn[`I_TYPE_IMM]};
        end
        `OP_LUI,`OP_AUIPC: begin
            gpr_we_         = `WRITE;
            gpr_rd_en       = `DISABLE;
            gpr_rd_addr_0   = `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = if_insn[`U_TYPE_RD];
            imm             = {if_insn[`U_TYPE_IMM], 12'b0};
        end
        `OP: begin
            gpr_we_         = `WRITE;
            gpr_rd_en       = `READ;
            gpr_rd_addr_0   = if_insn[`R_TYPE_RS1];
            gpr_rd_addr_1   = if_insn[`R_TYPE_RS2];
            dst_addr        = if_insn[`R_TYPE_RD];
            imm             = `WORD_WIDTH'b0;
        end
        `OP_JAL: begin
            gpr_we_         = `WRITE;
            gpr_rd_en       = `DISABLE;
            gpr_rd_addr_0   = `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = if_insn[`J_TYPE_RD];
            imm             = {{12{if_insn[`J_TYPE_IMM_20]}}, if_insn[`J_TYPE_IMM_19_12], if_insn[`J_TYPE_IMM_11], if_insn[`J_TYPE_IMM_10_1], 1'b0};
        end
        `OP_BRANCH: begin
            gpr_we_         = `READ;
            gpr_rd_en       = `READ;
            gpr_rd_addr_0   = if_insn[`B_TYPE_RS1];
            gpr_rd_addr_1   = if_insn[`B_TYPE_RS2];
            dst_addr        = `GPR_ADDR_WIDTH'b0;
            imm             = {{20{if_insn[`B_TYPE_IMM_12]}}, if_insn[`B_TYPE_IMM_11], if_insn[`B_TYPE_IMM_10_5], if_insn[`B_TYPE_IMM_4_1], 1'b0 };
        end
        `OP_STORE: begin
            gpr_we_         = `READ;
            gpr_rd_en       = `READ;
            gpr_rd_addr_0   = if_insn[`S_TYPE_RS1];
            gpr_rd_addr_1   = if_insn[`S_TYPE_RS2];
            dst_addr        = `GPR_ADDR_WIDTH'b0;
            imm             = {{20{if_insn[`S_TYPE_IMM_11]}}, if_insn[`S_TYPE_IMM_11_5], if_insn[`S_TYPE_IMM_4_0]};
        end
        `OP_SYSTEM: begin
            gpr_we_         = `READ;
            gpr_rd_en       = `DISABLE;
            gpr_rd_addr_0   = `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = `GPR_ADDR_WIDTH'b0;
            imm             = `WORD_WIDTH'b0;
        end
        default: begin
            gpr_we_         = `READ;
            gpr_rd_en       = `DISABLE;
            gpr_rd_addr_0   = `GPR_ADDR_WIDTH'b0;
            gpr_rd_addr_1   = `GPR_ADDR_WIDTH'b0;
            dst_addr        = `GPR_ADDR_WIDTH'b0;
            imm             = `WORD_WIDTH'b0;
        end
    endcase
end

always @* begin
    alu_in_0    =   `WORD_WIDTH'b0;
    alu_in_1    =   `WORD_WIDTH'b0;
    case (opcode)
        `OP_IMM: begin
            alu_in_0    =   imm;
            alu_in_1    =   ra_data;
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
            alu_in_0    =   ra_data;
            alu_in_1    =   rb_data;
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
            alu_in_0    =   ra_data;
            alu_in_1    =   imm;
        end
        `OP_STORE: begin
            alu_in_0    =   ra_data;
            alu_in_1    =   imm;
        end
        default: begin
            alu_in_0    =   `WORD_WIDTH'b0;
            alu_in_1    =   `WORD_WIDTH'b0;
        end
    endcase
end

always @* begin
    alu_op      =   `ALU_OP_NOP;
    case (opcode)
        `OP_IMM: begin
            case (if_insn[`I_TYPE_FUNCT3])
                `FUNCT3_ADDI: begin //rd = ra(alu_1) + imm(alu_0)
                    alu_op      =   `ALU_OP_ADDI;
                end
                `FUNCT3_SLTI: begin //rd = ($signed(ra) < $signed(imm))?1:0
                    alu_op      =   `ALU_OP_SLTI;
                end
                `FUNCT3_SLTIU: begin //rd = (ra < imm)?1:0
                    alu_op      =   `ALU_OP_SLTIU;
                end
                `FUNCT3_ANDI: begin //rd = ra & imm
                    alu_op      =   `ALU_OP_ANDI;
                end
                `FUNCT3_ORI: begin //rd = ra | imm
                    alu_op      =   `ALU_OP_ORI;
                end
                `FUNCT3_XORI: begin //rd = ra ˆ imm
                    alu_op      =   `ALU_OP_XORI;
                end
                `FUNCT3_SLLI: begin //rd = ra << imm[4:0]
                    alu_op      =   `ALU_OP_SLLI;
                end
                `FUNCT3_SRLI_SRAI: begin
                    if (if_insn[`I_TYPE_IMM_11_5] == 7'b0000000) begin
                        alu_op      =   `ALU_OP_SRLI; // logical right shift
                    end else if (if_insn[`I_TYPE_IMM_11_5] == 7'b0100000) begin
                        alu_op      =   `ALU_OP_SRAI; // arithmetic right shift
                    end else begin
                        alu_op      =   `ALU_OP_NOP;
                    end
                end
                default: begin
                    alu_op      =   `ALU_OP_NOP;
                end
            endcase
        end
        `OP_LUI: begin //load upper immediate
            alu_op      =   `ALU_OP_LUI;
        end
        `OP_AUIPC: begin //add upper immediate to pc
            alu_op      =   `ALU_OP_AUIPC;
        end
        `OP: begin
            case (if_insn[`R_TYPE_FUNCT7])
                7'b0000000: begin
                    case (if_insn[`R_TYPE_FUNCT3])
                        `FUNCT3_ADD: begin //performs the addition of ra and rb
                            alu_op      =   `ALU_OP_ADD; //rd = ra + rb
                        end
                        `FUNCT3_SLT: begin //perform signed compares, writing 1 to rd if ra < rb, 0 otherwise.
                            alu_op      =   `ALU_OP_SLT; //rd = (ra < rb)?1:0
                        end
                        `FUNCT3_SLTU: begin //perform unsigned compares, writing 1 to rd if ra < rb, 0 otherwise.
                            alu_op      =   `ALU_OP_SLTU; //rd = (ra < rb)?1:0
                        end
                        `FUNCT3_AND: begin //perform AND bitwise logical operations.
                            alu_op      =   `ALU_OP_AND; //rd = ra & rb
                        end
                        `FUNCT3_OR: begin //perform OR bitwise logical operations.
                            alu_op      =   `ALU_OP_OR; //rd = ra | rb
                        end
                        `FUNCT3_XOR: begin //perform XOR bitwise logical operations.
                            alu_op      =   `ALU_OP_XOR; //rd = ra ˆ rb
                        end
                        `FUNCT3_SLL: begin //perform logical left shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op      =   `ALU_OP_SLL; //rd = ra << rb[4:0]
                        end
                        `FUNCT3_SRL: begin // logical right shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op      =   `ALU_OP_SRL; //rd = ra >> rb[4:0]
                        end
                        default: begin
                            alu_op      =   `ALU_OP_NOP;
                        end
                    endcase
                end
                7'b0100000: begin
                    case (if_insn[`R_TYPE_FUNCT3])
                        `FUNCT3_SUB: begin //performs the subtraction of rb from ra.
                            alu_op      =   `ALU_OP_SUB; //rd = ra - rb
                        end
                        `FUNCT3_SRA: begin //arithmetic right shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op      =   `ALU_OP_SRA; //rd = ra >> rb
                        end
                        default: begin
                            alu_op      =   `ALU_OP_NOP;
                        end
                    endcase
                end
                default: begin
                    alu_op =  `ALU_OP_NOP;
                end
            endcase
        end
        `OP_JAL: begin
            alu_op = `ALU_OP_ADD; //rd = pc + 4
        end
        `OP_JALR: begin //rd = PC+4; PC = ra + imm
            alu_op =  `ALU_OP_ADD; //rd = pc + 4
        end
        `OP_BRANCH: begin
            alu_op  =   `ALU_OP_NOP;
        end
        `OP_LOAD: 
            alu_op  =   `ALU_OP_ADD;
        `OP_STORE: begin
            alu_op  =   `ALU_OP_ADD;
        end
        default: begin
            alu_op  =   `ALU_OP_NOP;
        end
    endcase
end

always @* begin
    exp_code    =   `ISA_EXP_NO_EXP;
    case (opcode)
        `OP_IMM: begin
            case (if_insn[`I_TYPE_FUNCT3])
                `FUNCT3_ADDI,`FUNCT3_SLTI,`FUNCT3_SLTIU,`FUNCT3_ANDI,`FUNCT3_ORI,`FUNCT3_XORI,`FUNCT3_SLLI: begin
                    exp_code    =   `ISA_EXP_NO_EXP;
                end
                `FUNCT3_SRLI_SRAI: begin
                    if ((if_insn[`I_TYPE_IMM_11_5] == 7'b0000000) || (if_insn[`I_TYPE_IMM_11_5] == 7'b0100000)) begin
                        exp_code    =   `ISA_EXP_NO_EXP;
                    end else begin
                        exp_code    =   `ISA_EXP_UNDEF_INSN;
                    end
                end
                default: begin
                    exp_code    =   `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP: begin
            case (if_insn[`R_TYPE_FUNCT7])
                7'b0000000: begin
                    case (if_insn[`R_TYPE_FUNCT3])
                        `FUNCT3_ADD,`FUNCT3_SLT,`FUNCT3_SLTU,`FUNCT3_AND,`FUNCT3_OR,`FUNCT3_XOR,`FUNCT3_SLL,`FUNCT3_SRL: begin 
                            exp_code    =   `ISA_EXP_NO_EXP;
                        end
                        default: begin
                            exp_code    =   `ISA_EXP_UNDEF_INSN;
                        end
                    endcase
                end
                7'b0100000: begin
                    case (if_insn[`R_TYPE_FUNCT3])
                        `FUNCT3_SUB,`FUNCT3_SRA: begin
                            exp_code    =   `ISA_EXP_NO_EXP;
                        end
                        default: begin
                            exp_code    =   `ISA_EXP_UNDEF_INSN;
                        end
                    endcase
                end
                default: begin
                    exp_code    =   `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP_LUI,`OP_AUIPC,`OP_JAL,`OP_JALR,`OP_BRANCH,`OP_LOAD,`OP_STORE: begin
            exp_code    =   `ISA_EXP_NO_EXP;
        end
        default: begin
            exp_code    =   `ISA_EXP_UNDEF_INSN	;
        end
    endcase
end

always @* begin
    br_taken    =   1'b0;
    jr_target   =   {SIGN_PC_WIDTH{1'b0}};
    br_addr     =   `PC_WIDTH'b0;
    case (opcode)
        `OP_JAL: begin //jump and link; rd = PC + 4; PC += imm
            //Lowest bit setting 0,realize signed offset for multiples of 2
            br_taken    =   1'b1;
            jr_target   =   $signed({1'b0,if_pc}) + $signed(imm);
            br_addr     =   jr_target[`PC_WIDTH-1 : 0];
        end
        `OP_JALR: begin //jump and link register; rd = PC+4; PC = ra + imm
            br_taken    =   (ra_data_valid)? 1'b1 : 1'b0;
            jr_target   =   $signed({1'b0,ra_data}) + $signed(imm);
            br_addr     =   {jr_target[`PC_WIDTH-1 : 1], 1'b0 };
        end
        `OP_BRANCH: begin
            jr_target   =   $signed({1'b0, if_pc}) + $signed(imm[11 : 0]);
            br_addr     =   jr_target[`PC_WIDTH-1 : 0];
            case (if_insn[`B_TYPE_FUNCT3])
                `FUNCT3_BEQ: begin      //branch if equal
                    br_taken =  ((ra_data == rb_data) && ra_data_valid && rb_data_valid) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BNE: begin      //branch if not equal
                    br_taken =  ((ra_data != rb_data) && ra_data_valid && rb_data_valid) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BLT: begin      //branch if less than
                    br_taken =  (($signed(ra_data) < $signed(rb_data)) && ra_data_valid && rb_data_valid) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BLTU: begin      //branch if less than，unsigned
                    br_taken =  ((ra_data < rb_data) && ra_data_valid && rb_data_valid) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BGE: begin      //branch if greater than or equal
                    br_taken =  (($signed(ra_data) >= $signed(rb_data)) && ra_data_valid && rb_data_valid) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BGEU: begin     //branch if greater than or equal，unsigned
                    br_taken =  ((ra_data >= rb_data) && ra_data_valid && rb_data_valid) ? 1'b1 : 1'b0;
                end
                default: br_taken = 1'b0;
            endcase
        end
        default: begin
            br_taken    =   1'b0;
            jr_target   =   `PC_WIDTH'b0;
            br_addr     =   `PC_WIDTH'b0;
        end
    endcase
end

always @* begin
    mem_op = `MEM_OP_NOP;
    case (opcode)
        `OP_LOAD: begin
            case (if_insn[`I_TYPE_FUNCT3])
                `FUNCT3_LW: begin                   // loads a 32-bit value from memory into rd
                    mem_op      = `MEM_OP_LOAD_LW;  //rd = M[ra+imm][0:31]
                end
                `FUNCT3_LH: begin                   //loads a 16-bit value from memory, then sign-extends to 32-bits before storing in rd.
                    mem_op      = `MEM_OP_LOAD_LH;  //rd = M[ra+imm][0:15]
                end
                `FUNCT3_LHU: begin
                    mem_op      = `MEM_OP_LOAD_LHU; //rd = M[ra+imm][0:15] 
                end
                `FUNCT3_LB: begin
                    mem_op      = `MEM_OP_LOAD_LB;  //rd = M[ra+imm][0:7]
                end
                `FUNCT3_LBU: begin
                    mem_op      = `MEM_OP_LOAD_LBU; //rd = M[ra+imm][0:7] 
                end
                default: begin
                    mem_op      = `MEM_OP_NOP;
                end
            endcase
        end
        `OP_STORE: begin
            case (if_insn[`S_TYPE_FUNCT3])
                `FUNCT3_SW: begin               // WORD: store 32-bit values from register rb to memory.
                    mem_op  =   `MEM_OP_SW;     // M[ra+imm][31:0] = rb[31:0]
                end
                `FUNCT3_SH: begin               // HALF_WORRD: store 16-bit values from the low bits of rb to memory.
                    mem_op  =   `MEM_OP_SH;     // M[ra+imm][0:15] = rb[0:15]
                end
                `FUNCT3_SB: begin               // BYTE: store 8-bit
                    mem_op  =   `MEM_OP_SB;     // M[ra+imm][0:7] = rb[0:7]
                end
                default: mem_op = `MEM_OP_NOP;
            endcase
        end
        default: begin
            mem_op = `MEM_OP_NOP;
        end
    endcase
end

assign store_byteena =  (mem_op == `MEM_OP_SW)? 4'b1111 :
                        (mem_op == `MEM_OP_SH)? 4'b0011 :
                        (mem_op == `MEM_OP_SB)? 4'b0001 : 4'b0000;

always @* begin
    case (opcode)
        `OP_STORE: begin
            case (if_insn[`S_TYPE_FUNCT3])
                `FUNCT3_SW: begin                   // WORD: store 32-bit values from register rb to memory.
                    store_data  =   rb_data;        // M[ra+imm][0:31] = rb[0:31]
                end
                `FUNCT3_SH: begin                   // HALF_WORRD: store 16-bit values from the low bits of rb to memory.
                    store_data  =   {16'b0, rb_data[15 : 0]}; // M[ra+imm][0:15] = rb[0:15]
                end
                `FUNCT3_SB: begin                   // BYTE: store 8-bit
                    store_data  =   {24'b0, rb_data[7 : 0]}; // M[ra+imm][0:7] = rb[0:7]
                end
                default: store_data = `WORD_WIDTH'b0;
            endcase
        end
        default: begin
            store_data = `WORD_WIDTH'b0;
        end
    endcase
end

// ecall and ebreak


// forwarding
always @(*) begin
    // gpr_rd_data_0
    if (gpr_rd_addr_0 == `GPR_ADDR_WIDTH'b0) begin
        ra_data = `WORD_WIDTH'b0; // highest priority-first
    end else if (id_en && (id_gpr_we_ == `WRITE) && (id_dst_addr == gpr_rd_addr_0)) begin
        if (id_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) begin
            if (ex_en && mem_we_en && (ex_alu_out == alu_out)) begin
                ra_data =  ex_store_data;  // forwarding(store -> load -> read gpr)
            end else begin
                ra_data = `WORD_WIDTH'b0; //stall
            end
        end else begin
            ra_data =  alu_out;         // writing to gpr is not yet finished, forwarding
        end
    end else if (ex_en && (ex_gpr_we_ ==`WRITE) && (ex_dst_addr == gpr_rd_addr_0)) begin
        if (ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) begin
            if (load_after_store_en) begin
                ra_data = prev_ex_store_data;  //(store->load->...->read gpr)
            end else begin
                ra_data = `WORD_WIDTH'b0;   //stall
            end
        end else begin
            ra_data = ex_alu_out;   // writing to gpr is not yet finished, forwarding
        end
    end else begin
        ra_data = gpr_rd_data_0;
    end
end

 // forwarding
always @(*) begin
    // gpr_rd_data_1
    if (gpr_rd_addr_1 == `GPR_ADDR_WIDTH'b0) begin
        rb_data = `WORD_WIDTH'b0;       // gpr[0] = 0 (x0)
    end else if (id_en && (id_gpr_we_ == `WRITE) && (id_dst_addr == gpr_rd_addr_1)) begin // read_gpr_addr = load_gpr_addr
        if (id_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) begin //ex-stage
            if (ex_en && mem_we_en && (ex_alu_out == alu_out)) begin //store_spm_addr = load_spm_addr
                rb_data = ex_store_data;   // forwarding(store->load->read gpr)
            end else begin
                rb_data = `WORD_WIDTH'b0;   // id-ex load, stall the pipeline
            end
        end else begin
            rb_data = alu_out;
        end
    end else if (ex_en && (ex_gpr_we_ == `WRITE) && (ex_dst_addr == gpr_rd_addr_1)) begin
        if (ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) begin                           // wb-stage  mem-stage ex-stage  decoder-stage
            if (load_after_store_en) begin
                rb_data = prev_ex_store_data; // ex-mem load, stall the pipeline or forwarding(store -> load ->  ...    ->  read gpr)
            end else begin
                rb_data = `WORD_WIDTH'b0;
            end
        end else begin
            rb_data = ex_alu_out;
        end
    end else begin
        rb_data = gpr_rd_data_1;
    end
end

// load hazard, stall the pipeline
// The load_op in id-ex takes 2 cycles before spm_rd_data load to gpr
// if-reg stall, id-reg flush(otherwise error gpr data to id_reg)
assign load_hazard_in_id_ex = ((gpr_rd_en == `READ) && (id_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) &&
                                id_en && (id_gpr_we_ == `WRITE) &&
                               ((id_dst_addr == gpr_rd_addr_0) || (id_dst_addr == gpr_rd_addr_1))
                               && !(ex_en && mem_we_en && (ex_alu_out == alu_out)) // not store in mem-stage
                              )? 1'b1 : 1'b0;

// The load_op in ex-id takes 1 cycles before spm_rd_data load to gpr
// if-reg stall, id-reg flush(otherwise error gpr data to id_reg)
assign load_hazard_in_ex_mem = ((gpr_rd_en == `READ) && (ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD)
                                && ex_en && (ex_gpr_we_ == `WRITE) &&
                               ((ex_dst_addr == gpr_rd_addr_0) || (ex_dst_addr == gpr_rd_addr_1))
                                && !load_after_store_en //(store -> load ->  ...    ->  read gpr)
                              )? 1'b1 : 1'b0;

// contral hazard, pc != br_addr
assign contral_hazard = (br_taken && (pc != br_addr))? 1'b1 : 1'b0;

// gpr_data valid
assign ra_data_valid =  (   ((id_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) && id_en && (id_gpr_we_ == `WRITE) &&
                              (id_dst_addr == gpr_rd_addr_0) && !(ex_en && mem_we_en && (ex_alu_out == alu_out)))
                        ||  ((ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) && ex_en && (ex_gpr_we_ == `WRITE) &&
                               ((ex_dst_addr) == gpr_rd_addr_0) && (!load_after_store_en))
                        )? 1'b0 : 1'b1;

assign rb_data_valid = (   ((id_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) && id_en && (id_gpr_we_ == `WRITE) &&
                              (id_dst_addr == gpr_rd_addr_1) && !(ex_en && mem_we_en && (ex_alu_out == alu_out)))
                        ||  ((ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) && ex_en && (ex_gpr_we_ == `WRITE) &&
                               ((ex_dst_addr) == gpr_rd_addr_1) && (!load_after_store_en))
                        )? 1'b0 : 1'b1;

endmodule
`endif