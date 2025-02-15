`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-21
//File name       :  frame_head_protect.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------


module frame_hd_jitter_remove
(
input  wire             clk          ,	
input  wire           	rst          ,
input	 wire	    	      i_ext_head   ,		    //frame head from others module
input	 wire    [25:0]	  i_frame_max  ,		    //frame cnt max
output reg				      o_int_head        		//frame head gen
);

reg [1:0]   sync_idx   = 2'd1;
reg [25:0]  ext_hd_pos = 'b0;
reg [25:0]  int_hd_pos = 'b0;
reg	        ext_head_ok=0   ;	
reg	        ext_head_d1=0   ;
reg [25:0]  cnt_check  = 'b0;
reg [25:0]  max_num         ;
reg [25:0]  frame_cnt  = 'd0; 
reg [25:0]  in_hd_pos_reg  = 'd0; 
reg         i_ext_hd_d1,i_ext_hd_d2 ;
wire        ext_hd_p ;
reg         frame_hd  ;
always@(posedge clk)begin
    i_ext_hd_d1 <= i_ext_head ;
    i_ext_hd_d2 <= i_ext_hd_d1 ;
end

assign ext_hd_p = ~i_ext_hd_d2 && i_ext_hd_d1 ;

always @ ( posedge clk)
	begin
      max_num <= i_frame_max+1;
	end	

always@(posedge clk)begin
if (rst)
    frame_cnt <= 'd0 ;
else if (frame_cnt == i_frame_max -1 )
    frame_cnt <= 'd0 ;
else 
    frame_cnt <= frame_cnt +  'd1 ;
end
///*
always@(posedge clk)begin
if (rst)
    in_hd_pos_reg <= 'd0 ;
else if (ext_hd_p)
    in_hd_pos_reg <= frame_cnt ;
end
//*/
always@(posedge clk)begin
    frame_hd   <=  ext_hd_p ;
    ext_hd_pos <=  ext_head_ok ? ext_hd_pos : in_hd_pos_reg ;
end

always @ ( posedge clk)
	begin
		if (ext_hd_p)
		    if ((ext_hd_pos - frame_cnt <= 64) | (frame_cnt - ext_hd_pos<= 64)|
				   (ext_hd_pos + i_frame_max- frame_cnt <= 64) | (frame_cnt + i_frame_max- ext_hd_pos<= 64))
			    ext_head_ok <= 1'b1;
			else
			    ext_head_ok <= 1'b0;
		else;
	end

//int_hd_pos
always @ ( posedge clk)
	begin
		if ((frame_cnt == int_hd_pos) && (sync_idx == 2'd2))//sync_idx,1-2-0  
			int_hd_pos <= ext_hd_pos;
		else;
	end	

always @ ( posedge clk)
	begin
		if (rst)
			sync_idx <= 2'b1;
		else if (sync_idx == 2'd2)
		        if (frame_cnt == int_hd_pos)
			        sync_idx <= 2'b0;
		  	    else;
		else if (sync_idx == 2'd0)
		        if (ext_head_ok)
		            sync_idx <= 2'd0;	  
			      else if(ext_head_d1) 
				        sync_idx <= 2'd1;	
		        else;
		else //(sync_idx == 2'd1)
		        if (ext_head_ok)
		            sync_idx <= 2'd2;
		        else;		    
	end	

 always @ ( posedge clk)
	begin
	    ext_head_d1 <= ext_hd_p;
	end

always @ ( posedge clk)
	begin
		if (rst)
		  	o_int_head <=  1'b0;
  	else if(sync_idx != 2'd0 )
		    o_int_head <= 1'b0;
		else if(frame_cnt == int_hd_pos)//sync_idx,1-2-0
		    o_int_head <= 1'b1;
		else
		    o_int_head <= 1'b0;
	end	

//o_int_head

///*
ila_frame_jitter u_ila_frame_jitter
 (
	.clk   (clk        ), // input wire clk
	.probe0(i_ext_head ), // input wire [0:0]  probe0  
	.probe1(o_int_head ), // input wire [0:0]  probe1 
	.probe2(ext_head_ok), // input wire [0:0]  probe2 
	.probe3(sync_idx   ), // input wire [1:0]  probe3 
	.probe4(ext_hd_pos  ), // input wire [25:0]  probe4 
	.probe5(int_hd_pos  ), // input wire [25:0]  probe5 
	.probe6(frame_cnt  ), // input wire [25:0]  probe6 
	.probe7(in_hd_pos_reg ),  // input wire [25:0]  probe7
	.probe8(rst           )//1
);
//*/
	
endmodule