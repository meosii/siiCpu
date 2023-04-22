// "signed alu_out" can judge whether the overflow
`ifndef siicpu_alu
`define siicpu_alu
`include "unit/define.v"

module alu (
    input wire [`DATA_WIDTH_ALU_OP - 1:0]   alu_op,
    input wire [`WORD_WIDTH - 1:0]          alu_in_0,
    input wire [`WORD_WIDTH - 1:0]          alu_in_1,
    output reg [`WORD_WIDTH - 1:0]          alu_out
);

integer i;

always @(*) begin
   case (alu_op)
    `ALU_OP_ADDI: begin
        alu_out = alu_in_0 + alu_in_1;
    end
    `ALU_OP_SLTI: begin
        alu_out = (alu_in_1 < alu_in_0)? 1:0;
    end
    `ALU_OP_SLTIU: begin
        alu_out = (alu_in_1 < alu_in_0)? 1:0;
    end
    `ALU_OP_ANDI: begin
        alu_out = alu_in_0 & alu_in_1;
    end
    `ALU_OP_ORI: begin
        alu_out = alu_in_0 | alu_in_1;
    end
    `ALU_OP_XORI: begin
        alu_out = alu_in_0 ^ alu_in_1;
    end
    `ALU_OP_SLLI: begin
        alu_out = alu_in_1 << alu_in_0[4:0];
    end
    `ALU_OP_SRLI: begin
        alu_out = alu_in_1 >> alu_in_0[4:0];
    end
    `ALU_OP_SRAI: begin
        alu_out = alu_in_1 >>> alu_in_0[4:0];
    end
    `ALU_OP_LUI: begin
        alu_out = alu_in_0 << 12;
    end
    `ALU_OP_AUIPC: begin
        alu_out = alu_in_1 + (alu_in_0 << 12);
    end
    `ALU_OP_ADD: begin
        alu_out = alu_in_0 + alu_in_1;
    end
    `ALU_OP_SLT: begin
        alu_out = (alu_in_0 < alu_in_1)? 1:0;
    end
    `ALU_OP_SLTU: begin
        alu_out = (alu_in_0 < alu_in_1)? 1:0;
    end
    `ALU_OP_AND: begin
        alu_out = alu_in_0 & alu_in_1;
    end
    `ALU_OP_OR: begin
        alu_out = alu_in_0 | alu_in_1;
    end
    `ALU_OP_XOR: begin
        alu_out = alu_in_0 ^ alu_in_1;
    end
    `ALU_OP_SLL: begin
        alu_out = alu_in_0 << alu_in_1[4:0];
    end
    `ALU_OP_SRL: begin
        alu_out = alu_in_0 >> alu_in_1[4:0];
    end
    `ALU_OP_SUB: begin
        alu_out = alu_in_0 - alu_in_1;
    end
    `ALU_OP_SRA: begin
        alu_out = alu_in_0 >>> alu_in_1[4:0];
    end
    default: alu_out = 0;
   endcase 
end

endmodule

`endif 