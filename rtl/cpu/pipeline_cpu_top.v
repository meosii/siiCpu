`ifndef SIICPU_TOP
`define SIICPU_TOP
`include "define.v"
module pipeline_cpu_top (
    input wire                          cpu_en,
    input wire                          clk,
    input wire                          rst_n,
    // int req
    input wire                          irq_external,
    input wire                          irq_timer,
    input wire                          irq_software,  
    // insn and pc
    input  wire [`WORD_WIDTH - 1 : 0]   insn,
    output wire                         rd_insn_en,
    output wire [`PC_WIDTH - 1 : 0]     pc,
    // from AHB
    input wire [`WORD_WIDTH - 1 : 0]    CPU_HRDATA,
    input wire                          CPU_HREADY,
    input wire [1 : 0]                  CPU_HRESP,
    // to AHB
    output wire [`WORD_WIDTH - 1 : 0]   CPU_HADDR,
    output wire                         CPU_HWRITE,
    output wire [2 : 0]                 CPU_HSIZE,
    output wire [2 : 0]                 CPU_HBURST,
    output wire [1 : 0]                 CPU_HTRANS,
    output wire                         CPU_HMASTLOCK,
    output wire [`WORD_WIDTH - 1 : 0]   CPU_HWDATA,
    // int clear
    output wire                         external_int_clear,
    output wire                         software_int_clear,
    output wire                         timer_int_clear
);

assign rd_insn_en = (cpu_en)? 1'b1:1'b0;

