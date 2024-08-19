//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-12
//File name       :  loop_buffer_sync.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

module loop_buffer_sync #
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
    input  wire                             syn_rst         ,
    input  wire                             clk             ,
                                            
    input  wire[WADDR_WIDTH-1:0]            wr_addr         ,
    input  wire[WDATA_WIDTH-1:0]            wr_data         ,
    input  wire                             wr_wen          ,
    input  wire                             wr_wlast        ,
    input  wire[INFO_WIDTH-1:0]             wr_info         ,                   
    output reg [LOOP_WIDTH-WADDR_WIDTH:0]   free_size       ,

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


always @ (posedge clk)
    begin
        if (syn_rst == 1'b1)
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
always @ (posedge clk)
    begin
        if (syn_rst == 1'b1)
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
always @ (posedge clk)
    begin
        if (syn_rst == 1'b1)
            rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= {LOOP_WIDTH-WADDR_WIDTH{1'b0}};
        else
            begin
                if (rd_rdy && (!rd_empty))// free_size != {1'b1,{LOOP_WIDTH-WADDR_WIDTH{1'b0}}}
                    rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] + 1'b1;  
                else
                    rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0] <= rbadr[LOOP_WIDTH-WADDR_WIDTH-1:0];
            end
    end

   
                                                       
FIFO_SYNC_XPM #(
    .FIFO_DEPTH            (FIFO_DEPTH        ),
    .DATA_WIDTH            (FIFO_WIDTH        )
)INST_INFO                                            
(                                                                   
    .rst                   (syn_rst           ),
    .clk                   (clk               ),
    .wr_en                 (wr_wlast          ),
    .din                   (wr_info           ),
    .rd_en                 (rd_rdy            ),
    .dout                  (rd_info           ),
    .dout_valid            (rd_vld            ),
    .empty                 (rd_empty          ),
    .full                  (wr_full           )
);    



//---------------------------------------------------------------------------//
//--MEMORY_TYPE 
generate 

begin :MEMORY_TYPE               
if (RAM_TYPE == 0) 

//------------------------------------------------------------------------------//
//--DRAM

 Simple_Dual_Port_DRAM_XPM
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
     .clk                  (clk                                     ),
     .wea                  ({(WDATA_WIDTH/BYTE_WRITE_WIDTH){wr_wen}}),
     .addra                ({wbadr,wr_addr}                         ),     
     .dina                 (wr_data[WDATA_WIDTH-1:0]                ),
     .addrb                ({rbadr,rd_addr}                         ),
     .doutb                (rd_data[RDATA_WIDTH-1:0]                )
 );
 
else if (RAM_TYPE == 1) 
    
//------------------------------------------------------------------------------//
//--BRAM

 Simple_Dual_Port_BRAM_XPM
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
     .clk                  (clk                                     ),
     .wea                  ({(WDATA_WIDTH/BYTE_WRITE_WIDTH){wr_wen}}),
     .addra                ({wbadr,wr_addr}                         ),     
     .dina                 (wr_data[WDATA_WIDTH-1:0]                ),
     .addrb                ({rbadr,rd_addr}                         ),
     .doutb                (rd_data[RDATA_WIDTH-1:0]                )
 );
    

else 
//------------------------------------------------------------------------------//
//--URAM


 Simple_Dual_Port_URAM_XPM
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
     .clk                  (clk                                     ),
     .wea                  ({(WDATA_WIDTH/BYTE_WRITE_WIDTH){wr_wen}}),
     .addra                ({wbadr,wr_addr}                         ),     
     .dina                 (wr_data[WDATA_WIDTH-1:0]                ),
     .addrb                ({rbadr,rd_addr}                         ),
     .doutb                (rd_data[RDATA_WIDTH-1:0]                )
 );


end

endgenerate

//---------------------------------------------------------------------------//




endmodule
