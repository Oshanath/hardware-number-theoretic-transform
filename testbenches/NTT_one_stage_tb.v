`timescale 1ns/1ps

module NTT_one_stage_tb;

    reg clk;
    reg en_in_default;
    reg en_in_wide;

    reg [7:0][15:0] a_default;
    wire en_out_default;
    wire [7:0][15:0] t_default;

    reg [7:0][19:0] a_wide;
    wire en_out_wide;
    wire [7:0][19:0] t_wide;

    integer i;

    NTT dut_default (
        .clk(clk),
        .en_in(en_in_default),
        .a(a_default),
        .en_out(en_out_default),
        .t(t_default)
    );

    NTT #(
        .width(20),
        .modulus(17),
        .root(9),
        .n(8)
    ) dut_wide (
        .clk(clk),
        .en_in(en_in_wide),
        .a(a_wide),
        .en_out(en_out_wide),
        .t(t_wide)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("NTT_one_stage_tb.vcd");
        $dumpvars(0, NTT_one_stage_tb);

        clk = 1'b0;
        en_in_default = 1'b0;
        en_in_wide = 1'b0;
        a_default = '0;
        a_wide = '0;

        #2;

        run_default_one_stage;
        run_wide_one_stage;

        $finish;
    end

    task wait_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task print_default_state;
        input [8*64-1:0] label_text;
        begin
            $display("TESTCASE %0s", label_text);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  loading=%0b stage_counter=%0d butterfly_counter=%0d input[%0d]=%0d output butterfly_results[%0d]=%0d",
                    dut_default.loading, dut_default.stage_counter, dut_default.butterfly_counter,
                    i, a_default[i], i, dut_default.butterfly_results[i]);
            end
        end
    endtask

    task print_wide_state;
        input [8*64-1:0] label_text;
        begin
            $display("TESTCASE %0s", label_text);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  loading=%0b stage_counter=%0d butterfly_counter=%0d input[%0d]=%0d output butterfly_results[%0d]=%0d",
                    dut_wide.loading, dut_wide.stage_counter, dut_wide.butterfly_counter,
                    i, a_wide[i], i, dut_wide.butterfly_results[i]);
            end
        end
    endtask

    task run_default_one_stage;
        begin
            $display("TESTCASE default parameters one stage setup");
            for (i = 0; i < 8; i = i + 1) begin
                a_default[i] = i + 1;
                $display("  input[%0d]=%0d", i, a_default[i]);
            end

            en_in_default = 1'b1;
            wait_cycle;
            en_in_default = 1'b0;

            wait (dut_default.started && !dut_default.loading);

            while (dut_default.stage_counter == 0) begin
                wait_cycle;
            end

            print_default_state("default parameters after one stage");
        end
    endtask

    task run_wide_one_stage;
        begin
            $display("TESTCASE width=20 one stage setup");
            for (i = 0; i < 8; i = i + 1) begin
                a_wide[i] = i + 1;
                $display("  input[%0d]=%0d", i, a_wide[i]);
            end

            en_in_wide = 1'b1;
            wait_cycle;
            en_in_wide = 1'b0;

            wait (dut_wide.started && !dut_wide.loading);

            while (dut_wide.stage_counter == 0) begin
                wait_cycle;
            end

            print_wide_state("width=20 after one stage");
        end
    endtask

endmodule