wire [`WORD_WIDTH - 1 : 0]              gpr_x1;
wire                                    predt_gpr_rd_en;
wire [`GPR_ADDR_WIDTH - 1 : 0]          predt_gpr_rd_addr;
wire                                    predt_br_taken;
wire [`WORD_WIDTH - 1 : 0]              predt_gpr_rd_data;
wire [`PC_WIDTH - 1 : 0]                if_pc;
wire [`WORD_WIDTH - 1 : 0]              if_insn;
//wire                                    if_predt_br_taken;
//decoder
wire [`PC_WIDTH - 1 : 0]                br_addr;
wire                                    br_taken;
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       mem_op;
wire                                    memory_we_en;
wire                                    memory_rd_en;
wire [`WORD_WIDTH - 1 : 0]              store_data;
wire [3 : 0]                            store_byteena;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      exp_code;
wire                                    ebreak_en;
wire                                    ecall_en;

wire                                    if_en;
wire                                    id_en;
wire                                    ex_en;
wire                                    mem_en;

wire                                    gpr_we_n;
wire                                    id_gpr_we_n;
wire                                    ex_gpr_we_n;
wire                                    mem_gpr_we_n;
// csr
wire                                    csr_rd_en;
wire [`CSR_ADDR_WIDTH - 1 : 0]          csr_rd_addr;
wire                                    csr_w_en;
wire [`CSR_ADDR_WIDTH - 1 : 0]          csr_w_addr;
wire [`WORD_WIDTH - 1 : 0]              csr_w_data;
wire [`WORD_WIDTH - 1 : 0]              csr_to_gpr_data;
wire [`WORD_WIDTH - 1 : 0]              csr_rd_data;
wire                                    csr_mstatus_mpie;   // prev interrupt enable
wire                                    csr_mstatus_mie;    // machine interrupt enable
wire                                    csr_mie_meie;       // external interrupt enable
wire                                    csr_mie_mtie;       // timer interrupt enable
wire                                    csr_mie_msie;       // software interrupt enable
wire                                    csr_mip_meip;
wire                                    csr_mip_mtip;
wire                                    csr_mip_msip;
wire [29 : 0]                           csr_mtvec_base;
wire [1 : 0]                            csr_mtvec_mode;
wire [`PC_WIDTH - 1 : 0]                csr_mepc_pc;
// id
wire [`PC_WIDTH - 1 : 0]                id_pc;
wire [`DATA_WIDTH_ALU_OP - 1 : 0]       id_alu_op;
wire [`WORD_WIDTH - 1 : 0]              id_alu_in_0;
wire [`WORD_WIDTH - 1 : 0]              id_alu_in_1;
wire [`WORD_WIDTH - 1 : 0]              id_csr_to_gpr_data;
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       id_mem_op;
wire                                    id_memory_we_en;
wire                                    id_memory_rd_en;
wire [`WORD_WIDTH - 1 : 0]              id_store_data;
wire [3 : 0]                            id_store_byteena;
wire [`WORD_WIDTH - 1 : 0]              id_insn;
wire [`GPR_ADDR_WIDTH - 1 : 0]          id_dst_addr;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      id_exp_code;
wire                                    id_ebreak_en;
wire                                    id_ecall_en;
//gpr
wire                                    wb_gpr_we_n;
wire [`GPR_ADDR_WIDTH - 1 :0]           wb_gpr_wr_addr;
wire [`WORD_WIDTH - 1 : 0]              wb_gpr_wr_data;
wire [`GPR_ADDR_WIDTH - 1 : 0]          gpr_rd_addr_0;
wire [`GPR_ADDR_WIDTH - 1 : 0]          gpr_rd_addr_1;
wire [`WORD_WIDTH - 1 : 0]              gpr_rd_data_0;
wire [`WORD_WIDTH - 1 : 0]              gpr_rd_data_1;
wire [`GPR_ADDR_WIDTH - 1 : 0]          dst_addr;
wire [`WORD_WIDTH - 1 : 0]              gpr_wr_data;
// alu
wire [`DATA_WIDTH_ALU_OP - 1 : 0]       alu_op;
wire [`WORD_WIDTH - 1 : 0]              alu_in_0;
wire [`WORD_WIDTH - 1 : 0]              alu_in_1;
wire [`WORD_WIDTH - 1 : 0]              alu_out;
wire                                    div_in_alu;
// exe
wire [`WORD_WIDTH - 1 : 0]              ex_insn;
wire [`GPR_ADDR_WIDTH - 1 : 0]          ex_dst_addr;
wire [`PC_WIDTH - 1 : 0]                ex_pc;
wire [`WORD_WIDTH - 1 : 0]              ex_alu_out;
wire [`WORD_WIDTH - 1 : 0]              ex_csr_to_gpr_data;
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       ex_mem_op;
wire                                    ex_memory_we_en;
wire                                    ex_memory_rd_en;
wire [`WORD_WIDTH - 1 : 0]              ex_store_data;
wire [3 : 0]                            ex_store_byteena;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      ex_exp_code;
wire                                    ex_ebreak_en;
wire                                    ex_ecall_en;
// mem_ctrl
wire [`WORD_WIDTH - 1 : 0]              memory_addr;
wire                                    loading_after_store_en;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      ex_exp_code_mem_ctrl;
wire [`WORD_WIDTH - 1 : 0]              prev_ex_store_data;
wire [`WORD_WIDTH - 1 : 0]              load_data;
wire [`WORD_WIDTH - 1 : 0]              load_rd_data;
//ahb
wire                                    bus_ahb_enable;
wire                                    trans_end_en;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      ahb_exp_code;
// spm
wire [3 : 0]                            spm_store_byteena;
wire [`WORD_WIDTH - 1 : 0]              spm_write_data;
wire [`WORD_WIDTH - 1 : 0]              spm_rdaddress;
wire                                    spm_rden;
wire [`WORD_WIDTH - 1 : 0]              spm_wraddress;
wire                                    spm_wren;
wire [`WORD_WIDTH - 1 : 0]              spm_rd_data; // mem_to gpr
// mem
wire [`PC_WIDTH - 1 : 0]                mem_pc;
wire [`WORD_WIDTH - 1 : 0]              mem_insn;
wire [`WORD_WIDTH - 1 : 0]              mem_alu_out;
wire                                    mem_bus_ahb_enable;
wire [`GPR_ADDR_WIDTH - 1 : 0]          mem_dst_addr;
wire [`WORD_WIDTH - 1 : 0]              mem_csr_to_gpr_data;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      mem_exp_code;
wire                                    mem_ebreak_en;
wire                                    mem_ecall_en;
// cpu ctrl
wire                                    mret_en;
wire                                    load_hazard_in_id_ex;
wire                                    load_hazard_in_ex_mem;
wire                                    contral_hazard;
wire                                    ahb_bus_wait;
//
wire                                    load_in_id_ex;
wire                                    load_in_ex_mem;
wire                                    alu2gpr_in_id_ex;
wire                                    csr2gpr_in_id_ex;
wire                                    alu2gpr_in_ex_mem;
wire                                    csr2gpr_in_ex_mem;
wire                                    load_after_storing_en;
wire                                    loading_after_store_en_r1;
wire                                    rem_after_div;
//
wire                                    mstatus_mie_clear_en;
wire                                    mstatus_mie_set_en;
wire                                    mepc_set_en;
wire [`PC_WIDTH - 1 :0]                 mepc_set_pc;
wire                                    mcause_set_en;
wire [`WORD_WIDTH - 1 : 0]              mcause_set_cause;
wire                                    mtval_set_en;
wire [`WORD_WIDTH - 1 : 0]              mtval_set_tval;
wire                                    pc_stall;
wire                                    if_stall;
wire                                    id_stall;
wire                                    ex_stall;
wire                                    mem_stall;
wire                                    if_flush;
wire                                    id_flush;
wire                                    ex_flush;
wire                                    mem_flush;
wire [`PC_WIDTH - 1 : 0]                ctrl_pc;
wire                                    trap_happened;

