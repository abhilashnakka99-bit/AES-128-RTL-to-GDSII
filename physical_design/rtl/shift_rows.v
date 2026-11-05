// shift_rows.v
// STEP 2 of a round: rotate the rows of the 4x4 grid. Pure wiring, no logic.
//
// The 16 bytes are laid out in the grid COLUMN by COLUMN:
//
//        col0 col1 col2 col3
//  row0:   s0   s4   s8   s12      -> not shifted
//  row1:   s1   s5   s9   s13      -> rotate left by 1
//  row2:   s2   s6   s10  s14      -> rotate left by 2
//  row3:   s3   s7   s11  s15      -> rotate left by 3
//
// After shifting:
//        col0 col1 col2 col3
//  row0:   s0   s4   s8   s12
//  row1:   s5   s9   s13  s1
//  row2:   s10  s14  s2   s6
//  row3:   s15  s3   s7   s11
//
// Reading the result column by column gives the output byte order below.
module shift_rows (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    wire [7:0] s0,  s1,  s2,  s3,  s4,  s5,  s6,  s7;
    wire [7:0] s8,  s9,  s10, s11, s12, s13, s14, s15;

    assign {s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15} = state_in;

    assign state_out = { s0,  s5,  s10, s15,    // new column 0
                         s4,  s9,  s14, s3,     // new column 1
                         s8,  s13, s2,  s7,     // new column 2
                         s12, s1,  s6,  s11 };  // new column 3
endmodule
