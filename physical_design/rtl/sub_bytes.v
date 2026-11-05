// sub_bytes.v
// STEP 1 of a round: run every one of the 16 state bytes through the S-box.
// No byte moves position here, each byte is just replaced.
module sub_bytes (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    // Byte 0 is the leftmost byte [127:120], byte 15 is the rightmost [7:0].
    wire [7:0] s0,  s1,  s2,  s3,  s4,  s5,  s6,  s7;
    wire [7:0] s8,  s9,  s10, s11, s12, s13, s14, s15;
    wire [7:0] t0,  t1,  t2,  t3,  t4,  t5,  t6,  t7;
    wire [7:0] t8,  t9,  t10, t11, t12, t13, t14, t15;

    assign {s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15} = state_in;

    sbox u0  (.data_in(s0),  .data_out(t0));
    sbox u1  (.data_in(s1),  .data_out(t1));
    sbox u2  (.data_in(s2),  .data_out(t2));
    sbox u3  (.data_in(s3),  .data_out(t3));
    sbox u4  (.data_in(s4),  .data_out(t4));
    sbox u5  (.data_in(s5),  .data_out(t5));
    sbox u6  (.data_in(s6),  .data_out(t6));
    sbox u7  (.data_in(s7),  .data_out(t7));
    sbox u8  (.data_in(s8),  .data_out(t8));
    sbox u9  (.data_in(s9),  .data_out(t9));
    sbox u10 (.data_in(s10), .data_out(t10));
    sbox u11 (.data_in(s11), .data_out(t11));
    sbox u12 (.data_in(s12), .data_out(t12));
    sbox u13 (.data_in(s13), .data_out(t13));
    sbox u14 (.data_in(s14), .data_out(t14));
    sbox u15 (.data_in(s15), .data_out(t15));

    assign state_out = {t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15};
endmodule
