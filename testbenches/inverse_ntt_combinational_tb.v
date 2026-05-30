`timescale 1ns/1ps

module inverse_ntt_combinational_tb;

    localparam integer WIDTH8 = 10;
    localparam integer MODULUS8 = 17;
    localparam integer ROOT8 = 9;
    localparam integer N8 = 8;
    localparam integer N_INV8 = 15;

    localparam integer WIDTH4 = 8;
    localparam integer MODULUS4 = 17;
    localparam integer ROOT4 = 13;
    localparam integer N4 = 4;
    localparam integer N_INV4 = 13;

    reg [N8-1:0][WIDTH8-1:0] a8;
    wire [N8-1:0][WIDTH8-1:0] t8;

    reg [N4-1:0][WIDTH4-1:0] a4;
    wire [N4-1:0][WIDTH4-1:0] t4;

    integer expected8 [N8-1:0];
    integer expected4 [N4-1:0];
    integer errors;

    ntt_combinational #(
        .width(WIDTH8),
        .modulus(MODULUS8),
        .root(ROOT8),
        .n(N8),
        .n_inverse(N_INV8)
    ) dut8 (
        .a(a8),
        .t(t8)
    );

    ntt_combinational #(
        .width(WIDTH4),
        .modulus(MODULUS4),
        .root(ROOT4),
        .n(N4),
        .n_inverse(N_INV4)
    ) dut4 (
        .a(a4),
        .t(t4)
    );

    initial begin
        $dumpfile("inverse_ntt_combinational_tb.vcd");
        $dumpvars(0, inverse_ntt_combinational_tb);

        errors = 0;

        run_inverse8(1,  2,  1, 12,  3, 13,  6, 14,  8);
        run_inverse8(2,  0,  0,  0,  0,  0,  0,  0,  0);
        run_inverse8(3,  5,  0,  0,  0,  0,  0,  0,  0);
        run_inverse8(4,  8,  8,  8,  8,  8,  8,  8,  8);
        run_inverse8(5,  8, 14,  6, 13,  3, 12,  1,  2);
        run_inverse8(6,  0,  1,  0,  1,  0,  1,  0,  1);
        run_inverse8(7, 16, 15, 14, 13, 12, 11, 10,  9);
        run_inverse8(8,  3,  1,  4,  1,  5,  9,  2,  6);
        run_inverse8(9,  2,  4,  8, 16, 15, 13,  9,  1);
        run_inverse8(10, 7,  0,  5,  0,  3,  0,  1,  0);

        run_inverse4(1, 10,  7, 15,  6);
        run_inverse4(2,  0,  0,  0,  0);
        run_inverse4(3,  5,  0,  0,  0);
        run_inverse4(4,  8,  8,  8,  8);
        run_inverse4(5,  6, 15,  7, 10);
        run_inverse4(6,  0,  1,  0,  1);
        run_inverse4(7, 16, 15, 14, 13);
        run_inverse4(8,  3,  1,  4,  1);
        run_inverse4(9,  2,  4,  8, 16);
        run_inverse4(10, 7,  0,  5,  0);

        if (errors == 0) begin
            $display("All inverse NTT combinational tests passed.");
        end else begin
            $display("inverse NTT combinational tests failed with %0d error(s).", errors);
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

    task calculate_expected8;
        integer k;
        integer j;
        integer sum;
        integer exponent;
        begin
            for (k = 0; k < N8; k = k + 1) begin
                sum = 0;

                for (j = 0; j < N8; j = j + 1) begin
                    exponent = (N8 - ((j * k) % N8)) % N8;
                    sum = (sum + (a8[j] % MODULUS8) * mod_pow(ROOT8, exponent, MODULUS8)) % MODULUS8;
                end

                expected8[k] = (sum * N_INV8) % MODULUS8;
            end
        end
    endtask

    task calculate_expected4;
        integer k;
        integer j;
        integer sum;
        integer exponent;
        begin
            for (k = 0; k < N4; k = k + 1) begin
                sum = 0;

                for (j = 0; j < N4; j = j + 1) begin
                    exponent = (N4 - ((j * k) % N4)) % N4;
                    sum = (sum + (a4[j] % MODULUS4) * mod_pow(ROOT4, exponent, MODULUS4)) % MODULUS4;
                end

                expected4[k] = (sum * N_INV4) % MODULUS4;
            end
        end
    endtask

    task run_inverse8;
        input integer testcase;
        input integer c0;
        input integer c1;
        input integer c2;
        input integer c3;
        input integer c4;
        input integer c5;
        input integer c6;
        input integer c7;

        begin
            a8[0] = c0[WIDTH8-1:0];
            a8[1] = c1[WIDTH8-1:0];
            a8[2] = c2[WIDTH8-1:0];
            a8[3] = c3[WIDTH8-1:0];
            a8[4] = c4[WIDTH8-1:0];
            a8[5] = c5[WIDTH8-1:0];
            a8[6] = c6[WIDTH8-1:0];
            a8[7] = c7[WIDTH8-1:0];

            calculate_expected8();

            #10;

            if ((t8[0] !== expected8[0][WIDTH8-1:0]) ||
                (t8[1] !== expected8[1][WIDTH8-1:0]) ||
                (t8[2] !== expected8[2][WIDTH8-1:0]) ||
                (t8[3] !== expected8[3][WIDTH8-1:0]) ||
                (t8[4] !== expected8[4][WIDTH8-1:0]) ||
                (t8[5] !== expected8[5][WIDTH8-1:0]) ||
                (t8[6] !== expected8[6][WIDTH8-1:0]) ||
                (t8[7] !== expected8[7][WIDTH8-1:0])) begin
                $display("FAIL inverse N=8 testcase=%0d modulus=%0d root=%0d n_inverse=%0d input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) | got=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) | expected=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                    testcase, MODULUS8, ROOT8, N_INV8,
                    a8[0], a8[1], a8[2], a8[3], a8[4], a8[5], a8[6], a8[7],
                    t8[0], t8[1], t8[2], t8[3], t8[4], t8[5], t8[6], t8[7],
                    expected8[0], expected8[1], expected8[2], expected8[3], expected8[4], expected8[5], expected8[6], expected8[7]);
                errors = errors + 1;
            end else begin
                $display("PASS inverse N=8 testcase=%0d modulus=%0d root=%0d n_inverse=%0d input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) | got=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) | expected=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                    testcase, MODULUS8, ROOT8, N_INV8,
                    a8[0], a8[1], a8[2], a8[3], a8[4], a8[5], a8[6], a8[7],
                    t8[0], t8[1], t8[2], t8[3], t8[4], t8[5], t8[6], t8[7],
                    expected8[0], expected8[1], expected8[2], expected8[3], expected8[4], expected8[5], expected8[6], expected8[7]);
            end
        end
    endtask

    task run_inverse4;
        input integer testcase;
        input integer c0;
        input integer c1;
        input integer c2;
        input integer c3;

        begin
            a4[0] = c0[WIDTH4-1:0];
            a4[1] = c1[WIDTH4-1:0];
            a4[2] = c2[WIDTH4-1:0];
            a4[3] = c3[WIDTH4-1:0];

            calculate_expected4();

            #10;

            if ((t4[0] !== expected4[0][WIDTH4-1:0]) ||
                (t4[1] !== expected4[1][WIDTH4-1:0]) ||
                (t4[2] !== expected4[2][WIDTH4-1:0]) ||
                (t4[3] !== expected4[3][WIDTH4-1:0])) begin
                $display("FAIL inverse N=4 testcase=%0d modulus=%0d root=%0d n_inverse=%0d input=(%0d,%0d,%0d,%0d) | got=(%0d,%0d,%0d,%0d) | expected=(%0d,%0d,%0d,%0d)",
                    testcase, MODULUS4, ROOT4, N_INV4,
                    a4[0], a4[1], a4[2], a4[3],
                    t4[0], t4[1], t4[2], t4[3],
                    expected4[0], expected4[1], expected4[2], expected4[3]);
                errors = errors + 1;
            end else begin
                $display("PASS inverse N=4 testcase=%0d modulus=%0d root=%0d n_inverse=%0d input=(%0d,%0d,%0d,%0d) | got=(%0d,%0d,%0d,%0d) | expected=(%0d,%0d,%0d,%0d)",
                    testcase, MODULUS4, ROOT4, N_INV4,
                    a4[0], a4[1], a4[2], a4[3],
                    t4[0], t4[1], t4[2], t4[3],
                    expected4[0], expected4[1], expected4[2], expected4[3]);
            end
        end
    endtask

endmodule
