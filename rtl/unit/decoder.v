`ifndef siicpu_decoder
`define siicpu_decoder

`include "unit/define.v"
// forwarding
// pc - 4: when we have insn_register, pc is one cycle ahead of insn, 
// therefore, we should use pc - 4
module decoder (
    //from if
    input wire [`WORD_WIDTH - 1 : 0]            if_insn,
    input wire [`WORD_ADDR_BUS]                 if_pc,
    input wire                                  if_en,
    //to gpr
    output reg [$clog2(`DATA_HIGH_GPR) - 1 : 0] gpr_rd_addr_0,
    output reg [$clog2(`DATA_HIGH_GPR) - 1 : 0] gpr_rd_addr_1,
    output reg [$clog2(`DATA_HIGH_GPR) - 1 : 0] dst_addr,
    output reg                                  gpr_we_,
    //from gpr
    input wire [`WORD_WIDTH - 1 : 0]            gpr_rd_data_0,
    input wire [`WORD_WIDTH - 1 : 0]            gpr_rd_data_1,
    //to alu
    output reg [`DATA_WIDTH_ALU_OP - 1 : 0]     alu_op,
    output reg [`WORD_WIDTH - 1 : 0]            alu_in_0,
    output reg [`WORD_WIDTH - 1 : 0]            alu_in_1,
    //to "break"
    output reg [`WORD_ADDR_BUS]                 br_addr,
    output reg                                  br_taken,
    //to mem
    output reg [`DATA_WIDTH_MEM_OP - 1 : 0]     mem_op,
    output reg [`WORD_WIDTH - 1 : 0]            gpr_data,
    //to "ctrl"
    output reg [`DATA_WIDTH_CTRL_OP - 1 : 0]    ctrl_op,
    output reg [`DATA_WIDTH_ISA_EXP - 1 : 0]    exp_code,
    // forwarding
    // EX data
    input wire                                  id_en,
    input wire [`WORD_WIDTH - 1 : 0]            id_insn,
    input wire                                  id_gpr_we_,
    input wire [$clog2(`DATA_HIGH_GPR) - 1 : 0] id_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]            alu_out,
    // MEM data
    input wire                                  ex_en,
    input wire [`WORD_WIDTH - 1 : 0]            ex_insn,
    input wire                                  ex_gpr_we_,
    input wire [$clog2(`DATA_HIGH_GPR) - 1 : 0] ex_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]            mem_data_to_gpr,
    input wire [`WORD_WIDTH - 1 : 0]            ex_alu_out
);

wire        [`ALL_TYPE_OPCODE]      opcode;
reg         [`WORD_WIDTH - 1 : 0]   ra_data;
reg         [`WORD_WIDTH - 1 : 0]   rb_data;
wire signed [`WORD_WIDTH - 1 : 0]   s_ra_data;
wire signed [`WORD_WIDTH - 1 : 0]   s_rb_data;
reg         [`WORD_ADDR_BUS]        br_target; // BRANCH
reg         [`WORD_ADDR_BUS]        jr_offset; // JAL/JALR
reg         [`WORD_ADDR_BUS]        jr_target;
reg         [`WORD_ADDR_BUS]        imm;
reg signed  [`WORD_ADDR_BUS]        store_data;

assign s_ra_data    =   $signed(ra_data);
assign s_rb_data    =   $signed(rb_data);
assign opcode       =   if_insn[`ALL_TYPE_OPCODE];

