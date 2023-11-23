`timescale 1ps/1ps
`include "../rtl/define.v"
module tb_soc ();

reg                         cpu_en;
reg                         clk;
reg                         rst_n;
reg                         io_rtcToggle;
wire                        rd_insn_en;
wire [`PC_WIDTH - 1 : 0]    pc;
reg [`WORD_WIDTH - 1 : 0]   insn;

soc_top u_soc_top(
    .cpu_en         (cpu_en         ),
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .io_rtcToggle   (io_rtcToggle   ),
    .rd_insn_en     (rd_insn_en     ),
    .pc             (pc             ),
    .insn           (insn           )
);
reg [7 : 0] counter;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 8'b0;
    end else begin
        counter <= counter + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        io_rtcToggle <= 1'b0;
    end else if (counter == 8'h11) begin
        io_rtcToggle <= 1'b1;
    end else begin
        io_rtcToggle <= 1'b0;
    end
end

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
    end
    #22 begin
        rst_n = 1;
    end
    // after itcm has insn
    #20 begin
       cpu_en = 1; 
    end
    #10000
    $finish;
end

initial begin
    $dumpfile("soc.vcd");
    $dumpvars(0,tb_soc);
end

endmodule