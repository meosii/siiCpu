`ifndef SIICPU_CSR
`define SIICPU_CSR
`include "define.v"
// here, only machine mode is supported
module csr (
    input wire                              clk,
    input wire                              rst_n,

    input wire                              irq_external, // irq -> csr -> trap -> csr
    input wire                              irq_timer,
    input wire                              irq_software,
    // from cpu_ctrl
    input wire                              mstatus_mie_clear_en,
    input wire                              mstatus_mie_set_en,
    input wire                              mepc_set_en,
    input wire [`PC_WIDTH - 1 :0]           mepc_set_pc,
    input wire                              mcause_set_en,
    input wire [`CSR_LOCA_MCAUSE_EXPCODE]   mcause_set_cause,
    input wire                              mtval_set_en,
    input wire [`WORD_WIDTH - 1 : 0]        mtval_set_tval,
    // read and write csrs
    input wire                              csr_rd_en,
    input wire [`CSR_ADDR_WIDTH - 1 : 0]    csr_rd_addr,
    input wire                              csr_w_en,
    input wire [`CSR_ADDR_WIDTH - 1 : 0]    csr_w_addr,
    input wire [`WORD_WIDTH - 1 : 0]        csr_w_data,
    //outputs
    output reg [`WORD_WIDTH - 1 : 0]        csr_rd_data,
    //to cpu_ctrl
    output wire                             csr_mstatus_mpie,   // prev interrupt enable
    output wire                             csr_mstatus_mie,    // machine interrupt enable
    output wire                             csr_mie_meie,       // external interrupt enable
    output wire                             csr_mie_mtie,       // timer interrupt enable
    output wire                             csr_mie_msie,       // software interrupt enable
    output wire                             csr_mip_meip,
    output wire                             csr_mip_mtip,
    output wire                             csr_mip_msip,
    output wire [29 : 0]                    csr_mtvec_base,
    output wire [1 : 0]                     csr_mtvec_mode,
    output wire [`PC_WIDTH - 1 : 0]         csr_mepc_pc
);

// machine
reg [`WORD_WIDTH - 1 : 0] csr_mtvec;
reg [`WORD_WIDTH - 1 : 0] csr_mepc;
reg [`WORD_WIDTH - 1 : 0] csr_mcause;
reg [`WORD_WIDTH - 1 : 0] csr_mie;
reg [`WORD_WIDTH - 1 : 0] csr_mip;
reg [`WORD_WIDTH - 1 : 0] csr_mtval;
reg [`WORD_WIDTH - 1 : 0] csr_mscratch;
reg [`WORD_WIDTH - 1 : 0] csr_mstatus;

// to cpu_ctrl
assign csr_mstatus_mpie     = csr_mstatus[`CSR_LOCA_MSTATUS_MPIE];
assign csr_mstatus_mie      = csr_mstatus[`CSR_LOCA_MSTATUS_MIE];
assign csr_mie_meie         = csr_mie[`CSR_LOCA_MIE_MEIE];
assign csr_mie_mtie         = csr_mie[`CSR_LOCA_MIE_MTIE];
assign csr_mie_msie         = csr_mie[`CSR_LOCA_MIE_MSIE];
assign csr_mip_meip         = csr_mip[`CSR_LOCA_MIP_MEIP];
assign csr_mip_mtip         = csr_mip[`CSR_LOCA_MIP_MTIP];
assign csr_mip_msip         = csr_mip[`CSR_LOCA_MIP_MSIP];
assign csr_mtvec_base       = csr_mtvec[`CSR_LOCA_MTVEC_BASE];
assign csr_mtvec_mode       = csr_mtvec[`CSR_LOCA_MTVEC_MODE];
assign csr_mepc_pc          = csr_mepc;

// read
always @(*) begin
    if (csr_rd_en) begin
        case (csr_rd_addr)
            `CSR_ADDR_MTVEC:    csr_rd_data = csr_mtvec;
            `CSR_ADDR_MEPC:     csr_rd_data = csr_mepc;
            `CSR_ADDR_MCAUSE:   csr_rd_data = csr_mcause;
            `CSR_ADDR_MIE:      csr_rd_data = csr_mie;
            `CSR_ADDR_MIP:      csr_rd_data = csr_mip;
            `CSR_ADDR_MTVAL:    csr_rd_data = csr_mtval;
            `CSR_ADDR_MSCRATCH: csr_rd_data = csr_mscratch;
            `CSR_ADDR_MSTATUS:  csr_rd_data = csr_mstatus;
            default:            csr_rd_data = `WORD_WIDTH'b0;
        endcase
    end else begin
        csr_rd_data = `WORD_WIDTH'b0;
    end
end

// write

// mstatus = {SD(1), WPRI(8), TSR(1), TW(1), TVM(1), MXR(1), SUM(1), MPRV(1), XS(2), FS(2),
// MPP(2), WPRI(2), SPP(1), MPIE(1), WPRI(1), SPIE(1), UPIE(1),MIE(1), WPRI(1), SIE(1), UIE(1)}
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mstatus     <= {19'b0, `MSTATUS_MPP_MACHINE, 3'b0, `MSTATUS_MPIE_ON, 3'b0 ,`MSTATUS_MIE_OFF, 3'b0}; // resets to machine mode
    end else if (csr_w_en && (csr_w_addr == `CSR_ADDR_MSTATUS)) begin
        csr_mstatus     <= csr_w_data;
    end else if (mstatus_mie_clear_en) begin
        csr_mstatus     <= {19'b0, `MSTATUS_MPP_MACHINE, 3'b0, csr_mstatus_mie, 3'b0 ,`MSTATUS_MIE_OFF, 3'b0}; // interrupt nesting is not supported
    end else if (mstatus_mie_set_en) begin
        csr_mstatus     <= {19'b0, `MSTATUS_MPP_MACHINE, 3'b0, `MSTATUS_MPIE_ON, 3'b0 ,csr_mstatus_mpie, 3'b0};
    end
end

// mip: {WPRI[31:12], MEIP(1), WPRI(1), SEIP(1), UEIP(1), MTIP(1), WPRI(1), STIP(1), 
//      UTIP(1), MSIP(1), WPRI(1), SSIP(1), USIP(1)}
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mip <= {20'b0, `MIP_MEIP_OFF, 3'b0, `MIP_MTIP_OFF, 3'b0, `MIP_MSIP_OFF};
    end else begin
        csr_mip <= {20'b0, irq_external, 3'b0, irq_timer, 3'b0, irq_software};
    end
end

// mie: {WPRI[31:12], MEIE(1), WPRI(1), SEIE(1), UEIE(1), MTIE(1), WPRI(1), STIE(1), 
//      UTIE(1), MSIE(1), WPRI(1), SSIE(1), USIE(1)}
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mie <= {20'b0, `MIE_MEIE_OFF, 3'b0, `MIE_MTIE_OFF, 3'b0, `MIE_MSIE_OFF};
    end else if (csr_w_en && (csr_w_addr == `CSR_ADDR_MIE)) begin
        csr_mie <= csr_w_data;
    end
