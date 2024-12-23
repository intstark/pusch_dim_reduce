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
//ASYNC_Dual_Port_BRAM_XPM_intel #(
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
module ASYNC_Dual_Port_BRAM_XPM_intel #(
    parameter integer DATA_WIDTH_A            =    32,
    parameter integer DATA_WIDTH_B            =    32,
    parameter integer NUMWORDS_A             =    32,
    parameter integer INI_FILE               =    "",
    parameter integer RAM_BLOCK_TYPE         =   "AUTO"
    
    
    )
    (
    input  [DATA_WIDTH_A-1:0]  data,
    input    rd_aclr,
    input  [$clog2(NUMWORDS_B)-1:0]  rdaddress,
    input    rdclock,
    input    rden,
    input  [$clog2(NUMWORDS_A)-1:0]  wraddress,
    input    wrclock,
    input    wea,
    output reg[DATA_WIDTH_B-1:0]  q   
    );

localparam ADDRESS_WIDTH_A = $clog2(NUMWORDS_A);
localparam ADDRESS_WIDTH_B = $clog2(NUMWORDS_B);
localparam NUMWORDS_B = NUMWORDS_A*DATA_WIDTH_A/DATA_WIDTH_B;
wire[DATA_WIDTH_B-1:0]  rd_data;
reg [DATA_WIDTH_B-1:0]  rd_data_d1;
// reg [DATA_WIDTH_B-1:0]  rd_data_d2;
always @(posedge rdclock)
begin
    rd_data_d1<=rd_data;
    q<=rd_data_d1;
end
// localparam RAM_BLOCK_TYPE = "AUTO";
 altera_syncram  altera_syncram_component (
                .aclr1 (rd_aclr),
                .address_a (wraddress),
                .address_b (rdaddress),
                .clock0 (wrclock),
                .clock1 (rdclock),
                .data_a (data),
                .rden_b (rden),
                .wren_a (wea),
                .q_b (rd_data),
                .aclr0 (1'b0),
                .address2_a (1'b1),
                .address2_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_b ({DATA_WIDTH_B{1'b1}}),
                .eccencbypass (1'b0),
                .eccencparity (8'b0),
                .eccstatus (),
                .q_a (),
                .rden_a (1'b1),
                .sclr (1'b0),
                .wren_b (1'b0));
    defparam
        altera_syncram_component.address_aclr_b  = "NONE",
        altera_syncram_component.address_reg_b  = "CLOCK1",
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
        altera_syncram_component.outdata_aclr_b  = "CLEAR1",
        altera_syncram_component.outdata_sclr_b  = "NONE",
        altera_syncram_component.power_up_uninitialized  = "FALSE",
        altera_syncram_component.ram_block_type  = RAM_BLOCK_TYPE,
        altera_syncram_component.rdcontrol_reg_b  = "CLOCK1",
        altera_syncram_component.widthad_a  = ADDRESS_WIDTH_A,
        altera_syncram_component.widthad_b  = ADDRESS_WIDTH_B,
        altera_syncram_component.width_a  = DATA_WIDTH_A,
        altera_syncram_component.width_b  = DATA_WIDTH_B,
        altera_syncram_component.width_byteena_a  = 1;


endmodule