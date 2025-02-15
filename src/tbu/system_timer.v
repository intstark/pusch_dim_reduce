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
module system_timer #
(
    parameter CLK_SET   = 1

)
(
input     wire                clk                ,
input     wire                rst                ,
output  	reg				          o_timer_10ms_pulse ,
output  	reg				          o_timer_80ms_pulse 




);



//---------------------------------------------------------------------------//
//--122.88MHz                             
//--1s=122_880_000                                
	localparam  TIMER_1_10MS_VALUE = 23'd1228800  -1;  
	localparam  TIMER_1_80MS_VALUE = 25'd9830400  -1;
//--245.76MHz                                      
//--1s=245_760_000                                 
	localparam  TIMER_2_10MS_VALUE = 23'd2457600  -1;
	localparam  TIMER_2_80MS_VALUE = 25'd19660800 -1;   
//--491.52MHz                                      
//--1s=491_520_000                                 
	localparam  TIMER_3_10MS_VALUE = 23'd4915200  -1;
	localparam  TIMER_3_80MS_VALUE = 26'd39321600 -1;   


reg		[22:0]			time_10ms_value      ;  
reg		[25:0]			time_80ms_value      ; 
reg	  [22:0]			cnt_10ms             ;
reg	  [25:0]			cnt_80ms             ;

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
//--10ms
always @ (posedge clk)
	begin
		if(rst)	
			cnt_10ms <= 23'd0;
		else if(cnt_10ms == time_10ms_value)
			cnt_10ms <= 23'd0;
		else  
			cnt_10ms <= cnt_10ms + 23'd1;
	end

always @ (posedge clk)
	begin
    if(cnt_10ms == time_10ms_value)
			o_timer_10ms_pulse <= 1'd1;
		else  
			o_timer_10ms_pulse <= 1'd0;
	end

//---------------------------------------------------------------------------//
//--80ms
always @ (posedge clk)
	begin
		if(rst)	
			cnt_80ms <= 26'd0;
		else if(cnt_80ms == time_80ms_value)
			cnt_80ms <= 26'd0;
		else  
			cnt_80ms <= cnt_80ms + 26'd1;
	end

always @ (posedge clk)
	begin
    if(cnt_80ms == time_80ms_value)
			o_timer_80ms_pulse <= 1'd1;
		else  
			o_timer_80ms_pulse <= 1'd0;
	end


	
endmodule