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

module ul_compress_bit 
#(
	parameter integer Num = 7
)
(
    input   wire                  clk          ,
    input   wire                  rst          ,                        
    input   wire                  i_sel        ,
    input   wire                  i_sop        ,
    input   wire                  i_eop        ,
    input   wire                  i_vld        ,
    input   wire    [31:0]        i_din        ,
    input   wire    [6:0]         i_slot_idx   ,
    input   wire    [3:0]         i_symb_idx   ,
    input   wire    [8:0]         i_prb_idx    ,
    input   wire    [3:0]         i_ch_type    ,
    input   wire    [7:0]         i_info       ,                         
    output  wire                  o_sel        ,
    output  wire                  o_sop        ,
    output  wire                  o_eop        ,
    output  wire                  o_vld        ,
    output  reg     [2*Num-1:0]   o_dout       ,
    output  reg     [3:0]         o_shift      ,
    output  wire    [6:0]         o_slot_idx   ,
    output  wire    [3:0]         o_symb_idx   ,
    output  wire    [8:0]         o_prb_idx    ,
    output  wire    [3:0]         o_type       ,
    output  wire    [7:0]         o_info    

);
//------------------------------------------------------------------------------//
reg  [11:0]     rx_vld_dly;
reg             i_eop_d1;
reg  [3:0] 	    shift_num;
reg  [15:0]     abs_i,abs_q;
reg  [15:0]	    abs_i_max,abs_q_max;
reg  [15:0]     max_value_i,max_value_q,max_value_iq;
reg  [4:0]      wr_addr,rd_addr;
wire [31:0]     data_dly;  
reg  [15:0]     data_shift_i,data_shift_q;
reg  [15:0]     rounding_i,rounding_q;
reg  [15:0]     data_shift_i_dly,data_shift_q_dly;
reg  [15:0]     result_i0,result_q0;
reg  [3:0] 	    max_shift_dly1,max_shift_dly2,max_shift_dly3;
//------------------------------------------------------------------------------//
//absolute value
always @ (posedge clk)
begin
    if(i_vld)
        begin
   	        if(!i_din[31])
	        	abs_i <= i_din[31:16];
   	        else
	        	abs_i <= ~i_din[31:16];
        end
    else
       abs_i <= 16'b0;
end

always @ (posedge clk)
begin	  
   if(i_vld)
        begin
	        if(!i_din[15])
	        	abs_q <= i_din[15:0];
            else
            abs_q <= ~i_din[15:0]; 
        end
    else
        abs_q <= 16'b0;
end 


always @ (posedge clk)
    i_eop_d1 <= i_eop;

always @ (posedge clk)
begin
  if(rst)
    abs_i_max <= 16'b0;
	else if(i_eop_d1)
		abs_i_max <= 16'b0;
	else
		abs_i_max <= (abs_i | abs_i_max);
end

always @ (posedge clk)
begin
  if(rst)
    abs_q_max <= 16'b0;
	else if(i_eop_d1)
		abs_q_max <= 16'b0;
	else
		abs_q_max <= (abs_q | abs_q_max);
end
//------------------------------------------------------------------------------//
//Find the maximum value in a RB-24 data
always @ (posedge clk)
begin
    if(rst)
        max_value_i <= 16'b0;
    else if(i_eop_d1)
        max_value_i <= (abs_i | abs_i_max);
    else
        max_value_i <= max_value_i;
end

always @ (posedge clk)
begin
    if(rst)
        max_value_q <= 16'b0;
    else if(i_eop_d1)
        max_value_q <= (abs_q | abs_q_max);
    else
        max_value_q <= max_value_q;
end

always @ (posedge clk)
	max_value_iq <= (max_value_q | max_value_i);

always @ (posedge clk)                      
begin
    casex(max_value_iq[15:6])//14-0;14-n=shift
        10'b0000000001 : shift_num <= 4'd8;  
        10'b000000001x : shift_num <= 4'd7;  
        10'b00000001xx : shift_num <= 4'd6;  
        10'b0000001xxx : shift_num <= 4'd5;  
        10'b000001xxxx : shift_num <= 4'd4;  
        10'b00001xxxxx : shift_num <= 4'd3;  
        10'b0001xxxxxx : shift_num <= 4'd2;        
        10'b001xxxxxxx : shift_num <= 4'd1;   
        10'b01xxxxxxxx : shift_num <= 4'd0;   
        10'b1xxxxxxxxx : shift_num <= 4'd0;
        default 	     : shift_num <= 4'd9;
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
    rx_vld_dly <= {rx_vld_dly[10:0],i_vld};  


always @ (posedge clk)
begin
	if(rst)
        rd_addr <= 5'd0;
    else if (rx_vld_dly[11])
        rd_addr <= rd_addr + 5'd1;       
    else
        rd_addr <= rd_addr;
end

always@(posedge clk)
begin
    data_shift_i <= data_dly[31:16] << shift_num;
    data_shift_q <= data_dly[15: 0] << shift_num;
