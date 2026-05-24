module ntt_combinational # (
    parameter width = 10,
    parameter modulus = 17,
    parameter root = 9,
    parameter n = 8
)(
    input wire [n-1:0][width-1:0] a,
    output [n-1:0][width-1:0] t
);

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

function integer bit_rotate;
    input integer x;
    input integer bits;

    integer mask;
    integer low;
    integer high;
    integer rotated_low;

    begin
        bit_rotate = 0;
        mask = (1 << bits) - 1;
        low = x & mask;
        high = x & ~mask;

        rotated_low = (low >> 1) | (low & 1) << (bits - 1);
        bit_rotate = high | rotated_low;
    end
endfunction

localparam stages = $clog2(n);
wire [width-1:0] stage_outputs [stages:0][n-1:0];

generate
    for (genvar i = 0; i < n; i = i + 1) begin
        localparam integer reverse = bit_reverse(i, stages);
        assign stage_outputs[0][reverse] = a[i];
    end

    for (genvar i = 0; i < n; i = i + 1) begin
        assign t[i] = stage_outputs[stages][i];
    end

    for (genvar i = 0; i < stages; i = i + 1) begin

        wire [width-1:0] inputs [n-1:0];
        localparam integer current_stage = i;
        localparam integer next_stage = i + 1;
        localparam integer distance = 1 << i;
        localparam integer group_size = 1 << (i+1);

        for (genvar group_start = 0; group_start < n; group_start = group_start + group_size) begin
            for (genvar j = 0; j < distance; j = j + 1) begin
                localparam integer input_pair_index = (group_start / group_size) * distance + j;
                localparam integer left_index  = group_start + j;
                localparam integer right_index = group_start + j + distance;
                localparam integer u_index = bit_rotate(input_pair_index * 2, i + 1);
                localparam integer v_index = bit_rotate(input_pair_index * 2 + 1, i + 1);
                localparam [stages-1:0] twiddle_address = j * (n >> (i + 1));

                wire [width-1:0] twiddle_factor;

                twiddle_rom # (
                    .width(width),
                    .modulus(modulus),
                    .root(root),
                    .n(n),
                    .rom_width(stages)
                ) rom (
                    .address(twiddle_address),
                    .twiddle(twiddle_factor)
                );

                ctb # (
                    .width(width),
                    .modulus(modulus)
                ) butterfly (
                    .a(stage_outputs[current_stage][left_index]),
                    .b(stage_outputs[current_stage][right_index]),
                    .omega(twiddle_factor),
                    .u(stage_outputs[next_stage][u_index]),
                    .v(stage_outputs[next_stage][v_index])
                );
            end
        end
    end
endgenerate

endmodule
