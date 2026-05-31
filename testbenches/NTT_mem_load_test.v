`timescale 1ns/1ps

module NTT_mem_load_test;

    localparam integer WIDTH8 = 10;
    localparam integer MODULUS8 = 17;
    localparam integer ROOT8 = 9;
    localparam integer N8 = 8;

    localparam integer WIDTH16 = 12;
    localparam integer MODULUS16 = 97;
    localparam integer ROOT16 = 5;
    localparam integer N16 = 16;

    reg clk;
    reg en_in8;
    reg en_in16;

    reg [N8-1:0][WIDTH8-1:0] a8;
    wire en_out8;
    wire [N8-1:0][WIDTH8-1:0] t8;

    reg [N16-1:0][WIDTH16-1:0] a16;
    wire en_out16;
    wire [N16-1:0][WIDTH16-1:0] t16;

    integer i;
    integer errors;

    NTT #(
        .width(WIDTH8),
        .modulus(MODULUS8),
        .root(ROOT8),
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
        .modulus(MODULUS16),
        .root(ROOT16),
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

        clk = 1'b0;
        en_in8 = 1'b0;
        en_in16 = 1'b0;
        a8 = '0;
        a16 = '0;
        errors = 0;

        #2;

        run_load_8("n=8 width=10 memory load");
        run_load_16("n=16 width=12 memory load");

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

    task run_load_8;
        input [8*64-1:0] name;
        integer expected_index;
        begin
            $display("TESTCASE %0s", name);

            for (i = 0; i < N8; i = i + 1) begin
                a8[i] = (i * 3 + 1) % MODULUS8;
                $display("  input[%0d]=%0d -> expected ram[%0d]",
                    i, a8[i], bit_reverse_index(i, 3));
            end

            en_in8 = 1'b1;
            wait_cycle;
            en_in8 = 1'b0;

            repeat ((N8 / 2) + 1) begin
                wait_cycle;
            end

            for (i = 0; i < N8; i = i + 1) begin
                expected_index = bit_reverse_index(i, 3);
                if (dut8.ram.mem[expected_index] !== a8[i]) begin
                    $display("FAIL %0s output ram[%0d]=%0d expected input[%0d]=%0d",
                        name, expected_index, dut8.ram.mem[expected_index], i, a8[i]);
                    errors = errors + 1;
                end else begin
                    $display("PASS %0s output ram[%0d]=%0d expected input[%0d]=%0d",
                        name, expected_index, dut8.ram.mem[expected_index], i, a8[i]);
                end
            end
        end
    endtask

    task run_load_16;
        input [8*64-1:0] name;
        integer expected_index;
        begin
            $display("TESTCASE %0s", name);

            for (i = 0; i < N16; i = i + 1) begin
                a16[i] = (i * 7 + 4) % MODULUS16;
                $display("  input[%0d]=%0d -> expected ram[%0d]",
                    i, a16[i], bit_reverse_index(i, 4));
            end

            en_in16 = 1'b1;
            wait_cycle;
            en_in16 = 1'b0;

            repeat ((N16 / 2) + 1) begin
                wait_cycle;
            end

            for (i = 0; i < N16; i = i + 1) begin
                expected_index = bit_reverse_index(i, 4);
                if (dut16.ram.mem[expected_index] !== a16[i]) begin
                    $display("FAIL %0s output ram[%0d]=%0d expected input[%0d]=%0d",
                        name, expected_index, dut16.ram.mem[expected_index], i, a16[i]);
                    errors = errors + 1;
                end else begin
                    $display("PASS %0s output ram[%0d]=%0d expected input[%0d]=%0d",
                        name, expected_index, dut16.ram.mem[expected_index], i, a16[i]);
                end
            end
        end
    endtask

endmodule
