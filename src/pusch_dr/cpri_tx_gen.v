`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  All rights reserved.
//Creation Date   :  2024-03-06
//File name       :  cpri_tx_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

//100*(150*256)*(96*64)-chip=1s
//10ms=80slot --> (150*256)*(96*64)=38400chip
//125us=1slot -->38400/80=480chip

module cpri_tx_gen
(
    input   wire            wr_clk            ,
    input   wire            wr_rst            ,  
    input   wire            rd_clk            ,
    input   wire            rd_rst            ,      
    input   wire            i_cpri_wen        ,
    input   wire  [6:0]     i_cpri_waddr      ,
    input   wire  [63:0]    i_cpri_wdata      ,
    input   wire            i_cpri_wlast      ,

	  input	  wire            i_iq_tx_enable    ,	
		output	wire            o_iq_tx_valid     ,
	  output	wire  [63:0]    o_iq_tx_data     

);

    localparam  WDATA_WIDTH        =  64   ; 
    localparam  WADDR_WIDTH        =  7    ; 
    localparam  RDATA_WIDTH        =  64   ; 
    localparam  RADDR_WIDTH        =  7    ; 
    localparam  READ_LATENCY       =  3    ; 
    localparam  FIFO_DEPTH         =  16   ; 
    localparam  FIFO_WIDTH         =  1    ; 
    localparam  LOOP_WIDTH         =  10   ; 
    localparam  INFO_WIDTH         =  1    ; 
    localparam  RAM_TYPE           =  1    ; 
  

wire [63:0]  cpri_rdata                           ;
wire         cpri_rinfo                           ;
reg          cpri_rdy                             ;
wire         cpri_rvld                            ;
reg          cpri_rvld_d1                         ;
reg          cpri_rvld_d2                         ;
reg          cpri_rvld_d3                         ;
reg          rd_valid                             ;
reg  [6:0]   cpri_raddr                           ;
wire         [LOOP_WIDTH-WADDR_WIDTH:0] free_size ;
   
//-----------------------------------------------------------------------------
//--

loop_buffer_async_intel #
//loop_buffer_async #
(
    .WDATA_WIDTH                (WDATA_WIDTH                     ),
    .WADDR_WIDTH                (WADDR_WIDTH                     ),
    .RDATA_WIDTH                (RDATA_WIDTH                     ),
    .RADDR_WIDTH                (RADDR_WIDTH                     ),
    .READ_LATENCY               (READ_LATENCY                    ),    
    .FIFO_DEPTH                 (FIFO_DEPTH                      ),
    .FIFO_WIDTH                 (FIFO_WIDTH                      ),
    .LOOP_WIDTH                 (LOOP_WIDTH                      ),
    .INFO_WIDTH                 (INFO_WIDTH                      ),
    .RAM_TYPE                   (RAM_TYPE                        )
)u_cpri_tx_ram
(
    .wr_rst                     (wr_rst                          ),
    .wr_clk                     (wr_clk                          ),  
    .rd_rst                     (rd_rst                          ), 
    .rd_clk                     (rd_clk                          ),     
    .wr_wen                     (i_cpri_wen                      ),
    .wr_addr                    (i_cpri_waddr                    ),
    .wr_data                    (i_cpri_wdata                    ),  
    .wr_wlast                   (i_cpri_wlast                    ),
    .wr_info                    (i_cpri_wlast                    ),
    .free_size                  (free_size                       ),    
    .rd_addr                    (cpri_raddr                      ),
    .rd_data                    (cpri_rdata                      ),
    .rd_vld                     (cpri_rvld                       ),
    .rd_info                    (cpri_rinfo                      ),
    .rd_rdy                     (cpri_rdy                        )    
 
);
//-----------------------------------------------------------------------------

always @ (posedge rd_clk)
    begin
        if( rd_rst )
            rd_valid <= 1'd0;     
        else if( i_iq_tx_enable && cpri_rvld )
            rd_valid <= 1'd1; 
        else if(cpri_rvld == 1'd0)
            rd_valid <= 1'd0;  
        else 
            rd_valid <= rd_valid;                                                                      
    end
    
//skip head-0-1-2
always @ (posedge rd_clk)
    begin
        if(rd_valid && cpri_rvld)
            if(cpri_raddr == 7'd98)
                cpri_raddr <= 7'd3;
            else
                cpri_raddr <= cpri_raddr + 7'd1;
        else
                cpri_raddr <= 7'd3;                                                        
    end

always @ (posedge rd_clk)
 if (cpri_rvld && (cpri_raddr == 7'd97))
       cpri_rdy <= 1'd1;  
 else
       cpri_rdy <= 1'd0;  

assign    o_iq_tx_data  = cpri_rdata;
assign    o_iq_tx_valid = rd_valid && cpri_rvld;

always @ (posedge rd_clk)
  begin
    cpri_rvld_d1  <= rd_valid   ;
    cpri_rvld_d2  <= cpri_rvld_d1;
    cpri_rvld_d3  <= cpri_rvld_d2;
  end

           
                   
endmodule