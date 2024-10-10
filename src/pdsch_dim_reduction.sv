//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: pdsch_dim_reduction 
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
module pdsch_dim_reduction #(
    parameter integer LANE               =  8    ,
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  12   ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  12   ,
    parameter integer FIFO_DEPTH         =  8    ,
    parameter integer FIFO_WIDTH         =  1    ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  15   ,    
    parameter integer INFO_WIDTH         =  1    ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,   // data clock
    input                                           i_reset                 ,   // reset

    input          [LANE-1: 0]                      i_cpri_clk              ,   // cpri clkout
    input          [LANE-1: 0]                      i_cpri_rst              ,   // cpri reset
    input          [LANE-1:0][63: 0]                i_cpri_rx_data          ,   // cpri data
    input          [LANE-1:0][6: 0]                 i_cpri_rx_seq           ,   // cpri seq
    input          [LANE-1: 0]                      i_cpri_rx_vld           ,   // cpri valid

    input          [63:0][32*32-1: 0]               i_code_word_even        ,
    input          [63:0][32*32-1: 0]               i_code_word_odd         ,

    input                                           i_sym1_done             ,    
    input          [   1: 0]                        i_rbg_size              ,

    output         [LANE*4*32-1: 0]                 o_ant_even              ,
    output         [LANE*4*32-1: 0]                 o_ant_odd               ,
    output         [RADDR_WIDTH-1: 0]               o_ant_addr              ,
    output                                          o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam   BEAM =   16;     // number of data streams
localparam   ANT  =   32;     // number of data streams
localparam   IW   =   32;     // number of data streams
localparam   OW   =   48;     // output width
genvar gi;


//------------------------------------------------------------------------------------------
// RAM BLOCK FOR CPRI DATA FOR 7 SYMBOLS 
//------------------------------------------------------------------------------------------
wire           [LANE-1:0][10: 0]                unpack_iq_addr          ;
wire           [LANE-1:0][3:0][31: 0]           unpack_iq_data          ;
wire           [LANE-1: 0]                      unpack_iq_vld           ;
wire           [LANE-1: 0]                      unpack_iq_last          ;

wire           [LANE-1:0][4*32-1: 0]            ant_even                ;
wire           [LANE-1:0][4*32-1: 0]            ant_odd                 ;
wire           [LANE-1:0][11-1: 0]              ant_addr                ;
wire           [LANE-1: 0]                      ant_tvalid              ;

reg            [LANE*4*32-1: 0]                 ant_data_even         =0;
reg            [LANE*4*32-1: 0]                 ant_data_odd          =0;

wire           [BEAM-1:0][OW-1: 0]              beams_sum_even          ;
wire           [BEAM-1:0][OW-1: 0]              beams_sum_odd           ;
wire           [BEAM-1:0][OW-1: 0]              beams_sum_ants          ;
wire                                            beams_tvalid            ;
reg                                             sym1_done             =0;

//------------------------------------------------------------------------------------------
// unpack cpri data for 8 lanes
//------------------------------------------------------------------------------------------
generate for(gi=0;gi<LANE;gi=gi+1) begin:gen_rxdata_unpack
    // Instantiate the Unit Under Test (UUT)
    cpri_rxdata_unpack                                      cpri_rxdata_unpack_4ant
    (

        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_cpri_clk                                         (i_cpri_clk    [gi]     ),
        .i_cpri_rst                                         (i_cpri_rst    [gi]     ),
        .i_cpri_rx_data                                     (i_cpri_rx_data[gi]     ),
        .i_cpri_rx_seq                                      (i_cpri_rx_seq [gi]     ),
        .i_cpri_rx_vld                                      (i_cpri_rx_vld [gi]     ),
        .i_sym1_done                                        (sym1_done              ),
        .o_iq_addr                                          (unpack_iq_addr[gi]     ),
        .o_iq_data                                          (unpack_iq_data[gi]     ),
        .o_iq_vld                                           (unpack_iq_vld [gi]     ),
        .o_iq_last                                          (unpack_iq_last[gi]     ) 
    );
    
    // ant data buffer for 4 antennas
    ant_data_buffer #(
        .ANT                                                (4                      ),
        .WDATA_WIDTH                                        (128                    ),
        .WADDR_WIDTH                                        (11                     ),
        .RDATA_WIDTH                                        (128                    ),
        .RADDR_WIDTH                                        (11                     ),
        .READ_LATENCY                                       (3                      ),
        .FIFO_DEPTH                                         (16                     ),
        .FIFO_WIDTH                                         (1                      ),
        .LOOP_WIDTH                                         (12                     ),
        .INFO_WIDTH                                         (1                      ),
        .RAM_TYPE                                           (1                      ) 
    )ant_data_buffer(
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_iq_addr                                          (unpack_iq_addr[gi]     ),
        .i_iq_data                                          (unpack_iq_data[gi]     ),
        .i_iq_vld                                           (unpack_iq_vld [gi]     ),
        .i_iq_last                                          (unpack_iq_last[gi]     ),
        .o_ant_even                                         (ant_even      [gi]     ),
        .o_ant_odd                                          (ant_odd       [gi]     ),
        .o_ant_addr                                         (ant_addr      [gi]     ),
        .o_tvalid                                           (ant_tvalid    [gi]     ) 
    );

    // Get 32 ants data, one clock pipe
    always @(posedge i_clk) begin
        ant_data_even[gi*4*32 +: 4*32] <= ant_even[gi];       
        ant_data_odd [gi*4*32 +: 4*32] <= ant_odd [gi];
    end

