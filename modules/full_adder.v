`timescale 1ns/1ps

`ifndef FULL_ADDER_V
`define FULL_ADDER_V

module full_adder(
    input a,
    input b,
    input cin,
    output s,
    output cout
);

assign s = a ^ b ^ cin;
assign cout = ((a ^ b) & cin) | (a & b);

endmodule

`endif
