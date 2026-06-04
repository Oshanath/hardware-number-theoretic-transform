`timescale 1ns/1ps

module modular_multiplicator # (
    parameter width = 10,
    parameter modulus = 17
)(
    input [width-1:0] a, b,
    output [width-1:0] p
);

wire [width-1:0] a_reduced;
modular_reducer # (
    .width(width),
    .modulus(modulus)
) mra (
    .x(a),
    .xmodn(a_reduced)
);

wire [width-1:0] b_reduced;
modular_reducer # (
    .width(width),
    .modulus(modulus)
) mrb (
    .x(b),
    .xmodn(b_reduced)
);

wire [width*2-1:0] p_temp;
wire [width*2-1:0] p_reduced;
assign p_temp = a_reduced * b_reduced;

modular_reducer # (
    .width(width*2),
    .modulus(modulus)
) mrp (
    .x(p_temp),
    .xmodn(p_reduced)
);

assign p = p_reduced[width-1:0];

endmodule
