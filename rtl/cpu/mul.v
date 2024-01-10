`ifndef SIICPU_MUL
`define SIICPU_MUL
`include "define.v"
module mul #(
    parameter SIGNED_WORD_WIDTH = `WORD_WIDTH + 1,
    parameter PARTIAL_PRODUCT_WIDTH = SIGNED_WORD_WIDTH + SIGNED_WORD_WIDTH
)(
    input wire [2:0]                            mul_opcode,
    input wire [`WORD_WIDTH-1 : 0]              mul_data1,
    input wire [`WORD_WIDTH-1 : 0]              mul_data2,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_add_a,
    output wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_add_b
);

wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product1;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product2;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product3;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product4;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product5;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product6;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product7;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product8;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product9;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product10;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product11;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product12;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product13;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product14;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product15;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product16;
wire [PARTIAL_PRODUCT_WIDTH-1 : 0]   mul_partial_product17;

booth_radix_4 u_booth_radix_4(
    .mul_opcode                     (mul_opcode                     ),
    .mul_data1                      (mul_data1                      ),
    .mul_data2                      (mul_data2                      ),
    .mul_partial_product1           (mul_partial_product1           ),
    .mul_partial_product2           (mul_partial_product2           ),
    .mul_partial_product3           (mul_partial_product3           ),
    .mul_partial_product4           (mul_partial_product4           ),
    .mul_partial_product5           (mul_partial_product5           ),
    .mul_partial_product6           (mul_partial_product6           ),
    .mul_partial_product7           (mul_partial_product7           ),
    .mul_partial_product8           (mul_partial_product8           ),
    .mul_partial_product9           (mul_partial_product9           ),
    .mul_partial_product10          (mul_partial_product10          ),
    .mul_partial_product11          (mul_partial_product11          ),
    .mul_partial_product12          (mul_partial_product12          ),
    .mul_partial_product13          (mul_partial_product13          ),
    .mul_partial_product14          (mul_partial_product14          ),
    .mul_partial_product15          (mul_partial_product15          ),
    .mul_partial_product16          (mul_partial_product16          ),
    .mul_partial_product17          (mul_partial_product17          )
);

wallace #(
    .SIGNED_WORD_WIDTH              (SIGNED_WORD_WIDTH              ),
    .PARTIAL_PRODUCT_WIDTH          (PARTIAL_PRODUCT_WIDTH          )
) u_wallace(
    .mul_partial_product1           (mul_partial_product1           ),
    .mul_partial_product2           (mul_partial_product2           ),
    .mul_partial_product3           (mul_partial_product3           ),
    .mul_partial_product4           (mul_partial_product4           ),
    .mul_partial_product5           (mul_partial_product5           ),
    .mul_partial_product6           (mul_partial_product6           ),
    .mul_partial_product7           (mul_partial_product7           ),
    .mul_partial_product8           (mul_partial_product8           ),
    .mul_partial_product9           (mul_partial_product9           ),
    .mul_partial_product10          (mul_partial_product10          ),
    .mul_partial_product11          (mul_partial_product11          ),
    .mul_partial_product12          (mul_partial_product12          ),
    .mul_partial_product13          (mul_partial_product13          ),
    .mul_partial_product14          (mul_partial_product14          ),
    .mul_partial_product15          (mul_partial_product15          ),
    .mul_partial_product16          (mul_partial_product16          ),
    .mul_partial_product17          (mul_partial_product17          ),
    .mul_add_a                      (mul_add_a                      ),
    .mul_add_b                      (mul_add_b                      )
);


endmodule
`endif