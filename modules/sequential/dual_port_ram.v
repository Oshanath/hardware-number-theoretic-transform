module dual_port_ram # (
    parameter width = 16,
    parameter size = 8
) (
    input clk,

    input [$clog2(size)-1:0] addr_a,
    input [width-1:0] data_a,
    input read_a,
    output reg [width-1:0] out_a,

    input [$clog2(size)-1:0] addr_b,
    input [width-1:0] data_b,
    input read_b,
    output reg [width-1:0] out_b
);

reg [width-1:0] mem [size-1:0];

always @(posedge clk) begin
    if (!read_a) begin
        mem[addr_a] <= data_a;
    end

    if (!read_b) begin
        mem[addr_b] <= data_b;
    end

    out_a <= mem[addr_a];
    out_b <= mem[addr_b];
end

endmodule