module rom_65536x64_L2 (
		output wire [63:0] q,       //       q.dataout
		input  wire [15:0] address, // address.address
		input  wire        clock,   //   clock.clk
		input  wire        rden     //    rden.rden
	);
endmodule

