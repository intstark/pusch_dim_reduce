`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2024-04-25
//File name       :  pcie_bf_para.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------
module pcie_bf_para 
(

  input   wire                    w_clk               ,
  input   wire                    w_rst               , 
  input   wire                    r_clk               , 
  input   wire                    r_rst               , 
  input   wire [511:0]            pcie_data           , 
  input   wire [63:0]             pcie_keep           ,
  input   wire                    pcie_valid          ,
  input   wire                    pcie_last           ,

  input   wire                    bit_rrdy             ,
  input   wire [16:0]             bit_raddr            ,
  output  wire [31:0]             bit_rdata            ,
  output  wire                    bit_rvld             ,
  output  wire [23:0]	            bit_rinfo            ,
  output  wire [1:0]              free_size             //--2bit

       
 );
 


//---------------------------------------------------------------------------//
//--FSM state
localparam IDLE   	  = 4'b0001;
localparam READ_DATA 	= 4'b0010;
localparam ADD_CP 	  = 4'b0100;
localparam FSM_END	  = 4'b1000;


//------------------------------------------------------------------------------//
 reg     [3:0]            cs,ns            ;
 reg                      info=0           ;
 reg     [9:0]            start            ;
 reg     [23:0]           winfo            ;   
 reg                      wlast            ; 
 reg                      w_valid_0        ;
 reg                      w_valid_1        ;
 reg     [12:0]           waddr_0=0        ;
 reg     [12:0]           waddr_1=0        ;
 reg     [16:0]           raddr_0=0        ;
 reg     [16:0]           raddr_1=0        ;
 wire    [31:0]           r_data_0         ;    
 wire    [31:0]           r_data_1         ;    
 reg     [63:0]           wen_byte_0       ;
 reg     [63:0]           wen_byte_1       ;
 reg     [511:0]          pcie_data_0      ; 
 wire    [511:0]          pcie_data_1      ; 
 reg     [511:0]          pcie_data_d1     ;  
 reg     [3:0]            w_cnt            ;
 reg     [3:0]            w_cnt_d1         ;




//------------------------------------------------------------------------------//
//--      

always @ (posedge w_clk )
 begin 
     if (w_rst==1'd1) 
        w_cnt <= 4'd0;   
     else if (pcie_valid)       
        w_cnt <=w_cnt +	4'd1; 
     else
        w_cnt <= 0;                     	                                                            				  
 end


always @ (posedge w_clk )
  w_cnt_d1 <= w_cnt;

always @ (posedge w_clk )
 begin 
     if ((w_cnt>=0 && w_cnt<=4) && pcie_valid==1'd1 )       
        w_valid_0 <= 1'd1; 
     else
        w_valid_0 <= 1'd0; 
 end

always @ (posedge w_clk )
 begin 
     if ((w_cnt>=4 && w_cnt<=8) && pcie_valid==1'd1 )       
        w_valid_1 <= 1'd1; 
     else
        w_valid_1 <= 1'd0; 
 end



always @ (posedge w_clk )
 begin 
  pcie_data_0  <= pcie_data;
 end   

always @ (posedge w_clk )
 begin 
  pcie_data_d1 <= pcie_data;
 end    
assign   pcie_data_1   = {pcie_data[63:0],pcie_data_d1[511:64]};
   
       
always @ (posedge w_clk )
 begin 
     if (w_rst==1'd1) 
        waddr_0 <= 13'd0;        
     else if (w_valid_0==1'd1)       
        waddr_0 <= waddr_0 +1'd1; 
     else
        waddr_0 <= waddr_0;                     	                                                            				  
 end

always @ (posedge w_clk )
 begin 
     if (w_rst==1'd1) 
        waddr_1 <= 13'd0;        
     else if (w_valid_1==1'd1)       
        waddr_1 <= waddr_1 +1'd1; 
     else
        waddr_1 <= waddr_1;                     	                                                            				  
 end


//--66=16*4+2,16-2=14
//--132=16*8+4,16-4=12
always @ (* )
 begin 
     if (w_cnt == 4'd5)      
        wen_byte_0 <=  { {56{1'd0}} ,{8{w_valid_0}} } ; //64bit-vld     
     else
        wen_byte_0 <=  {64{w_valid_0} } ;                 	                                                            				  
 end 

always @ (* )
 begin 
     if (w_cnt == 4'd9)      
        wen_byte_1 <=  { {56{1'd0}} ,{16{w_valid_1}} } ;//128bit-vid     
     else
        wen_byte_1 <=  {64{w_valid_1} } ;                 	                                                            				  
 end

always @ (posedge w_clk )
 begin 
     if (pcie_last==1'd1)       
        raddr_0 <=17'd1; 
     else if (raddr_0 == 17'd79)//16*5
        raddr_0 <=17'd0 ;             
     else if (raddr_0 != 17'd0)
        raddr_0 <=raddr_0 +1'd1 ;                             	                                                            				  
 end

always @ (posedge w_clk )
 begin 
     if (pcie_last==1'd1)       
        raddr_1 <=17'd1; 
     else if (raddr_1 == 17'd79)//16*5
        raddr_1 <=17'd0 ;             
     else if (raddr_1 != 17'd0)
        raddr_1 <=raddr_1 +1'd1 ;                             	                                                            				  
 end


//------------------------------------------------------------------------------//
 Simple_Dual_Port_URAM_XPM
  #(    
     .MEMORY_SIZE          (512*(2**13)            ),
     .WDATA_WIDTH          (512                    ),
     .WADDR_WIDTH          (13                     ),
     .RDATA_WIDTH          (32                     ),
     .RADDR_WIDTH          (17                     ),
     .READ_LATENCY         (3                      ),
     .BYTE_WRITE_WIDTH_A   (8                      )
 ) 
 INST_CP_SDP_DRAM_32_1024_EVEN                                          
 (                                                                   
     .clk                  (w_clk                  ),
     .wea                  (wen_byte_0             ),
     .addra                (waddr_0                ),
     .dina                 (pcie_data_0            ),
     .addrb                (raddr_0                ),
     .doutb                (r_data_0               )
 );  


//------------------------------------------------------------------------------//
 Simple_Dual_Port_URAM_XPM
  #(    
     .MEMORY_SIZE          (512*(2**13)            ),
     .WDATA_WIDTH          (512                    ),
     .WADDR_WIDTH          (13                     ),
     .RDATA_WIDTH          (32                     ),
     .RADDR_WIDTH          (17                     ),
     .READ_LATENCY         (3                      ),
     .BYTE_WRITE_WIDTH_A   (8                      )
 ) 
 INST_CP_SDP_DRAM_32_1024_ODD                                         
 (                                                                   
     .clk                  (w_clk                  ),
     .wea                  (wen_byte_1             ),
     .addra                (waddr_1                ),
     .dina                 (pcie_data_1            ),
     .addrb                (raddr_1                ),
     .doutb                (r_data_1               )
 ); 




endmodule 