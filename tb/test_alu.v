`include "unit/define.v"
`include "unit/alu.v"
module test_alu();
reg [`DATA_WIDTH_ALU_OP - 1:0] alu_op;
reg [`DATA_WIDTH_GPR - 1:0] alu_in_0;
reg [`DATA_WIDTH_GPR - 1:0] alu_in_1;
wire [`DATA_WIDTH_GPR - 1:0] alu_out;

alu u_alu(
    .alu_op(alu_op),
    .alu_in_0(alu_in_0),
    .alu_in_1(alu_in_1),
    .alu_out(alu_out)
);

initial begin
    #0 begin
        alu_op = `ALU_OP_ADDI;
        alu_in_0 = 22;
        alu_in_1 = 33;
        #1 $display("ADDI: out = %d",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SLTI;
        alu_in_0 = 44;
        alu_in_1 = 33;
        #1 $display("SLTI: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SLTIU;
        alu_in_0 = 44;
        alu_in_1 = 33;
        #1 $display("SLTIU: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_ANDI;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("ANDI: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_ORI;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("ORI: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_XORI;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("XORI: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SLLI;
        alu_in_0 = 6;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("SLLI: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SRLI;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("SRLI: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SRAI;
        alu_in_0 = 6;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("SRAI: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_LUI;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("LUI: out = %d",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_AUIPC;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 15;
        #1 $display("AUIPC: out = %d",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_ADD;
        alu_in_0 = 33;
        alu_in_1 = 22;
        #1 $display("ADD: out = %d",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SLT;
        alu_in_0 = 11;
        alu_in_1 = 11;
        #1 $display("SLT: out = %d",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SLTU;
        alu_in_0 = 32;
        alu_in_1 = 33;
        #1 $display("SLTU: out = %d",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_AND;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("AND: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_OR;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("OR: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_XOR;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 32'b0101_1110_0010_1110_1111_0101_0000_1001;
        #1 $display("XOR: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SLL;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 6;
        #1 $display("SLL: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SRL;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 6;
        #1 $display("SRL: out = %b",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SUB;
        alu_in_0 = 33;
        alu_in_1 = 22;
        #1 $display("SUB: out = %d",alu_out);
    end
    #1 begin
        alu_op = `ALU_OP_SRA;
        alu_in_0 = 32'b0101_1110_0010_1110_0000_1010_1101_0110;
        alu_in_1 = 6;
        #1 $display("SRA: out = %b",alu_out);
    end
    #1
    $finish;
end

endmodule