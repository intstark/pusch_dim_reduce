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


module frame_head_protect
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
reg [25:0]  cnt_frame  = 'b0;
reg	        ext_head_ok=0   ;	
reg	        ext_head_d1=0   ;
reg [25:0]  cnt_check  = 'b0;
reg [25:0]  max_num         ;
reg [7:0]   calibration= 'b0;    

always @ ( posedge clk)
	begin
      max_num <= i_frame_max+1;
	end	

always @ (posedge clk)//cnt from
   begin    		
    		if(i_ext_head)	
    			cnt_check <= 26'd1;
    		else if(cnt_check != 26'd0)
    			cnt_check <= cnt_check + 26'd1;
   end

always @ ( posedge clk)//
	begin
		if (i_ext_head & ext_head_ok)
	      if(cnt_check> max_num)//
		      calibration <= cnt_check - max_num; 
		   else
		   	  calibration <= 8'd0; 
	  else	 
			    calibration <= calibration;     	  
	end	

//cnt in frame

//always @ ( posedge clk)
//	begin
//		if (i_ext_head)
//			  cnt_frame <= 26'd1;//10 offset accuracies
//		else if(cnt_frame != 26'd0)
//		    cnt_frame <= cnt_frame + 26'd1;
//	end	
	
//always @ ( posedge clk)
//	begin
//		if (i_ext_head)
//			  cnt_frame <= 26'd0;//10 offset accuracies
//		else if (cnt_frame == i_frame_max)
//			  cnt_frame <= 26'd0;			  
//		else 
//		    cnt_frame <= cnt_frame + 26'd1;
//	end		

always @ ( posedge clk)
	begin
		if (cnt_frame == i_frame_max)
			  cnt_frame <= 26'd0;
		else
		    cnt_frame <= cnt_frame + 26'd1;
	end	

//int_hd_pos
always @ ( posedge clk)
	begin
		if ((cnt_frame == int_hd_pos) && (sync_idx == 2'd2))//sync_idx,1-2-0  
			int_hd_pos <= ext_hd_pos;
		else;
	end	

//ext_head_ok

always @ ( posedge clk)
	begin
		if (i_ext_head)
		    if ((ext_hd_pos - cnt_frame <= 256) | (cnt_frame - ext_hd_pos<= 256)|
				   (ext_hd_pos + i_frame_max- cnt_frame <= 256) | (cnt_frame + i_frame_max- ext_hd_pos<= 256))
			    ext_head_ok <= 1'b1;
			else
			    ext_head_ok <= 1'b0;
		else;
	end

 always @ ( posedge clk)
	begin
	    ext_head_d1 <= i_ext_head;
	end

//ext_hd_pos

always @ ( posedge clk)
	begin
		if (ext_head_d1)
		    if (ext_head_ok)
			    ext_hd_pos <= ext_hd_pos+calibration;
			 else
			    ext_hd_pos <= cnt_frame;
		else;
	end	


//sync_idx,1-2-0

always @ ( posedge clk)
	begin
		if (rst)
			sync_idx <= 2'b1;
		else if (sync_idx == 2'd2)
		        if (cnt_frame == int_hd_pos)
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
	

//o_int_head

always @ ( posedge clk)
	begin
		if (rst)
		  	o_int_head <=  1'b0;
  	else if(sync_idx != 2'd0 )
		    o_int_head <= 1'b0;
		else if(cnt_frame == int_hd_pos)//sync_idx,1-2-0
		    o_int_head <= 1'b1;
		else
		    o_int_head <= 1'b0;
	end	



//ila_frame_head_check u_ila_frame_head_check
// (
//	.clk   (clk        ), // input wire clk
//	.probe0(i_ext_head ), // input wire [0:0]  probe0  
//	.probe1(o_int_head ), // input wire [0:0]  probe1 
//	.probe2(ext_head_ok), // input wire [0:0]  probe2 
//	.probe3(sync_idx   ), // input wire [1:0]  probe3 
//	.probe4(calibration), // input wire [7:0]  probe4 
//	.probe5(cnt_check  ), // input wire [25:0]  probe5 
//	.probe6(cnt_frame  ), // input wire [25:0]  probe6 
//	.probe7(ext_hd_pos )  // input wire [25:0]  probe7
//);

	
endmodule