//ip_pll u_ip_pll(
//  .areset (rst_n  ),
//	.inclk0 (clk    ),
//	.c0     (clk_pll)
//);

pc u_pc(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .cpu_en                 (cpu_en                 ),
    .pc_stall               (pc_stall               ),
    // jump and branch
    .br_addr                (br_addr                ),
    .br_taken               (br_taken               ),
    // from cpu_ctrl
    .ctrl_pc                (ctrl_pc                ),
    .trap_happened          (trap_happened          ),
//    .insn                   (insn                   ),
//    // from gpr
//    .gpr_rd_addr_1          (gpr_rd_addr_1          ),
//    .predt_gpr_rd_data      (gpr_rd_data_1          ),
//    .gpr_x1                 (gpr_x1                 ),
//    // ra hazard
//    .gpr_we_n               (gpr_we_n               ),
//    .load_in_id_ex          (load_in_id_ex          ),
//    .load_in_ex_mem         (load_in_ex_mem         ),
//    .alu2gpr_in_id_ex       (alu2gpr_in_id_ex       ),
//    .alu2gpr_in_ex_mem      (alu2gpr_in_ex_mem      ),
//    .csr2gpr_in_id_ex       (csr2gpr_in_id_ex       ),
//    .csr2gpr_in_ex_mem      (csr2gpr_in_ex_mem      ),
//    .load_after_storing_en  (load_after_storing_en  ),
//    .loading_after_store_en (loading_after_store_en ),
//    .dst_addr               (dst_addr               ),
//    .id_dst_addr            (id_dst_addr            ),
//    .ex_dst_addr            (ex_dst_addr            ),
//    .alu_out                (alu_out                ),
//    .id_csr_to_gpr_data     (id_csr_to_gpr_data     ),
//    .ex_alu_out             (ex_alu_out             ),
//    .ex_csr_to_gpr_data     (ex_csr_to_gpr_data     ),
//    .ex_store_data          (ex_store_data          ),
//    .prev_ex_store_data     (prev_ex_store_data     ),
//    // outputs
//    .predt_gpr_rd_en        (predt_gpr_rd_en        ),
//    .predt_gpr_rd_addr      (predt_gpr_rd_addr      ),
//    .predt_br_taken         (predt_br_taken         ),
    .mret_en                (mret_en                ),
    .pc                     (pc                     )
);

if_reg u_if_reg(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .cpu_en                 (cpu_en                 ),
    .if_stall               (if_stall               ),
    .if_flush               (if_flush               ),
    .pc                     (pc                     ),
    .insn                   (insn                   ),
//    .predt_br_taken         (predt_br_taken         ),
    // outputs
    .if_pc                  (if_pc                  ),
    .if_insn                (if_insn                ),
    .if_en                  (if_en                  )
//    .if_predt_br_taken      (if_predt_br_taken      )
);

