`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-21
//File name       :  sys_frame_head_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------
module sys_frame_head_gen #
(
    parameter CLK_SET   = 1

)
(
input  	wire      		rst,
input  	wire      		clk,
input	  wire		  	  i_ref_frame_10ms,	
input  	wire			    i_ref_frame_80ms,
output	wire			    o_ref_frame_5ms,			//输出的去抖后的61.44 的空口5ms中断
output	wire			    o_ref_frame_10ms,		  
output	wire			    o_ref_frame_80ms,
output	wire		     	o_ref_frame_kind,
output	wire	[31:0]	o_ext_frame_info,       // 10ms_head register
input	  wire	[31:0]	reg_max_delay,			    //被配置的最大上下行时延值
output	reg				    o_mst_rx_5ms, 	  	    //参考接收5ms，ir模式下有效                                     	
output	reg				    o_mst_rx_10ms,          //参考接收10ms，cpri模式下有效，ir-lte模式下有效  
output	reg				    o_mst_tx_5ms,           //发送5ms，ir模式下有效                           
output	reg				    o_mst_tx_10ms,          //发送10ms，cpri模式下有效，ir-lte模式下有效  
input	  wire	[31:0]	reg_10ms_ul_dl_gap      //被配置的最大上下行时延值
);


//---------------------------------------------------------------------------//
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



//---------------------------------------------------------------------------//

wire   		        ref_frame_10ms  ;
wire   		        ref_frame_80ms  ;
reg		 [22:0]			time_10ms_value ;  
reg		 [25:0]			time_80ms_value ; 
reg	   	          ref_frame_80ms_d1,ref_frame_80ms_d2,ref_frame_80ms_d3;
reg	   	          ref_frame_80ms_p;
reg	   	          ref_frame_10ms_d1,ref_frame_10ms_d2,ref_frame_10ms_d3;
reg	   	          ref_frame_10ms_p;
reg	   [22:0]	    mst_cnt_10ms=23'd0;
reg	   [22:0]	    mst_cnt_10ms_dly;
reg	   				    mst_10ms_flag;
reg	   [3:0]	  	mst_10ms_flag_dly;
reg	   			  	  mst_5ms_flag;
reg        			  mst_frame_kind=1'd0;
reg    [3:0]		  mst_5ms_flag_dly;
reg	   [7:0]			ext10ms_gen_num=8'd0;
reg	   [7:0]			ext80ms_gen_num=8'd0;
reg	   [7:0]			ext10ms_err_num=8'd0;
reg	   [7:0]			ext80ms_err_num=8'd0;
reg	   [22:0]	    mst_cnt_rx_pos= 23'h7fffff;
reg	   [22:0]	    mst_cnt_tx_pos= 23'h7fffff;

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
//--
//i_ref_frame_10ms

always @ ( posedge clk)
	begin
		ref_frame_10ms_d1	<=	i_ref_frame_10ms;    
		ref_frame_10ms_d2	<=	ref_frame_10ms_d1;    
		ref_frame_10ms_d3	<=	ref_frame_10ms_d2;    
		ref_frame_10ms_p 	<=	ref_frame_10ms_d2 & (~ref_frame_10ms_d3);    
	end		

// i_ref_frame_80ms 

always @ ( posedge clk)
	begin
		ref_frame_80ms_d1	<=	i_ref_frame_80ms;    
		ref_frame_80ms_d2	<=	ref_frame_80ms_d1;    
		ref_frame_80ms_d3	<=	ref_frame_80ms_d2;    
		ref_frame_80ms_p 	<=	ref_frame_80ms_d2 & (~ref_frame_80ms_d3);    
	end	

frame_head_protect u_frame_head_10ms_protect
(
	.rst		  	       (rst						  	        ),
	.clk				       (clk								        ),		
	.i_ext_head			   (ref_frame_10ms_p					),		//frame head from epld or receiver module
	.i_frame_max			 ({3'b0,time_10ms_value}    ),		//frame cnt max
	.o_int_head			   (ref_frame_10ms						)     //frame head gen
);	


frame_head_protect u_frame_head_80ms_protect
(
	.clk               (clk								        ),		 
	.rst               (rst							          ),
	.i_ext_head        (ref_frame_80ms_p					),		//frame head from epld or receiver module
	.i_frame_max       (time_80ms_value		   		  ),		//frame cnt max
	.o_int_head        (ref_frame_80ms						)     //frame head gen
);		

assign o_ref_frame_80ms = ref_frame_80ms;	 
//---------------------------------------------------------------------------//
//--
//--master的5ms计数器
//--接收到5ms时刻时，计数器所在位置


always @ (posedge clk)
	begin
		if(reg_max_delay[15:0] == 16'd0)
			    mst_cnt_rx_pos <= {1'd0,time_10ms_value[22:1]};
	    else
	        mst_cnt_rx_pos <= {7'b0,reg_max_delay[15:0]} - 23'd1;
	end	

// 产生发送5ms时刻，计数器所在位置 

always @ ( posedge clk)
	begin
        mst_cnt_tx_pos <=  {1'd0,time_10ms_value[22:1]} - {7'b0,reg_max_delay[31:16]};
	end

//------------------------------------------------------------------------------//
//--
// 产生master 10ms计数器

always @ ( posedge clk)
	begin
		if(ref_frame_10ms)
			mst_cnt_10ms <= reg_10ms_ul_dl_gap[22:0] + 23'd1;
		else if(mst_cnt_10ms == time_10ms_value)
			mst_cnt_10ms <= 23'd0;
		else if(mst_cnt_10ms != 23'd0)
			mst_cnt_10ms <= mst_cnt_10ms + 23'd1;
	end	
	
always @ ( posedge clk)
	begin
        mst_cnt_10ms_dly <= mst_cnt_10ms;
	end	
	


always @ ( posedge clk)
	begin
		if(mst_cnt_10ms == time_10ms_value)
		    mst_10ms_flag <= 1'b1;
		else 
			  mst_10ms_flag <= 1'b0;
	end
	
always @ ( posedge clk)
	begin
        mst_10ms_flag_dly <= {mst_10ms_flag_dly[2:0],mst_10ms_flag};
	end	
	
assign o_ref_frame_10ms = (|mst_10ms_flag_dly) | mst_10ms_flag;	


// 5ms flag
always @ ( posedge clk)
	begin
		if(mst_cnt_10ms == time_10ms_value)	   
		    begin
				mst_5ms_flag   <= 1'b1;
			  mst_frame_kind <= 1'b1;
			end
		else if(mst_cnt_10ms == {1'b0,{1'd0,time_10ms_value[22:1]}}) 
			begin
				mst_5ms_flag   <= 1'b1;
				mst_frame_kind <= 1'b0;
			end
		else 
			begin
				mst_5ms_flag   <= 1'b0;
				mst_frame_kind <= mst_frame_kind;
			end
	end	
	
always @ ( posedge clk)
	begin
        mst_5ms_flag_dly <= {mst_5ms_flag_dly[2:0],mst_5ms_flag};
	end	
	
assign o_ref_frame_5ms	= (|mst_5ms_flag_dly) | mst_5ms_flag;
assign o_ref_frame_kind	= mst_frame_kind;
//------------------------------------------------------------------------------//
//--rx		
// o_mst_rx_5ms
always @ ( posedge clk)
	begin
		if(mst_cnt_10ms_dly != mst_cnt_10ms)
    		if(mst_cnt_10ms == mst_cnt_rx_pos)
    			o_mst_rx_5ms <= 1'b1;
        else if(mst_cnt_10ms == ({1'b0,time_10ms_value[22:1]} + mst_cnt_rx_pos+ 1'b1))	
    			o_mst_rx_5ms <= 1'b1;
    		else 
    			o_mst_rx_5ms <= 1'b0;
    else
    	    o_mst_rx_5ms <= 1'b0;
	end	

// o_mst_rx_10ms
always @ ( posedge clk)
	begin
		if(mst_cnt_10ms_dly != mst_cnt_10ms)
    		if(mst_cnt_rx_pos == time_10ms_value[22:1]) 
        		if(mst_cnt_10ms == ({1'b0,time_10ms_value[22:1]} + mst_cnt_rx_pos + 1'b1))
        			o_mst_rx_10ms <= 1'b1;
        		else 
        			o_mst_rx_10ms <= 1'b0;		
        else
             if(mst_cnt_10ms ==  mst_cnt_rx_pos)
        			o_mst_rx_10ms <= 1'b1;
        		else 
        			o_mst_rx_10ms <= 1'b0;	
     else
              o_mst_rx_10ms <= 1'b0;	
	end			
//------------------------------------------------------------------------------//
//--tx				
// o_mst_tx_5ms
always @ ( posedge clk)
	begin
		if(mst_cnt_10ms == mst_cnt_tx_pos)
			o_mst_tx_5ms <= 1'b1;
		else if(mst_cnt_10ms == ({1'b0,time_10ms_value[22:1]} + mst_cnt_tx_pos+ 1'b1))
			o_mst_tx_5ms <= 1'b1;
		else 
			o_mst_tx_5ms <= 1'b0;
	end	
		
// o_mst_tx_10ms
always @ ( posedge clk)
	begin
		if(mst_cnt_10ms == ({1'b0,time_10ms_value[22:1]} + mst_cnt_tx_pos + 1'b1))
			o_mst_tx_10ms <= 1'b1;
		else 
			o_mst_tx_10ms <= 1'b0;
	end
		
//------------------------------------------------------------------------------//
//--check

always @ ( posedge clk)
	begin
		if (ref_frame_10ms_p)
			ext10ms_gen_num <= ext10ms_gen_num + 8'd1;
		else
			ext10ms_gen_num <= ext10ms_gen_num;
	end
	
always @ ( posedge clk)
	begin
		if (ref_frame_80ms_p)
			ext80ms_gen_num <= ext80ms_gen_num + 8'd1;
		else
			ext80ms_gen_num <= ext80ms_gen_num;
	end
        
always @ ( posedge clk)//error
	begin
		if (ref_frame_10ms & (|mst_cnt_10ms))
			ext10ms_err_num <= ext10ms_err_num + 8'b1;
		else;
	end
	
always @ ( posedge clk)//error
	begin
		if (ref_frame_80ms & (|mst_cnt_10ms))
			ext80ms_err_num <= ext80ms_err_num + 8'b1;
		else;
	end
        
assign o_ext_frame_info = {ext80ms_err_num,ext80ms_gen_num,ext10ms_err_num,ext10ms_gen_num};
	
endmodule