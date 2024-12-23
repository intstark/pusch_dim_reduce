// (C) 2001-2023 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  rom_65536x64_L3_rom_1port_2020_2h6lsty  (
    address,
    clock,
    rden,
    q);

    input  [13:0]  address;
    input    clock;
    input    rden;
    output [63:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
    tri1     clock;
    tri1     rden;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

    wire [63:0] sub_wire0;
    wire [63:0] q = sub_wire0[63:0];

    altera_syncram  altera_syncram_component (
                .address_a (address),
                .clock0 (clock),
                .rden_a (rden),
                .q_a (sub_wire0),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address2_a (1'b1),
                .address2_b (1'b1),
                .address_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_a ({64{1'b1}}),
                .data_b (1'b1),
                .eccencbypass (1'b0),
                .eccencparity (8'b0),
                .eccstatus ( ),
                .q_b ( ),
                .rden_b (1'b1),
                .sclr (1'b0),
                .wren_a (1'b0),
                .wren_b (1'b0));
    defparam
        altera_syncram_component.address_aclr_a  = "NONE",
        altera_syncram_component.clock_enable_input_a  = "BYPASS",
        altera_syncram_component.clock_enable_output_a  = "BYPASS",
        altera_syncram_component.init_file = "../pusch_group0_mif/LAN4.mif",
        altera_syncram_component.intended_device_family  = "Agilex 7",
        altera_syncram_component.lpm_type  = "altera_syncram",
        altera_syncram_component.numwords_a  = 12672,
        altera_syncram_component.operation_mode  = "ROM",
        altera_syncram_component.outdata_aclr_a  = "NONE",
        altera_syncram_component.outdata_sclr_a  = "NONE",
        altera_syncram_component.outdata_reg_a  = "CLOCK0",
        altera_syncram_component.ram_block_type  = "M20K",
        altera_syncram_component.enable_force_to_zero  = "FALSE",
        altera_syncram_component.widthad_a  = 14,
        altera_syncram_component.width_a  = 64,
        altera_syncram_component.width_byteena_a  = 1;


endmodule


