//-------------------------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-10-17
//File name       :  search_max.sv
//--------------------------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//--------------------------------------------------------------------------------------------

module search_max
#(
	parameter integer IW = 40
)
(
    input  wire                                     clk                     ,
    input  wire                                     rst                     ,
    input  wire                                     i_sop                   ,
    input  wire                                     i_eop                   ,
    input  wire                                     i_vld                   ,
    input  wire    [IW-1: 0]                        i_din_re                ,
    input  wire    [IW-1: 0]                        i_din_im                ,
    output wire    [IW-1: 0]                        o_max                   ,
    output wire    [   7: 0]                        o_vld                    
);


//--------------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------------
reg                                             i_eop_d1              =0;
reg            [   4: 0]                        shift_num             =0;
reg            [IW-1: 0]                        abs_i                 =0;
reg            [IW-1: 0]                        abs_q                 =0;
reg            [IW-1: 0]                        abs_i_max             =0;
reg            [IW-1: 0]                        abs_q_max             =0;
reg            [IW-1: 0]                        max_value_i           =0;
reg            [IW-1: 0]                        max_value_q           =0;
reg            [IW-1: 0]                        max_value_iq          =0;

//--------------------------------------------------------------------------------------------
// ABS value
//--------------------------------------------------------------------------------------------
always @ (posedge clk)
begin
    if(i_vld)
        begin
   	        if(!i_din_re[IW-1])
	        	abs_i <= i_din_re;
   	        else
	        	abs_i <= ~i_din_re + 'd1;
        end
    else
       abs_i <= {IW{1'b0}};
end

always @ (posedge clk)
begin	  
   if(i_vld)
        begin
	        if(!i_din_im[IW-1])
	        	abs_q <= i_din_im;
            else
            abs_q <= ~i_din_im + 'd1; 
        end
    else
        abs_q <= {IW{1'b0}};
end 

//--------------------------------------------------------------------------------------------
// max i/q value
//--------------------------------------------------------------------------------------------
always @ (posedge clk)
    i_eop_d1 <= i_eop;

always @ (posedge clk)
begin
  if(rst)
    abs_i_max <= {IW{1'b0}};
	else if(i_eop_d1)
		abs_i_max <= {IW{1'b0}};
	else
		abs_i_max <= (abs_i | abs_i_max);
end

always @ (posedge clk)
begin
  if(rst)
    abs_q_max <= {IW{1'b0}};
	else if(i_eop_d1)
		abs_q_max <= {IW{1'b0}};
	else
		abs_q_max <= (abs_q | abs_q_max);
end

//--------------------------------------------------------------------------------------------
// max value
//--------------------------------------------------------------------------------------------
always @ (posedge clk)
begin
    if(rst)
        max_value_i <= {IW{1'b0}};
    else if(i_eop_d1)
        max_value_i <= (abs_i | abs_i_max);
    else
        max_value_i <= max_value_i;
end

always @ (posedge clk)
begin
    if(rst)
        max_value_q <= {IW{1'b0}};
    else if(i_eop_d1)
        max_value_q <= (abs_q | abs_q_max);
    else
        max_value_q <= max_value_q;
end

//--------------------------------------------------------------------------------------------
// final max value
//--------------------------------------------------------------------------------------------
always @ (posedge clk)
	max_value_iq <= (max_value_q | max_value_i);


assign o_max = max_value_iq;




endmodule
