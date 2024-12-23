// pus_rst.v

// Generated using ACDS version 23.2 94

`timescale 1 ps / 1 ps
module pus_rst (
		output wire [15:0] source,     //    sources.source
		input  wire        source_clk  // source_clk.clk
	);

	altsource_probe_top #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("NONE"),
		.probe_width             (0),
		.source_width            (16),
		.source_initial_value    ("0"),
		.enable_metastability    ("YES")
	) in_system_sources_probes_0 (
		.source     (source),     //  output,  width = 16,    sources.source
		.source_clk (source_clk), //   input,   width = 1, source_clk.clk
		.source_ena (1'b1)        // (terminated),                         
	);

endmodule
