`ifndef BOOTH_RADIX_4
`define BOOTH_RADIX_4
`include "define.v"
module booth_radix_4 #(
    parameter SIGNED_WORD_WIDTH = `WORD_WIDTH + 1,
    parameter PARTIAL_PRODUCT_WIDTH = SIGNED_WORD_WIDTH + SIGNED_WORD_WIDTH
)(
    input wire [2:0]                            mul_opcode,
    input wire [`WORD_WIDTH-1 : 0]              mul_data1,
    input wire [`WORD_WIDTH-1 : 0]              mul_data2,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product1,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product2,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product3,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product4,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product5,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product6,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product7,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product8,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product9,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product10,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product11,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product12,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product13,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product14,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product15,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product16,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product17
);

wire                                mul_data1_signed;   // 1'b1:signed; 1'b0:unsigned
wire                                mul_data2_signed;   // 1'b1:signed; 1'b0:unsigned
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1;    // [SIGNED_WORD_WIDTH-1 : 0]
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData2;    // [SIGNED_WORD_WIDTH-1 : 0]
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_0; // mul_signedData1<<0
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_2; // mul_signedData1<<2
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_4; // mul_signedData1<<4
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_6;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_8;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_10;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_12;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_14;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_16;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_18;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_20;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_22;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_24;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_26;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_28;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_30;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_32;

wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_0_n; // -mul_signedData1_mulBy2_0
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_2_n; // -mul_signedData1_mulBy2_2
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_4_n; // -mul_signedData1_mulBy2_4
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_6_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_8_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_10_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_12_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_14_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_16_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_18_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_20_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_22_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_24_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_26_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_28_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_30_n;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]  mul_signedData1_mulBy2_32_n;

assign mul_data1_signed =   (mul_opcode == `MUL_OP_MUL      )?  1'b1 :
                            (mul_opcode == `MUL_OP_MULH     )?  1'b1 :
                            (mul_opcode == `MUL_OP_MULHU    )?  1'b0 :
                            (mul_opcode == `MUL_OP_MULHSU   )?  1'b1 : 1'b0;

assign mul_data2_signed =   (mul_opcode == `MUL_OP_MUL      )?  1'b1 :
                            (mul_opcode == `MUL_OP_MULH     )?  1'b1 :
                            (mul_opcode == `MUL_OP_MULHU    )?  1'b0 :
                            (mul_opcode == `MUL_OP_MULHSU   )?  1'b0 : 1'b0;

