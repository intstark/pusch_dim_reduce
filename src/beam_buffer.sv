//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: beam_buffer 
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
module beam_buffer # (
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  6    ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  6    ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_rvalid                ,
    input                                           i_wr_wen                ,
    input          [WDATA_WIDTH-1: 0]               i_wr_data               ,
    input          [WADDR_WIDTH-1: 0]               i_wr_addr               ,

    input          [4*RDATA_WIDTH-1: 0]             o_rd_data               ,
    input          [RADDR_WIDTH-1: 0]               o_rd_addr               ,
    input                                           o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
localparam RDATA_DEPTH = 1<<RADDR_WIDTH;
localparam WDATA_DEPTH = 1<<WADDR_WIDTH;

//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
genvar gi;

reg            [3:0][WDATA_WIDTH-1: 0]          wr_data               =0;
reg            [3:0][WADDR_WIDTH-1: 0]          wr_addr               =0;
reg            [   3: 0]                        wr_wen                =0;
reg            [   3: 0]                        rd_ren                =0;
reg            [3:0][RADDR_WIDTH-1: 0]          rd_addr               =0;
wire           [3:0][RDATA_WIDTH-1: 0]          rd_data                 ;


reg            [   2: 0]                        num_blocks            =0;
reg                                             rvalid_r              =0;
wire                                            rvld_neg                ;



//--------------------------------------------------------------------------------------
// generate data block number due to cutting data into 4 blocks 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    rvalid_r <= i_rvalid;
end

assign rvld_neg = ~i_rvalid & (rvalid_r);

always @(posedge i_clk) begin
    if(i_reset)
        num_blocks <= 'd0;
    else if(rvld_neg)
        num_blocks <= num_blocks + 'd1;
end

//--------------------------------------------------------------------------------------
// generate 4 mem blocks write enable signal
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    case(num_blocks)
        2'b00:  begin
                    wr_wen[3:0] <= {3'd0,i_wr_wen};
                end
        2'b01:  begin
                    wr_wen[3:0] <= {2'd0,i_wr_wen,1'd0};
                end
        2'b10:  begin
                    wr_wen[3:0] <= {1'd0,i_wr_wen,2'd0};
                end
        2'b11:  begin
                    wr_wen[3:0] <= {i_wr_wen,3'd0};
                end
        default:begin
                    wr_wen[3:0] <= 4'd0;
                end
    endcase
end

reg            [RADDR_WIDTH-1: 0]               rd_addr_syn           =0;
wire           [   3: 0]                        data_vld                ;
wire           [   3: 0]                        rd_empty                ;
wire           [   3: 0]                        wr_full                 ;

always @(posedge i_clk) begin
    if(data_vld[3])
        rd_ren[3:0] <= {4{wr_wen[3]}};
    else
        rd_ren[3:0] <= 4'd0;
end

always @(posedge i_clk) begin
    if(i_reset)
        rd_addr_syn <= 'd0;
    else if(data_vld[3])
        rd_addr_syn <= wr_addr[3];
end

always @(posedge i_clk) begin
    for(int i=0;i<4;i=i+1) begin
        wr_data[i] <= i_wr_data;
        wr_addr[i] <= i_wr_addr;
        rd_addr[i] <= rd_addr_syn;
    end
end

//--------------------------------------------------------------------------------------
// Store 4 blocks of data in memory at different time
// Read data from memory at the same time
//--------------------------------------------------------------------------------------
generate for(gi=0;gi<4;gi=gi+1)begin
    FIFO_SYNC_XPM_intel #(
        .NUMWORDS                                           (WDATA_DEPTH            ),
        .DATA_WIDTH                                         (WDATA_WIDTH            )
    )INST_INFO(                                                                   
        .rst                                                (i_reset                ),
        .clk                                                (i_clk                  ),
        .wr_en                                              (wr_wen  [gi]           ),
        .din                                                (wr_data [gi]           ),
        .rd_en                                              (rd_ren  [gi]           ),
        .dout                                               (rd_data [gi]           ),
        .dout_valid                                         (data_vld[gi]           ),
        .empty                                              (rd_empty[gi]           ),
        .full                                               (wr_full [gi]           ),
        .usedw                                              (                       ),
        .almost_full                                        (                       ),
        .almost_empty                                       (                       ) 
    );

    assign o_rd_data[(gi+1)*RDATA_WIDTH-1:gi*RDATA_WIDTH] = rd_data[gi];
end
endgenerate

//--------------------------------------------------------------------------------------
// output valid signal
//--------------------------------------------------------------------------------------
reg                                             data_vld_r=0            ;
reg                                             tvalid                =0;
wire                                            dout_vld_pos            ;

always @(posedge i_clk) begin
    data_vld_r <= data_vld[3];
end

assign dout_vld_pos = data_vld[3] & (~data_vld_r);

always @(posedge i_clk) begin
    if(i_reset)
        tvalid <= 0;
    else if(dout_vld_pos || rd_ren[3])
        tvalid <= 1;
    else
        tvalid <= 0;
end

assign o_tvalid = tvalid;






endmodule
