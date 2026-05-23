`timescale 1ns/1ps

module twiddle_rom_tb;

    localparam integer WIDTH10 = 10;
    localparam integer MODULUS10 = 17;
    localparam integer ROOT10 = 9;
    localparam integer N10 = 8;
    localparam integer ROM_WIDTH10 = 3;

    localparam integer WIDTH8 = 8;
    localparam integer MODULUS8 = 13;
    localparam integer ROOT8 = 2;
    localparam integer N8 = 4;
    localparam integer ROM_WIDTH8 = 2;

    reg [ROM_WIDTH10-1:0] address10;
    wire [WIDTH10-1:0] twiddle10;

    reg [ROM_WIDTH8-1:0] address8;
    wire [WIDTH8-1:0] twiddle8;

    integer i;
    integer j;
    integer expected;
    integer errors;

    twiddle_rom #(
        .width(WIDTH10),
        .modulus(MODULUS10),
        .root(ROOT10),
        .n(N10),
        .rom_width(ROM_WIDTH10)
    ) dut10 (
        .address(address10),
        .twiddle(twiddle10)
    );

    twiddle_rom #(
        .width(WIDTH8),
        .modulus(MODULUS8),
        .root(ROOT8),
        .n(N8),
        .rom_width(ROM_WIDTH8)
    ) dut8 (
        .address(address8),
        .twiddle(twiddle8)
    );

    initial begin
        $dumpfile("twiddle_rom_tb.vcd");
        $dumpvars(0, twiddle_rom_tb);

        errors = 0;

        for (i = 0; i < N10; i = i + 1) begin
            check_10_bit_twiddle(i);
        end

        for (i = 0; i < N8; i = i + 1) begin
            check_8_bit_twiddle(i);
        end

        if (errors == 0) begin
            $display("All twiddle ROM tests passed.");
        end else begin
            $display("Twiddle ROM tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_10_bit_twiddle;
        input integer next_address;
        begin
            address10 = next_address[ROM_WIDTH10-1:0];

            #10;

            expected = 1;
            for (j = 0; j < next_address; j = j + 1) begin
                expected = (expected * ROOT10) % MODULUS10;
            end

            if (twiddle10 !== expected[WIDTH10-1:0]) begin
                $display("FAIL 10-bit: modulus=%0d root=%0d n=%0d address=%0d | got twiddle=%0d | expected twiddle=%0d",
                    MODULUS10, ROOT10, N10, next_address, twiddle10, expected);
                errors = errors + 1;
            end else begin
                $display("PASS 10-bit: modulus=%0d root=%0d n=%0d address=%0d | got twiddle=%0d | expected twiddle=%0d",
                    MODULUS10, ROOT10, N10, next_address, twiddle10, expected);
            end
        end
    endtask

    task check_8_bit_twiddle;
        input integer next_address;
        begin
            address8 = next_address[ROM_WIDTH8-1:0];

            #10;

            expected = 1;
            for (j = 0; j < next_address; j = j + 1) begin
                expected = (expected * ROOT8) % MODULUS8;
            end

            if (twiddle8 !== expected[WIDTH8-1:0]) begin
                $display("FAIL 8-bit: modulus=%0d root=%0d n=%0d address=%0d | got twiddle=%0d | expected twiddle=%0d",
                    MODULUS8, ROOT8, N8, next_address, twiddle8, expected);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit: modulus=%0d root=%0d n=%0d address=%0d | got twiddle=%0d | expected twiddle=%0d",
                    MODULUS8, ROOT8, N8, next_address, twiddle8, expected);
            end
        end
    endtask

endmodule
