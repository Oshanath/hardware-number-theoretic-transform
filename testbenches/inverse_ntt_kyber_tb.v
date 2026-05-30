`timescale 1ns/1ps

module inverse_ntt_kyber_tb;

    localparam integer WIDTH = 24;
    localparam integer MODULUS = 3329;
    localparam integer ROOT = 17;
    localparam integer N = 256;
    localparam integer N_INVERSE = 3316;

    reg [N-1:0][WIDTH-1:0] a;
    wire [N-1:0][WIDTH-1:0] t;

    integer expected [N-1:0];
    integer errors;

    ntt_combinational #(
        .width(WIDTH),
        .modulus(MODULUS),
        .root(ROOT),
        .n(N),
        .n_inverse(N_INVERSE)
    ) dut (
        .a(a),
        .t(t)
    );

    initial begin
        $dumpfile("inverse_ntt_kyber_tb.vcd");
        $dumpvars(0, inverse_ntt_kyber_tb);

        errors = 0;

        run_testcase(1, "zero");
        run_testcase(2, "unit_impulse");
        run_testcase(3, "constant_one");
        run_testcase(4, "ascending");
        run_testcase(5, "kyber_like_pattern");

        if (errors == 0) begin
            $display("All Kyber-scale inverse NTT tests passed.");
        end else begin
            $display("Kyber-scale inverse NTT tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    function integer mod_pow;
        input integer base;
        input integer exponent;
        input integer modulus;

        integer i;
        begin
            mod_pow = 1;

            for (i = 0; i < exponent; i = i + 1) begin
                mod_pow = (mod_pow * base) % modulus;
            end
        end
    endfunction

    function integer coeff_for;
        input integer testcase;
        input integer index;

        integer lcg;
        begin
            case (testcase)
                1: coeff_for = 0;
                2: coeff_for = (index == 0) ? 1 : 0;
                3: coeff_for = 1;
                4: coeff_for = index % MODULUS;
                5: begin
                    lcg = (1229 * index + 321) % MODULUS;
                    coeff_for = (lcg * lcg + 7 * index + 11) % MODULUS;
                end
                default: coeff_for = 0;
            endcase
        end
    endfunction

    task calculate_expected;
        integer k;
        integer j;
        integer sum;
        integer exponent;
        begin
            for (k = 0; k < N; k = k + 1) begin
                sum = 0;

                for (j = 0; j < N; j = j + 1) begin
                    exponent = (N - ((j * k) % N)) % N;
                    sum = (sum + (a[j] % MODULUS) * mod_pow(ROOT, exponent, MODULUS)) % MODULUS;
                end

                expected[k] = (sum * N_INVERSE) % MODULUS;
            end
        end
    endtask

    task run_testcase;
        input integer testcase;
        input [8*32-1:0] label;

        integer i;
        integer failed;
        integer next_coeff;
        integer first_mismatch;
        begin
            for (i = 0; i < N; i = i + 1) begin
                next_coeff = coeff_for(testcase, i);
                a[i] = next_coeff[WIDTH-1:0];
            end

            calculate_expected();

            #10;

            failed = 0;
            first_mismatch = -1;
            for (i = 0; i < N; i = i + 1) begin
                if (t[i] !== expected[i][WIDTH-1:0]) begin
                    failed = 1;
                    if (first_mismatch == -1) begin
                        first_mismatch = i;
                    end
                end
            end

            $display("TESTCASE Kyber inverse N=%0d testcase=%0d label=%0s modulus=%0d root=%0d n_inverse=%0d",
                N, testcase, label, MODULUS, ROOT, N_INVERSE);

            if (failed) begin
                $display("FAIL Kyber inverse testcase=%0d first_mismatch=%0d got=%0d expected=%0d",
                    testcase, first_mismatch, t[first_mismatch], expected[first_mismatch]);
                errors = errors + 1;
            end else begin
                $display("PASS Kyber inverse testcase=%0d sample got[0..7]=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected[0..7]=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                    testcase,
                    t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7],
                    expected[0], expected[1], expected[2], expected[3],
                    expected[4], expected[5], expected[6], expected[7]);
            end
        end
    endtask

endmodule
