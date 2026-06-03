`timescale 1ns/1ps

module dual_port_ram_tb;

    localparam integer WIDTH4 = 8;
    localparam integer SIZE4 = 4;
    localparam integer ADDR4 = $clog2(SIZE4);

    localparam integer WIDTH8 = 16;
    localparam integer SIZE8 = 8;
    localparam integer ADDR8 = $clog2(SIZE8);

    reg clk;
    reg write4;
    reg write8;

    reg [ADDR4-1:0] addr_a4;
    reg [WIDTH4-1:0] data_a4;
    wire [WIDTH4-1:0] out_a4;

    reg [ADDR4-1:0] addr_b4;
    reg [WIDTH4-1:0] data_b4;
    wire [WIDTH4-1:0] out_b4;

    reg [ADDR8-1:0] addr_a8;
    reg [WIDTH8-1:0] data_a8;
    wire [WIDTH8-1:0] out_a8;

    reg [ADDR8-1:0] addr_b8;
    reg [WIDTH8-1:0] data_b8;
    wire [WIDTH8-1:0] out_b8;

    integer errors;

    dual_port_ram #(
        .width(WIDTH4),
        .size(SIZE4)
    ) dut4 (
        .clk(clk),
        .write(write4),
        .addr_a(addr_a4),
        .data_a(data_a4),
        .out_a(out_a4),
        .addr_b(addr_b4),
        .data_b(data_b4),
        .out_b(out_b4)
    );

    dual_port_ram #(
        .width(WIDTH8),
        .size(SIZE8)
    ) dut8 (
        .clk(clk),
        .write(write8),
        .addr_a(addr_a8),
        .data_a(data_a8),
        .out_a(out_a8),
        .addr_b(addr_b8),
        .data_b(data_b8),
        .out_b(out_b8)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        errors = 0;

        write4 = 1'b0;
        addr_a4 = {ADDR4{1'b0}};
        addr_b4 = {ADDR4{1'b0}};
        data_a4 = {WIDTH4{1'b0}};
        data_b4 = {WIDTH4{1'b0}};

        write8 = 1'b0;
        addr_a8 = {ADDR8{1'b0}};
        addr_b8 = {ADDR8{1'b0}};
        data_a8 = {WIDTH8{1'b0}};
        data_b8 = {WIDTH8{1'b0}};

        #2;

        write_dual_4(2'd0, 8'h12, 2'd1, 8'h34, "write two addresses");
        read_dual_4(2'd0, 8'h12, 2'd1, 8'h34, "read initial writes");
        write_dual_4(2'd2, 8'hab, 2'd3, 8'hcd, "write remaining addresses");
        read_dual_4(2'd2, 8'hab, 2'd3, 8'hcd, "read remaining writes");
        write_a_read_b_4(2'd0, 8'h56, 2'd1, 8'h34, "write A while reading B");
        write_b_read_a_4(2'd2, 8'hab, 2'd3, 8'hef, "read A while writing B");
        read_dual_4(2'd0, 8'h56, 2'd3, 8'hef, "read updated edge addresses");
        read_dual_4(2'd1, 8'h34, 2'd2, 8'hab, "read preserved middle addresses");

        write_dual_8(3'd0, 16'h1234, 3'd7, 16'hcafe, "write edge addresses");
        read_dual_8(3'd0, 16'h1234, 3'd7, 16'hcafe, "read edge addresses");
        write_dual_8(3'd3, 16'h55aa, 3'd4, 16'ha55a, "write middle addresses");
        read_dual_8(3'd3, 16'h55aa, 3'd4, 16'ha55a, "read middle addresses");
        write_a_read_b_8(3'd2, 16'h0f0f, 3'd7, 16'hcafe, "write A while reading B");
        write_b_read_a_8(3'd3, 16'h55aa, 3'd5, 16'hf00d, "read A while writing B");
        read_dual_8(3'd2, 16'h0f0f, 3'd5, 16'hf00d, "read updated middle addresses");
        read_dual_8(3'd0, 16'h1234, 3'd4, 16'ha55a, "read preserved addresses");

        if (errors == 0) begin
            $display("All dual port RAM tests passed.");
        end else begin
            $display("Dual port RAM tests failed with %0d error(s).", errors);
        end

        $finish;
    end

    task wait_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task write_dual_4;
        input [ADDR4-1:0] next_addr_a;
        input [WIDTH4-1:0] next_data_a;
        input [ADDR4-1:0] next_addr_b;
        input [WIDTH4-1:0] next_data_b;
        input [8*40-1:0] name;
        begin
            addr_a4 = next_addr_a;
            data_a4 = next_data_a;
            addr_b4 = next_addr_b;
            data_b4 = next_data_b;
            write4 = 1'b1;
            wait_cycle;
            write4 = 1'b0;
        end
    endtask

    task read_dual_4;
        input [ADDR4-1:0] next_addr_a;
        input [WIDTH4-1:0] expected_a;
        input [ADDR4-1:0] next_addr_b;
        input [WIDTH4-1:0] expected_b;
        input [8*40-1:0] name;
        begin
            addr_a4 = next_addr_a;
            addr_b4 = next_addr_b;
            write4 = 1'b0;
            wait_cycle;

            if ((out_a4 !== expected_a) || (out_b4 !== expected_b)) begin
                $display("FAIL 8-bit size-4 dual read: %0s | input A_addr=%0d B_addr=%0d | got A=%h B=%h | expected A=%h B=%h",
                    name, next_addr_a, next_addr_b, out_a4, out_b4, expected_a, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit size-4 dual read: %0s | input A_addr=%0d B_addr=%0d | got A=%h B=%h | expected A=%h B=%h",
                    name, next_addr_a, next_addr_b, out_a4, out_b4, expected_a, expected_b);
            end
        end
    endtask

    task write_a_read_b_4;
        input [ADDR4-1:0] next_addr_a;
        input [WIDTH4-1:0] next_data_a;
        input [ADDR4-1:0] next_addr_b;
        input [WIDTH4-1:0] expected_b;
        input [8*40-1:0] name;
        begin
            addr_a4 = next_addr_a;
            data_a4 = next_data_a;
            addr_b4 = next_addr_b;
            data_b4 = expected_b;
            write4 = 1'b1;
            wait_cycle;
            write4 = 1'b0;

            if (out_b4 !== expected_b) begin
                $display("FAIL 8-bit size-4 mixed A write/B read: %0s | input A_addr=%0d A_data=%h B_addr=%0d | got B=%h | expected B=%h",
                    name, next_addr_a, next_data_a, next_addr_b, out_b4, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit size-4 mixed A write/B read: %0s | input A_addr=%0d A_data=%h B_addr=%0d | got B=%h | expected B=%h",
                    name, next_addr_a, next_data_a, next_addr_b, out_b4, expected_b);
            end
        end
    endtask

    task write_b_read_a_4;
        input [ADDR4-1:0] next_addr_a;
        input [WIDTH4-1:0] expected_a;
        input [ADDR4-1:0] next_addr_b;
        input [WIDTH4-1:0] next_data_b;
        input [8*40-1:0] name;
        begin
            addr_a4 = next_addr_a;
            data_a4 = expected_a;
            addr_b4 = next_addr_b;
            data_b4 = next_data_b;
            write4 = 1'b1;
            wait_cycle;
            write4 = 1'b0;

            if (out_a4 !== expected_a) begin
                $display("FAIL 8-bit size-4 mixed A read/B write: %0s | input A_addr=%0d B_addr=%0d B_data=%h | got A=%h | expected A=%h",
                    name, next_addr_a, next_addr_b, next_data_b, out_a4, expected_a);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit size-4 mixed A read/B write: %0s | input A_addr=%0d B_addr=%0d B_data=%h | got A=%h | expected A=%h",
                    name, next_addr_a, next_addr_b, next_data_b, out_a4, expected_a);
            end
        end
    endtask

    task write_dual_8;
        input [ADDR8-1:0] next_addr_a;
        input [WIDTH8-1:0] next_data_a;
        input [ADDR8-1:0] next_addr_b;
        input [WIDTH8-1:0] next_data_b;
        input [8*40-1:0] name;
        begin
            addr_a8 = next_addr_a;
            data_a8 = next_data_a;
            addr_b8 = next_addr_b;
            data_b8 = next_data_b;
            write8 = 1'b1;
            wait_cycle;
            write8 = 1'b0;
        end
    endtask

    task read_dual_8;
        input [ADDR8-1:0] next_addr_a;
        input [WIDTH8-1:0] expected_a;
        input [ADDR8-1:0] next_addr_b;
        input [WIDTH8-1:0] expected_b;
        input [8*40-1:0] name;
        begin
            addr_a8 = next_addr_a;
            addr_b8 = next_addr_b;
            write8 = 1'b0;
            wait_cycle;

            if ((out_a8 !== expected_a) || (out_b8 !== expected_b)) begin
                $display("FAIL 16-bit size-8 dual read: %0s | input A_addr=%0d B_addr=%0d | got A=%h B=%h | expected A=%h B=%h",
                    name, next_addr_a, next_addr_b, out_a8, out_b8, expected_a, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit size-8 dual read: %0s | input A_addr=%0d B_addr=%0d | got A=%h B=%h | expected A=%h B=%h",
                    name, next_addr_a, next_addr_b, out_a8, out_b8, expected_a, expected_b);
            end
        end
    endtask

    task write_a_read_b_8;
        input [ADDR8-1:0] next_addr_a;
        input [WIDTH8-1:0] next_data_a;
        input [ADDR8-1:0] next_addr_b;
        input [WIDTH8-1:0] expected_b;
        input [8*40-1:0] name;
        begin
            addr_a8 = next_addr_a;
            data_a8 = next_data_a;
            addr_b8 = next_addr_b;
            data_b8 = expected_b;
            write8 = 1'b1;
            wait_cycle;
            write8 = 1'b0;

            if (out_b8 !== expected_b) begin
                $display("FAIL 16-bit size-8 mixed A write/B read: %0s | input A_addr=%0d A_data=%h B_addr=%0d | got B=%h | expected B=%h",
                    name, next_addr_a, next_data_a, next_addr_b, out_b8, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit size-8 mixed A write/B read: %0s | input A_addr=%0d A_data=%h B_addr=%0d | got B=%h | expected B=%h",
                    name, next_addr_a, next_data_a, next_addr_b, out_b8, expected_b);
            end
        end
    endtask

    task write_b_read_a_8;
        input [ADDR8-1:0] next_addr_a;
        input [WIDTH8-1:0] expected_a;
        input [ADDR8-1:0] next_addr_b;
        input [WIDTH8-1:0] next_data_b;
        input [8*40-1:0] name;
        begin
            addr_a8 = next_addr_a;
            data_a8 = expected_a;
            addr_b8 = next_addr_b;
            data_b8 = next_data_b;
            write8 = 1'b1;
            wait_cycle;
            write8 = 1'b0;

            if (out_a8 !== expected_a) begin
                $display("FAIL 16-bit size-8 mixed A read/B write: %0s | input A_addr=%0d B_addr=%0d B_data=%h | got A=%h | expected A=%h",
                    name, next_addr_a, next_addr_b, next_data_b, out_a8, expected_a);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit size-8 mixed A read/B write: %0s | input A_addr=%0d B_addr=%0d B_data=%h | got A=%h | expected A=%h",
                    name, next_addr_a, next_addr_b, next_data_b, out_a8, expected_a);
            end
        end
    endtask

endmodule
