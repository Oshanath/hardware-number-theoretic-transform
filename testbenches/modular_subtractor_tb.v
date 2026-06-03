`timescale 1ns/1ps

module modular_subtractor_tb;

    localparam integer WIDTH = 10;
    localparam integer MODULUS = 17;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] d;

    integer expected;
    integer errors;

    modular_subtractor #(
        .width(WIDTH),
        .modulus(MODULUS)
    ) dut (
        .a(a),
        .b(b),
        .d(d)
    );

    initial begin

        errors = 0;

        check_difference(10'd0,    10'd0);
        check_difference(10'd0,    10'd1);
        check_difference(10'd8,    10'd9);
        check_difference(10'd456,  10'd123);
        check_difference(10'd287,  10'd731);
        check_difference(10'd1023, 10'd1023);
        check_difference(10'd5,    10'd11);
        check_difference(10'd42,   10'd99);
        check_difference(10'd256,  10'd17);
        check_difference(10'd999,  10'd123);

        if (errors == 0) begin
            $display("All modular subtractor tests passed.");
        end else begin
            $display("Modular subtractor tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_difference;
        input [WIDTH-1:0] next_a;
        input [WIDTH-1:0] next_b;
        begin
            a = next_a;
            b = next_b;

            #10;

            expected = (next_a % MODULUS) - (next_b % MODULUS);
            if (expected < 0) begin
                expected = expected + MODULUS;
            end

            if (d !== expected[WIDTH-1:0]) begin
                $display("FAIL: modulus=%0d a=%0d b=%0d | got d=%0d | expected d=%0d",
                    MODULUS, next_a, next_b, d, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: modulus=%0d a=%0d b=%0d | got d=%0d | expected d=%0d",
                    MODULUS, next_a, next_b, d, expected);
            end
        end
    endtask

endmodule
