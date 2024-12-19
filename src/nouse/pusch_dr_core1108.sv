//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: pusch_dr_core
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
module pusch_dr_core #(
    parameter integer LANE  =   8 
)(
    input                                           i_clk                   ,   // data clock
    input                                           i_reset                 ,   // reset

    input          [   1: 0]                        i_rbg_size              ,   // default:2'b10 16rb
    input                                           i_aiu_idx               ,   // default:0

    // header info
    input          [LANE-1:0][63: 0]                i_info_0                ,   // IQ HD 
    input          [LANE-1:0][63: 0]                i_info_1                ,   // FFT AGC

    // cpri rxdata
    input          [LANE-1:0][10: 0]                i_iq_addr               ,   // 4 ants iq addr
    input          [LANE-1:0][4*32-1: 0]            i_iq_data               ,   // 4 ants iq data
    input          [LANE-1: 0]                      i_iq_vld                ,   // 4 ants iq vld
    input          [LANE-1: 0]                      i_iq_last               ,   // 4 ants iq last(132prb ends)

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


wire           [LANE*4*32-1: 0]                 ant_data_even           ;
wire           [LANE*4*32-1: 0]                 ant_data_odd            ;


wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_i            ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_q            ;
wire                                            beams_tvalid            ;
wire                                            beams_sop               ;
wire                                            beams_eop               ;

wire           [LANE-1: 0]                      w_cpri_clk              ;
wire           [LANE-1: 0]                      w_cpri_rst              ;
wire           [LANE-1:0][63: 0]                w_cpri_rx_data          ;
wire           [LANE-1: 0]                      w_cpri_rx_vld           ;

wire     signed[BEAM-1:0][OW-1: 0]              beams_pick_i            ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_pick_q            ;
wire                                            beams_pick_vld          ;
wire                                            beams_pick_sop          ;
wire                                            beams_pick_eop          ;
wire                                            beams_pick_load         ;
wire           [BEAM-1:0][31: 0]                beams_pick_pwr          ;


//------------------------------------------------------------------------------------------
// Buffer to align even & odd ants data
//------------------------------------------------------------------------------------------
generate for(gi=0;gi<LANE;gi=gi+1) begin: ant_data_buffer
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
    assign ant_data_even[gi*4*32 +: 4*32] = ant_even[gi];       
    assign ant_data_odd [gi*4*32 +: 4*32] = ant_odd [gi];

end
endgenerate

//------------------------------------------------------------------------------------------
// rbG number and re number
//------------------------------------------------------------------------------------------
reg                                             sym_is_1st            =1;
reg            [   7: 0]                        ant_buffer_sym        =0;

wire           [BEAM-1:0][7: 0]                 beam_sort_idx           ;

wire                                            rbg_slip                ;
wire                                            rbg_load                ;

wire                                            aiu_idx                 ;
reg            [   7: 0]                        re_num                =0;
reg            [   7: 0]                        rbg_num               =0;
reg            [   7: 0]                        re_num_per_rbg        =0;
wire           [   7: 0]                        rbg_num_max             ;

assign aiu_idx = i_aiu_idx;

always @(posedge i_clk) begin
    if(i_reset)
        ant_buffer_sym <= 'd0;
    else if(ant_eop[0])
        ant_buffer_sym <= ant_buffer_sym + 'd1;
end

always @(posedge i_clk) begin
    if(i_reset)
        sym_is_1st <= 'd1;
    else if(ant_buffer_sym < 8'd4)
        sym_is_1st <= 'd1;
    else
        sym_is_1st <= 'd0;
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
// CODEWORD FOR 16 BEAMS 
//------------------------------------------------------------------------------------------
wire           [BEAM-1:0][ANT*IW-1: 0]          code_word_even          ;
wire           [BEAM-1:0][ANT*IW-1: 0]          code_word_odd           ;

code_word_rev                                           code_word_rev
(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),

    .i_enable                                           (1'b1                   ),
    .i_rbg_load                                         (rbg_load               ),
    
    .i_beam_idx                                         (beam_sort_idx          ),
    .i_symb_idx                                         (ant_buffer_sym         ),
    .i_symb_1st                                         (sym_is_1st             ),
    
    .o_cw_even                                          (code_word_even         ),
    .o_cw_odd                                           (code_word_odd          ),
    .o_tvalid                                           (                       ) 
);


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
    .i_rvalid                                           (ant_tvalid[0]          ),
    .i_sop                                              (ant_sop   [0]          ),
    .i_eop                                              (ant_eop   [0]          ),
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
// Beam power calculation
//------------------------------------------------------------------------------------------
wire           [BEAM-1:0][OW-1: 0]              rbg_sum_abs             ;
wire           [   7: 0]                        rbg_abs_addr            ;
wire                                            rbg_sum_vld             ;
wire                                            rbg_sum_load            ;
wire                                            rbg_sum_wen             ;

beam_power_calc # (
    .BEAM                                               (BEAM                   ),
    .IW                                                 (40                     ),
    .OW                                                 (40                     ) 
)beam_power_calc(
    .i_clk                                              (i_clk                  ),// data clock
    .i_reset                                            (i_reset                ),// reset
    .i_rbg_size                                         (i_rbg_size             ),// default:2'b10 16rb
    .i_data_re                                          (beams_ants_i           ),// 4 ants iq addr
    .i_data_im                                          (beams_ants_q           ),// 4 ants iq data
    .i_data_vld                                         (beams_tvalid           ),
    .i_data_eop                                         (beams_eop              ),
    .i_data_sop                                         (beams_sop              ),
    .i_re_num                                           (re_num                 ),
    .i_rbg_num                                          (rbg_num                ),
    .i_rbg_load                                         (rbg_load               ),
    .o_data_sum                                         (rbg_sum_abs            ),
    .o_data_addr                                        (rbg_abs_addr           ),
    .o_data_vld                                         (rbg_sum_vld            ),
    .o_data_load                                        (rbg_sum_load           ),
    .o_data_wen                                         (rbg_sum_wen            ) 
);

//------------------------------------------------------------------------------------------
// buffer valid and load signal
//------------------------------------------------------------------------------------------
wire           [63:0][OW-1: 0]                  rbg_buffer_out          ;
wire                                            rbg_buffer_vld          ;
wire           [15:0][31: 0]                    beam_sort_pwr           ;
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
    
    .o_score                                            (                       ),
    .o_data                                             (beam_sort_pwr          ),
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
    
    .i_sort_pwr                                         (beam_sort_pwr          ),
    .i_sort_idx                                         (beam_sort_idx          ),
    .i_sort_sop                                         (beam_sort_sop          ),
    .i_rbg_load                                         (beam_sort_load         ),
    .i_sym_1st                                          (sym_is_1st             ),

    .o_sort_pwr                                         (beams_pick_pwr         ),
    .o_data_re                                          (beams_pick_i           ),
    .o_data_im                                          (beams_pick_q           ),
    .o_sop                                              (beams_pick_sop         ),
    .o_eop                                              (beams_pick_eop         ),
    .o_rbg_load                                         (beams_pick_load        ),
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
wire                                            dr_rbg_load             ;
wire           [BEAM-1:0][31: 0]                dr_beam_pwr             ;


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
    
    .i_rbg_load                                         (beams_pick_load        ),
    .i_beam_pwr                                         (beams_pick_pwr         ),

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
    .o_rbg_load                                         (dr_rbg_load            ),
    .o_beam_pwr                                         (dr_beam_pwr            ),
    .o_slot_idx                                         (                       ),
    .o_symb_idx                                         (                       ),
    .o_prb_idx                                          (                       ),
    .o_type                                             (                       ),
    .o_info                                             (                       ) 
);

//------------------------------------------------------------------------------------------
// store 16 beams data, output 4 beams data 
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