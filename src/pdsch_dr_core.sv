//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: pdsch_dr_core
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
module pdsch_dr_core #(
    parameter integer LANE  =   8 
)(
    input                                           i_clk                   ,// data clock
    input                                           i_reset                 ,// reset

    input          [   1: 0]                        i_rbg_size              ,// default:2'b10 16rb

    // cpri rxdata
    input          [LANE-1:0][10: 0]                i_iq_addr               ,// 4 ants iq addr
    input          [LANE-1:0][4*32-1: 0]            i_iq_data               ,// 4 ants iq data
    input          [LANE-1: 0]                      i_iq_vld                ,// 4 ants iq vld
    input          [LANE-1: 0]                      i_iq_last               ,// 4 ants iq last(132prb ends)

    // output dr data
    output         [3:0][31: 0]                     o_tx_data               ,
    output                                          o_tx_vld                , 
    output                                          o_tx_sop                ,
    output                                          o_tx_eop                ,
    output         [   8: 0]                        o_prb_idx               

);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam   BEAM =   16;     // number of beams 
localparam   ANT  =   32;     // number of antenas 
localparam   IW   =   32;     // input width
localparam   OW   =   40;     // output width
genvar gi;


//------------------------------------------------------------------------------------------
// RAM BLOCK FOR CPRI DATA FOR 7 SYMBOLS 
//------------------------------------------------------------------------------------------
wire           [LANE-1:0][4*32-1: 0]            ant_even                ;
wire           [LANE-1:0][4*32-1: 0]            ant_odd                 ;
wire           [LANE-1:0][11-1: 0]              ant_addr                ;
wire           [LANE-1: 0]                      ant_tvalid              ;
wire           [LANE-1: 0]                      ant_sop                 ;
wire           [LANE-1: 0]                      ant_eop                 ;


reg            [LANE*4*32-1: 0]                 ant_data_even         =0;
reg            [LANE*4*32-1: 0]                 ant_data_odd          =0;

wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_i            ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_q            ;
wire                                            beams_tvalid            ;
wire                                            beams_sop               ;
wire                                            beams_eop               ;

reg                                             sym1_done             =0;
wire           [LANE-1: 0]                      w_cpri_clk              ;
wire           [LANE-1: 0]                      w_cpri_rst              ;
wire           [LANE-1:0][63: 0]                w_cpri_rx_data          ;
wire           [LANE-1: 0]                      w_cpri_rx_vld           ;

wire     signed[BEAM-1:0][OW-1: 0]              beams_pick_i            ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_pick_q            ;
wire                                            beams_pick_vld          ;
wire                                            beams_pick_sop          ;
wire                                            beams_pick_eop          ;

//------------------------------------------------------------------------------------------
// unpack cpri data for 8 lanes
//------------------------------------------------------------------------------------------
generate for(gi=0;gi<LANE;gi=gi+1) begin: ant_data_buffer
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
        .i_iq_addr                                          (i_iq_addr     [gi]     ),
        .i_iq_data                                          (i_iq_data     [gi]     ),
        .i_iq_vld                                           (i_iq_vld      [gi]     ),
        .i_iq_last                                          (i_iq_last     [gi]     ),
        .o_ant_even                                         (ant_even      [gi]     ),
        .o_ant_odd                                          (ant_odd       [gi]     ),
        .o_ant_addr                                         (ant_addr      [gi]     ),
        .o_ant_sop                                          (ant_sop       [gi]     ), 
        .o_ant_eop                                          (ant_eop       [gi]     ), 
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
wire           [63:0][ANT*IW-1: 0]              rev_cw_even             ;
wire           [63:0][ANT*IW-1: 0]              rev_cw_odd              ;
reg            [15:0][ANT*IW-1: 0]              code_word_even        ='{default:0};
reg            [15:0][ANT*IW-1: 0]              code_word_odd         ='{default:0};
reg            [15:0][ANT*IW-1: 0]              cw_even_select        ='{default:0};
reg            [15:0][ANT*IW-1: 0]              cw_odd_select         ='{default:0};

