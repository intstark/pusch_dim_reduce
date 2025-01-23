//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/28 15:54:23
// Design Name: 
// Module Name: lp_buffer_syn 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Delay 1 write cycle, No matter how many clock cycles between 2 write cycles
//                 __               __               __ 
// din  _ _ _ _ _ |  |_ _ _ _ _ _ _|  |_ _ _ _ _ _ _|  |_ _ _ _ _ _ __ _ _ _ _ _ _
//
//                                  __               __               __
// dout _ _ _ _ _ _ _ _ _ _ _ _ _ _|  |_ _ _ _ _ _ _|  |_ _ _ _ _ _ _|  |_ _ _ _ _
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lp_buffer_syn # (
    parameter DATA_WIDTH     = 32,
    parameter ADDR_WIDTH     = 64
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [DATA_WIDTH-1: 0]                i_wr_data               ,
    input                                           i_wr_wen                ,
    input                                           i_wr_vld                ,

    output         [DATA_WIDTH-1: 0]                o_rd_data               ,
    output                                          o_rd_vld                ,
    output                                          o_rd_sop                 
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
localparam DATA_DEPTH     = 1 << ADDR_WIDTH ;
genvar idx;



reg            [DATA_WIDTH-1: 0]                wr_data1              =0;
reg            [DATA_WIDTH-1: 0]                wr_data2              =0;
reg            [ADDR_WIDTH-1: 0]                wr_addr               =0;
reg            [ADDR_WIDTH-1: 0]                rd_addr               =0;
reg                                             rd_ren                =0;
reg                                             wr_wen                =0;
wire           [DATA_WIDTH-1: 0]                rd_data                 ;
wire                                            empty                   ;
wire                                            full                    ;


//--------------------------------------------------------------------------------------
// Store the index of sorted beams to BRAM
//--------------------------------------------------------------------------------------
always @(posedge i_clk)begin
    if(i_reset)
        wr_wen <= 1'b0;
    else if(i_wr_vld)
        wr_wen <= 1'b1;
    else
        wr_wen <= 1'b0;
end

always @(posedge i_clk)begin
    if(i_reset)
        wr_addr <= {ADDR_WIDTH{1'b0}};
    else if(!i_wr_vld)
        wr_addr <= {ADDR_WIDTH{1'b0}};
    else if(i_wr_wen)
        wr_addr <= wr_addr + 'd1;
end

always @(posedge i_clk)begin
    wr_data1 <= i_wr_data;
    wr_data2 <= wr_data1;
end


always @(posedge i_clk)begin
    if(i_reset)
        rd_ren <= 1'b0;
    if(empty)
        rd_ren <= 1'b0;
    else if(wr_addr==1 && i_wr_wen)
        rd_ren <= 1'b1;
end

always @(posedge i_clk)begin
    if(i_reset)
        rd_addr <= {ADDR_WIDTH{1'b0}};
    else if(empty)
        rd_addr <= {ADDR_WIDTH{1'b0}};
    else if(rd_ren)
        rd_addr <= wr_addr - 'd1;
end



//--------------------------------------------------------------------------------------
// bram for beams index: 4 clock cycle delay
//--------------------------------------------------------------------------------------
FIFO_SYNC_XPM_intel #(
    .NUMWORDS                                           (DATA_DEPTH             ),
    .DATA_WIDTH                                         (DATA_WIDTH             )
)INST_INFO                                            
(                                                                   
    .rst                                                (i_reset                ),
    .clk                                                (i_clk                  ),
    .wr_en                                              (wr_wen                 ),
    .din                                                (wr_data2               ),
    .rd_en                                              (rd_ren                 ),
    .dout                                               (rd_data                ),
    .dout_valid                                         (                       ),
    .empty                                              (empty                  ),
    .full                                               (full                   ),
    .usedw                                              (                       ),
    .almost_full                                        (                       ),
    .almost_empty                                       (                       ) 
);  

assign o_rd_data = rd_data;


endmodule