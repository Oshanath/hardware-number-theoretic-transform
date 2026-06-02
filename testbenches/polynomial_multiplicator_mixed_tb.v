`timescale 1ns/1ps

module polynomial_multiplicator_mixed_tb;

    localparam integer WIDTH8 = 16;
    localparam integer MODULUS8 = 17;
    localparam integer ROOT8 = 9;
    localparam integer N8 = 8;
    localparam integer N_INV8 = 15;

    localparam integer WIDTH4 = 8;
    localparam integer MODULUS4 = 17;
    localparam integer ROOT4 = 13;
    localparam integer N4 = 4;
    localparam integer N_INV4 = 13;

    reg clk;
    reg en_in8;
    reg en_in4;

    reg [N8-1:0][WIDTH8-1:0] a8;
    reg [N8-1:0][WIDTH8-1:0] b8;
    wire [N8-1:0][WIDTH8-1:0] p8;
    wire en_out8;

    reg [N4-1:0][WIDTH4-1:0] a4;
    reg [N4-1:0][WIDTH4-1:0] b4;
    wire [N4-1:0][WIDTH4-1:0] p4;
    wire en_out4;

    integer expected8 [N8-1:0];
    integer expected4 [N4-1:0];
    integer errors;
    integer i;
    integer cycles;

    polynomial_multiplicator_mixed #(
        .width(WIDTH8),
        .modulus(MODULUS8),
        .root(ROOT8),
        .n(N8),
        .n_inverse(N_INV8)
    ) dut8 (
        .clk(clk),
        .en_in(en_in8),
        .a(a8),
        .b(b8),
        .p(p8),
        .en_out(en_out8)
    );

    polynomial_multiplicator_mixed #(
        .width(WIDTH4),
        .modulus(MODULUS4),
        .root(ROOT4),
        .n(N4),
        .n_inverse(N_INV4)
    ) dut4 (
        .clk(clk),
        .en_in(en_in4),
        .a(a4),
        .b(b4),
        .p(p4),
        .en_out(en_out4)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("polynomial_multiplicator_mixed_tb.vcd");
        $dumpvars(0, polynomial_multiplicator_mixed_tb);

        clk = 1'b0;
        en_in8 = 1'b0;
        en_in4 = 1'b0;
        a8 = '0;
        b8 = '0;
        a4 = '0;
        b4 = '0;
        errors = 0;

        #2;

        run_poly8(1,  0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0);
        run_poly8(2,  1, 0, 0, 0, 0, 0, 0, 0,   3, 1, 4, 1, 5, 9, 2, 6);
        run_poly8(3,  1, 2, 3, 4, 5, 6, 7, 8,   8, 7, 6, 5, 4, 3, 2, 1);
        run_poly8(4,  0, 1, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 1);
        run_poly8(5, 16,15,14,13,12,11,10, 9,   1, 2, 3, 4, 5, 6, 7, 8);
        run_poly8(6, 17,18,19,20,21,22,23,24,  25,26,27,28,29,30,31,32);

        run_poly4(1, 0, 0, 0, 0,   0, 0, 0, 0);
        run_poly4(2, 1, 0, 0, 0,   3, 1, 4, 1);
        run_poly4(3, 1, 2, 3, 4,   4, 3, 2, 1);
        run_poly4(4, 0, 1, 0, 0,   0, 0, 0, 1);
        run_poly4(5, 16,15,14,13,  1, 2, 3, 4);
        run_poly4(6, 17,18,19,20,  21,22,23,24);

        if (errors == 0) begin
            $display("All polynomial multiplicator mixed tests passed.");
        end else begin
            $display("Polynomial multiplicator mixed tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task wait_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task calculate_expected8;
        integer i;
        integer j;
        integer source_index;
        integer sum;
        begin
            for (i = 0; i < N8; i = i + 1) begin
                sum = 0;

                for (j = 0; j < N8; j = j + 1) begin
                    source_index = (i - j + N8) % N8;
                    sum = (sum + (a8[j] % MODULUS8) * (b8[source_index] % MODULUS8)) % MODULUS8;
                end

                expected8[i] = sum;
            end
        end
    endtask

    task calculate_expected4;
        integer i;
        integer j;
        integer source_index;
        integer sum;
        begin
            for (i = 0; i < N4; i = i + 1) begin
                sum = 0;

                for (j = 0; j < N4; j = j + 1) begin
                    source_index = (i - j + N4) % N4;
                    sum = (sum + (a4[j] % MODULUS4) * (b4[source_index] % MODULUS4)) % MODULUS4;
                end

                expected4[i] = sum;
            end
        end
    endtask

    task run_poly8;
        input integer testcase;
        input integer a0;
        input integer a1;
        input integer a2;
        input integer a3;
        input integer a4_in;
        input integer a5;
        input integer a6;
        input integer a7;
        input integer b0;
        input integer b1;
        input integer b2;
        input integer b3;
        input integer b4_in;
        input integer b5;
        input integer b6;
        input integer b7;

        begin
            a8[0] = a0[WIDTH8-1:0];
            a8[1] = a1[WIDTH8-1:0];
            a8[2] = a2[WIDTH8-1:0];
            a8[3] = a3[WIDTH8-1:0];
            a8[4] = a4_in[WIDTH8-1:0];
            a8[5] = a5[WIDTH8-1:0];
            a8[6] = a6[WIDTH8-1:0];
            a8[7] = a7[WIDTH8-1:0];
            b8[0] = b0[WIDTH8-1:0];
            b8[1] = b1[WIDTH8-1:0];
            b8[2] = b2[WIDTH8-1:0];
            b8[3] = b3[WIDTH8-1:0];
            b8[4] = b4_in[WIDTH8-1:0];
            b8[5] = b5[WIDTH8-1:0];
            b8[6] = b6[WIDTH8-1:0];
            b8[7] = b7[WIDTH8-1:0];

            calculate_expected8();

            $display("TESTCASE mixed poly N=8 testcase=%0d setup", testcase);
            for (i = 0; i < N8; i = i + 1) begin
                $display("  input a[%0d]=%0d input b[%0d]=%0d", i, a8[i], i, b8[i]);
            end

            en_in8 = 1'b1;
            wait_cycle;
            en_in8 = 1'b0;

            cycles = 0;
            while (!en_out8 && cycles < 100) begin
                wait_cycle;
                cycles = cycles + 1;
            end

            if (!en_out8) begin
                $display("FAIL mixed poly N=8 testcase=%0d timed out waiting for en_out", testcase);
                errors = errors + 1;
            end

            $display("TESTCASE mixed poly N=8 testcase=%0d output", testcase);
            $display("  cycles=%0d en_out=%0b", cycles, en_out8);
            for (i = 0; i < N8; i = i + 1) begin
                $display("  output p[%0d]=%0d expected[%0d]=%0d", i, p8[i], i, expected8[i]);
                if (p8[i] !== expected8[i][WIDTH8-1:0]) begin
                    errors = errors + 1;
                end
            end

            if ((p8[0] !== expected8[0][WIDTH8-1:0]) ||
                (p8[1] !== expected8[1][WIDTH8-1:0]) ||
                (p8[2] !== expected8[2][WIDTH8-1:0]) ||
                (p8[3] !== expected8[3][WIDTH8-1:0]) ||
                (p8[4] !== expected8[4][WIDTH8-1:0]) ||
                (p8[5] !== expected8[5][WIDTH8-1:0]) ||
                (p8[6] !== expected8[6][WIDTH8-1:0]) ||
                (p8[7] !== expected8[7][WIDTH8-1:0])) begin
                $display("FAIL mixed poly N=8 testcase=%0d modulus=%0d root=%0d n_inverse=%0d",
                    testcase, MODULUS8, ROOT8, N_INV8);
            end else begin
                $display("PASS mixed poly N=8 testcase=%0d modulus=%0d root=%0d n_inverse=%0d",
                    testcase, MODULUS8, ROOT8, N_INV8);
            end

            wait_cycle;
        end
    endtask

    task run_poly4;
        input integer testcase;
        input integer a0;
        input integer a1;
        input integer a2;
        input integer a3;
        input integer b0;
        input integer b1;
        input integer b2;
        input integer b3;

        begin
            a4[0] = a0[WIDTH4-1:0];
            a4[1] = a1[WIDTH4-1:0];
            a4[2] = a2[WIDTH4-1:0];
            a4[3] = a3[WIDTH4-1:0];
            b4[0] = b0[WIDTH4-1:0];
            b4[1] = b1[WIDTH4-1:0];
            b4[2] = b2[WIDTH4-1:0];
            b4[3] = b3[WIDTH4-1:0];

            calculate_expected4();

            $display("TESTCASE mixed poly N=4 testcase=%0d setup", testcase);
            for (i = 0; i < N4; i = i + 1) begin
                $display("  input a[%0d]=%0d input b[%0d]=%0d", i, a4[i], i, b4[i]);
            end

            en_in4 = 1'b1;
            wait_cycle;
            en_in4 = 1'b0;

            cycles = 0;
            while (!en_out4 && cycles < 100) begin
                wait_cycle;
                cycles = cycles + 1;
            end

            if (!en_out4) begin
                $display("FAIL mixed poly N=4 testcase=%0d timed out waiting for en_out", testcase);
                errors = errors + 1;
            end

            $display("TESTCASE mixed poly N=4 testcase=%0d output", testcase);
            $display("  cycles=%0d en_out=%0b", cycles, en_out4);
            for (i = 0; i < N4; i = i + 1) begin
                $display("  output p[%0d]=%0d expected[%0d]=%0d", i, p4[i], i, expected4[i]);
                if (p4[i] !== expected4[i][WIDTH4-1:0]) begin
                    errors = errors + 1;
                end
            end

            if ((p4[0] !== expected4[0][WIDTH4-1:0]) ||
                (p4[1] !== expected4[1][WIDTH4-1:0]) ||
                (p4[2] !== expected4[2][WIDTH4-1:0]) ||
                (p4[3] !== expected4[3][WIDTH4-1:0])) begin
                $display("FAIL mixed poly N=4 testcase=%0d modulus=%0d root=%0d n_inverse=%0d",
                    testcase, MODULUS4, ROOT4, N_INV4);
            end else begin
                $display("PASS mixed poly N=4 testcase=%0d modulus=%0d root=%0d n_inverse=%0d",
                    testcase, MODULUS4, ROOT4, N_INV4);
            end

            wait_cycle;
        end
    endtask

endmodule
