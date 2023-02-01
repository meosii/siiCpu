`include "bus_arbiter.v"
`include "define_bus.v"

module test_arbiter();
reg clk;
reg rst_;
reg master_0_req;
reg master_1_req;
reg master_2_req;
reg master_3_req;
wire master_0_grnt;
wire master_1_grnt;
wire master_2_grnt;
wire master_3_grnt;

parameter TIMECLK = 10;

bus_arbiter u_bus_arbiter(
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
        master_3_req = 0;
    end
    #TIMECLK begin
        master_0_req = 1;
        master_1_req = 1;
        master_2_req = 1;
        master_3_req = 1;
    end
    #TIMECLK begin
        master_0_req = 1;
        master_1_req = 0;
        master_2_req = 1;
        master_3_req = 1;
    end
    #TIMECLK begin
        master_0_req = 1;
        master_1_req = 1;
        master_2_req = 0;
        master_3_req = 1;
    end
    #TIMECLK begin
        master_0_req = 0;
        master_1_req = 0;
        master_2_req = 0;
        master_3_req = 0;
    end
    #TIMECLK begin
        master_0_req = 1;
        master_1_req = 0;
        master_2_req = 0;
        master_3_req = 1;
    end
    $finish;
end

initial begin
    $dumpfile("wave_arbiter.vcd");
    $dumpvars(0,test_arbiter);
end

endmodule