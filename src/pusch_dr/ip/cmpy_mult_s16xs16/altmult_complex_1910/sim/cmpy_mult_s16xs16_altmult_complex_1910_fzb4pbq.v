//altmult_complex CBX_AUTO_BLACKBOX="ALL" CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="Agilex 7" IMPLEMENTATION_STYLE="AUTO" PIPELINE=4 REPRESENTATION_A="SIGNED" REPRESENTATION_B="SIGNED" WIDTH_A=16 WIDTH_B=16 WIDTH_RESULT=32 clock dataa_imag dataa_real datab_imag datab_real result_imag result_real
//VERSION_BEGIN 23.2 cbx_alt_ded_mult_y 2023:06:13:18:22:37:SC cbx_altera_mult_add 2023:06:13:18:22:37:SC cbx_altera_mult_add_rtl 2023:06:13:18:22:37:SC cbx_altmult_add 2023:06:13:18:22:37:SC cbx_altmult_complex 2023:06:13:18:22:37:SC cbx_lpm_add_sub 2023:06:13:18:22:37:SC cbx_lpm_compare 2023:06:13:18:22:37:SC cbx_lpm_mult 2023:06:13:18:22:38:SC cbx_mgl 2023:06:13:18:22:58:SC cbx_nadder 2023:06:13:18:22:37:SC cbx_padd 2023:06:13:18:22:37:SC cbx_parallel_add 2023:06:13:18:22:37:SC cbx_stratix 2023:06:13:18:22:38:SC cbx_stratixii 2023:06:13:18:22:38:SC cbx_stratixv 2023:06:13:18:22:37:SC cbx_util_mgl 2023:06:13:18:22:38:SC  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2023  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and any partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details, at
//  https://fpgasoftware.intel.com/eula.



//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  cmpy_mult_s16xs16_altmult_complex_1910_fzb4pbq
	( 
	clock,
	dataa_imag,
	dataa_real,
	datab_imag,
	datab_real,
	result_imag,
	result_real) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	input   [15:0]  dataa_imag;
	input   [15:0]  dataa_real;
	input   [15:0]  datab_imag;
	input   [15:0]  datab_real;
	output   [31:0]  result_imag;
	output   [31:0]  result_real;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg  [15:0]  datab_real_input_reg;
	reg  [15:0]  datab_imag_input_reg;
	reg  [15:0]  dataa_real_input_reg;
	reg  [15:0]  dataa_imag_input_reg;
	reg  [31:0]  result_real_output_reg;
	reg  [31:0]  result_imag_output_reg;
	reg  [31:0]  result_real_extra0_reg;
	reg  [31:0]  result_imag_extra0_reg;
	reg  [31:0]  result_real_extra1_reg;
	reg  [31:0]  result_imag_extra1_reg;
	wire signed	[15:0]    datab_real_wire;
	wire signed	[15:0]    datab_imag_wire;
	wire signed	[15:0]    dataa_real_wire;
	wire signed	[15:0]    dataa_imag_wire;
	wire signed	[32:0]    result_real_wire;
	wire signed	[32:0]    result_imag_wire;
	wire signed	[16:0]    a1_wire;
	wire signed	[16:0]    a2_wire;
	wire signed	[16:0]    a3_wire;
	wire signed	[32:0]    p1_wire;
	wire signed	[32:0]    p2_wire;
	wire signed	[32:0]    p3_wire;


	// synopsys translate_off
	initial
		datab_real_input_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		datab_real_input_reg <= datab_real;
	// synopsys translate_off
	initial
		datab_imag_input_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		datab_imag_input_reg <= datab_imag;
	// synopsys translate_off
	initial
		dataa_real_input_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		dataa_real_input_reg <= dataa_real;
	// synopsys translate_off
	initial
		dataa_imag_input_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		dataa_imag_input_reg <= dataa_imag;
	// synopsys translate_off
	initial
		result_real_output_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		result_real_output_reg <= result_real_extra1_reg;
	// synopsys translate_off
	initial
		result_imag_output_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		result_imag_output_reg <= result_imag_extra1_reg;
	// synopsys translate_off
	initial
		result_real_extra0_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		result_real_extra0_reg <= result_real_wire[31:0];
	// synopsys translate_off
	initial
		result_imag_extra0_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		result_imag_extra0_reg <= result_imag_wire[31:0];
	// synopsys translate_off
	initial
		result_real_extra1_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		result_real_extra1_reg <= result_real_extra0_reg;
	// synopsys translate_off
	initial
		result_imag_extra1_reg = 0;
	// synopsys translate_on
	always @(posedge clock)
		
		result_imag_extra1_reg <= result_imag_extra0_reg;

	assign datab_real_wire = datab_real_input_reg;
	assign datab_imag_wire = datab_imag_input_reg;
	assign dataa_real_wire = dataa_real_input_reg;
	assign dataa_imag_wire = dataa_imag_input_reg;
	assign a1_wire = {datab_real_wire[15], datab_real_wire} - {datab_imag_wire[15], datab_imag_wire};
	assign p1_wire = a1_wire * dataa_imag_wire;
	assign a2_wire = {dataa_real_wire[15], dataa_real_wire} - {dataa_imag_wire[15], dataa_imag_wire};
	assign p2_wire = a2_wire * datab_real_wire;
	assign a3_wire = {dataa_real_wire[15], dataa_real_wire} + {dataa_imag_wire[15], dataa_imag_wire};
	assign p3_wire = a3_wire * datab_imag_wire;
	assign result_real_wire = p1_wire + p2_wire;
	assign result_imag_wire = p1_wire + p3_wire;
	assign result_real = ({result_real_output_reg});
	assign result_imag = ({result_imag_output_reg});

endmodule //cmpy_mult_s16xs16_altmult_complex_1910_fzb4pbq
//VALID FILE
