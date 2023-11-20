`ifndef SIICPU_PC
`define SIICPU_PC
`include "define.v"
module pc (
    input wire                              clk,
    input wire                              rst_n,
    input wire                              cpu_en,
    input wire                              pc_stall,
    // jump and branch
    input wire [`PC_WIDTH-1 : 0]            br_addr,
    input wire                              br_taken,
    // cpu_ctrl
    input wire [`PC_WIDTH-1 : 0]            ctrl_pc,
    input wire                              trap_happened,
    // instruction
    input wire [`WORD_WIDTH - 1 : 0]        insn,
    // jalr: read gpr
    input wire [`GPR_ADDR_WIDTH - 1 : 0]    gpr_rd_addr_1,  // from decoder, hazard?
    input wire [`WORD_WIDTH - 1 : 0]        predt_gpr_rd_data,
    input wire [`WORD_WIDTH - 1 : 0]        gpr_x1,         // from gpr
    // ra hazard
    input wire                              gpr_we_n,
    input wire                              load_in_id_ex,
    input wire                              load_in_ex_mem,
    input wire                              alu2gpr_in_id_ex,
    input wire                              alu2gpr_in_ex_mem,
    input wire                              load_after_storing_en,
    input wire                              loading_after_store_en,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]    dst_addr,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]    id_dst_addr,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]    ex_dst_addr,
    input wire [`WORD_WIDTH - 1 : 0]        alu_out,
    input wire [`WORD_WIDTH - 1 : 0]        ex_alu_out,
    input wire [`WORD_WIDTH - 1 : 0]        ex_store_data,
    input wire [`WORD_WIDTH - 1 : 0]        prev_ex_store_data,
    // outputs
    output wire                             predt_gpr_rd_en,
    output wire [`GPR_ADDR_WIDTH - 1 : 0]   predt_gpr_rd_addr,
    output wire                             predt_br_taken,
    output wire                             mret_en, // to cpu_ctrl, write csrs
    output reg [`PC_WIDTH-1 : 0]            pc
);

wire [`WORD_WIDTH - 1 : 0]  local_gpr_x1;
wire                        local_gpr_x1_valid;
wire [`WORD_WIDTH - 1 : 0]  local_predt_gpr_rd_data;
wire                        local_predt_gpr_rd_data_valid;
wire [`WORD_WIDTH - 1 : 0]  predt_pc_add_op1;
wire [`WORD_WIDTH - 1 : 0]  predt_pc_add_op2;
wire [`WORD_WIDTH - 1 : 0]  predt_pc;

