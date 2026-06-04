`timescale 1ns/1ps

module inverse_NTT_mixed # (
    parameter width = 16,
    parameter modulus = 17,
    parameter root = 9,
    parameter n = 8,
    parameter n_inverse = 15
) (
    input clk,
    input en_in,
    input [n-1:0][width-1:0] a,

    output reg en_out,
    output reg [n-1:0][width-1:0] t
);

localparam stages = $clog2(n);
localparam butterflies = n / 2;
localparam [width-1:0] n_inverse_sized = n_inverse;

localparam [1:0] STATE_IDLE = 2'd0;
localparam [1:0] STATE_PROCESS = 2'd1;

// combinational
reg [width-1:0] gsb_u [butterflies-1:0];
reg [width-1:0] gsb_v [butterflies-1:0];
wire [width-1:0] gsb_a [butterflies-1:0];
wire [width-1:0] gsb_b [butterflies-1:0];
reg [stages-1:0] twiddle_address [butterflies-1:0];
wire [width-1:0] twiddle_factor [butterflies-1:0];
reg [n-1:0][width-1:0] butterfly_results;
reg [n-1:0][width-1:0] next_stage_results;
wire [n-1:0][width-1:0] scaled_results;

// registers
reg [1:0] state;
reg [width-1:0] stage_counter;
reg [n-1:0][width-1:0] stage_results;

integer distance;
integer group_size;
integer group;
integer j;
integer twiddle_step;
integer left_index;
integer right_index;
integer u_index;
integer v_index;
integer rotated_addr_a;
integer rotated_addr_b;
integer i;

function integer bit_reverse;
    input integer x;
    input integer stages;

    integer j;
    integer bit_;
    begin
        bit_reverse = 0;

        for (j = 0; j < stages; j = j + 1) begin
            bit_ = ((1 << j) & x) >> j;
            bit_reverse = bit_reverse | (bit_ << (stages - 1 - j));
        end
    end
endfunction

function integer bit_rotate_index;
    input integer value;
    input integer bit_count;
    integer mask;
    integer low;
    integer high;
    integer rotated_low;
    begin
        mask = (1 << bit_count) - 1;
        low = value & mask;
        high = value & ~mask;
        rotated_low = (low >> 1) | ((low & 1) << (bit_count - 1));
        bit_rotate_index = high | rotated_low;
    end
endfunction

generate
    for (genvar butterfly_index = 0; butterfly_index < butterflies; butterfly_index = butterfly_index + 1) begin
        twiddle_rom # (
            .width(width),
            .modulus(modulus),
            .root(root),
            .n(n),
            .rom_width(stages)
        ) rom (
            .address(twiddle_address[butterfly_index]),
            .twiddle(twiddle_factor[butterfly_index])
        );

        gsb # (
            .width(width),
            .modulus(modulus)
        ) butterfly (
            .u(gsb_u[butterfly_index]),
            .v(gsb_v[butterfly_index]),
            .omega(twiddle_factor[butterfly_index]),
            .a(gsb_a[butterfly_index]),
            .b(gsb_b[butterfly_index])
        );
    end

    for (genvar output_index = 0; output_index < n; output_index = output_index + 1) begin
        localparam integer reverse = bit_reverse(output_index, stages);

        modular_multiplicator # (
            .width(width),
            .modulus(modulus)
        ) output_scaler (
            .a(n_inverse_sized),
            .b(next_stage_results[reverse]),
            .p(scaled_results[output_index])
        );
    end
endgenerate

initial begin
    state <= STATE_IDLE;
    stage_counter <= 0;
    en_out <= 0;
end

always_comb begin : comb_logic
    for (i = 0; i < n; i = i + 1) begin
        butterfly_results[i] = 0;
        next_stage_results[i] = stage_results[i];
    end

    distance = 1 << (stages - 1 - stage_counter);
    group_size = 1 << (stages - stage_counter);

    for (i = 0; i < butterflies; i = i + 1) begin
        group = (i / distance) * group_size;
        j = i % distance;
        left_index = group + j;
        right_index = group + j + distance;
        u_index = i * 2;
        v_index = i * 2 + 1;
        rotated_addr_a = bit_rotate_index(u_index, stages - stage_counter);
        rotated_addr_b = bit_rotate_index(v_index, stages - stage_counter);
        twiddle_step = j * (n >> (stages - stage_counter));
        twiddle_address[i] = (twiddle_step == 0) ? 0 : n - twiddle_step;

        gsb_u[i] = stage_results[rotated_addr_a];
        gsb_v[i] = stage_results[rotated_addr_b];

        butterfly_results[u_index] = gsb_a[i];
        butterfly_results[v_index] = gsb_b[i];
        next_stage_results[left_index] = butterfly_results[u_index];
        next_stage_results[right_index] = butterfly_results[v_index];
    end
end

always @(posedge clk) begin
    case (state)
        STATE_IDLE: begin
            en_out <= 0;

            if (en_in) begin
                for (i = 0; i < n; i = i + 1) begin
                    stage_results[i] <= a[i];
                end

                stage_counter <= 0;
                state <= STATE_PROCESS;
            end
        end

        STATE_PROCESS: begin
            stage_results <= next_stage_results;

            if (stage_counter == stages-1) begin
                t <= scaled_results;
                en_out <= 1;
                stage_counter <= 0;
                state <= STATE_IDLE;
            end else begin
                en_out <= 0;
                stage_counter <= stage_counter + 1;
            end
        end

        default: begin
            state <= STATE_IDLE;
            en_out <= 0;
        end
    endcase
end

endmodule
