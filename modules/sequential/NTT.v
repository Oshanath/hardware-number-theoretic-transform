module NTT # (
    parameter width = 16,
    parameter modulus = 17,
    parameter root = 9,
    parameter n = 8,
    parameter n_inverse = 15
) (
    input clk,
    input en_in,
    input inverse_,
    input [width-1:0] a,

    output reg en_out,
    output reg [width-1:0] t
);

localparam stages = $clog2(n);
localparam butterflies = n / 2;

localparam [2:0] STATE_IDLE = 3'd0;
localparam [2:0] STATE_LOAD = 3'd1;
localparam [2:0] STATE_PROCESS = 3'd2;
localparam [2:0] STATE_WRITEBACK = 3'd3;
localparam [2:0] STATE_OUTPUT = 3'd4;

// combinational
reg [width-1:0] ram_addr_a, ram_addr_b, ram_data_a, ram_data_b, ram_out_a, ram_out_b;
reg write;
reg [width-1:0] bra_input, brb_input, bra_output, brb_output;
reg [width-1:0] ctb_a, ctb_b, ctb_u, ctb_v;
reg [width-1:0] gsb_a, gsb_b, gsb_u, gsb_v;
reg [stages-1:0] twiddle_address;
wire [width-1:0] twiddle_factor;

// registers
reg [2:0] state;
reg inverse;
reg [width-1:0] load_counter;
reg [width-1:0] output_counter;
reg [width-1:0] stage_counter;
reg [width-1:0] butterfly_counter;
reg [n-1:0][width-1:0] butterfly_results;
reg [n-1:0][width-1:0] t_results;

initial begin
    state <= STATE_IDLE;
    load_counter <= 0;
    output_counter <= 0;
    stage_counter <= 0;
    butterfly_counter <= 0;
    inverse <= 0;
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
    .a(ctb_a),
    .b(ctb_b),
    .u(ctb_u),
    .v(ctb_v),
    .omega(twiddle_factor)
);

gsb # (
    .width(width),
    .modulus(modulus)
) inverse_butterfly (
    .u(gsb_u),
    .v(gsb_v),
    .omega(twiddle_factor),
    .a(gsb_a),
    .b(gsb_b)
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
    ctb_a = ram_out_a;
    ctb_b = ram_out_b;
    gsb_u = ram_out_a;
    gsb_v = ram_out_b;
    twiddle_address = 0;
    rotated_addr_a = 0;
    rotated_addr_b = 0;

    bra_input = load_counter;
    brb_input = load_counter + 1;

    case (state)
        STATE_IDLE: begin
            if (en_in) begin
                if(inverse_) begin
                    ram_addr_a = 0;
                end else begin
                    ram_addr_a = bra_output;
                end

                ram_addr_b = ram_addr_a;
                ram_data_a = a;
                ram_data_b = a;
                write = 1;
            end
        end

        STATE_LOAD: begin
            if (en_in) begin
                if(inverse) begin
                    ram_addr_a = load_counter;
                end else begin
                    ram_addr_a = bra_output;
                end

                ram_addr_b = ram_addr_a;
                ram_data_a = a;
                ram_data_b = a;
                write = 1;
            end
        end

        STATE_PROCESS: begin
            if(inverse) begin
                distance = 1 << (stages - 1 - stage_counter);
                group_size = 1 << (stages - stage_counter);
            end else begin
                distance = 1 << stage_counter;
                group_size = 1 << (stage_counter+1);
            end

            if (butterfly_counter < butterflies) begin
                group = (butterfly_counter / distance) * group_size;
                j = butterfly_counter % distance;
                left_index = group + j;
                right_index = group + j + distance;
                u_index = butterfly_counter * 2;
                v_index = butterfly_counter * 2 + 1;
                if (inverse) begin
                    rotated_addr_a = bit_rotate_index(u_index, stages - stage_counter);
                    rotated_addr_b = bit_rotate_index(v_index, stages - stage_counter);
                    ram_addr_a = rotated_addr_a;
                    ram_addr_b = rotated_addr_b;
                end else begin
                    ram_addr_a = left_index;
                    ram_addr_b = right_index;
                end
            end

            if (butterfly_counter > 0) begin
                twiddle_j = (butterfly_counter - 1) % distance;
                if (inverse) begin
                    twiddle_address = n - twiddle_j * (n >> (stages - stage_counter));
                end else begin
                    twiddle_address = twiddle_j * (n >> (stage_counter + 1));
                end
            end
        end

        STATE_WRITEBACK: begin
            ram_data_a = butterfly_results[load_counter];
            ram_data_b = butterfly_results[load_counter + 1];
            if(inverse) begin
                distance = 1 << (stages - 1 - stage_counter);
                group_size = 1 << (stages - stage_counter);
                group = ((load_counter / 2) / distance) * group_size;
                j = (load_counter / 2) % distance;
                left_index = group + j;
                right_index = group + j + distance;
                ram_addr_a = left_index;
                ram_addr_b = right_index;
            end else begin
                rotated_addr_a = bit_rotate_index(load_counter, stage_counter + 1);
                rotated_addr_b = bit_rotate_index(load_counter + 1, stage_counter + 1);
                ram_addr_a = rotated_addr_a;
                ram_addr_b = rotated_addr_b;
            end

            write = 1;
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
                inverse <= inverse_;
                load_counter <= 1;
                output_counter <= 0;
                stage_counter <= 0;
                butterfly_counter <= 0;
            end
        end

        STATE_LOAD: begin
            if (en_in) begin
                if (load_counter == n-1) begin
                    state <= STATE_PROCESS;
                    load_counter <= 0;
                end else begin
                    load_counter <= load_counter + 1;
                end
            end
        end

        STATE_PROCESS: begin
            if (butterfly_counter > 0) begin
                if (inverse) begin
                    butterfly_results[(butterfly_counter - 1) * 2] <= gsb_a;
                    butterfly_results[((butterfly_counter - 1) * 2) + 1] <= gsb_b;
                end else begin
                    butterfly_results[(butterfly_counter - 1) * 2] <= ctb_u;
                    butterfly_results[((butterfly_counter - 1) * 2) + 1] <= ctb_v;
                end 
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
                if (inverse) begin
                    t_results[load_counter] <= (n_inverse * butterfly_results[bra_output]) % modulus;
                    t_results[load_counter + 1] <= (n_inverse * butterfly_results[brb_output]) % modulus;
                end else begin
                    t_results[rotated_addr_a] <= butterfly_results[load_counter];
                    t_results[rotated_addr_b] <= butterfly_results[load_counter + 1];
                end
            end

            if (load_counter == n-2) begin
                load_counter <= 0;

                if (stage_counter == stages-1) begin
                    state <= STATE_OUTPUT;
                    stage_counter <= 0;
                    output_counter <= 0;
                end else begin
                    state <= STATE_PROCESS;
                    stage_counter <= stage_counter + 1;
                end
            end else begin
                load_counter <= load_counter + 2;
            end
        end

        STATE_OUTPUT: begin
            t <= t_results[output_counter];
            en_out <= 1;

            if (output_counter == n-1) begin
                state <= STATE_IDLE;
                output_counter <= 0;
            end else begin
                output_counter <= output_counter + 1;
            end
        end

        default: begin
            state <= STATE_IDLE;
            en_out <= 0;
        end
    endcase
end

endmodule
