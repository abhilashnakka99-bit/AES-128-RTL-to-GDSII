// key_expansion.v
// Makes the NEXT round key from the CURRENT round key.
//   round_num = which round we are about to do (1..10), used to pick rcon.
//
// Split the 128-bit key into four 32-bit words:  w0 | w1 | w2 | w3
// Recipe:
//   g       = SubWord( RotWord(w3) ) with rcon XORed into its first byte
//   new_w0  = w0 ^ g
//   new_w1  = w1 ^ new_w0
//   new_w2  = w2 ^ new_w1
//   new_w3  = w3 ^ new_w2
module key_expansion (
    input  wire [127:0] key_in,
    input  wire [3:0]   round_num,
    output wire [127:0] key_out
);
    // ---- split the key into words ----
    wire [31:0] w0 = key_in[127:96];
    wire [31:0] w1 = key_in[95:64];
    wire [31:0] w2 = key_in[63:32];
    wire [31:0] w3 = key_in[31:0];

    // ---- RotWord: move the first byte of w3 to the end ----
    //      bytes (b0 b1 b2 b3) -> (b1 b2 b3 b0)
    wire [31:0] rot_w3 = {w3[23:0], w3[31:24]};

    // ---- SubWord: S-box on each of the 4 bytes ----
    wire [31:0] sub_w3;
    sbox sw0 (.data_in(rot_w3[31:24]), .data_out(sub_w3[31:24]));
    sbox sw1 (.data_in(rot_w3[23:16]), .data_out(sub_w3[23:16]));
    sbox sw2 (.data_in(rot_w3[15:8]),  .data_out(sub_w3[15:8]));
    sbox sw3 (.data_in(rot_w3[7:0]),   .data_out(sub_w3[7:0]));

    // ---- round constant (a different value each round) ----
    reg [7:0] rcon;
    always @(*) begin
        case (round_num)
            4'd1:    rcon = 8'h01;
            4'd2:    rcon = 8'h02;
            4'd3:    rcon = 8'h04;
            4'd4:    rcon = 8'h08;
            4'd5:    rcon = 8'h10;
            4'd6:    rcon = 8'h20;
            4'd7:    rcon = 8'h40;
            4'd8:    rcon = 8'h80;
            4'd9:    rcon = 8'h1b;
            4'd10:   rcon = 8'h36;
            default: rcon = 8'h00;
        endcase
    end

    // rcon only touches the FIRST byte of the word
    wire [31:0] g = sub_w3 ^ {rcon, 24'h000000};

    // ---- build the new words ----
    wire [31:0] new_w0 = w0 ^ g;
    wire [31:0] new_w1 = w1 ^ new_w0;
    wire [31:0] new_w2 = w2 ^ new_w1;
    wire [31:0] new_w3 = w3 ^ new_w2;

    assign key_out = {new_w0, new_w1, new_w2, new_w3};
endmodule
