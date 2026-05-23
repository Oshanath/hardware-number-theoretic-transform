module twiddle_rom # (
    parameter width = 10,
    parameter modulus = 17,
    parameter root = 9,
    parameter n = 8,
    parameter rom_width = 3
)(
    input [rom_width-1:0] address,
    output [width-1:0] twiddle
);

reg [width-1:0] rom [n-1:0];

integer i;

initial begin
    rom[0] = 1;
    for (i = 1; i < n; i = i + 1) begin
        rom[i] = (rom[i-1] * root) % modulus;
    end
end

assign twiddle = rom[address];

endmodule