//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: beams_mem_pick
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
    input                                           i_wr_sop                ,
    input                                           i_wr_eop                ,
    input          [15:0][WDATA_WIDTH-1: 0]         i_wr_data               ,

    input          [15:0][7: 0]                     i_sort_idx              ,
    input                                           i_sort_sop              ,
    input                                           i_sym_1st               ,
    input                                           i_rbg_load              ,
    
    // input header info
    input          [  63: 0]                        i_info_0                ,// IQ HD 
    input          [  15: 0]                        i_info_1                ,// FFT AGC{odd, even}

    // output header info
    output         [  63: 0]                        o_info_0                ,// IQ HD 
    output         [15:0][7: 0]                     o_info_1                ,// FFT AGC


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
reg                                             wr_wen_d1             =0;
reg                                             wr_eop_d1             =0;
reg                                             sym_1st_d1            =0;

wire           [   3: 0]                        data_vld                ;
wire           [   3: 0]                        rd_empty                ;
wire           [   3: 0]                        wr_full                 ;

reg            [   1: 0]                        num_blocks            =0;
reg            [   1: 0]                        rvalid_r              =0;
reg            [WADDR_WIDTH-1: 0]               addr_max              =1;
reg            [1:0]                            sort_sop_buf          =0;
wire                                            sort_sop_pos            ;

reg            [15:0][WDATA_WIDTH-1: 0]         sort_data             =0;
reg            [15:0][WDATA_WIDTH-1: 0]         data_out              =0;
reg                                             sym_is_1st            =0;
reg                                             sym_is_1st_d1         =0;
reg            [   2: 0]                        rd_last_buf           =0;
wire                                            rd_last                 ;
reg            [63: 0]                          symb1_info_0          =0;
reg            [63: 0]                          dout_info_0           =0;
wire                                            wr_wen_1st              ;
wire                                            wr_eop_1st              ;
wire                                            sym_1st_neg             ;
wire                                            mem_rst                 ;

//--------------------------------------------------------------------------------------
// generate data block number due to cutting data into 4 blocks 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    rvalid_r <= {rvalid_r[0],i_rvalid};
end


assign wr_wen_1st = i_wr_wen & i_sym_1st;
assign wr_eop_1st = i_wr_eop & i_sym_1st;

always @(posedge i_clk) begin
    wr_wen_d1   <= wr_wen_1st;
    wr_eop_d1   <= wr_eop_1st;
    sym_1st_d1  <= i_sym_1st ;
end

assign sym_1st_neg = ~sym_is_1st & sym_is_1st_d1;

always @(posedge i_clk) begin
    if(i_reset)
        num_blocks <= 'd0;
    else if(!sym_1st_d1)
        num_blocks <= 'd0;
    else if(wr_eop_d1)
        num_blocks <= num_blocks + 'd1;
end

