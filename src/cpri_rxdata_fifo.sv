//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: cpri_rxdata_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module cpri_rxdata_fifo#(
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  14   ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  14   ,
    parameter integer FIFO_DEPTH         =  2**14,
    parameter integer FIFO_WIDTH         =  64   ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  14   ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [WDATA_WIDTH-1: 0]               i_rx_data               ,
    input          [   6: 0]                        i_rx_seq                ,
    input                                           i_rvalid                ,
    input                                           i_rready                ,

    output         [RDATA_WIDTH-1: 0]               o_tx_data               ,
    output         [   6: 0]                        o_tx_addr               ,
    output                                          o_tx_last               ,                 
    output                                          o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam [WADDR_WIDTH-1: 0] DATA_DEPTH = 11094;
localparam [6: 0]             CHIP_DW    = 95;

//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
wire                                            wr_wen                  ;
wire                                            rd_ren                  ;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;
wire           [WDATA_WIDTH-1: 0]               wr_data                 ;
reg            [RADDR_WIDTH-1: 0]               rd_addr               =0;
wire           [RDATA_WIDTH-1: 0]               rd_data                 ;
wire                                            rd_en                   ;
reg            [   6: 0]                        seq_num               =0;
wire                                            data_vld                ;
reg                                             data_last             =0;

//--------------------------------------------------------------------------------------
// Write logic
//--------------------------------------------------------------------------------------
assign wr_wen  = i_rvalid;
assign wr_data = i_rx_data;

always @ (posedge i_clk)begin
    if(i_reset)
        wr_addr <= 0;
    else if(wr_addr==DATA_DEPTH)
        wr_addr <= 0;
    else if(wr_wen)
        wr_addr <= wr_addr + 1;    
end

//--------------------------------------------------------------------------------------
// Read logic
//--------------------------------------------------------------------------------------
assign rd_en  = i_rready & data_vld;

always @ (posedge i_clk)begin
    if(i_reset)
        rd_addr<= 0;
    else if(rd_addr==DATA_DEPTH)
        rd_addr <= 0;
    else if(rd_en)
        rd_addr <= rd_addr + 1;
end

always @ (posedge i_clk)begin
    if(i_reset)
        seq_num <= 0;
    else if(seq_num==CHIP_DW)
        seq_num <= 0;
    else if(rd_en)
        seq_num <= seq_num + 1;
end

always @ (posedge i_clk)begin
    if(i_reset)
        data_last <= 0;
    else if(seq_num == CHIP_DW-1)
        data_last <= 1;
    else
        data_last <= 0;
end

//--------------------------------------------------------------------------------------
// FIFO 
//--------------------------------------------------------------------------------------
FIFO_SYNC_XPM_intel #(
    .NUMWORDS                                           (FIFO_DEPTH             ),
    .DATA_WIDTH                                         (FIFO_WIDTH             ) 
)INST_INFO(                                                                   
    .rst                                                (i_reset                ),
    .clk                                                (i_clk                  ),
    .wr_en                                              (wr_wen                 ),
    .din                                                (wr_data                ),
    .rd_en                                              (rd_en                  ),
    .dout                                               (rd_data                ),
    .dout_valid                                         (data_vld               ),
    .empty                                              (rd_empty               ),
    .full                                               (wr_full                ),
    .usedw                                              (                       ),
    .almost_full                                        (                       ),
    .almost_empty                                       (                       ) 
);    

//--------------------------------------------------------------------------------------
// Output 
//--------------------------------------------------------------------------------------
reg            [RDATA_WIDTH-1: 0]               rx_data_out           =0;
reg            [  10: 0]                        tx_addr_out           =0;
reg                                             tvalid_out            =0;
reg                                             txlast_out            =0;

always @ (posedge i_clk)begin
    rx_data_out <= rd_data[RDATA_WIDTH-1:0];
    tx_addr_out <= seq_num;
    tvalid_out  <= data_vld;
    txlast_out  <= data_last;
end

assign o_tx_data    = rx_data_out;
assign o_tx_addr    = tx_addr_out;
assign o_tvalid     = tvalid_out ;
assign o_tx_last    = txlast_out ;

//--------------------------------------------------------------------------------------
// DEBUG PORT
//--------------------------------------------------------------------------------------
`ifdef SIM_PRJ
reg [6:0] prb_num = 0;
reg [3:0] symbol_num = 0;

always @ (posedge i_clk)begin
    if(i_reset)begin
        prb_num <= 0;
        symbol_num <= 0;
    end else if(prb_num == 131)begin
        prb_num <= 0;
        symbol_num <= symbol_num + 1;
    end else if(wr_wen) begin
        prb_num <= prb_num + 1;
    end
    
    $display("NO %d Symbol", symbol_num);
end

`endif




endmodule