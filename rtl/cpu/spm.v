`ifndef SIICPU_SPM
`define SIICPU_SPM

//Dual Port RAM
//One port for IF, the other for MEM

module spm #(
    parameter READ  = 1,
    parameter WRITE = 0
)(
    input wire              clk,
    input wire              rst_n,
    input wire  [31 : 0]    if_spm_addr,
    input wire              if_spm_as_,
    input wire              if_spm_rw,
    input wire  [31 : 0]    if_spm_wr_data,
    output wire [31 : 0]    if_spm_rd_data,
    input wire  [31 : 0]    mem_spm_addr,
    input wire              mem_spm_as_,
    input wire              mem_spm_rw,
    input wire  [31 : 0]    mem_spm_wr_data,
    output wire [31 : 0]    mem_spm_rd_data
);

reg [7 : 0] spm [0 : 1023];
integer i;

assign if_spm_rd_data   =   (!if_spm_as_ && (if_spm_rw == READ)) ?
                            {   spm[if_spm_addr], 
                                spm[if_spm_addr + 1], 
                                spm[if_spm_addr + 2], 
                                spm[if_spm_addr + 3]} : 32'b0;
assign mem_spm_rd_data  =   (!mem_spm_as_ && (mem_spm_rw == READ)) ? 
                            {   spm[mem_spm_addr],
                                spm[mem_spm_addr + 1], 
                                spm[mem_spm_addr + 2], 
                                spm[mem_spm_addr + 3] } : 32'b0;

//always @(posedge clk or negedge rst_n) begin
//    if (!rst_n) begin
//        for (i = 0; i < 1024;i = i + 1) begin
//            spm[i] <= 8'b0;
//        end
//    end else if (!mem_spm_as_ && (mem_spm_rw == WRITE)) begin
//        spm[mem_spm_addr]       <= mem_spm_wr_data[31 : 24];
//        spm[mem_spm_addr + 1]   <= mem_spm_wr_data[23 : 16];
//        spm[mem_spm_addr + 2]   <= mem_spm_wr_data[15 : 8];
//        spm[mem_spm_addr + 3]   <= mem_spm_wr_data[7 : 0];
//    end else if (!if_spm_as_ && (if_spm_rw == WRITE)) begin
//        spm[if_spm_addr]        <= if_spm_wr_data[31 : 24];
//        spm[if_spm_addr + 1]    <= if_spm_wr_data[23 : 16];
//        spm[if_spm_addr + 2]    <= if_spm_wr_data[15 : 8];
//        spm[if_spm_addr + 3]    <= if_spm_wr_data[7 : 0];
//    end
//end

always @(posedge clk) begin
    if (rst_n) begin
        if (!mem_spm_as_ && (mem_spm_rw == WRITE)) begin
            spm[mem_spm_addr]       <= mem_spm_wr_data[31 : 24];
            spm[mem_spm_addr + 1]   <= mem_spm_wr_data[23 : 16];
            spm[mem_spm_addr + 2]   <= mem_spm_wr_data[15 : 8];
            spm[mem_spm_addr + 3]   <= mem_spm_wr_data[7 : 0];
        end else if (!if_spm_as_ && (if_spm_rw == WRITE)) begin
            spm[if_spm_addr]        <= if_spm_wr_data[31 : 24];
            spm[if_spm_addr + 1]    <= if_spm_wr_data[23 : 16];
            spm[if_spm_addr + 2]    <= if_spm_wr_data[15 : 8];
            spm[if_spm_addr + 3]    <= if_spm_wr_data[7 : 0];
        end
    end
end

endmodule

`endif 