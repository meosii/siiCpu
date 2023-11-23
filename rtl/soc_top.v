`ifndef SOC_TOP
`define SOC_TOP
`include "define.v"
module soc_top (
    input wire                          cpu_en,
    input wire                          clk,
    input wire                          rst_n,
    //
    input wire                          io_rtcToggle,
    // insn and pc
    input  wire [`WORD_WIDTH - 1 : 0]   insn,
    output wire                         rd_insn_en,
    output wire [`PC_WIDTH - 1 : 0]     pc
);

wire [`WORD_WIDTH - 1 : 0]      D_HRDATA;
wire                            D_HREADY;
wire [1 : 0]                    D_HRESP;
wire [`WORD_WIDTH - 1 : 0]      D_HADDR;
wire                            D_HWRITE;
wire [2 : 0]                    D_HSIZE;
wire [2 : 0]                    D_HBURST;
wire [1 : 0]                    D_HTRANS;
wire                            D_HMASTLOCK;
wire [`WORD_WIDTH - 1 : 0]      D_HWDATA;
wire                            HSEL_1;         // clint
wire                            HSEL_2;         // plic
wire                            HSEL_3;         // uart0
wire                            HSEL_4;         // spi0
wire                            irq_external;   // from plic
wire                            irq_timer;      // from clint
wire                            irq_software;   // from clint
wire                            external_int_clear;
wire                            software_int_clear;
wire                            timer_int_clear;

assign                          irq_external = 1'b0;

pipeline_cpu_top u_pipeline_cpu_top(
    .cpu_en             (cpu_en             ),
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .irq_external       (irq_external       ),
    .irq_timer          (irq_timer          ),
    .irq_software       (irq_software       ),
    .insn               (insn               ),
    .rd_insn_en         (rd_insn_en         ),
    .pc                 (pc                 ),
    //ahb
    .D_HRDATA           (D_HRDATA           ),
    .D_HREADY           (D_HREADY           ),
    .D_HRESP            (D_HRESP            ),
    .D_HADDR            (D_HADDR            ),
    .D_HWRITE           (D_HWRITE           ),
    .D_HSIZE            (D_HSIZE            ),
    .D_HBURST           (D_HBURST           ),
    .D_HTRANS           (D_HTRANS           ),
    .D_HMASTLOCK        (D_HMASTLOCK        ),
    .D_HWDATA           (D_HWDATA           ),
    // int clear
    .external_int_clear (external_int_clear ),
    .software_int_clear (software_int_clear ),
    .timer_int_clear    (timer_int_clear    )
);

ahb_bus_decoder u_ahb_bus_decoder(
    .HADDR              (D_HADDR            ),
    .HSEL_1             (HSEL_1             ), // clint
    .HSEL_2             (HSEL_2             ), // plic
    .HSEL_3             (HSEL_3             ), // uart0
    .HSEL_4             (HSEL_4             )  // spi0
);

clint u_clint(
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .io_rtcToggle       (io_rtcToggle       ),   // async  
    .HSELx              (HSEL_1             ),
    .HADDR              (D_HADDR            ),
    .HWRITE             (D_HWRITE           ),
    .HSIZE              (D_HSIZE            ),
    .HBURST             (D_HBURST           ),   // not used
    .HTRANS             (D_HTRANS           ),
    .HMASTLOCK          (D_HMASTLOCK        ),   // not used
    .HWDATA             (D_HWDATA           ),
    .software_int_clear (software_int_clear ),
    .timer_int_clear    (timer_int_clear    ),
    // outputs
    .irq_timer          (irq_timer          ),
    .irq_software       (irq_software       ),
    .HRDATA             (D_HRDATA           ),
    .HREADY             (D_HREADY           ),
    .HRESP              (D_HRESP            )
);

endmodule
`endif