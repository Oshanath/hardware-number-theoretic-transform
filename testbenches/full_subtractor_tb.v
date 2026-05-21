`timescale 1ns/1ps

module full_subtractor_tb;

    reg a;
    reg b;
    reg bal_in;

    wire d;
    wire bal_out;

    reg expected_d;
    reg expected_bal_out;
    integer i;
    integer errors;

    full_subtractor dut (
        .a(a),
        .b(b),
        .bal_in(bal_in),
        .d(d),
        .bal_out(bal_out)
    );

    initial begin
        $dumpfile("full_subtractor_tb.vcd");
        $dumpvars(0, full_subtractor_tb);

        errors = 0;

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, bal_in} = i[2:0];

            #10;

            expected_d = a ^ b ^ bal_in;
            expected_bal_out = (~a & b) | (~a & bal_in) | (b & bal_in);

            if ({bal_out, d} !== {expected_bal_out, expected_d}) begin
                $display("FAILED: a=%b b=%b bal_in=%b | got bal_out=%b d=%b | expected bal_out=%b d=%b",
                    a, b, bal_in, bal_out, d, expected_bal_out, expected_d);
                errors = errors + 1;
            end else begin
                $display("PASSED: a=%b b=%b bal_in=%b | bal_out=%b d=%b",
                    a, b, bal_in, bal_out, d);
            end
        end

        if (errors == 0) begin
            $display("All full subtractor tests passed.");
        end else begin
            $display("Full subtractor tests failed with %0d error(s).", errors);
        end

        $finish;
    end

endmodule
