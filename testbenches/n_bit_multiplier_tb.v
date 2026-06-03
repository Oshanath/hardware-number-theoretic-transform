`timescale 1ns/1ps

module n_bit_multiplier_tb;

    reg [2:0] a3;
    reg [2:0] b3;
    wire [2:0] p3;
    wire overflow3;

    reg [3:0] a4;
    reg [3:0] b4;
    wire [3:0] p4;
    wire overflow4;

    reg [15:0] a16;
    reg [15:0] b16;
    wire [15:0] p16;
    wire overflow16;

    reg [5:0] expected3;
    reg [7:0] expected4;
    reg [31:0] expected16;
    reg expected_overflow3;
    reg expected_overflow4;
    reg expected_overflow16;
    integer errors;

    n_bit_multiplier #(
        .width(3)
    ) dut3 (
        .a(a3),
        .b(b3),
        .p(p3),
        .overflow(overflow3)
    );

    n_bit_multiplier #(
        .width(4)
    ) dut4 (
        .a(a4),
        .b(b4),
        .p(p4),
        .overflow(overflow4)
    );

    n_bit_multiplier #(
        .width(16)
    ) dut16 (
        .a(a16),
        .b(b16),
        .p(p16),
        .overflow(overflow16)
    );

    initial begin

        errors = 0;

        check_3_bit_product(3'd0, 3'd0);
        check_3_bit_product(3'd1, 3'd7);
        check_3_bit_product(3'd3, 3'd3);
        check_3_bit_product(3'd7, 3'd7);

        check_4_bit_product(4'd0, 4'd0);
        check_4_bit_product(4'd1, 4'd15);
        check_4_bit_product(4'd7, 4'd9);
        check_4_bit_product(4'd15, 4'd15);

        check_16_bit_product(16'h0000, 16'h0000);
        check_16_bit_product(16'hffff, 16'h0001);
        check_16_bit_product(16'h1357, 16'h2468);
        check_16_bit_product(16'h1234, 16'h5678);
        check_16_bit_product(16'h8000, 16'h8000);

        if (errors == 0) begin
            $display("All 3-bit, 4-bit, and 16-bit multiplier tests passed.");
        end else begin
            $display("Multiplier tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_3_bit_product;
        input [2:0] next_a;
        input [2:0] next_b;
        begin
            a3 = next_a;
            b3 = next_b;

            #10;

            expected3 = a3 * b3;
            expected_overflow3 = |expected3[5:3];

            if ((p3 !== expected3[2:0]) || (overflow3 !== expected_overflow3)) begin
                $display("FAIL 3-bit: a=%0d b=%0d | got p=%b overflow=%b | expected p=%b overflow=%b",
                    a3, b3, p3, overflow3, expected3[2:0], expected_overflow3);
                errors = errors + 1;
            end else begin
                $display("PASS 3-bit: a=%0d b=%0d | got p=%b overflow=%b | expected p=%b overflow=%b",
                    a3, b3, p3, overflow3, expected3[2:0], expected_overflow3);
            end
        end
    endtask

    task check_4_bit_product;
        input [3:0] next_a;
        input [3:0] next_b;
        begin
            a4 = next_a;
            b4 = next_b;

            #10;

            expected4 = a4 * b4;
            expected_overflow4 = |expected4[7:4];

            if ((p4 !== expected4[3:0]) || (overflow4 !== expected_overflow4)) begin
                $display("FAIL 4-bit: a=%0d b=%0d | got p=%b overflow=%b | expected p=%b overflow=%b",
                    a4, b4, p4, overflow4, expected4[3:0], expected_overflow4);
                errors = errors + 1;
            end else begin
                $display("PASS 4-bit: a=%0d b=%0d | got p=%b overflow=%b | expected p=%b overflow=%b",
                    a4, b4, p4, overflow4, expected4[3:0], expected_overflow4);
            end
        end
    endtask

    task check_16_bit_product;
        input [15:0] next_a;
        input [15:0] next_b;
        begin
            a16 = next_a;
            b16 = next_b;

            #10;

            expected16 = {16'b0, a16} * {16'b0, b16};
            expected_overflow16 = |expected16[31:16];

            if ((p16 !== expected16[15:0]) || (overflow16 !== expected_overflow16)) begin
                $display("FAIL 16-bit: a=%h b=%h | got p=%h overflow=%b | expected p=%h overflow=%b",
                    a16, b16, p16, overflow16, expected16[15:0], expected_overflow16);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit: a=%h b=%h | got p=%h overflow=%b | expected p=%h overflow=%b",
                    a16, b16, p16, overflow16, expected16[15:0], expected_overflow16);
            end
        end
    endtask

endmodule
