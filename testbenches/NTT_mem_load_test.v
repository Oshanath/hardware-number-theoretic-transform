`timescale 1ns/1ps

module NTT_mem_load_test;

    localparam integer WIDTH8 = 10;
    localparam integer N8 = 8;
    localparam integer STAGES8 = $clog2(N8);

    localparam integer WIDTH16 = 12;
    localparam integer N16 = 16;
    localparam integer STAGES16 = $clog2(N16);

    reg clk;
    reg en_in8;
    reg en_in16;
    reg [N8-1:0][WIDTH8-1:0] a8;
    reg [N16-1:0][WIDTH16-1:0] a16;

    wire en_out8;
    wire en_out16;
    wire [N8-1:0][WIDTH8-1:0] t8;
    wire [N16-1:0][WIDTH16-1:0] t16;

    integer errors;
    integer i;

    NTT #(
        .width(WIDTH8),
        .modulus(17),
        .root(9),
        .n(N8)
    ) dut8 (
        .clk(clk),
        .en_in(en_in8),
        .a(a8),
        .en_out(en_out8),
        .t(t8)
    );

    NTT #(
        .width(WIDTH16),
        .modulus(97),
        .root(5),
        .n(N16)
    ) dut16 (
        .clk(clk),
        .en_in(en_in16),
        .a(a16),
        .en_out(en_out16),
        .t(t16)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("NTT_mem_load_test.vcd");
        $dumpvars(0, NTT_mem_load_test);

        clk = 0;
        en_in8 = 0;
        en_in16 = 0;
        errors = 0;

        for (i = 0; i < N8; i = i + 1) begin
            a8[i] = 10'd100 + i[WIDTH8-1:0];
        end

        for (i = 0; i < N16; i = i + 1) begin
            a16[i] = 12'd200 + i[WIDTH16-1:0];
        end

        #2;

        run_load8("n=8 width=10 memory load", (N8 / 2) + 2);
        run_load16("n=16 width=12 memory load", (N16 / 2) + 2);

        if (errors == 0) begin
            $display("All NTT memory load tests passed.");
        end else begin
            $display("NTT memory load tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task wait_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    function integer expected_bit_reverse;
        input integer x;
        input integer bit_count;
        integer j;
        begin
            expected_bit_reverse = 0;
            for (j = 0; j < bit_count; j = j + 1) begin
                expected_bit_reverse = (expected_bit_reverse << 1) | ((x >> j) & 1);
            end
        end
    endfunction

    task run_load8;
        input [8*40-1:0] name;
        input integer cycles_to_wait;
        integer expected_addr;
        begin
            $display("TEST %0s", name);
            for (i = 0; i < N8; i = i + 1) begin
                $display("  input[%0d]=%0d", i, a8[i]);
            end

            en_in8 = 1'b1;
            wait_cycle;
            en_in8 = 1'b0;

            repeat (cycles_to_wait) begin
                wait_cycle;
            end

            for (i = 0; i < N8; i = i + 1) begin
                expected_addr = expected_bit_reverse(i, STAGES8);
                if (dut8.ram.mem[expected_addr] !== a8[i]) begin
                    $display("FAIL n=8 input_index=%0d bit_reverse_addr=%0d got=%0d expected=%0d",
                        i, expected_addr, dut8.ram.mem[expected_addr], a8[i]);
                    errors = errors + 1;
                end else begin
                    $display("PASS n=8 input_index=%0d bit_reverse_addr=%0d got=%0d expected=%0d",
                        i, expected_addr, dut8.ram.mem[expected_addr], a8[i]);
                end
            end
        end
    endtask

    task run_load16;
        input [8*40-1:0] name;
        input integer cycles_to_wait;
        integer expected_addr;
        begin
            $display("TEST %0s", name);
            for (i = 0; i < N16; i = i + 1) begin
                $display("  input[%0d]=%0d", i, a16[i]);
            end

            en_in16 = 1'b1;
            wait_cycle;
            en_in16 = 1'b0;

            repeat (cycles_to_wait) begin
                wait_cycle;
            end

            for (i = 0; i < N16; i = i + 1) begin
                expected_addr = expected_bit_reverse(i, STAGES16);
                if (dut16.ram.mem[expected_addr] !== a16[i]) begin
                    $display("FAIL n=16 input_index=%0d bit_reverse_addr=%0d got=%0d expected=%0d",
                        i, expected_addr, dut16.ram.mem[expected_addr], a16[i]);
                    errors = errors + 1;
                end else begin
                    $display("PASS n=16 input_index=%0d bit_reverse_addr=%0d got=%0d expected=%0d",
                        i, expected_addr, dut16.ram.mem[expected_addr], a16[i]);
                end
            end
        end
    endtask

endmodule
