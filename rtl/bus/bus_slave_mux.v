`include "bus/define_bus.v"

module bus_slave_mux(
    //from decoder
    input wire slave_0_cs,
    input wire slave_1_cs,
    input wire slave_2_cs,
    input wire slave_3_cs,
    input wire slave_4_cs,
    input wire slave_5_cs,
    input wire slave_6_cs,
    input wire slave_7_cs,
    //from slave
    input wire slave_0_rdy,
    input wire slave_1_rdy,
    input wire slave_2_rdy,
    input wire slave_3_rdy,
    input wire slave_4_rdy,
    input wire slave_5_rdy,
    input wire slave_6_rdy,
    input wire slave_7_rdy,
    input wire [`DATA_WIDTH - 1:0] slave_0_out_data,
    input wire [`DATA_WIDTH - 1:0] slave_1_out_data,
    input wire [`DATA_WIDTH - 1:0] slave_2_out_data,
    input wire [`DATA_WIDTH - 1:0] slave_3_out_data,
    input wire [`DATA_WIDTH - 1:0] slave_4_out_data,
    input wire [`DATA_WIDTH - 1:0] slave_5_out_data,
    input wire [`DATA_WIDTH - 1:0] slave_6_out_data,
    input wire [`DATA_WIDTH - 1:0] slave_7_out_data,
    //to master
    output reg master_rdy,
    output reg [`DATA_WIDTH - 1:0] master_data
);

always @* begin
    if(slave_0_cs)begin
        master_rdy = slave_0_rdy;
        master_data = slave_0_out_data;
    end else if(slave_1_cs)begin
        master_rdy = slave_1_rdy;
        master_data = slave_1_out_data;
    end else if(slave_2_cs)begin
        master_rdy = slave_2_rdy;
        master_data = slave_2_out_data;
    end else if(slave_3_cs)begin
        master_rdy = slave_3_rdy;
        master_data = slave_3_out_data;
    end else if(slave_4_cs)begin
        master_rdy = slave_4_rdy;
        master_data = slave_4_out_data;
    end else if(slave_5_cs)begin
        master_rdy = slave_5_rdy;
        master_data = slave_5_out_data;
    end else if(slave_6_cs)begin
        master_rdy = slave_6_rdy;
        master_data = slave_6_out_data;
    end else if(slave_7_cs)begin
        master_rdy = slave_7_rdy;
        master_data = slave_7_out_data;
    end
end


endmodule
