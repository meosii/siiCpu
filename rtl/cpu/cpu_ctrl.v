`ifndef CPU_CTRL
`define CPU_CTRL
`include "define.v"

module cpu_ctrl (
    input wire                                  clk,
    input wire                                  rst_n,
    input wire [`PC_WIDTH - 1 : 0]              id_pc,
    input wire [`PC_WIDTH - 1 : 0]              mem_pc,
    // hazard from decoder
    input wire                                  load_hazard_in_id_ex,
    input wire                                  load_hazard_in_ex_mem,
    input wire                                  contral_hazard,
    // ahb bus
    input wire                                  ahb_bus_wait,
    // exception excuted in the mem stage
    // exception
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    exp_code,               // from decoder
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    ex_exp_code_mem_ctrl,   // from mem_ctrl
    input wire [`DATA_WIDTH_ISA_EXP - 1 : 0]    mem_exp_code,
    // ebreak, ecall and mret
    input wire                                  ebreak_en,              // from decoder
    input wire                                  ecall_en,               // from decoder
    input wire                                  mret_en,                // from decoder
    input wire                                  mem_ebreak_en,
    input wire                                  mem_ecall_en,
    // signals from csr
    input wire                                  csr_mstatus_mpie,   // prev interrupt enable
    input wire                                  csr_mstatus_mie,    // machine interrupt enable
    input wire                                  csr_mie_meie,       // external interrupt enable
    input wire                                  csr_mie_mtie,       // timer interrupt enable
    input wire                                  csr_mie_msie,       // software interrupt enable
    input wire                                  csr_mip_meip,       // external interrupt pending
    input wire                                  csr_mip_mtip,       // timer interrupt pending
    input wire                                  csr_mip_msip,       // software interrupt pending
    input wire [29 : 0]                         csr_mtvec_base,     // jump pc_base
    input wire [1 : 0]                          csr_mtvec_mode,     // jump pc_mode
    input wire [`PC_WIDTH - 1 : 0]              csr_mepc_pc,        // restore pc
    // outputs
    // to csr
    output reg                                  mstatus_mie_clear_en,
    output reg                                  mstatus_mie_set_en,
    output reg                                  mepc_set_en,
    output reg [`PC_WIDTH - 1 :0]               mepc_set_pc,
    output reg                                  mcause_set_en,
    output reg [`WORD_WIDTH - 1 : 0]            mcause_set_cause,
    output reg                                  mtval_set_en,
    output reg [`WORD_WIDTH - 1 : 0]            mtval_set_tval,
    // to pc
    output wire                                 trap_happened,
    output reg [`PC_WIDTH - 1 : 0]              ctrl_pc,
    // to all registers
    output wire                                 pc_stall,
    output wire                                 if_stall,
    output wire                                 id_stall,
    output wire                                 ex_stall,
    output wire                                 mem_stall,
    output wire                                 if_flush,
    output wire                                 id_flush,
    output wire                                 ex_flush,
    output wire                                 mem_flush,
    // to clint
    output reg                                  external_int_clear,
    output reg                                  software_int_clear,
    output reg                                  timer_int_clear
);

wire    exp_in_decoder;
wire    exp_in_alu;
wire    exp_in_mem_ctrl;

assign  exp_in_decoder  =   ebreak_en || ecall_en || (exp_code == `ISA_EXP_UNDEF_INSN);
assign  exp_in_alu      =   1'b0; //resevered
assign  exp_in_mem_ctrl =   (ex_exp_code_mem_ctrl   == `ISA_EXP_LOAD_MISALIGNED )   ||
                            (ex_exp_code_mem_ctrl   == `ISA_EXP_STORE_MISALIGNED);

// trap
wire        external_int_en;
wire        timer_int_en;
wire        software_int_en;
wire        interrupt_en;
wire        exception_mem_en;
wire        mcause_set_cause_interrupt;
wire [30:0] mcause_set_cause_expcode;
reg [2:0]   int_handler; //int_handler = {timer_int_handler, software_int_handler, external_int_handler};

