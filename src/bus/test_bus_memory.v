`include "bus_top.v"
`include "../memory.v"

module test_bus_memory ();

reg clk;
reg rst_;
reg master_0_req;
reg master_1_req;
reg master_2_req;
reg master_3_req;
reg master_0_as;
reg master_1_as;
reg master_2_as;
reg master_3_as;
reg [`ADDR_WIDTH - 1:0] master_0_addr;
reg [`ADDR_WIDTH - 1:0] master_1_addr;
reg [`ADDR_WIDTH - 1:0] master_2_addr;
reg [`ADDR_WIDTH - 1:0] master_3_addr;
reg master_0_wr;
reg master_1_wr;
reg master_2_wr;
reg master_3_wr;
reg [`DATA_WIDTH - 1:0] master_0_wr_data;
reg [`DATA_WIDTH - 1:0] master_1_wr_data;
reg [`DATA_WIDTH - 1:0] master_2_wr_data;
reg [`DATA_WIDTH - 1:0] master_3_wr_data;
wire master_0_grnt;
wire master_1_grnt;
wire master_2_grnt;
wire master_3_grnt;
wire slave_as;
wire [`ADDR_WIDTH - 1:0] slave_addr;
wire slave_wr;
wire [`DATA_WIDTH - 1:0] slave_wr_data;
wire slave_0_cs;
wire slave_1_cs;
wire slave_2_cs;
wire slave_3_cs;
wire slave_4_cs;
wire slave_5_cs;
wire slave_6_cs;
wire slave_7_cs;
reg slave_0_rdy;
reg slave_1_rdy;
reg slave_2_rdy;
reg slave_3_rdy;
reg slave_4_rdy;
reg slave_5_rdy;
reg slave_6_rdy;
reg slave_7_rdy;
wire [`DATA_WIDTH - 1:0] slave_0_out_data;
reg [`DATA_WIDTH - 1:0] slave_1_out_data;
reg [`DATA_WIDTH - 1:0] slave_2_out_data;
reg [`DATA_WIDTH - 1:0] slave_3_out_data;
reg [`DATA_WIDTH - 1:0] slave_4_out_data;
reg [`DATA_WIDTH - 1:0] slave_5_out_data;
reg [`DATA_WIDTH - 1:0] slave_6_out_data;
reg [`DATA_WIDTH - 1:0] slave_7_out_data;
wire master_rdy;
wire [`DATA_WIDTH - 1:0] master_data;

wire slave_as_;

bus_top u_bus_top(
    .clk(clk),
    .rst_(rst_),
    .master_0_req(master_0_req),
    .master_1_req(master_1_req),
    .master_2_req(master_2_req),
    .master_3_req(master_3_req),
    .master_0_as(master_0_as), 
    .master_1_as(master_1_as),
    .master_2_as(master_2_as),
    .master_3_as(master_3_as),
    .master_0_addr(master_0_addr),
    .master_1_addr(master_1_addr),
    .master_2_addr(master_2_addr),
    .master_3_addr(master_3_addr),
    .master_0_wr(master_0_wr),
    .master_1_wr(master_1_wr),
    .master_2_wr(master_2_wr),
    .master_3_wr(master_3_wr),
    .master_0_wr_data(master_0_wr_data),
    .master_1_wr_data(master_1_wr_data),
    .master_2_wr_data(master_2_wr_data),
    .master_3_wr_data(master_3_wr_data),
    .master_0_grnt(master_0_grnt),
    .master_1_grnt(master_1_grnt),
    .master_2_grnt(master_2_grnt),
    .master_3_grnt(master_3_grnt),
    .slave_as(slave_as), 
    .slave_addr(slave_addr),
    .slave_wr(slave_wr),
    .slave_wr_data(slave_wr_data),
    .slave_0_cs(slave_0_cs),
    .slave_1_cs(slave_1_cs),
    .slave_2_cs(slave_2_cs),
    .slave_3_cs(slave_3_cs),
    .slave_4_cs(slave_4_cs),
    .slave_5_cs(slave_5_cs),
    .slave_6_cs(slave_6_cs),
    .slave_7_cs(slave_7_cs),
    .slave_0_rdy(slave_0_rdy),
    .slave_1_rdy(slave_1_rdy),
    .slave_2_rdy(slave_2_rdy),
    .slave_3_rdy(slave_3_rdy),
    .slave_4_rdy(slave_4_rdy),
    .slave_5_rdy(slave_5_rdy),
    .slave_6_rdy(slave_6_rdy),
    .slave_7_rdy(slave_7_rdy),
    .slave_0_out_data(slave_0_out_data),
    .slave_1_out_data(slave_1_out_data),
    .slave_2_out_data(slave_2_out_data),
    .slave_3_out_data(slave_3_out_data),
    .slave_4_out_data(slave_4_out_data),
    .slave_5_out_data(slave_5_out_data),
    .slave_6_out_data(slave_6_out_data),
    .slave_7_out_data(slave_7_out_data),
    .master_rdy(master_rdy),
    .master_data(master_data)
);

assign slave_as_ = !slave_as;

memory u_memory(
    .clk(clk),
    .rst_(rst_),
    .if_memory_addr(slave_addr[11:0]),
    .if_memory_as_(slave_as_),
    .if_memory_rw(slave_wr),
    .if_memory_wr_data(slave_wr_data),
    .if_memory_rd_data(slave_0_out_data)
);

parameter TIMECLK = 10;

always #(TIMECLK/2) clk = ~clk;

initial begin
    #0 begin
        clk = 0;
        rst_ = 0;
    end
    #1 begin
        rst_ = 1;
        master_0_req = 0;
        master_1_req = 1;
        master_2_req = 1;
        master_3_req = 1;
        master_0_as = 0;
        master_1_as = 1;
        master_2_as = 1;
        master_3_as = 1;
        master_0_addr = 30'b00_0000_0000_0000_0000_0000_0000_0000;
        master_1_addr = 30'b00_1000_0000_0000_0000_0000_0000_0000;
        master_2_addr = 30'b01_0000_0000_0000_0000_0000_0000_0000;
        master_3_addr = 30'b01_1000_0000_0000_0000_0000_0000_0000;
        master_0_wr = `READ;
        master_1_wr = `READ;
        master_2_wr = `READ;
        master_3_wr = `READ;
        master_0_wr_data = 0;
        master_1_wr_data = 0;
        master_2_wr_data = 0;
        master_3_wr_data = 0;
        slave_0_rdy = 1;
        slave_1_rdy = 1;
        slave_2_rdy = 1;
        slave_3_rdy = 1;
        slave_4_rdy = 1;
        slave_5_rdy = 1;
        slave_6_rdy = 1;
        slave_7_rdy = 1;
        slave_1_out_data = 1;
        slave_2_out_data = 2;
        slave_3_out_data = 3;
        slave_4_out_data = 4;
        slave_5_out_data = 5;
        slave_6_out_data = 6;
        slave_7_out_data = 7;
    end
    #TIMECLK begin
        master_0_req = 1;
        master_1_req = 0;
        master_2_req = 1;
        master_3_req = 1;
        master_0_as = 1;
        master_1_as = 0;
        master_2_as = 1;
        master_3_as = 1;
        master_0_addr = 30'b00_0000_0000_0000_0000_0000_0000_0000;
        master_1_addr = 30'b00_1000_0000_0000_0000_0000_0000_0000;
        master_2_addr = 30'b01_0000_0000_0000_0000_0000_0000_0000;
        master_3_addr = 30'b01_1000_0000_0000_0000_0000_0000_0000;
        master_0_wr = `READ;
        master_1_wr = `READ;
        master_2_wr = `READ;
        master_3_wr = `READ;
        master_0_wr_data = 0;
        master_1_wr_data = 0;
        master_2_wr_data = 0;
        master_3_wr_data = 0;
        slave_0_rdy = 1;
        slave_1_rdy = 1;
        slave_2_rdy = 1;
        slave_3_rdy = 1;
        slave_4_rdy = 1;
        slave_5_rdy = 1;
        slave_6_rdy = 1;
        slave_7_rdy = 1;
        slave_1_out_data = 1;
        slave_2_out_data = 2;
        slave_3_out_data = 3;
        slave_4_out_data = 4;
        slave_5_out_data = 5;
        slave_6_out_data = 6;
        slave_7_out_data = 7;
    end
    #TIMECLK begin
        master_0_req = 1;
        master_1_req = 1;
        master_2_req = 0;
        master_3_req = 1;
        master_0_as = 1;
        master_1_as = 1;
        master_2_as = 0;
        master_3_as = 1;
        master_0_addr = 30'b00_0000_0000_0000_0000_0000_0000_0000;
        master_1_addr = 30'b00_1000_0000_0000_0000_0000_0000_0000;
        master_2_addr = 30'b01_0000_0000_0000_0000_0000_0000_0000;
        master_3_addr = 30'b01_1000_0000_0000_0000_0000_0000_0000;
        master_0_wr = `READ;
        master_1_wr = `READ;
        master_2_wr = `READ;
        master_3_wr = `READ;
        master_0_wr_data = 0;
        master_1_wr_data = 0;
        master_2_wr_data = 0;
        master_3_wr_data = 0;
        slave_0_rdy = 1;
        slave_1_rdy = 1;
        slave_2_rdy = 1;
        slave_3_rdy = 1;
        slave_4_rdy = 1;
        slave_5_rdy = 1;
        slave_6_rdy = 1;
        slave_7_rdy = 1;
        slave_1_out_data = 1;
        slave_2_out_data = 2;
        slave_3_out_data = 3;
        slave_4_out_data = 4;
        slave_5_out_data = 5;
        slave_6_out_data = 6;
        slave_7_out_data = 7;
    end
    #TIMECLK begin
        master_0_req = 1;
        master_1_req = 1;
        master_2_req = 1;
        master_3_req = 0;
        master_0_as = 1;
        master_1_as = 1;
        master_2_as = 1;
        master_3_as = 0;
        master_0_addr = 30'b00_0000_0000_0000_0000_0000_0000_0000;
        master_1_addr = 30'b00_1000_0000_0000_0000_0000_0000_0000;
        master_2_addr = 30'b01_0000_0000_0000_0000_0000_0000_0000;
        master_3_addr = 30'b01_1000_0000_0000_0000_0000_0000_0000;
        master_0_wr = `READ;
        master_1_wr = `READ;
        master_2_wr = `READ;
        master_3_wr = `READ;
        master_0_wr_data = 0;
        master_1_wr_data = 0;
        master_2_wr_data = 0;
        master_3_wr_data = 0;
        slave_0_rdy = 1;
        slave_1_rdy = 1;
        slave_2_rdy = 1;
        slave_3_rdy = 1;
        slave_4_rdy = 1;
        slave_5_rdy = 1;
        slave_6_rdy = 1;
        slave_7_rdy = 1;
        slave_1_out_data = 1;
        slave_2_out_data = 2;
        slave_3_out_data = 3;
        slave_4_out_data = 4;
        slave_5_out_data = 5;
        slave_6_out_data = 6;
        slave_7_out_data = 7;
    end
    #TIMECLK begin
        master_0_req = 0;
        master_1_req = 1;
        master_2_req = 1;
        master_3_req = 1;
        master_0_as = 0;
        master_1_as = 1;
        master_2_as = 1;
        master_3_as = 1;
        master_0_addr = 30'b00_0000_0000_0000_0000_0000_0000_0000;
        master_1_addr = 30'b00_1000_0000_0000_0000_0000_0000_0000;
        master_2_addr = 30'b01_0000_0000_0000_0000_0000_0000_0000;
        master_3_addr = 30'b01_1000_0000_0000_0000_0000_0000_0000;
        master_0_wr = `READ;
        master_1_wr = `READ;
        master_2_wr = `READ;
        master_3_wr = `READ;
        master_0_wr_data = 0;
        master_1_wr_data = 0;
        master_2_wr_data = 0;
        master_3_wr_data = 0;
        slave_0_rdy = 1;
        slave_1_rdy = 1;
        slave_2_rdy = 1;
        slave_3_rdy = 1;
        slave_4_rdy = 1;
        slave_5_rdy = 1;
        slave_6_rdy = 1;
        slave_7_rdy = 1;
        slave_1_out_data = 1;
        slave_2_out_data = 2;
        slave_3_out_data = 3;
        slave_4_out_data = 4;
        slave_5_out_data = 5;
        slave_6_out_data = 6;
        slave_7_out_data = 7;
    end
    #TIMECLK begin
        master_0_req = 0;
        master_1_req = 0;
        master_2_req = 0;
        master_3_req = 1;
        master_0_as = 0;
        master_1_as = 0;
        master_2_as = 0;
        master_3_as = 1;
        master_0_addr = 30'b00_0000_0000_0000_0000_0000_0000_0000;
        master_1_addr = 30'b00_1000_0000_0000_0000_0000_0000_0000;
        master_2_addr = 30'b01_0000_0000_0000_0000_0000_0000_0000;
        master_3_addr = 30'b00_0000_0000_0000_0000_0000_0000_0000;
        master_0_wr = `READ;
        master_1_wr = `READ;
        master_2_wr = `READ;
        master_3_wr = `READ;
        master_0_wr_data = 0;
        master_1_wr_data = 0;
        master_2_wr_data = 0;
        master_3_wr_data = 0;
        slave_0_rdy = 1;
        slave_1_rdy = 1;
        slave_2_rdy = 1;
        slave_3_rdy = 1;
        slave_4_rdy = 1;
        slave_5_rdy = 1;
        slave_6_rdy = 1;
        slave_7_rdy = 1;
        slave_1_out_data = 1;
        slave_2_out_data = 2;
        slave_3_out_data = 3;
        slave_4_out_data = 4;
        slave_5_out_data = 5;
        slave_6_out_data = 6;
        slave_7_out_data = 7;
    end
    #TIMECLK
    $finish;
end

initial begin
    $dumpfile("wave_bus_memory.vcd");
    $dumpvars(0,test_bus_memory);
end

endmodule