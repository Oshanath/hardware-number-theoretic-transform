`timescale 1ns/1ps

module modular_reducer_tb;

    localparam integer MODULUS10 = 17;
    localparam integer MODULUS16 = 251;
    localparam integer MAX_X10 = MODULUS10 * MODULUS10;
    localparam integer MAX_X16 = MODULUS16 * MODULUS16;

    reg [9:0] x10;
    wire [9:0] xmodn10;

    reg [15:0] x16;
    wire [15:0] xmodn16;

    integer expected10;
    integer expected16;
    integer errors;

    modular_reducer #(
        .width(10),
        .modulus(10'd17)
    ) dut10 (
        .x(x10),
        .xmodn(xmodn10)
    );

    modular_reducer #(
        .width(16),
        .modulus(16'd251)
    ) dut16 (
        .x(x16),
        .xmodn(xmodn16)
    );

    initial begin

        errors = 0;

        check_10_bit_reduction(0);
        check_10_bit_reduction(MODULUS10 - 1);
        check_10_bit_reduction(MODULUS10);
        check_10_bit_reduction(10'd73);
        check_10_bit_reduction(10'd218);
        check_10_bit_reduction(MAX_X10);

        check_16_bit_reduction(0);
        check_16_bit_reduction(MODULUS16 - 1);
        check_16_bit_reduction(MODULUS16);
        check_16_bit_reduction(16'd12345);
        check_16_bit_reduction(16'd54321);
        check_16_bit_reduction(MAX_X16);

        if (errors == 0) begin
            $display("All 10-bit and 16-bit modular reducer tests passed.");
        end else begin
            $display("Modular reducer tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_10_bit_reduction;
        input integer next_x;
        begin
            x10 = next_x[9:0];

            #10;

            expected10 = next_x % MODULUS10;

            if (xmodn10 !== expected10[9:0]) begin
                $display("FAIL 10-bit: modulus=%0d x=%0d | got xmodn=%0d | expected xmodn=%0d",
                    MODULUS10, next_x, xmodn10, expected10);
                errors = errors + 1;
            end else begin
                $display("PASS 10-bit: modulus=%0d x=%0d | got xmodn=%0d | expected xmodn=%0d",
                    MODULUS10, next_x, xmodn10, expected10);
            end
        end
    endtask

    task check_16_bit_reduction;
        input integer next_x;
        begin
            x16 = next_x[15:0];

            #10;

            expected16 = next_x % MODULUS16;

            if (xmodn16 !== expected16[15:0]) begin
                $display("FAIL 16-bit: modulus=%0d x=%0d | got xmodn=%0d | expected xmodn=%0d",
                    MODULUS16, next_x, xmodn16, expected16);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit: modulus=%0d x=%0d | got xmodn=%0d | expected xmodn=%0d",
                    MODULUS16, next_x, xmodn16, expected16);
            end
        end
    endtask

endmodule
