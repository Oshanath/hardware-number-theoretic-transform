`timescale 1ns/1ps

module modular_multiplicator_tb;

    localparam integer WIDTH = 10;
    localparam integer MODULUS = 17;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] p;

    integer expected;
    integer errors;

    modular_multiplicator #(
        .width(WIDTH),
        .modulus(MODULUS)
    ) dut (
        .a(a),
        .b(b),
        .p(p)
    );

    initial begin

        errors = 0;

        check_product(10'd0,    10'd0);
        check_product(10'd1,    10'd16);
        check_product(10'd16,   10'd16);
        check_product(10'd123,  10'd456);
        check_product(10'd731,  10'd287);
        check_product(10'd1023, 10'd1023);
        check_product(10'd5,    10'd11);
        check_product(10'd42,   10'd99);
        check_product(10'd256,  10'd17);
        check_product(10'd999,  10'd123);

        if (errors == 0) begin
            $display("All modular multiplicator tests passed.");
        end else begin
            $display("Modular multiplicator tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_product;
        input [WIDTH-1:0] next_a;
        input [WIDTH-1:0] next_b;
        begin
            a = next_a;
            b = next_b;

            #10;

            expected = ((next_a % MODULUS) * (next_b % MODULUS)) % MODULUS;

            if (p !== expected[WIDTH-1:0]) begin
                $display("FAIL: modulus=%0d a=%0d b=%0d | got p=%0d | expected p=%0d",
                    MODULUS, next_a, next_b, p, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: modulus=%0d a=%0d b=%0d | got p=%0d | expected p=%0d",
                    MODULUS, next_a, next_b, p, expected);
            end
        end
    endtask

endmodule
