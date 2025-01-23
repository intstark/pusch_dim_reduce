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


    // cpri txdata
    output         [  63: 0]                        o_cpri_tx_data          ,// cpri data
    output                                          o_cpri_tx_vld            // cpri valid

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
wire           [63:0][ANT*IW-1: 0]              i_code_word_even        ;
wire           [63:0][ANT*IW-1: 0]              i_code_word_odd         ;
reg                                             ant_sop_r             =0;
reg                                             ant_eop_r             =0;
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

reg                                             aiu_idx               =1;
reg            [  15: 0]                        re_num                =0;
reg            [   7: 0]                        rbg_num               =0;
reg            [  15: 0]                        re_num_per_rbg        =0;
wire           [   7: 0]                        rbg_num_max             ;



// code word read
code_word_rev                   code_word_rev
(
    .i_clk                      (i_clk           ),
    .i_reset                    (i_reset         ),
    .i_enable                   (1'b1            ),
    .o_cw_even                  (i_code_word_even),
    .o_cw_odd                   (i_code_word_odd ),
    .o_tvalid                   (                ) 
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

assign bid_rden = ~sym_is_1st & rbg_load;


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
wire                                            iq_abs_valid            ;
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

assign iq_abs_valid  = beam_tvalid_buf[1];   // 2 clock cycle delay
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
//wire           [BEAM*OW-1: 0]                   rbg_sum_all             ;
reg            [BEAM*OW-1: 0]                   rbg_sum_all           =0;

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
        if(iq_abs_valid==0)
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

//    assign rbg_sum_all[gi*OW +: OW] = rbg_sum_abs[gi];    
end
endgenerate

reg [210:0] rbg_load_dly2 = 0;
always @ (posedge i_clk)begin
    rbg_load_dly2    <= {rbg_load_dly2[209:0], rbg_load_acc};
end

generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum_all
    always @(posedge i_clk) begin
        if(rbg_load_dly2[192]) begin
            rbg_sum_all[gi*OW +: OW] <= rbg_sum_abs[gi];
        end
    end
end
endgenerate

lp_buffer_syn # (
    .DATA_WIDTH                                         (2                      ),
    .ADDR_WIDTH                                         (8                      ) 
)lp_buffer_0(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_wr_data                                          ({rbg_load_acc,iq_abs_valid}),
    .i_wr_wen                                           (rbg_load_acc           ),
    .i_wr_vld                                           (iq_abs_valid           ),
    .o_rd_data                                          (                       ),
    .o_rd_vld                                           (                       ),
    .o_rd_sop                                           (                       ) 
);

//------------------------------------------------------------------------------------------
// buffer valid and load signal
//------------------------------------------------------------------------------------------

reg            [   2: 0]                        rbg_load_buf          =0;
reg                                             rbg_sum_load          =0;
reg                                             rbg_sum_vld           =0;
reg            [1:0][7: 0]                      rbg_num_buf           =0;
reg            [   7: 0]                        rbg_abs_addr          =0;
wire           [63:0][OW-1: 0]                  rbg_buffer_out          ;
wire                                            rbg_buffer_vld          ;
wire           [63:0][OW-1: 0]                  beam_sort_out           ;
wire                                            beam_sort_sop           ;
wire                                            beam_sort_vld           ;
wire                                            beam_sort_load          ;

// delay valid
always @(posedge i_clk) begin
    rbg_load_buf    <= {rbg_load_buf[1:0], rbg_load_acc || rbg_acc_tlast};
end

//always @(posedge i_clk) begin
//    if(i_reset)
//        rbg_sum_vld <= 1'b0;
//    else if(rbg_acc_valid && rbg_load_buf[1])
//        rbg_sum_vld <= 1'b1;
//    else if(rbg_acc_valid==0)
//        rbg_sum_vld <= 1'b0;
//end
//
//always @ (posedge i_clk) begin
//    if(rbg_acc_valid)
//        rbg_sum_load <= rbg_load_buf[1];
//    else
//        rbg_sum_load <= 0;
//end

always @ (posedge i_clk) begin
    rbg_sum_load <= rbg_load_dly2[192];
end

reg [210:0] beam_tvld_dly = 0;
always @ (posedge i_clk)begin
    beam_tvld_dly    <= {beam_tvld_dly[209:0], beams_tvalid};
    rbg_sum_vld      <= beam_tvld_dly[194];
end

always @ (posedge i_clk) begin
    if(beams_sop)
        rbg_abs_addr <= 8'd0;
    else if(rbg_sum_vld && rbg_sum_load)
        rbg_abs_addr <= rbg_abs_addr + 8'd1;
end

always @ (posedge i_clk) begin
    rbg_num_buf[0] <= rbg_num_acc;
    for(int i=0; i<1; i++) begin
        rbg_num_buf[i+1] <= rbg_num_buf[i];
    end
    //rbg_abs_addr <= rbg_num_buf[1];
end

//------------------------------------------------------------------------------------------
// beam buffer to align 64 beams data
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
    .i_wr_wen                                           (rbg_sum_load           ),
    .i_wr_data                                          (rbg_sum_abs            ),
    .i_wr_addr                                          (rbg_abs_addr           ),

    .o_rd_data                                          (rbg_buffer_out         ),
    .o_rd_addr                                          (                       ),
    .o_rd_vld                                           (rbg_buffer_vld         ),
    .o_tvalid                                           (rbg_buffer_tvalid      ) 
);

//beam_buffer #(
//    .WDATA_WIDTH                                        (16*OW                  ),
//    .WADDR_WIDTH                                        (8                      ),
//    .RDATA_WIDTH                                        (16*OW                  ),
//    .RADDR_WIDTH                                        (8                      ),
//    .RAM_TYPE                                           (1                      ) 
//)beam_buffer (
//    .i_clk                                              (i_clk                  ),
//    .i_reset                                            (i_reset                ),
//    .i_rvalid                                           (rbg_sum_vld            ),
//    .i_wr_wen                                           (rbg_sum_load           ),
//    .i_wr_data                                          (rbg_sum_all            ),
//    .i_wr_addr                                          (rbg_abs_addr           ),
//    .o_rd_data                                          (rbg_buffer_out         ),
//    .o_rd_addr                                          (                       ),
//    .o_rd_vld                                           (rbg_buffer_vld         ),
//    .o_tvalid                                           (rbg_buffer_tvalid      ) 
//);

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
    .o_rbg_load                                         (beam_sort_load         ),
    .o_idx_sop                                          (beam_sort_sop          ),
    .o_tvalid                                           (beam_sort_vld          ),
    .o_tready                                           (                       ) 
);

//------------------------------------------------------------------------------------------
// beam sort
//------------------------------------------------------------------------------------------
beams_pick_top # (
    .WDATA_WIDTH                                        (40                     ),
    .WADDR_WIDTH                                        (11                     ),
    .RDATA_WIDTH                                        (40                     ),
    .RADDR_WIDTH                                        (11                     )
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
// dynamical scaler 
//------------------------------------------------------------------------------------------
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
    .o_sop                                              (                       ),
    .o_eop                                              (                       ),
    .o_vld                                              (                       ),
    .o_dout_re                                          (                       ),
    .o_dout_im                                          (                       ),
    .o_shift                                            (                       ),
    .o_slot_idx                                         (                       ),
    .o_symb_idx                                         (                       ),
    .o_prb_idx                                          (                       ),
    .o_type                                             (                       ),
    .o_info                                             (                       ) 
);





endmodule