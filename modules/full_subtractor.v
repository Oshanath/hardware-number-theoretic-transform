`timescale 1ns/1ps

module full_subtractor (
    input a,
    input b,
    input bal_in,
    output d,
    output bal_out
);

assign d = a ^ b ^ bal_in;
assign bal_out = (b & bal_in) | (~a & bal_in) | (~a & b);

endmodule
