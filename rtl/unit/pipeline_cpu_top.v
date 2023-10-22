`ifndef SIICPU_TOP
`define SIICPU_TOP
`include "define.v"
module pipeline_cpu_top (
    input wire                          cpu_en,
    input wire                          clk,
    input wire                          rst_n,
    //
    output wire                         rd_insn_en,
    output wire [`PC_WIDTH - 1 : 0]     pc,
    input  wire [`WORD_WIDTH - 1 : 0]   insn
);

assign rd_insn_en = (cpu_en)? 1'b1:1'b0;

//wire [`PC_WIDTH - 1 : 0]                pc;
//wire [`WORD_WIDTH - 1 : 0]              insn;
wire [`PC_WIDTH - 1 : 0]                if_pc;
wire [`WORD_WIDTH - 1 : 0]              if_insn;
wire [`PC_WIDTH - 1 : 0]                br_addr;
wire                                    br_taken;

wire                                    load_hazard_in_id_ex;
wire                                    load_hazard_in_ex_mem;
wire                                    contral_hazard;
wire [`WORD_WIDTH - 1 : 0]              store_data;

wire									if_en;
wire 								    id_en;
wire 								    ex_en;
wire									mem_en;

wire                                    pc_stall;
wire                                    if_stall;
wire                                    id_stall;
wire                                    ex_stall;
wire                                    mem_stall;

wire                                    if_flush;
wire                                    id_flush;
wire                                    ex_flush;
wire                                    mem_flush;

