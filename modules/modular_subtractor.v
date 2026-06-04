`timescale 1ns/1ps

module modular_subtractor # (
    parameter width = 10,
    parameter modulus = 17
) (
    input [width-1:0] a,
    input [width-1:0] b,
    output [width-1:0] d
);

wire [width-1:0] a_reduced;
wire [width-1:0] b_reduced;
localparam [width-1:0] modulus_sized = modulus[width-1:0];

modular_reducer # (
    .width(width),
    .modulus(modulus)
) mra (
    .x(a),
    .xmodn(a_reduced)
);

modular_reducer # (
    .width(width),
    .modulus(modulus)
) mrb (
    .x(b),
    .xmodn(b_reduced)
);

reg [width-1:0] a_temp;
wire [width-1:0] a_added;

n_bit_adder # (
    .width(width)
) adder_a_temp (
    .a(a_reduced),
    .b(modulus_sized),
    .s(a_added)
);

always @ (*) begin
    if (b_reduced > a_reduced) begin
        a_temp = a_added;
    end else begin
        a_temp = a_reduced;
    end
end

n_bit_subtractor # (
    .width(width)
) sub_ab (
    .a(a_temp),
    .b(b_reduced),
    .d(d)
);

endmodule
