module gsb # (
    parameter width = 10,
    parameter modulus = 17
)(
    input [width-1:0] u,
    input [width-1:0] v,
    input [width-1:0] omega,
    output [width-1:0] a,
    output [width-1:0] b
);

wire [width-1:0] u_minus_v;

modular_adder # (
    .width(width),
    .modulus(modulus)
) u_plus_v_adder (
    .a(u),
    .b(v),
    .s(a)
);

modular_subtractor # (
    .width(width),
    .modulus(modulus)
) u_minus_v_subtractor (
    .a(u),
    .b(v),
    .d(u_minus_v)
);

modular_multiplicator # (
    .width(width),
    .modulus(modulus)
) u_minus_v_omega_multiplier (
    .a(u_minus_v),
    .b(omega),
    .p(b)
);

endmodule
