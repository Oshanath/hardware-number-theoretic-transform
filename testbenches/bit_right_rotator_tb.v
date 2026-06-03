`timescale 1ns/1ps

module bit_right_rotator_tb;

    localparam integer WIDTH8 = 8;
    localparam integer BITS8 = 3;
    localparam integer WIDTH12 = 12;
    localparam integer BITS12 = 5;

    reg [WIDTH8-1:0] a8;
    wire [WIDTH8-1:0] r8;

    reg [WIDTH12-1:0] a12;
    wire [WIDTH12-1:0] r12;

    integer errors;
    integer expected;

    bit_right_rotator #(
        .width(WIDTH8),
        .bits(BITS8)
    ) dut8 (
        .a(a8),
        .r(r8)
    );

    bit_right_rotator #(
        .width(WIDTH12),
        .bits(BITS12)
    ) dut12 (
        .a(a12),
        .r(r12)
    );

    initial begin

        errors = 0;

        check_width8(8'h00);
        check_width8(8'h01);
        check_width8(8'ha5);
        check_width8(8'h5a);
        check_width8(8'hff);

        check_width12(12'h000);
        check_width12(12'h001);
        check_width12(12'h0a5);
        check_width12(12'h3c7);
        check_width12(12'hfff);

        if (errors == 0) begin
            $display("All bit_right_rotator tests passed.");
        end else begin
            $display("bit_right_rotator tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    function integer expected_right_rotate;
        input integer value;
        input integer width;
        input integer bits;
        integer bit_mask;
        integer width_mask;
        integer low;
        integer high;
        integer rotated_low;
        begin
            bit_mask = (1 << bits) - 1;
            width_mask = (1 << width) - 1;
            low = value & bit_mask;
            high = value & (width_mask ^ bit_mask);
            rotated_low = (low >> 1) | ((low & 1) << (bits - 1));
            expected_right_rotate = high | rotated_low;
        end
    endfunction

    task check_width8;
        input [WIDTH8-1:0] value;
        begin
            a8 = value;
            #1;
            expected = expected_right_rotate(value, WIDTH8, BITS8);
            if (r8 !== expected[WIDTH8-1:0]) begin
                $display("FAIL width=%0d bits=%0d input=%0h output=%0h expected=%0h",
                    WIDTH8, BITS8, a8, r8, expected[WIDTH8-1:0]);
                errors = errors + 1;
            end else begin
                $display("PASS width=%0d bits=%0d input=%0h output=%0h expected=%0h",
                    WIDTH8, BITS8, a8, r8, expected[WIDTH8-1:0]);
            end
        end
    endtask

    task check_width12;
        input [WIDTH12-1:0] value;
        begin
            a12 = value;
            #1;
            expected = expected_right_rotate(value, WIDTH12, BITS12);
            if (r12 !== expected[WIDTH12-1:0]) begin
                $display("FAIL width=%0d bits=%0d input=%0h output=%0h expected=%0h",
                    WIDTH12, BITS12, a12, r12, expected[WIDTH12-1:0]);
                errors = errors + 1;
            end else begin
                $display("PASS width=%0d bits=%0d input=%0h output=%0h expected=%0h",
                    WIDTH12, BITS12, a12, r12, expected[WIDTH12-1:0]);
            end
        end
    endtask

endmodule
