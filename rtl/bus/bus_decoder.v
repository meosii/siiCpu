`include "define_bus.v"
//Using the upper three digits of the address 
//generate the cs signal

module bus_decoder(
    input wire [`ADDR_WIDTH - 1:0] slave_addr,
    output reg slave_0_cs,
    output reg slave_1_cs,
    output reg slave_2_cs,
    output reg slave_3_cs,
    output reg slave_4_cs,
    output reg slave_5_cs,
    output reg slave_6_cs,
    output reg slave_7_cs
);

wire [`SLAVE_ADDR_WIDTH - 1:0] index;
assign index = slave_addr[`ADDR_WIDTH - 1:`ADDR_WIDTH - `SLAVE_ADDR_WIDTH]; //Judge which slave is selected by the high three bits of the address

always @* begin
    case(index)
        `INDEX_S0:begin
            slave_0_cs = 1;
            slave_1_cs = 0;
            slave_2_cs = 0;
            slave_3_cs = 0;
            slave_4_cs = 0;
            slave_5_cs = 0;
            slave_6_cs = 0;
            slave_7_cs = 0;
        end
        `INDEX_S1:begin
            slave_0_cs = 0;
            slave_1_cs = 1;
            slave_2_cs = 0;
            slave_3_cs = 0;
            slave_4_cs = 0;
            slave_5_cs = 0;
            slave_6_cs = 0;
            slave_7_cs = 0;
        end
        `INDEX_S2:begin
            slave_0_cs = 0;
            slave_1_cs = 0;
            slave_2_cs = 1;
            slave_3_cs = 0;
            slave_4_cs = 0;
            slave_5_cs = 0;
            slave_6_cs = 0;
            slave_7_cs = 0;
        end
        `INDEX_S3:begin
            slave_0_cs = 0;
            slave_1_cs = 0;
            slave_2_cs = 0;
            slave_3_cs = 1;
            slave_4_cs = 0;
            slave_5_cs = 0;
            slave_6_cs = 0;
            slave_7_cs = 0;
        end
        `INDEX_S4:begin
            slave_0_cs = 0;
            slave_1_cs = 0;
            slave_2_cs = 0;
            slave_3_cs = 0;
            slave_4_cs = 1;
            slave_5_cs = 0;
            slave_6_cs = 0;
            slave_7_cs = 0;
        end
        `INDEX_S5:begin
            slave_0_cs = 0;
            slave_1_cs = 0;
            slave_2_cs = 0;
            slave_3_cs = 0;
            slave_4_cs = 0;
            slave_5_cs = 1;
            slave_6_cs = 0;
            slave_7_cs = 0;
        end
        `INDEX_S6:begin
            slave_0_cs = 0;
            slave_1_cs = 0;
            slave_2_cs = 0;
            slave_3_cs = 0;
            slave_4_cs = 0;
            slave_5_cs = 0;
            slave_6_cs = 1;
            slave_7_cs = 0;
        end
        `INDEX_S7:begin
            slave_0_cs = 0;
            slave_1_cs = 0;
            slave_2_cs = 0;
            slave_3_cs = 0;
            slave_4_cs = 0;
            slave_5_cs = 0;
            slave_6_cs = 0;
            slave_7_cs = 1;
        end
    endcase
end

endmodule