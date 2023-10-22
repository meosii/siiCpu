`ifndef CPU_CTRL
`define CPU_CTRL
`include "define.v"

module cpu_ctrl (
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    exp_code,
    input wire                                  load_hazard_in_id_ex,
    input wire                                  load_hazard_in_ex_mem,
    input wire                                  contral_hazard,
    output wire                                 pc_stall,
    output wire                                 if_stall,
    output wire                                 id_stall,
    output wire                                 ex_stall,
    output wire                                 mem_stall,
    output wire                                 if_flush,
    output wire                                 id_flush,
    output wire                                 ex_flush,
    output wire                                 mem_flush
);

assign pc_stall = (load_hazard_in_id_ex || load_hazard_in_ex_mem)? 1'b1 : 1'b0; 
assign if_stall = (load_hazard_in_id_ex || load_hazard_in_ex_mem)? 1'b1 : 1'b0; 
assign id_stall = (1'b0)? 1'b1 : 1'b0; 
assign ex_stall = (1'b0)? 1'b1 : 1'b0; 
assign mem_stall = (1'b0)? 1'b1 : 1'b0; 

assign if_flush = (contral_hazard)? 1'b1 : 1'b0;
assign id_flush = ((exp_code == `ISA_EXP_UNDEF_INSN) || load_hazard_in_id_ex || load_hazard_in_ex_mem)? 1'b1 : 1'b0;
assign ex_flush = (1'b0)? 1'b1 : 1'b0;
assign mem_flush = (1'b0)? 1'b1 : 1'b0;

endmodule
`endif