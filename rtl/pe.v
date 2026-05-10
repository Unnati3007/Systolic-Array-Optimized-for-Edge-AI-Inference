`timescale 1ns / 1ps
//=============================================================================
// pe.v — Processing Element for Systolic Array
//
// Each PE performs one 8-bit MAC per clock cycle:
//   acc_out = acc_in + (weight * activation)
//
// Weight-stationary: weight is loaded once via weight_load and held.
// Activation flows right (passed to next PE in the row).
// Partial sum flows down (accumulated by next PE in the column).
//=============================================================================

module pe #(
    parameter DATA_W = 8,    // INT8 activation/weight width
    parameter ACC_W  = 32    // 32-bit accumulator (prevents overflow)
)(
    input  wire                 clk,
    input  wire                 rst_n,

    // Weight loading (done once before inference)
    input  wire                 weight_load,
    input  wire signed [DATA_W-1:0] weight_in,

    // Data flow
    input  wire signed [DATA_W-1:0] act_in,    // activation from left
    output reg  signed [DATA_W-1:0] act_out,   // pass to right neighbour

    input  wire signed [ACC_W-1:0]  acc_in,    // partial sum from above
    output reg  signed [ACC_W-1:0]  acc_out    // partial sum to below
);

    reg signed [DATA_W-1:0] weight;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight   <= '0;
            act_out  <= '0;
            acc_out  <= '0;
        end else begin
            // Latch weight when loading
            if (weight_load)
                weight <= weight_in;

            // Pipeline: pass activation to the right
            act_out <= act_in;

            // MAC: accumulate partial sum
            acc_out <= acc_in + (weight * act_in);
        end
    end

endmodule
