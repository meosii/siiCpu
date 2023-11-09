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

pipeline_cpu_top u_pipeline_cpu_top(
    .cpu_en         (cpu_en         ),
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .irq_external   (irq_external   ),
    .irq_timer      (irq_timer      ),
    .irq_software   (irq_software   ),
    .insn           (insn           ),
    .rd_insn_en     (rd_insn_en     ),
    .pc             (pc             )
);

parameter TIME_CLK = 10;

always #(TIME_CLK/2) clk = ~clk;

reg [31:0] disk [0:1024];

initial begin
    $readmemh("disk.hex", disk);
end

always @(*) begin
    if (rd_insn_en) begin
        insn = disk[pc[11:2]];
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
    // after disk has insn
    #20 begin
       cpu_en = 1; 
    end
    #100000
    $finish;
end

initial begin
    $dumpfile("pipeline_cpu.vcd");
    $dumpvars(0,tb_pipeline_cpu);
end

endmodule