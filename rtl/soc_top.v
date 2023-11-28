`ifndef SOC_TOP
`define SOC_TOP
`include "define.v"
module soc_top (
    input wire                          CPU_EN,
    input wire                          CLK_IN,
    input wire                          RST_N,
    // outputs
    // uart
    output wire                         TX,
    // dtube
    output wire [7 : 0]                 DTUBE_HEX0,
    output wire [7 : 0]                 DTUBE_HEX1,
    output wire [7 : 0]                 DTUBE_HEX2,
    output wire [7 : 0]                 DTUBE_HEX3,
    output wire [7 : 0]                 DTUBE_HEX4,
    output wire [7 : 0]                 DTUBE_HEX5
);

// clock_manager
wire                            clk_50;         // 50MHz
wire                            clk_5;          // 5MHz
wire                            chip_rst_n;
wire                            io_rtcToggle;   // to clint timer
// itcm
wire [`WORD_WIDTH - 1 : 0]      insn;
wire                            rd_insn_en;
wire [`PC_WIDTH - 1 : 0]        pc;
// cpu
wire [`WORD_WIDTH - 1 : 0]      CPU_HRDATA;
wire                            CPU_HREADY;
wire [1 : 0]                    CPU_HRESP;
wire [`WORD_WIDTH - 1 : 0]      CPU_HADDR;
wire                            CPU_HWRITE;
wire [2 : 0]                    CPU_HSIZE;
wire [2 : 0]                    CPU_HBURST;
wire [1 : 0]                    CPU_HTRANS;
wire                            CPU_HMASTLOCK;
wire [`WORD_WIDTH - 1 : 0]      CPU_HWDATA;
// ahb decoder
wire                            HSEL_CLINT;         // clint
wire                            HSEL_PLIC;          // plic
wire                            HSEL_UART;          // uart0
wire                            HSEL_SPI;           // spi0
wire                            HSEL_DTUBE;
// clint
wire [`WORD_WIDTH - 1 : 0]      CLINT_HRDATA;
wire                            CLINT_HREADY;
wire [1 : 0]                    CLINT_HRESP;
// plic
wire [`WORD_WIDTH - 1 : 0]      PLIC_HRDATA;
wire                            PLIC_HREADY;
wire [1 : 0]                    PLIC_HRESP;
// uart
wire [`WORD_WIDTH - 1 : 0]      UART_HRDATA;
wire                            UART_HREADY;
wire [1 : 0]                    UART_HRESP;
// spi
wire [`WORD_WIDTH - 1 : 0]      SPI_HRDATA;
wire                            SPI_HREADY;
wire [1 : 0]                    SPI_HRESP;
// dtube
wire [`WORD_WIDTH - 1 : 0]      DTUBE_HRDATA;
wire                            DTUBE_HREADY;
wire [1 : 0]                    DTUBE_HRESP;
// interrupt
wire                            irq_external;   // from plic
wire                            irq_timer;      // from clint
wire                            irq_software;   // from clint
wire                            irq_uart;       // from uart
wire                            external_int_clear;
wire                            software_int_clear;
wire                            timer_int_clear;
wire                            uart_int_clear;

assign irq_external     = 1'b0;
assign uart_int_clear   = 1'b0;
assign PLIC_HRDATA  = 32'b0;
assign PLIC_HREADY  = 1'b0;
assign PLIC_HRESP   = `HRESP_ERROR;
assign SPI_HRDATA   = 32'b0;
assign SPI_HREADY   = 1'b0;
assign SPI_HRESP    = `HRESP_ERROR;

ip_itcm u_ip_itcm(
    .address    (pc[14:2]       ),
    .clock      (clk_50         ),
    .rden       (rd_insn_en     ),
    .q          (insn           )
);

clock_manager u_clock_manager(
    .CLK_IN         (CLK_IN         ),
    .RST_N          (RST_N          ),
    .clk_50         (clk_50         ),
    .clk_5          (clk_5          ),
    .chip_rst_n     (chip_rst_n     ),
    .io_rtcToggle   (io_rtcToggle   )
);

pipeline_cpu_top u_pipeline_cpu_top(
    .cpu_en             (CPU_EN             ),
    .clk                (clk_50             ),
    .rst_n              (chip_rst_n         ),
    .irq_external       (irq_external       ),
    .irq_timer          (irq_timer          ),
    .irq_software       (irq_software       ),
    .insn               (insn               ),
    .rd_insn_en         (rd_insn_en         ),
    .pc                 (pc                 ),
    //ahb
    .CPU_HRDATA         (CPU_HRDATA         ),
    .CPU_HREADY         (CPU_HREADY         ),
    .CPU_HRESP          (CPU_HRESP          ),
    // outputs
    .CPU_HADDR          (CPU_HADDR          ),
    .CPU_HWRITE         (CPU_HWRITE         ),
    .CPU_HSIZE          (CPU_HSIZE          ),
    .CPU_HBURST         (CPU_HBURST         ),
    .CPU_HTRANS         (CPU_HTRANS         ),
    .CPU_HMASTLOCK      (CPU_HMASTLOCK      ),
    .CPU_HWDATA         (CPU_HWDATA         ),
    // int clear
    .external_int_clear (external_int_clear ),
    .software_int_clear (software_int_clear ),
    .timer_int_clear    (timer_int_clear    )
);

ahb_bus_decoder u_ahb_bus_decoder(
    .clk                (clk_50             ),
    .rst_n              (chip_rst_n         ),
    // cpu
    .CPU_HADDR          (CPU_HADDR          ),
    // clint
    .CLINT_HRDATA       (CLINT_HRDATA       ),
    .CLINT_HREADY       (CLINT_HREADY       ),
    .CLINT_HRESP        (CLINT_HRESP        ),
    // plic
    .PLIC_HRDATA        (PLIC_HRDATA        ),
    .PLIC_HREADY        (PLIC_HREADY        ),
    .PLIC_HRESP         (PLIC_HRESP         ),
    // uart
    .UART_HRDATA        (UART_HRDATA        ),
    .UART_HREADY        (UART_HREADY        ),
    .UART_HRESP         (UART_HRESP         ),
    // spi
    .SPI_HRDATA         (SPI_HRDATA         ),
    .SPI_HREADY         (SPI_HREADY         ),
    .SPI_HRESP          (SPI_HRESP          ),
    // dtube
    .DTUBE_HRDATA       (DTUBE_HRDATA       ),
    .DTUBE_HREADY       (DTUBE_HREADY       ),
    .DTUBE_HRESP        (DTUBE_HRESP        ),
    // outputs
    .HSEL_CLINT         (HSEL_CLINT         ), // clint
    .HSEL_PLIC          (HSEL_PLIC          ), // plic
    .HSEL_UART          (HSEL_UART          ), // uart0
    .HSEL_SPI           (HSEL_SPI           ), // spi
    .HSEL_DTUBE         (HSEL_DTUBE         ), // dtube
    .CPU_HRDATA         (CPU_HRDATA         ),
    .CPU_HREADY         (CPU_HREADY         ),
    .CPU_HRESP          (CPU_HRESP          )
);

clint u_clint(
    .clk                (clk_50             ),
    .rst_n              (chip_rst_n         ),
    .io_rtcToggle       (io_rtcToggle       ),   // async  
    .HSELx              (HSEL_CLINT         ),
    .HADDR              (CPU_HADDR          ),
    .HWRITE             (CPU_HWRITE         ),
    .HSIZE              (CPU_HSIZE          ),
    .HBURST             (CPU_HBURST         ),   // not used
    .HTRANS             (CPU_HTRANS         ),
    .HMASTLOCK          (CPU_HMASTLOCK      ),   // not used
    .HWDATA             (CPU_HWDATA         ),
    .software_int_clear (software_int_clear ),
    .timer_int_clear    (timer_int_clear    ),
    // outputs
    .irq_timer          (irq_timer          ),
    .irq_software       (irq_software       ),
    .HRDATA             (CLINT_HRDATA       ),
    .HREADY             (CLINT_HREADY       ),
    .HRESP              (CLINT_HRESP        )
);

uart_tx u_uart_tx(
    .clk            (clk_50         ),
    .rst_n          (chip_rst_n     ),
    .HSELx          (HSEL_UART      ),
    .HADDR          (CPU_HADDR      ),
    .HWRITE         (CPU_HWRITE     ),
    .HSIZE          (CPU_HSIZE      ),
    .HBURST         (CPU_HBURST     ),
    .HTRANS         (CPU_HTRANS     ),
    .HMASTLOCK      (CPU_HMASTLOCK  ),
    .HWDATA         (CPU_HWDATA     ),
    .uart_int_clear (uart_int_clear ),
    // outputs
    .HRDATA         (UART_HRDATA    ),
    .HREADY         (UART_HREADY    ),
    .HRESP          (UART_HRESP     ),
    .TX             (TX             ),
    .irq_uart       (irq_uart       )
);

dtube u_dtube(
    .clk            (clk_50         ),
    .rst_n          (chip_rst_n     ),
    .HSELx          (HSEL_DTUBE     ),
    .HADDR          (CPU_HADDR      ),
    .HWRITE         (CPU_HWRITE     ),
    .HSIZE          (CPU_HSIZE      ),
    .HBURST         (CPU_HBURST     ),
    .HTRANS         (CPU_HTRANS     ),
    .HMASTLOCK      (CPU_HMASTLOCK  ),
    .HWDATA         (CPU_HWDATA     ),
    .HRDATA         (DTUBE_HRDATA   ),
    .HREADY         (DTUBE_HREADY   ),
    .HRESP          (DTUBE_HRESP    ),
    // outputs
    .DTUBE_HEX0     (DTUBE_HEX0     ),
    .DTUBE_HEX1     (DTUBE_HEX1     ),
    .DTUBE_HEX2     (DTUBE_HEX2     ),
    .DTUBE_HEX3     (DTUBE_HEX3     ),
    .DTUBE_HEX4     (DTUBE_HEX4     ),
    .DTUBE_HEX5     (DTUBE_HEX5     ) 
);

endmodule
`endif