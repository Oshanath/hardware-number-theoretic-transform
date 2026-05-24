`timescale 1ns/1ps

module ntt_combinational_run_tb;

    localparam integer WIDTH8 = 10;
    localparam integer MODULUS8 = 17;
    localparam integer ROOT8 = 9;
    localparam integer N8 = 8;

    localparam integer WIDTH4 = 8;
    localparam integer MODULUS4 = 17;
    localparam integer ROOT4 = 13;
    localparam integer N4 = 4;

    reg [N8-1:0][WIDTH8-1:0] a8;
    wire [N8-1:0][WIDTH8-1:0] t8;

    reg [N4-1:0][WIDTH4-1:0] a4;
    wire [N4-1:0][WIDTH4-1:0] t4;

    ntt_combinational #(
        .width(WIDTH8),
        .modulus(MODULUS8),
        .root(ROOT8),
        .n(N8)
    ) dut8 (
        .a(a8),
        .t(t8)
    );

    ntt_combinational #(
        .width(WIDTH4),
        .modulus(MODULUS4),
        .root(ROOT4),
        .n(N4)
    ) dut4 (
        .a(a4),
        .t(t4)
    );

    initial begin
        $dumpfile("ntt_combinational_run_tb.vcd");
        $dumpvars(0, ntt_combinational_run_tb);

        a8[0] = 10'd1;
        a8[1] = 10'd2;
        a8[2] = 10'd3;
        a8[3] = 10'd4;
        a8[4] = 10'd5;
        a8[5] = 10'd6;
        a8[6] = 10'd7;
        a8[7] = 10'd8;

        a4[0] = 8'd1;
        a4[1] = 8'd2;
        a4[2] = 8'd3;
        a4[3] = 8'd4;

        #10;

        $display("TESTCASE N=8 width=%0d modulus=%0d root=%0d input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
            WIDTH8, MODULUS8, ROOT8, a8[0], a8[1], a8[2], a8[3], a8[4], a8[5], a8[6], a8[7]);
        $display("OUTPUT N=8 t=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
            t8[0], t8[1], t8[2], t8[3], t8[4], t8[5], t8[6], t8[7]);

        $display("TESTCASE N=4 width=%0d modulus=%0d root=%0d input=(%0d,%0d,%0d,%0d)",
            WIDTH4, MODULUS4, ROOT4, a4[0], a4[1], a4[2], a4[3]);
        $display("OUTPUT N=4 t=(%0d,%0d,%0d,%0d)",
            t4[0], t4[1], t4[2], t4[3]);

        $finish;
    end

endmodule
