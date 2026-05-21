`timescale 1ns/1ps

module four_bit_adder_tb;

    reg [3:0] a4;
    reg [3:0] b4;
    wire [3:0] s4;
    wire cout4;

    reg [15:0] a16;
    reg [15:0] b16;
    wire [15:0] s16;
    wire cout16;

    reg [4:0] expected4;
    reg [16:0] expected16;
    integer i;
    integer j;
    integer errors;

    n_bit_adder #(
        .width(4)
    ) dut4 (
        .a(a4),
        .b(b4),
        .s(s4),
        .cout(cout4)
    );

    n_bit_adder #(
        .width(16)
    ) dut16 (
        .a(a16),
        .b(b16),
        .s(s16),
        .cout(cout16)
    );

    initial begin
        $dumpfile("4_bit_adder_tb.vcd");
        $dumpvars(0, four_bit_adder_tb);

        errors = 0;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a4 = i[3:0];
                b4 = j[3:0];

                #10;

                expected4 = a4 + b4;

                if ({cout4, s4} !== expected4) begin
                    $display("FAILED 4-bit: a=%b b=%b | got cout=%b s=%b | expected cout=%b s=%b",
                        a4, b4, cout4, s4, expected4[4], expected4[3:0]);
                    errors = errors + 1;
                end
            end
        end

        for (i = 0; i < 256; i = i + 1) begin
            a16 = (i * 16'h1021) ^ 16'h5a5a;
            b16 = (i * 16'h00f3) ^ 16'ha5a5;

            #10;

            expected16 = a16 + b16;

            if ({cout16, s16} !== expected16) begin
                $display("FAILED 16-bit: a=%h b=%h | got cout=%b s=%h | expected cout=%b s=%h",
                    a16, b16, cout16, s16, expected16[16], expected16[15:0]);
                errors = errors + 1;
            end
        end

        a16 = 16'h0000; b16 = 16'h0000; #10; check_16_bit_sum;
        a16 = 16'hffff; b16 = 16'h0001; #10; check_16_bit_sum;
        a16 = 16'hffff; b16 = 16'hffff; #10; check_16_bit_sum;
        a16 = 16'h8000; b16 = 16'h8000; #10; check_16_bit_sum;
        a16 = 16'h1234; b16 = 16'hedcb; #10; check_16_bit_sum;

        if (errors == 0) begin
            $display("All 4-bit and 16-bit adder tests passed.");
        end else begin
            $display("Adder tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_16_bit_sum;
        begin
            expected16 = a16 + b16;

            if ({cout16, s16} !== expected16) begin
                $display("FAILED 16-bit: a=%h b=%h | got cout=%b s=%h | expected cout=%b s=%h",
                    a16, b16, cout16, s16, expected16[16], expected16[15:0]);
                errors = errors + 1;
            end
        end
    endtask

endmodule
