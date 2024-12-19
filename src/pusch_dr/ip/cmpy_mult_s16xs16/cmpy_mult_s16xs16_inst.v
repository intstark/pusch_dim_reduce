	cmpy_mult_s16xs16 u0 (
		.dataa_real  (_connected_to_dataa_real_),  //   input,  width = 16,  dataa_real.dataa_real
		.dataa_imag  (_connected_to_dataa_imag_),  //   input,  width = 16,  dataa_imag.dataa_imag
		.datab_real  (_connected_to_datab_real_),  //   input,  width = 16,  datab_real.datab_real
		.datab_imag  (_connected_to_datab_imag_),  //   input,  width = 16,  datab_imag.datab_imag
		.result_real (_connected_to_result_real_), //  output,  width = 32, result_real.result_real
		.result_imag (_connected_to_result_imag_), //  output,  width = 32, result_imag.result_imag
		.clock       (_connected_to_clock_)        //   input,   width = 1,       clock.clk
	);

