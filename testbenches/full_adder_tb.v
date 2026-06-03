`timescale 1ns/1ps

module full_adder_tb;

    reg a;
    reg b;
    reg cin;

    wire s;
    wire cout;

    reg [1:0] expected;
    integer errors;

    full_adder dut (
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin

        errors = 0;

        run_case(1'b0, 1'b0, 1'b0);
        run_case(1'b0, 1'b0, 1'b1);
        run_case(1'b0, 1'b1, 1'b0);
        run_case(1'b0, 1'b1, 1'b1);
        run_case(1'b1, 1'b0, 1'b0);
        run_case(1'b1, 1'b0, 1'b1);
        run_case(1'b1, 1'b1, 1'b0);
        run_case(1'b1, 1'b1, 1'b1);
        run_case(1'b0, 1'b1, 1'b1);
        run_case(1'b1, 1'b1, 1'b1);

        if (errors == 0) begin
            $display("All full adder tests passed.");
        end else begin
            $display("Full adder tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task run_case;
        input next_a;
        input next_b;
        input next_cin;
        begin
            a = next_a;
            b = next_b;
            cin = next_cin;

            #10;

            expected = a + b + cin;

            if ({cout, s} !== expected) begin
                $display("FAILED: a=%b b=%b cin=%b | got cout=%b s=%b | expected cout=%b s=%b", a, b, cin, cout, s, expected[1], expected[0]);
                errors = errors + 1;
            end else begin
                $display("PASSED: a=%b b=%b cin=%b | cout=%b s=%b", a, b, cin, cout, s);
            end
        end
    endtask

endmodule
