`timescale 1ns/1ps

module inverse_ntt_single_tb;

    localparam integer WIDTH = 10;
    localparam integer MODULUS = 17;
    localparam integer ROOT = 9;
    localparam integer N = 8;

    reg [N-1:0][WIDTH-1:0] a;
    wire [N-1:0][WIDTH-1:0] t;

    integer errors;

    ntt_combinational #(
        .width(WIDTH),
        .modulus(MODULUS),
        .root(ROOT),
        .n(N)
    ) dut (
        .a(a),
        .t(t)
    );

    initial begin
        $dumpfile("inverse_ntt_single_tb.vcd");
        $dumpvars(0, inverse_ntt_single_tb);

        errors = 0;

        a[0] = 2;
        a[1] = 1;
        a[2] = 12;
        a[3] = 3;
        a[4] = 13;
        a[5] = 6;
        a[6] = 14;
        a[7] = 8;

        #10;

        $display("TESTCASE inverse_ntt_single N=%0d modulus=%0d root=%0d input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected=(1,2,3,4,5,6,7,8)",
            N, MODULUS, ROOT,
            a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);

        if ((t[0] !== 1) ||
            (t[1] !== 2) ||
            (t[2] !== 3) ||
            (t[3] !== 4) ||
            (t[4] !== 5) ||
            (t[5] !== 6) ||
            (t[6] !== 7) ||
            (t[7] !== 8)) begin
            $display("FAIL inverse_ntt_single got=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected=(1,2,3,4,5,6,7,8)",
                t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7]);
            errors = errors + 1;
        end else begin
            $display("PASS inverse_ntt_single got=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected=(1,2,3,4,5,6,7,8)",
                t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7]);
        end

        if (errors == 0) begin
            $display("All inverse NTT single tests passed.");
        end else begin
            $display("inverse NTT single tests failed with %0d error(s).", errors);
        end

        $finish;
    end

endmodule
