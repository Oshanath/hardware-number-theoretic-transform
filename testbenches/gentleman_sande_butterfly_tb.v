`timescale 1ns/1ps

module gentleman_sande_butterfly_tb;

    localparam integer WIDTH10 = 10;
    localparam integer MODULUS10 = 17;
    localparam integer WIDTH8 = 8;
    localparam integer MODULUS8 = 13;

    reg [WIDTH10-1:0] u10;
    reg [WIDTH10-1:0] v10;
    reg [WIDTH10-1:0] omega10;
    wire [WIDTH10-1:0] a10;
    wire [WIDTH10-1:0] b10;

    reg [WIDTH8-1:0] u8;
    reg [WIDTH8-1:0] v8;
    reg [WIDTH8-1:0] omega8;
    wire [WIDTH8-1:0] a8;
    wire [WIDTH8-1:0] b8;

    integer u_minus_v;
    integer expected_a;
    integer expected_b;
    integer errors;

    gsb #(
        .width(WIDTH10),
        .modulus(MODULUS10)
    ) dut10 (
        .u(u10),
        .v(v10),
        .omega(omega10),
        .a(a10),
        .b(b10)
    );

    gsb #(
        .width(WIDTH8),
        .modulus(MODULUS8)
    ) dut8 (
        .u(u8),
        .v(v8),
        .omega(omega8),
        .a(a8),
        .b(b8)
    );

    initial begin
        errors = 0;

        check_10_bit(10'd0,   10'd0,   10'd0);
        check_10_bit(10'd1,   10'd1,   10'd1);
        check_10_bit(10'd16,  10'd0,   10'd9);
        check_10_bit(10'd0,   10'd16,  10'd9);
        check_10_bit(10'd100, 10'd200, 10'd7);
        check_10_bit(10'd42,  10'd99,  10'd5);

        check_8_bit(8'd0,  8'd0,  8'd0);
        check_8_bit(8'd1,  8'd12, 8'd1);
        check_8_bit(8'd12, 8'd0,  8'd5);
        check_8_bit(8'd0,  8'd12, 8'd5);
        check_8_bit(8'd55, 8'd89, 8'd5);
        check_8_bit(8'd42, 8'd99, 8'd4);

        if (errors == 0) begin
            $display("All Gentleman-Sande butterfly tests passed.");
        end else begin
            $display("Gentleman-Sande butterfly tests failed with %0d error(s).", errors);
        end

        $finish(0);
    end

    task check_10_bit;
        input [WIDTH10-1:0] next_u;
        input [WIDTH10-1:0] next_v;
        input [WIDTH10-1:0] next_omega;
        begin
            u10 = next_u;
            v10 = next_v;
            omega10 = next_omega;

            #10;

            expected_a = ((next_u % MODULUS10) + (next_v % MODULUS10)) % MODULUS10;
            u_minus_v = (next_u % MODULUS10) - (next_v % MODULUS10);
            if (u_minus_v < 0) begin
                u_minus_v = u_minus_v + MODULUS10;
            end
            expected_b = (u_minus_v * (next_omega % MODULUS10)) % MODULUS10;

            if ((a10 !== expected_a[WIDTH10-1:0]) || (b10 !== expected_b[WIDTH10-1:0])) begin
                $display("FAIL 10-bit: modulus=%0d u=%0d v=%0d omega=%0d | got a=%0d b=%0d | expected a=%0d b=%0d",
                    MODULUS10, next_u, next_v, next_omega, a10, b10, expected_a, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 10-bit: modulus=%0d u=%0d v=%0d omega=%0d | got a=%0d b=%0d | expected a=%0d b=%0d",
                    MODULUS10, next_u, next_v, next_omega, a10, b10, expected_a, expected_b);
            end
        end
    endtask

    task check_8_bit;
        input [WIDTH8-1:0] next_u;
        input [WIDTH8-1:0] next_v;
        input [WIDTH8-1:0] next_omega;
        begin
            u8 = next_u;
            v8 = next_v;
            omega8 = next_omega;

            #10;

            expected_a = ((next_u % MODULUS8) + (next_v % MODULUS8)) % MODULUS8;
            u_minus_v = (next_u % MODULUS8) - (next_v % MODULUS8);
            if (u_minus_v < 0) begin
                u_minus_v = u_minus_v + MODULUS8;
            end
            expected_b = (u_minus_v * (next_omega % MODULUS8)) % MODULUS8;

            if ((a8 !== expected_a[WIDTH8-1:0]) || (b8 !== expected_b[WIDTH8-1:0])) begin
                $display("FAIL 8-bit: modulus=%0d u=%0d v=%0d omega=%0d | got a=%0d b=%0d | expected a=%0d b=%0d",
                    MODULUS8, next_u, next_v, next_omega, a8, b8, expected_a, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit: modulus=%0d u=%0d v=%0d omega=%0d | got a=%0d b=%0d | expected a=%0d b=%0d",
                    MODULUS8, next_u, next_v, next_omega, a8, b8, expected_a, expected_b);
            end
        end
    endtask

endmodule
