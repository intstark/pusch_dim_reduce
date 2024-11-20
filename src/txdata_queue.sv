//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: txdata_queue
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
module txdata_queue #(
    parameter integer WDATA_WIDTH        =  128  ,
    parameter integer WADDR_WIDTH        =  11   ,
    parameter integer RDATA_WIDTH        =  128  ,
    parameter integer RADDR_WIDTH        =  11   ,
    parameter integer FIFO_DEPTH         =  4    ,
    parameter integer FIFO_WIDTH         =  1    ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  13   ,    
    parameter integer INFO_WIDTH         =  1    ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [7:0][31: 0]                     i_ant_data              ,
    input          [7:0][31: 0]                     i_ant_pwr               ,
    input                                           i_rx_vld                ,
    input                                           i_rx_sop                ,
    input                                           i_rx_eop                ,
    input                                           i_rbg_load              ,
    input                                           i_rready                ,

    input          [   3: 0]                        i_ant0_idx              ,

    input          [   3: 0]                        i_rbg_idx               ,
    input          [   3: 0]                        i_pkg_type              ,
    input                                           i_cell_idx              ,
    input          [   6: 0]                        i_slot_idx              ,
    input          [   3: 0]                        i_symb_idx              ,
    input          [  63: 0]                        i_fft_agc               ,

    output         [7:0][31: 0]                     o_ant_pwr               ,
    output         [   3: 0]                        o_rbg_idx               ,
    output         [   3: 0]                        o_pkg_type              ,
    output                                          o_cell_idx              ,
    output         [   6: 0]                        o_slot_idx              ,
    output         [   3: 0]                        o_symb_idx              ,
    output         [  63: 0]                        o_fft_agc               ,
    output         [3:0][ 7: 0]                     o_pkg_info              ,
    output         [   8: 0]                        o_prb_idx               ,

    output         [3:0][31: 0]                     o_tx_data               ,
    output                                          o_tx_vld                , 
    output                                          o_tx_sop                ,
    output                                          o_tx_eop                ,
    output                                          o_tready                 
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam [WADDR_WIDTH-1: 0] DATA_DEPTH  = 1583;
localparam FSIZE_WIDTH = LOOP_WIDTH-WADDR_WIDTH;
localparam GRP_NUM = 2;

//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
genvar gi;
reg            [GRP_NUM-1: 0]                   rd_rdy                  ;
reg                                             wr_wlast                ;
reg                                             wr_wen                =0;
reg            [GRP_NUM-1: 0]                   rd_ren                =0;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;
reg            [WDATA_WIDTH-1: 0]               wr_data[GRP_NUM-1:0]  ='{default:0};
reg            [GRP_NUM-1:0][RADDR_WIDTH-1: 0]  rd_addr               =0;
wire           [RDATA_WIDTH-1: 0]               rd_data[GRP_NUM-1:0]    ;
wire                                            rd_en                   ;
reg            [  10: 0]                        seq_num               =0;
wire           [GRP_NUM-1: 0]                   rd_vld                  ;

reg            [GRP_NUM-1: 0]                   rd_rlast              =0;
reg            [   2: 0]                        rd_rlast_buf          =0;
reg            [   7: 0]                        rd_sym_num            =0;
wire           [GRP_NUM-1:0][FSIZE_WIDTH: 0]    free_size               ;
reg                                             wr_block_num          =0;
wire                                            wr_info                 ;
reg            [83: 0]                          wr_dinfo[GRP_NUM-1:0] ='{default:0};
wire           [83: 0]                          rd_dinfo[GRP_NUM-1:0]   ;
reg            [1:0]                            wr_rbg_load           =0;
wire           [GRP_NUM-1: 0]                   rd_rbg_load             ;



//--------------------------------------------------------------------------------------
// Write logic
//--------------------------------------------------------------------------------------
reg            [   5: 0]                        rx_vld_buf            =0;

always @ (posedge i_clk)begin
    if(i_reset)
        wr_wen <= 1'b0;
    else
        wr_wen <= i_rx_vld;
end

