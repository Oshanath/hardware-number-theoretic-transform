module polynomial_multiplicator_mixed # (
    parameter width = 16,
    parameter modulus = 17,
    parameter root = 9,
    parameter n = 8,
    parameter n_inverse = 15
) (
    input clk,
    input en_in,
    input [n-1:0][width-1:0] a, b,

    output [n-1:0][width-1:0] p,
    output en_out
);

localparam STATE_IDLE = 3'd0;
localparam STATE_LOAD_A = 3'd1;
localparam STATE_WAIT_TRANS_A = 3'd2;
localparam STATE_LOAD_B = 3'd3;
localparam STATE_WAIT_TRANS_B = 3'd4;
localparam STATE_LOAD_INV = 3'd5;
localparam STATE_WAIT_INV = 3'd6;

//state
reg [2:0] state;
reg [n-1:0][width-1:0] a_buffer, b_buffer, p_buffer;
reg [n-1:0][width-1:0] forward_a_results, forward_b_results;
reg en_out_reg, forward_ntt_en_reg, inverse_ntt_en_reg;

// combinational
wire forward_ntt_en_in, forward_ntt_en_out;
wire inverse_ntt_en_in, inverse_ntt_en_out;
wire [n-1:0][width-1:0] forward_ntt_a_in, forward_ntt_t_out;
wire [n-1:0][width-1:0] inverse_ntt_t_out;
wire [n-1:0][width-1:0] mult_results, p_out;

assign p = p_buffer;
assign en_out = en_out_reg;
assign forward_ntt_en_in = forward_ntt_en_reg;
assign inverse_ntt_en_in = inverse_ntt_en_reg;
assign forward_ntt_a_in = (state == STATE_LOAD_B || state == STATE_WAIT_TRANS_B) ? b_buffer : a_buffer;

NTT_mixed # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n)
) forward_ntt (
    .clk(clk),
    .en_in(forward_ntt_en_in),
    .a(forward_ntt_a_in),
    .en_out(forward_ntt_en_out),
    .t(forward_ntt_t_out)
);

generate
    for(genvar i = 0; i < n; i = i + 1) begin
        modular_multiplicator # (
            .width(width),
            .modulus(modulus)
        ) mm (
            .a(forward_a_results[i]),
            .b(forward_b_results[i]),
            .p(mult_results[i])
        );
    end
endgenerate

inverse_NTT_mixed # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n),
    .n_inverse(n_inverse)
) intt (
    .clk(clk),
    .en_in(inverse_ntt_en_in),
    .a(mult_results),
    .en_out(inverse_ntt_en_out),
    .t(inverse_ntt_t_out)
);

initial begin
    state <= 0;
    forward_ntt_en_reg <= 0;
    inverse_ntt_en_reg <= 0;
    en_out_reg <= 0;
end

always @(posedge clk) begin
    case(state)
        STATE_IDLE: begin
            en_out_reg <= 0;
            forward_ntt_en_reg <= 0;
            inverse_ntt_en_reg <= 0;

            if (en_in) begin
                a_buffer <= a;
                b_buffer <= b;
                forward_ntt_en_reg <= 1;
                state <= STATE_LOAD_A;
            end
        end

        STATE_LOAD_A: begin
            en_out_reg <= 0;
            forward_ntt_en_reg <= 0;
            inverse_ntt_en_reg <= 0;
            state <= STATE_WAIT_TRANS_A;
        end

        STATE_WAIT_TRANS_A: begin
            if (forward_ntt_en_out) begin
                forward_a_results <= forward_ntt_t_out;
                forward_ntt_en_reg <= 1;
                inverse_ntt_en_reg <= 0;
                state <= STATE_LOAD_B;
            end
        end

        STATE_LOAD_B: begin
            forward_ntt_en_reg <= 0;
            inverse_ntt_en_reg <= 0;
            state <= STATE_WAIT_TRANS_B;
        end

        STATE_WAIT_TRANS_B: begin
            if (forward_ntt_en_out) begin
                forward_b_results <= forward_ntt_t_out;
                inverse_ntt_en_reg <= 1;
                state <= STATE_LOAD_INV;
            end
        end

        STATE_LOAD_INV: begin
            inverse_ntt_en_reg <= 0;
            state <= STATE_WAIT_INV;
        end

        STATE_WAIT_INV: begin
            if (inverse_ntt_en_out) begin
                p_buffer <= inverse_ntt_t_out;
                en_out_reg <= 1;
                state <= STATE_IDLE;
            end
        end

        default: begin
            state <= STATE_IDLE;
            en_out_reg <= 0;
            forward_ntt_en_reg <= 0;
            inverse_ntt_en_reg <= 0;
        end
    endcase
end

endmodule
