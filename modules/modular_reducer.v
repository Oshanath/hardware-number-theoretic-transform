module modular_reducer # (     
    parameter width = 10,
    parameter [width-1:0] modulus = 10'd17
)(
    input [width-1:0] x,
    output [width-1:0] xmodn
);

localparam [2*width:0] four_to_k = {1'b1, {(2*width){1'b0}}};
localparam [2*width:0] r = four_to_k / modulus;

wire [width-1:0] xr_over_4_to_k;
assign xr_over_4_to_k = (x * r) >> (2*width);

wire [width-1:0] t;
assign t = x - xr_over_4_to_k * modulus;

assign xmodn = t < modulus ? t : t - modulus;

endmodule
