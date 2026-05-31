`timescale 1ns/1ps

module bit_reverser_tb;

    reg [2:0] a3;
    wire [2:0] r3;

    reg [7:0] a8;
    wire [7:0] r8;

    reg [2:0] expected3;
    reg [7:0] expected8;
    integer i;
    integer errors;

    bit_reverser #(
        .width(3)
    ) dut3 (
        .a(a3),
        .r(r3)
    );

    bit_reverser #(
        .width(8)
    ) dut8 (
        .a(a8),
        .r(r8)
    );

    initial begin
        $dumpfile("bit_reverser_tb.vcd");
        $dumpvars(0, bit_reverser_tb);

        errors = 0;

        for (i = 0; i < 8; i = i + 1) begin
            a3 = i[2:0];
            #10;

            expected3 = reverse3(a3);

            if (r3 !== expected3) begin
                $display("FAILED 3-bit: a=%b | got r=%b | expected r=%b", a3, r3, expected3);
                errors = errors + 1;
            end else begin
                $display("PASSED 3-bit: a=%b | r=%b | expected r=%b", a3, r3, expected3);
            end
        end

        for (i = 0; i < 256; i = i + 1) begin
            a8 = i[7:0];
            #10;

            expected8 = reverse8(a8);

            if (r8 !== expected8) begin
                $display("FAILED 8-bit: a=%b | got r=%b | expected r=%b", a8, r8, expected8);
                errors = errors + 1;
            end else begin
                $display("PASSED 8-bit: a=%b | r=%b | expected r=%b", a8, r8, expected8);
            end
        end

        if (errors == 0) begin
            $display("All bit_reverser tests passed.");
        end else begin
            $display("bit_reverser tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    function [2:0] reverse3;
        input [2:0] value;
        begin
            reverse3 = {value[0], value[1], value[2]};
        end
    endfunction

    function [7:0] reverse8;
        input [7:0] value;
        begin
            reverse8 = {value[0], value[1], value[2], value[3], value[4], value[5], value[6], value[7]};
        end
    endfunction

endmodule
