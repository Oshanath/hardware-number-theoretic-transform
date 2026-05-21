`timescale 1ns/1ps

module n_bit_adder #(
    parameter width = 4
) (
    input [width - 1:0] a,
    input [width - 1:0] b,
    output [width - 1:0] s,
    output cout
);

wire [width:0] cins;
assign cins[0] = 1'b0;
assign cout = cins[width];

generate
    for (genvar i = 0; i < width; i = i + 1) begin
        full_adder fa (
            .a(a[i]),
            .b(b[i]),
            .cin(cins[i]),
            .s(s[i]),
            .cout(cins[i+1])
        );
    end
endgenerate

endmodule