decoder u_decoder(
    // in
//    .pc                     (pc                     ),
    .if_en                  (if_en                  ),
    .if_pc                  (if_pc                  ),
    .if_insn                (if_insn                ),
//    .if_predt_br_taken      (if_predt_br_taken      ),
    // from gpr
    .gpr_rd_data_0          (gpr_rd_data_0          ),
    .gpr_rd_data_1          (gpr_rd_data_1          ),
    //out
    .gpr_rd_addr_0          (gpr_rd_addr_0          ),
    .gpr_rd_addr_1          (gpr_rd_addr_1          ),
    .dst_addr               (dst_addr               ),
    .gpr_we_n               (gpr_we_n               ),
    // csr
    //out
    .csr_to_gpr_data        (csr_to_gpr_data        ),
    .csr_rd_en              (csr_rd_en              ),
    .csr_rd_addr            (csr_rd_addr            ),
    .csr_w_en               (csr_w_en               ),
    .csr_w_addr             (csr_w_addr             ),
    .csr_w_data             (csr_w_data             ),
    .ebreak_en              (ebreak_en              ),
    .ecall_en               (ecall_en               ),
	 .mret_en                (mret_en                ),
    // in
    .csr_rd_data            (csr_rd_data            ),
    // outputs
    .alu_op                 (alu_op                 ),
    .alu_in_0               (alu_in_0               ),
    .alu_in_1               (alu_in_1               ),
    .br_addr                (br_addr                ),
    .br_taken               (br_taken               ),
    .mem_op                 (mem_op                 ),
    .memory_we_en           (memory_we_en           ),
    .memory_rd_en           (memory_rd_en           ),
    .store_data             (store_data             ), //to mem
    .store_byteena          (store_byteena          ),
    // inputs
    // EX data
    .id_dst_addr            (id_dst_addr            ),
    .id_csr_to_gpr_data     (id_csr_to_gpr_data     ),
    .alu_out                (alu_out                ),
    // MEM data
    .ex_dst_addr            (ex_dst_addr            ),
    .ex_alu_out             (ex_alu_out             ),
    .ex_csr_to_gpr_data     (ex_csr_to_gpr_data     ),
    .load_after_storing_en  (load_after_storing_en  ),
    .loading_after_store_en (loading_after_store_en ),
    .ex_store_data          (ex_store_data          ),
    .prev_ex_store_data     (prev_ex_store_data     ),
    // in
    .load_in_id_ex          (load_in_id_ex          ),
    .load_in_ex_mem         (load_in_ex_mem         ),
    .alu2gpr_in_id_ex       (alu2gpr_in_id_ex       ),
    .csr2gpr_in_id_ex       (csr2gpr_in_id_ex       ),
    .alu2gpr_in_ex_mem      (alu2gpr_in_ex_mem      ),
    .csr2gpr_in_ex_mem      (csr2gpr_in_ex_mem      ),
    // outputs
    .exp_code               (exp_code               ),
    .load_hazard_in_id_ex   (load_hazard_in_id_ex   ),
    .load_hazard_in_ex_mem  (load_hazard_in_ex_mem  ),
    .contral_hazard         (contral_hazard         )
);

