//Here, we design a bus with 4 masters and 8 slaves,
//The bus is mainly composed of 4 parts: arbiter, master_mux, decoder, slave_mux.
//Among them, "arbiter" is used to select a master to grant the current bus use right,
//After getting the "grnt" signal, "master_mux" is used to transmit this master's "as", "addr", "wr", "data" to all slave,
//By the "decoder" module, we gain the "cs" signal
//By the "cs" signal, we select the slave to give all master the signals of "data" and "rdy".

`include"bus_arbiter.v"
`include"bus_master_mux.v"
`include"bus_decoder.v"
`include"bus_slave_mux.v"
`include "define_bus.v"

module bus_top(
    input wire clk,
    input wire rst_,
    //from master
    input wire master_0_req,
    input wire master_1_req,
    input wire master_2_req,
    input wire master_3_req,
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
    //to master (from "arbiter")
    output wire master_0_grnt,
    output wire master_1_grnt,
    output wire master_2_grnt,
    output wire master_3_grnt,
    //to slave (from "bus_master_mux")
    output wire slave_as,
    output wire [`ADDR_WIDTH - 1:0] slave_addr,
    output wire slave_wr,
    output wire [`DATA_WIDTH - 1:0] slave_wr_data,
    //to each slave (from "decoder")
    output wire slave_0_cs,
    output wire slave_1_cs,
    output wire slave_2_cs,
    output wire slave_3_cs,
    output wire slave_4_cs,
    output wire slave_5_cs,
    output wire slave_6_cs,
    output wire slave_7_cs,
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
    //to master (from "bus_slave_mux")
    output wire master_rdy,
    output wire [`DATA_WIDTH - 1:0] master_data
);

bus_arbiter bus_arbiter_1(
    .clk(clk),
    .rst_(rst_),
    .master_0_req(master_0_req),
    .master_1_req(master_1_req),
    .master_2_req(master_2_req),
    .master_3_req(master_3_req),
    .master_0_grnt(master_0_grnt), 
    .master_1_grnt(master_1_grnt),
    .master_2_grnt(master_2_grnt),
    .master_3_grnt(master_3_grnt)
);

bus_master_mux bus_master_mux_1(
    .master_0_grnt(master_0_grnt),
    .master_1_grnt(master_1_grnt),
    .master_2_grnt(master_2_grnt),
    .master_3_grnt(master_3_grnt),
    .master_0_as(master_0_as), //Address select, indicating that the transmitted signal is the address or data signal
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
    .slave_as(slave_as), 
    .slave_addr(slave_addr),
    .slave_wr(slave_wr),
    .slave_wr_data(slave_wr_data)
);

bus_decoder bus_decoder_1(
    .slave_addr(slave_addr),
    .slave_0_cs(slave_0_cs),
    .slave_1_cs(slave_1_cs),
    .slave_2_cs(slave_2_cs),
    .slave_3_cs(slave_3_cs),
    .slave_4_cs(slave_4_cs),
    .slave_5_cs(slave_5_cs),
    .slave_6_cs(slave_6_cs),
    .slave_7_cs(slave_7_cs)
);

bus_slave_mux bus_slave_mux(
    .slave_0_cs(slave_0_cs),
    .slave_1_cs(slave_1_cs),
    .slave_2_cs(slave_2_cs),
    .slave_3_cs(slave_3_cs),
    .slave_4_cs(slave_4_cs),
    .slave_5_cs(slave_5_cs),
    .slave_6_cs(slave_6_cs),
    .slave_7_cs(slave_7_cs),
    .slave_0_rdy(slave_0_rdy),//slave is ready
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

endmodule