module n_bit_multiplier #(
    parameter width = 3
)(
    input [width - 1:0] a,
    input [width - 1:0] b,
    output [width - 1:0] p,
    output overflow
);

    generate
        wire[width-1:0][width-1:0] carries;
        for (genvar i = 0; i < width - 1; i = i + 1) begin
            wire [i:0] products;
            for (genvar j = 0; j < i + 1; j = j + 1) begin
                assign products[j] = a[i - j] & b[j];
            end
            localparam int adders = i;
            if (adders == 0) begin
                assign p[i] = products[0];
            end else begin
                wire [adders:0] sums;
                assign sums[0] = products[0];
                for (genvar k = 0; k < adders; k = k + 1) begin
                    wire cin_local;
                    if (k == i-1) begin
                        assign cin_local = 1'b0;
                    end else begin
                        assign cin_local = carries[i][k];
                    end
                    full_adder fa(
                        .a(sums[k]),
                        .b(products[k+1]),
                        .cin(cin_local),
                        .s(sums[k+1]),
                        .cout(carries[i+1][k])
                    );
                end
                assign p[i] = sums[adders];
            end
        end
    endgenerate

endmodule