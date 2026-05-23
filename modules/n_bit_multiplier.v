`timescale 1ns/1ps

module n_bit_multiplier #(
    parameter width = 16
)(
    input [width - 1:0] a,
    input [width - 1:0] b,
    output [width - 1:0] p,
    output overflow
);

    wire [(2 * width) - 1:0] partial_products [0:width - 1];
    wire [(2 * width) - 1:0] partial_sums [0:width - 1];

    generate
        for (genvar i = 0; i < width; i = i + 1) begin : gen_partial_product_rows
            for (genvar j = 0; j < 2 * width; j = j + 1) begin : gen_partial_product_bits
                if ((j >= i) && (j < i + width)) begin
                    assign partial_products[i][j] = a[j - i] & b[i];
                end else begin
                    assign partial_products[i][j] = 1'b0;
                end
            end
        end

        assign partial_sums[0] = partial_products[0];

        for (genvar i = 1; i < width; i = i + 1) begin : gen_partial_product_adders
            wire unused_cout;

            n_bit_adder #(
                .width(2 * width)
            ) partial_product_adder (
                .a(partial_sums[i - 1]),
                .b(partial_products[i]),
                .s(partial_sums[i]),
                .cout(unused_cout)
            );
        end
    endgenerate

    assign p = partial_sums[width - 1][width - 1:0];
    assign overflow = |partial_sums[width - 1][(2 * width) - 1:width];

endmodule