end
//example
//result bit[15]-bit[9]     
//rounding off--bit[8]
//16-7=9
always@(posedge clk)
begin
    if(data_shift_i[15] == 1'b0 && data_shift_i[15-Num])begin// pose
        if(data_shift_i[14:16-Num]=={(Num-1){1'b1}}) // pos max
            rounding_i <= 16'h0000;
        else
            rounding_i <= 16'h0200;
    end else if(data_shift_i[15] == 1'b1 && data_shift_i[15-Num] && (|data_shift_i[15-Num-1:0]) ) // neg
        rounding_i <= 16'h0200;
    else
        rounding_i <= 16'h0000; 

//    if(data_shift_i[15-1:(15-Num+1)] == {1'b1,1'b1,{(Num-3){1'b1}}})
//        rounding_i <= 16'h0000;
//    else
//        rounding_i <= 16'h0100;
end

always@(posedge clk)
begin          
    if(data_shift_q[15] == 1'b0 && data_shift_q[15-Num])begin // pose
        if(data_shift_q[14:16-Num]=={(Num-1){1'b1}}) // pos max
            rounding_q <= 16'h0000;
        else
            rounding_q <= 16'h0200;
    end else if(data_shift_q[15] == 1'b1 && data_shift_q[15-Num] && (|data_shift_q[15-Num-1:0]) ) // neg
        rounding_q <= 16'h0200;
    else
        rounding_q <= 16'h0000; 
//        
//    if(data_shift_q[15-1:(15-Num+1)] == {1'b1,1'b1,{(Num-3){1'b1}}})
//        rounding_q <= 16'h0000;
//    else
//        rounding_q <= 16'h0100;
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
    o_dout <= {result_i0[15:(15-Num+1)],result_q0[15:(15-Num+1)]};   
   
always@(posedge clk)
begin
    max_shift_dly1 <= shift_num   ;
    max_shift_dly2 <= max_shift_dly1;
    max_shift_dly3 <= max_shift_dly2;
    o_shift        <= max_shift_dly3;
end

//------------------------------------------------------------------------------//
//--intel:dram/fifo
 Simple_Dual_Port_BRAM_XPM_intel
  #(   
     .WDATA_WIDTH          (32                       ),
     .NUMWORDS_A           (32                       ),
     .RDATA_WIDTH          (32                       ),
     .NUMWORDS_B           (32                       ),
     .INI_FILE             (                         )
 ) 
 u_bram_bit_32w_128d 
 (                                                  
     .clock                 (clk                      ),
     .wren                  ({(32/8){i_vld}}          ),
     .wraddress             (wr_addr                  ),
     .data                  (i_din                    ),
     .rdaddress             (rd_addr                  ),
     .q                     (data_dly                 )
 );  
//------------------------------------------------------------------------------//
//--xilinx:dram/fifo
// Simple_Dual_Port_DRAM_XPM
//  #(    
//     .MEMORY_SIZE          (32*(2**5)                ),
//     .WDATA_WIDTH          (32                       ),
//     .WADDR_WIDTH          (5                        ),
//     .RDATA_WIDTH          (32                       ),
//     .RADDR_WIDTH          (5                        ),
//     .READ_LATENCY         (3                        ),
//     .BYTE_WRITE_WIDTH_A   (8                        )
// ) 
// u_bram_bit_32w_128d 
// (                                                  
//     .clk                  (clk                      ),
//     .wea                  ({(32/8){i_vld}}          ),
//     .addra                (wr_addr                  ),
//     .dina                 (i_din                    ),
//     .addrb                (rd_addr                  ),
//     .doutb                (data_dly                 )
// );  

//------------------------------------------------------------------------------//
//--fifo 
register_shift
#(
    .WIDTH        (4                   ),
    .DEPTH        (19                  )                
)
u_dly_vld
(                                       
	  .clk          (clk                 ),
	  .in           ({i_sel,i_sop,i_eop,i_vld} ),
	  .out          ({o_sel,o_sop,o_eop,o_vld} )
);


register_shift
#(
    .WIDTH        (7                   ),
    .DEPTH        (19                  ) 
)
u_dly_slot
(               
	  .clk          (clk                 ),
	  .in           (i_slot_idx          ),
	  .out          (o_slot_idx          ) 
);
     
register_shift
#(
    .WIDTH        (4                   ),
    .DEPTH        (19                  ) 
)
u_dly_sym
(               
	  .clk          (clk                 ),
	  .in           (i_symb_idx          ),
	  .out          (o_symb_idx          ) 
);

register_shift
#(
    .WIDTH        (9                   ),
    .DEPTH        (19                  ) 
)                                        
u_dly_prb                                
(                                        
	  .clk          (clk                 ),
	  .in           (i_prb_idx           ),
	  .out          (o_prb_idx           ) 
);

register_shift
#(
    .WIDTH        (4                   ),
    .DEPTH        (19                  )
)                                       
u_dly_ch_type                            
(                                        
	  .clk          (clk                 ),      
	  .in           (i_ch_type           ),
	  .out          (o_type              ) 
);                                   
//--info null
register_shift
#(
    .WIDTH        (8                   ),
    .DEPTH        (19                  ) 
)                                        
u_dly_i_info                              
(                                        
	  .clk          (clk                 ),
	  .in           (i_info              ),
	  .out          (o_info              ) 
);

endmodule
