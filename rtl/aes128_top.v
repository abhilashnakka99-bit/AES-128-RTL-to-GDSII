// aes128_top.v
// Top module: ties everything together. Does ONE round per clock cycle.
//
//   cycle 0   (start)    : state = plaintext ^ key         (initial AddRoundKey)
//   cycle 1..10 (RUN)    : state = round(state, next_key)  (10 rounds)
//   cycle 11  (DONE)     : done = 1 for one cycle, ciphertext is valid
//
// Usage: put key + plaintext on the inputs, pulse start for 1 clock while idle.
// Wait for done = 1, then read ciphertext.
module aes128_top (
    input  wire         clk,
    input  wire         rst,          // synchronous, active high
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] plaintext,
    output wire [127:0] ciphertext,   // valid when done = 1 (holds until next start)
    output wire         busy,
    output wire         done
);
    // ---------- FSM states ----------
    localparam IDLE = 2'd0;
    localparam RUN  = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0]   fsm;
    reg [127:0] state_reg;    // the 4x4 data grid
    reg [127:0] key_reg;      // the CURRENT round key
    reg [3:0]   round_cnt;    // which round we are about to do (1..10)

    // ---------- datapath ----------
    wire [127:0] init_state;     // plaintext ^ key
    wire [127:0] next_key;       // round key for the round we're doing now
    wire [127:0] next_state;     // result of this round
    wire         is_last = (round_cnt == 4'd10);

    // initial AddRoundKey (before round 1)
    add_round_key u_init (.state_in(plaintext), .round_key(key), .state_out(init_state));

    // make the key for this round from the previous one
    key_expansion u_key (.key_in(key_reg), .round_num(round_cnt), .key_out(next_key));

    // do one round
    aes_round u_round (.state_in(state_reg), .round_key(next_key),
                       .is_last(is_last), .state_out(next_state));

    // ---------- control ----------
    always @(posedge clk) begin
        if (rst) begin
            fsm       <= IDLE;
            state_reg <= 128'b0;
            key_reg   <= 128'b0;
            round_cnt <= 4'd0;
        end else begin
            case (fsm)
                IDLE: begin
                    if (start) begin
                        state_reg <= init_state;
                        key_reg   <= key;
                        round_cnt <= 4'd1;
                        fsm       <= RUN;
                    end
                end

                RUN: begin
                    state_reg <= next_state;
                    key_reg   <= next_key;
                    if (is_last) begin
                        fsm <= DONE;
                    end else begin
                        round_cnt <= round_cnt + 4'd1;
                    end
                end

                DONE: begin
                    fsm <= IDLE;
                end

                default: fsm <= IDLE;
            endcase
        end
    end

    assign busy       = (fsm == RUN);
    assign done       = (fsm == DONE);
    assign ciphertext = state_reg;
endmodule
