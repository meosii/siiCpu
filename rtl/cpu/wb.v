`ifndef SIICPU_WB
`define SIICPU_WB
`include "define.v"
module wb (
    input wire                              clk,
    input wire                              rst_n,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]    gpr_rd_addr_1,
    input wire                              predt_gpr_rd_en,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]    predt_gpr_rd_addr,
    input wire                              mem_gpr_we_n,
    input wire [`GPR_ADDR_WIDTH - 1 : 0]    mem_dst_addr,
    input wire                              mem_bus_ahb_enable,
    input wire                              trans_end_en,
    input wire                              ahb_bus_wait,
    input wire                              loading_after_store_en_r1,
    input wire [`WORD_WIDTH - 1 : 0]        mem_insn,
    input wire [`WORD_WIDTH - 1 : 0]        load_data,
    input wire [`WORD_WIDTH - 1 : 0]        mem_csr_to_gpr_data,
    input wire [`WORD_WIDTH - 1 : 0]        mem_alu_out,
    
    output wire                             wb_gpr_we_n,
    output wire [`GPR_ADDR_WIDTH - 1 :0]    wb_gpr_wr_addr,
    output wire [`WORD_WIDTH - 1 : 0]       wb_gpr_wr_data
);

reg                             gpr_we_n_r;
reg [`GPR_ADDR_WIDTH - 1 : 0]   dst_addr_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gpr_we_n_r <= 1'b1;
        dst_addr_r <= `GPR_ADDR_WIDTH'b0;
    end else if (!ahb_bus_wait) begin
        gpr_we_n_r <= mem_gpr_we_n;
        dst_addr_r <= mem_dst_addr;
    end
end

assign wb_gpr_we_n      =   (   !mem_bus_ahb_enable                                                             // 1. Do not read bus
                            || (mem_bus_ahb_enable && trans_end_en && !ahb_bus_wait)                            // 2. Read the bus in a single cycle
                            || loading_after_store_en_r1                            )?  mem_gpr_we_n :          // 3. loading_after_store
                                                                                    !(trans_end_en && !gpr_we_n_r);  // Reading the bus and requiring multiple cycles of wait

assign wb_gpr_wr_addr   =   (   !mem_bus_ahb_enable
                            || (mem_bus_ahb_enable && trans_end_en && !ahb_bus_wait)
                            || loading_after_store_en_r1                            )?  mem_dst_addr :
                                                                                        dst_addr_r;
                                                                                        
assign wb_gpr_wr_data   =   (!mem_bus_ahb_enable && (mem_insn[`ALL_TYPE_OPCODE] == `OP_LOAD)    )? load_data            : 
                            (!mem_bus_ahb_enable && (mem_insn[`ALL_TYPE_OPCODE] == `OP_SYSTEM)  )? mem_csr_to_gpr_data  : 
                            (!mem_bus_ahb_enable                                                )? mem_alu_out          : load_data;
									    
endmodule

`endif