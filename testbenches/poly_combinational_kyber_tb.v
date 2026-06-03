`timescale 1ns/1ps

module poly_combinational_kyber_tb;

    localparam integer CASES = 20;
    localparam integer VALUES_PER_CASE = 3;
    localparam integer WIDTH = 24;
    localparam integer MODULUS = 3329;
    localparam integer ROOT = 17;
    localparam integer N = 256;
    localparam integer N_INV = 3316;

    reg [N-1:0][WIDTH-1:0] a;
    reg [N-1:0][WIDTH-1:0] b;
    wire [N-1:0][WIDTH-1:0] p;

    reg [WIDTH-1:0] data [0:CASES*VALUES_PER_CASE*N-1];
    reg [N-1:0][WIDTH-1:0] output_values;

    integer errors;
    integer testcase;

    polynomial_multiplicator #(
        .width(WIDTH),
        .modulus(MODULUS),
        .root(ROOT),
        .n(N),
        .n_inverse(N_INV)
    ) dut (
        .a(a),
        .b(b),
        .p(p)
    );

    initial begin
        a = '0;
        b = '0;
        output_values = '0;
        errors = 0;

        $readmemh("testbenches/data/poly_kyber.mem", data);

        for (testcase = 1; testcase <= CASES; testcase = testcase + 1) begin
            run_testcase(testcase);
        end

        $finish(0);
    end

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
        integer failed;
        begin
            base = (case_id - 1) * VALUES_PER_CASE * N;
            expected_base = base + (2 * N);
            output_values = '0;

            for (i = 0; i < N; i = i + 1) begin
                a[i] = data[base + i];
                b[i] = data[base + N + i];
            end

            #10;

            for (i = 0; i < N; i = i + 1) begin
                output_values[i] = p[i];
            end

            failed = 0;
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
        end
    endtask

endmodule
