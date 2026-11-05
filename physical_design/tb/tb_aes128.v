`timescale 1ns/1ps
module tb_aes128;
    reg          clk = 0;
    reg          rst = 1;
    reg          start = 0;
    reg  [127:0] key, plaintext;
    wire [127:0] ciphertext;
    wire         busy, done;
    integer      errors = 0;

    aes128_top dut (.clk(clk), .rst(rst), .start(start), .key(key),
                    .plaintext(plaintext), .ciphertext(ciphertext),
                    .busy(busy), .done(done));

    always #5 clk = ~clk;

    task run_test;
        input [127:0] k;
        input [127:0] p;
        input [127:0] expected;
        begin
            @(negedge clk);
            key = k; plaintext = p; start = 1;
            @(negedge clk);
            start = 0;
            while (!done) @(negedge clk);
            if (ciphertext === expected)
                $display("PASS  ct = %h", ciphertext);
            else begin
                $display("FAIL  ct = %h  expected = %h", ciphertext, expected);
                errors = errors + 1;
            end
            @(negedge clk);
        end
    endtask

    initial begin
        #22 rst = 0;
        // FIPS-197 Appendix C.1
        run_test(128'h000102030405060708090a0b0c0d0e0f,
                 128'h00112233445566778899aabbccddeeff,
                 128'h69c4e0d86a7b0430d8cdb78070b4c55a);
        // FIPS-197 Appendix B
        run_test(128'h2b7e151628aed2a6abf7158809cf4f3c,
                 128'h3243f6a8885a308d313198a2e0370734,
                 128'h3925841d02dc09fbdc118597196a0b32);
        // all-zero key and plaintext
        run_test(128'h0, 128'h0,
                 128'h66e94bd4ef8a2c3b884cfa59ca342b2e);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
