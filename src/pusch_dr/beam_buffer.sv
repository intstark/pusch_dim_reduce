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
    parameter integer WDATA_WIDTH        =  40   ,
    parameter integer WADDR_WIDTH        =  11   ,
    parameter integer RDATA_WIDTH        =  40   ,
    parameter integer RADDR_WIDTH        =  11    
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_rvalid                ,
    input                                           i_wr_wen                ,
    input          [WADDR_WIDTH-1: 0]               i_wr_addr               ,
    input          [15:0][WDATA_WIDTH-1: 0]         i_wr_data               ,


    output         [15:0][4*RDATA_WIDTH-1: 0]       o_rd_data               ,
    output         [RADDR_WIDTH-1: 0]               o_rd_addr               ,
    output                                          o_rd_vld                ,
    output                                          o_tvalid              
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

reg            [15:0][WDATA_WIDTH-1: 0]         wr_data_0             =0;
reg            [15:0][WDATA_WIDTH-1: 0]         wr_data_1             =0;
reg            [15:0][WDATA_WIDTH-1: 0]         wr_data_2             =0;
reg            [15:0][WDATA_WIDTH-1: 0]         wr_data_3             =0;
reg            [3:0][WADDR_WIDTH-1: 0]          wr_addr               =0;
reg            [   3: 0]                        wr_wen                =0;
reg            [   3: 0]                        rd_ren                =0;
reg            [3:0][RADDR_WIDTH-1: 0]          rd_addr               =0;
reg            [RADDR_WIDTH-1: 0]               rd_addr_syn           =0;
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_0               ;
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_1               ;
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_2               ;
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_3               ;
reg            [63:0][RDATA_WIDTH-1: 0]         rd_data_matrix        =0;

wire           [   3: 0]                        data_vld                ;
wire           [   3: 0]                        rd_empty                ;
wire           [   3: 0]                        wr_full                 ;

reg            [   1: 0]                        num_blocks            =0;
reg            [   4: 0]                        rvalid_r              =0;
wire                                            rvld_pos                ;
wire                                            rvld_neg                ;


//--------------------------------------------------------------------------------------
// generate data block number due to cutting data into 4 blocks 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    rvalid_r <= {rvalid_r[3:0],i_rvalid};
end

assign rvld_pos = i_rvalid & (~rvalid_r[0]);
assign rvld_neg = ~i_rvalid & (rvalid_r[0]);

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

always @(posedge i_clk) begin
    wr_data_0 <= i_wr_data;
    wr_data_1 <= i_wr_data;
    wr_data_2 <= i_wr_data;
    wr_data_3 <= i_wr_data;
end

//--------------------------------------------------------------------------------------
// generate 4 mem blocks reaad signal
//--------------------------------------------------------------------------------------
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
        wr_addr[i] <= i_wr_addr;
        rd_addr[i] <= rd_addr_syn;
    end
end


//--------------------------------------------------------------------------------------
// Store 4 blocks of data in memory at different time
// Read data from memory at the same time
// Latency is 3 cycles
//--------------------------------------------------------------------------------------
mem_streams # (
    .CHANNELS                                           (16                     ),
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .WADDR_WIDTH                                        (WADDR_WIDTH            ),
    .RDATA_WIDTH                                        (RDATA_WIDTH            ),
    .RADDR_WIDTH                                        (RADDR_WIDTH            ),
    .READ_LATENCY                                       (3                      ),
    .RAM_TYPE                                           (1                      ) 
)mem_streams_0(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rvalid               ),
    .i_wr_wen                                           (wr_wen  [0]            ),
    .i_wr_addr                                          (wr_addr [0]            ),
    .i_wr_data                                          (wr_data_0              ),
    .i_rd_ren                                           (rd_ren  [0]            ),
    .o_rd_data                                          (rd_data_0              ),
    .o_rd_addr                                          (                       ),
    .o_tvalid                                           (data_vld[0]            ) 
);

