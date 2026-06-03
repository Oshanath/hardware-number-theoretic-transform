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

        errors = 0;

        run_4_bit_case(4'h0, 4'h0);
        run_4_bit_case(4'h1, 4'h2);
        run_4_bit_case(4'hf, 4'h1);
        run_4_bit_case(4'hf, 4'hf);

        run_16_bit_case(16'h0000, 16'h0000);
        run_16_bit_case(16'hffff, 16'h0001);
        run_16_bit_case(16'h8000, 16'h8000);
        run_16_bit_case(16'h1357, 16'h2468);
        run_16_bit_case(16'h1234, 16'hedcb);
        run_16_bit_case(16'ha5a5, 16'h5a5a);

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
            end else begin
                $display("PASSED 16-bit: a=%h b=%h | got cout=%b s=%h | expected cout=%b s=%h",
                    a16, b16, cout16, s16, expected16[16], expected16[15:0]);
            end
        end
    endtask

    task run_4_bit_case;
        input [3:0] next_a;
        input [3:0] next_b;
        begin
            a4 = next_a;
            b4 = next_b;

            #10;

            expected4 = a4 + b4;

            if ({cout4, s4} !== expected4) begin
                $display("FAILED 4-bit: a=%b b=%b | got cout=%b s=%b | expected cout=%b s=%b",
                    a4, b4, cout4, s4, expected4[4], expected4[3:0]);
                errors = errors + 1;
            end else begin
                $display("PASSED 4-bit: a=%b b=%b | got cout=%b s=%b | expected cout=%b s=%b",
                    a4, b4, cout4, s4, expected4[4], expected4[3:0]);
            end
        end
    endtask

    task run_16_bit_case;
        input [15:0] next_a;
        input [15:0] next_b;
        begin
            a16 = next_a;
            b16 = next_b;
            #10;
            check_16_bit_sum;
        end
    endtask

endmodule
