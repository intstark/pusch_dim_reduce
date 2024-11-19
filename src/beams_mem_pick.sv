//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: mac_beams_mem
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
module beams_mem_pick # (
    parameter integer WDATA_WIDTH        =  40   ,
    parameter integer WADDR_WIDTH        =  11   ,
    parameter integer RDATA_WIDTH        =  40   ,
    parameter integer RADDR_WIDTH        =  11    
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_rvalid                ,
    input                                           i_wr_wen                ,
    input                                           i_wr_eop                ,
    input          [15:0][WDATA_WIDTH-1: 0]         i_wr_data               ,

    input          [15:0][7: 0]                     i_sort_idx              ,
    input                                           i_sort_sop              ,
    input                                           i_sym_1st               ,
    
    // input header info
    input          [  63: 0]                        i_info_0                ,// IQ HD 
    input          [  63: 0]                        i_info_1                ,// FFT AGC

    // output header info
    output         [  63: 0]                        o_info_0                ,// IQ HD 
    output         [  63: 0]                        o_info_1                ,// FFT AGC


    output         [15:0][RDATA_WIDTH-1: 0]         o_rd_data               ,
    output         [RADDR_WIDTH-1: 0]               o_rd_addr               ,
    output                                          o_sop                   ,
    output                                          o_eop                   ,
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
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_0               ;
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_1               ;
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_2               ;
wire           [15:0][RDATA_WIDTH-1: 0]         rd_data_3               ;
reg            [63:0][RDATA_WIDTH-1: 0]         rd_data_matrix        =0;
reg            [   6: 0]                        wr_wen_buf            =0;
reg            [   6: 0]                        wr_eop_buf            =0;

wire           [   3: 0]                        data_vld                ;
wire           [   3: 0]                        rd_empty                ;
wire           [   3: 0]                        wr_full                 ;

reg            [   2: 0]                        num_blocks            =0;
reg            [   2: 0]                        rvalid_r              =0;
wire                                            rvld_pos                ;
wire                                            rvld_neg                ;
reg            [WADDR_WIDTH-1: 0]               addr_max              =1;
reg            [1:0]                            sort_sop_buf          =0;
wire                                            sort_sop_pos            ;

reg            [15:0][WDATA_WIDTH-1: 0]         sort_data             =0;
reg            [15:0][WDATA_WIDTH-1: 0]         data_out              =0;
reg                                             sym_is_1st            =0;
reg            [   2: 0]                        rd_last_buf           =0;
wire                                            rd_last                 ;
reg            [63: 0]                          symb1_info_0          =0;
reg            [63: 0]                          symb1_info_1          =0;
reg            [63: 0]                          dout_info_0           =0;
reg            [63: 0]                          dout_info_1           =0;

//--------------------------------------------------------------------------------------
// generate data block number due to cutting data into 4 blocks 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    rvalid_r <= {rvalid_r[1:0],i_rvalid};
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
    for(int i=0;i<4;i=i+1)begin
        if(i_wr_eop)
            wr_addr[i] <= 'd0;
        else if(i_rvalid)
            wr_addr[i] <= wr_addr[i] + 'd1;
    end
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
    wr_wen_buf <= {wr_wen_buf[5:0], i_wr_wen};
    wr_eop_buf <= {wr_eop_buf[5:0], i_wr_eop};
end

always @(posedge i_clk) begin
    if(i_wr_eop)
        addr_max <= wr_addr[3];
end

always @(posedge i_clk) begin
    sort_sop_buf <= {sort_sop_buf[0], i_sort_sop};
end

assign sort_sop_pos = sort_sop_buf[0] & (~sort_sop_buf[1]);

always @(posedge i_clk) begin
    for(int i=0;i<4;i=i+1)begin
        if(sort_sop_pos)
            rd_ren[i] <= 1'b1;
        else if(rd_addr[i] == addr_max)
            rd_ren[i] <= 1'b0;
    end
end

always @(posedge i_clk) begin
    for(int i=0;i<4;i=i+1)begin
        if(i_reset)
            rd_addr[i] <= 0;
        else if(rd_addr[i] == addr_max)
            rd_addr[i] <= 0;
        else if(rd_ren[i])
            rd_addr[i] <= rd_addr[i] + 'd1;
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
// Output 16 beams data
//--------------------------------------------------------------------------------------

assign rd_last = (rd_addr[3] == addr_max) ? 1'b1 : 1'b0;

always @(posedge i_clk) begin
    rd_last_buf <= {rd_last_buf[1:0], rd_last};
end


always @ (posedge i_clk)begin
    if(i_sym_1st)
        sym_is_1st <= 1'b1;
    else if(rd_last_buf[2])
        sym_is_1st <= 1'b0;
end


always @ (posedge i_clk)begin
    for(int i=0; i<16; i=i+1)begin
        sort_data[i] <= rd_data_matrix[i_sort_idx[i]];
    end
end	

always @ (posedge i_clk)begin
    for(int i=0; i<16; i=i+1)begin
        if(sym_is_1st)
            data_out[i] <= sort_data[i];
        else
            data_out[i] <= i_wr_data[i];
    end
end	

//--------------------------------------------------------------------------------------
// output valid signal
//--------------------------------------------------------------------------------------
reg                                             data_vld_r            =0;
reg                                             tvalid                =0;
reg                                             sop_out               =0;
reg                                             eop_out               =0;
reg            [   3: 0]                        rd_rden_buf           =0;


always @(posedge i_clk) begin
    data_vld_r <= data_vld[3];
    rd_rden_buf <= {rd_rden_buf[2:0], rd_ren[3]};
end


always @(posedge i_clk) begin
    if(i_reset)
        tvalid <= 1'b0;
    else if(sym_is_1st)
        tvalid <= rd_rden_buf[2];
    else
        tvalid <= i_rvalid;
end

always @(posedge i_clk) begin
    if(i_reset)
        eop_out <= 1'b0;
    else if(sym_is_1st)
        eop_out <= rd_last_buf[2];
    else
        eop_out <= i_wr_eop;
end

always @(posedge i_clk) begin
    if(i_reset)
        sop_out <= 1'b0;
    else if(sym_is_1st)
        sop_out <= rd_rden_buf[2] & (~rd_rden_buf[3]);
    else
        sop_out <= rvld_pos;
end

always @(posedge i_clk) begin
    if(i_reset)begin
        symb1_info_0 <= 'd0;
        symb1_info_1 <= 'd0;
    end else if(rd_rden_buf[1] & (~rd_rden_buf[2]))begin
        symb1_info_0 <= i_info_0;
        symb1_info_1 <= i_info_1;
    end
end

always @ (posedge i_clk)begin
    if(sym_is_1st)begin
        dout_info_0 <= symb1_info_0;
        dout_info_1 <= symb1_info_1;
    end else begin
        dout_info_0 <= i_info_0;
        dout_info_1 <= i_info_1;
    end
end	




assign o_tvalid     = tvalid;
assign o_sop        = sop_out;
assign o_eop        = eop_out;
assign o_rd_data    = data_out;
assign o_info_0     = dout_info_0;
assign o_info_1     = dout_info_1;

endmodule
