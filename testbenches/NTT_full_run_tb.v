`timescale 1ns/1ps

module NTT_full_run_tb;

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
    integer cycles;
    integer last_stage;

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
                a_default[i] = i + 1;
                $display("  input[%0d]=%0d", i, a_default[i]);
            end

            en_in_default = 1'b1;
            wait_cycle;
            en_in_default = 1'b0;

            wait (dut_default.started && !dut_default.loading);
            last_stage = dut_default.stage_counter;
            cycles = 0;
            while (!en_out_default && cycles < 100) begin
                wait_cycle;
                cycles = cycles + 1;
                if (!en_out_default && dut_default.stage_counter != last_stage) begin
                    print_default_stage(name, last_stage);
                    last_stage = dut_default.stage_counter;
                end
            end
            print_default_stage(name, last_stage);

            $display("TESTCASE %0s output", name);
            $display("  cycles=%0d loading=%0b started=%0b stage_counter=%0d butterfly_counter=%0d en_out=%0b",
                cycles, dut_default.loading, dut_default.started,
                dut_default.stage_counter, dut_default.butterfly_counter, en_out_default);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  input[%0d]=%0d output t[%0d]=%0d output butterfly_results[%0d]=%0d",
                    i, a_default[i], i, t_default[i], i, dut_default.butterfly_results[i]);
            end
        end
    endtask

    task print_default_stage;
        input [8*64-1:0] name;
        input integer completed_stage;
        begin
            $display("TESTCASE %0s stage %0d", name, completed_stage);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  loading=%0b stage_counter=%0d butterfly_counter=%0d output butterfly_results[%0d]=%0d",
                    dut_default.loading, dut_default.stage_counter,
                    dut_default.butterfly_counter, i, dut_default.butterfly_results[i]);
            end
        end
    endtask

    task run_wide_full;
        input [8*64-1:0] name;
        begin
            $display("TESTCASE %0s setup", name);
            for (i = 0; i < 8; i = i + 1) begin
                a_wide[i] = i + 1;
                $display("  input[%0d]=%0d", i, a_wide[i]);
            end

            en_in_wide = 1'b1;
            wait_cycle;
            en_in_wide = 1'b0;

            wait (dut_wide.started && !dut_wide.loading);
            last_stage = dut_wide.stage_counter;
            cycles = 0;
            while (!en_out_wide && cycles < 100) begin
                wait_cycle;
                cycles = cycles + 1;
                if (!en_out_wide && dut_wide.stage_counter != last_stage) begin
                    print_wide_stage(name, last_stage);
                    last_stage = dut_wide.stage_counter;
                end
            end
            print_wide_stage(name, last_stage);

            $display("TESTCASE %0s output", name);
            $display("  cycles=%0d loading=%0b started=%0b stage_counter=%0d butterfly_counter=%0d en_out=%0b",
                cycles, dut_wide.loading, dut_wide.started,
                dut_wide.stage_counter, dut_wide.butterfly_counter, en_out_wide);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  input[%0d]=%0d output t[%0d]=%0d output butterfly_results[%0d]=%0d",
                    i, a_wide[i], i, t_wide[i], i, dut_wide.butterfly_results[i]);
            end
        end
    endtask

    task print_wide_stage;
        input [8*64-1:0] name;
        input integer completed_stage;
        begin
            $display("TESTCASE %0s stage %0d", name, completed_stage);
            for (i = 0; i < 8; i = i + 1) begin
                $display("  loading=%0b stage_counter=%0d butterfly_counter=%0d output butterfly_results[%0d]=%0d",
                    dut_wide.loading, dut_wide.stage_counter,
                    dut_wide.butterfly_counter, i, dut_wide.butterfly_results[i]);
            end
        end
    endtask

endmodule
