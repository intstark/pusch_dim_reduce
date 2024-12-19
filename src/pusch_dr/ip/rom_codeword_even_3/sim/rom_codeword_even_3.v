// rom_codeword_even_3.v

// Generated using ACDS version 23.2 94

`timescale 1 ps / 1 ps
module rom_codeword_even_3 (
		output wire [255:0] q,       //       q.dataout
		input  wire [5:0]   address, // address.address
		input  wire         clock,   //   clock.clk
		input  wire         rden     //    rden.rden
	);

	rom_codeword_even_3_rom_1port_2020_y3et4zi rom_1port_0 (
		.q       (q),       //  output,  width = 256,       q.dataout
		.address (address), //   input,    width = 6, address.address
		.clock   (clock),   //   input,    width = 1,   clock.clk
		.rden    (rden)     //   input,    width = 1,    rden.rden
	);

endmodule
