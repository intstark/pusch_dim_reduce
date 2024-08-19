//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-12
//File name       :  loop_buffer_async.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

module loop_buffer_async #
(                                
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  8    ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  8    ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer BYTE_WRITE_WIDTH   =  8    ,   
    parameter integer FIFO_DEPTH         =  16   ,
    parameter integer FIFO_WIDTH         =  256  ,
    parameter integer LOOP_WIDTH         =  9    ,    
    parameter integer INFO_WIDTH         =  256  ,
    parameter integer RAM_TYPE           =  1


)
(
    input  wire                             wr_rst          ,
    input  wire                             wr_clk          ,
                                            
    input  wire[WADDR_WIDTH-1:0]            wr_addr         ,
    input  wire[WDATA_WIDTH-1:0]            wr_data         ,
    input  wire                             wr_wen          ,
    input  wire                             wr_wlast        ,
    input  wire[INFO_WIDTH-1:0]             wr_info         ,                   
    output reg [LOOP_WIDTH-WADDR_WIDTH:0]   free_size       ,
    input  wire                             rd_rst          ,
    input  wire                             rd_clk          ,
                                            
    input  wire[RADDR_WIDTH-1:0]            rd_addr         ,
    output wire[RDATA_WIDTH-1:0]            rd_data         ,
    output wire                             rd_vld          ,
    output wire[INFO_WIDTH-1:0]             rd_info         ,                   
    input  wire                             rd_rdy          
);

//---------------------------------------------------------------------------//
//--                                           
reg [LOOP_WIDTH-WADDR_WIDTH-1:0]            wbadr;
reg [LOOP_WIDTH-WADDR_WIDTH-1:0]            rbadr;
                                           
wire                                        rd_empty;
wire                                        wr_full;


always @ (posedge wr_clk)
    begin
        if (wr_rst == 1'b1)
            free_size[LOOP_WIDTH-WADDR_WIDTH:0] <= {1'b1,{LOOP_WIDTH-WADDR_WIDTH{1'b0}}};
        else
            begin
                case ({rd_rdy,wr_wlast})
                    2'b01:  begin
                              if(free_size != 'd0)
                                free_size[LOOP_WIDTH-WADDR_WIDTH:0] <= free_size[LOOP_WIDTH-WADDR_WIDTH:0] - 1'b1;                                
                            end
                    2'b10:  begin
                              if(free_size != {1'b1,{LOOP_WIDTH-WADDR_WIDTH{1'b0}}})
                                free_size[LOOP_WIDTH-WADDR_WIDTH:0] <= free_size[LOOP_WIDTH-WADDR_WIDTH:0] + 1'b1;
                            end
                    default:free_size[LOOP_WIDTH-WADDR_WIDTH:0] <= free_size[LOOP_WIDTH-WADDR_WIDTH:0];
                endcase
            end
    end 



