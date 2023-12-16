`include "define.v"
`include "sii_sync.v"
`include "sii_pos.v"
// Core Local Interrupt Controller
module clint (
    input wire                          clk,
    input wire                          rst_n,
    input wire                          io_rtcToggle, // async
    // ahb-lite
    input wire                          HSELx,
    input wire [`WORD_WIDTH - 1 : 0]    HADDR,
    input wire                          HWRITE,
    input wire [2 : 0]                  HSIZE,
    input wire [2 : 0]                  HBURST,     // not used
    input wire [1 : 0]                  HTRANS,
    input wire                          HMASTLOCK,  // not used
    input wire [`WORD_WIDTH - 1 : 0]    HWDATA,
    // int clear
    input wire                          software_int_clear, // Hardware reset
    input wire                          timer_int_clear,    // Hardware reset
    // outputs
    output reg                          irq_timer,
    output reg                          irq_software,
    //ahb-lite
    output reg [`WORD_WIDTH - 1 : 0]    HRDATA,
    output reg                          HREADY,
    output reg [1 : 0]                  HRESP
);

wire io_rtcToggle_sync;
wire io_rtcToggle_sync_pos;

reg [63 : 0]    sii_timer;
reg [31 : 0]    clint_mtime_high;
reg [31 : 0]    clint_mtime_low;
reg [31 : 0]    clint_mtimecmp_high;
reg [31 : 0]    clint_mtimecmp_low;
reg [31 : 0]    clint_msip;

sii_sync u_sii_sync(
    .clk        (clk                ),
    .rst_n      (rst_n              ),
    .data       (io_rtcToggle       ),
    .data_sync  (io_rtcToggle_sync  )
);

sii_pos u_sii_pos(
    .clk        (clk                    ),
    .rst_n      (rst_n                  ),
    .data       (io_rtcToggle_sync      ),
    .data_pos   (io_rtcToggle_sync_pos  )
);

wire    clint_wen;
wire    clint_ren;
assign  clint_wen = HSELx &&  HWRITE && (HTRANS == `HTRANS_NONSEQ);
assign  clint_ren = HSELx && !HWRITE && (HTRANS == `HTRANS_NONSEQ);

// timer interrupt
// mtime
wire    mtime_high_wen;
wire    mtime_high_ren;
wire    mtime_low_wen;
wire    mtime_low_ren;
reg     mtime_high_wen_r1;
reg     mtime_low_wen_r1;
// mtimecmp
wire    mtimecmp_high_wen;
wire    mtimecmp_high_ren;
wire    mtimecmp_low_wen;
wire    mtimecmp_low_ren;
reg     mtimecmp_high_wen_r1;
reg     mtimecmp_low_wen_r1;
// mtime
assign mtime_high_wen = (HADDR == `BUS_ADDR_CLINT_MTIME_HIGH) && clint_wen;
assign mtime_high_ren = (HADDR == `BUS_ADDR_CLINT_MTIME_HIGH) && clint_ren;
assign mtime_low_wen  = (HADDR == `BUS_ADDR_CLINT_MTIME_LOW)  && clint_wen;
assign mtime_low_ren  = (HADDR == `BUS_ADDR_CLINT_MTIME_LOW)  && clint_ren;
// mtimecmp
assign mtimecmp_high_wen = (HADDR == `BUS_ADDR_CLINT_MTIMECMP_HIGH) && clint_wen;
assign mtimecmp_high_ren = (HADDR == `BUS_ADDR_CLINT_MTIMECMP_HIGH) && clint_ren;
assign mtimecmp_low_wen  = (HADDR == `BUS_ADDR_CLINT_MTIMECMP_LOW)  && clint_wen;
assign mtimecmp_low_ren  = (HADDR == `BUS_ADDR_CLINT_MTIMECMP_LOW)  && clint_ren;