always @ (posedge i_clk)begin
    wr_data[0] <= {i_ant_data[ 6],i_ant_data[ 4],i_ant_data[ 2],i_ant_data[ 0]};
    wr_data[1] <= {i_ant_data[ 7],i_ant_data[ 5],i_ant_data[ 3],i_ant_data[ 1]};
end


always @ (posedge i_clk)begin
    wr_dinfo[0] <= {i_fft_agc, i_rbg_idx, i_pkg_type, i_cell_idx, i_slot_idx, i_symb_idx};
    wr_dinfo[1] <= {i_fft_agc, i_rbg_idx, i_pkg_type, i_cell_idx, i_slot_idx, i_symb_idx};
end

always @ (posedge i_clk)begin
    wr_rbg_load <= {wr_rbg_load[0],i_rbg_load};
end

always @ (posedge i_clk)begin
    rx_vld_buf <= {rx_vld_buf[4:0],i_rx_vld};    
end


always @ (posedge i_clk)begin
    if(i_reset)
        wr_addr <= 'd0;
    else if(wr_addr==DATA_DEPTH)
        wr_addr <= 'd0;
    else if(wr_wen)
        wr_addr <= wr_addr + 'd1;    
end

always @ (posedge i_clk)begin
    if(i_reset)
        wr_wlast <= 1'b0;
    else if(wr_addr == DATA_DEPTH-1)
        wr_wlast <= 1'b1;
    else
        wr_wlast <= 1'b0;
end

assign wr_info = (wr_addr==1) ? 1'b1 : 1'b0;


always @ (posedge i_clk)begin
    if(i_reset)
        wr_block_num <= 1'd0;
    else if(wr_wlast)
        wr_block_num <= wr_block_num + 1'd1;
end


//--------------------------------------------------------------------------------------
// Read logic
//--------------------------------------------------------------------------------------
reg                                             rd_block_num          =0;
reg            [   1: 0]                        raddr_almost_full     =0;
reg            [RDATA_WIDTH-1: 0]               rd_dout               =0;
reg            [RDATA_WIDTH-1: 0]               rd_dout_dly           =0;
reg            [3:0][1: 0]                      rd_ren_buf            =0;
reg                                             rd_dout_vld           =0;


always @ (posedge i_clk)begin
    if(i_reset)
        rd_block_num <= 1'd0;
    else if(|raddr_almost_full)
        rd_block_num <= rd_block_num + 1'd1;
end

always @ (posedge i_clk)begin
    case(rd_block_num) 
        1'd0    : rd_ren <= {1'd0,rd_vld[0]};
        1'd1    : rd_ren <= {rd_vld[1],1'b0};
        default : rd_ren <= 2'd0;
    endcase
end

always @ (posedge i_clk)begin
    for(int i=0;i<GRP_NUM;i=i+1) begin
        if(rd_addr[i] == DATA_DEPTH-1)
            rd_rlast[i] <= 1'b1;
        else
            rd_rlast[i] <= 1'b0;
    end
end

always @ (posedge i_clk)begin
    for(int i=0;i<GRP_NUM;i=i+1) begin
        if(rd_rlast[i])
            rd_addr[i] <= 'd0;
        else if(rd_ren[i])
            rd_addr[i] <= rd_addr[i] + 'd1;
    end
end


always @ (posedge i_clk)begin
    for(int i=0;i<GRP_NUM;i=i+1) begin
        if(rd_addr[i] == DATA_DEPTH-2)
            raddr_almost_full[i] <= 1'b1;
        else
            raddr_almost_full[i] <= 1'b0;
    end
end

always @ (posedge i_clk)begin
    for(int i=0;i<GRP_NUM;i=i+1) begin
        if(raddr_almost_full[i])
            rd_rdy[i] <= 1'b1;
        else
            rd_rdy[i] <= 1'b0;
    end
end



always @ (posedge i_clk)begin
    rd_ren_buf[0] <= rd_ren;
    for(int i=1;i<4;i=i+1) begin
        rd_ren_buf[i] <= rd_ren_buf[i-1];
    end
