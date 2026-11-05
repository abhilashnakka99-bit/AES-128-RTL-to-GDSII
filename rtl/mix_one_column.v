// mix_one_column.v
// MixColumns on ONE column (4 bytes a,b,c,d).
// Textbook matrix, written exactly as it appears in the AES spec:
//
//   out0 = 2*a  ^ 3*b  ^ 1*c  ^ 1*d
//   out1 = 1*a  ^ 2*b  ^ 3*c  ^ 1*d
//   out2 = 1*a  ^ 1*b  ^ 2*c  ^ 3*d
//   out3 = 3*a  ^ 1*b  ^ 1*c  ^ 2*d
//
// "+" is XOR in AES. "*2" and "*3" are the special functions below.
module mix_one_column (
    input  wire [31:0] col_in,
    output wire [31:0] col_out
);
    // *2 : shift left by 1. If a 1 fell off the top, fix it by XORing 0x1b.
    function [7:0] mul2;
        input [7:0] x;
        begin
            if (x[7] == 1'b1)
                mul2 = {x[6:0], 1'b0} ^ 8'h1b;
            else
                mul2 = {x[6:0], 1'b0};
        end
    endfunction

    // *3 = (*2) + (*1)  ->  mul2(x) XOR x
    function [7:0] mul3;
        input [7:0] x;
        begin
            mul3 = mul2(x) ^ x;
        end
    endfunction

    wire [7:0] a, b, c, d;
    assign {a, b, c, d} = col_in;

    wire [7:0] out0 = mul2(a) ^ mul3(b) ^ c       ^ d;
    wire [7:0] out1 = a       ^ mul2(b) ^ mul3(c) ^ d;
    wire [7:0] out2 = a       ^ b       ^ mul2(c) ^ mul3(d);
    wire [7:0] out3 = mul3(a) ^ b       ^ c       ^ mul2(d);

    assign col_out = {out0, out1, out2, out3};
endmodule
