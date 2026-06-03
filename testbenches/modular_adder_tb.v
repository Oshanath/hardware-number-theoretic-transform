`timescale 1ns/1ps

module modular_adder_tb;

    localparam integer WIDTH = 10;
    localparam integer MODULUS = 17;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] s;

    integer expected;
    integer errors;

    modular_adder #(
        .width(WIDTH),
        .modulus(MODULUS)
    ) dut (
        .a(a),
        .b(b),
        .s(s)
    );

    initial begin

        errors = 0;

        check_sum(10'd0,    10'd0);
        check_sum(10'd16,   10'd1);
        check_sum(10'd8,    10'd8);
        check_sum(10'd123,  10'd456);
        check_sum(10'd731,  10'd287);
        check_sum(10'd1023, 10'd1023);
        check_sum(10'd5,    10'd11);
        check_sum(10'd42,   10'd99);
        check_sum(10'd256,  10'd17);
        check_sum(10'd999,  10'd123);

        if (errors == 0) begin
            $display("All modular adder tests passed.");
        end else begin
            $display("Modular adder tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_sum;
        input [WIDTH-1:0] next_a;
        input [WIDTH-1:0] next_b;
        begin
            a = next_a;
            b = next_b;

            #10;

            expected = ((next_a % MODULUS) + (next_b % MODULUS)) % MODULUS;

            if (s !== expected[WIDTH-1:0]) begin
                $display("FAIL: modulus=%0d a=%0d b=%0d | got s=%0d | expected s=%0d",
                    MODULUS, next_a, next_b, s, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: modulus=%0d a=%0d b=%0d | got s=%0d | expected s=%0d",
                    MODULUS, next_a, next_b, s, expected);
            end
        end
    endtask

endmodule
