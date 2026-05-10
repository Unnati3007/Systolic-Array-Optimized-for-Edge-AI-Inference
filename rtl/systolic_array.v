`timescale 1ns / 1ps
//=============================================================================
// systolic_array.v — 16x16 Systolic Array
//
// Instantiates a 16x16 grid of PE modules.
// Activations stream in from the left column.
// Partial sums accumulate downward; final results leave the bottom row.
//=============================================================================

module systolic_array #(
    parameter SIZE   = 16,
    parameter DATA_W = 8,
    parameter ACC_W  = 32
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          weight_load,

    // Weight inputs — one per column (broadcast down each column)
    input  wire signed [DATA_W-1:0]      weights [0:SIZE-1][0:SIZE-1],

    // Activation inputs — one per row, streamed in each cycle
    input  wire signed [DATA_W-1:0]      act_in  [0:SIZE-1],

    // Output — accumulated results, one per column
    output wire signed [ACC_W-1:0]       result  [0:SIZE-1]
);

    // Internal wires: act[row][col], acc[row][col]
    wire signed [DATA_W-1:0] act_wire [0:SIZE-1][0:SIZE];
    wire signed [ACC_W-1:0]  acc_wire [0:SIZE][0:SIZE-1];

    genvar r, c;
    generate
        for (r = 0; r < SIZE; r++) begin : ROW
            // Connect external activations to the leftmost column
            assign act_wire[r][0] = act_in[r];

            // Top row receives zero partial sums
            for (c = 0; c < SIZE; c++) begin : COL
                if (r == 0)
                    assign acc_wire[0][c] = '0;

                pe #(.DATA_W(DATA_W), .ACC_W(ACC_W)) u_pe (
                    .clk         (clk),
                    .rst_n       (rst_n),
                    .weight_load (weight_load),
                    .weight_in   (weights[r][c]),
                    .act_in      (act_wire[r][c]),
                    .act_out     (act_wire[r][c+1]),
                    .acc_in      (acc_wire[r][c]),
                    .acc_out     (acc_wire[r+1][c])
                );
            end
        end
    endgenerate

    // Bottom row outputs are the final results
    for (genvar col = 0; col < SIZE; col++) begin : OUT
        assign result[col] = acc_wire[SIZE][col];
    end

endmodule
