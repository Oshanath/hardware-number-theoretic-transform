module ctb # (
    parameter width = 10,
    parameter modulus = 17
)(
    input [width-1:0] a,b,omega,
    output [width-1:0] u,v
);

wire [width-1:0] b_omega;
modular_multiplicator # (
    .width(width),
    .modulus(modulus)
) b_omega_multiplier (
    .a(b),
    .b(omega),
    .p(b_omega)
);

modular_adder # (
    .width(width),
    .modulus(modulus)
) a_plus_b_omega_adder (
    .a(a),
    .b(b_omega),
    .s(u)
);

modular_subtractor # (
    .width(width),
    .modulus(modulus)
) a_plus_b_omega_subtractor (
    .a(a),
    .b(b_omega),
    .d(v)
);

endmodule