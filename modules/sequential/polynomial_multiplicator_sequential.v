module polynomial_multiplicator_sequential # (
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
localparam STATE_WAIT_TRANS_A = 3'd1;
localparam STATE_WAIT_TRANS_B = 3'd2;
localparam STATE_MULT = 3'd3;
localparam STATE_WAIT_INV_TRANS = 3'd4;

//state
reg [2:0] state;
reg [width-1:0] mult_counter;
reg [n-1:0][width-1:0] forward_a_results, forward_b_results, mult_results;
reg en_out_reg, inverse_ntt_en_reg;

// combinational
wire forward_ntt_a_en_in, forward_ntt_a_en_out;
wire [n-1:0][width-1:0] forward_ntt_a_a_in, forward_ntt_a_t_out;
wire forward_ntt_b_en_in, forward_ntt_b_en_out;
wire [n-1:0][width-1:0] forward_ntt_b_a_in, forward_ntt_b_t_out;
wire inverse_ntt_clk_in, inverse_ntt_en_in, inverse_ntt_en_out;
wire [n-1:0][width-1:0] inverse_ntt_a_in, inverse_ntt_t_out;
wire [width-1:0] mult_a_in, mult_b_in, mult_p_out;

assign forward_ntt_a_en_in = en_in;
assign forward_ntt_b_en_in = forward_ntt_a_en_out;
assign mult_a_in = forward_a_results[mult_counter];
assign mult_b_in = forward_b_results[mult_counter];
assign inverse_ntt_a_in = mult_results;
assign p = inverse_ntt_t_out;
assign en_out = en_out_reg;
assign forward_ntt_a_a_in = a;
assign forward_ntt_b_a_in = b;
assign inverse_ntt_en_in = inverse_ntt_en_reg;

NTT # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n),
    .n_inverse(n_inverse)
) forward_ntt_a (
    .clk(clk),
    .en_in(forward_ntt_a_en_in),
    .inverse_(0),
    .a(forward_ntt_a_a_in),
    .en_out(forward_ntt_a_en_out),
    .t(forward_ntt_a_t_out)
);

NTT # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n),
    .n_inverse(n_inverse)
) forward_ntt_b (
    .clk(clk),
    .en_in(forward_ntt_b_en_in),
    .inverse_(0),
    .a(forward_ntt_b_a_in),
    .en_out(forward_ntt_b_en_out),
    .t(forward_ntt_b_t_out)
);

NTT # (
    .width(width),
    .modulus(modulus),
    .root(root),
    .n(n),
    .n_inverse(n_inverse)
) inverse_ntt (
    .clk(clk),
    .en_in(inverse_ntt_en_in),
    .inverse_(1),
    .a(inverse_ntt_a_in),
    .en_out(inverse_ntt_en_out),
    .t(inverse_ntt_t_out)
);

modular_multiplicator # (
    .width(width),
    .modulus(modulus)
) mm (
    .a(mult_a_in),
    .b(mult_b_in),
    .p(mult_p_out)
);

initial begin
    state <= 0;
    mult_counter <= 0;
    inverse_ntt_en_reg <= 0;
end

always @(posedge clk) begin
    case(state)
        STATE_IDLE: begin
            en_out_reg <= 0;
            if (en_in) begin
                state <= STATE_WAIT_TRANS_A;
            end
        end

        STATE_WAIT_TRANS_A: begin
            if (forward_ntt_a_en_out) begin
                forward_a_results <= forward_ntt_a_t_out;
                state <= STATE_WAIT_TRANS_B;
            end
        end

        STATE_WAIT_TRANS_B: begin
            if (forward_ntt_b_en_out) begin
                forward_b_results <= forward_ntt_b_t_out;
                state <= STATE_MULT;
            end
        end
        
        STATE_MULT: begin
            mult_results[mult_counter] = mult_p_out;
            if (mult_counter == n-1) begin
                state <= STATE_WAIT_INV_TRANS;
                mult_counter <= 0;
                inverse_ntt_en_reg <= 1;
            end else begin
                mult_counter <= mult_counter + 1;
            end
        end

        STATE_WAIT_INV_TRANS: begin
            inverse_ntt_en_reg <= 0;
            if (inverse_ntt_en_out) begin
                state <= STATE_IDLE;
                en_out_reg <= 1;
            end
        end
    endcase
end

endmodule