wire									gpr_we_;
wire									id_gpr_we_;
wire									ex_gpr_we_;
wire									mem_gpr_we_;
wire									miss_align;
wire                                    mem_we_en;
wire                                    mem_rd_en;
wire [3 : 0]                            store_byteena;
// id
wire [`PC_WIDTH - 1 : 0]                id_pc;
wire [`DATA_WIDTH_ALU_OP - 1 : 0]       id_alu_op;
wire [`WORD_WIDTH - 1 : 0]              id_alu_in_0;
wire [`WORD_WIDTH - 1 : 0]              id_alu_in_1;
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       id_mem_op;
wire [`WORD_WIDTH - 1 : 0]              id_store_data;
wire [3 : 0]                            id_store_byteena;
wire [`WORD_WIDTH - 1 : 0]              id_insn;
wire [`GPR_ADDR_WIDTH - 1 : 0]          id_dst_addr;
//gpr
wire [`GPR_ADDR_WIDTH - 1 : 0]          gpr_rd_addr_0;
wire [`GPR_ADDR_WIDTH - 1 : 0]          gpr_rd_addr_1;
wire [`WORD_WIDTH - 1 : 0]              gpr_rd_data_0;
wire [`WORD_WIDTH - 1 : 0]              gpr_rd_data_1;
wire [`GPR_ADDR_WIDTH - 1 : 0]          dst_addr;
wire [`WORD_WIDTH - 1 : 0]              gpr_wr_data;
wire [`WORD_WIDTH - 1 : 0]              load_data;
// alu
wire [`DATA_WIDTH_ALU_OP - 1 : 0]       alu_op;
wire [`WORD_WIDTH - 1 : 0]              alu_in_0;
wire [`WORD_WIDTH - 1 : 0]              alu_in_1;
wire [`WORD_WIDTH - 1 : 0]              alu_out;
// exe
wire [`WORD_WIDTH - 1 : 0]              ex_insn;
wire [`GPR_ADDR_WIDTH - 1 : 0]          ex_dst_addr;
wire [`PC_WIDTH - 1 : 0]                ex_pc;
wire [`WORD_WIDTH - 1 : 0]              ex_alu_out;
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       ex_mem_op;
wire [`WORD_WIDTH - 1 : 0]              ex_store_data;
wire [3 : 0]                            ex_store_byteena;
// mem_ctrl
wire [`DATA_WIDTH_MEM_OP - 1 : 0]       mem_op;
wire [`WORD_ADDR_BUS]                   mem_addr;
wire [`WORD_WIDTH - 1 : 0]              wr_data; // gpr to mem
wire [`WORD_WIDTH - 1 : 0]              spm_rd_data; // mem_to gpr
wire                                    load_after_store_en;
wire [`WORD_WIDTH - 1 : 0]              prev_ex_store_data;
// mem
wire [`PC_WIDTH - 1 : 0]                mem_pc;
wire [`WORD_WIDTH - 1 : 0]              mem_insn;
wire [`WORD_WIDTH - 1 : 0]              mem_alu_out;
wire [`GPR_ADDR_WIDTH - 1 : 0]          mem_dst_addr;
wire [`WORD_WIDTH - 1 : 0]              mem_load_data;
// ctrl
wire [`DATA_WIDTH_CTRL_OP - 1 : 0]      ctrl_op;
wire [`DATA_WIDTH_ISA_EXP - 1 : 0]      exp_code;

//ip_pll u_ip_pll(
//  .areset (rst_n  ),
//	.inclk0 (clk    ),
//	.c0     (clk_pll)
//);

pc u_pc(
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .cpu_en     (cpu_en     ),
    .pc_stall   (pc_stall   ),
    .br_addr    (br_addr    ),
    .br_taken   (br_taken   ),
    .pc         (pc         )
);

if_reg u_if_reg(
    .clk	    (clk        ),
    .rst_n		(rst_n	    ),
    .if_stall   (if_stall   ),
    .if_flush   (if_flush   ),
    .pc         (pc         ),
    .insn		(insn		),
    .if_pc		(if_pc	    ),
    .if_insn	(if_insn	),
    .if_en		(if_en	    )
);

decoder u_decoder(
    .pc                     (pc                     ),
    .if_en                  (if_en                  ),
    .if_pc                  (if_pc                  ),
    .if_insn                (if_insn                ),
    .gpr_rd_data_0          (gpr_rd_data_0          ),
    .gpr_rd_data_1          (gpr_rd_data_1          ),
    .gpr_rd_addr_0          (gpr_rd_addr_0          ),
    .gpr_rd_addr_1          (gpr_rd_addr_1          ),
    .dst_addr               (dst_addr               ),
    .gpr_we_                (gpr_we_                ),
    .alu_op                 (alu_op                 ),
    .alu_in_0               (alu_in_0               ),
    .alu_in_1               (alu_in_1               ),
    .br_addr                (br_addr                ),
    .br_taken               (br_taken               ),
    .mem_op                 (mem_op                 ),
    .store_data             (store_data             ), //to mem
    .store_byteena          (store_byteena          ),
    .id_en                  (id_en                  ),
    .id_insn                (id_insn                ),
    .id_gpr_we_             (id_gpr_we_             ),
    .id_dst_addr            (id_dst_addr            ),
    .alu_out                (alu_out                ),
    .ex_en                  (ex_en                  ),
    .ex_insn                (ex_insn                ),
    .ex_gpr_we_             (ex_gpr_we_             ),
    .ex_dst_addr            (ex_dst_addr            ),
    .ex_alu_out             (ex_alu_out             ),
    .mem_we_en              (mem_we_en              ),
    .load_after_store_en    (load_after_store_en    ),
    .prev_ex_store_data     (prev_ex_store_data     ),
    .ex_store_data          (ex_store_data          ),
    .exp_code               (exp_code               ),
    .load_hazard_in_id_ex   (load_hazard_in_id_ex   ),
    .load_hazard_in_ex_mem  (load_hazard_in_ex_mem  ),
    .contral_hazard         (contral_hazard         )
);

id_reg u_id_reg(
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .id_stall           (id_stall           ),
    .id_flush           (id_flush           ),
    //in
    .if_pc              (if_pc              ),
    .if_insn            (if_insn            ),
    .if_en              (if_en              ),
    .gpr_we_            (gpr_we_            ),
    .dst_addr           (dst_addr           ), 
    .alu_op             (alu_op             ),
    .alu_in_0           (alu_in_0           ),
    .alu_in_1           (alu_in_1           ),
    .mem_op             (mem_op             ),
    .store_data         (store_data         ),
    .store_byteena      (store_byteena      ),
    //out
    .id_pc              (id_pc              ),
    .id_insn            (id_insn            ),
    .id_en              (id_en              ),
    .id_gpr_we_         (id_gpr_we_         ),
    .id_dst_addr        (id_dst_addr        ),
    .id_alu_op          (id_alu_op          ),
    .id_alu_in_0        (id_alu_in_0        ),
    .id_alu_in_1        (id_alu_in_1        ),
    .id_mem_op          (id_mem_op          ),
    .id_store_data      (id_store_data      ),
    .id_store_byteena   (id_store_byteena   )
);

gpr u_gpr(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .we_        (mem_gpr_we_    ),
    .wr_addr    (mem_dst_addr   ),
    .wr_data    (gpr_wr_data    ),
    .rd_addr_0  (gpr_rd_addr_0  ),
    .rd_addr_1  (gpr_rd_addr_1  ),
    .rd_data_0  (gpr_rd_data_0  ),
    .rd_data_1  (gpr_rd_data_1  )
);

assign gpr_wr_data = (mem_insn[`ALL_TYPE_OPCODE] == `OP_LOAD)? load_data : mem_alu_out;

alu u_alu(
    .alu_op     (id_alu_op  ),
    .alu_in_0   (id_alu_in_0),
    .alu_in_1   (id_alu_in_1),
    .alu_out    (alu_out    )
);

ex_reg u_ex_reg(
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .ex_stall           (ex_stall           ),
    .ex_flush           (ex_flush           ),
    //in
    .id_pc              (id_pc              ),
    .id_insn            (id_insn            ),
    .id_en              (id_en              ),
    .alu_out            (alu_out            ),
    .id_gpr_we_         (id_gpr_we_         ),
    .id_dst_addr        (id_dst_addr        ),
    .id_mem_op          (id_mem_op          ),
    .id_store_data      (id_store_data      ),
    .id_store_byteena   (id_store_byteena   ),
    .ex_pc              (ex_pc              ),
    .ex_insn            (ex_insn            ),
    .ex_en              (ex_en              ),
    .ex_alu_out         (ex_alu_out         ),
    .ex_gpr_we_         (ex_gpr_we_         ),
    .ex_dst_addr        (ex_dst_addr        ),
    .ex_mem_op          (ex_mem_op          ),
    .ex_store_data      (ex_store_data      ),
    .ex_store_byteena   (ex_store_byteena   )
);

mem_ctrl u_mem_ctrl(
    //in
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .ex_insn                (ex_insn                ),
    .ex_mem_op              (ex_mem_op              ),
    .ex_alu_out             (ex_alu_out             ),
    .ex_store_data          (ex_store_data          ),
    .ex_store_byteena       (ex_store_byteena       ),
    .spm_rd_data            (spm_rd_data            ), //mem to gpr (spm_rd_data -> load_data)
    //out
    .mem_we_en              (mem_we_en              ),
    .mem_rd_en              (mem_rd_en              ),
    .mem_addr               (mem_addr               ), //from alu_out
    .load_data              (load_data              ),
    .prev_ex_store_data     (prev_ex_store_data     ),
    .load_after_store_en    (load_after_store_en    ),
    .miss_align             (miss_align             )
);

mem_reg u_mem_reg (
    //in
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .mem_stall      (mem_stall      ),
    .mem_flush      (mem_flush      ),
    .ex_pc          (ex_pc          ),
    .ex_insn        (ex_insn        ),
    .ex_en          (ex_en          ),
    .ex_alu_out     (ex_alu_out     ),
    .ex_dst_addr    (ex_dst_addr    ),
    .ex_gpr_we_     (ex_gpr_we_     ),
//    .load_data      (load_data      ),
    //out
    .mem_pc         (mem_pc         ),
    .mem_insn       (mem_insn       ),
    .mem_en         (mem_en         ),
    .mem_alu_out    (mem_alu_out    ),
    .mem_gpr_we_    (mem_gpr_we_    ),
    .mem_dst_addr   (mem_dst_addr   )
//    .mem_load_data  (mem_load_data  )
);

ip_spm u_ip_spm(
	.byteena_a  (ex_store_byteena    ),
	.clock      (clk                 ),
	.data       (ex_store_data       ),
	.rdaddress  (mem_addr[13 : 2]    ),
	.rden       (mem_rd_en           ),
	.wraddress  (mem_addr[13 : 2]    ),
	.wren       (mem_we_en           ),
	.q          (spm_rd_data            )
);

cpu_ctrl u_cpu_ctrl(
    .exp_code               (exp_code               ),
    .load_hazard_in_id_ex   (load_hazard_in_id_ex   ),
    .load_hazard_in_ex_mem  (load_hazard_in_ex_mem  ),
    .contral_hazard         (contral_hazard         ),
    .pc_stall               (pc_stall               ),
    .if_stall               (if_stall               ),
    .id_stall               (id_stall               ),
    .ex_stall               (ex_stall               ),
    .mem_stall              (mem_stall              ),
    .if_flush               (if_flush               ),
    .id_flush               (id_flush               ),
    .ex_flush               (ex_flush               ),
    .mem_flush              (mem_flush              )
);

endmodule
`endif