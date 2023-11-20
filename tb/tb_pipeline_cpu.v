`timescale 1ps/1ps
`include "../rtl/define.v"
module tb_pipeline_cpu ();

reg                         cpu_en;
reg                         clk;
reg                         rst_n;
reg                         irq_external;
reg                         irq_timer;
reg                         irq_software;
wire                        rd_insn_en;
wire [`PC_WIDTH - 1 : 0]    pc;
reg [`WORD_WIDTH - 1 : 0]   insn;
//ahb
reg [`WORD_WIDTH - 1 : 0]   D_HRDATA;
reg                         D_HREADY;
reg  [1 : 0]                D_HRESP;
wire [`WORD_WIDTH - 1 : 0]  D_HADDR;
wire                        D_HWRITE;
wire [2 : 0]                D_HSIZE;
wire [2 : 0]                D_HBURST;
wire [1 : 0]                D_HTRANS;
wire                        D_HMASTLOCK;
wire [`WORD_WIDTH - 1 : 0]  D_HWDATA;

pipeline_cpu_top u_pipeline_cpu_top(
    .cpu_en         (cpu_en         ),
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .irq_external   (irq_external   ),
    .irq_timer      (irq_timer      ),
    .irq_software   (irq_software   ),
    .insn           (insn           ),
    .rd_insn_en     (rd_insn_en     ),
    .pc             (pc             ),
    //ahb
    .D_HRDATA       (D_HRDATA       ),
    .D_HREADY       (D_HREADY       ),
    .D_HRESP        (D_HRESP        ),
    .D_HADDR        (D_HADDR        ),
    .D_HWRITE       (D_HWRITE       ),
    .D_HSIZE        (D_HSIZE        ),
    .D_HBURST       (D_HBURST       ),
    .D_HTRANS       (D_HTRANS       ),
    .D_HMASTLOCK    (D_HMASTLOCK    ),
    .D_HWDATA       (D_HWDATA       )
);
// ahb
integer i;
reg [31:0] ahb_bus_reg [0:1023];

wire ahb_write_en;
wire ahb_read_en;
assign ahb_write_en = (D_HTRANS == `HTRANS_NONSEQ) && (D_HWRITE == 1'b1);
assign ahb_read_en = (D_HTRANS == `HTRANS_NONSEQ) && (!D_HWRITE);
reg ahb_write_en_r1;
reg ahb_read_en_r1;
reg [`WORD_WIDTH - 1 : 0] D_HADDR_r1;
reg [`WORD_WIDTH - 1 : 0] D_HADDR_r2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ahb_write_en_r1 <= 1'b0;
        ahb_read_en_r1 <= 1'b0;
        D_HADDR_r1      <= 32'b0;
        D_HADDR_r2      <= 32'b0;
    end else begin
        ahb_write_en_r1 <= ahb_write_en;
        ahb_read_en_r1 <= ahb_read_en;
        D_HADDR_r1      <= D_HADDR;
        D_HADDR_r2      <= D_HADDR_r1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i=0; i<1024;i=i+1) begin
            ahb_bus_reg[i] <= 32'b0;
        end
    end else if (ahb_write_en_r1) begin
        ahb_bus_reg[D_HADDR_r1[11:2]] <= D_HWDATA;
    end
end

/*
// The slave does not need to wait
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        D_HREADY <= 1'b0;
        D_HRESP  <= `HRESP_OKAY;
    end else if (D_HTRANS == `HTRANS_NONSEQ) begin
        D_HREADY <= 1'b1;
        D_HRESP  <= `HRESP_OKAY;
    end else begin
        D_HREADY <= 1'b0;
        D_HRESP  <= `HRESP_OKAY;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        D_HRDATA <= 32'b0;
    end else if ((D_HTRANS == `HTRANS_NONSEQ) && (!D_HWRITE)) begin
        D_HRDATA <= ahb_bus_reg[D_HADDR[11:2]];
    end else begin
        D_HRDATA <= 32'b0;
    end
end

*/

// Reading slave needs to wait for one cycle
// Writing to the slave does not require waiting
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        D_HREADY <= 1'b0;
        D_HRESP  <= `HRESP_OKAY;
    end else if (ahb_write_en || ahb_read_en_r1) begin
        D_HREADY <= 1'b1;
        D_HRESP  <= `HRESP_OKAY;
    end else begin
        D_HREADY <= 1'b0;
        D_HRESP  <= `HRESP_OKAY;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        D_HRDATA <= 32'b0;
    end else if (ahb_read_en_r1) begin
        D_HRDATA <= ahb_bus_reg[D_HADDR_r1[11:2]];
    end else begin
        D_HRDATA <= 32'b0;
    end
end

//
parameter TIME_CLK = 10;

always #(TIME_CLK/2) clk = ~clk;

reg [31:0] itcm [0:1023];

initial begin
    $readmemh("itcm.hex", itcm);
end

always @(*) begin
    if (rd_insn_en) begin
        insn = itcm[pc[11:2]];
    end else begin
        insn = 0;
    end
end

initial begin
    #0 begin
        clk = 0;
        cpu_en = 0;
        rst_n = 0;
        irq_external = 0;
        irq_timer = 0;
        irq_software = 0;
    end
    #22 begin
        rst_n = 1;
    end
    // after itcm has insn
    #20 begin
       cpu_en = 1; 
    end
    #1000
    $finish;
end

initial begin
    $dumpfile("pipeline_cpu.vcd");
    $dumpvars(0,tb_pipeline_cpu);
end

endmodule