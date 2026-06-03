`timescale 1ns/1ps

module ntt_combinational_kyber_tb;

    localparam integer CASES = 20;
    localparam integer FORWARD_CASES = 15;
    localparam integer VALUES_PER_CASE = 2;
    localparam integer WIDTH = 24;
    localparam integer MODULUS = 3329;
    localparam integer ROOT = 17;
    localparam integer N = 256;
    localparam integer N_INV = 3316;

    reg [N-1:0][WIDTH-1:0] forward_a;
    reg [N-1:0][WIDTH-1:0] inverse_a;
    wire [N-1:0][WIDTH-1:0] forward_t;
    wire [N-1:0][WIDTH-1:0] inverse_t;

    reg [WIDTH-1:0] data [0:CASES*VALUES_PER_CASE*N-1];
    reg [N-1:0][WIDTH-1:0] output_values;

    integer errors;
    integer testcase;

    ntt_combinational #(
        .width(WIDTH),
        .modulus(MODULUS),
        .root(ROOT),
        .n(N)
    ) forward_dut (
        .a(forward_a),
        .t(forward_t)
    );

    inverse_ntt_combinational #(
        .width(WIDTH),
        .modulus(MODULUS),
        .root(ROOT),
        .n(N),
        .n_inverse(N_INV)
    ) inverse_dut (
        .a(inverse_a),
        .t(inverse_t)
    );

    initial begin
        forward_a = '0;
        inverse_a = '0;
        output_values = '0;
        errors = 0;

        $readmemh("testbenches/data/ntt_kyber.mem", data);

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
        integer inverse_case;
        begin
            base = (case_id - 1) * VALUES_PER_CASE * N;
            expected_base = base + N;
            inverse_case = (case_id > FORWARD_CASES);
            output_values = '0;

            if (inverse_case) begin
                for (i = 0; i < N; i = i + 1) begin
                    inverse_a[i] = data[base + i];
                end
            end else begin
                for (i = 0; i < N; i = i + 1) begin
                    forward_a[i] = data[base + i];
                end
            end

            #10;

            if (inverse_case) begin
                for (i = 0; i < N; i = i + 1) begin
                    output_values[i] = inverse_t[i];
                end
            end else begin
                for (i = 0; i < N; i = i + 1) begin
                    output_values[i] = forward_t[i];
                end
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

            $write(" testcase=%0d input=", case_id);
            print_data_vector(base);
            $write(" output=");
            print_output_vector();
            $write("\n");
        end
    endtask

endmodule