//--------------------------------------------------------------------------------------
// generate 4 mem blocks write enable signal
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    case(num_blocks)
        2'b00:  begin
                    wr_wen[3:0] <= {3'd0,wr_wen_1st};
                end
        2'b01:  begin
                    wr_wen[3:0] <= {2'd0,wr_wen_1st,1'd0};
                end
        2'b10:  begin
                    wr_wen[3:0] <= {1'd0,wr_wen_1st,2'd0};
                end
        2'b11:  begin
                    wr_wen[3:0] <= {wr_wen_1st,3'd0};
                end
        default:begin
                    wr_wen[3:0] <= 4'd0;
                end
    endcase
end

always @(posedge i_clk) begin
    for(int i=0;i<4;i=i+1)begin
        if(i_reset)
            wr_addr[i] <= 'd0;
        else if(!sym_1st_d1)
            wr_addr[i] <= 'd0;
        else if(wr_eop_d1)
            wr_addr[i] <= 'd0;
        else if(wr_wen_d1)
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
    if(wr_eop_d1)
        addr_max <= wr_addr[3];
    else
        addr_max <= addr_max;
end

always @(posedge i_clk) begin
    sort_sop_buf <= {sort_sop_buf[0], i_sort_sop};
end

assign sort_sop_pos = sort_sop_buf[0] & (~sort_sop_buf[1]);

always @(posedge i_clk) begin
    for(int i=0;i<4;i=i+1)begin
        if(i_reset)
            rd_ren[i] <= 1'b0;
        else if(sort_sop_pos)
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
assign mem_rst = i_reset | sym_1st_neg;

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
    .i_reset                                            (mem_rst                ),
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
    .i_reset                                            (mem_rst                ),
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
    .i_reset                                            (mem_rst                ),
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
    .i_reset                                            (mem_rst                ),
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
    if(i_reset)
        rd_last_buf <= 'd0;
    else
        rd_last_buf <= {rd_last_buf[1:0], rd_last};
end


always @ (posedge i_clk)begin
    sym_is_1st_d1  <= sym_is_1st;

    if(i_reset)
        sym_is_1st <= 1'b0;
    else if(i_sym_1st)
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
        if(i_sym_1st || sym_is_1st)
            data_out[i] <= sort_data[i];
        else
            data_out[i] <= i_wr_data[i];
    end
end


//--------------------------------------------------------------------------------------
// original beam polarity(even/odd)
//--------------------------------------------------------------------------------------
reg            [15:0][7: 0]                     sort_idx_2nd          =0;
reg            [  15: 0]                        ant_polarity          =0;
reg            [  15: 0]                        ant_polarity_2nd      =0;
wire           [15:0][7: 0]                     fft_agc_1st             ;
wire           [15:0][7: 0]                     fft_agc_2nd             ;
reg            [15:0][7: 0]                     dout_fft_agc          =0;
reg            [6:0][15: 0]                     ant_polarity_buf      =0;
reg            [15:0][7: 0]                     fft_agc_out[6:0]      ='{default:0};

always @ (posedge i_clk)begin
    for(int i=0; i<16; i=i+1)begin
        if(i_sort_idx[i]<'d32)
            ant_polarity[i] <= 1'b0;
        else
            ant_polarity[i] <= 1'b1;
    end
end

always @ (posedge i_clk)begin
    if(!i_sym_1st && i_sort_sop)
        sort_idx_2nd <= i_sort_idx;
    else
        sort_idx_2nd <= sort_idx_2nd;
end

always @ (posedge i_clk)begin
    for(int i=0; i<16; i=i+1)begin
        if(sort_idx_2nd[i]<'d32)
            ant_polarity_2nd[i] <= 1'b0;
        else
            ant_polarity_2nd[i] <= 1'b1;
    end
end


always @ (posedge i_clk)begin
    ant_polarity_buf[0] <= ant_polarity_2nd;
    for(int i=1; i<7; i=i+1)begin
        ant_polarity_buf[i] <= ant_polarity_buf[i-1];
    end
end

generate for (gi=0; gi<16; gi=gi+1) begin: gen_fft_agc
    assign fft_agc_1st[gi] = (ant_polarity[gi]) ? i_info_1[15:8] : i_info_1[ 7:0];
    assign fft_agc_2nd[gi] = (ant_polarity_buf[5][gi]) ? i_info_1[15:8] : i_info_1[ 7:0];
end
endgenerate

//--------------------------------------------------------------------------------------
// output valid signal
//--------------------------------------------------------------------------------------
reg                                             data_vld_r            =0;
reg                                             tvalid                =0;
reg                                             sop_out               =0;
reg                                             eop_out               =0;
reg            [   3: 0]                        rd_rden_buf           =0;
wire                                            rden_pos_d1             ;
wire                                            rden_pos_d2             ;


always @(posedge i_clk) begin
    if(i_reset)begin
        data_vld_r  <= 'd0;
        rd_rden_buf <= 'd0;
    end else begin
        data_vld_r  <= data_vld[3];
        rd_rden_buf <= {rd_rden_buf[2:0], rd_ren[3]};
    end
end

assign rden_pos_d1 = rd_rden_buf[1] & (~rd_rden_buf[2]);
assign rden_pos_d2 = rd_rden_buf[2] & (~rd_rden_buf[3]);

always @(posedge i_clk) begin
    if(i_reset)
        tvalid <= 1'b0;
    else if(i_sym_1st || sym_is_1st)
        tvalid <= rd_rden_buf[2];
    else
        tvalid <= i_rvalid;
end

always @(posedge i_clk) begin
    if(i_reset)
        eop_out <= 1'b0;
    else if(i_sym_1st || sym_is_1st)
        eop_out <= rd_last_buf[2];
    else
        eop_out <= i_wr_eop;
end

always @(posedge i_clk) begin
    if(i_reset)
        sop_out <= 1'b0;
    else if(i_sym_1st || sym_is_1st)
        sop_out <= rden_pos_d2;
    else
        sop_out <= i_wr_sop;
end

always @(posedge i_clk) begin
    if(i_reset)
        symb1_info_0 <= 'd0;
    else if(rden_pos_d1)
        symb1_info_0 <= i_info_0;
end

always @ (posedge i_clk)begin
    if(i_sym_1st || sym_is_1st)
        dout_info_0 <= symb1_info_0;
    else
        dout_info_0 <= i_info_0;
end

always @ (posedge i_clk)begin
    if(sym_is_1st && rd_rden_buf[2])
        dout_fft_agc <= fft_agc_1st;
    else if(!sym_is_1st && i_rvalid)
        dout_fft_agc <= fft_agc_2nd;
    else 
        dout_fft_agc <= 'd0;
end	




assign o_tvalid     = tvalid;
assign o_sop        = sop_out;
assign o_eop        = eop_out;
assign o_rd_data    = data_out;
assign o_info_0     = dout_info_0;
assign o_info_1     = dout_fft_agc;

endmodule
