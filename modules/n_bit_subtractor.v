`timescale 1ns/1ps

module n_bit_subtractor # (
    parameter width = 4
)
(
    input [width - 1:0] a,
    input [width - 1:0] b,
    output [width - 1:0] d,
    output bal
);

wire [width:0] balances;
assign balances[0] = 1'b0;
assign bal = balances[width];

generate
    for (genvar i = 0; i < width; i = i + 1) begin
        full_subtractor fs (
            .a(a[i]),
            .b(b[i]),
            .bal_in(balances[i]),
            .d(d[i]),
            .bal_out(balances[i+1])
        );
    end
endgenerate

endmodule
