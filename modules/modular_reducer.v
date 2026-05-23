module modular_reducer # (     
    parameter width = 10,
    parameter [width-1:0] modulus = 10'd17
)(
    input [width-1:0] x,
    output [width-1:0] xmodn
);

localparam [2*width:0] four_to_k = {1'b1, {(2*width){1'b0}}};
localparam [2*width:0] r = four_to_k / modulus;

wire [(4*width)-1:0] x_wide;
wire [(4*width)-1:0] r_wide;
wire [(4*width)-1:0] xr;
wire [(4*width)-1:0] xr_over_4_to_k;

assign x_wide = x;
assign r_wide = r;
assign xr = x_wide * r_wide;
assign xr_over_4_to_k = xr >> (2*width);

wire [(4*width)-1:0] modulus_wide;
wire [(4*width)-1:0] t;
wire [(4*width)-1:0] t_minus_modulus;

assign modulus_wide = modulus;
assign t = x_wide - (xr_over_4_to_k * modulus_wide);
assign t_minus_modulus = t - modulus_wide;

assign xmodn = t < modulus_wide ? t[width-1:0] : t_minus_modulus[width-1:0];

endmodule
