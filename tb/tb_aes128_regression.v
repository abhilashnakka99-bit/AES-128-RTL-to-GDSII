`timescale 1ns/1ps
module tb_aes128_regression;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg start = 1'b0;
    reg [127:0] key = 128'b0;
    reg [127:0] plaintext = 128'b0;
    wire [127:0] ciphertext;
    wire busy, done;
    integer errors = 0;
    integer cycles;

    aes128_top dut (.clk(clk), .rst(rst), .start(start), .key(key), .plaintext(plaintext), .ciphertext(ciphertext), .busy(busy), .done(done));
    always #5 clk = ~clk;

    task fail;
        input [8*80-1:0] message;
        begin
            $display("FAIL: %0s", message);
            errors = errors + 1;
        end
    endtask

    task run_test;
        input [127:0] test_key;
        input [127:0] test_plaintext;
        input [127:0] expected;
        begin
            @(negedge clk);
            key = test_key; plaintext = test_plaintext; start = 1'b1;
            @(negedge clk);
            start = 1'b0;
            if (!busy) fail("busy was not asserted after accepted start");
            key = 128'hffffffffffffffffffffffffffffffff;
            plaintext = 128'hffffffffffffffffffffffffffffffff;
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;
            cycles = 0;
            while (!done && cycles < 12) begin
                if (!busy) fail("busy deasserted before done");
                @(negedge clk);
                cycles = cycles + 1;
            end
            if (!done) fail("timeout waiting for done");
            if (busy) fail("busy remained asserted with done");
            if (ciphertext !== expected) begin
                $display("FAIL: ciphertext=%h expected=%h", ciphertext, expected);
                errors = errors + 1;
            end else $display("PASS: ciphertext=%h", ciphertext);
            @(negedge clk);
            if (done) fail("done did not pulse for exactly one cycle");
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        rst = 1'b0;
        if (busy || done || ciphertext !== 128'b0) fail("synchronous reset state is incorrect");
        run_test(128'h000102030405060708090a0b0c0d0e0f, 128'h00112233445566778899aabbccddeeff, 128'h69c4e0d86a7b0430d8cdb78070b4c55a);
        run_test(128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3243f6a8885a308d313198a2e0370734, 128'h3925841d02dc09fbdc118597196a0b32);
        run_test(128'h00000000000000000000000000000000, 128'h00000000000000000000000000000000, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e);
        if (errors == 0) $display("REGRESSION PASSED");
        else $display("REGRESSION FAILED: %0d errors", errors);
        $finish;
    end
endmodule