csr u_csr(
    //inputs
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .irq_external           (irq_external           ),
    .irq_timer              (irq_timer              ),
    .irq_software           (irq_software           ),
    .mstatus_mie_clear_en   (mstatus_mie_clear_en   ),
    .mstatus_mie_set_en     (mstatus_mie_set_en     ),
    .mepc_set_en            (mepc_set_en            ),
    .mepc_set_pc            (mepc_set_pc            ),
    .mcause_set_en          (mcause_set_en          ),
    .mcause_set_cause       (mcause_set_cause       ),
    .mtval_set_en           (mtval_set_en           ),
    .mtval_set_tval         (mtval_set_tval         ),
    // read and write
    .csr_rd_en              (csr_rd_en              ),
    .csr_rd_addr            (csr_rd_addr            ),
    .csr_w_en               (csr_w_en               ),
    .csr_w_addr             (csr_w_addr             ),
    .csr_w_data             (csr_w_data             ),
    // outputs
    .csr_rd_data            (csr_rd_data            ),
    .csr_mstatus_mpie       (csr_mstatus_mpie       ),
    .csr_mstatus_mie        (csr_mstatus_mie        ),
    .csr_mie_meie           (csr_mie_meie           ),
    .csr_mie_mtie           (csr_mie_mtie           ),
    .csr_mie_msie           (csr_mie_msie           ),
    .csr_mip_meip           (csr_mip_meip           ),
    .csr_mip_mtip           (csr_mip_mtip           ),
    .csr_mip_msip           (csr_mip_msip           ),
    .csr_mtvec_base         (csr_mtvec_base         ),
    .csr_mtvec_mode         (csr_mtvec_mode         ),
    .csr_mepc_pc            (csr_mepc_pc            )
);

id_reg u_id_reg(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .cpu_en                 (cpu_en                 ),
    .id_stall               (id_stall               ),
    .id_flush               (id_flush               ),
    //in
    .if_pc                  (if_pc                  ),
    .if_insn                (if_insn                ),
    .if_en                  (if_en                  ),
    .gpr_we_n               (gpr_we_n               ),
    .dst_addr               (dst_addr               ), 
    .csr_to_gpr_data        (csr_to_gpr_data        ),
    .gpr_rd_addr_0          (gpr_rd_addr_0          ),
    .gpr_rd_addr_1          (gpr_rd_addr_1          ),
    .alu_op                 (alu_op                 ),
    .alu_in_0               (alu_in_0               ),
    .alu_in_1               (alu_in_1               ),
    .mem_op                 (mem_op                 ),
    .memory_we_en           (memory_we_en           ),
    .memory_rd_en           (memory_rd_en           ),
    .store_data             (store_data             ),
    .store_byteena          (store_byteena          ),
    .exp_code               (exp_code               ),
    .ebreak_en              (ebreak_en              ),
    .ecall_en               (ecall_en               ),
    //out
    .id_pc                  (id_pc                  ),
    .id_insn                (id_insn                ),
    .id_en                  (id_en                  ),
    .id_gpr_we_n            (id_gpr_we_n            ),
    .id_dst_addr            (id_dst_addr            ),
    .id_csr_to_gpr_data     (id_csr_to_gpr_data     ),
    .id_alu_op              (id_alu_op              ),
    .id_alu_in_0            (id_alu_in_0            ),
    .id_alu_in_1            (id_alu_in_1            ),
    .id_mem_op              (id_mem_op              ),
    .id_memory_we_en        (id_memory_we_en        ),
    .id_memory_rd_en        (id_memory_rd_en        ),
    .id_store_data          (id_store_data          ),
    .id_store_byteena       (id_store_byteena       ),
    .id_exp_code            (id_exp_code            ),
    .id_ebreak_en           (id_ebreak_en           ),
    .id_ecall_en            (id_ecall_en            ),
    // outputs
    .load_in_id_ex          (load_in_id_ex          ),
    .alu2gpr_in_id_ex       (alu2gpr_in_id_ex       ),
    .csr2gpr_in_id_ex       (csr2gpr_in_id_ex       ),
    .rem_after_div          (rem_after_div          )
);

