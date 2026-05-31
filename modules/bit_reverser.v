module bit_reverser # (
    parameter width = 3
) (
    input [width-1:0] a,
    output [width-1:0] r
);

generate
    for (genvar i = 0; i < width; i = i + 1) begin
        assign r[width-1-i] = a[i];
    end
endgenerate

endmodule