module srai (
    input wire [15:0] shift,
    input wire [15:0] alu_in_1,
    output reg [15:0] alu_out
);
integer i;
reg [15:0] in_1; 

always @* begin
    alu_out = alu_in_1;
    for (i = 0; i < shift; i = i + 1) begin
        alu_out = {alu_out[0],alu_out[15:1]};
    end
end
    
endmodule