wire [`GPR_ADDR_WIDTH - 1 : 0]   gpr_rd_addr_1_in;
assign gpr_rd_addr_1_in = ((gpr_rd_addr_1 == `GPR_ADDR_WIDTH'b0) && predt_gpr_rd_en)? predt_gpr_rd_addr : gpr_rd_addr_1;								 

gpr u_gpr(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .we_n                   (wb_gpr_we_n            ),
    .wr_addr                (wb_gpr_wr_addr         ),
    .wr_data                (wb_gpr_wr_data         ),
    .rd_addr_0              (gpr_rd_addr_0          ),
    .rd_addr_1              (gpr_rd_addr_1_in       ),
    .rd_data_0              (gpr_rd_data_0          ),
    .rd_data_1              (gpr_rd_data_1          ),
    .gpr_x1                 (gpr_x1                 )
);

alu u_alu(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .alu_op                 (id_alu_op              ),
    .alu_in_0               (id_alu_in_0            ),
    .alu_in_1               (id_alu_in_1            ),
    .rem_after_div          (rem_after_div          ),
    .alu_out                (alu_out                ),
    .div_in_alu             (div_in_alu             )
);

ex_reg u_ex_reg(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .cpu_en                 (cpu_en                 ),
    .ex_stall               (ex_stall               ),
    .ex_flush               (ex_flush               ),
    //in
    .id_pc                  (id_pc                  ),
    .id_insn                (id_insn                ),
    .id_en                  (id_en                  ),
    .id_gpr_we_n            (id_gpr_we_n            ),
    .id_dst_addr            (id_dst_addr            ),
    .id_csr_to_gpr_data     (id_csr_to_gpr_data     ),
    .alu_out                (alu_out                ),
    .id_mem_op              (id_mem_op              ),
    .id_memory_we_en        (id_memory_we_en        ),
    .id_memory_rd_en        (id_memory_rd_en        ),
    .id_store_data          (id_store_data          ),
    .id_store_byteena       (id_store_byteena       ),
    .id_exp_code            (id_exp_code            ),
    .id_ebreak_en           (id_ebreak_en           ),
    .id_ecall_en            (id_ecall_en            ),
    //out
    .ex_pc                  (ex_pc                  ),
    .ex_insn                (ex_insn                ),
    .ex_en                  (ex_en                  ),
    .ex_gpr_we_n            (ex_gpr_we_n            ),
    .ex_dst_addr            (ex_dst_addr            ),
    .ex_csr_to_gpr_data     (ex_csr_to_gpr_data     ),
    .ex_alu_out             (ex_alu_out             ),
    .ex_mem_op              (ex_mem_op              ),
    .ex_memory_we_en        (ex_memory_we_en        ),
    .ex_memory_rd_en        (ex_memory_rd_en        ),
    .ex_store_data          (ex_store_data          ),
    .ex_store_byteena       (ex_store_byteena       ),
    .ex_exp_code            (ex_exp_code            ),
    .ex_ebreak_en           (ex_ebreak_en           ),
    .ex_ecall_en            (ex_ecall_en            ),
    //
    .load_in_ex_mem         (load_in_ex_mem         ),
    .alu2gpr_in_ex_mem      (alu2gpr_in_ex_mem      ),
    .csr2gpr_in_ex_mem      (csr2gpr_in_ex_mem      )
);

mem_ctrl u_mem_ctrl(
    // inputs
    .clk                        (clk                        ),
    .rst_n                      (rst_n                      ),
    .ex_en                      (ex_en                      ),
    .ex_insn                    (ex_insn                    ),
    .ex_exp_code                (ex_exp_code                ),
    .ex_mem_op                  (ex_mem_op                  ),
    .ex_memory_we_en            (ex_memory_we_en            ),
    .ex_memory_rd_en            (ex_memory_rd_en            ),
    .ex_alu_out                 (ex_alu_out                 ),
    .ex_store_data              (ex_store_data              ),
    .ex_store_byteena           (ex_store_byteena           ),
    // load after store
    .load_in_id_ex              (load_in_id_ex              ),
    .load_in_ex_mem             (load_in_ex_mem             ),
    .alu_out                    (alu_out                    ),
    // from ahb
    .load_rd_data               (load_rd_data               ), //mem to gpr (load_rd_data -> load_data)
    .ahb_exp_code               (ahb_exp_code               ),
    // outputs
    .memory_addr                (memory_addr                ), // from alu_out to spm
    .load_data                  (load_data                  ), // to gpr
    // load after store
    .prev_ex_store_data         (prev_ex_store_data         ),
    .load_after_storing_en      (load_after_storing_en      ),
    .loading_after_store_en     (loading_after_store_en     ),
    .loading_after_store_en_r1  (loading_after_store_en_r1  ),
    // exp
    .ex_exp_code_mem_ctrl       (ex_exp_code_mem_ctrl       )
);

ahb_mem_ctrl u_ahb_mem_ctrl(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .ex_memory_we_en        (ex_memory_we_en        ),
    .ex_memory_rd_en        (ex_memory_rd_en        ),
    .memory_addr            (memory_addr            ),
    .ex_store_data          (ex_store_data          ),
    .ex_store_byteena       (ex_store_byteena       ),
    .CPU_HRDATA             (CPU_HRDATA             ),
    .CPU_HREADY             (CPU_HREADY             ),
    .CPU_HRESP              (CPU_HRESP              ),
    .spm_rd_data            (spm_rd_data            ),
    .loading_after_store_en (loading_after_store_en ),
    .CPU_HADDR              (CPU_HADDR              ),
    .CPU_HWRITE             (CPU_HWRITE             ),
    .CPU_HSIZE              (CPU_HSIZE              ),
    .CPU_HBURST             (CPU_HBURST             ),
    .CPU_HTRANS             (CPU_HTRANS             ),
    .CPU_HMASTLOCK          (CPU_HMASTLOCK          ),
    .CPU_HWDATA             (CPU_HWDATA             ),
    .spm_store_byteena      (spm_store_byteena      ),
    .spm_write_data         (spm_write_data         ),
    .spm_rdaddress          (spm_rdaddress          ),
    .spm_rden               (spm_rden               ),
    .spm_wraddress          (spm_wraddress          ),
    .spm_wren               (spm_wren               ),
    .load_rd_data           (load_rd_data           ),
    .ahb_bus_wait           (ahb_bus_wait           ),
    .bus_ahb_enable         (bus_ahb_enable         ),
    .trans_end_en           (trans_end_en           ),
    .ahb_exp_code           (ahb_exp_code           )
);

mem_reg u_mem_reg (
    //in
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .cpu_en                 (cpu_en                 ),
    .mem_stall              (mem_stall              ),
    .mem_flush              (mem_flush              ),
    .ex_pc                  (ex_pc                  ),
    .ex_insn                (ex_insn                ),
    .ex_en                  (ex_en                  ),
    .ex_gpr_we_n            (ex_gpr_we_n            ),
    .ex_dst_addr            (ex_dst_addr            ),
    .ex_alu_out             (ex_alu_out             ),
    .bus_ahb_enable         (bus_ahb_enable         ),
    .ex_csr_to_gpr_data     (ex_csr_to_gpr_data     ),
    .ex_exp_code_mem_ctrl   (ex_exp_code_mem_ctrl   ),
    .ex_ebreak_en           (ex_ebreak_en           ),
    .ex_ecall_en            (ex_ecall_en            ),
    //out
    .mem_pc                 (mem_pc                 ),
    .mem_insn               (mem_insn               ),
    .mem_en                 (mem_en                 ),
    .mem_gpr_we_n           (mem_gpr_we_n           ),
    .mem_dst_addr           (mem_dst_addr           ),
    .mem_alu_out            (mem_alu_out            ),
    .mem_bus_ahb_enable     (mem_bus_ahb_enable     ),
    .mem_csr_to_gpr_data    (mem_csr_to_gpr_data    ),
    .mem_exp_code           (mem_exp_code           ),
    .mem_ebreak_en          (mem_ebreak_en          ),
    .mem_ecall_en           (mem_ecall_en           )
);

ip_spm u_ip_spm(
	.byteena_a              (spm_store_byteena              ),
	.clock                  (clk                            ),
	.data                   (spm_write_data                 ),
	.rdaddress              (spm_rdaddress[`SPM_ADDR_LOCA]  ),
	.rden                   (spm_rden                       ),
	.wraddress              (spm_wraddress[`SPM_ADDR_LOCA]  ),
	.wren                   (spm_wren                       ),
	.q                      (spm_rd_data                    )
);

wb u_wb (
    .clk                        (clk                       ),
    .rst_n                      (rst_n                     ),
    .gpr_rd_addr_1              (gpr_rd_addr_1             ),
    .predt_gpr_rd_en            (predt_gpr_rd_en           ),
    .predt_gpr_rd_addr          (predt_gpr_rd_addr         ),
    .mem_gpr_we_n               (mem_gpr_we_n              ),
    .mem_dst_addr               (mem_dst_addr              ),
    .mem_bus_ahb_enable         (mem_bus_ahb_enable        ),
    .trans_end_en               (trans_end_en              ),
    .ahb_bus_wait               (ahb_bus_wait              ),
    .loading_after_store_en_r1  (loading_after_store_en_r1 ),
    .mem_insn                   (mem_insn                  ),
    .load_data                  (load_data                 ),
    .mem_csr_to_gpr_data        (mem_csr_to_gpr_data       ),
    .mem_alu_out                (mem_alu_out               ),
    // outputs                            
    .wb_gpr_we_n                (wb_gpr_we_n               ),
    .wb_gpr_wr_addr             (wb_gpr_wr_addr            ),
    .wb_gpr_wr_data             (wb_gpr_wr_data            ) 
);

cpu_ctrl u_cpu_ctrl(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .id_pc                  (id_pc                  ),
    .mem_pc                 (mem_pc                 ),
    // inputs
    .load_hazard_in_id_ex   (load_hazard_in_id_ex   ),
    .load_hazard_in_ex_mem  (load_hazard_in_ex_mem  ),
    .contral_hazard         (contral_hazard         ),
    .div_in_alu             (div_in_alu             ),
    .ahb_bus_wait           (ahb_bus_wait           ),
    // exp
    .exp_code               (exp_code               ),
    .ex_exp_code_mem_ctrl   (ex_exp_code_mem_ctrl   ),
    .mem_exp_code           (mem_exp_code           ),
    // ecall, ebreak, mret
    .ebreak_en              (ebreak_en              ),
    .ecall_en               (ecall_en               ),
    .mret_en                (mret_en                ),  // from pc (prediction)
    .mem_ebreak_en          (mem_ebreak_en          ),
    .mem_ecall_en           (mem_ecall_en           ),
    // from csrs
    .csr_mstatus_mpie       (csr_mstatus_mpie       ),    // prev interrupt enable
    .csr_mstatus_mie        (csr_mstatus_mie        ),    // machine interrupt enable
    .csr_mie_meie           (csr_mie_meie           ),    // external interrupt enable
    .csr_mie_mtie           (csr_mie_mtie           ),    // timer interrupt enable
    .csr_mie_msie           (csr_mie_msie           ),    // software interrupt enable
    .csr_mip_meip           (csr_mip_meip           ),
    .csr_mip_mtip           (csr_mip_mtip           ),
    .csr_mip_msip           (csr_mip_msip           ),
    .csr_mtvec_base         (csr_mtvec_base         ),
    .csr_mtvec_mode         (csr_mtvec_mode         ),
    .csr_mepc_pc            (csr_mepc_pc            ),
    // outputs
    // to csrs
    .mstatus_mie_clear_en   (mstatus_mie_clear_en   ),
    .mstatus_mie_set_en     (mstatus_mie_set_en     ),
    .mepc_set_en            (mepc_set_en            ),
    .mepc_set_pc            (mepc_set_pc            ),
    .mcause_set_en          (mcause_set_en          ),
    .mcause_set_cause       (mcause_set_cause       ),
    .mtval_set_en           (mtval_set_en           ),
    .mtval_set_tval         (mtval_set_tval         ),
    // to pc
    .trap_happened          (trap_happened          ),
    .ctrl_pc                (ctrl_pc                ),
    // stall and flush
    .pc_stall               (pc_stall               ),
    .if_stall               (if_stall               ),
    .id_stall               (id_stall               ),
    .ex_stall               (ex_stall               ),
    .mem_stall              (mem_stall              ),
    .if_flush               (if_flush               ),
    .id_flush               (id_flush               ),
    .ex_flush               (ex_flush               ),
    .mem_flush              (mem_flush              ),
    // int clear
    .external_int_clear     (external_int_clear     ),
    .software_int_clear     (software_int_clear     ),
    .timer_int_clear        (timer_int_clear        )
);

endmodule
`endif