end

// mtvec: { base[31:2], mode[1:0]}
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mtvec <= {`MTVEC_RESET_BASE, `MTVEC_RESET_MODE};
    end else if (csr_w_en && (csr_w_addr == `CSR_ADDR_MTVEC)) begin
        csr_mtvec <= csr_w_data;
    end
end

// mepc: When a trap is taken into M-mode, mepc is written with the virtual address of the instruction
// that was interrupted or that encountered the exception.
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mepc <= 32'b0;
    end else if (mepc_set_en) begin
        csr_mepc <= {mepc_set_pc[`PC_WIDTH-1 : 2], 2'b0};
    end else if (csr_w_en && (csr_w_addr == `CSR_ADDR_MEPC)) begin
        csr_mepc <= {csr_w_data[`PC_WIDTH-1 : 2], 2'b0};
    end
end

// mcause: {interupt[31:30], Exception code}
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mcause <= 32'b0;
    end else if (mcause_set_en) begin
        csr_mcause <= mcause_set_cause;
    end else if (csr_w_en && (csr_w_addr == `CSR_ADDR_MCAUSE)) begin
        csr_mcause <= csr_w_data;
    end
end

// mtval: Machine Trap Value
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mtval <= 32'b0;
    end else if (mtval_set_en) begin
        csr_mtval <= mtval_set_tval;
    end else if (csr_w_en && (csr_w_addr == `CSR_ADDR_MTVAL)) begin
        csr_mtval <= csr_w_data;
    end
end

// mscratch: 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr_mscratch <= 32'b0;
    end else if (csr_w_en && (csr_w_addr == `CSR_ADDR_MSCRATCH)) begin
        csr_mscratch <= csr_w_data;
    end
end

endmodule
`endif