//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-12
//File name       :  loop_buffer_sync_intel.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

module loop_buffer2_sync_intel #
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
    input  wire                                     syn_rst                 ,
    input  wire                                     clk                     ,
                                            
    input  wire    [WADDR_WIDTH-1: 0]               wr_addr                 ,
    input  wire    [WDATA_WIDTH-1: 0]               wr_data                 ,
    input  wire                                     wr_wen                  ,
    input  wire                                     wr_wlast                ,
    input  wire    [INFO_WIDTH-1: 0]                wr_info                 ,
    output reg     [LOOP_WIDTH-WADDR_WIDTH: 0]      free_size               ,

    input  wire    [RADDR_WIDTH-1: 0]               rd_addr                 ,
    output wire    [RDATA_WIDTH-1: 0]               rd_data                 ,
    output wire                                     rd_vld                  ,
    output wire    [INFO_WIDTH-1: 0]                rd_info                 ,
    input  wire                                     rd_rdy                   
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

reg                                             wr_proc               =0;
reg                                             wr_wen_r              =0;
reg                                             wr_proc_r             =0;
wire                                            wr_pos                  ;
wire                                            fifo_wen                ;
reg [15:0] wr_cnt = 0;

always @(posedge clk)begin
    wr_wen_r <= wr_wen;
    wr_proc_r <= wr_proc;
    if(wr_pos)
        wr_proc <= 1'b1;
    else if(wr_wlast)
        wr_proc <= 1'b0;
end

always @(posedge clk)begin
    if(wr_wlast)
        wr_cnt <= 0;
    else if(wr_wen)
        wr_cnt <= wr_cnt + 1'b1;
    
end


assign wr_pos = wr_wen & (~wr_wen_r);
assign fifo_wen = (wr_cnt == 16'd500) ? 1'b1: 1'b0; 


FIFO_SYNC_XPM_intel #(
    .NUMWORDS                                           (FIFO_DEPTH             ),
    .DATA_WIDTH                                         (FIFO_WIDTH             ) 
)INST_INFO
(
    .rst                                                (syn_rst                ),
    .clk                                                (clk                    ),
    .wr_en                                              (fifo_wen               ),
    .din                                                (1'b1                   ),
    .rd_en                                              (rd_rdy                 ),
    .dout                                               (rd_info                ),
    .dout_valid                                         (rd_vld                 ),
    .empty                                              (rd_empty               ),
    .full                                               (wr_full                ),
    .usedw                                              (                       ),
    .almost_full                                        (                       ),
    .almost_empty                                       (                       ) 
);



//---------------------------------------------------------------------------//
//--MEMORY_TYPE 
generate 

begin :MEMORY_TYPE               
if (RAM_TYPE == 0) 

//------------------------------------------------------------------------------//
//--DRAM

Simple_Dual_Port_BRAM_XPM_intel
#(
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_A                                         ((2**LOOP_WIDTH)        ),
    .RDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_B                                         ((2**LOOP_WIDTH)        ),
    .INI_FILE                                           (                       ) 


)
INST_DRAM
(
    .clock                                              (clk                    ),
    .wren                                               (wr_wen                 ),
    .wraddress                                          ({wbadr,wr_addr}        ),
    .data                                               (wr_data[WDATA_WIDTH-1:0]),
    .rdaddress                                          ({rbadr,rd_addr}        ),
    .q                                                  (rd_data[RDATA_WIDTH-1:0]) 
);
 
else if (RAM_TYPE == 1) 
    
//------------------------------------------------------------------------------//
//--BRAM
Simple_Dual_Port_BRAM_XPM_intel
#(
    
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_A                                         ((2**LOOP_WIDTH)        ),
    .RDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_B                                         ((2**LOOP_WIDTH)        ),
    .INI_FILE                                           (                       ) 

)
INST_BRAM
(
    .clock                                              (clk                    ),
    .wren                                               (wr_wen                 ),
    .wraddress                                          ({wbadr,wr_addr}        ),
    .data                                               (wr_data[WDATA_WIDTH-1:0]),
    .rdaddress                                          ({rbadr,rd_addr}        ),
    .q                                                  (rd_data[RDATA_WIDTH-1:0]) 
);


else
//------------------------------------------------------------------------------//
//--URAM


Simple_Dual_Port_BRAM_XPM_intel
#(
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_A                                         ((2**LOOP_WIDTH)        ),
    .RDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_B                                         ((2**LOOP_WIDTH)        ),
    .INI_FILE                                           (                       ) 

)
INST_URAM
(
    .clock                                              (clk                    ),
    .wren                                               (wr_wen                 ),
    .wraddress                                          ({wbadr,wr_addr}        ),
    .data                                               (wr_data[WDATA_WIDTH-1:0]),
    .rdaddress                                          ({rbadr,rd_addr}        ),
    .q                                                  (rd_data[RDATA_WIDTH-1:0]) 
);


end

endgenerate

//---------------------------------------------------------------------------//




endmodule
