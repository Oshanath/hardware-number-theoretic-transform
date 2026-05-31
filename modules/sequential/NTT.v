module NTT # (
    parameter width = 16,
    parameter modulus = 17,
    parameter root = 9,
    parameter n = 8
) (
    input clk,
    input en_in,
    input [n-1:0][width-1:0] a,

    output reg en_out,
    output reg [n-1:0][width-1:0] t
);

localparam stages = $clog2(n);
localparam butterflies = n / 2;

localparam [1:0] STATE_IDLE = 2'd0;
localparam [1:0] STATE_LOAD = 2'd1;
localparam [1:0] STATE_PROCESS = 2'd2;
localparam [1:0] STATE_WRITEBACK = 2'd3;

// combinational
reg [width-1:0] ram_addr_a, ram_addr_b, ram_data_a, ram_data_b, ram_out_a, ram_out_b;
reg write;
reg [width-1:0] bra_input, brb_input, bra_output, brb_output;
reg [width-1:0] but_a, but_b, but_u, but_v;
reg [stages-1:0] twiddle_address;
wire [width-1:0] twiddle_factor;

// registers
reg [1:0] state;
reg [width-1:0] load_counter;
reg [width-1:0] stage_counter;
reg [width-1:0] butterfly_counter;
reg [n-1:0][width-1:0] butterfly_results;

initial begin
    state <= STATE_IDLE;
    load_counter <= 0;
    stage_counter <= 0;
    butterfly_counter <= 0;
    en_out = 0;
end

dual_port_ram # (
    .width(width),
    .size(n)
) ram (
    .clk(clk),
    .write(write),
    .addr_a(ram_addr_a),
    .data_a(ram_data_a),
    .out_a(ram_out_a),
    .addr_b(ram_addr_b),
    .data_b(ram_data_b),
    .out_b(ram_out_b)
);

bit_reverser # (
    .width(stages)
) bra (
    .a(bra_input),
    .r(bra_output)
);

bit_reverser # (
    .width(stages)
) brb (
    .a(brb_input),
    .r(brb_output)
);

ctb # (
    .width(width),
    .modulus(modulus)
) butterfly (
    .a(but_a),
    .b(but_b),
    .u(but_u),
    .v(but_v),
    .omega(twiddle_factor)
);

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

integer distance;
integer group_size;
integer group;
integer j;
integer twiddle_j;
integer left_index, right_index;
integer u_index, v_index;
integer rotated_addr_a, rotated_addr_b;

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

always @(*) begin : comb_logic
    bra_input = 0;
    brb_input = 0;
    ram_addr_a = 0;
    ram_addr_b = 0;
    ram_data_a = 0;
    ram_data_b = 0;
    write = 0;
    but_a = ram_out_a;
    but_b = ram_out_b;
    twiddle_address = 0;
    rotated_addr_a = 0;
    rotated_addr_b = 0;

    case (state)
        STATE_LOAD: begin
            bra_input = load_counter;
            ram_addr_a = bra_output;

            brb_input = load_counter + 1;
            ram_addr_b = brb_output;

            ram_data_a = a[load_counter];
            ram_data_b = a[load_counter + 1];

            write = 1;
        end

        STATE_WRITEBACK: begin
            rotated_addr_a = bit_rotate_index(load_counter, stage_counter + 1);
            rotated_addr_b = bit_rotate_index(load_counter + 1, stage_counter + 1);
            ram_addr_a = rotated_addr_a;
            ram_addr_b = rotated_addr_b;
            ram_data_a = butterfly_results[load_counter];
            ram_data_b = butterfly_results[load_counter + 1];

            write = 1;
        end

        STATE_PROCESS: begin
            distance = 1 << stage_counter;
            group_size = 1 << (stage_counter+1);

            if (butterfly_counter < butterflies) begin
                group = (butterfly_counter / distance) * group_size;
                j = butterfly_counter % distance;
                left_index = group + j;
                right_index = group + j + distance;
                u_index = butterfly_counter * 2;
                v_index = butterfly_counter * 2 + 1;
                ram_addr_a = left_index;
                ram_addr_b = right_index;
            end

            if (butterfly_counter > 0) begin
                twiddle_j = (butterfly_counter - 1) % distance;
                twiddle_address = twiddle_j * (n >> (stage_counter + 1));
            end
        end

        default: begin
        end
    endcase
end

always @(posedge clk) begin
    case (state)
        STATE_IDLE: begin
            en_out <= 0;

            if (en_in) begin
                state <= STATE_LOAD;
                load_counter <= 0;
                stage_counter <= 0;
                butterfly_counter <= 0;
            end
        end

        STATE_LOAD: begin
            if (load_counter == n-2) begin
                state <= STATE_PROCESS;
                load_counter <= 0;
            end else begin
                load_counter <= load_counter + 2;
            end
        end

        STATE_PROCESS: begin
            if (butterfly_counter > 0) begin
                butterfly_results[(butterfly_counter - 1) * 2] <= but_u;
                butterfly_results[((butterfly_counter - 1) * 2) + 1] <= but_v;
            end

            if (butterfly_counter == butterflies) begin
                state <= STATE_WRITEBACK;
                butterfly_counter <= 0;
                load_counter <= 0;
            end else begin
                butterfly_counter <= butterfly_counter + 1;
            end
        end

        STATE_WRITEBACK: begin
            if (stage_counter == stages-1) begin
                t[rotated_addr_a] <= butterfly_results[load_counter];
                t[rotated_addr_b] <= butterfly_results[load_counter + 1];
            end

            if (load_counter == n-2) begin
                load_counter <= 0;

                if (stage_counter == stages-1) begin
                    state <= STATE_IDLE;
                    stage_counter <= 0;
                    en_out <= 1;
                end else begin
                    state <= STATE_PROCESS;
                    stage_counter <= stage_counter + 1;
                end
            end else begin
                load_counter <= load_counter + 2;
            end
        end

        default: begin
            state <= STATE_IDLE;
            en_out <= 0;
        end
    endcase
end

endmodule
