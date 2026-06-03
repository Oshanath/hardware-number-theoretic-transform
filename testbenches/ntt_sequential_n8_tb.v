`timescale 1ns/1ps

module ntt_sequential_n8_tb;

    localparam integer CASES = 20;
    localparam integer FORWARD_CASES = 15;
    localparam integer VALUES_PER_CASE = 2;
    localparam integer MAX_CYCLES = 2000;
    localparam integer WIDTH = 16;
    localparam integer MODULUS = 17;
    localparam integer ROOT = 9;
    localparam integer N = 8;
    localparam integer N_INV = 15;

    reg clk;
    reg en_in;
    reg inverse_mode;
    reg [WIDTH-1:0] a;
    wire en_out;
    wire [WIDTH-1:0] t;

    reg [WIDTH-1:0] data [0:CASES*VALUES_PER_CASE*N-1];
    reg [WIDTH-1:0] output_values [0:N-1];

    integer errors;
    integer testcase;

    NTT #(
        .width(WIDTH),
        .modulus(MODULUS),
        .root(ROOT),
        .n(N),
        .n_inverse(N_INV)
    ) dut (
        .clk(clk),
        .en_in(en_in),
        .inverse_(inverse_mode),
        .a(a),
        .en_out(en_out),
        .t(t)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        en_in = 1'b0;
        inverse_mode = 1'b0;
        a = '0;
        errors = 0;

        $readmemh("testbenches/data/ntt_n8.mem", data);
        repeat (2) wait_cycle();

        for (testcase = 1; testcase <= CASES; testcase = testcase + 1) begin
            run_testcase(testcase);
        end

        $finish(0);
    end

    task wait_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task print_data_vector;
        input integer base;
        integer i;
        begin
            $write("[");
            for (i = 0; i < N; i = i + 1) begin
                if (i != 0) begin
                    $write(",");
                end
                $write("%0d", data[base + i]);
            end
            $write("]");
        end
    endtask

    task print_output_vector;
        integer i;
        begin
            $write("[");
            for (i = 0; i < N; i = i + 1) begin
                if (i != 0) begin
                    $write(",");
                end
                $write("%0d", output_values[i]);
            end
            $write("]");
        end
    endtask

    task run_testcase;
        input integer case_id;
        integer base;
        integer expected_base;
        integer i;
        integer cycles;
        integer output_count;
        integer failed;
        begin
            base = (case_id - 1) * VALUES_PER_CASE * N;
            expected_base = base + N;
            inverse_mode = (case_id > FORWARD_CASES);

            for (i = 0; i < N; i = i + 1) begin
                output_values[i] = '0;
            end

            for (i = 0; i < N; i = i + 1) begin
                a = data[base + i];
                en_in = 1'b1;
                wait_cycle();
            end
            en_in = 1'b0;
            a = '0;

            cycles = 0;
            output_count = 0;
            while ((output_count < N) && (cycles < MAX_CYCLES)) begin
                wait_cycle();
                cycles = cycles + 1;
                if (en_out) begin
                    output_values[output_count] = t;
                    output_count = output_count + 1;
                end
            end

            failed = (output_count != N);
            for (i = 0; i < N; i = i + 1) begin
                if (output_values[i] !== data[expected_base + i]) begin
                    failed = 1;
                end
            end

            if (failed) begin
                errors = errors + 1;
                $write("FAIL");
            end else begin
                $write("PASS");
            end

            $write(" testcase=%0d input=", case_id);
            print_data_vector(base);
            $write(" output=");
            print_output_vector();
            $write("\n");

            wait_cycle();
        end
    endtask

endmodule
