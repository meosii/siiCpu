`ifndef SIICPU_MEM_CTRL
`define SIICPU_MEM_CTRL

`ifndef SIICPU_MEM_CTRL
`define SIICPU_MEM_CTRL
`include "define.v"

module mem_ctrl (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire                                  ex_en,
    input wire [`WORD_WIDTH - 1 : 0]            ex_insn,
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    ex_exp_code,
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0]     ex_mem_op,      //from decoder
    input wire                                  ex_memory_we_en,
    input wire                                  ex_memory_rd_en,
    input wire [`WORD_WIDTH - 1 : 0]            ex_alu_out,     // ex_alu_out -> memory_addr
    input wire [`WORD_WIDTH - 1 : 0]            ex_store_data,
    input wire [3 : 0]                          ex_store_byteena,
    // load_after_store
    input wire                                  load_in_id_ex,
    input wire                                  load_in_ex_mem,
    input wire [`WORD_WIDTH - 1 : 0]            alu_out,
    // from spm
    input wire [`WORD_WIDTH - 1 : 0]            spm_rd_data,       // spm_rd_data -> load_data
    // to spm
    output wire [`WORD_WIDTH - 1 : 0]           memory_addr,
    // to gpr or decoder
    output wire [`WORD_WIDTH - 1 : 0]           load_data,
    output reg [`WORD_WIDTH - 1 : 0]            prev_ex_store_data,
    output wire                                 load_after_storing_en,   // store in mem_stage, load in ex_stage
    output wire                                 loading_after_store_en, // store in wb_stage, load in mem_stage
    // exp_code
    output wire [`DATA_WIDTH_ISA_EXP - 1 : 0]   ex_exp_code_mem_ctrl
);

wire [`DATA_WIDTH_OFFSET - 1 : 0]   offset;
wire                                miss_align;
wire [`WORD_WIDTH - 1 : 0]          load_data_tmp;

// registers
reg                                 ex_en_r1;
reg                                 ex_memory_we_en_r1;
reg [`WORD_WIDTH - 1 : 0]           memory_addr_r1;
reg [3 : 0]                         ex_store_byteena_r1;
reg                                 loading_after_store_en_r1;
reg [`WORD_WIDTH - 1 : 0]           prev_ex_store_data_r1;
reg [`DATA_WIDTH_MEM_OP - 1 : 0]    ex_mem_op_r1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ex_en_r1                    <= 1'b0;
        ex_memory_we_en_r1          <= 1'b0;
        memory_addr_r1              <= 1'b0;
        prev_ex_store_data          <= `WORD_WIDTH'b0;
        prev_ex_store_data_r1       <= `WORD_WIDTH'b0;
        loading_after_store_en_r1   <= 1'b0;
        ex_store_byteena_r1         <= 4'b0000;
        ex_mem_op_r1                <= `DATA_WIDTH_MEM_OP'b0;
    end else begin
        ex_en_r1                    <= ex_en;
        ex_memory_we_en_r1          <= ex_memory_we_en;
        memory_addr_r1              <= memory_addr;
        prev_ex_store_data          <= ex_store_data;
        prev_ex_store_data_r1       <= prev_ex_store_data;
        loading_after_store_en_r1   <= loading_after_store_en;
        ex_store_byteena_r1         <= ex_store_byteena;
        ex_mem_op_r1                <= ex_mem_op;
    end
end

assign memory_addr  = ex_alu_out; // 31 : 0
assign offset       = ex_alu_out[`BYTE_OFFSET_LOC];
assign miss_align   = (ex_en && (offset == `BYTE_OFFSET_WORD))? 1'b0 : 1'b1;
assign ex_exp_code_mem_ctrl =   (ex_exp_code != `ISA_EXP_NO_EXP)? ex_exp_code :
                                (miss_align && (ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD))? `ISA_EXP_LOAD_MISALIGNED :
                                (miss_align && (ex_insn[`ALL_TYPE_OPCODE] == `OP_STORE))? `ISA_EXP_STORE_MISALIGNED : `ISA_EXP_NO_EXP;

assign load_after_storing_en    =   load_in_id_ex &&            // load in ex_stage
                                    ex_en && (ex_memory_we_en == `ENABLE) && (ex_alu_out == alu_out) && (ex_store_byteena == 4'b1111);  // storing in mem_stage

assign loading_after_store_en   =   load_in_ex_mem &&           // load in mem_stage
                                    ex_en_r1 && (ex_memory_we_en_r1 == `ENABLE) && (memory_addr_r1 == memory_addr) &&  (ex_store_byteena_r1 == 4'b1111);

assign load_data_tmp = (loading_after_store_en_r1)? prev_ex_store_data_r1 : spm_rd_data;

assign load_data =  (ex_mem_op_r1 == `MEM_OP_LOAD_LW    )?  load_data_tmp                                                                   :
                    (ex_mem_op_r1 == `MEM_OP_LOAD_LH    )?  {{16{load_data_tmp[`WORD_WIDTH/2 - 1]}}, load_data_tmp[`WORD_WIDTH/2 - 1 : 0]}  :
                    (ex_mem_op_r1 == `MEM_OP_LOAD_LHU   )?  {16'b0, load_data_tmp[`WORD_WIDTH/2 - 1 : 0]}                                   :
                    (ex_mem_op_r1 == `MEM_OP_LOAD_LB    )?  {{24{load_data_tmp[`WORD_WIDTH/4 - 1]}}, load_data_tmp[`WORD_WIDTH/4 - 1 : 0]}  :
                    (ex_mem_op_r1 == `MEM_OP_LOAD_LBU   )?  {24'b0, load_data_tmp[`WORD_WIDTH/4 - 1 : 0]}                                   : `WORD_WIDTH'b0;

endmodule

`endif 