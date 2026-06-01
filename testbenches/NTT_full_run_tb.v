`timescale 1ns/1ps

module NTT_full_run_tb;

    reg clk;
    reg en_in_default;
    reg en_in_wide;

    reg [15:0] a_default;
    reg [7:0][15:0] a_default_values;
    reg [7:0][15:0] t_default_values;
    wire en_out_default;
    wire [15:0] t_default;

    reg [19:0] a_wide;
    reg [7:0][19:0] a_wide_values;
    reg [7:0][19:0] t_wide_values;
    wire en_out_wide;
    wire [19:0] t_wide;

    integer i;
    integer cycles;
    integer last_stage;
    integer output_count;

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
        $dumpfile("NTT_full_run_tb.vcd");
        $dumpvars(0, NTT_full_run_tb);

        clk = 1'b0;
        en_in_default = 1'b0;
        en_in_wide = 1'b0;
        a_default = '0;
        a_wide = '0;
        a_default_values = '0;
        a_wide_values = '0;
        t_default_values = '0;
        t_wide_values = '0;

        #2;

        run_default_full("default parameters full run");
        run_wide_full("width=20 full run");

        $finish;
    end

    task wait_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task run_default_full;
        input [8*64-1:0] name;
        begin
            $display("TESTCASE %0s setup", name);
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
            last_stage = dut_default.stage_counter;
            cycles = 0;
            output_count = 0;
            while (output_count < 8 && cycles < 150) begin
                wait_cycle;
                cycles = cycles + 1;
                if (en_out_default) begin
                    t_default_values[output_count] = t_default;
                    output_count = output_count + 1;
                end
                if (output_count == 0 && dut_default.stage_counter != last_stage) begin
                    print_default_stage(name, last_stage);
                    last_stage = dut_default.stage_counter;
                end
            end
            print_default_stage(name, last_stage);

            $display("TESTCASE %0s output", name);
            $display("  cycles=%0d state=%0d stage_counter=%0d butterfly_counter=%0d en_out=%0b",
                cycles, dut_default.state,
                dut_default.stage_counter, dut_default.butterfly_counter, en_out_default);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  input[%0d]=%0d output t[%0d]=%0d output butterfly_results[%0d]=%0d",
                    i, a_default_values[i], i, t_default_values[i], i, dut_default.butterfly_results[i]);
            end
        end
    endtask

    task print_default_stage;
        input [8*64-1:0] name;
        input integer completed_stage;
        begin
            $display("TESTCASE %0s stage %0d", name, completed_stage);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  state=%0d stage_counter=%0d butterfly_counter=%0d output butterfly_results[%0d]=%0d",
                    dut_default.state, dut_default.stage_counter,
                    dut_default.butterfly_counter, i, dut_default.butterfly_results[i]);
            end
        end
    endtask

    task run_wide_full;
        input [8*64-1:0] name;
        begin
            $display("TESTCASE %0s setup", name);
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
            last_stage = dut_wide.stage_counter;
            cycles = 0;
            output_count = 0;
            while (output_count < 8 && cycles < 150) begin
                wait_cycle;
                cycles = cycles + 1;
                if (en_out_wide) begin
                    t_wide_values[output_count] = t_wide;
                    output_count = output_count + 1;
                end
                if (output_count == 0 && dut_wide.stage_counter != last_stage) begin
                    print_wide_stage(name, last_stage);
                    last_stage = dut_wide.stage_counter;
                end
            end
            print_wide_stage(name, last_stage);

            $display("TESTCASE %0s output", name);
            $display("  cycles=%0d state=%0d stage_counter=%0d butterfly_counter=%0d en_out=%0b",
                cycles, dut_wide.state,
                dut_wide.stage_counter, dut_wide.butterfly_counter, en_out_wide);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  input[%0d]=%0d output t[%0d]=%0d output butterfly_results[%0d]=%0d",
                    i, a_wide_values[i], i, t_wide_values[i], i, dut_wide.butterfly_results[i]);
            end
        end
    endtask

    task print_wide_stage;
        input [8*64-1:0] name;
        input integer completed_stage;
        begin
            $display("TESTCASE %0s stage %0d", name, completed_stage);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  state=%0d stage_counter=%0d butterfly_counter=%0d output butterfly_results[%0d]=%0d",
                    dut_wide.state, dut_wide.stage_counter,
                    dut_wide.butterfly_counter, i, dut_wide.butterfly_results[i]);
            end
        end
    endtask

endmodule
