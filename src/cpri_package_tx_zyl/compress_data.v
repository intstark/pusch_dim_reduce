`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-03-07
//File name       :  compress_data.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------


module compress_data
(
    input   wire            clk,
    input   wire            rst,   
    input   wire    [3:0]   i_sel,      
    input   wire    [3:0]   i_sop,      
    input   wire    [3:0]   i_eop,      
    input   wire    [3:0]   i_vld,      
    input   wire    [31:0]  i_din_ant0, 
    input   wire    [31:0]  i_din_ant1, 
    input   wire    [31:0]  i_din_ant2, 
    input   wire    [31:0]  i_din_ant3, 
    input   wire    [6:0]   i_slot_idx, 
    input   wire    [3:0]   i_symb_idx, 
    input   wire    [8:0]   i_prb_idx,    
    input   wire    [3:0]   i_channel_type0, 
    input   wire    [3:0]   i_channel_type1, 
    input   wire    [3:0]   i_channel_type2, 
    input   wire    [3:0]   i_channel_type3,
    input   wire    [7:0]   i_info0, 
    input   wire    [7:0]   i_info1, 
    input   wire    [7:0]   i_info2, 
    input   wire    [7:0]   i_info3,
      
    output  wire            o_sel,
    output  wire            o_sop,
    output  wire            o_eop,
    output  wire            o_vld,
    output  wire    [13:0]  o_data_ant0,
    output  wire    [13:0]  o_data_ant1,
    output  wire    [13:0]  o_data_ant2,
    output  wire    [13:0]  o_data_ant3,
    output  wire    [3:0]   o_shift0,
    output  wire    [3:0]   o_shift1,
    output  wire    [3:0]   o_shift2,
    output  wire    [3:0]   o_shift3,
    output  wire    [6:0]   o_slot_idx,
    output  wire    [3:0]   o_symb_idx,
    output  wire    [8:0]   o_prb_idx,   
    output  wire    [3:0]   o_channel_type0,
    output  wire    [3:0]   o_channel_type1,
    output  wire    [3:0]   o_channel_type2,
    output  wire    [3:0]   o_channel_type3,
    output  wire    [7:0]   o_info0,
    output  wire    [7:0]   o_info1,
    output  wire    [7:0]   o_info2,
    output  wire    [7:0]   o_info3    
);         

compress_bit #
(
    .Num(7)
)
u0_compress_bit
(
    .clk                  (clk		          ),
    .rst                  (rst		          ),                                                            
    .i_sel                (i_sel[0]         ),
    .i_sop                (i_sop[0]         ),
    .i_eop                (i_eop[0]         ),
    .i_vld                (i_vld[0]         ),
    .i_din                (i_din_ant0		    ),
    .i_slot_idx           (i_slot_idx		    ),
    .i_symb_idx           (i_symb_idx		    ),
    .i_prb_idx            (i_prb_idx		    ),
    .i_ch_type            (i_channel_type0  ),
    .i_info               (i_info0          ),                                            
    .o_sel                (o_sel		        ),
    .o_sop                (o_sop		        ),
    .o_eop                (o_eop		        ),
    .o_vld                (o_vld		        ),
    .o_dout               (o_data_ant0      ),
    .o_shift              (o_shift0	        ),
    .o_slot_idx           (o_slot_idx	      ),
    .o_symb_idx           (o_symb_idx	      ),
    .o_prb_idx            (o_prb_idx	      ),
    .o_type               (o_channel_type0  ),
    .o_info               (o_info0          )
);

compress_bit #
(
    .Num(7)
)
u1_compress_bit
(
    .clk                  (clk		          ),
    .rst                  (rst		          ),
    .i_sel                (i_sel[1]         ),                                                             
    .i_sop                (i_sop[1]         ),
    .i_eop                (i_eop[1]         ),
    .i_vld                (i_vld[1]         ),
    .i_din                (i_din_ant1		    ),
    .i_ch_type            (i_channel_type1  ),
    .i_info               (i_info1          ),                                             
    .o_dout               (o_data_ant1      ),
    .o_shift              (o_shift1	        ),
    .o_type               (o_channel_type1  ),
    .o_info               (o_info1          )
);

compress_bit #
(
    .Num(7)
)
u2_compress_bit
(
    .clk                  (clk		          ),
    .rst                  (rst		          ), 
    .i_sel                (i_sel[2]         ),                                                           
    .i_sop                (i_sop[2]         ),
    .i_eop                (i_eop[2]         ),
    .i_vld                (i_vld[2]         ),
    .i_din                (i_din_ant2		    ),
    .i_ch_type            (i_channel_type2  ),
    .i_info               (i_info2          ),                                          
    .o_dout               (o_data_ant2      ),
    .o_shift              (o_shift2	        ),
    .o_type               (o_channel_type2  ),
    .o_info               (o_info2          )
);

compress_bit #
(
    .Num(7)
)
u3_compress_bit
(                                           
    .clk                  (clk		          ),
    .rst                  (rst		          ),
    .i_sel                (i_sel[3]         ),                                                               
    .i_sop                (i_sop[3]         ),
    .i_eop                (i_eop[3]         ),
    .i_vld                (i_vld[3]         ),
    .i_din                (i_din_ant3		    ),
    .i_ch_type            (i_channel_type3  ),
    .i_info               (i_info3          ),                                              
    .o_dout               (o_data_ant3      ),
    .o_shift              (o_shift3	        ),
    .o_type               (o_channel_type3  ),
    .o_info               (o_info3          )
);

endmodule