assign external_int_en  = csr_mstatus_mie && (csr_mie_meie && csr_mip_meip);
assign timer_int_en     = csr_mstatus_mie && (csr_mie_mtie && csr_mip_mtip);
assign software_int_en  = csr_mstatus_mie && (csr_mie_msie && csr_mip_msip);
assign interrupt_en     = external_int_en || timer_int_en|| software_int_en;
assign exception_mem_en = (mem_exp_code != `ISA_EXP_NO_EXP) || mem_ecall_en || mem_ebreak_en;
assign trap_happened    =  exception_mem_en || interrupt_en;

assign mcause_set_cause_interrupt = (interrupt_en       )? `MCAUSE_INTERRUPT :
                                    (exception_mem_en   )? `MCAUSE_EXCEPTION : 1'b0;

assign mcause_set_cause_expcode =   (external_int_en                            )?      `MCAUSE_MACHINE_EXTERNAL_INT        :
                                    (timer_int_en                               )?      `MCAUSE_MACHINE_TIMER_INT           :
                                    (software_int_en                            )?      `MCAUSE_MACHINE_SOFTWARE_INT        :
                                    (mem_ecall_en                               )?      `MCAUSE_ENVIRONMENT_CALL_FROM_M_MODE:
                                    (mem_ebreak_en                              )?      `MCAUSE_BREAKPOINT                  :
                                    (mem_exp_code == `ISA_EXP_UNDEF_INSN        )?      `MCAUSE_ILLEGAL_INSTRUCTION         :
                                    (mem_exp_code == `ISA_EXP_ALU_OVERFLOW      )?      `MCAUSE_ALU_OVERFLOW                :
                                    (mem_exp_code == `ISA_EXP_LOAD_MISALIGNED   )?      `MCAUSE_LOAD_ADDRESS_MISALIGNED     :
                                    (mem_exp_code == `ISA_EXP_STORE_MISALIGNED  )?      `MCAUSE_STORE_ADDRESS_MISALIGNED    : 31'b0;

// int_clear
// which kind of int is handling
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int_handler <= 3'b000;
    end else if (external_int_en) begin     // External interrupt handler begins
        int_handler <= 3'b001;
    end else if (software_int_en) begin     // Software interrupt handler begins
        int_handler <= 3'b010;
    end else if (timer_int_en) begin        // Timer interrupt handler begins
        int_handler <= 3'b100;
    end else if (mret_en) begin             // The interrupt handler completes
        int_handler <= 3'b000;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        external_int_clear <= 1'b0;
    end else if (int_handler[0] && mret_en) begin   // The external interrupt handler completes
        external_int_clear <= 1'b1;                 // Hardware reset
    end else if (!csr_mip_meip) begin               // Software also writes registers in interrupt handlers to clear interrupts
        external_int_clear <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        software_int_clear <= 1'b0;
    end else if (int_handler[1] && mret_en) begin   // The software interrupt handler completes
        software_int_clear <= 1'b1;
    end else if (!csr_mip_msip) begin
        software_int_clear <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timer_int_clear <= 1'b0;
    end else if (int_handler[2] && mret_en) begin   // The timer interrupt handler completes
        timer_int_clear <= 1'b1;
    end else if (!csr_mip_mtip) begin
        timer_int_clear <= 1'b0;
    end
end                     

always @(*) begin
    if (trap_happened) begin
            mstatus_mie_clear_en    = `ENABLE;
            mstatus_mie_set_en      = `DISABLE;
            mepc_set_en             = `ENABLE;
            mepc_set_pc             = (interrupt_en)? id_pc : mem_pc; // if exp is ecall, ebreak··· soft will change pc as (pc + 4)
            mcause_set_en           = `ENABLE;
            mcause_set_cause        = {mcause_set_cause_interrupt, mcause_set_cause_expcode};
            mtval_set_en            = `DISABLE; // reserved
            mtval_set_tval          = 32'b0;    // reserved
            ctrl_pc                 = (csr_mtvec_mode == `MTVEC_MODE_DIRECT)?   {csr_mtvec_base, 2'b00} :
                                                                                {csr_mtvec_base, 2'b00} + (mcause_set_cause_expcode << 2);
    end else if (mret_en) begin
            mstatus_mie_clear_en    = `DISABLE;
            mstatus_mie_set_en      = `ENABLE;
            mepc_set_en             = `DISABLE;
            mepc_set_pc             = 32'b0;
            mcause_set_en           = `DISABLE;
            mcause_set_cause        = 32'b0;
            mtval_set_en            = `DISABLE;
            mtval_set_tval          = 32'b0;
            ctrl_pc                 = csr_mepc_pc;
    end else begin
            mstatus_mie_clear_en    = `DISABLE;
            mstatus_mie_set_en      = `DISABLE;
            mepc_set_en             = `DISABLE;
            mepc_set_pc             = 32'b0;
            mcause_set_en           = `DISABLE;
            mcause_set_cause        = 32'b0;
            mtval_set_en            = `DISABLE;
            mtval_set_tval          = 32'b0;
            ctrl_pc                 = 32'b0;
    end
end

// stall and flush
assign pc_stall = load_hazard_in_id_ex || load_hazard_in_ex_mem || ahb_bus_wait; 
assign if_stall = load_hazard_in_id_ex || load_hazard_in_ex_mem || ahb_bus_wait; 
assign id_stall = ahb_bus_wait; 
assign ex_stall = ahb_bus_wait; 
assign mem_stall = ahb_bus_wait; 

assign if_flush =   contral_hazard  ||                                  // hazard in decoder
                    exp_in_decoder  || exp_in_alu || exp_in_mem_ctrl || // exception happened in each stage
                    trap_happened;                                      // pc jump after mem_stage

assign id_flush =   load_hazard_in_id_ex || load_hazard_in_ex_mem ||    // hazard in decoder
                    exp_in_alu || exp_in_mem_ctrl ||                    // exception happened in each stage
                    trap_happened;                                      // pc jump after mem_stage

assign ex_flush =   exp_in_alu || exp_in_mem_ctrl ||                    // exception happened in each stage
                    trap_happened;                                      // pc jump after mem_stage

assign mem_flush =  exp_in_mem_ctrl ||                                  // exception happened in each stage
                    exception_mem_en;                                   // exception happened: pc jump after mem_stage

endmodule
`endif