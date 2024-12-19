module cmpy_mult_s16xs16 (
		input  wire [15:0] dataa_real,  //  dataa_real.dataa_real
		input  wire [15:0] dataa_imag,  //  dataa_imag.dataa_imag
		input  wire [15:0] datab_real,  //  datab_real.datab_real
		input  wire [15:0] datab_imag,  //  datab_imag.datab_imag
		output wire [31:0] result_real, // result_real.result_real
		output wire [31:0] result_imag, // result_imag.result_imag
		input  wire        clock        //       clock.clk
	);
endmodule