// Booth algorithm operates on signed numbers,
// For unsigned numbers, it is necessary to add a bit to convert it to a signed number.
assign mul_signedData1 = (mul_data1_signed)? {{34{mul_data1[`WORD_WIDTH-1]}}, mul_data1} : {34'b0, mul_data1};
assign mul_signedData2 = (mul_data2_signed)? {{34{mul_data2[`WORD_WIDTH-1]}}, mul_data2} : {34'b0, mul_data2};

assign mul_signedData1_mulBy2_0 = mul_signedData1;
assign mul_signedData1_mulBy2_2 = mul_signedData1<<2;
assign mul_signedData1_mulBy2_4 = mul_signedData1<<4;
assign mul_signedData1_mulBy2_6 = mul_signedData1<<6;
assign mul_signedData1_mulBy2_8 = mul_signedData1<<8;
assign mul_signedData1_mulBy2_10 = mul_signedData1<<10;
assign mul_signedData1_mulBy2_12 = mul_signedData1<<12;
assign mul_signedData1_mulBy2_14 = mul_signedData1<<14;
assign mul_signedData1_mulBy2_16 = mul_signedData1<<16;
assign mul_signedData1_mulBy2_18 = mul_signedData1<<18;
assign mul_signedData1_mulBy2_20 = mul_signedData1<<20;
assign mul_signedData1_mulBy2_22 = mul_signedData1<<22;
assign mul_signedData1_mulBy2_24 = mul_signedData1<<24;
assign mul_signedData1_mulBy2_26 = mul_signedData1<<26;
assign mul_signedData1_mulBy2_28 = mul_signedData1<<28;
assign mul_signedData1_mulBy2_30 = mul_signedData1<<30;
assign mul_signedData1_mulBy2_32 = mul_signedData1<<32;

assign mul_signedData1_mulBy2_0_n   = ~mul_signedData1_mulBy2_0 + 1;
assign mul_signedData1_mulBy2_2_n   = ~mul_signedData1_mulBy2_2 + 1;
assign mul_signedData1_mulBy2_4_n   = ~mul_signedData1_mulBy2_4 + 1;
assign mul_signedData1_mulBy2_6_n   = ~mul_signedData1_mulBy2_6 + 1;
assign mul_signedData1_mulBy2_8_n   = ~mul_signedData1_mulBy2_8 + 1;
assign mul_signedData1_mulBy2_10_n  = ~mul_signedData1_mulBy2_10 + 1;
assign mul_signedData1_mulBy2_12_n  = ~mul_signedData1_mulBy2_12 + 1;
assign mul_signedData1_mulBy2_14_n  = ~mul_signedData1_mulBy2_14 + 1;
assign mul_signedData1_mulBy2_16_n  = ~mul_signedData1_mulBy2_16 + 1;
assign mul_signedData1_mulBy2_18_n  = ~mul_signedData1_mulBy2_18 + 1;
assign mul_signedData1_mulBy2_20_n  = ~mul_signedData1_mulBy2_20 + 1;
assign mul_signedData1_mulBy2_22_n  = ~mul_signedData1_mulBy2_22 + 1;
assign mul_signedData1_mulBy2_24_n  = ~mul_signedData1_mulBy2_24 + 1;
assign mul_signedData1_mulBy2_26_n  = ~mul_signedData1_mulBy2_26 + 1;
assign mul_signedData1_mulBy2_28_n  = ~mul_signedData1_mulBy2_28 + 1;
assign mul_signedData1_mulBy2_30_n  = ~mul_signedData1_mulBy2_30 + 1;
assign mul_signedData1_mulBy2_32_n  = ~mul_signedData1_mulBy2_32 + 1;

assign mul_partial_product1 =   ({mul_signedData2[1:0], 1'b0} == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}     :
                                ({mul_signedData2[1:0], 1'b0} == 3'b001)? mul_signedData1_mulBy2_0          :
                                ({mul_signedData2[1:0], 1'b0} == 3'b010)? mul_signedData1_mulBy2_0          :
                                ({mul_signedData2[1:0], 1'b0} == 3'b011)? mul_signedData1_mulBy2_0<<1       :
                                ({mul_signedData2[1:0], 1'b0} == 3'b100)? mul_signedData1_mulBy2_0_n<<1     :
                                ({mul_signedData2[1:0], 1'b0} == 3'b101)? mul_signedData1_mulBy2_0_n        :
                                ({mul_signedData2[1:0], 1'b0} == 3'b110)? mul_signedData1_mulBy2_0_n        :
                                ({mul_signedData2[1:0], 1'b0} == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}     :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product2 =   (mul_signedData2[3:1] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :
                                (mul_signedData2[3:1] == 3'b001)? mul_signedData1_mulBy2_2              :
                                (mul_signedData2[3:1] == 3'b010)? mul_signedData1_mulBy2_2              :
                                (mul_signedData2[3:1] == 3'b011)? mul_signedData1_mulBy2_2<<1           :
                                (mul_signedData2[3:1] == 3'b100)? mul_signedData1_mulBy2_2_n<<1         :
                                (mul_signedData2[3:1] == 3'b101)? mul_signedData1_mulBy2_2_n            :
                                (mul_signedData2[3:1] == 3'b110)? mul_signedData1_mulBy2_2_n            :
                                (mul_signedData2[3:1] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product3 =   (mul_signedData2[5:3] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :
                                (mul_signedData2[5:3] == 3'b001)? mul_signedData1_mulBy2_4              :
                                (mul_signedData2[5:3] == 3'b010)? mul_signedData1_mulBy2_4              :
                                (mul_signedData2[5:3] == 3'b011)? mul_signedData1_mulBy2_4<<1           :
                                (mul_signedData2[5:3] == 3'b100)? mul_signedData1_mulBy2_4_n<<1         :
                                (mul_signedData2[5:3] == 3'b101)? mul_signedData1_mulBy2_4_n            :
                                (mul_signedData2[5:3] == 3'b110)? mul_signedData1_mulBy2_4_n            :
                                (mul_signedData2[5:3] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product4 =   (mul_signedData2[7:5] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :
                                (mul_signedData2[7:5] == 3'b001)? mul_signedData1_mulBy2_6              :
                                (mul_signedData2[7:5] == 3'b010)? mul_signedData1_mulBy2_6              :
                                (mul_signedData2[7:5] == 3'b011)? mul_signedData1_mulBy2_6<<1           :
                                (mul_signedData2[7:5] == 3'b100)? mul_signedData1_mulBy2_6_n<<1         :
                                (mul_signedData2[7:5] == 3'b101)? mul_signedData1_mulBy2_6_n            :
                                (mul_signedData2[7:5] == 3'b110)? mul_signedData1_mulBy2_6_n            :
                                (mul_signedData2[7:5] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product5 =   (mul_signedData2[9:7] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :
                                (mul_signedData2[9:7] == 3'b001)? mul_signedData1_mulBy2_8              :
                                (mul_signedData2[9:7] == 3'b010)? mul_signedData1_mulBy2_8              :
                                (mul_signedData2[9:7] == 3'b011)? mul_signedData1_mulBy2_8<<1           :
                                (mul_signedData2[9:7] == 3'b100)? mul_signedData1_mulBy2_8_n<<1         :
                                (mul_signedData2[9:7] == 3'b101)? mul_signedData1_mulBy2_8_n            :
                                (mul_signedData2[9:7] == 3'b110)? mul_signedData1_mulBy2_8_n            :
                                (mul_signedData2[9:7] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}         :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product6 =   (mul_signedData2[11:9] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}        :
                                (mul_signedData2[11:9] == 3'b001)? mul_signedData1_mulBy2_10            :
                                (mul_signedData2[11:9] == 3'b010)? mul_signedData1_mulBy2_10            :
                                (mul_signedData2[11:9] == 3'b011)? mul_signedData1_mulBy2_10<<1         :
                                (mul_signedData2[11:9] == 3'b100)? mul_signedData1_mulBy2_10_n<<1       :
                                (mul_signedData2[11:9] == 3'b101)? mul_signedData1_mulBy2_10_n          :
                                (mul_signedData2[11:9] == 3'b110)? mul_signedData1_mulBy2_10_n          :
                                (mul_signedData2[11:9] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}        :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product7 =   (mul_signedData2[13:11] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[13:11] == 3'b001)? mul_signedData1_mulBy2_12           :
                                (mul_signedData2[13:11] == 3'b010)? mul_signedData1_mulBy2_12           :
                                (mul_signedData2[13:11] == 3'b011)? mul_signedData1_mulBy2_12<<1        :
                                (mul_signedData2[13:11] == 3'b100)? mul_signedData1_mulBy2_12_n<<1      :
                                (mul_signedData2[13:11] == 3'b101)? mul_signedData1_mulBy2_12_n         :
                                (mul_signedData2[13:11] == 3'b110)? mul_signedData1_mulBy2_12_n         :
                                (mul_signedData2[13:11] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product8 =   (mul_signedData2[15:13] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[15:13] == 3'b001)? mul_signedData1_mulBy2_14           :
                                (mul_signedData2[15:13] == 3'b010)? mul_signedData1_mulBy2_14           :
                                (mul_signedData2[15:13] == 3'b011)? mul_signedData1_mulBy2_14<<1        :
                                (mul_signedData2[15:13] == 3'b100)? mul_signedData1_mulBy2_14_n<<1      :
                                (mul_signedData2[15:13] == 3'b101)? mul_signedData1_mulBy2_14_n         :
                                (mul_signedData2[15:13] == 3'b110)? mul_signedData1_mulBy2_14_n         :
                                (mul_signedData2[15:13] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product9 =   (mul_signedData2[17:15] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[17:15] == 3'b001)? mul_signedData1_mulBy2_16           :
                                (mul_signedData2[17:15] == 3'b010)? mul_signedData1_mulBy2_16           :
                                (mul_signedData2[17:15] == 3'b011)? mul_signedData1_mulBy2_16<<1        :
                                (mul_signedData2[17:15] == 3'b100)? mul_signedData1_mulBy2_16_n<<1      :
                                (mul_signedData2[17:15] == 3'b101)? mul_signedData1_mulBy2_16_n         :
                                (mul_signedData2[17:15] == 3'b110)? mul_signedData1_mulBy2_16_n         :
                                (mul_signedData2[17:15] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product10 =  (mul_signedData2[19:17] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[19:17] == 3'b001)? mul_signedData1_mulBy2_18           :
                                (mul_signedData2[19:17] == 3'b010)? mul_signedData1_mulBy2_18           :
                                (mul_signedData2[19:17] == 3'b011)? mul_signedData1_mulBy2_18<<1        :
                                (mul_signedData2[19:17] == 3'b100)? mul_signedData1_mulBy2_18_n<<1      :
                                (mul_signedData2[19:17] == 3'b101)? mul_signedData1_mulBy2_18_n         :
                                (mul_signedData2[19:17] == 3'b110)? mul_signedData1_mulBy2_18_n         : 
                                (mul_signedData2[19:17] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product11 =  (mul_signedData2[21:19] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[21:19] == 3'b001)? mul_signedData1_mulBy2_20           :
                                (mul_signedData2[21:19] == 3'b010)? mul_signedData1_mulBy2_20           :
                                (mul_signedData2[21:19] == 3'b011)? mul_signedData1_mulBy2_20<<1        :
                                (mul_signedData2[21:19] == 3'b100)? mul_signedData1_mulBy2_20_n<<1      :
                                (mul_signedData2[21:19] == 3'b101)? mul_signedData1_mulBy2_20_n         :
                                (mul_signedData2[21:19] == 3'b110)? mul_signedData1_mulBy2_20_n         :
                                (mul_signedData2[21:19] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product12 =  (mul_signedData2[23:21] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[23:21] == 3'b001)? mul_signedData1_mulBy2_22           :
                                (mul_signedData2[23:21] == 3'b010)? mul_signedData1_mulBy2_22           :
                                (mul_signedData2[23:21] == 3'b011)? mul_signedData1_mulBy2_22<<1        :
                                (mul_signedData2[23:21] == 3'b100)? mul_signedData1_mulBy2_22_n<<1      :
                                (mul_signedData2[23:21] == 3'b101)? mul_signedData1_mulBy2_22_n         :
                                (mul_signedData2[23:21] == 3'b110)? mul_signedData1_mulBy2_22_n         :
                                (mul_signedData2[23:21] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product13 =  (mul_signedData2[25:23] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[25:23] == 3'b001)? mul_signedData1_mulBy2_24           :
                                (mul_signedData2[25:23] == 3'b010)? mul_signedData1_mulBy2_24           :
                                (mul_signedData2[25:23] == 3'b011)? mul_signedData1_mulBy2_24<<1        :
                                (mul_signedData2[25:23] == 3'b100)? mul_signedData1_mulBy2_24_n<<1      :
                                (mul_signedData2[25:23] == 3'b101)? mul_signedData1_mulBy2_24_n         :
                                (mul_signedData2[25:23] == 3'b110)? mul_signedData1_mulBy2_24_n         :
                                (mul_signedData2[25:23] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product14 =  (mul_signedData2[27:25] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[27:25] == 3'b001)? mul_signedData1_mulBy2_26           :
                                (mul_signedData2[27:25] == 3'b010)? mul_signedData1_mulBy2_26           :
                                (mul_signedData2[27:25] == 3'b011)? mul_signedData1_mulBy2_26<<1        :
                                (mul_signedData2[27:25] == 3'b100)? mul_signedData1_mulBy2_26_n<<1      :
                                (mul_signedData2[27:25] == 3'b101)? mul_signedData1_mulBy2_26_n         :
                                (mul_signedData2[27:25] == 3'b110)? mul_signedData1_mulBy2_26_n         :
                                (mul_signedData2[27:25] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product15 =  (mul_signedData2[29:27] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[29:27] == 3'b001)? mul_signedData1_mulBy2_28           :
                                (mul_signedData2[29:27] == 3'b010)? mul_signedData1_mulBy2_28           :
                                (mul_signedData2[29:27] == 3'b011)? mul_signedData1_mulBy2_28<<1        :
                                (mul_signedData2[29:27] == 3'b100)? mul_signedData1_mulBy2_28_n<<1      :
                                (mul_signedData2[29:27] == 3'b101)? mul_signedData1_mulBy2_28_n         :
                                (mul_signedData2[29:27] == 3'b110)? mul_signedData1_mulBy2_28_n         :
                                (mul_signedData2[29:27] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product16 =  (mul_signedData2[31:29] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[31:29] == 3'b001)? mul_signedData1_mulBy2_30           :
                                (mul_signedData2[31:29] == 3'b010)? mul_signedData1_mulBy2_30           :
                                (mul_signedData2[31:29] == 3'b011)? mul_signedData1_mulBy2_30<<1        :
                                (mul_signedData2[31:29] == 3'b100)? mul_signedData1_mulBy2_30_n<<1      :
                                (mul_signedData2[31:29] == 3'b101)? mul_signedData1_mulBy2_30_n         :
                                (mul_signedData2[31:29] == 3'b110)? mul_signedData1_mulBy2_30_n         :
                                (mul_signedData2[31:29] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};

assign mul_partial_product17 =  (mul_signedData2[33:31] == 3'b000)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :
                                (mul_signedData2[33:31] == 3'b001)? mul_signedData1_mulBy2_32           :
                                (mul_signedData2[33:31] == 3'b010)? mul_signedData1_mulBy2_32           :
                                (mul_signedData2[33:31] == 3'b011)? mul_signedData1_mulBy2_32<<1        :
                                (mul_signedData2[33:31] == 3'b100)? mul_signedData1_mulBy2_32_n<<1      :
                                (mul_signedData2[33:31] == 3'b101)? mul_signedData1_mulBy2_32_n         :
                                (mul_signedData2[33:31] == 3'b110)? mul_signedData1_mulBy2_32_n         :
                                (mul_signedData2[33:31] == 3'b111)? {PARTIAL_PRODUCT_WIDTH{1'b0}}       :   {PARTIAL_PRODUCT_WIDTH{1'b0}};
endmodule
`endif