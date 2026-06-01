`timescale 1ns/1ps

module NTT_one_stage_tb;

    reg clk;
    reg en_in_default;
    reg en_in_wide;

    reg [15:0] a_default;
    reg [7:0][15:0] a_default_values;
    wire en_out_default;
    wire [15:0] t_default;

    reg [19:0] a_wide;
    reg [7:0][19:0] a_wide_values;
    wire en_out_wide;
    wire [19:0] t_wide;

    integer i;

    localparam [2:0] STATE_PROCESS = 3'd2;

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
        a_default_values = '0;
        a_wide_values = '0;

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
                $display("  state=%0d stage_counter=%0d butterfly_counter=%0d input[%0d]=%0d output butterfly_results[%0d]=%0d",
                    dut_default.state, dut_default.stage_counter, dut_default.butterfly_counter,
                    i, a_default_values[i], i, dut_default.butterfly_results[i]);
            end
        end
    endtask

    task print_wide_state;
        input [8*64-1:0] label_text;
        begin
            $display("TESTCASE %0s", label_text);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  state=%0d stage_counter=%0d butterfly_counter=%0d input[%0d]=%0d output butterfly_results[%0d]=%0d",
                    dut_wide.state, dut_wide.stage_counter, dut_wide.butterfly_counter,
                    i, a_wide_values[i], i, dut_wide.butterfly_results[i]);
            end
        end
    endtask

    task run_default_one_stage;
        begin
            $display("TESTCASE default parameters one stage setup");
            for (i = 0; i < 8; i = i + 1) begin
                a_default_values[i] = i + 1;
                $display("  input[%0d]=%0d", i, a_default_values[i]);
            end

            for (i = 0; i < 8; i = i + 1) begin
                a_default = a_default_values[i];
                en_in_default = 1'b1;
                wait_cycle;
            end
            en_in_default = 1'b0;

            wait (dut_default.state == STATE_PROCESS);

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
                a_wide_values[i] = i + 1;
                $display("  input[%0d]=%0d", i, a_wide_values[i]);
            end

            for (i = 0; i < 8; i = i + 1) begin
                a_wide = a_wide_values[i];
                en_in_wide = 1'b1;
                wait_cycle;
            end
            en_in_wide = 1'b0;

            wait (dut_wide.state == STATE_PROCESS);

            while (dut_wide.stage_counter == 0) begin
                wait_cycle;
            end

            print_wide_state("width=20 after one stage");
        end
    endtask

endmodule
