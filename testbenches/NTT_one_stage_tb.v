`timescale 1ns/1ps

module NTT_one_stage_tb;

    reg clk;
    reg en_in_default;
    reg en_in_wide;
    reg inverse_default;
    reg inverse_wide;

    reg [15:0] a_default;
    reg [15:0] a_default_values [0:7];
    reg [15:0] expected_default_values [0:7];
    wire en_out_default;
    wire [15:0] t_default;

    reg [19:0] a_wide;
    reg [19:0] a_wide_values [0:7];
    reg [19:0] expected_wide_values [0:7];
    wire en_out_wide;
    wire [19:0] t_wide;

    integer i;
    integer errors;

    localparam integer DEFAULT_MODULUS = 17;
    localparam integer WIDE_MODULUS = 17;
    localparam [2:0] STATE_IDLE = 3'd0;
    localparam [2:0] STATE_PROCESS = 3'd2;

    NTT dut_default (
        .clk(clk),
        .en_in(en_in_default),
        .inverse_(inverse_default),
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
        .inverse_(inverse_wide),
        .a(a_wide),
        .en_out(en_out_wide),
        .t(t_wide)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        en_in_default = 1'b0;
        en_in_wide = 1'b0;
        inverse_default = 1'b0;
        inverse_wide = 1'b0;
        a_default = '0;
        a_wide = '0;
        errors = 0;

        #2;

        run_default_one_stage("default regular ascending", 16'd1, 16'd2, 16'd3, 16'd4, 16'd5, 16'd6, 16'd7, 16'd8);
        run_default_one_stage("default regular sparse", 16'd3, 16'd0, 16'd14, 16'd5, 16'd9, 16'd2, 16'd11, 16'd7);
        run_default_one_stage("default regular alternating", 16'd5, 16'd12, 16'd7, 16'd10, 16'd9, 16'd4, 16'd13, 16'd6);
        run_default_one_stage("default edge all zero", 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0);
        run_default_one_stage("default edge modulus boundary", 16'd16, 16'd0, 16'd16, 16'd1, 16'd15, 16'd2, 16'd14, 16'd3);

        run_wide_one_stage("width=20 regular ascending", 20'd1, 20'd2, 20'd3, 20'd4, 20'd5, 20'd6, 20'd7, 20'd8);
        run_wide_one_stage("width=20 regular sparse", 20'd4, 20'd12, 20'd1, 20'd15, 20'd6, 20'd10, 20'd3, 20'd8);
        run_wide_one_stage("width=20 regular alternating", 20'd6, 20'd13, 20'd4, 20'd9, 20'd10, 20'd7, 20'd12, 20'd5);
        run_wide_one_stage("width=20 edge all zero", 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0);
        run_wide_one_stage("width=20 edge modulus boundary", 20'd16, 20'd16, 20'd0, 20'd1, 20'd2, 20'd15, 20'd14, 20'd3);

        if (errors == 0) begin
            $display("All NTT one stage tests passed.");
        end else begin
            $display("NTT one stage tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task wait_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    function integer bit_reverse_index;
        input integer value;
        input integer bits;
        integer j;
        begin
            bit_reverse_index = 0;
            for (j = 0; j < bits; j = j + 1) begin
                bit_reverse_index = (bit_reverse_index << 1) | ((value >> j) & 1);
            end
        end
    endfunction

    task compute_default_one_stage_expected;
        reg [15:0] ram_values [0:7];
        integer pair_base;
        begin
            for (i = 0; i < 8; i = i + 1) begin
                ram_values[bit_reverse_index(i, 3)] = a_default_values[i] % DEFAULT_MODULUS;
            end

            for (pair_base = 0; pair_base < 8; pair_base = pair_base + 2) begin
                expected_default_values[pair_base] = (ram_values[pair_base] + ram_values[pair_base + 1]) % DEFAULT_MODULUS;
                expected_default_values[pair_base + 1] = (ram_values[pair_base] + DEFAULT_MODULUS - ram_values[pair_base + 1]) % DEFAULT_MODULUS;
            end
        end
    endtask

    task compute_wide_one_stage_expected;
        reg [19:0] ram_values [0:7];
        integer pair_base;
        begin
            for (i = 0; i < 8; i = i + 1) begin
                ram_values[bit_reverse_index(i, 3)] = a_wide_values[i] % WIDE_MODULUS;
            end

            for (pair_base = 0; pair_base < 8; pair_base = pair_base + 2) begin
                expected_wide_values[pair_base] = (ram_values[pair_base] + ram_values[pair_base + 1]) % WIDE_MODULUS;
                expected_wide_values[pair_base + 1] = (ram_values[pair_base] + WIDE_MODULUS - ram_values[pair_base + 1]) % WIDE_MODULUS;
            end
        end
    endtask

    task run_default_one_stage;
        input [8*64-1:0] name;
        input [15:0] a0;
        input [15:0] a1;
        input [15:0] a2;
        input [15:0] a3;
        input [15:0] a4;
        input [15:0] a5;
        input [15:0] a6;
        input [15:0] a7;
        integer failed;
        begin
            while (dut_default.state != STATE_IDLE) begin
                wait_cycle;
            end

            a_default_values[0] = a0;
            a_default_values[1] = a1;
            a_default_values[2] = a2;
            a_default_values[3] = a3;
            a_default_values[4] = a4;
            a_default_values[5] = a5;
            a_default_values[6] = a6;
            a_default_values[7] = a7;
            compute_default_one_stage_expected;

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

            failed = 0;
            for (i = 0; i < 8; i = i + 1) begin
                if (dut_default.butterfly_results[i] !== expected_default_values[i]) begin
                    errors = errors + 1;
                    failed = 1;
                end
            end

            $display("%s %0s input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) got=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                failed ? "FAIL" : "PASS", name,
                a_default_values[0], a_default_values[1], a_default_values[2], a_default_values[3],
                a_default_values[4], a_default_values[5], a_default_values[6], a_default_values[7],
                dut_default.butterfly_results[0], dut_default.butterfly_results[1],
                dut_default.butterfly_results[2], dut_default.butterfly_results[3],
                dut_default.butterfly_results[4], dut_default.butterfly_results[5],
                dut_default.butterfly_results[6], dut_default.butterfly_results[7],
                expected_default_values[0], expected_default_values[1], expected_default_values[2], expected_default_values[3],
                expected_default_values[4], expected_default_values[5], expected_default_values[6], expected_default_values[7]);

            wait_cycle;
        end
    endtask

    task run_wide_one_stage;
        input [8*64-1:0] name;
        input [19:0] a0;
        input [19:0] a1;
        input [19:0] a2;
        input [19:0] a3;
        input [19:0] a4;
        input [19:0] a5;
        input [19:0] a6;
        input [19:0] a7;
        integer failed;
        begin
            while (dut_wide.state != STATE_IDLE) begin
                wait_cycle;
            end

            a_wide_values[0] = a0;
            a_wide_values[1] = a1;
            a_wide_values[2] = a2;
            a_wide_values[3] = a3;
            a_wide_values[4] = a4;
            a_wide_values[5] = a5;
            a_wide_values[6] = a6;
            a_wide_values[7] = a7;
            compute_wide_one_stage_expected;

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

            failed = 0;
            for (i = 0; i < 8; i = i + 1) begin
                if (dut_wide.butterfly_results[i] !== expected_wide_values[i]) begin
                    errors = errors + 1;
                    failed = 1;
                end
            end

            $display("%s %0s input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) got=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                failed ? "FAIL" : "PASS", name,
                a_wide_values[0], a_wide_values[1], a_wide_values[2], a_wide_values[3],
                a_wide_values[4], a_wide_values[5], a_wide_values[6], a_wide_values[7],
                dut_wide.butterfly_results[0], dut_wide.butterfly_results[1],
                dut_wide.butterfly_results[2], dut_wide.butterfly_results[3],
                dut_wide.butterfly_results[4], dut_wide.butterfly_results[5],
                dut_wide.butterfly_results[6], dut_wide.butterfly_results[7],
                expected_wide_values[0], expected_wide_values[1], expected_wide_values[2], expected_wide_values[3],
                expected_wide_values[4], expected_wide_values[5], expected_wide_values[6], expected_wide_values[7]);

            wait_cycle;
        end
    endtask

endmodule