end

always @ (posedge i_clk)begin
    case(rd_ren_buf[2])
        2'd1    : rd_dout <= rd_data[0];
        2'd2    : rd_dout <= rd_data[1];
        default : rd_dout <= 'd0;
    endcase
end

always @ (posedge i_clk)begin
    if(|rd_ren_buf[3])
        rd_dout_vld <= 1'b1;
    else
        rd_dout_vld <= 1'b0;
end

reg            [   3: 0]                        ant0_idx              =0;
reg            [   3: 0]                        ant1_idx              =0;
reg            [   3: 0]                        ant2_idx              =0;
reg            [   3: 0]                        ant3_idx              =0;
reg            [   3: 0]                        ant_group_idx         =0;
reg            [3:0][7: 0]                      pkg_info              =0;
reg            [  83: 0]                        dinfo_out             =0;
reg            [  83: 0]                        dinfo_out_dly         =0;


always @ (posedge i_clk)begin
    case(rd_ren_buf[2])
        2'd1    : dinfo_out <= rd_dinfo[0];
        2'd2    : dinfo_out <= rd_dinfo[1];
        default : dinfo_out <= 'd0;
    endcase
end

always @ (posedge i_clk)begin
    case(rd_ren_buf[2])
    2'd1:   begin
                ant0_idx <= i_ant0_idx + 4'd0;
                ant1_idx <= i_ant0_idx + 4'd2;
                ant2_idx <= i_ant0_idx + 4'd4;
                ant3_idx <= i_ant0_idx + 4'd6;
                ant_group_idx <=4'd0;
            end
    2'd2:   begin
                ant0_idx <= i_ant0_idx + 4'd1;
                ant1_idx <= i_ant0_idx + 4'd3;
                ant2_idx <= i_ant0_idx + 4'd5;
                ant3_idx <= i_ant0_idx + 4'd7;
                ant_group_idx <=4'd1;             
            end
    default:begin
                ant0_idx <= 4'd0;
                ant1_idx <= 4'd0;
                ant2_idx <= 4'd0;
                ant3_idx <= 4'd0; 
                ant_group_idx <=4'd0;             
            end
    endcase
end

always @ (posedge i_clk)begin
    pkg_info[0] <= {ant_group_idx,ant0_idx};
    pkg_info[1] <= {ant_group_idx,ant1_idx};
    pkg_info[2] <= {ant_group_idx,ant2_idx};
    pkg_info[3] <= {ant_group_idx,ant3_idx};
end

always @ (posedge i_clk)begin
    rd_dout_dly   <= rd_dout  ;
    dinfo_out_dly <= dinfo_out;
end



//--------------------------------------------------------------------------------------
// 
//--------------------------------------------------------------------------------------
reg            [   3: 0]                        dr_renum              =0;
reg            [   3: 0]                        dr_rbnum              =0;
reg            [   8: 0]                        dr_prb_idx            =0;
wire                                            re_sop                  ;
wire                                            re_eop                  ;


always @(posedge i_clk) begin
    if(i_reset)
        dr_renum <= 0;
    else if(dr_renum == 11)
        dr_renum <= 0;
    else if(rd_dout_vld)
        dr_renum <= dr_renum + 1;
end

always @(posedge i_clk) begin
    if(i_reset)
        dr_rbnum <= 0;
    else if(dr_rbnum == 3 && re_eop)
        dr_rbnum <= 0;
    else if(re_eop)
        dr_rbnum <= dr_rbnum + 1;
end

always @(posedge i_clk) begin
    if(i_reset)
        dr_prb_idx <= 0;
    else if(dr_prb_idx == 131 && re_eop)
        dr_prb_idx <= 0;
    else if(re_eop)
        dr_prb_idx <= dr_prb_idx + 1;
end



assign re_eop = (rd_dout_vld && (dr_renum == 11)) ? 1'b1 : 1'b0;
assign re_sop = (rd_dout_vld && dr_renum == 0 && (dr_rbnum == 0)) ? 1'b1 : 1'b0;



