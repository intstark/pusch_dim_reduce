`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-03-06
//File name       :  compress_bit.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

module compress_40b16b
#(
	parameter integer Num = 16
)
(
    input  wire                                     clk                     ,
    input  wire                                     rst                     ,
    input  wire                                     i_sel                   ,
    input  wire                                     i_sop                   ,
    input  wire                                     i_eop                   ,
    input  wire                                     i_vld                   ,
    input  wire    [  79: 0]                        i_din                   ,
    input  wire    [   6: 0]                        i_slot_idx              ,
    input  wire    [   3: 0]                        i_symb_idx              ,
    input  wire    [   8: 0]                        i_prb_idx               ,
    input  wire    [   3: 0]                        i_ch_type               ,
    input  wire    [   7: 0]                        i_info                  ,
    output wire                                     o_sel                   ,
    output wire                                     o_sop                   ,
    output wire                                     o_eop                   ,
    output wire                                     o_vld                   ,
    output reg     [2*Num-1: 0]                     o_dout                  ,
    output reg     [   4: 0]                        o_shift                 ,
    output wire    [   6: 0]                        o_slot_idx              ,
    output wire    [   3: 0]                        o_symb_idx              ,
    output wire    [   8: 0]                        o_prb_idx               ,
    output wire    [   3: 0]                        o_type                  ,
    output wire    [   7: 0]                        o_info                   
);

localparam DAT_DEPTH = 1584;
localparam CAL_CYCLE = 7;
localparam DLY_DEPTH = DAT_DEPTH + CAL_CYCLE;

//------------------------------------------------------------------------------//
reg            [DAT_DEPTH-1: 0]                 rx_vld_dly            =0;
reg                                             i_eop_d1              =0;
reg            [   4: 0]                        shift_num             =0;
reg            [  39: 0]                        abs_i                 =0;
reg            [  39: 0]                        abs_q                 =0;
reg            [  39: 0]                        abs_i_max             =0;
reg            [  39: 0]                        abs_q_max             =0;
reg            [  39: 0]                        max_value_i           =0;
reg            [  39: 0]                        max_value_q           =0;
reg            [  39: 0]                        max_value_iq          =0;
reg            [  11: 0]                        wr_addr               =0;
reg            [  11: 0]                        rd_addr               =0;
wire           [  79: 0]                        data_dly                ;
reg            [  39: 0]                        data_shift_i          =0;
reg            [  39: 0]                        data_shift_q          =0;
reg            [  39: 0]                        rounding_i            =0;
reg            [  39: 0]                        rounding_q            =0;
reg            [  39: 0]                        data_shift_i_dly      =0;
reg            [  39: 0]                        data_shift_q_dly      =0;
reg            [  39: 0]                        result_i0             =0;
reg            [  39: 0]                        result_q0             =0;
reg            [   4: 0]                        max_shift_dly1        =0;
reg            [   4: 0]                        max_shift_dly2        =0;
reg            [   4: 0]                        max_shift_dly3        =0;


//------------------------------------------------------------------------------//
//absolute value
always @ (posedge clk)
begin
    if(i_vld)
        begin
   	        if(!i_din[79])
	        	abs_i <= i_din[79:40];
   	        else
	        	abs_i <= ~i_din[79:40];
        end
    else
       abs_i <= 40'd0;
end

always @ (posedge clk)
begin	  
   if(i_vld)
        begin
	        if(!i_din[39])
	        	abs_q <= i_din[39:0];
            else
            abs_q <= ~i_din[39:0];  
        end
    else
        abs_q <= 40'b0;
end 


always @ (posedge clk)
    i_eop_d1 <= i_eop;

always @ (posedge clk)
begin
  if(rst)
    abs_i_max <= 40'd0;
	else if(i_eop_d1)
		abs_i_max <= 40'd0;
	else
		abs_i_max <= (abs_i | abs_i_max);
end

always @ (posedge clk)
begin
  if(rst)
    abs_q_max <= 40'b0;
	else if(i_eop_d1)
		abs_q_max <= 40'b0;
	else
		abs_q_max <= (abs_q | abs_q_max);
end
//------------------------------------------------------------------------------//
//Find the maximum value in a RB-24 data
always @ (posedge clk)
begin
    if(rst)
        max_value_i <= 40'd0;
    else if(i_eop_d1)
        max_value_i <= (abs_i | abs_i_max);
    else
        max_value_i <= max_value_i;
end

always @ (posedge clk)
begin
    if(rst)
        max_value_q <= 40'd0;
    else if(i_eop_d1)
        max_value_q <= (abs_q | abs_q_max);
    else
        max_value_q <= max_value_q;
end

always @ (posedge clk)
	max_value_iq <= (max_value_q | max_value_i);

always @ (posedge clk)                      
begin
    casex(max_value_iq[39:15])//14-0;14-n=shift
        25'b0_0000_0000_0000_0000_0000_0001 : shift_num <= 5'd23;  
        25'b0_0000_0000_0000_0000_0000_001x : shift_num <= 5'd22;  
        25'b0_0000_0000_0000_0000_0000_01xx : shift_num <= 5'd21;  
        25'b0_0000_0000_0000_0000_0000_1xxx : shift_num <= 5'd20;  
        25'b0_0000_0000_0000_0000_0001_xxxx : shift_num <= 5'd19;  
        25'b0_0000_0000_0000_0000_001x_xxxx : shift_num <= 5'd18;  
        25'b0_0000_0000_0000_0000_01xx_xxxx : shift_num <= 5'd17;        
        25'b0_0000_0000_0000_0000_1xxx_xxxx : shift_num <= 5'd16;   
        25'b0_0000_0000_0000_0001_xxxx_xxxx : shift_num <= 5'd15;   
        25'b0_0000_0000_0000_001x_xxxx_xxxx : shift_num <= 5'd14;
        25'b0_0000_0000_0000_01xx_xxxx_xxxx : shift_num <= 5'd13;
        25'b0_0000_0000_0000_1xxx_xxxx_xxxx : shift_num <= 5'd12;
        25'b0_0000_0000_0001_xxxx_xxxx_xxxx : shift_num <= 5'd11;
        25'b0_0000_0000_001x_xxxx_xxxx_xxxx : shift_num <= 5'd10;
        25'b0_0000_0000_01xx_xxxx_xxxx_xxxx : shift_num <= 5'd9 ;
        25'b0_0000_0000_1xxx_xxxx_xxxx_xxxx : shift_num <= 5'd8 ;
        25'b0_0000_0001_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd7 ;
        25'b0_0000_001x_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd6 ;
        25'b0_0000_01xx_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd5 ;
        25'b0_0000_1xxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd4 ;
        25'b0_0001_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd3 ;
        25'b0_001x_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd2 ;
        25'b0_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd1 ;
        25'b0_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd0 ;
        25'b1_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 5'd0 ;
        default 	                        : shift_num <= 5'd24;
    endcase
end

always @ (posedge clk)
begin
	if(rst)
		wr_addr <= 5'd0;
	else if(i_vld)
		wr_addr <= wr_addr + 5'd1;
	else
	  wr_addr <= wr_addr;
end


always @ (posedge clk)
    rx_vld_dly <= {rx_vld_dly[DAT_DEPTH-2:0],i_vld};  


always @ (posedge clk)
begin
	if(rst)
        rd_addr <= 5'd0;
    else if (rx_vld_dly[DAT_DEPTH-1])
        rd_addr <= rd_addr + 5'd1;       
    else
        rd_addr <= rd_addr;
end

always@(posedge clk)
begin
    data_shift_i <= data_dly[79:40] << shift_num;
    data_shift_q <= data_dly[39: 0] << shift_num;
end
//example
//result bit[15]-bit[9]     
//rounding off--bit[8]
//16-7=9
always@(posedge clk)
begin
    if(data_shift_i[39-1:(39-Num+1)] == {1'b1,1'b1,{(Num-3){1'b1}}})
        rounding_i <= 40'h00_0000_0000;
    else
        rounding_i <= 40'h00_0080_0000;
end

always@(posedge clk)
begin          
    if(data_shift_q[39-1:(39-Num+1)] == {1'b1,1'b1,{(Num-3){1'b1}}})
        rounding_q <= 40'h00_0000_0000;
    else
        rounding_q <= 40'h00_0080_0000;
end
    
always@(posedge clk)
begin
    data_shift_i_dly <= data_shift_i;
    data_shift_q_dly <= data_shift_q;
end 
    
always@(posedge clk)
begin
    result_i0 <= data_shift_i_dly + rounding_i;
    result_q0 <= data_shift_q_dly + rounding_q;
end
   
always @ (posedge clk)
    o_dout <= {result_i0[39:(39-Num+1)],result_q0[39:(39-Num+1)]};   
   
always@(posedge clk)
begin
    max_shift_dly1 <= shift_num   ;
    max_shift_dly2 <= max_shift_dly1;
    max_shift_dly3 <= max_shift_dly2;
    o_shift        <= max_shift_dly3;
end

//------------------------------------------------------------------------------
//--intel:dram/fifo
Simple_Dual_Port_BRAM_XPM_intel
#(
    .WDATA_WIDTH                                        (80                     ),
    .NUMWORDS_A                                         (DAT_DEPTH*2            ),
    .RDATA_WIDTH                                        (80                     ),
    .NUMWORDS_B                                         (DAT_DEPTH*2            ),
    .INI_FILE                                           (                       ) 
)
u_bram_bit_32w_128d
(
    .clock                                              (clk                    ),
    .wren                                               (i_vld                  ),
    .wraddress                                          (wr_addr                ),
    .data                                               (i_din                  ),
    .rdaddress                                          (rd_addr                ),
    .q                                                  (data_dly               ) 
);

//------------------------------------------------------------------------------//
//-- delay match
//------------------------------------------------------------------------------//
register_shift
#(
    .WIDTH                                              (4                      ),
    .DEPTH                                              (DLY_DEPTH              ) 
)
u_dly_vld
(
    .clk                                                (clk                    ),
    .in                                                 ({i_sel,i_sop,i_eop,i_vld}),
    .out                                                ({o_sel,o_sop,o_eop,o_vld}) 
);


register_shift
#(
    .WIDTH                                              (7                      ),
    .DEPTH                                              (DLY_DEPTH              ) 
)
u_dly_slot
(
    .clk                                                (clk                    ),
    .in                                                 (i_slot_idx             ),
    .out                                                (o_slot_idx             ) 
);
     
register_shift
#(
    .WIDTH                                              (4                      ),
    .DEPTH                                              (DLY_DEPTH              ) 
)
u_dly_sym
(
    .clk                                                (clk                    ),
    .in                                                 (i_symb_idx             ),
    .out                                                (o_symb_idx             ) 
);

register_shift
#(
    .WIDTH                                              (9                      ),
    .DEPTH                                              (DLY_DEPTH              ) 
)
u_dly_prb
(
    .clk                                                (clk                    ),
    .in                                                 (i_prb_idx              ),
    .out                                                (o_prb_idx              ) 
);

register_shift
#(
    .WIDTH                                              (4                      ),
    .DEPTH                                              (DLY_DEPTH              ) 
)
u_dly_ch_type
(
    .clk                                                (clk                    ),
    .in                                                 (i_ch_type              ),
    .out                                                (o_type                 ) 
);

//--info null
register_shift
#(
    .WIDTH                                              (8                      ),
    .DEPTH                                              (DLY_DEPTH              ) 
)
u_dly_i_info
(
    .clk                                                (clk                    ),
    .in                                                 (i_info                 ),
    .out                                                (o_info                 ) 
);

endmodule
