`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-12
//File name       :  Simple_Dual_Port_BRAM_XPM.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//Simple_Dual_Port_BRAM_XPM_intel #(
// .WDATA_WIDTH    (256),
// .NUMWORDS_A     (256),//length
// .RDATA_WIDTH    (256),
// .NUMWORDS_B     (256)
// )u_xxx (
  // .clock		(		    ),   
  // .wren		(			),    
  // .wraddress	(			),  
  // .data		(			), 
  // .rdaddress	(	        ),  
  // .q	        (			) //2 clock out
// );

//
//-----------------------------------------------------------------------------
module Simple_Dual_Port_BRAM_XPM_intel #(
    parameter integer WDATA_WIDTH            =    32,
    parameter integer NUMWORDS_A             =    32,
    parameter integer RDATA_WIDTH            =    32,
    parameter integer NUMWORDS_B             =    32,
    parameter integer INI_FILE               =    ""
    
    )
    (
    input  wire                                              clock            ,
    input  wire                                              wren            ,
    input  wire[WDATA_WIDTH-1:0]                             data           ,
    input  wire[$clog2(NUMWORDS_A)-1:0]                             wraddress          ,
    
    output reg[RDATA_WIDTH-1:0]                             q          ,
    input  wire[$clog2(NUMWORDS_B)-1:0]                             rdaddress   
    );
localparam WADDR_WIDTH =$clog2(NUMWORDS_A);
localparam RADDR_WIDTH =$clog2(NUMWORDS_B);
wire[RDATA_WIDTH-1:0]                             rd_data;
reg[RDATA_WIDTH-1:0]                             rd_data1;
always @(posedge clock)
begin
    q<=rd_data;
    // q<=rd_data1;
end

 altera_syncram  altera_syncram_component (
                .address_a (wraddress),
                .address_b (rdaddress),
                .clock0 (clock),
                .data_a (data),
                .rden_b (1'b1),
                .sclr (1'b0),
                .wren_a (wren),
                .q_b (rd_data),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address2_a (1'b1),
                .address2_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_b ({16{1'b1}}),
                .eccencbypass (1'b0),
                .eccencparity (8'b0),
                .eccstatus (),
                .q_a (),
                .rden_a (1'b1),
                .wren_b (1'b0));
    defparam
        altera_syncram_component.address_aclr_b  = "NONE",
        altera_syncram_component.address_reg_b  = "CLOCK0",
        altera_syncram_component.clock_enable_input_a  = "BYPASS",
        altera_syncram_component.clock_enable_input_b  = "BYPASS",
        altera_syncram_component.clock_enable_output_b  = "BYPASS",
        altera_syncram_component.init_file = INI_FILE,
        altera_syncram_component.init_file_layout  = "PORT_A",
        altera_syncram_component.enable_force_to_zero  = "FALSE",
        altera_syncram_component.intended_device_family  = "Agilex",
        altera_syncram_component.lpm_type  = "altera_syncram",
        altera_syncram_component.numwords_a  = NUMWORDS_A,
        altera_syncram_component.numwords_b  = NUMWORDS_B,
        altera_syncram_component.operation_mode  = "DUAL_PORT",
        altera_syncram_component.outdata_aclr_b  = "NONE",
        altera_syncram_component.outdata_sclr_b  = "SCLEAR",
        altera_syncram_component.outdata_reg_b  = "CLOCK0",
        altera_syncram_component.power_up_uninitialized  = "FALSE",
        altera_syncram_component.ram_block_type  = "AUTO",
        altera_syncram_component.rdcontrol_reg_b  = "CLOCK0",
        altera_syncram_component.read_during_write_mode_mixed_ports  = "DONT_CARE",
        altera_syncram_component.widthad_a  = WADDR_WIDTH,
        altera_syncram_component.widthad_b  = RADDR_WIDTH,
        altera_syncram_component.width_a  = WDATA_WIDTH,
        altera_syncram_component.width_b  = RDATA_WIDTH,
        altera_syncram_component.width_byteena_a  = 1;

endmodule