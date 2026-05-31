module NTT # (
    parameter width = 10,
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

reg started, loading;
reg [width-1:0] load_counter;

reg [stages-1:0] ram_addr_a, ram_addr_b;
reg [width-1:0] ram_data_a, ram_data_b, ram_out_a, ram_out_b;
reg ram_write;

dual_port_ram # (
    .width(width),
    .size(n)
) ram (
    .clk(clk),
    .write(ram_write),
    .addr_a(ram_addr_a),
    .data_a(ram_data_a),
    .out_a(ram_out_a),
    .addr_b(ram_addr_b),
    .data_b(ram_data_b),
    .out_b(ram_out_b)
);

reg [width-1:0] bit_reverse_a_input, bit_reverse_b_input, bit_reverse_a_output, bit_reverse_b_output;

bit_reverser # (
    .width(stages)
) bra (
    .a(bit_reverse_a_input),
    .r(bit_reverse_a_output)
);

bit_reverser # (
    .width(stages)
) brb (
    .a(bit_reverse_b_input),
    .r(bit_reverse_b_output)
);

initial begin
    en_out = 0;
    t = 0;
    started = 0;
    loading = 0;
    load_counter = 0;
    ram_write = 0;
end

always @(posedge clk) begin
    if (en_in && !started) begin
        started <= 1;
        loading <= 1;
        load_counter <= 0;
        ram_addr_a <= 0;
        ram_data_a <= a[0];
        bit_reverse_b_input = 1;
        ram_addr_b <= bit_reverse_b_output;
        ram_data_b <= a[1];
        ram_write <= 1;
    end

    if(loading) begin
        if (load_counter == n-2) begin
            load_counter <= 0;
            loading <= 0;
            ram_write <= 0;
        end else begin
            bit_reverse_a_input = load_counter + 2;
            ram_addr_a <= bit_reverse_a_output;
            ram_data_a <= a[load_counter + 2];
            bit_reverse_b_input = load_counter + 3;
            ram_addr_b <= bit_reverse_b_output;
            ram_data_b <= a[load_counter + 3];
            load_counter <= load_counter + 2;
            ram_write <= 1;
        end
    end
end

endmodule