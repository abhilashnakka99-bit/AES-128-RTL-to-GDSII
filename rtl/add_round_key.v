// add_round_key.v
// STEP 4 of a round: XOR the state with the round key. That's it.
module add_round_key (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);
    assign state_out = state_in ^ round_key;
endmodule
