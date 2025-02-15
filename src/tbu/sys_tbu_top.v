`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-20
//File name       :  nr_tbu.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------
module sys_tbu_top #(
   parameter  SIM_TEST           = 0, 
   parameter  CLK_SET            = 2 // 1=122.88, 2=245.76, 4=491.52
)
(

	  input	  wire				      clk              ,  
	  input	  wire				      clk_368          ,
	  input	  wire				      rst              ,	                                        									
	  input	  wire		[1:0]     nr_scs_cfg       ,	                                        									
	  input	  wire				      i_ref_10ms_head  ,  	
	  input	  wire				      i_ref_80ms_head  , 
	  input	  wire	  [10:0]		i_ref_frame_num  ,  
	  input   wire	  [31:0]		i_sys_max_delay  ,
	  input   wire	  [31:0]		i_10ms_ul_dl_gap , 	     		  
	  output	wire	  			    o_frame5ms_head  ,
	  output	wire	  			    o_frame10ms_head ,   
	  output	wire	  			    o_frame80ms_head ,
	  output	wire	  			    o_ref_frame_kind ,
	  output	wire	  [31:0]		o_ext_frame_info ,	  
//---------------------------------------------------------------------------//
//--uplink	  
	  input	  wire	  [31:0]		i_ul_0_frame_pos            ,
    output	wire    [10:0]	  o_ul_0_half_frame_num       , 
    output	wire    [9:0]	    o_ul_0_frame_num            , 
    output	wire    [7:0]	    o_ul_0_slot_num             , 
    output	wire    [3:0]	    o_ul_0_symb_num             , 
    output	wire              o_ul_0_half_frame_head      , 
    output	wire              o_ul_0_frame_head           , 
    output	wire              o_ul_0_slot_head            , 
    output	wire              o_ul_0_symb_head            , 
    output  wire    [9:0]     o_ul_0_10us_or_5us_num      , 
    output  wire              o_ul_0_10us_or_5us_vld      ,  

	  input	  wire	  [31:0]		i_ul_1_frame_pos            ,
    output	wire    [10:0]	  o_ul_1_half_frame_num       , 
    output	wire    [9:0]	    o_ul_1_frame_num            , 
    output	wire    [7:0]	    o_ul_1_slot_num             , 
    output	wire    [3:0]	    o_ul_1_symb_num             , 
    output	wire              o_ul_1_half_frame_head      , 
    output	wire              o_ul_1_frame_head           , 
    output	wire              o_ul_1_slot_head            , 
    output	wire              o_ul_1_symb_head            , 
    output  wire    [9:0]     o_ul_1_10us_or_5us_num      , 
    output  wire              o_ul_1_10us_or_5us_vld      ,  

//---------------------------------------------------------------------------//
//--downlink	
	  input	  wire	  [31:0]		i_dl_0_frame_pos            ,
    output	wire    [10:0]	  o_dl_0_half_frame_num       , 
    output	wire    [9:0]	    o_dl_0_frame_num            , 
    output	wire    [7:0]	    o_dl_0_slot_num             , 
    output	wire    [3:0]	    o_dl_0_symb_num             , 
    output	wire              o_dl_0_half_frame_head      , 
    output	wire              o_dl_0_frame_head           , 
    output	wire              o_dl_0_slot_head            , 
    output	wire              o_dl_0_symb_head            , 
    output  wire    [9:0]     o_dl_0_10us_or_5us_num      , 
    output  wire              o_dl_0_10us_or_5us_vld      ,  
//---------------------------------------------------------------------------//
//--report to x86   
    input	  wire	  [31:0]		i_prt_frame_pos             , 
    output	wire    [10:0]	  o_rpt_half_frame_num        , 
    output	wire    [9:0]	    o_rpt_frame_num             , 
    output	wire    [7:0]	    o_rpt_slot_num              , 
    output	wire    [3:0]	    o_rpt_symb_num              , 
    output	wire              o_rpt_half_frame_head       , 
    output	wire              o_rpt_frame_head            , 
    output	wire              o_rpt_slot_head             , 
    output	wire              o_rpt_symb_head             , 
    output  wire    [9:0]     o_rpt_10us_or_5us_num       , 
    output  wire              o_rpt_10us_or_5us_vld            
); 


//---------------------------------------------------------------------------//
//------------------------	
//clk=122.88m
//1ms=2slot=122.88mhz	
//1ms=122880
//1ms=2slot=2*14sym=28symbol

//clk=122.88m 
//--FFT-N+CP=N_OFDM
//normal cp=288
//long   cp=352
//1symbol=4388 =122880/28
//------------------------
//--1slot=0.5ms
//--4096+288=4384
//--4096+352=4448  
//--4384*13+4448 =61440
//--2slot=122880



//clk=245.76m=2*(clk-122.88m )
//(4096+288)*2=8768
//(4096+352)*2=8896    
//8768*13+8896=122880
//------------------------

//--122.88MHz                             
//--1s=122_880_000                                
	localparam  TIMER_1_10MS_VALUE = 23'd1228800  -1;   
	localparam  TIMER_1_80MS_VALUE = 26'd9830400  -1; 
//--245.76MHz                                   
//--1s=245_760_000                              
	localparam  TIMER_2_10MS_VALUE = 23'd2457600  -1;
	localparam  TIMER_2_80MS_VALUE = 26'd19660800 -1;   
//--491.52MHz                                   
//--1s=491_520_000                              
	localparam  TIMER_3_10MS_VALUE = 23'd4915200  -1;
	localparam  TIMER_3_80MS_VALUE = 26'd39321600 -1;   



  wire              timer_10ms_pulse     ; 
  wire              timer_80ms_pulse     ; 	
  wire					    up_frame_head        ;
  wire					    dw_frame_head        ;   
  reg		[22:0]			time_10ms_value      ;  
  reg		[25:0]			time_80ms_value      ;   
  reg		[22:0]			up_cnt_10ms = 23'd0  ;
  reg		[22:0]			dw_cnt_10ms = 23'd0  ;

//---------------------------------------------------------------------------//
//--clk set 
//--1=122.88, 2=245.76, 4=491.52 
always @ (clk)//10ms
begin
    if(CLK_SET==1 )    
        time_10ms_value  <= TIMER_1_10MS_VALUE;
    else if(CLK_SET==2)    
        time_10ms_value  <= TIMER_2_10MS_VALUE;   
    else   
        time_10ms_value  <= TIMER_3_10MS_VALUE;                

end   

always @ (clk)//80ms
begin
    if(CLK_SET==1 )    
        time_80ms_value  <= TIMER_1_80MS_VALUE;
    else if(CLK_SET==2)    
        time_80ms_value  <= TIMER_2_80MS_VALUE;   
    else   
        time_80ms_value  <= TIMER_3_80MS_VALUE;                

end  


//---------------------------------------------------------------------------//
//--NR FRAME STRUCTURE--TIME BASE UNIT
//--internal timer
system_timer #
(                         
	  .CLK_SET					      (CLK_SET            )
) 
 u_system_timer
(
    .clk                    (clk                ),
    .rst                    (rst                ),
    .o_timer_10ms_pulse     (timer_10ms_pulse   ),
    .o_timer_80ms_pulse     (timer_80ms_pulse   )

);  


 
//---------------------------------------------------------------------------//
//--frame head generate

sys_frame_head_gen #
(                         
	.CLK_SET					        (CLK_SET            )
)  
u_sys_frame_head_gen
(
	.clk					            (clk                ),
	.rst				              (rst                ),
	.i_ref_frame_10ms		      (i_ref_10ms_head    ),//timer_10ms_pulse  or  i_ref_10ms_head  
	.i_ref_frame_80ms		      (i_ref_80ms_head    ),//timer_80ms_pulse  or  i_ref_80ms_head	
	.o_ref_frame_5ms	  	    (o_frame5ms_head    ),                     
	.o_ref_frame_10ms		      (o_frame10ms_head   ),
	.o_ref_frame_80ms		      (o_frame80ms_head   ),
	.o_mst_rx_5ms			        (                   ),                                   	
	.o_mst_rx_10ms			      (up_frame_head      ),   
	.o_mst_tx_5ms			        (                   ),                        
	.o_mst_tx_10ms			      (dw_frame_head      ), 				
	.o_ref_frame_kind    	    (o_ref_frame_kind   ),        		
	.o_ext_frame_info		      (o_ext_frame_info   ),                          			              		      	
	.reg_max_delay            (i_sys_max_delay    ),
	.reg_10ms_ul_dl_gap	      (i_10ms_ul_dl_gap   )
);
//---------------------------------------------------------------------------//
//--uplink
//--1s=245_760_000

//--SIM_TEST:  for sim,it=1;for prj,it=0.
//UL_DL_SET,[1]-1-lower,0-higher;[0]-1-lower,0-higher

generate
if ( SIM_TEST == 1'b1 )//for sim
  begin
    always @ (posedge clk)
    	begin
    		if(rst)	
    			up_cnt_10ms <= time_10ms_value-50;
    		else if(up_cnt_10ms == time_10ms_value)
    			up_cnt_10ms <= 23'd0;
    		else 
    			up_cnt_10ms <= up_cnt_10ms + 23'd1;
    	end
    	
    always @ (posedge clk)
    	begin
    		if(rst)	
    			dw_cnt_10ms <=time_10ms_value-50;
    		else if(dw_cnt_10ms == time_10ms_value)
    			dw_cnt_10ms <= 23'd0;
    		else  
    			dw_cnt_10ms <= dw_cnt_10ms + 23'd1;
    end
  end
else//for prj
  begin
    always @ (posedge clk)
    	begin
//    		if(rst)	
//    			up_cnt_10ms <= time_10ms_value-100; //delay 2us  	
//    		else 
    		
    		if(up_frame_head)	
    			up_cnt_10ms <= 23'd1;
    		else if(up_cnt_10ms == time_10ms_value)
    			up_cnt_10ms <= 23'd0;
    		else if(up_cnt_10ms != 23'd0)
    			up_cnt_10ms <= up_cnt_10ms + 23'd1;
    	end
    	

    always @ (posedge clk)
    	begin
//         if(rst)	
//    			dw_cnt_10ms <= time_10ms_value-100; //delay 2us  	
//    	  else 
    	  
    	  if(dw_frame_head)	
    			dw_cnt_10ms <= 23'd1;
    		else if(dw_cnt_10ms == time_10ms_value)
    			dw_cnt_10ms <= 23'd0;
    		else if(dw_cnt_10ms != 23'd0)
    			dw_cnt_10ms <= dw_cnt_10ms + 23'd1;
    end
  end
endgenerate

//---------------------------------------------------------------------------//
//--uplink
sys_frame_info_gen #
(                         
	  .SIM_TEST					    (SIM_TEST                    ),
	  .CLK_SET					    (CLK_SET                     ),
    .UL_DL_SET	  	      (2'b11                       )
)                                                      
u_sys_frame_info_gen_ul_0                              
(                                                      
    .rst			    	      (rst                         ),
    .clk					        (clk                         ),
    .i_ref_frame_num			(i_ref_frame_num             ),
    .i_ref_frame_cnt			(up_cnt_10ms                 ),
    .i_set_frame_pos			(i_ul_0_frame_pos[22:0]      ),  
    .o_half_frame_num  		(o_ul_0_half_frame_num       ),
    .o_frame_num       	  (o_ul_0_frame_num            ),
    .o_slot_num        	  (o_ul_0_slot_num             ),
    .o_symb_num        		(o_ul_0_symb_num             ),
    .o_half_frame_head 		(o_ul_0_half_frame_head      ),
    .o_frame_head      		(o_ul_0_frame_head           ),
    .o_slot_head       		(o_ul_0_slot_head            ),
    .o_symb_head       		(o_ul_0_symb_head            ),
    .o_10us_or_5us_num 		(o_ul_0_10us_or_5us_num      ),
    .o_10us_or_5us_vld 		(o_ul_0_10us_or_5us_vld      ) 

);

sys_frame_info_gen #
(
	  .SIM_TEST					    (SIM_TEST                    ),
	  .CLK_SET					    (CLK_SET                     ),
    .UL_DL_SET			      (2'b11                       ) 
)                                                        
                                                         
u_sys_frame_info_gen_ul_1                                
(                                                       
    .rst				          (rst                         ),
    .clk					        (clk                         ),
    .i_ref_frame_num			(i_ref_frame_num             ),
    .i_ref_frame_cnt			(up_cnt_10ms                 ),
    .i_set_frame_pos			(i_ul_1_frame_pos[22:0]      ),
    .o_half_frame_num  		(o_ul_1_half_frame_num       ),
    .o_frame_num       	  (o_ul_1_frame_num            ),
    .o_slot_num        	  (o_ul_1_slot_num             ),
    .o_symb_num        		(o_ul_1_symb_num             ),
    .o_half_frame_head 		(o_ul_1_half_frame_head      ),
    .o_frame_head      		(o_ul_1_frame_head           ),
    .o_slot_head       		(o_ul_1_slot_head            ),
    .o_symb_head       		(o_ul_1_symb_head            ),
    .o_10us_or_5us_num 		(o_ul_1_10us_or_5us_num      ),
    .o_10us_or_5us_vld 		(o_ul_1_10us_or_5us_vld      ) 

);

//---------------------------------------------------------------------------//
//--downlink
sys_frame_info_gen #
(
	  .SIM_TEST					    (SIM_TEST                    ),
	  .CLK_SET					    (CLK_SET 	                   ),
    .UL_DL_SET				  	(2'b11                       ) 
)                                                        
u_sys_frame_info_gen_dl_0                                
(                                                        
    .rst				          (rst                         ),
    .clk					        (clk                         ),
    .i_ref_frame_num			(i_ref_frame_num             ),
    .i_ref_frame_cnt			(dw_cnt_10ms                 ),
    .i_set_frame_pos			(i_dl_0_frame_pos[22:0]      ),
    .o_half_frame_num  		(o_dl_0_half_frame_num       ),
    .o_frame_num       	  (o_dl_0_frame_num            ),
    .o_slot_num        	  (o_dl_0_slot_num             ),
    .o_symb_num        		(o_dl_0_symb_num             ),
    .o_half_frame_head 		(o_dl_0_half_frame_head      ),
    .o_frame_head      		(o_dl_0_frame_head           ), 
    .o_slot_head       		(o_dl_0_slot_head            ), 
    .o_symb_head       		(o_dl_0_symb_head            ), 
    .o_10us_or_5us_num 		(o_dl_0_10us_or_5us_num      ), 
    .o_10us_or_5us_vld 		(o_dl_0_10us_or_5us_vld      ) 
);

//---------------------------------------------------------------------------//
//--report to x86
sys_frame_info_gen #
(
	  .SIM_TEST					    (SIM_TEST                    ),
	  .CLK_SET					    (CLK_SET 	                   ),
    .UL_DL_SET				  	(2'b11                       ) 
)                                                        
u_sys_frame_info_report                                
(                                                        
    .rst				          (rst                         ),
    .clk					        (clk                         ),
    .i_ref_frame_num			(i_ref_frame_num             ),
    .i_ref_frame_cnt			(dw_cnt_10ms                 ),
    .i_set_frame_pos			(i_prt_frame_pos[22:0]       ),
    .o_half_frame_num  		(o_rpt_half_frame_num        ),
    .o_frame_num       	  (o_rpt_frame_num             ),
    .o_slot_num        	  (o_rpt_slot_num              ),
    .o_symb_num        		(o_rpt_symb_num              ),
    .o_half_frame_head 		(o_rpt_half_frame_head       ),
    .o_frame_head      		(o_rpt_frame_head            ),
    .o_slot_head       		(o_rpt_slot_head             ),
    .o_symb_head       		(o_rpt_symb_head             ),
    .o_10us_or_5us_num 		(o_rpt_10us_or_5us_num       ),
    .o_10us_or_5us_vld 		(o_rpt_10us_or_5us_vld       ) 

);

wire frame_hd_368;






endmodule