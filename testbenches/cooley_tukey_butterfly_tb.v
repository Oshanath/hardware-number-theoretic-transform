`timescale 1ns/1ps

module cooley_tukey_butterfly_tb;

    localparam integer WIDTH10 = 10;
    localparam integer MODULUS10 = 17;
    localparam integer WIDTH8 = 8;
    localparam integer MODULUS8 = 13;

    reg [WIDTH10-1:0] a10;
    reg [WIDTH10-1:0] b10;
    reg [WIDTH10-1:0] omega10;
    wire [WIDTH10-1:0] u10;
    wire [WIDTH10-1:0] v10;

    reg [WIDTH8-1:0] a8;
    reg [WIDTH8-1:0] b8;
    reg [WIDTH8-1:0] omega8;
    wire [WIDTH8-1:0] u8;
    wire [WIDTH8-1:0] v8;

    integer b_omega;
    integer expected_u;
    integer expected_v;
    integer errors;

    ctb #(
        .width(WIDTH10),
        .modulus(MODULUS10)
    ) dut10 (
        .a(a10),
        .b(b10),
        .omega(omega10),
        .u(u10),
        .v(v10)
    );

    ctb #(
        .width(WIDTH8),
        .modulus(MODULUS8)
    ) dut8 (
        .a(a8),
        .b(b8),
        .omega(omega8),
        .u(u8),
        .v(v8)
    );

    initial begin
        $dumpfile("cooley_tukey_butterfly_tb.vcd");
        $dumpvars(0, cooley_tukey_butterfly_tb);

        errors = 0;

        check_10_bit(10'd0,    10'd0,    10'd0);
        check_10_bit(10'd1,    10'd1,    10'd1);
        check_10_bit(10'd16,   10'd1,    10'd1);
        check_10_bit(10'd8,    10'd9,    10'd3);
        check_10_bit(10'd17,   10'd18,   10'd16);
        check_10_bit(10'd100,  10'd200,  10'd7);
        check_10_bit(10'd1023, 10'd1023, 10'd1023);

        check_8_bit(8'd0,   8'd0,   8'd0);
        check_8_bit(8'd1,   8'd12,  8'd1);
        check_8_bit(8'd12,  8'd12,  8'd12);
        check_8_bit(8'd13,  8'd14,  8'd12);
        check_8_bit(8'd55,  8'd89,  8'd5);
        check_8_bit(8'd255, 8'd255, 8'd255);

        if (errors == 0) begin
            $display("All Cooley-Tukey butterfly tests passed.");
        end else begin
            $display("Cooley-Tukey butterfly tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task check_10_bit;
        input [WIDTH10-1:0] next_a;
        input [WIDTH10-1:0] next_b;
        input [WIDTH10-1:0] next_omega;
        begin
            a10 = next_a;
            b10 = next_b;
            omega10 = next_omega;

            #10;

            b_omega = ((next_b % MODULUS10) * (next_omega % MODULUS10)) % MODULUS10;
            expected_u = ((next_a % MODULUS10) + b_omega) % MODULUS10;
            expected_v = (next_a % MODULUS10) - b_omega;
            if (expected_v < 0) begin
                expected_v = expected_v + MODULUS10;
            end

            if ((u10 !== expected_u[WIDTH10-1:0]) || (v10 !== expected_v[WIDTH10-1:0])) begin
                $display("FAIL 10-bit: modulus=%0d a=%0d b=%0d omega=%0d | got u=%0d v=%0d | expected u=%0d v=%0d",
                    MODULUS10, next_a, next_b, next_omega, u10, v10, expected_u, expected_v);
                errors = errors + 1;
            end else begin
                $display("PASS 10-bit: modulus=%0d a=%0d b=%0d omega=%0d | got u=%0d v=%0d | expected u=%0d v=%0d",
                    MODULUS10, next_a, next_b, next_omega, u10, v10, expected_u, expected_v);
            end
        end
    endtask

    task check_8_bit;
        input [WIDTH8-1:0] next_a;
        input [WIDTH8-1:0] next_b;
        input [WIDTH8-1:0] next_omega;
        begin
            a8 = next_a;
            b8 = next_b;
            omega8 = next_omega;

            #10;

            b_omega = ((next_b % MODULUS8) * (next_omega % MODULUS8)) % MODULUS8;
            expected_u = ((next_a % MODULUS8) + b_omega) % MODULUS8;
            expected_v = (next_a % MODULUS8) - b_omega;
            if (expected_v < 0) begin
                expected_v = expected_v + MODULUS8;
            end

            if ((u8 !== expected_u[WIDTH8-1:0]) || (v8 !== expected_v[WIDTH8-1:0])) begin
                $display("FAIL 8-bit: modulus=%0d a=%0d b=%0d omega=%0d | got u=%0d v=%0d | expected u=%0d v=%0d",
                    MODULUS8, next_a, next_b, next_omega, u8, v8, expected_u, expected_v);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit: modulus=%0d a=%0d b=%0d omega=%0d | got u=%0d v=%0d | expected u=%0d v=%0d",
                    MODULUS8, next_a, next_b, next_omega, u8, v8, expected_u, expected_v);
            end
        end
    endtask

endmodule