mem_streams # (
    .CHANNELS                                           (16                     ),
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .WADDR_WIDTH                                        (WADDR_WIDTH            ),
    .RDATA_WIDTH                                        (RDATA_WIDTH            ),
    .RADDR_WIDTH                                        (RADDR_WIDTH            ),
    .READ_LATENCY                                       (3                      ),
    .RAM_TYPE                                           (1                      ) 
)mem_streams_1(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rvalid               ),
    .i_wr_wen                                           (wr_wen  [1]            ),
    .i_wr_addr                                          (wr_addr [1]            ),
    .i_wr_data                                          (wr_data_1              ),
    .i_rd_ren                                           (rd_ren  [1]            ),
    .o_rd_data                                          (rd_data_1              ),
    .o_rd_addr                                          (                       ),
    .o_tvalid                                           (data_vld[1]            ) 
);

mem_streams # (
    .CHANNELS                                           (16                     ),
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .WADDR_WIDTH                                        (WADDR_WIDTH            ),
    .RDATA_WIDTH                                        (RDATA_WIDTH            ),
    .RADDR_WIDTH                                        (RADDR_WIDTH            ),
    .READ_LATENCY                                       (3                      ),
    .RAM_TYPE                                           (1                      ) 
)mem_streams_2(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rvalid               ),
    .i_wr_wen                                           (wr_wen  [2]            ),
    .i_wr_addr                                          (wr_addr [2]            ),
    .i_wr_data                                          (wr_data_2              ),
    .i_rd_ren                                           (rd_ren  [2]            ),
    .o_rd_data                                          (rd_data_2              ),
    .o_rd_addr                                          (                       ),
    .o_tvalid                                           (data_vld[2]            ) 
);

mem_streams # (
    .CHANNELS                                           (16                     ),
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .WADDR_WIDTH                                        (WADDR_WIDTH            ),
    .RDATA_WIDTH                                        (RDATA_WIDTH            ),
    .RADDR_WIDTH                                        (RADDR_WIDTH            ),
    .READ_LATENCY                                       (3                      ),
    .RAM_TYPE                                           (1                      ) 
)mem_streams_3(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rvalid               ),
    .i_wr_wen                                           (wr_wen  [3]            ),
    .i_wr_addr                                          (wr_addr [3]            ),
    .i_wr_data                                          (wr_data_3              ),
    .i_rd_ren                                           (rd_ren  [3]            ),
    .o_rd_data                                          (rd_data_3              ),
    .o_rd_addr                                          (                       ),
    .o_tvalid                                           (data_vld[3]            ) 
);




//--------------------------------------------------------------------------------------
// combine them into 16 channels
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    rd_data_matrix[15: 0] <= rd_data_0[15:0];
    rd_data_matrix[31:16] <= rd_data_1[15:0];
    rd_data_matrix[47:32] <= rd_data_2[15:0];
    rd_data_matrix[63:48] <= rd_data_3[15:0];
end	


//--------------------------------------------------------------------------------------
// output valid signal
//--------------------------------------------------------------------------------------
reg                                             data_vld_r            =0;
reg            [   1: 0]                        rd_ren_r              =0;
reg                                             rd_vld                =0;
wire                                            dout_vld_pos            ;

always @(posedge i_clk) begin
    data_vld_r <= data_vld[3];
    rd_ren_r <= {rd_ren_r[0], rd_ren[3]};
end

assign dout_vld_pos = data_vld[3] & (~data_vld_r);

always @(posedge i_clk) begin
    if(i_reset)
        rd_vld <= 0;
    else if(dout_vld_pos || rd_ren_r[1])
        rd_vld <= 1;
    else
        rd_vld <= 0;
end

assign o_tvalid = rvalid_r[4];
assign o_rd_vld = rd_vld ;
assign o_rd_data = rd_data_matrix;


// debug
reg            [   7: 0]                        renum=0                 ;
always @ (posedge i_clk) begin
    if(rd_vld)
        renum <= 8'd0;
    else
        renum <= renum + 8'd1;
end


endmodule
