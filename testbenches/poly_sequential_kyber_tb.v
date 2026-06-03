`timescale 1ns/1ps

module poly_sequential_kyber_tb;

    localparam integer CASES = 20;
    localparam integer VALUES_PER_CASE = 3;
    localparam integer MAX_CYCLES = 200000;
    localparam integer WIDTH = 24;
    localparam integer MODULUS = 3329;
    localparam integer ROOT = 17;
    localparam integer N = 256;
    localparam integer N_INV = 3316;

    reg clk;
    reg en_in;
    reg [N-1:0][WIDTH-1:0] a;
    reg [N-1:0][WIDTH-1:0] b;
    wire en_out;
    wire [N-1:0][WIDTH-1:0] p;

    reg [WIDTH-1:0] data [0:CASES*VALUES_PER_CASE*N-1];
    reg [N-1:0][WIDTH-1:0] output_values;

    integer errors;
    integer testcase;

    polynomial_multiplicator_sequential #(
        .width(WIDTH),
        .modulus(MODULUS),
        .root(ROOT),
        .n(N),
        .n_inverse(N_INV)
    ) dut (
        .clk(clk),
        .en_in(en_in),
        .a(a),
        .b(b),
        .p(p),
        .en_out(en_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        en_in = 1'b0;
        a = '0;
        b = '0;
        output_values = '0;
        errors = 0;

        $readmemh("testbenches/data/poly_kyber.mem", data);
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
        integer failed;
        begin
            base = (case_id - 1) * VALUES_PER_CASE * N;
            expected_base = base + (2 * N);
            output_values = '0;

            for (i = 0; i < N; i = i + 1) begin
                a[i] = data[base + i];
                b[i] = data[base + N + i];
            end

            en_in = 1'b1;
            wait_cycle();
            en_in = 1'b0;

            cycles = 0;
            while ((en_out !== 1'b1) && (cycles < MAX_CYCLES)) begin
                wait_cycle();
                cycles = cycles + 1;
            end

            for (i = 0; i < N; i = i + 1) begin
                output_values[i] = p[i];
            end

            failed = (en_out !== 1'b1);
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

            $write(" testcase=%0d a=", case_id);
            print_data_vector(base);
            $write(" b=");
            print_data_vector(base + N);
            $write(" output=");
            print_output_vector();
            $write("\n");

            wait_cycle();
        end
    endtask

endmodule
