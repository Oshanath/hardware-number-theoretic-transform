`timescale 1ns/1ps

module ntt_function_tb;

    localparam integer WIDTH8 = 10;
    localparam integer MODULUS8 = 17;
    localparam integer ROOT8 = 9;
    localparam integer N8 = 8;
    localparam integer STAGES8 = 3;

    localparam integer WIDTH16 = 16;
    localparam integer MODULUS16 = 97;
    localparam integer ROOT16 = 5;
    localparam integer N16 = 16;
    localparam integer STAGES16 = 4;

    reg [N8-1:0][WIDTH8-1:0] a8;
    wire [N8-1:0][WIDTH8-1:0] t8;

    reg [N16-1:0][WIDTH16-1:0] a16;
    wire [N16-1:0][WIDTH16-1:0] t16;

    integer errors;

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
        .width(WIDTH16),
        .modulus(MODULUS16),
        .root(ROOT16),
        .n(N16)
    ) dut16 (
        .a(a16),
        .t(t16)
    );

    initial begin

        a8 = '0;
        a16 = '0;
        errors = 0;

        check_bit_reverse_8(0);
        check_bit_reverse_8(1);
        check_bit_reverse_8(3);
        check_bit_reverse_8(5);
        check_bit_reverse_8(N8 - 1);

        check_bit_rotate_8(0, 1);
        check_bit_rotate_8(1, 1);
        check_bit_rotate_8(3, 2);
        check_bit_rotate_8(5, STAGES8);
        check_bit_rotate_8(N8 - 1, STAGES8);

        check_bit_reverse_16(0);
        check_bit_reverse_16(1);
        check_bit_reverse_16(6);
        check_bit_reverse_16(9);
        check_bit_reverse_16(N16 - 1);

        check_bit_rotate_16(0, 1);
        check_bit_rotate_16(1, 1);
        check_bit_rotate_16(6, 3);
        check_bit_rotate_16(9, STAGES16);
        check_bit_rotate_16(N16 - 1, STAGES16);

        if (errors == 0) begin
            $display("All NTT function tests passed.");
        end else begin
            $display("NTT function tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    function integer expected_bit_reverse;
        input integer x;
        input integer stages;

        integer j;
        integer temp;
        begin
            expected_bit_reverse = 0;
            temp = x;

            for (j = 0; j < stages; j = j + 1) begin
                expected_bit_reverse = (expected_bit_reverse * 2) + (temp % 2);
                temp = temp / 2;
            end
        end
    endfunction

    function integer expected_bit_rotate;
        input integer x;
        input integer bit_count;

        integer mask;
        integer low;
        integer high;
        begin
            mask = (1 << bit_count) - 1;
            low = x % (1 << bit_count);
            high = x - low;
            expected_bit_rotate = high + (low / 2) + ((low % 2) * (1 << (bit_count - 1)));
        end
    endfunction

    task check_bit_reverse_8;
        input integer next_x;

        integer actual;
        integer expected;
        begin
            #1;
            actual = dut8.bit_reverse(next_x, STAGES8);
            expected = expected_bit_reverse(next_x, STAGES8);

            if (actual !== expected) begin
                $display("FAIL bit_reverse N=%0d stages=%0d x=%0d | got=%0d | expected=%0d",
                    N8, STAGES8, next_x, actual, expected);
                errors = errors + 1;
            end else begin
                $display("PASS bit_reverse N=%0d stages=%0d x=%0d | got=%0d | expected=%0d",
                    N8, STAGES8, next_x, actual, expected);
            end
        end
    endtask

    task check_bit_rotate_8;
        input integer next_x;
        input integer next_bits;

        integer actual;
        integer expected;
        begin
            #1;
            actual = dut8.bit_rotate(next_x, next_bits);
            expected = expected_bit_rotate(next_x, next_bits);

            if (actual !== expected) begin
                $display("FAIL bit_rotate N=%0d bits=%0d x=%0d | got=%0d | expected=%0d",
                    N8, next_bits, next_x, actual, expected);
                errors = errors + 1;
            end else begin
                $display("PASS bit_rotate N=%0d bits=%0d x=%0d | got=%0d | expected=%0d",
                    N8, next_bits, next_x, actual, expected);
            end
        end
    endtask

    task check_bit_reverse_16;
        input integer next_x;

        integer actual;
        integer expected;
        begin
            #1;
            actual = dut16.bit_reverse(next_x, STAGES16);
            expected = expected_bit_reverse(next_x, STAGES16);

            if (actual !== expected) begin
                $display("FAIL bit_reverse N=%0d stages=%0d x=%0d | got=%0d | expected=%0d",
                    N16, STAGES16, next_x, actual, expected);
                errors = errors + 1;
            end else begin
                $display("PASS bit_reverse N=%0d stages=%0d x=%0d | got=%0d | expected=%0d",
                    N16, STAGES16, next_x, actual, expected);
            end
        end
    endtask

    task check_bit_rotate_16;
        input integer next_x;
        input integer next_bits;

        integer actual;
        integer expected;
        begin
            #1;
            actual = dut16.bit_rotate(next_x, next_bits);
            expected = expected_bit_rotate(next_x, next_bits);

            if (actual !== expected) begin
                $display("FAIL bit_rotate N=%0d bits=%0d x=%0d | got=%0d | expected=%0d",
                    N16, next_bits, next_x, actual, expected);
                errors = errors + 1;
            end else begin
                $display("PASS bit_rotate N=%0d bits=%0d x=%0d | got=%0d | expected=%0d",
                    N16, next_bits, next_x, actual, expected);
            end
        end
    endtask

endmodule
