module polynomial_multiplicator # (
    parameter width = 16,
    parameter modulus = 17,
    parameter root = 9,
    parameter n = 8,
    parameter n_inverse = 15
) (
    input [n-1:0][width-1:0] a, b,
    output [n-1:0][width-1:0] p
);

wire [n-1:0][width-1:0] a_ntt, b_ntt, p_ntt;

ntt_combinational # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n)
) ntta (
    .a(a),
    .t(a_ntt)
);

ntt_combinational # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n)
) nttb (
    .a(b),
    .t(b_ntt)
);

generate
    for(genvar i = 0; i < n; i = i + 1) begin
        modular_multiplicator # (
            .width(width),
            .modulus(modulus)
        ) mm (
            .a(a_ntt[i]),
            .b(b_ntt[i]),
            .p(p_ntt[i])
        );
    end
endgenerate

inverse_ntt_combinational # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n),
    .n_inverse(n_inverse)
) intt (
    .a(p_ntt),
    .t(p)
);

endmodule