//------------------------------------------------------------------------------------------
// RAM BLOCK FOR 16 BEAMS 
//------------------------------------------------------------------------------------------
generate
    for(gi=0;gi<GRP_NUM;gi=gi+1) begin: gen_ram_block0
        loop_buffer_sync_intel #(
            .WDATA_WIDTH                                        (WDATA_WIDTH            ),
            .WADDR_WIDTH                                        (WADDR_WIDTH            ),
            .RDATA_WIDTH                                        (RDATA_WIDTH            ),
            .RADDR_WIDTH                                        (RADDR_WIDTH            ),
            .READ_LATENCY                                       (READ_LATENCY           ),
            .FIFO_DEPTH                                         (FIFO_DEPTH             ),
            .FIFO_WIDTH                                         (FIFO_WIDTH             ),
            .LOOP_WIDTH                                         (LOOP_WIDTH             ),
            .INFO_WIDTH                                         (INFO_WIDTH             ),
            .RAM_TYPE                                           (RAM_TYPE               ) 
        )loop_buffer_0(
            .syn_rst                                            (i_reset                ),
            .clk                                                (i_clk                  ),
            .wr_wen                                             (wr_wen                 ),
            .wr_addr                                            (wr_addr                ),
            .wr_data                                            (wr_data  [gi]          ),
            .wr_wlast                                           (wr_wlast               ),
            .wr_info                                            (wr_info                ),
            .free_size                                          (free_size[gi]          ),
            .rd_addr                                            (rd_addr  [gi]          ),
            .rd_data                                            (rd_data  [gi]          ),
            .rd_vld                                             (rd_vld   [gi]          ),
            .rd_info                                            (                       ),
            .rd_rdy                                             (rd_rdy   [gi]          ) 
        );

        loop_buffer_sync_intel #(
            .WDATA_WIDTH                                        (84                     ),
            .WADDR_WIDTH                                        (WADDR_WIDTH            ),
            .RDATA_WIDTH                                        (84                     ),
            .RADDR_WIDTH                                        (RADDR_WIDTH            ),
            .READ_LATENCY                                       (READ_LATENCY           ),
            .FIFO_DEPTH                                         (FIFO_DEPTH             ),
            .FIFO_WIDTH                                         (FIFO_WIDTH             ),
            .LOOP_WIDTH                                         (LOOP_WIDTH             ),
            .INFO_WIDTH                                         (INFO_WIDTH             ),
            .RAM_TYPE                                           (RAM_TYPE               ) 
        )loop_buffer_info(
            .syn_rst                                            (i_reset                ),
            .clk                                                (i_clk                  ),
            .wr_wen                                             (wr_wen                 ),
            .wr_addr                                            (wr_addr                ),
            .wr_data                                            (wr_dinfo [gi]          ),
            .wr_wlast                                           (wr_wlast               ),
            .wr_info                                            (wr_info                ),
            .free_size                                          (                       ),
            .rd_addr                                            (rd_addr  [gi]          ),
            .rd_data                                            (rd_dinfo [gi]          ),
            .rd_vld                                             (                       ),
            .rd_info                                            (                       ),
            .rd_rdy                                             (rd_rdy   [gi]          ) 
        );

        loop_buffer_sync_intel #(
            .WDATA_WIDTH                                        (1                      ),
            .WADDR_WIDTH                                        (WADDR_WIDTH            ),
            .RDATA_WIDTH                                        (1                      ),
            .RADDR_WIDTH                                        (RADDR_WIDTH            ),
            .READ_LATENCY                                       (READ_LATENCY           ),
            .FIFO_DEPTH                                         (FIFO_DEPTH             ),
            .FIFO_WIDTH                                         (FIFO_WIDTH             ),
            .LOOP_WIDTH                                         (LOOP_WIDTH             ),
            .INFO_WIDTH                                         (INFO_WIDTH             ),
            .RAM_TYPE                                           (RAM_TYPE               ) 
        )loop_buffer_load(
            .syn_rst                                            (i_reset                ),
            .clk                                                (i_clk                  ),
            .wr_wen                                             (wr_wen                 ),             
            .wr_addr                                            (wr_addr                ),
            .wr_data                                            (wr_rbg_load[0]         ),
            .wr_wlast                                           (wr_wlast               ),
            .wr_info                                            (wr_info                ),
            .free_size                                          (                       ),
            .rd_addr                                            (rd_addr    [gi]        ),
            .rd_data                                            (rd_rbg_load[gi]        ),
            .rd_vld                                             (                       ),
            .rd_info                                            (                       ),
            .rd_rdy                                             (rd_rdy   [gi]          ) 
        );
    end
