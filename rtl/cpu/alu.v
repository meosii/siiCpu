`ifndef SIICPU_ALU
`define SIICPU_ALU
`include "define.v"
module alu (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire [`DATA_WIDTH_ALU_OP - 1:0]       alu_op,
    input wire [`WORD_WIDTH - 1:0]              alu_in_0,
    input wire [`WORD_WIDTH - 1:0]              alu_in_1,
    input wire                                  rem_after_div,
    output reg [`WORD_WIDTH - 1:0]              alu_out,
    output wire                                 div_in_alu  // stall and flush the pipeline
);

parameter SIGNED_WORD_WIDTH = `WORD_WIDTH + 1;
parameter PARTIAL_PRODUCT_WIDTH = SIGNED_WORD_WIDTH + SIGNED_WORD_WIDTH;

wire [2:0]                          mul_opcode;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_add_a;    // mul = a + b; from mul
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_add_b;    // mul = a + b; from mul
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_result;

wire                                div_start;
wire [2:0]                          div_opcode;
wire [`WORD_WIDTH-1 : 0]            div_quotient;   // from div
wire [`WORD_WIDTH-1 : 0]            div_remainder;  // from div
wire                                div_finish;
reg                                 diving_in_alu;
reg                                 remAdiv_in_alu; // No division required
reg [`WORD_WIDTH-1 : 0]             remAdiv_div_remainder;

// mul
assign mul_opcode = (alu_op == `ALU_OP_MUL      )? `MUL_OP_MUL      : 
                    (alu_op == `ALU_OP_MULH     )? `MUL_OP_MULH     :
                    (alu_op == `ALU_OP_MULHU    )? `MUL_OP_MULHU    :
                    (alu_op == `ALU_OP_MULHSU   )? `MUL_OP_MULHSU   : `MUL_OP_NOP;

assign mul_result = mul_add_a + mul_add_b;

// div
assign div_opcode = ((alu_op == `ALU_OP_DIV) || (alu_op == `ALU_OP_REM)     )? `DIV_OP_DIV  : 
                    ((alu_op == `ALU_OP_DIVU) || (alu_op == `ALU_OP_REMU)   )? `DIV_OP_DIVU : `DIV_OP_NOP;

assign div_start = ((div_opcode == `DIV_OP_DIV) || (div_opcode == `DIV_OP_DIVU)) && !diving_in_alu 
                && !remAdiv_in_alu; // div-rem; divu-remu

assign div_in_alu = (diving_in_alu || div_start) && !div_finish; // stall and flush the pipeline

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        remAdiv_in_alu          <= 1'b0;
        remAdiv_div_remainder   <= `WORD_WIDTH'b0;
    end else if (div_finish && rem_after_div) begin
        remAdiv_in_alu          <= 1'b1;
        remAdiv_div_remainder   <= div_remainder;
    end else begin
        remAdiv_in_alu          <= 1'b0;
        remAdiv_div_remainder   <= `WORD_WIDTH'b0;
    end
end

mul #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_alu_mul(
    .mul_opcode             (mul_opcode             ),
    .mul_data1              (alu_in_0               ),
    .mul_data2              (alu_in_1               ),
    .mul_add_a              (mul_add_a              ),
    .mul_add_b              (mul_add_b              )
);

div u_alu_div(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .div_start              (div_start              ),
    .div_opcode             (div_opcode             ),
    .div_divident           (alu_in_0               ),
    .div_divisor            (alu_in_1               ),
    .div_quotient           (div_quotient           ),
    .div_remainder          (div_remainder          ),
    .div_finish             (div_finish             )
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        diving_in_alu <= 1'b0;
    end else if (div_start && !div_finish) begin
        diving_in_alu <= 1'b1;
    end else if (div_finish) begin
        diving_in_alu <= 1'b0;
    end
end

always @(*) begin
   case (alu_op)
    `ALU_OP_ADDI: begin
        alu_out = alu_in_0 + alu_in_1;
    end
    `ALU_OP_SLTI: begin
        alu_out = ($signed(alu_in_1) < $signed(alu_in_0))? 1'b1:1'b0;
    end
    `ALU_OP_SLTIU: begin
        alu_out = (alu_in_1 < alu_in_0)? 1'b1:1'b0;
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
        alu_out = alu_in_0; // imm has already shift, << 12
    end
    `ALU_OP_AUIPC: begin
        alu_out = alu_in_1 + (alu_in_0 << 12);
    end
    `ALU_OP_ADD: begin
        alu_out = alu_in_0 + alu_in_1;
    end
    `ALU_OP_SLT: begin
        alu_out = ($signed(alu_in_0) < $signed(alu_in_1))? 1:0;
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
    `ALU_OP_MUL:begin
        alu_out = mul_result[`WORD_WIDTH-1 : 0]; 
    end
    `ALU_OP_MULH, `ALU_OP_MULHSU, `ALU_OP_MULHU:begin
        alu_out = mul_result[`WORD_WIDTH+`WORD_WIDTH-1 : `WORD_WIDTH];
    end
    `ALU_OP_DIV, `ALU_OP_DIVU: begin
        alu_out = (div_finish)? div_quotient : `WORD_WIDTH'b0;
    end
    `ALU_OP_REM, `ALU_OP_REMU: begin
        alu_out =   (remAdiv_in_alu )? remAdiv_div_remainder :
                    (div_finish     )? div_remainder : `WORD_WIDTH'b0;
    end
    default: alu_out = `WORD_WIDTH'b0;
   endcase 
end
endmodule
`endif 