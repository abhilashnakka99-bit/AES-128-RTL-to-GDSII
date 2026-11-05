// aes_round.v
// One full AES round = SubBytes -> ShiftRows -> MixColumns -> AddRoundKey.
// In the last round (is_last = 1) MixColumns is skipped.
module aes_round (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    input  wire         is_last,
    output wire [127:0] state_out
);
    wire [127:0] after_sub;
    wire [127:0] after_shift;
    wire [127:0] after_mix;
    wire [127:0] before_key;

    sub_bytes   u_sub   (.state_in(state_in),    .state_out(after_sub));
    shift_rows  u_shift (.state_in(after_sub),   .state_out(after_shift));
    mix_columns u_mix   (.state_in(after_shift), .state_out(after_mix));

    // last round: skip MixColumns
    assign before_key = is_last ? after_shift : after_mix;

    add_round_key u_ark (.state_in(before_key), .round_key(round_key), .state_out(state_out));
endmodule