end
endgenerate


//------------------------------------------------------------------------------------------
// code word 
//------------------------------------------------------------------------------------------
reg                                             ant_tvalid_r          =0;
wire                                            ant_tvld_pos            ;
reg            [   7: 0]                        ant_buffer_sym        =0;
reg            [15:0][ANT*IW-1: 0]              code_word_even        ='{default:0};
reg            [15:0][ANT*IW-1: 0]              code_word_odd         ='{default:0};
reg            [15:0][ANT*IW-1: 0]              code_word_even_map    =0;
reg            [15:0][ANT*IW-1: 0]              code_word_odd_map     =0;
wire           [BEAM-1:0][7: 0]                 beam_sort_idx           ;
reg                                             sym_is_1st            =1;
wire                                            rbg_slip                ;
wire                                            rbg_load                ;
wire                                            bid_rden                ;



always @ (posedge i_clk) begin
    ant_tvalid_r <= ant_tvalid[0];
end

assign ant_tvld_pos = ~ant_tvalid[0] & (ant_tvalid_r);

always @(posedge i_clk) begin
    if(i_reset)
        ant_buffer_sym <= 'd0;
    else if(ant_tvld_pos)
        ant_buffer_sym <= ant_buffer_sym + 'd1;
end

always @(posedge i_clk) begin
    case(ant_buffer_sym)
        8'd0: begin
                sym_is_1st      <= 1'b1;
                code_word_even  <= i_code_word_even[15:0];
                code_word_odd   <= i_code_word_odd [15:0];
            end
        8'd1: begin
                sym_is_1st      <= 1'b1;
                code_word_even  <= i_code_word_even[31:16];
                code_word_odd   <= i_code_word_odd [31:16];
            end
        8'd2: begin
                sym_is_1st      <= 1'b1;
                code_word_even  <= i_code_word_even[47:32];
                code_word_odd   <= i_code_word_odd [47:32];
            end
        8'd3: begin
                sym_is_1st      <= 1'b1;
                code_word_even  <= i_code_word_even[63:48];
                code_word_odd   <= i_code_word_odd [63:48];
            end
        default: begin
                sym_is_1st      <= 1'b0;
                if(rbg_load)begin
                    code_word_even  <= code_word_even_map[15:0];
                    code_word_odd   <= code_word_odd_map [15:0];
                end
            end
    endcase
end


always @(posedge i_clk) begin
    for(int i=0;i<16;i=i+1) begin
        code_word_even_map[i] <= i_code_word_even[beam_sort_idx[i]];
        code_word_odd_map[i]  <= i_code_word_odd [beam_sort_idx[i]];
    end
end

reg                                             aiu_idx               =1;
reg            [  15: 0]                        re_num                =0;
reg            [   7: 0]                        rbg_num               =0;
reg            [  15: 0]                        re_num_per_rbg        =0;
wire           [   7: 0]                        rbg_num_max             ;