assign local_gpr_x1 =   (alu2gpr_in_id_ex && (id_dst_addr == `GPR_ADDR_WIDTH'd1)                         )? alu_out             :   // forwarding from alu
                        (alu2gpr_in_ex_mem && (ex_dst_addr == `GPR_ADDR_WIDTH'd1)                        )? ex_alu_out          :   // forwarding from ex_alu
                        (load_in_id_ex && (id_dst_addr == `GPR_ADDR_WIDTH'd1) && load_after_storing_en   )? ex_store_data       :   // forwarding from mem_store_data
                        (load_in_ex_mem && (ex_dst_addr == `GPR_ADDR_WIDTH'd1) && loading_after_store_en )? prev_ex_store_data  :   // forwarding from wb_stroe_data
                                                                                                            gpr_x1;

assign local_gpr_x1_valid = !((gpr_we_n == `GPR_WRITE) && (dst_addr == `GPR_ADDR_WIDTH'd1)                      ) &&
                            !(load_in_id_ex && (id_dst_addr == `GPR_ADDR_WIDTH'd1) && !load_after_storing_en    ) &&
                            !(load_in_ex_mem && (ex_dst_addr == `GPR_ADDR_WIDTH'd1) && loading_after_store_en   );

assign local_predt_gpr_rd_data =    (alu2gpr_in_id_ex && (id_dst_addr == predt_gpr_rd_addr)                         )?  alu_out             :   // forwarding from alu
                                    (alu2gpr_in_ex_mem && (ex_dst_addr == predt_gpr_rd_addr)                        )?  ex_alu_out          :   // forwarding from ex_alu
                                    (load_in_id_ex && (id_dst_addr == predt_gpr_rd_addr) && load_after_storing_en   )?  ex_store_data       :   // forwarding from mem_store_data
                                    (load_in_ex_mem && (ex_dst_addr == predt_gpr_rd_addr) && loading_after_store_en )?  prev_ex_store_data  :   // forwarding from wb_stroe_data
                                                                                                                        predt_gpr_rd_data   ;

assign local_predt_gpr_rd_data_valid =  !((gpr_we_n == `GPR_WRITE) && (dst_addr == predt_gpr_rd_addr)                      ) &&
                                        !(load_in_id_ex && (id_dst_addr == predt_gpr_rd_addr) && !load_after_storing_en    ) &&
                                        !(load_in_ex_mem && (ex_dst_addr == predt_gpr_rd_addr) && loading_after_store_en   );

//  prediction
assign predt_gpr_rd_en   = insn[`ALL_TYPE_OPCODE] == `OP_JALR;
assign predt_gpr_rd_addr = insn[`I_TYPE_RS1];

assign predt_br_taken = (insn[`ALL_TYPE_OPCODE] == `OP_JAL                                                  )   // unconditional jump
                    ||  ((insn[`ALL_TYPE_OPCODE] == `OP_JALR) &&                                                // unconditional jump
                         (  (predt_gpr_rd_addr == `GPR_ADDR_WIDTH'b0                                ) ||        // read gpr_x0
                            ((predt_gpr_rd_addr == `GPR_ADDR_WIDTH'd1) && local_gpr_x1_valid        ) ||        // read gpr_x1
                            ((gpr_rd_addr_1 != `GPR_ADDR_WIDTH'b0) && local_predt_gpr_rd_data_valid )   )   )   // gpr rd_addr is free
                    ||  ((insn[`ALL_TYPE_OPCODE] == `OP_BRANCH) && insn[`B_TYPE_IMM_12]                     );  // static prediction, if (pc+imm > pc): jump

assign predt_pc_add_op1 =   ((insn[`ALL_TYPE_OPCODE] == `OP_JAL)  || (insn[`ALL_TYPE_OPCODE] == `OP_BRANCH)         )?  pc                  :
                            ((insn[`ALL_TYPE_OPCODE] == `OP_JALR) && (predt_gpr_rd_addr == `GPR_ADDR_WIDTH'b0)      )?  `WORD_WIDTH'b0      :
                            ((insn[`ALL_TYPE_OPCODE] == `OP_JALR) && (predt_gpr_rd_addr == `GPR_ADDR_WIDTH'd1)      )?  local_gpr_x1        :
                            ((insn[`ALL_TYPE_OPCODE] == `OP_JALR) && (gpr_rd_addr_1 != `GPR_ADDR_WIDTH'b0)          )?  local_predt_gpr_rd_data   : `WORD_WIDTH'b0;

assign predt_pc_add_op2 =   (insn[`ALL_TYPE_OPCODE] == `OP_JAL)?    {{12{insn[`J_TYPE_IMM_20]}}, insn[`J_TYPE_IMM_19_12], insn[`J_TYPE_IMM_11], insn[`J_TYPE_IMM_10_1], 1'b0} :
                            (insn[`ALL_TYPE_OPCODE] == `OP_JALR)?   {{20{insn[`INSN_MSB]}}, insn[`I_TYPE_IMM]}                                                              :
                            (insn[`ALL_TYPE_OPCODE] == `OP_BRANCH)? {{20{insn[`B_TYPE_IMM_12]}}, insn[`B_TYPE_IMM_11], insn[`B_TYPE_IMM_10_5], insn[`B_TYPE_IMM_4_1], 1'b0 }: `WORD_WIDTH'b0;

assign predt_pc    = predt_pc_add_op1 + predt_pc_add_op2;

// mret, jump return
assign mret_en   = (insn == `MRET_INSN)?  `ENABLE : `DISABLE;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= `PC_WIDTH'b0;
    end else if (cpu_en) begin
        if (trap_happened || mret_en) begin
            pc <= ctrl_pc;
        end else if (br_taken && !pc_stall) begin
            pc <= br_addr;
        end else if (predt_br_taken && !pc_stall) begin
            pc <= predt_pc;
        end else if (!pc_stall) begin
            pc <= pc + 4;
        end
    end
end

endmodule
`endif