`timescale 1ns/1ps

module full_adder_tb;

    reg a;
    reg b;
    reg cin;

    wire s;
    wire cout;

    reg [1:0] expected;
    integer i;

    full_adder dut (
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin
        $dumpfile("full_adder_tb.vcd");
        $dumpvars(0, full_adder_tb);

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];

            #10;

            expected = a + b + cin;

            if ({cout, s} !== expected) begin
                $display("FAILED: a=%b b=%b cin=%b | got cout=%b s=%b | expected cout=%b s=%b", a, b, cin, cout, s, expected[1], expected[0]);
            end else begin
                $display("PASSED: a=%b b=%b cin=%b | cout=%b s=%b", a, b, cin, cout, s);
            end

        end

        $display("Test finished.");
        $finish;
    end

endmodule