assign rbg_num_max = (i_rbg_size == 2'b00) ? 8'd32  :
                     (i_rbg_size == 2'b01) ? 8'd16  :
                     (i_rbg_size == 2'b10) ? 8'd8   : 8'd8;



// re number per rbG based on rbg size
always @ (posedge i_clk) begin
    case(i_rbg_size)
        2'b00:  re_num_per_rbg <= 'd48;    // rbG=4 PRRs
        2'b01:  begin
                    if(aiu_idx==0 && rbg_num==0)
                        re_num_per_rbg <= 'd48;     // rbG=4 PRRs
                    else if(aiu_idx==1 && rbg_num==rbg_num_max)
                        re_num_per_rbg <= 'd48;     // rbG=4 PRRs
                    else
                        re_num_per_rbg <= 'd96;    // rbG=8 PRRs
                end
        2'b10:  begin
                    if(aiu_idx==0 && rbg_num==0)
                        re_num_per_rbg <= 'd48;     // rbG=4 PRRs
                    else if(aiu_idx==1 && rbg_num==rbg_num_max)
                        re_num_per_rbg <= 'd48;     // rbG=4 PRRs
                    else
                        re_num_per_rbg <= 'd192;    // rbG=16 PRRs
                end
        default:re_num_per_rbg <= 'd48;
    endcase
end

always @ (posedge i_clk)begin
    if(re_num == re_num_per_rbg-1)
        re_num <= 'd0;
    else if(ant_tvalid[0])
        re_num <= re_num + 1'b1;
end


assign rbg_slip = (re_num == re_num_per_rbg-1) ? 1'b1 : 1'b0;
assign rbg_load = (ant_tvalid[0] && re_num == 0) ? 1'b1 : 1'b0;

// rbG number
always @ (posedge i_clk)begin
    if(i_reset || ant_tvld_pos)
        rbg_num <= 'd0;
    else if(rbg_slip)
        rbg_num <= rbg_num + 'd1;
end


//------------------------------------------------------------------------------------------
// BEAMS MAC BLOCK FOR 16 BEAMS
//------------------------------------------------------------------------------------------
mac_beams #(
    .BEAM                                               (BEAM                   ),
    .ANT                                                (ANT                    ),
    .IW                                                 (IW                     ),
    .OW                                                 (OW                     ) 
)mac_beams(
    .i_clk                                              (i_clk                  ),
    .i_ants_data_even                                   (ant_data_even          ),
    .i_ants_data_odd                                    (ant_data_odd           ),
    .i_rvalid                                           (ant_tvalid_r           ),
    .i_code_word_even                                   (code_word_even         ),
    .i_code_word_odd                                    (code_word_odd          ),
    .o_sum_data_even                                    (beams_sum_even         ),
    .o_sum_data_odd                                     (beams_sum_odd          ),
    .o_sum_data                                         (beams_sum_ants         ),
    .o_tvalid                                           (beams_tvalid           ) 
);


assign o_ant_even = ant_data_even ;
assign o_ant_odd  = ant_data_odd  ;
assign o_ant_addr = ant_addr[0]   ;
assign o_tvalid   = ant_tvalid[0] ;

//------------------------------------------------------------------------------------------
// beams process counter
//------------------------------------------------------------------------------------------
reg                                             beams_tvalid_r        =0;
wire                                            beams_tvld_pos          ;
wire                                            beams_tvld_neg          ;
reg            [   7: 0]                        beams_blk_num         =0;

always @ (posedge i_clk) begin
    beams_tvalid_r <= beams_tvalid;
end


assign beams_tvld_pos = beams_tvalid & (~beams_tvalid_r);
assign beams_tvld_neg = ~beams_tvalid & (beams_tvalid_r);


always @ (posedge i_clk) begin
    if(i_reset)
        beams_blk_num <= 0;
    else if(beams_tvld_neg)
        beams_blk_num <= beams_blk_num + 1;
end

always @ (posedge i_clk) begin
    if(i_reset)
        sym1_done <= 0;
    else if(beams_blk_num==3 && beams_tvld_neg)
        sym1_done <= 1;
end

assign bid_rden = ~sym_is_1st & rbg_load;


//------------------------------------------------------------------------------------------
// rbG sum 
//------------------------------------------------------------------------------------------

reg            [BEAM-1:0][OW-1: 0]              rbg_acc_re            ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_sum_abs           ='{default:0};
reg            [14:0][7: 0]                     re_num_dly            ='{default:0};
reg            [14:0][7: 0]                     rbg_num_dly           ='{default:0};
reg            [  14: 0]                        rbg_load_dly          =0;
wire           [   7: 0]                        rbg_num_acc             ;
wire           [   7: 0]                        re_num_acc              ;
wire                                            rbg_load_acc            ;
wire           [BEAM*OW-1: 0]                   rbg_sum_all             ;

always @ (posedge i_clk)begin
    re_num_dly[0]   <= re_num;
    rbg_num_dly[0]  <= rbg_num;
    rbg_load_dly    <= {rbg_load_dly[13:0], rbg_load};

    for(int i=0; i<15; i++) begin
        re_num_dly[i+1] <= re_num_dly[i];
        rbg_num_dly[i+1] <= rbg_num_dly[i];
    end
end

assign re_num_acc   = re_num_dly  [14];
assign rbg_num_acc  = rbg_num_dly [14];
assign rbg_load_acc = rbg_load_dly[14];

// re accumulator
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_acc
    always @(posedge i_clk) begin
        if(beams_tvalid==0)
            rbg_acc_re[gi] <= 'd0;
        else if(rbg_load_acc)
            rbg_acc_re[gi] <= signed'(beams_sum_ants[gi]);
        else
            rbg_acc_re[gi] <= signed'(rbg_acc_re[gi]) + signed'(beams_sum_ants[gi]);
    end
end
endgenerate

generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum
    always @(posedge i_clk) begin
        if(rbg_load_acc || beams_tvld_neg) begin
            rbg_sum_abs[gi] <= rbg_acc_re[gi];
        end
    end

    assign rbg_sum_all[gi*OW +: OW] = rbg_sum_abs[gi];    
end
endgenerate

//------------------------------------------------------------------------------------------
// buffer valid and load signal
//------------------------------------------------------------------------------------------
reg            [   4: 0]                        beam_tvalid_buf       =0;
reg            [   2: 0]                        rbg_load_buf          =0;
reg                                             rbg_sum_load          =0;
reg                                             rbg_sum_vld           =0;
reg            [1:0][7: 0]                      rbg_num_buf           =0;
reg            [   7: 0]                        rbg_abs_addr          =0;
wire           [63:0][OW-1: 0]                  rbg_buffer_out          ;
wire                                            rbg_buffer_vld          ;
wire           [63:0][OW-1: 0]                  beam_sort_out           ;
wire                                            beam_sort_vld           ;

always @(posedge i_clk) begin
    beam_tvalid_buf <= {beam_tvalid_buf[3:0], beams_tvalid};
    rbg_load_buf    <= {rbg_load_buf[1:0], rbg_load_acc || beams_tvld_neg};
end

always @(posedge i_clk) begin
    if(i_reset)
        rbg_sum_vld <= 1'b0;
    else if(beam_tvalid_buf[3] && rbg_load_buf[2])
        rbg_sum_vld <= 1'b1;
    else if(beam_tvalid_buf[3]==0)
        rbg_sum_vld <= 1'b0;
end

always @ (posedge i_clk) begin
    if(beam_tvalid_buf[3])
        rbg_sum_load <= rbg_load_buf[2];
    else
        rbg_sum_load <= 0;
end

always @ (posedge i_clk) begin
    rbg_num_buf[0] <= rbg_num_acc;
    for(int i=0; i<1; i++) begin
        rbg_num_buf[i+1] <= rbg_num_buf[i];
    end
    rbg_abs_addr <= rbg_num_buf[1];
end

//------------------------------------------------------------------------------------------
// beam buffer to align 64 beams data
//------------------------------------------------------------------------------------------
beam_buffer #(
    .WDATA_WIDTH                                        (16*OW                  ),
    .WADDR_WIDTH                                        (8                      ),
    .RDATA_WIDTH                                        (16*OW                  ),
    .RADDR_WIDTH                                        (8                      ),
    .RAM_TYPE                                           (1                      ) 
)beam_buffer (
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (rbg_sum_vld            ),
    .i_wr_wen                                           (rbg_sum_load           ),
    .i_wr_data                                          (rbg_sum_all            ),
    .i_wr_addr                                          (rbg_abs_addr           ),
    .o_rd_data                                          (rbg_buffer_out         ),
    .o_rd_addr                                          (                       ),
    .o_rd_vld                                           (rbg_buffer_vld         ),
    .o_tvalid                                           (rbg_buffer_tvalid      ) 
);



//------------------------------------------------------------------------------------------
// beam sort
//------------------------------------------------------------------------------------------
beam_sort # (
    .IW                                                 (OW                     ),
    .COL                                                (64                     ) 
)beam_sort(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_data                                             (rbg_buffer_out         ),
    .i_enable                                           (rbg_buffer_tvalid      ),
    .i_rready                                           (1'b1                   ),
    .i_rvalid                                           (rbg_buffer_vld         ),

    .i_bid_rden                                         (bid_rden               ),
    .i_rbg_max                                          (rbg_num_max            ),
    
    .o_data                                             (beam_sort_out          ),
    .o_score                                            (                       ),
    .o_beam_index                                       (beam_sort_idx          ),
    .o_rbg_num                                          (                       ),
    .o_rbg_load                                         (beam_sort_vld          ),
    .o_tvalid                                           (                       ),
    .o_tready                                           (                       ) 
);






endmodule