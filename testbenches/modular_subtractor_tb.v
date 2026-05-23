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
        $dumpfile("modular_subtractor_tb.vcd");
        $dumpvars(0, modular_subtractor_tb);

        errors = 0;

        check_difference(10'd0,    10'd0);
        check_difference(10'd0,    10'd1);
        check_difference(10'd1,    10'd0);
        check_difference(10'd16,   10'd0);
        check_difference(10'd0,    10'd16);
        check_difference(10'd16,   10'd1);
        check_difference(10'd1,    10'd16);
        check_difference(10'd8,    10'd8);
        check_difference(10'd8,    10'd9);
        check_difference(10'd9,    10'd8);
        check_difference(10'd17,   10'd0);
        check_difference(10'd18,   10'd16);
        check_difference(10'd33,   10'd34);
        check_difference(10'd34,   10'd33);
        check_difference(10'd100,  10'd200);
        check_difference(10'd250,  10'd251);
        check_difference(10'd288,  10'd288);
        check_difference(10'd289,  10'd0);
        check_difference(10'd512,  10'd512);
        check_difference(10'd1023, 10'd1023);

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
