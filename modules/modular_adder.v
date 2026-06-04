`timescale 1ns/1ps

module modular_adder # (
    parameter width = 10,
    parameter modulus = 17
) (
    input [width-1:0] a,
    input [width-1:0] b,
    output [width-1:0] s
);

    wire [width-1:0] a_reduced;
    wire [width-1:0] b_reduced;

    modular_reducer #(
        .width(width),
        .modulus(modulus)
    ) mra (
        .x(a),
        .xmodn(a_reduced)
    );

    modular_reducer #(
        .width(width),
        .modulus(modulus)
    ) mrb (
        .x(b),
        .xmodn(b_reduced)
    );

    wire[width-1:0] s_temp;

    n_bit_adder # (
        .width(width)
    ) adder (
        .a(a_reduced),
        .b(b_reduced),
        .s(s_temp)
    );

    wire[width-1:0] s_reduced;
    modular_reducer #(
        .width(width),
        .modulus(modulus)
    ) mrs (
        .x(s_temp),
        .xmodn(s)
    );

endmodule
