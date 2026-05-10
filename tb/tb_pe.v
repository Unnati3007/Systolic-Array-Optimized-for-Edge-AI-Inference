`timescale 1ns / 1ps
//=============================================================================
// tb_pe.v — Testbench for Processing Element
//=============================================================================

module tb_pe;
    parameter DATA_W = 8;
    parameter ACC_W  = 32;

    reg  clk, rst_n, weight_load;
    reg  signed [DATA_W-1:0] weight_in, act_in;
    wire signed [DATA_W-1:0] act_out;
    wire signed [ACC_W-1:0]  acc_out;

    // DUT
    pe #(.DATA_W(DATA_W), .ACC_W(ACC_W)) dut (
        .clk(clk), .rst_n(rst_n), .weight_load(weight_load),
        .weight_in(weight_in), .act_in(act_in),
        .act_out(act_out), .acc_in('0), .acc_out(acc_out)
    );

    initial clk = 0;
    always #2 clk = ~clk;  // 250 MHz

    task load_weight(input signed [DATA_W-1:0] w);
        @(negedge clk); weight_load = 1; weight_in = w;
        @(negedge clk); weight_load = 0;
    endtask

    integer errors = 0;

    initial begin
        rst_n = 0; weight_load = 0; weight_in = 0; act_in = 0;
        @(negedge clk); rst_n = 1;

        // Test 1: 3 * 4 = 12
        load_weight(8'sd3);
        @(negedge clk); act_in = 8'sd4;
        @(posedge clk); #1;
        if (acc_out !== 32'sd12) begin
            $display("FAIL test1: expected 12, got %0d", acc_out);
            errors++;
        end else $display("PASS test1: 3*4 = %0d", acc_out);

        // Test 2: negative weights
        load_weight(-8'sd5);
        @(negedge clk); act_in = 8'sd2;
        @(posedge clk); #1;
        if (acc_out !== -32'sd10) begin
            $display("FAIL test2: expected -10, got %0d", acc_out);
            errors++;
        end else $display("PASS test2: -5*2 = %0d", acc_out);

        // Test 3: activation passes through
        if (act_out !== 8'sd2) begin
            $display("FAIL test3: act_out expected 2, got %0d", act_out);
            errors++;
        end else $display("PASS test3: act_out = %0d", act_out);

        if (errors == 0) $display("\nAll PE tests PASSED");
        else $display("\n%0d test(s) FAILED", errors);
        $finish;
    end
endmodule