endgenerate

//--------------------------------------------------------------------------------------
// beam power memory
//--------------------------------------------------------------------------------------
wire           [ 7:0][31: 0]                    rd_beam_pwr             ;
reg            [ 7:0][31: 0]                    rd_beam_pwr_out       =0;
reg                                             rbg_load_out          =0;
reg                                             pwr_rd_ren              ;


always @ (posedge i_clk)begin
    case(rd_ren_buf[2])
        2'd1    : pwr_rd_ren <= rd_rbg_load[0];
        2'd2    : pwr_rd_ren <= rd_rbg_load[1];
        default : pwr_rd_ren <= 'd0;
    endcase
end

mem_streams_ram # (
    .CHANNELS                                           (8                      ),
    .WDATA_WIDTH                                        (32                     ),
    .WADDR_WIDTH                                        (4                      ),
    .RDATA_WIDTH                                        (32                     ),
    .RADDR_WIDTH                                        (4                      ),
    .READ_LATENCY                                       (3                      ),
    .RAM_TYPE                                           (1                      ) 
)mem_beam_pwr(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rx_vld               ),
    .i_wr_wen                                           (i_rbg_load             ),
    .i_wr_data                                          (i_ant_pwr              ),
    .i_rd_ren                                           (pwr_rd_ren             ),
    .o_rd_data                                          (rd_beam_pwr            ),
    .o_rd_addr                                          (                       ),
    .o_tvalid                                           (                       ) 
);

always @(posedge i_clk) begin
    rbg_load_out <= pwr_rd_ren;
    if(pwr_rd_ren)
        rd_beam_pwr_out <= rd_beam_pwr;
    else
        rd_beam_pwr_out <= rd_beam_pwr_out;
end


//--------------------------------------------------------------------------------------
// full flag
//--------------------------------------------------------------------------------------
reg            [GRP_NUM-1: 0]                   rd_full               =0;
wire                                            ready_out               ;

always @(posedge i_clk) begin
    for(int i=0;i<GRP_NUM;i=i+1)begin
        if(free_size[i]==0)
            rd_full[i] <= 1'b1;
        else
            rd_full[i] <= 1'b0;
    end
end

assign ready_out = (|rd_full) ? 1'b0 : 1'b1;

//--------------------------------------------------------------------------------------
// Output 
//--------------------------------------------------------------------------------------

assign o_tx_data[0] = rd_dout_dly[0*32 +: 32];
assign o_tx_data[1] = rd_dout_dly[1*32 +: 32];
assign o_tx_data[2] = rd_dout_dly[2*32 +: 32];
assign o_tx_data[3] = rd_dout_dly[3*32 +: 32];
assign o_tx_vld     = rd_dout_vld;
assign o_tx_sop     = re_sop;
assign o_tx_eop     = re_eop;
assign o_prb_idx    = dr_prb_idx;
assign o_tready     = ready_out ;
assign o_pkg_info   = pkg_info  ;
assign o_fft_agc    = dinfo_out_dly[83:20];
assign o_rbg_idx    = dinfo_out_dly[19:16];
assign o_pkg_type   = dinfo_out_dly[15:12];
assign o_cell_idx   = dinfo_out_dly[11];
assign o_slot_idx   = dinfo_out_dly[10: 4];
assign o_symb_idx   = dinfo_out_dly[3: 0];
assign o_ant_pwr    = rd_beam_pwr_out;






endmodule