//---------------------------------------------------------------------------//
//--
always @ (posedge wr_clk)
    begin
        if (wr_rst == 1'b1)
            wbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= {LOOP_WIDTH-WADDR_WIDTH{1'b0}};
        else
            begin
                if (wr_wlast && (!wr_full))// && free_size != 'd0
                    wbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= wbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] + 1'b1;
                else
                    wbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= wbadr[LOOP_WIDTH-WADDR_WIDTH-1:0];
            end
    end

//---------------------------------------------------------------------------//
//--
always @ (posedge rd_clk)
    begin
        if (rd_rst == 1'b1)
            rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= {LOOP_WIDTH-WADDR_WIDTH{1'b0}};
        else
            begin
                if (rd_rdy && (!rd_empty))// free_size != {1'b1,{LOOP_WIDTH-WADDR_WIDTH{1'b0}}}
                    rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] + 1'b1;  
                else
                    rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0];
            end
    end


FIFO_ASYNC_XPM #(
    .FIFO_DEPTH            (FIFO_DEPTH                       ),
    .DATA_WIDTH            (FIFO_WIDTH                       )
)INST_INFO                                      
(                                                             
    .rst                   (wr_rst                           ),
    .wclk                  (wr_clk                           ),
    .wr_en                 (wr_wlast                         ),
    .din                   (wr_info                          ),
    .rclk                  (rd_clk                           ),
    .rd_en                 (rd_rdy                           ),
    .dout                  (rd_info                          ),
    .dout_valid            (rd_vld                           ),
    .empty                 (rd_empty                         ),
    .full                  (wr_full                          )
);                                                           



//---------------------------------------------------------------------------//
//--MEMORY_TYPE 
generate 

begin :MEMORY_TYPE               
if (RAM_TYPE == 0) 

//------------------------------------------------------------------------------//
//--DRAM

 ASYNC_Dual_Port_DRAM_XPM
  #(    
     .MEMORY_SIZE          (WDATA_WIDTH*(2**LOOP_WIDTH)             ),
     .WDATA_WIDTH          (WDATA_WIDTH                             ),
     .WADDR_WIDTH          (LOOP_WIDTH                              ),
     .RDATA_WIDTH          (RDATA_WIDTH                             ),
     .RADDR_WIDTH          (LOOP_WIDTH                              ),
     .READ_LATENCY         (READ_LATENCY                            ),
     .BYTE_WRITE_WIDTH_A   (BYTE_WRITE_WIDTH                        )     
 ) 
 INST_DRAM                                          
 (                                                                   
     .wclk                 (wr_clk                                  ),
     .wea                  ({(WDATA_WIDTH/BYTE_WRITE_WIDTH){wr_wen}}),
     .addra                ({wbadr,wr_addr}                         ),     
     .dina                 (wr_data[WDATA_WIDTH-1:0]                ),
     .rclk                 (rd_clk                                  ),    
     .addrb                ({rbadr,rd_addr}                         ),
     .doutb                (rd_data[RDATA_WIDTH-1:0]                )
 );
 
else if (RAM_TYPE == 1) 
    
//------------------------------------------------------------------------------//
//--BRAM

 ASYNC_Dual_Port_BRAM_XPM
  #(    
     .MEMORY_SIZE          (WDATA_WIDTH*(2**LOOP_WIDTH)             ),
     .WDATA_WIDTH          (WDATA_WIDTH                             ),
     .WADDR_WIDTH          (LOOP_WIDTH                              ),
     .RDATA_WIDTH          (RDATA_WIDTH                             ),
     .RADDR_WIDTH          (LOOP_WIDTH                              ),
     .READ_LATENCY         (READ_LATENCY                            ),
     .BYTE_WRITE_WIDTH_A   (BYTE_WRITE_WIDTH                        )     
 ) 
 INST_BRAM                                          
 (                                                                   
     .wclk                 (wr_clk                                  ),
     .wea                  ({(WDATA_WIDTH/BYTE_WRITE_WIDTH){wr_wen}}),
     .addra                ({wbadr,wr_addr}                         ),     
     .dina                 (wr_data[WDATA_WIDTH-1:0]                ),
     .rclk                 (rd_clk                                  ),    
     .addrb                ({rbadr,rd_addr}                         ),
     .doutb                (rd_data[RDATA_WIDTH-1:0]                )
 );
    

else 
//------------------------------------------------------------------------------//
//--URAM


 ASYNC_Dual_Port_URAM_XPM
  #(    
     .MEMORY_SIZE          (WDATA_WIDTH*(2**LOOP_WIDTH)             ),
     .WDATA_WIDTH          (WDATA_WIDTH                             ),
     .WADDR_WIDTH          (LOOP_WIDTH                              ),
     .RDATA_WIDTH          (RDATA_WIDTH                             ),
     .RADDR_WIDTH          (LOOP_WIDTH                              ),
     .READ_LATENCY         (READ_LATENCY                            ),
     .BYTE_WRITE_WIDTH_A   (BYTE_WRITE_WIDTH                        )     
 ) 
 INST_URAM                                          
 (                                                                   
     .wclk                 (wr_clk                                  ),
     .wea                  ({(WDATA_WIDTH/BYTE_WRITE_WIDTH){wr_wen}}),
     .addra                ({wbadr,wr_addr}                         ),     
     .dina                 (wr_data[WDATA_WIDTH-1:0]                ),
     .rclk                 (rd_clk                                  ),    
     .addrb                ({rbadr,rd_addr}                         ),
     .doutb                (rd_data[RDATA_WIDTH-1:0]                )
 );


end

endgenerate

//---------------------------------------------------------------------------//




endmodule
