module bit_right_rotator # (
    parameter width = 16,
    parameter bits = 3
) (
    input [width-1:0] a,
    output [width-1:0] r
);

generate
    for(genvar i = 0; i < bits-1; i = i + 1) begin
        assign r[i] = a[i+1];
    end
    assign r[bits-1] = a[0];
    for(genvar i = bits; i < width; i = i + 1) begin
        assign r[i] = a[i];
    end
endgenerate

endmodule