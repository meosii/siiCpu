`include "bus/define_bus.v"

//Here, we use the round-robin priority,
//define the priority order as 0 1 2 3 

module bus_arbiter (
    input wire clk,
    input wire rst_,
    input wire master_0_req,
    input wire master_1_req,
    input wire master_2_req,
    input wire master_3_req,
    output reg master_0_grnt,
    output reg master_1_grnt,
    output reg master_2_grnt,
    output reg master_3_grnt
);

reg [`MASTER_ADDR_WIDTH - 1:0] owner;

always @(posedge clk or negedge rst_) begin
    if (!rst_) begin
        owner <= `OWNER0;
    end else begin
        case(owner)
            `OWNER0:
                `arbiter_owner_choose(master_0_req,master_1_req,master_2_req,master_3_req,`OWNER0,`OWNER1,`OWNER2,`OWNER3)
            `OWNER1:
                `arbiter_owner_choose(master_1_req,master_2_req,master_3_req,master_0_req,`OWNER1,`OWNER2,`OWNER3,`OWNER0)
            `OWNER2:
                `arbiter_owner_choose(master_2_req,master_3_req,master_0_req,master_1_req,`OWNER2,`OWNER3,`OWNER0,`OWNER1)
            `OWNER3:
                `arbiter_owner_choose(master_3_req,master_0_req,master_1_req,master_2_req,`OWNER3,`OWNER0,`OWNER1,`OWNER2)
            default: owner <= `OWNER0;
        endcase
    end
end

always @* begin
    master_0_grnt = 0;
    master_1_grnt = 0;
    master_2_grnt = 0;
    master_3_grnt = 0;
    case(owner)
        `OWNER0: begin
            master_0_grnt = 1; 
            master_1_grnt = 0;
            master_2_grnt = 0;
            master_3_grnt = 0;
        end
        `OWNER1: begin
            master_0_grnt = 0; 
            master_1_grnt = 1;
            master_2_grnt = 0;
            master_3_grnt = 0;
        end
        `OWNER2: begin
            master_0_grnt = 0; 
            master_1_grnt = 0;
            master_2_grnt = 1;
            master_3_grnt = 0;
        end
        `OWNER3: begin
            master_0_grnt = 0; 
            master_1_grnt = 0;
            master_2_grnt = 0;
            master_3_grnt = 1;
        end
        default: begin
            master_0_grnt = 1; 
            master_1_grnt = 0;
            master_2_grnt = 0;
            master_3_grnt = 0;
        end
    endcase
end

endmodule