`timescale 1ns/1ps

module ml_kem_ntt_tb;

    localparam integer KYBER_WIDTH = 24;
    localparam integer KYBER_MODULUS = 3329;
    localparam integer KYBER_ROOT = 17;
    localparam integer KYBER_N = 256;

    localparam integer SMALL_WIDTH = 10;
    localparam integer SMALL_MODULUS = 17;
    localparam integer SMALL_ROOT = 9;
    localparam integer SMALL_N = 8;

    reg [KYBER_N-1:0][KYBER_WIDTH-1:0] kyber_a;
    wire [KYBER_N-1:0][KYBER_WIDTH-1:0] kyber_t;

    reg [SMALL_N-1:0][SMALL_WIDTH-1:0] small_a;
    wire [SMALL_N-1:0][SMALL_WIDTH-1:0] small_t;

    integer kyber_expected [0:KYBER_N-1];
    integer small_expected [0:SMALL_N-1];
    integer errors;

    ntt_combinational #(
        .width(KYBER_WIDTH),
        .modulus(KYBER_MODULUS),
        .root(KYBER_ROOT),
        .n(KYBER_N)
    ) kyber_dut (
        .a(kyber_a),
        .t(kyber_t)
    );

    ntt_combinational #(
        .width(SMALL_WIDTH),
        .modulus(SMALL_MODULUS),
        .root(SMALL_ROOT),
        .n(SMALL_N)
    ) small_dut (
        .a(small_a),
        .t(small_t)
    );

    initial begin
        errors = 0;

        run_kyber_testcase(1);
        run_kyber_testcase(2);
        run_kyber_testcase(3);
        run_kyber_testcase(4);
        run_kyber_testcase(5);
        run_kyber_testcase(6);
        run_kyber_testcase(7);
        run_kyber_testcase(8);
        run_kyber_testcase(9);
        run_kyber_testcase(10);

        run_small_testcase(1);
        run_small_testcase(2);

        if (errors == 0) begin
            $display("All ML-KEM-style NTT tests passed.");
        end else begin
            $display("ML-KEM-style NTT tests failed with %0d error(s).", errors);
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

    function integer kyber_coeff;
        input integer testcase;
        input integer index;

        integer lcg;
        begin
            case (testcase)
                1: kyber_coeff = 0;
                2: kyber_coeff = (index == 0) ? 1 : 0;
                3: kyber_coeff = (index == 0) ? KYBER_MODULUS - 1 : 0;
                4: kyber_coeff = index % KYBER_MODULUS;
                5: kyber_coeff = (KYBER_N - 1 - index) % KYBER_MODULUS;
                6: kyber_coeff = (index[0] == 1'b0) ? 1 : KYBER_MODULUS - 1;
                7: kyber_coeff = (index % 3 == 0) ? 2 : ((index % 3 == 1) ? KYBER_MODULUS - 2 : 0);
                8: kyber_coeff = (index % 5 == 0) ? 3 : ((index % 5 == 1) ? KYBER_MODULUS - 3 : 0);
                9: begin
                    lcg = (17 * index + 91) % KYBER_MODULUS;
                    kyber_coeff = lcg;
                end
                10: begin
                    lcg = (1229 * index + 321) % KYBER_MODULUS;
                    kyber_coeff = (lcg * lcg + 7 * index + 11) % KYBER_MODULUS;
                end
                default: kyber_coeff = 0;
            endcase
        end
    endfunction

    function integer small_coeff;
        input integer testcase;
        input integer index;

        begin
            case (testcase)
                1: small_coeff = index + 1;
                2: small_coeff = (index[0] == 1'b0) ? 1 : SMALL_MODULUS - 1;
                default: small_coeff = 0;
            endcase
        end
    endfunction

    task calculate_kyber_expected;
        integer k;
        integer j;
        integer sum;
        integer factor;
        integer power;
        begin
            for (k = 0; k < KYBER_N; k = k + 1) begin
                sum = 0;
                factor = mod_pow(KYBER_ROOT, k, KYBER_MODULUS);
                power = 1;

                for (j = 0; j < KYBER_N; j = j + 1) begin
                    sum = (sum + (kyber_a[j] % KYBER_MODULUS) * power) % KYBER_MODULUS;
                    power = (power * factor) % KYBER_MODULUS;
                end

                kyber_expected[k] = sum;
            end
        end
    endtask

    task calculate_small_expected;
        integer k;
        integer j;
        integer sum;
        integer factor;
        integer power;
        begin
            for (k = 0; k < SMALL_N; k = k + 1) begin
                sum = 0;
                factor = mod_pow(SMALL_ROOT, k, SMALL_MODULUS);
                power = 1;

                for (j = 0; j < SMALL_N; j = j + 1) begin
                    sum = (sum + (small_a[j] % SMALL_MODULUS) * power) % SMALL_MODULUS;
                    power = (power * factor) % SMALL_MODULUS;
                end

                small_expected[k] = sum;
            end
        end
    endtask

    task print_kyber_vector;
        input integer testcase;

        integer i;
        begin
            $write("TESTCASE ML-KEM-like N=256 testcase=%0d modulus=%0d root=%0d input=(", testcase, KYBER_MODULUS, KYBER_ROOT);
            for (i = 0; i < KYBER_N; i = i + 1) begin
                if (i != 0) begin
                    $write(",");
                end
                $write("%0d", kyber_a[i]);
            end
            $display(")");
        end
    endtask

    task print_kyber_result;
        input [8*8-1:0] label;

        integer i;
        begin
            $write("%0s=(", label);
            for (i = 0; i < KYBER_N; i = i + 1) begin
                if (i != 0) begin
                    $write(",");
                end
                $write("%0d", kyber_t[i]);
            end
            $display(")");

            $write("expected=(");
            for (i = 0; i < KYBER_N; i = i + 1) begin
                if (i != 0) begin
                    $write(",");
                end
                $write("%0d", kyber_expected[i]);
            end
            $display(")");
        end
    endtask

    task run_kyber_testcase;
        input integer testcase;

        integer i;
        integer failed;
        integer next_coeff;
        begin
            for (i = 0; i < KYBER_N; i = i + 1) begin
                next_coeff = kyber_coeff(testcase, i);
                kyber_a[i] = next_coeff[KYBER_WIDTH-1:0];
            end

            calculate_kyber_expected();

            #10;

            failed = 0;
            for (i = 0; i < KYBER_N; i = i + 1) begin
                if (kyber_t[i] !== kyber_expected[i][KYBER_WIDTH-1:0]) begin
                    failed = 1;
                end
            end

            print_kyber_vector(testcase);
            print_kyber_result(failed ? "got FAIL" : "got PASS");

            if (failed) begin
                errors = errors + 1;
            end
        end
    endtask

    task run_small_testcase;
        input integer testcase;

        integer i;
        integer failed;
        integer next_coeff;
        begin
            for (i = 0; i < SMALL_N; i = i + 1) begin
                next_coeff = small_coeff(testcase, i);
                small_a[i] = next_coeff[SMALL_WIDTH-1:0];
            end

            calculate_small_expected();

            #10;

            failed = 0;
            for (i = 0; i < SMALL_N; i = i + 1) begin
                if (small_t[i] !== small_expected[i][SMALL_WIDTH-1:0]) begin
                    failed = 1;
                end
            end

            $display("TESTCASE small N=8 testcase=%0d modulus=%0d root=%0d input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                testcase, SMALL_MODULUS, SMALL_ROOT,
                small_a[0], small_a[1], small_a[2], small_a[3],
                small_a[4], small_a[5], small_a[6], small_a[7]);
            $display("%s small got=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                failed ? "FAIL" : "PASS",
                small_t[0], small_t[1], small_t[2], small_t[3],
                small_t[4], small_t[5], small_t[6], small_t[7],
                small_expected[0], small_expected[1], small_expected[2], small_expected[3],
                small_expected[4], small_expected[5], small_expected[6], small_expected[7]);

            if (failed) begin
                errors = errors + 1;
            end
        end
    endtask

endmodule