reg                                             ant_sop_r             =0;
reg                                             ant_eop_r             =0;
reg                                             ant_tvalid_r          =0;
wire                                            ant_tvld_pos            ;
reg            [   7: 0]                        ant_buffer_sym        =0;

wire           [BEAM-1:0][7: 0]                 beam_sort_idx           ;
reg                                             sym_is_1st            =1;
wire                                            rbg_slip                ;
wire                                            rbg_load                ;

reg                                             aiu_idx               =0;
reg            [   7: 0]                        re_num                =0;
reg            [   7: 0]                        rbg_num               =0;
reg            [   7: 0]                        re_num_per_rbg        =0;
wire           [   7: 0]                        rbg_num_max             ;



// code word read
code_word_rev                                           code_word_rev
(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_enable                                           (1'b1                   ),
    .o_cw_even                                          (rev_cw_even            ),
    .o_cw_odd                                           (rev_cw_odd             ),
    .o_tvalid                                           (                       ) 
);



always @ (posedge i_clk) begin
    ant_tvalid_r <= ant_tvalid[0];
    ant_sop_r    <= ant_sop   [0];
    ant_eop_r    <= ant_eop   [0];
end

assign ant_tvld_pos = ~ant_tvalid[0] & (ant_tvalid_r);

always @(posedge i_clk) begin
    if(i_reset)
        ant_buffer_sym <= 'd0;
    else if(ant_eop[0])
        ant_buffer_sym <= ant_buffer_sym + 'd1;
end

reg            [   1: 0]                        symb_phx              =0;
reg            [BEAM-1:0][1: 0]                 symb_phx_vec          =0;
reg            [BEAM-1: 0]                      symb_1st_vec          ={BEAM{1'b1}};

always @(posedge i_clk) begin
    symb_phx <= ant_buffer_sym[1:0];
    if(i_reset)
        sym_is_1st <= 'd1;
    else if(ant_buffer_sym < 8'd4)
        sym_is_1st <= 'd1;
    else
        sym_is_1st <= 'd0;
end

always @(posedge i_clk) begin
    for(int i=0;i<BEAM;i=i+1) begin
        symb_1st_vec[i] <= sym_is_1st;
        symb_phx_vec[i] <= symb_phx;
    end
end

always @(posedge i_clk) begin
    for(int i=0;i<BEAM;i=i+1) begin
        if(symb_1st_vec[i])begin
            case(symb_phx_vec[i])
                2'd0:   begin
                            code_word_even[i]  <= rev_cw_even[i];
                            code_word_odd [i]  <= rev_cw_odd [i];
                        end
                2'd1:   begin
                            code_word_even[i]  <= rev_cw_even[i+16];
                            code_word_odd [i]  <= rev_cw_odd [i+16];
                        end
                2'd2:   begin
                            code_word_even[i]  <= rev_cw_even[i+32];
                            code_word_odd [i]  <= rev_cw_odd [i+32];
                        end
                2'd3:   begin
                            code_word_even[i]  <= rev_cw_even[i+48];
                            code_word_odd [i]  <= rev_cw_odd [i+48];
                        end
                default:begin
                            code_word_even[i]  <= rev_cw_even[i];
                            code_word_odd [i]  <= rev_cw_odd [i];
                        end
            endcase
        end else begin
            if(rbg_load)begin
                code_word_even[i]  <= cw_even_select[i];
                code_word_odd [i]  <= cw_odd_select [i];
            end
        end
    end
end


always @(posedge i_clk) begin
    for(int i=0;i<BEAM;i=i+1) begin
        cw_even_select[i] <= rev_cw_even[beam_sort_idx[i]];
        cw_odd_select[i]  <= rev_cw_odd [beam_sort_idx[i]];
    end
end


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
                        re_num_per_rbg <= 'd96;     // rbG=8 PRRs
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
    if(i_reset)
        rbg_num <= 'd0;
    else if(rbg_num == rbg_num_max && rbg_slip)
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
    .i_sop                                              (ant_sop_r              ),
    .i_eop                                              (ant_eop_r              ),
    .i_code_word_even                                   (code_word_even         ),
    .i_code_word_odd                                    (code_word_odd          ),
    .o_data_even_i                                      (                       ),
    .o_data_even_q                                      (                       ),
    .o_data_odd_i                                       (                       ),
    .o_data_odd_q                                       (                       ),
    .o_data_i                                           (beams_ants_i           ),
    .o_data_q                                           (beams_ants_q           ),
    .o_sop                                              (beams_sop              ), 
    .o_eop                                              (beams_eop              ), 
    .o_tvalid                                           (beams_tvalid           ) 
);


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




//------------------------------------------------------------------------------------------
// ABS |I|+|Q|: 2 clock cycle
//------------------------------------------------------------------------------------------
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_sft_i        ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_sft_q        ;
reg            [BEAM-1:0][OW-1: 0]              beams_ants_abs_iq     =0;
reg            [BEAM-1:0][OW-1: 0]              beams_ants_abs_i      =0;
reg            [BEAM-1:0][OW-1: 0]              beams_ants_abs_q      =0;
reg            [   4: 0]                        beam_tvalid_buf       =0;
reg            [   1: 0]                        beam_tlast_buf        =0;
wire                                            iq_abs_vld              ;
wire                                            rbg_acc_valid           ;
wire                                            rbg_acc_tlast           ;

// right shift 6 bits SQ(40,21)
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_shift
    assign beams_ants_sft_i[gi] = signed'(beams_ants_i[gi])>>>8;
    assign beams_ants_sft_q[gi] = signed'(beams_ants_q[gi])>>>8;
end
endgenerate

// real part abs
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_abs_re
    always @(posedge i_clk) begin
        if(beams_ants_sft_i[gi][OW-1] == 1'b0)
            beams_ants_abs_i[gi] <= beams_ants_sft_i[gi];
        else
            beams_ants_abs_i[gi] <= ~beams_ants_sft_i[gi] + 'd1;
    end
end
endgenerate

// imaginary part abs
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_abs_im
    always @(posedge i_clk) begin
        if(beams_ants_sft_q[gi][OW-1] == 1'b0)
            beams_ants_abs_q[gi] <= beams_ants_sft_q[gi];
        else
            beams_ants_abs_q[gi] <= ~beams_ants_sft_q[gi] + 'd1;
    end
end
endgenerate

// |real| + |imaginary|
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_re_im
    always @(posedge i_clk) begin
        beams_ants_abs_iq[gi] <= beams_ants_abs_i[gi] + beams_ants_abs_q[gi];
    end
end
endgenerate

// delay valid
always @(posedge i_clk) begin
    beam_tvalid_buf <= {beam_tvalid_buf[3:0], beams_tvalid};
    beam_tlast_buf <= {beam_tlast_buf[0], beams_tvld_neg};
end

assign iq_abs_vld    = beam_tvalid_buf[1];   // 2 clock cycle delay
assign rbg_acc_valid = beam_tvalid_buf[4];  // 4 clock cycle delay
assign rbg_acc_tlast = beam_tlast_buf[1];  // 4 clock cycle delay

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

reg            [BEAM*OW-1: 0]                   rbg_sum_all           =0;
reg                                             rbg_sum_load          =0;
wire                                            rbg_sum_load_lp         ;
wire                                            rbg_sum_vld_lp          ;
reg                                             rbg_sum_wen           =0;
reg                                             rbg_sum_vld           =0;
reg            [   7: 0]                        rbg_abs_addr          =0;
reg            [   2: 0]                        rbg_store_en          =0;



always @ (posedge i_clk)begin
    re_num_dly[0]   <= re_num;
    rbg_num_dly[0]  <= rbg_num;
    rbg_load_dly    <= {rbg_load_dly[13:0], rbg_load};

    for(int i=0; i<14; i++) begin
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
        if(iq_abs_vld==0)
            rbg_acc_re[gi] <= 'd0;
        else if(rbg_load_acc)
            rbg_acc_re[gi] <= signed'(beams_ants_abs_iq[gi]);
        else
            rbg_acc_re[gi] <= signed'(rbg_acc_re[gi]) + signed'(beams_ants_abs_iq[gi]);
    end
end
endgenerate

// store sum when rbG ends
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum
    always @(posedge i_clk) begin
        if(rbg_load_acc || rbg_acc_tlast) begin
            rbg_sum_abs[gi] <= rbg_acc_re[gi];
        end
    end

end
endgenerate

always @(posedge i_clk) begin
    rbg_store_en <= {rbg_store_en[1:0], rbg_load_acc || rbg_acc_tlast};
end

generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum_all
    always @(posedge i_clk) begin
        if(rbg_store_en[0]) begin
            rbg_sum_all[gi*OW +: OW] <= rbg_sum_abs[gi];
        end
    end
end
endgenerate

lp_buffer_syn # (
    .DATA_WIDTH                                         (2                                  ),
    .ADDR_WIDTH                                         (8                                  ) 
)lp_buffer_0(
    .i_clk                                              (i_clk                              ),
    .i_reset                                            (i_reset                            ),
    .i_wr_data                                          ({rbg_load_acc,iq_abs_vld}          ),
    .i_wr_wen                                           (rbg_load_acc                       ),
    .i_wr_vld                                           (iq_abs_vld                         ),
    .o_rd_data                                          ({rbg_sum_load_lp,rbg_sum_vld_lp}   ),
    .o_rd_vld                                           (                                   ),
    .o_rd_sop                                           (                                   ) 
);

always @ (posedge i_clk) begin
    if(rbg_sum_vld_lp)
        rbg_sum_wen <= rbg_store_en[1];
    else 
        rbg_sum_wen <= 0;
    rbg_sum_vld  <= rbg_sum_vld_lp;
    rbg_sum_load <= rbg_sum_load_lp;
end

always @ (posedge i_clk) begin
    if(beams_sop)
        rbg_abs_addr <= 8'd0;
    else if(rbg_sum_vld && rbg_sum_wen)
        rbg_abs_addr <= rbg_abs_addr + 8'd1;
end


//------------------------------------------------------------------------------------------
// buffer valid and load signal
//------------------------------------------------------------------------------------------
wire           [63:0][OW-1: 0]                  rbg_buffer_out          ;
wire                                            rbg_buffer_vld          ;
wire           [63:0][OW-1: 0]                  beam_sort_out           ;
wire                                            beam_sort_sop           ;
wire                                            beam_sort_vld           ;
wire                                            beam_sort_load          ;

//------------------------------------------------------------------------------------------
// beam buffer: align 64 beams data
//------------------------------------------------------------------------------------------
beam_buffer #(
    .WDATA_WIDTH                                        (OW                     ),
    .WADDR_WIDTH                                        (8                      ),
    .RDATA_WIDTH                                        (OW                     ),
    .RADDR_WIDTH                                        (8                      ) 
)beam_buffer (
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (rbg_sum_vld            ),
    .i_wr_wen                                           (rbg_sum_wen            ),
    .i_wr_data                                          (rbg_sum_abs            ),
    .i_wr_addr                                          (rbg_abs_addr           ),

    .o_rd_data                                          (rbg_buffer_out         ),
    .o_rd_addr                                          (                       ),
    .o_rd_vld                                           (rbg_buffer_vld         ),
    .o_tvalid                                           (rbg_buffer_tvalid      ) 
);

//------------------------------------------------------------------------------------------
// beam sort: sort 64 beams data based on the power of beams
//------------------------------------------------------------------------------------------
beam_sort # (
    .IW                                                 (OW                     ), // input data width
    .COL                                                (64                     )  // input data stream number 
)beam_sort(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_data                                             (rbg_buffer_out         ),
    .i_enable                                           (rbg_buffer_tvalid      ),
    .i_rready                                           (1'b1                   ),
    .i_rvalid                                           (rbg_buffer_vld         ),

    .i_rbg_max                                          (rbg_num_max            ),
    .i_rbg_load                                         (rbg_load               ),
    .i_bid_rdinit                                       (rbg_sum_load           ),
    
    .o_data                                             (beam_sort_out          ),
    .o_score                                            (                       ),
    .o_beam_index                                       (beam_sort_idx          ),
    .o_rbg_num                                          (                       ),
    .o_rbg_load                                         (beam_sort_load         ),
    .o_idx_sop                                          (beam_sort_sop          ),
    .o_tvalid                                           (beam_sort_vld          ),
    .o_tready                                           (                       ) 
);

//------------------------------------------------------------------------------------------
// beams_pick_top: select top 16 beams based on beam_sort_idx
//------------------------------------------------------------------------------------------
beams_pick_top # (
    .WDATA_WIDTH                                        (40                     ), // write data width
    .WADDR_WIDTH                                        (11                     ), // bram address width
    .RDATA_WIDTH                                        (40                     ), // read data width 
    .RADDR_WIDTH                                        (11                     )  // bram address width
)beams_pick_top(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvld                                             (beams_tvalid           ),
    .i_eop                                              (beams_eop              ),
    .i_data_re                                          (beams_ants_i           ),
    .i_data_im                                          (beams_ants_q           ),
    .i_sort_idx                                         (beam_sort_idx          ),
    .i_sort_sop                                         (beam_sort_sop          ),
    .i_sym_1st                                          (sym_is_1st             ),

    .o_data_re                                          (beams_pick_i           ),
    .o_data_im                                          (beams_pick_q           ),
    .o_sop                                              (beams_pick_sop         ),
    .o_eop                                              (beams_pick_eop         ),
    .o_tvld                                             (beams_pick_vld         ) 
);

//------------------------------------------------------------------------------------------
// dynamical scaler: compress 40 bits to 16 bits
//------------------------------------------------------------------------------------------
wire           [15:0][15: 0]                    dr_data_re              ;
wire           [15:0][15: 0]                    dr_data_im              ;
wire                                            dr_vld                  ;
wire                                            dr_sop                  ;
wire                                            dr_eop                  ;
wire           [   8: 0]                        dr_prb_idx              ;

compress_matrix #(
    .IW                                                 (OW                     ),
    .OW                                                 (16                     )
)compress_matrix(
    .clk                                                (i_clk                  ),
    .rst                                                (i_reset                ),
    .i_sel                                              (                       ),
    .i_sop                                              (beams_pick_sop         ),
    .i_eop                                              (beams_pick_eop         ),
    .i_vld                                              (beams_pick_vld         ),
    .i_din_re                                           (beams_pick_i           ),
    .i_din_im                                           (beams_pick_q           ),
    .i_slot_idx                                         (                       ),
    .i_symb_idx                                         (                       ),
    .i_prb_idx                                          (                       ),
    .i_ch_type                                          (                       ),
    .i_info                                             (                       ),
    .o_sel                                              (                       ),
    .o_sop                                              (dr_sop                 ),
    .o_eop                                              (dr_eop                 ),
    .o_vld                                              (dr_vld                 ),
    .o_dout_re                                          (dr_data_re             ),
    .o_dout_im                                          (dr_data_im             ),
    .o_shift                                            (                       ),
    .o_slot_idx                                         (                       ),
    .o_symb_idx                                         (                       ),
    .o_prb_idx                                          (                       ),
    .o_type                                             (                       ),
    .o_info                                             (                       ) 
);

//------------------------------------------------------------------------------------------
// store 16 beams data, output 4 beaams data 
// -----------------------------------------------------------------------------------------
wire           [15:0][31: 0]                    dr_data_iq              ;
for(genvar i=0;i<16;i++)begin: gen_dr_data_iq
    assign dr_data_iq[i] = {dr_data_re[i],dr_data_im[i]};
end

dr_data_buffer                                          dr_data_buffer(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rx_data                                          (dr_data_iq             ),
    .i_rx_vld                                           (dr_vld                 ),
    .i_rx_sop                                           (dr_sop                 ),
    .i_rx_eop                                           (dr_eop                 ),
    .i_rready                                           (1'b1                   ),
    .o_tx_data                                          (o_tx_data              ),
    .o_tx_vld                                           (o_tx_vld               ),
    .o_tx_sop                                           (o_tx_sop               ),
    .o_tx_eop                                           (o_tx_eop               ),
    .o_prb_idx                                          (o_prb_idx              )
);



endmodule