`timescale 1ns/1ps

module n_bit_subtractor_tb;

    reg [3:0] a4;
    reg [3:0] b4;
    wire [3:0] d4;
    wire bal4;

    reg [15:0] a16;
    reg [15:0] b16;
    wire [15:0] d16;
    wire bal16;

    reg [4:0] expected4;
    reg [16:0] expected16;
    integer errors;

    n_bit_subtractor #(
        .width(4)
    ) dut4 (
        .a(a4),
        .b(b4),
        .d(d4),
        .bal(bal4)
    );

    n_bit_subtractor #(
        .width(16)
    ) dut16 (
        .a(a16),
        .b(b16),
        .d(d16),
        .bal(bal16)
    );

    initial begin

        errors = 0;

        run_4_bit_case(4'h0, 4'h0);
        run_4_bit_case(4'h1, 4'h0);
        run_4_bit_case(4'h0, 4'h1);
        run_4_bit_case(4'hf, 4'h7);

        run_16_bit_case(16'h0000, 16'h0000);
        run_16_bit_case(16'h0000, 16'h0001);
        run_16_bit_case(16'h1234, 16'h00ff);
        run_16_bit_case(16'h9abc, 16'h1357);
        run_16_bit_case(16'h1234, 16'h5678);
        run_16_bit_case(16'ha5a5, 16'h5a5a);

        if (errors == 0) begin
            $display("All n-bit subtractor tests passed.");
        end else begin
            $display("n-bit subtractor tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task run_4_bit_case;
        input [3:0] next_a;
        input [3:0] next_b;
        begin
            a4 = next_a;
            b4 = next_b;

            #10;

            expected4 = a4 - b4;
            print_4_bit_result;
        end
    endtask

    task print_4_bit_result;
        begin
            if ({bal4, d4} !== expected4) begin
                $display("FAILED 4-bit: a=%0d b=%0d | got bal=%0d d=%0d | expected bal=%0d d=%0d",
                    a4, b4, bal4, d4, expected4[4], expected4[3:0]);
                errors = errors + 1;
            end else begin
                $display("PASSED 4-bit: a=%0d b=%0d | bal=%0d d=%0d",
                    a4, b4, bal4, d4);
            end
        end
    endtask

    task run_16_bit_case;
        input [15:0] test_a;
        input [15:0] test_b;
        begin
            a16 = test_a;
            b16 = test_b;

            #10;

            expected16 = a16 - b16;

            if ({bal16, d16} !== expected16) begin
                $display("FAILED 16-bit: a=%0d b=%0d | got bal=%0d d=%0d | expected bal=%0d d=%0d",
                    a16, b16, bal16, d16, expected16[16], expected16[15:0]);
                errors = errors + 1;
            end else begin
                $display("PASSED 16-bit: a=%0d b=%0d | bal=%0d d=%0d",
                    a16, b16, bal16, d16);
            end
        end
    endtask

endmodule
