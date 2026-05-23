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

wire [width-1:0] p_temp;
assign p_temp = a_reduced * b_reduced;

modular_reducer # (
    .width(width),
    .modulus(modulus)
) mrp (
    .x(p_temp),
    .xmodn(p)
);

endmodule