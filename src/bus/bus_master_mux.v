//After "arbiter" selects which master is granted the bus usage right,
//This module will transmit this master signal to each slave
module bus_master_mux(
    //from master
    input wire master_0_as,
    input wire master_1_as,
    input wire master_2_as,
    input wire master_3_as,
    input wire [`ADDR_WIDTH - 1:0] master_0_addr,
    input wire [`ADDR_WIDTH - 1:0] master_1_addr,
    input wire [`ADDR_WIDTH - 1:0] master_2_addr,
    input wire [`ADDR_WIDTH - 1:0] master_3_addr,
    input wire master_0_wr,
    input wire master_1_wr,
    input wire master_2_wr,
    input wire master_3_wr,
    input wire [`DATA_WIDTH - 1:0] master_0_wr_data,
    input wire [`DATA_WIDTH - 1:0] master_1_wr_data,
    input wire [`DATA_WIDTH - 1:0] master_2_wr_data,
    input wire [`DATA_WIDTH - 1:0] master_3_wr_data,
    //from arbiter
    input wire master_0_grnt,
    input wire master_1_grnt,
    input wire master_2_grnt,
    input wire master_3_grnt,
    //to slave
    output reg slave_as,
    output reg [`ADDR_WIDTH - 1:0] slave_addr,
    output reg slave_wr,
    output reg [`DATA_WIDTH - 1:0] slave_wr_data
);

always @* begin
    if(master_0_grnt == 1)begin
        slave_as =  master_0_as;
        slave_addr = master_0_addr;
        slave_wr = master_0_wr;
        slave_wr_data = master_0_wr_data;
    end else if(master_1_grnt == 1)begin
        slave_as =  master_1_as;
        slave_addr = master_1_addr;
        slave_wr = master_1_wr;
        slave_wr_data = master_1_wr_data;
    end else if(master_2_grnt == 1)begin
        slave_as =  master_2_as;
        slave_addr = master_2_addr;
        slave_wr = master_2_wr;
        slave_wr_data = master_2_wr_data;
    end else if(master_3_grnt == 1)begin
        slave_as =  master_3_as;
        slave_addr = master_3_addr;
        slave_wr = master_3_wr;
        slave_wr_data = master_3_wr_data;
    end
end

endmodule