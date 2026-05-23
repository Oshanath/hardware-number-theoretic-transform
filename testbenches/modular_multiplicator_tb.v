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
        $dumpfile("modular_multiplicator_tb.vcd");
        $dumpvars(0, modular_multiplicator_tb);

        errors = 0;

        check_product(10'd0,    10'd0);
        check_product(10'd0,    10'd16);
        check_product(10'd1,    10'd0);
        check_product(10'd1,    10'd16);
        check_product(10'd16,   10'd1);
        check_product(10'd16,   10'd16);
        check_product(10'd8,    10'd8);
        check_product(10'd8,    10'd9);
        check_product(10'd9,    10'd9);
        check_product(10'd17,   10'd16);
        check_product(10'd18,   10'd16);
        check_product(10'd33,   10'd34);
        check_product(10'd34,   10'd34);
        check_product(10'd100,  10'd200);
        check_product(10'd250,  10'd251);
        check_product(10'd288,  10'd288);
        check_product(10'd289,  10'd16);
        check_product(10'd512,  10'd512);
        check_product(10'd1023, 10'd1);
        check_product(10'd1023, 10'd1023);

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
