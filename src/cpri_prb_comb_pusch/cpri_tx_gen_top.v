`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  All rights reserved.
//Creation Date   :  2024-03-06
//File name       :  cpri_tx_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

//100*(150*256)*(96*64)-chip=1s
//10ms=80slot --> (150*256)*(96*64)=38400chip
//125us=1slot -->38400/80=480chip

module cpri_tx_gen_top
(
    input   wire            wr_clk            ,
    input   wire            wr_rst            ,  
    input   wire            rd_clk            ,
    input   wire            rd_rst            ,      
    input   wire            i_cpri_sop        ,
    input   wire  [63:0]    i_cpri_wdata      ,

	  input	  wire            i_iq_tx_enable    ,	
		output	wire            o_iq_tx_valid     ,
	  output	wire  [63:0]    o_iq_tx_data     

);


wire        dat_vld;
wire [6:0]  dat_adr;
wire [63:0] dat_reg;
wire 		    dat_lst;

  
cpri_tx_gen_tb u_cpri_tx_gen_tb(

    .clk            (wr_clk				),
    .rst            (wr_rst				),  

	  .i_sop          (i_cpri_sop		),
	  .i_dat          (i_cpri_wdata	),
  
    .o_cpri_wen     (dat_vld			),
    .o_cpri_waddr   (dat_adr			),
    .o_cpri_wdata   (dat_reg			),
    .o_cpri_wlast   (dat_lst			)   
);  
  
  
cpri_tx_gen u_cpri_tx_gen(

    .wr_clk            (wr_clk ),
    .wr_rst            (wr_rst ),  
    .rd_clk            (rd_clk ),
    .rd_rst            (rd_rst ),      
    .i_cpri_wen        (dat_vld),
    .i_cpri_waddr      (dat_adr),
    .i_cpri_wdata      (dat_reg),
    .i_cpri_wlast      (dat_lst),

	  .i_iq_tx_enable    (i_iq_tx_enable),	
		.o_iq_tx_valid     (o_iq_tx_valid),
	  .o_iq_tx_data      (o_iq_tx_data)

);  
  
  
           
                   
endmodule