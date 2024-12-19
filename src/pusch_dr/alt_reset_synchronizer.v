module alt_reset_synchronizer
#(
    //The purpose of the wrapper provides flexibility for future modification
    parameter depth     = 2, // This value must be >= 2 !
    parameter rst_value = 0
 )
 (
    input    clk,
    input    reset_n,
    output   rst_out
 );

    altera_std_synchronizer_nocut #(.depth(depth),.rst_value(rst_value)) inst_uflex_std_synchronizer_nocut (.clk(clk),.reset_n(reset_n),.din(~rst_value[0]),.dout(rst_out));

endmodule

