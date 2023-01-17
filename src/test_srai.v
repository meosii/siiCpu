`include "srai.v"
module test_srai ();
reg [15:0] shift;
reg [15:0] alu_in_1;
wire [15:0] alu_out;

srai u_srai(
    .shift(shift),
    .alu_in_1(alu_in_1),
    .alu_out(alu_out)
);

initial begin
    #0 begin
        shift = 3;
        alu_in_1 = 16'b0011_1010_1011_1101;
        #1 $display("%b",alu_out);
    end
    #10 begin
        shift = 7;
        alu_in_1 = 16'b0011_1010_1011_1101;
        #1 $display("%b",alu_out);
    end
    #10 begin
        shift = 2;
        alu_in_1 = 16'b0011_1010_1011_1101;
        #1 $display("%b",alu_out);
    end
    $finish;
end

initial begin
    $dumpfile("wave_srai.vcd");
    $dumpvars(0,test_srai);
end

endmodule