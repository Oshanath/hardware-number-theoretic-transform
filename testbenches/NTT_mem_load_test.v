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
    reg inverse8;
    reg inverse16;

    reg [WIDTH8-1:0] a8;
    reg [WIDTH8-1:0] a8_values [0:N8-1];
    reg [WIDTH8-1:0] expected_ram8 [0:N8-1];
    wire en_out8;
    wire [WIDTH8-1:0] t8;

    reg [WIDTH16-1:0] a16;
    reg [WIDTH16-1:0] a16_values [0:N16-1];
    reg [WIDTH16-1:0] expected_ram16 [0:N16-1];
    wire en_out16;
    wire [WIDTH16-1:0] t16;

    integer i;
    integer errors;

    localparam [2:0] STATE_IDLE = 3'd0;

    NTT #(
        .width(WIDTH8),
        .modulus(MODULUS8),
        .root(ROOT8),
        .n(N8)
    ) dut8 (
        .clk(clk),
        .en_in(en_in8),
        .inverse_(inverse8),
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
        .inverse_(inverse16),
        .a(a16),
        .en_out(en_out16),
        .t(t16)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        en_in8 = 1'b0;
        en_in16 = 1'b0;
        inverse8 = 1'b0;
        inverse16 = 1'b0;
        a8 = '0;
        a16 = '0;
        errors = 0;

        #2;

        run_load_8("n=8 regular ascending", 10'd1, 10'd2, 10'd3, 10'd4, 10'd5, 10'd6, 10'd7, 10'd8);
        run_load_8("n=8 regular sparse", 10'd3, 10'd0, 10'd14, 10'd5, 10'd9, 10'd2, 10'd11, 10'd7);
        run_load_8("n=8 regular alternating", 10'd5, 10'd12, 10'd7, 10'd10, 10'd9, 10'd4, 10'd13, 10'd6);
        run_load_8("n=8 edge all zero", 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0);
        run_load_8("n=8 edge modulus boundary", 10'd16, 10'd0, 10'd16, 10'd1, 10'd15, 10'd2, 10'd14, 10'd3);

        run_load_16("n=16 regular ascending",
            12'd1, 12'd2, 12'd3, 12'd4, 12'd5, 12'd6, 12'd7, 12'd8,
            12'd9, 12'd10, 12'd11, 12'd12, 12'd13, 12'd14, 12'd15, 12'd16);
        run_load_16("n=16 regular sparse",
            12'd3, 12'd0, 12'd14, 12'd5, 12'd9, 12'd2, 12'd11, 12'd7,
            12'd4, 12'd12, 12'd1, 12'd15, 12'd6, 12'd10, 12'd8, 12'd13);
        run_load_16("n=16 regular alternating",
            12'd5, 12'd12, 12'd7, 12'd10, 12'd9, 12'd4, 12'd13, 12'd6,
            12'd15, 12'd2, 12'd14, 12'd3, 12'd16, 12'd1, 12'd11, 12'd8);
        run_load_16("n=16 edge all zero",
            12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,
            12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0);
        run_load_16("n=16 edge modulus boundary",
            12'd96, 12'd0, 12'd96, 12'd1, 12'd95, 12'd2, 12'd94, 12'd3,
            12'd93, 12'd4, 12'd92, 12'd5, 12'd91, 12'd6, 12'd90, 12'd7);

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
        input [WIDTH8-1:0] a0;
        input [WIDTH8-1:0] a1;
        input [WIDTH8-1:0] a2;
        input [WIDTH8-1:0] a3;
        input [WIDTH8-1:0] a4_in;
        input [WIDTH8-1:0] a5;
        input [WIDTH8-1:0] a6;
        input [WIDTH8-1:0] a7;
        integer expected_index;
        integer failed;
        begin
            a8_values[0] = a0;
            a8_values[1] = a1;
            a8_values[2] = a2;
            a8_values[3] = a3;
            a8_values[4] = a4_in;
            a8_values[5] = a5;
            a8_values[6] = a6;
            a8_values[7] = a7;
            for (i = 0; i < N8; i = i + 1) begin
                expected_ram8[bit_reverse_index(i, 3)] = a8_values[i];
            end

            for (i = 0; i < N8; i = i + 1) begin
                a8 = a8_values[i];
                en_in8 = 1'b1;
                wait_cycle;
            end
            en_in8 = 1'b0;

            failed = 0;
            for (i = 0; i < N8; i = i + 1) begin
                expected_index = bit_reverse_index(i, 3);
                if (dut8.ram.mem[expected_index] !== expected_ram8[expected_index]) begin
                    errors = errors + 1;
                    failed = 1;
                end
            end

            $display("%s %0s input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) got_ram=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected_ram=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                failed ? "FAIL" : "PASS", name,
                a8_values[0], a8_values[1], a8_values[2], a8_values[3],
                a8_values[4], a8_values[5], a8_values[6], a8_values[7],
                dut8.ram.mem[0], dut8.ram.mem[1], dut8.ram.mem[2], dut8.ram.mem[3],
                dut8.ram.mem[4], dut8.ram.mem[5], dut8.ram.mem[6], dut8.ram.mem[7],
                expected_ram8[0], expected_ram8[1], expected_ram8[2], expected_ram8[3],
                expected_ram8[4], expected_ram8[5], expected_ram8[6], expected_ram8[7]);

            while (dut8.state != STATE_IDLE) begin
                wait_cycle;
            end
        end
    endtask

    task run_load_16;
        input [8*64-1:0] name;
        input [WIDTH16-1:0] a0;
        input [WIDTH16-1:0] a1;
        input [WIDTH16-1:0] a2;
        input [WIDTH16-1:0] a3;
        input [WIDTH16-1:0] a4_in;
        input [WIDTH16-1:0] a5;
        input [WIDTH16-1:0] a6;
        input [WIDTH16-1:0] a7;
        input [WIDTH16-1:0] a8_in;
        input [WIDTH16-1:0] a9;
        input [WIDTH16-1:0] a10;
        input [WIDTH16-1:0] a11;
        input [WIDTH16-1:0] a12;
        input [WIDTH16-1:0] a13;
        input [WIDTH16-1:0] a14;
        input [WIDTH16-1:0] a15;
        integer expected_index;
        integer failed;
        begin
            a16_values[0] = a0;
            a16_values[1] = a1;
            a16_values[2] = a2;
            a16_values[3] = a3;
            a16_values[4] = a4_in;
            a16_values[5] = a5;
            a16_values[6] = a6;
            a16_values[7] = a7;
            a16_values[8] = a8_in;
            a16_values[9] = a9;
            a16_values[10] = a10;
            a16_values[11] = a11;
            a16_values[12] = a12;
            a16_values[13] = a13;
            a16_values[14] = a14;
            a16_values[15] = a15;
            for (i = 0; i < N16; i = i + 1) begin
                expected_ram16[bit_reverse_index(i, 4)] = a16_values[i];
            end

            for (i = 0; i < N16; i = i + 1) begin
                a16 = a16_values[i];
                en_in16 = 1'b1;
                wait_cycle;
            end
            en_in16 = 1'b0;

            failed = 0;
            for (i = 0; i < N16; i = i + 1) begin
                expected_index = bit_reverse_index(i, 4);
                if (dut16.ram.mem[expected_index] !== expected_ram16[expected_index]) begin
                    errors = errors + 1;
                    failed = 1;
                end
            end

            $display("%s %0s input=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) got_ram=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d) expected_ram=(%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                failed ? "FAIL" : "PASS", name,
                a16_values[0], a16_values[1], a16_values[2], a16_values[3],
                a16_values[4], a16_values[5], a16_values[6], a16_values[7],
                a16_values[8], a16_values[9], a16_values[10], a16_values[11],
                a16_values[12], a16_values[13], a16_values[14], a16_values[15],
                dut16.ram.mem[0], dut16.ram.mem[1], dut16.ram.mem[2], dut16.ram.mem[3],
                dut16.ram.mem[4], dut16.ram.mem[5], dut16.ram.mem[6], dut16.ram.mem[7],
                dut16.ram.mem[8], dut16.ram.mem[9], dut16.ram.mem[10], dut16.ram.mem[11],
                dut16.ram.mem[12], dut16.ram.mem[13], dut16.ram.mem[14], dut16.ram.mem[15],
                expected_ram16[0], expected_ram16[1], expected_ram16[2], expected_ram16[3],
                expected_ram16[4], expected_ram16[5], expected_ram16[6], expected_ram16[7],
                expected_ram16[8], expected_ram16[9], expected_ram16[10], expected_ram16[11],
                expected_ram16[12], expected_ram16[13], expected_ram16[14], expected_ram16[15]);

            while (dut16.state != STATE_IDLE) begin
                wait_cycle;
            end
        end
    endtask

endmodule
