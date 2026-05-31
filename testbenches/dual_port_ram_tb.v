`timescale 1ns/1ps

module dual_port_ram_tb;

    localparam integer WIDTH4 = 8;
    localparam integer SIZE4 = 4;
    localparam integer ADDR4 = $clog2(SIZE4);

    localparam integer WIDTH8 = 16;
    localparam integer SIZE8 = 8;
    localparam integer ADDR8 = $clog2(SIZE8);

    reg clk;

    reg [ADDR4-1:0] addr_a4;
    reg [WIDTH4-1:0] data_a4;
    reg read_a4;
    wire [WIDTH4-1:0] out_a4;

    reg [ADDR4-1:0] addr_b4;
    reg [WIDTH4-1:0] data_b4;
    reg read_b4;
    wire [WIDTH4-1:0] out_b4;

    reg [ADDR8-1:0] addr_a8;
    reg [WIDTH8-1:0] data_a8;
    reg read_a8;
    wire [WIDTH8-1:0] out_a8;

    reg [ADDR8-1:0] addr_b8;
    reg [WIDTH8-1:0] data_b8;
    reg read_b8;
    wire [WIDTH8-1:0] out_b8;

    integer errors;

    dual_port_ram #(
        .width(WIDTH4),
        .size(SIZE4)
    ) dut4 (
        .clk(clk),
        .addr_a(addr_a4),
        .data_a(data_a4),
        .read_a(read_a4),
        .out_a(out_a4),
        .addr_b(addr_b4),
        .data_b(data_b4),
        .read_b(read_b4),
        .out_b(out_b4)
    );

    dual_port_ram #(
        .width(WIDTH8),
        .size(SIZE8)
    ) dut8 (
        .clk(clk),
        .addr_a(addr_a8),
        .data_a(data_a8),
        .read_a(read_a8),
        .out_a(out_a8),
        .addr_b(addr_b8),
        .data_b(data_b8),
        .read_b(read_b8),
        .out_b(out_b8)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dual_port_ram_tb.vcd");
        $dumpvars(0, dual_port_ram_tb);

        clk = 0;
        errors = 0;

        read_a4 = 1'b1;
        read_b4 = 1'b1;
        addr_a4 = {ADDR4{1'b0}};
        addr_b4 = {ADDR4{1'b0}};
        data_a4 = {WIDTH4{1'b0}};
        data_b4 = {WIDTH4{1'b0}};

        read_a8 = 1'b1;
        read_b8 = 1'b1;
        addr_a8 = {ADDR8{1'b0}};
        addr_b8 = {ADDR8{1'b0}};
        data_a8 = {WIDTH8{1'b0}};
        data_b8 = {WIDTH8{1'b0}};

        #2;

        write_dual_4(2'd0, 8'h12, 2'd1, 8'h34, "write two addresses");
        read_dual_4(2'd0, 8'h12, 2'd1, 8'h34, "read initial writes");
        write_dual_4(2'd2, 8'hab, 2'd3, 8'hcd, "write remaining addresses");
        read_dual_4(2'd2, 8'hab, 2'd3, 8'hcd, "read remaining writes");
        read_dual_4(2'd1, 8'h34, 2'd0, 8'h12, "cross-port read");
        write_a_read_b_4(2'd0, 8'h56, 2'd3, 8'hcd, "write port A while reading port B");
        read_dual_4(2'd0, 8'h56, 2'd3, 8'hcd, "verify mixed operation");
        write_b_read_a_4(2'd2, 8'hab, 2'd1, 8'h78, "read port A while writing port B");
        read_dual_4(2'd2, 8'hab, 2'd1, 8'h78, "verify second mixed operation");
        read_dual_4(2'd0, 8'h56, 2'd0, 8'h56, "both ports read same address");

        write_dual_8(3'd0, 16'h1234, 3'd7, 16'hcafe, "write edge addresses");
        read_dual_8(3'd0, 16'h1234, 3'd7, 16'hcafe, "read edge addresses");
        write_dual_8(3'd3, 16'h55aa, 3'd4, 16'ha55a, "write middle addresses");
        read_dual_8(3'd3, 16'h55aa, 3'd4, 16'ha55a, "read middle addresses");
        read_dual_8(3'd7, 16'hcafe, 3'd0, 16'h1234, "cross-port read");
        write_a_read_b_8(3'd7, 16'hbeef, 3'd4, 16'ha55a, "write port A while reading port B");
        read_dual_8(3'd7, 16'hbeef, 3'd4, 16'ha55a, "verify mixed operation");
        write_b_read_a_8(3'd3, 16'h55aa, 3'd0, 16'h0f0f, "read port A while writing port B");
        read_dual_8(3'd3, 16'h55aa, 3'd0, 16'h0f0f, "verify second mixed operation");
        read_dual_8(3'd7, 16'hbeef, 3'd7, 16'hbeef, "both ports read same address");

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
            $display("TEST 8-bit size-4 dual write: %0s | A addr=%0d data=%h | B addr=%0d data=%h",
                name, next_addr_a, next_data_a, next_addr_b, next_data_b);
            addr_a4 = next_addr_a;
            data_a4 = next_data_a;
            read_a4 = 1'b0;
            addr_b4 = next_addr_b;
            data_b4 = next_data_b;
            read_b4 = 1'b0;
            wait_cycle;
        end
    endtask

    task read_dual_4;
        input [ADDR4-1:0] next_addr_a;
        input [WIDTH4-1:0] expected_a;
        input [ADDR4-1:0] next_addr_b;
        input [WIDTH4-1:0] expected_b;
        input [8*40-1:0] name;
        begin
            $display("TEST 8-bit size-4 dual read: %0s | A addr=%0d expected=%h | B addr=%0d expected=%h",
                name, next_addr_a, expected_a, next_addr_b, expected_b);
            addr_a4 = next_addr_a;
            read_a4 = 1'b1;
            addr_b4 = next_addr_b;
            read_b4 = 1'b1;
            wait_cycle;

            if ((out_a4 !== expected_a) || (out_b4 !== expected_b)) begin
                $display("FAIL 8-bit size-4 dual read: got A=%h B=%h | expected A=%h B=%h",
                    out_a4, out_b4, expected_a, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit size-4 dual read: got A=%h B=%h | expected A=%h B=%h",
                    out_a4, out_b4, expected_a, expected_b);
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
            $display("TEST 8-bit size-4 mixed A write/B read: %0s | A addr=%0d data=%h | B addr=%0d expected=%h",
                name, next_addr_a, next_data_a, next_addr_b, expected_b);
            addr_a4 = next_addr_a;
            data_a4 = next_data_a;
            read_a4 = 1'b0;
            addr_b4 = next_addr_b;
            read_b4 = 1'b1;
            wait_cycle;

            if (out_b4 !== expected_b) begin
                $display("FAIL 8-bit size-4 mixed A write/B read: got B=%h | expected B=%h",
                    out_b4, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit size-4 mixed A write/B read: got B=%h | expected B=%h",
                    out_b4, expected_b);
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
            $display("TEST 8-bit size-4 mixed A read/B write: %0s | A addr=%0d expected=%h | B addr=%0d data=%h",
                name, next_addr_a, expected_a, next_addr_b, next_data_b);
            addr_a4 = next_addr_a;
            read_a4 = 1'b1;
            addr_b4 = next_addr_b;
            data_b4 = next_data_b;
            read_b4 = 1'b0;
            wait_cycle;

            if (out_a4 !== expected_a) begin
                $display("FAIL 8-bit size-4 mixed A read/B write: got A=%h | expected A=%h",
                    out_a4, expected_a);
                errors = errors + 1;
            end else begin
                $display("PASS 8-bit size-4 mixed A read/B write: got A=%h | expected A=%h",
                    out_a4, expected_a);
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
            $display("TEST 16-bit size-8 dual write: %0s | A addr=%0d data=%h | B addr=%0d data=%h",
                name, next_addr_a, next_data_a, next_addr_b, next_data_b);
            addr_a8 = next_addr_a;
            data_a8 = next_data_a;
            read_a8 = 1'b0;
            addr_b8 = next_addr_b;
            data_b8 = next_data_b;
            read_b8 = 1'b0;
            wait_cycle;
        end
    endtask

    task read_dual_8;
        input [ADDR8-1:0] next_addr_a;
        input [WIDTH8-1:0] expected_a;
        input [ADDR8-1:0] next_addr_b;
        input [WIDTH8-1:0] expected_b;
        input [8*40-1:0] name;
        begin
            $display("TEST 16-bit size-8 dual read: %0s | A addr=%0d expected=%h | B addr=%0d expected=%h",
                name, next_addr_a, expected_a, next_addr_b, expected_b);
            addr_a8 = next_addr_a;
            read_a8 = 1'b1;
            addr_b8 = next_addr_b;
            read_b8 = 1'b1;
            wait_cycle;

            if ((out_a8 !== expected_a) || (out_b8 !== expected_b)) begin
                $display("FAIL 16-bit size-8 dual read: got A=%h B=%h | expected A=%h B=%h",
                    out_a8, out_b8, expected_a, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit size-8 dual read: got A=%h B=%h | expected A=%h B=%h",
                    out_a8, out_b8, expected_a, expected_b);
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
            $display("TEST 16-bit size-8 mixed A write/B read: %0s | A addr=%0d data=%h | B addr=%0d expected=%h",
                name, next_addr_a, next_data_a, next_addr_b, expected_b);
            addr_a8 = next_addr_a;
            data_a8 = next_data_a;
            read_a8 = 1'b0;
            addr_b8 = next_addr_b;
            read_b8 = 1'b1;
            wait_cycle;

            if (out_b8 !== expected_b) begin
                $display("FAIL 16-bit size-8 mixed A write/B read: got B=%h | expected B=%h",
                    out_b8, expected_b);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit size-8 mixed A write/B read: got B=%h | expected B=%h",
                    out_b8, expected_b);
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
            $display("TEST 16-bit size-8 mixed A read/B write: %0s | A addr=%0d expected=%h | B addr=%0d data=%h",
                name, next_addr_a, expected_a, next_addr_b, next_data_b);
            addr_a8 = next_addr_a;
            read_a8 = 1'b1;
            addr_b8 = next_addr_b;
            data_b8 = next_data_b;
            read_b8 = 1'b0;
            wait_cycle;

            if (out_a8 !== expected_a) begin
                $display("FAIL 16-bit size-8 mixed A read/B write: got A=%h | expected A=%h",
                    out_a8, expected_a);
                errors = errors + 1;
            end else begin
                $display("PASS 16-bit size-8 mixed A read/B write: got A=%h | expected A=%h",
                    out_a8, expected_a);
            end
        end
    endtask

endmodule
