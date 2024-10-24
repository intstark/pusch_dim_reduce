`timescale 1ns/1ps


`timescale 1ns/1ps
`define CLOCK_PERIOD 10.0
`define SIM_ENDS_TIME 60000


module codeword_tb;


    // Parameters
    localparam ANTS = 32;
    localparam WIDTH = 32;
    localparam DEPTH = 64;

    // Signal declarations
    reg i_clk;
    reg i_reset;
    reg i_enable;

    wire [DEPTH-1:0][WIDTH*ANTS-1:0] o_cw_even;
    wire [DEPTH-1:0][WIDTH*ANTS-1:0] o_cw_odd;
    wire o_tvalid;

    // Instantiate the Unit Under Test (UUT)
    code_word_rev #(
        .ANTS(ANTS),
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_enable(i_enable),
        .o_cw_even(o_cw_even),
        .o_cw_odd(o_cw_odd),
        .o_tvalid(o_tvalid)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signal
        i_reset = 1;
        i_enable = 0;

        // Wait for two clock cycles
        @(posedge i_clk);
        @(posedge i_clk);

        // Test 1: Reset the module
        // Ensure that outputs are in reset state
        i_reset = 1;
        @(posedge i_clk);
        i_reset = 0;

        // Test 2: Enable functionality
        i_enable = 1;


    end

endmodule