always @* begin
    alu_op      =   `ALU_OP_NOP;            //default, not initial, every cycle
    alu_in_0    =   ra_data;
    alu_in_1    =   rb_data;
    br_taken    =   1'b0;
    br_addr     =   `WORD_ADDR_WIDTH'b0;
    mem_op      =   `MEM_OP_NOP;
    ctrl_op     =   `CTRL_OP_NOP;
    dst_addr    =   0;
    gpr_we_     =   1'b1;                   // not write to gpr
    exp_code    =   `ISA_EXP_NO_EXP;
    case (opcode)
        `OP_IMM: begin
            if (if_insn[`INSN_MSB] == 1) begin          //The immediate number is sign extended to XLEN bits
                imm = { 20'b1111_1111_1111_1111_1111, if_insn[`I_TYPE_IMM] };
            end else begin
                imm = { 20'b0000_0000_0000_0000_0000, if_insn[`I_TYPE_IMM] };
            end
            alu_in_0        =   $signed(imm);
            gpr_rd_addr_0   =   if_insn[`I_TYPE_RS1];
            dst_addr        =   if_insn[`I_TYPE_RD];
            gpr_we_         =   1'b0;                   // Have the signal of "dst_addr": need write
            case (if_insn[`I_TYPE_FUNCT3])
                `FUNCT3_ADDI: begin //rd = ra + imm
                    alu_op      =   `ALU_OP_ADDI;
                    alu_in_1    =   s_ra_data;
                end
                `FUNCT3_SLTI: begin //rd = (ra < imm)?1:0
                    alu_op      =   `ALU_OP_SLTI;
                    alu_in_1    =   s_ra_data;
                end
                `FUNCT3_SLTIU: begin //rd = (ra < imm)?1:0 
                    alu_in_0    =   $unsigned(imm); //The immediate number is sign extended to XLEN bits 
                                                    //and then treated as an unsigned number.
                    alu_op      =   `ALU_OP_SLTIU;
                    alu_in_1    =   ra_data;
                end
                `FUNCT3_ANDI: begin //rd = ra & imm
                    alu_op      =   `ALU_OP_ANDI;
                    alu_in_1    =   s_ra_data;
                end
                `FUNCT3_ORI: begin //rd = ra | imm
                    alu_op      =   `ALU_OP_ORI;
                    alu_in_1    =   s_ra_data;
                end
                `FUNCT3_XORI: begin //rd = ra ˆ imm
                    alu_op      =   `ALU_OP_XORI;
                    alu_in_1    =   s_ra_data;
                end
                `FUNCT3_SLLI: begin //rd = ra << imm[0:4]
                    alu_op      =   `ALU_OP_SLLI;
                    alu_in_1    =   ra_data;
                end
                `FUNCT3_SRLI_SRAI: begin //rd = ra >> imm[0:4]
                    if (if_insn[`I_TYPE_IMM_11_5] == 7'b0000000) begin
                        alu_op      =   `ALU_OP_SRLI; 
                        alu_in_0    =   $unsigned(alu_in_0);
                        alu_in_1    =   ra_data;
                    end else if (if_insn[`I_TYPE_IMM_11_5] == 7'b0100000) begin
                        alu_op      =   `ALU_OP_SRAI;
                        alu_in_1    =   s_ra_data;
                    end else begin
                        alu_op      =   `ALU_OP_NOP;
                        exp_code    =   `ISA_EXP_UNDEF_INSN;
                    end
                end
                default: begin
                    alu_op      =   `ALU_OP_NOP;
                    exp_code    =   `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP_LUI: begin //load upper immediate
            alu_op      =   `ALU_OP_LUI;
            alu_in_0    =   { 12'b0, if_insn[`U_TYPE_IMM]};
            dst_addr    =   if_insn[`U_TYPE_RD]; //rd = imm << 12
            gpr_we_     =   1'b0;
        end
        `OP_AUIPC: begin //add upper immediate to pc
            alu_op      =   `ALU_OP_AUIPC;
            alu_in_0    =   { 12'b0, if_insn[`U_TYPE_IMM] };
            alu_in_1    =   (if_pc - 4); // Cause of insn resgiter, "insn" will be delay than "pc" one cycle
            dst_addr    =   if_insn[`U_TYPE_RD]; //rd = PC + (imm << 12)
            gpr_we_     =   1'b0;
        end
        `OP: begin
            gpr_rd_addr_0   =   if_insn[`R_TYPE_RS1];
            gpr_rd_addr_1   =   if_insn[`R_TYPE_RS2];
            dst_addr        =   if_insn[`R_TYPE_RD];
            gpr_we_         =   1'b0;
            case (if_insn[`R_TYPE_FUNCT7])
                7'b0000000: begin
                    case (if_insn[`R_TYPE_FUNCT3])
                        `FUNCT3_ADD: begin //performs the addition of ra and rb
                            alu_op      =   `ALU_OP_ADD; //rd = ra + rb
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        `FUNCT3_SLT: begin //perform signed compares, writing 1 to rd if ra < rb, 0 otherwise.
                            alu_op      =   `ALU_OP_SLT; //rd = (ra < rb)?1:0
                            alu_in_0    =   s_ra_data;
                            alu_in_1    =   s_rb_data;
                        end
                        `FUNCT3_SLTU: begin //perform unsigned compares, writing 1 to rd if ra < rb, 0 otherwise.
                            alu_op      =   `ALU_OP_SLTU; //rd = (ra < rb)?1:0
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        `FUNCT3_AND: begin //perform AND bitwise logical operations.
                            alu_op      =   `ALU_OP_AND; //rd = ra & rb
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        `FUNCT3_OR: begin //perform OR bitwise logical operations.
                            alu_op      =   `ALU_OP_OR; //rd = ra | rb
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        `FUNCT3_XOR: begin //perform XOR bitwise logical operations.
                            alu_op      =   `ALU_OP_XOR; //rd = ra ˆ rb
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        `FUNCT3_SLL: begin //perform logical left shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op      =   `ALU_OP_SLL; //rd = ra << rb[4:0]
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        `FUNCT3_SRL: begin // logical right shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op      =   `ALU_OP_SRL; //rd = ra >> rb[4:0]
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        default: begin
                            alu_op      =   `ALU_OP_NOP;
                            exp_code    =   `ISA_EXP_UNDEF_INSN;
                        end
                    endcase
                end
                7'b0100000: begin
                    case (if_insn[`R_TYPE_FUNCT3])
                        `FUNCT3_SUB: begin //performs the subtraction of rb from ra.
                            alu_op      =   `ALU_OP_SUB; //rd = ra - rb
                            alu_in_0    =   ra_data;
                            alu_in_1    =   rb_data;
                        end
                        `FUNCT3_SRA: begin //arithmetic right shifts on the value in register ra by the shift amount held in the lower 5 bits of register rb.
                            alu_op      =   `ALU_OP_SRA; //rd = ra >> rb
                            alu_in_0    =   s_ra_data;
                            alu_in_1    =   s_rb_data;
                        end
                        default: begin
                            alu_op      =   `ALU_OP_NOP;
                            exp_code    =   `ISA_EXP_UNDEF_INSN;
                        end
                    endcase
                end
                default: begin
                    alu_op      =   `ALU_OP_NOP;
                    exp_code    =   `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP_JAL: begin //jump and link; rd = PC + 4; PC += imm
            //Lowest bit setting 0,realize signed offset for multiples of 2
            jr_offset = { if_insn[`J_TYPE_IMM_20], 
                          if_insn[`J_TYPE_IMM_19_12], 
                          if_insn[`J_TYPE_IMM_11], 
                          if_insn[`J_TYPE_IMM_10_1], 
                          1'b0}; 
            if (if_insn[`INSN_MSB] == 1) begin
                jr_target = (if_pc - 4) - jr_offset[19 : 0];
            end else begin
                jr_target = (if_pc - 4) + jr_offset[19 : 0];
            end
            br_addr     =   jr_target;
            br_taken    =   1'b1;
            gpr_we_     =   1'b0;
            alu_op      =   `ALU_OP_ADD; //rd = pc + 4
            alu_in_0    =   (if_pc - 4);
            alu_in_1    =   4;
            dst_addr    =   if_insn[`J_TYPE_RD];
        end
        `OP_JALR: begin //jump and link register; rd = PC+4; PC = ra + imm
            gpr_we_         =   1'b0;
            gpr_rd_addr_0   =   if_insn[`I_TYPE_RS1];
            if (if_insn[`INSN_MSB] == 1) begin
                jr_target   =   ra_data - if_insn[`I_TYPE_IMM];
            end else begin
                jr_target   =   ra_data + if_insn[`I_TYPE_IMM];
            end
            br_addr     =   { jr_target[`WORD_ADDR_WIDTH - 1 : 1], 1'b0 };
            br_taken    =   1'b1;
            alu_op      =   `ALU_OP_ADD; //rd = pc + 4
            alu_in_0    =   (if_pc - 4);
            alu_in_1    =   4;
            dst_addr    =   if_insn[`I_TYPE_RD];
        end
        `OP_BRANCH: begin
            gpr_rd_addr_0   =       if_insn[`B_TYPE_RS1];
            gpr_rd_addr_1   =       if_insn[`B_TYPE_RS2];
            imm             =   {   if_insn[`B_TYPE_IMM_12],
                                    if_insn[`B_TYPE_IMM_11],
                                    if_insn[`B_TYPE_IMM_10_5],
                                    if_insn[`B_TYPE_IMM_4_1],
                                    1'b0 };
            if (if_insn[`B_TYPE_IMM_12] == 1) begin
                br_target   =   (if_pc - 4) - imm[11 : 0];
            end else begin
                br_target   =   (if_pc - 4) + imm[11 : 0];
            end
            br_addr         =   br_target;
            case (if_insn[`B_TYPE_FUNCT3])
                `FUNCT3_BEQ: begin      //branch if equal
                    br_taken =  (ra_data == rb_data) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BNE: begin      //branch if not equal
                    br_taken =  (ra_data != rb_data) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BLT: begin      //branch if less than
                    br_taken =  (s_ra_data < s_rb_data) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BLTU: begin      //branch if less than，unsigned
                    br_taken =  (ra_data < rb_data) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BGE: begin      //branch if greater than or equal
                    br_taken =  (s_ra_data >= s_rb_data) ? 1'b1 : 1'b0;
                end
                `FUNCT3_BGEU: begin     //branch if greater than or equal，unsigned
                    br_taken =  (ra_data >= rb_data) ? 1'b1 : 1'b0;
                end
                default: br_taken = 1'b0;
            endcase
        end
        `OP_LOAD: begin //Loads copy a value from memory to register rd
            gpr_we_         =   1'b0;
            gpr_rd_addr_1   =   if_insn[`I_TYPE_RS1]; 
            dst_addr        =   if_insn[`I_TYPE_RD];
            if (if_insn[`INSN_MSB] == 1) begin
                alu_op      =   `ALU_OP_SUB;
                alu_in_0    =   rb_data;
                alu_in_1    =   if_insn[30 : 20];   //imm = $signed(if_insn[31:20]);
            end else begin
                alu_op      =   `ALU_OP_ADD;
                alu_in_0    =   rb_data;
                alu_in_1    =   if_insn[30 : 20];   // "alu_out" is the  effective address in memory
            end
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
                    exp_code    = `ISA_EXP_UNDEF_INSN;
                end
            endcase
        end
        `OP_STORE: begin                                // Stores copy the value in register rb to memory.
            mem_op          =   `MEM_OP_STORE;
            imm             =   {if_insn[`S_TYPE_IMM_11_5], if_insn[`S_TYPE_IMM_4_0]};
            gpr_rd_addr_0   =   if_insn[`S_TYPE_RS1];   // ra_data
            gpr_rd_addr_1   =   if_insn[`S_TYPE_RS2];   // rb

            // The most significant bit is used to determine whether a signed number is positive or negative
            // "alu_out" is the  effective address in memory
            if (if_insn[`INSN_MSB] == 1) begin
                alu_op      =   `ALU_OP_SUB;
                alu_in_0    =   ra_data;
                alu_in_1    =   imm[10 : 0];            //imm = {if_insn[31:25],if_insn[11:7]};
            end else begin
                alu_op      =   `ALU_OP_ADD;
                alu_in_0    =   ra_data;
                alu_in_1    =   imm[10 : 0];
            end

            case (if_insn[`S_TYPE_FUNCT3])
                `FUNCT3_SW: begin                   // WORD: store 32-bit values from register rb to memory.
                    gpr_data    =   rb_data;        // M[ra+imm][0:31] = rb[0:31]
                end

                `FUNCT3_SH: begin                   // HALF_WORRD: store 16-bit values from the low bits of rb to memory.
                    if (rb_data[15] == 1) begin
                        store_data  =   { 16'b1111_1111_1111_1111, rb_data[15 : 0] };
                    end else begin
                        store_data  =   { 16'b0000_0000_0000_0000, rb_data[15 : 0] };
                    end
                    gpr_data        =   $signed(store_data); // M[ra+imm][0:15] = rb[0:15]
                end

                `FUNCT3_SB: begin                   // BYTE: store 8-bit
                    if (rb_data[7] == 1) begin
                        store_data  =   { 24'b1111_1111_1111_1111_1111_1111, rb_data[7 : 0] };
                    end else begin
                        store_data  =   { 24'b0000_0000_0000_0000_0000_0000, rb_data[7 : 0] };
                    end
                    gpr_data        =   $signed(store_data); // M[ra+imm][0:7] = rb[0:7]
                end
                default: gpr_data   =   0;
            endcase
        end
        default: begin
            alu_op      =   `ALU_OP_NOP;
            mem_op      =   `MEM_OP_NOP;
            ctrl_op     =   `CTRL_OP_NOP;
            exp_code    =   `ISA_EXP_UNDEF_INSN;
        end
    endcase
end

// forwarding
always @(*) begin
    // gpr_rd_data_0
    if (id_en   &&  (!id_gpr_we_)   &&  (id_dst_addr == gpr_rd_addr_0)) begin
        if (id_insn[`ALL_TYPE_OPCODE] != `OP_LOAD) begin
            ra_data     <=  alu_out;
        end else begin
            ra_data     <=  0; // error, need to be reviewd
        end
    end else if (ex_en && !ex_gpr_we_ && (ex_dst_addr == gpr_rd_addr_0)) begin
        if (ex_insn[`ALL_TYPE_OPCODE] != `OP_LOAD) begin
            ra_data     <= ex_alu_out;
        end else begin
            ra_data     <= mem_data_to_gpr;
        end
    end else begin
        ra_data         <= gpr_rd_data_0;
    end
    
    // gpr_rd_data_1
    if (id_en && !id_gpr_we_ && (id_dst_addr == gpr_rd_addr_1)) begin
        if (id_insn[`ALL_TYPE_OPCODE] != `OP_LOAD) begin
            rb_data     <= alu_out;
        end else begin
            rb_data     <= 0; // error, need to be reviewd
        end
    end else if (ex_en && !ex_gpr_we_ && (ex_dst_addr == gpr_rd_addr_1)) begin
        if (ex_insn[`ALL_TYPE_OPCODE] != `OP_LOAD) begin
            rb_data     <= ex_alu_out;
        end else begin
            rb_data     <= mem_data_to_gpr;
        end
    end else begin
        rb_data         <= gpr_rd_data_1;
    end
end

endmodule

`endif