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
    integer i;
    integer j;
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
        $dumpfile("n_bit_multiplier_tb.vcd");
        $dumpvars(0, n_bit_multiplier_tb);

        errors = 0;

        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                a3 = i;
                b3 = j;

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
        end

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a4 = i;
                b4 = j;

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
        end

        check_16_bit_product(16'h0000, 16'h0000);
        check_16_bit_product(16'h0001, 16'h0001);
        check_16_bit_product(16'hffff, 16'h0001);
        check_16_bit_product(16'hffff, 16'hffff);
        check_16_bit_product(16'h8000, 16'h0002);
        check_16_bit_product(16'h8000, 16'h8000);
        check_16_bit_product(16'h1234, 16'h5678);
        check_16_bit_product(16'habcd, 16'h0101);
        check_16_bit_product(16'h00ff, 16'h0100);
        check_16_bit_product(16'h0100, 16'h0100);

        for (i = 0; i < 256; i = i + 1) begin
            check_16_bit_product((i * 16'h1021) ^ 16'h5a5a, (i * 16'h00f3) ^ 16'ha5a5);
        end

        if (errors == 0) begin
            $display("All 3-bit, 4-bit, and 16-bit multiplier tests passed.");
        end else begin
            $display("Multiplier tests failed with %0d error(s).", errors);
        end

        $finish;
    end

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