// mtime
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mtime_high_wen_r1 <= 1'b0;
        mtime_low_wen_r1  <= 1'b0;
    end else begin
        mtime_high_wen_r1 <= mtime_high_wen;
        mtime_low_wen_r1  <= mtime_low_wen;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clint_mtime_high <= 32'b0;
    end else if (mtime_high_wen_r1) begin
        clint_mtime_high <= HWDATA;
    end else begin
        clint_mtime_high <= sii_timer[63 : 32];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clint_mtime_low <= 32'b0;
    end else if (mtime_low_wen_r1) begin
        clint_mtime_low <= HWDATA;
    end else begin
        clint_mtime_low <= sii_timer[31 : 0];
    end
end

// sii_timer
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sii_timer <= 64'b0;
    end else if (mtime_high_wen_r1) begin
        sii_timer <= {HWDATA, sii_timer[31 : 0]} + 1;
    end else if (mtime_low_wen_r1) begin
        sii_timer <= {sii_timer[63 : 32], HWDATA} + 1;
    end else if (io_rtcToggle_sync_pos) begin
        sii_timer <= sii_timer + 1;
    end
end

// mtimecmp
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mtimecmp_high_wen_r1 <= 1'b0;
        mtimecmp_low_wen_r1  <= 1'b0;
    end else begin
        mtimecmp_high_wen_r1 <= mtimecmp_high_wen;
        mtimecmp_low_wen_r1  <= mtimecmp_low_wen;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clint_mtimecmp_high <= 32'h1111_1111;
    end else if (mtimecmp_high_wen_r1) begin
        clint_mtimecmp_high <= HWDATA;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clint_mtimecmp_low <= 32'h1111_1111;
    end else if (mtimecmp_low_wen_r1) begin
        clint_mtimecmp_low <= HWDATA;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        irq_timer <= 1'b0;
    end else if (timer_int_clear) begin
        irq_timer <= 1'b0;
    end else if ((clint_mtimecmp_low == clint_mtime_low) && (clint_mtimecmp_high == clint_mtime_high)) begin
        irq_timer <= 1'b1;
    end else begin
        irq_timer <= 1'b0;
    end
end

// software interrupt
wire    msip_wen;
wire    msip_ren;
reg     msip_wen_r1;

assign msip_wen = (HADDR == `BUS_ADDR_CLINT_MSIP) &&  clint_wen;
assign msip_ren = (HADDR == `BUS_ADDR_CLINT_MSIP) && clint_ren;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        msip_wen_r1 <= 1'b0;
    end else begin
        msip_wen_r1 <= msip_wen;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clint_msip <= 32'b0;
    end else if (msip_wen_r1) begin
        clint_msip <= HWDATA;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        irq_software <= 1'b0;
    end else if (software_int_clear) begin
        irq_software <= 1'b0;
    end else if (clint_msip[0] == 1'b1) begin
        irq_software <= 1'b1;
    end else begin
        irq_software <= 1'b0;
    end
end

// ahb outputs
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        HREADY  <= 1'b0;
        HRESP   <= `HRESP_ERROR;
    end else if (msip_wen || msip_ren || mtime_high_ren || mtime_high_wen || mtime_low_ren || mtime_low_wen
                || mtimecmp_high_ren || mtimecmp_high_wen || mtimecmp_low_ren || mtimecmp_low_wen   ) begin
        HREADY  <= 1'b1;
        HRESP   <= `HRESP_OKAY;
    end else if (clint_ren || clint_wen) begin // address error
        HREADY  <= 1'b0;
        HRESP   <= `HRESP_ERROR;
    end else begin
        HREADY  <= 1'b1;
        HRESP   <= `HRESP_OKAY;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        HRDATA <= `WORD_WIDTH'b0;
    end else if (msip_ren) begin
        HRDATA <= clint_msip;
    end else if (mtime_high_ren) begin
        HRDATA <= clint_mtime_high;
    end else if (mtime_low_ren) begin
        HRDATA <= clint_mtime_low;
    end else if (mtimecmp_high_ren) begin
        HRDATA <= clint_mtimecmp_high;
    end else if (mtimecmp_low_ren) begin
        HRDATA <= clint_mtimecmp_low;
    end else if (!clint_ren) begin
        HRDATA <= `WORD_WIDTH'b0;
    end
end

endmodule
`endif