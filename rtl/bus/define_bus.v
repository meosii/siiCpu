`ifndef define_bus

`define define_bus

`define INDEX_S0 3'b000
`define INDEX_S1 3'b001
`define INDEX_S2 3'b010
`define INDEX_S3 3'b011
`define INDEX_S4 3'b100
`define INDEX_S5 3'b101
`define INDEX_S6 3'b110
`define INDEX_S7 3'b111
`define DATA_WIDTH 32
`define ADDR_WIDTH 30
`define SLAVE_ADDR_WIDTH 3 // 8 slaves
`define MASTER_ADDR_WIDTH 2 // 4 masters
`define OWNER0 2'b00
`define OWNER1 2'b01
`define OWNER2 2'b10
`define OWNER3 2'b11
`define READ 0
`define WRITE 1
`define arbiter_owner_choose(req0,req1,req2,req3,o0,o1,o2,o3)\
    if (req0)begin\
                    owner <= o0;\
                end else if (req1) begin\
                    owner <= o1;\
                end else if (req2) begin\
                    owner <= o2;\
                end else if (req3) begin\
                    owner <= o3;\
                end else begin\
                    owner <= o0;\
                end

`endif