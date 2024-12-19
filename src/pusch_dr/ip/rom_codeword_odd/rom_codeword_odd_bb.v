module rom_codeword_odd (
		output wire [1023:0] q,       //       q.dataout
		input  wire [5:0]    address, // address.address
		input  wire          clock,   //   clock.clk
		input  wire          rden     //    rden.rden
	);
endmodule

