`ifndef WALLACE
`define WALLACE
`include "define.v"
module wallace #(
    parameter SIGNED_WORD_WIDTH = `WORD_WIDTH + 1,
    parameter PARTIAL_PRODUCT_WIDTH = SIGNED_WORD_WIDTH + SIGNED_WORD_WIDTH
)(
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product1,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product2,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product3,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product4,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product5,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product6,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product7,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product8,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product9,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product10,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product11,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product12,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product13,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product14,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product15,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product16,
    input wire [PARTIAL_PRODUCT_WIDTH-1 : 0]    mul_partial_product17,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_add_a,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_add_b
);

wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa0;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa0;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa1;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa1;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa2;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa2;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa3;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa3;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa4;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa4;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa5;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa5;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa6;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa6;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa7;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa7;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa8;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa8;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa9;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa9;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa10;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa10;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa11;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa11;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa12;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa12;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa13;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa13;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] sum_csa14;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0] carry_csa14;

//////////////////////////stage_1////////////////////////////////////////
csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_prod1_prod2_prod3_csa0 (
    .in_1                   (mul_partial_product1   ),
    .in_2                   (mul_partial_product2   ),
    .in_3                   (mul_partial_product3   ),
    .sum                    (sum_csa0               ),
    .carry                  (carry_csa0             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_prod4_prod5_prod6_csa1 (
    .in_1                   (mul_partial_product4   ),
    .in_2                   (mul_partial_product5   ),
    .in_3                   (mul_partial_product6   ),
    .sum                    (sum_csa1               ),
    .carry                  (carry_csa1             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_prod7_prod8_prod9_csa2 (
    .in_1                   (mul_partial_product7   ),
    .in_2                   (mul_partial_product8   ),
    .in_3                   (mul_partial_product9   ),
    .sum                    (sum_csa2               ),
    .carry                  (carry_csa2             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_prod10_prod11_prod12_csa3 (
    .in_1                   (mul_partial_product10  ),
    .in_2                   (mul_partial_product11  ),
    .in_3                   (mul_partial_product12  ),
    .sum                    (sum_csa3               ),
    .carry                  (carry_csa3             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_prod13_prod14_prod15_csa4 (
    .in_1                   (mul_partial_product13  ),
    .in_2                   (mul_partial_product14  ),
    .in_3                   (mul_partial_product15  ),
    .sum                    (sum_csa4               ),
    .carry                  (carry_csa4             )
);
//////////////////////////stage_2////////////////////////////////////
csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_sum0_carry0_sum1_csa5 (
    .in_1                   (sum_csa0               ),
    .in_2                   (carry_csa0             ),
    .in_3                   (sum_csa1               ),
    .sum                    (sum_csa5               ),
    .carry                  (carry_csa5             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_carry1_sum2_carry2_csa6 (
    .in_1                   (carry_csa1             ),
    .in_2                   (sum_csa2               ),
    .in_3                   (carry_csa2             ),
    .sum                    (sum_csa6               ),
    .carry                  (carry_csa6             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_sum3_carry3_sum4_csa7 (
    .in_1                   (sum_csa3               ),
    .in_2                   (carry_csa3             ),
    .in_3                   (sum_csa4               ),
    .sum                    (sum_csa7               ),
    .carry                  (carry_csa7             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_carry4_prod16_prod17_csa8 (
    .in_1                   (carry_csa4             ),
    .in_2                   (mul_partial_product16  ),
    .in_3                   (mul_partial_product17  ),
    .sum                    (sum_csa8               ),
    .carry                  (carry_csa8             )
);
///////////////////////stage_3//////////////////////////
csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_sum5_carry5_sum6_csa9 (
    .in_1                   (sum_csa5               ),
    .in_2                   (carry_csa5             ),
    .in_3                   (sum_csa6               ),
    .sum                    (sum_csa9               ),
    .carry                  (carry_csa9             )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_carry6_sum7_carry7_csa10 (
    .in_1                   (carry_csa6             ),
    .in_2                   (sum_csa7               ),
    .in_3                   (carry_csa7             ),
    .sum                    (sum_csa10              ),
    .carry                  (carry_csa10            )
);
///////////////////////stage_4//////////////////////////
csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_sum9_carry9_sum10_csa11 (
    .in_1                   (sum_csa9               ),
    .in_2                   (carry_csa9             ),
    .in_3                   (sum_csa10              ),
    .sum                    (sum_csa11              ),
    .carry                  (carry_csa11            )
);

csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_carry10_sum8_carry8_csa12 (
    .in_1                   (carry_csa10            ),
    .in_2                   (sum_csa8               ),
    .in_3                   (carry_csa8             ),
    .sum                    (sum_csa12              ),
    .carry                  (carry_csa12            )
);
/////////////////////stage_5//////////////////////////
csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_sum11_carry11_sum12_csa13 (
    .in_1                   (sum_csa11              ),
    .in_2                   (carry_csa11            ),
    .in_3                   (sum_csa12              ),
    .sum                    (sum_csa13              ),
    .carry                  (carry_csa13            )
);
/////////////////////stage_5//////////////////////////
csa #(
    .SIGNED_WORD_WIDTH      (SIGNED_WORD_WIDTH      ),
    .PARTIAL_PRODUCT_WIDTH  (PARTIAL_PRODUCT_WIDTH  )
) u_sum13_carry13_carry12_csa14 (
    .in_1                   (sum_csa13              ),
    .in_2                   (carry_csa13            ),
    .in_3                   (carry_csa12            ),
    .sum                    (sum_csa14              ),
    .carry                  (carry_csa14            )
);
////////////////a+b//////////////////////////////////
assign mul_add_a = sum_csa14;
assign mul_add_b = carry_csa14;

endmodule
`endif