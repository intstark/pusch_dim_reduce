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
    input                                           i_clk                   ,// data clock
    input                                           i_reset                 ,// reset

    input          [   1: 0]                        i_aiu_idx               ,// AIU index 0-3
    input          [   1: 0]                        i_rbg_size              ,// default:2'b10 16rb
    input          [   1: 0]                        i_dr_mode               ,// re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 

    // header info
    input          [   3: 0]                        i_pkg_type              ,
    input          [   6: 0]                        i_slot_idx              ,
    input          [   3: 0]                        i_symb_idx              ,
    input                                           i_cell_idx              ,
    input          [LANE-1:0][63: 0]                i_info_0                ,// IQ HD 
    input          [LANE-1:0][ 7: 0]                i_info_1                ,// FFT AGC

    // cpri rxdata
    input          [LANE-1:0][10: 0]                i_iq_addr               ,// 4 ants iq addr
    input          [LANE-1:0][4*32-1: 0]            i_iq_data               ,// 4 ants iq data
    input          [LANE-1: 0]                      i_iq_vld                ,// 4 ants iq vld
    input          [LANE-1: 0]                      i_iq_last               ,// 4 ants iq last(132prb ends)

    // output dr data
    output         [15:0][31: 0]                    o_beam_pwr              ,
    output         [15:0][31: 0]                    o_dr_data               ,
    output                                          o_dr_vld                , 
    output                                          o_dr_sop                ,
    output                                          o_dr_eop                ,
    output                                          o_rbg_load              ,

    output         [   3: 0]                        o_rbg_idx               ,// rbg index 
    output         [   3: 0]                        o_pkg_type              ,// pusch:4'b1000 
    output                                          o_cell_idx              ,// cell index
    output         [   6: 0]                        o_slot_idx              ,// slot index 
    output         [   3: 0]                        o_symb_idx              ,// symbol index 0-13
    output         [15:0][7: 0]                     o_fft_agc                // fft agc value 

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
wire                                            aiu_idx                 ;
wire           [LANE-1:0][63: 0]                ant_info_0              ;
wire           [LANE-1:0][15: 0]                ant_info_1              ;
wire           [LANE-1:0][ 6: 0]                ant_slot_idx            ;
wire           [LANE-1:0][ 3: 0]                ant_symb_idx            ;
wire           [LANE-1:0][4*32-1: 0]            ant_even                ;
wire           [LANE-1:0][4*32-1: 0]            ant_odd                 ;
wire           [LANE-1:0][11-1: 0]              ant_addr                ;
wire           [LANE-1: 0]                      ant_tvalid              ;
wire           [LANE-1: 0]                      ant_symb_clr            ;
wire           [LANE-1: 0]                      ant_sop                 ;
wire           [LANE-1: 0]                      ant_eop                 ;


wire           [LANE*4*32-1: 0]                 ant_data_even           ;
wire           [LANE*4*32-1: 0]                 ant_data_odd            ;

wire           [63: 0]                          beams_info_0            ;
wire           [15: 0]                          beams_info_1            ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_i            ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_q            ;
wire                                            beams_tvalid            ;
wire                                            beams_sop               ;
wire                                            beams_eop               ;
wire                                            beams_symb_clr          ;
wire                                            beams_symb_1st          ;
wire                                            beams_rbg_load          ;
wire           [   7: 0]                        beams_re_num            ;
wire           [   7: 0]                        beams_rbg_num           ;

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
wire           [63: 0]                          beams_pick_info_0       ;
wire           [15:0][ 7: 0]                    beams_pick_info_1       ;


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
        .FIFO_WIDTH                                         (72                     ),
        .LOOP_WIDTH                                         (12                     ),
        .INFO_WIDTH                                         (72                     ),
        .RAM_TYPE                                           (1                      ) 
    )ant_data_buffer(
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),

        .i_dr_mode                                          (i_dr_mode              ),

        .i_info_0                                           (i_info_0      [gi]     ),  // IQ HD
        .i_info_1                                           (i_info_1      [gi]     ),  // FFT AGC

        .i_iq_addr                                          (i_iq_addr     [gi]     ),
        .i_iq_data                                          (i_iq_data     [gi]     ),
        .i_iq_vld                                           (i_iq_vld      [gi]     ),
        .i_iq_last                                          (i_iq_last     [gi]     ),

        .o_info_0                                           (ant_info_0    [gi]     ),  // IQ HD
        .o_info_1                                           (ant_info_1    [gi]     ),  // FFT AGC:{odd, even}
        .o_slot_idx                                         (ant_slot_idx  [gi]     ),
        .o_symb_idx                                         (ant_symb_idx  [gi]     ),

        .o_ant_even                                         (ant_even      [gi]     ),
        .o_ant_odd                                          (ant_odd       [gi]     ),
        .o_ant_addr                                         (ant_addr      [gi]     ),
        .o_ant_sop                                          (ant_sop       [gi]     ), 
        .o_ant_eop                                          (ant_eop       [gi]     ), 
        .o_tvalid                                           (ant_tvalid    [gi]     ),
        .o_symb_clr                                         (ant_symb_clr  [gi]     ) 
    );

    // arrange data for even and odd ants
    assign ant_data_even[gi*4*32 +: 4*32] = ant_even[gi];       
    assign ant_data_odd [gi*4*32 +: 4*32] = ant_odd [gi];

end
endgenerate

//------------------------------------------------------------------------------------------
// rbG number and re number
//------------------------------------------------------------------------------------------
reg                                             symb_is_1st           =1;
reg            [   7: 0]                        ant_buffer_sym        =0;

wire           [BEAM-1:0][7: 0]                 beam_sort_idx           ;
wire                                            rbg_slip                ;
wire                                            rbg_load                ;
reg            [   7: 0]                        re_num                =0;
reg            [   7: 0]                        rbg_num               =0;
reg            [   7: 0]                        re_num_per_rbg        =0;
wire           [   7: 0]                        rbg_num_max             ;
wire                                            symb_clr                ;

assign symb_clr = ant_symb_clr[0];

always @(posedge i_clk) begin
    if(i_reset)
        ant_buffer_sym <= 'd0;
    else if(symb_clr)
        ant_buffer_sym <= 'd0;
    else if(ant_buffer_sym == 4)
        ant_buffer_sym <= 'd4;
    else if(ant_eop[0])
        ant_buffer_sym <= ant_buffer_sym + 'd1;
end

always @(posedge i_clk) begin
    if(i_reset)
        symb_is_1st <= 'd1;
    else if(symb_clr)
        symb_is_1st <= 'd1;
    else if(ant_buffer_sym < 'd4)
        symb_is_1st <= 'd1;
    else
        symb_is_1st <= 'd0;
end


assign rbg_num_max = (i_rbg_size == 2'b00) ? 8'd32  :
                     (i_rbg_size == 2'b01) ? 8'd16  :
                     (i_rbg_size == 2'b10) ? 8'd8   : 8'd8;

assign aiu_idx = i_aiu_idx[0];

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
    if(i_reset)
        re_num <= 'd0;
    else if(re_num == re_num_per_rbg-1)
        re_num <= 'd0;
    else if(ant_tvalid[0])
        re_num <= re_num + 1'b1;
    else
        re_num <= 'd0;
end


assign rbg_slip = (re_num == re_num_per_rbg-1) ? 1'b1 : 1'b0;
assign rbg_load = (ant_tvalid[0] && re_num == 0) ? 1'b1 : 1'b0;

// rbG number
reg [2:0] r1_rbg_load = 0;
always @ (posedge i_clk)begin
    r1_rbg_load <= {r1_rbg_load[1:0],rbg_load};
end

// rbG number
always @ (posedge i_clk)begin
    if(i_reset)
        rbg_num <= 'd0;
    else if(!ant_tvalid[0])
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
    .i_symb_clr                                         (symb_clr               ),
    .i_symb_1st                                         (symb_is_1st            ),
    
    .o_cw_even                                          (code_word_even         ),
    .o_cw_odd                                           (code_word_odd          ),
    .o_tvalid                                           (                       ) 
);


//------------------------------------------------------------------------------------------
// BEAMS MAC BLOCK FOR 16 BEAMS: 12 Clocks
//------------------------------------------------------------------------------------------
mac_beams #(
    .BEAM                                               (BEAM                   ),
    .ANT                                                (ANT                    ),
    .IW                                                 (IW                     ),
    .OW                                                 (OW                     ) 
)mac_beams(
    .i_clk                                              (i_clk                  ),

    .i_rvalid                                           (ant_tvalid[0]          ),
    .i_sop                                              (ant_sop   [0]          ),
    .i_eop                                              (ant_eop   [0]          ),
    .i_symb_clr                                         (symb_clr               ),
    .i_symb_1st                                         (symb_is_1st            ),

    .i_ants_data_even                                   (ant_data_even          ),
    .i_ants_data_odd                                    (ant_data_odd           ),
    .i_code_word_even                                   (code_word_even         ),
    .i_code_word_odd                                    (code_word_odd          ),

    .i_info_0                                           (ant_info_0[0]          ),// IQ HD
    .i_info_1                                           (ant_info_1[0]          ),// FFT AGC{odd, even}
    
    .i_re_num                                           (re_num                 ),
    .i_rbg_num                                          (rbg_num                ),
    .i_rbg_load                                         (rbg_load               ),

    .o_info_0                                           (beams_info_0           ),// IQ HD
    .o_info_1                                           (beams_info_1           ),// FFT AGC{odd, even}
    .o_data_even_i                                      (                       ),
    .o_data_even_q                                      (                       ),
    .o_data_odd_i                                       (                       ),
    .o_data_odd_q                                       (                       ),
    .o_data_i                                           (beams_ants_i           ),
    .o_data_q                                           (beams_ants_q           ),
    .o_sop                                              (beams_sop              ),
    .o_eop                                              (beams_eop              ),
    .o_tvalid                                           (beams_tvalid           ),
    
    .o_re_num                                           (beams_re_num           ),
    .o_rbg_num                                          (beams_rbg_num          ),
    .o_rbg_load                                         (beams_rbg_load         ),

    .o_symb_clr                                         (beams_symb_clr         ),
    .o_symb_1st                                         (beams_symb_1st         ) 
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
    .i_symb_clr                                         (beams_symb_clr         ),
    .i_symb_1st                                         (beams_symb_1st         ),

    .i_data_re                                          (beams_ants_i           ),// 4 ants iq addr
    .i_data_im                                          (beams_ants_q           ),// 4 ants iq data
    .i_data_vld                                         (beams_tvalid           ),
    .i_data_eop                                         (beams_eop              ),
    .i_data_sop                                         (beams_sop              ),
    
    .i_re_num                                           (beams_re_num           ),
    .i_rbg_num                                          (beams_rbg_num          ),
    .i_rbg_load                                         (beams_rbg_load         ),
    
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
    .WADDR_WIDTH                                        (6                      ),
    .RDATA_WIDTH                                        (OW                     ),
    .RADDR_WIDTH                                        (6                      ) 
)beam_buffer (
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (rbg_sum_vld            ),
    .i_wr_wen                                           (rbg_sum_wen            ),
    .i_wr_data                                          (rbg_sum_abs            ),
    .i_wr_addr                                          (rbg_abs_addr[5:0]      ),

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
    
    .i_symb_clr                                         (symb_clr               ),
    .i_symb_1st                                         (beams_symb_1st         ),

    .i_rbg_max                                          (rbg_num_max            ),
    .i_rbg_load                                         (r1_rbg_load[0]         ),
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
// beams_pick_top: select top 16 beams based on beam sort idx
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
    .i_sop                                              (beams_sop              ),
    .i_eop                                              (beams_eop              ),
    .i_data_re                                          (beams_ants_i           ),
    .i_data_im                                          (beams_ants_q           ),
    
    .i_sort_pwr                                         (beam_sort_pwr          ),
    .i_sort_idx                                         (beam_sort_idx          ),
    .i_sort_sop                                         (beam_sort_sop          ),
    .i_rbg_load                                         (beam_sort_load         ),
    .i_sym_1st                                          (beams_symb_1st         ),

    .i_info_0                                           (beams_info_0           ),  // IQ HD
    .i_info_1                                           (beams_info_1           ),  // FFT AGC{odd, even}

    .o_info_0                                           (beams_pick_info_0      ),  // IQ HD
    .o_info_1                                           (beams_pick_info_1      ),  // FFT AGC{ant15->ant0}
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
wire                                            dr_rbg_load             ;
wire           [BEAM-1:0][31: 0]                dr_beam_pwr             ;
wire           [   3: 0]                        dr_rbg_idx              ;
wire           [   3: 0]                        dr_pkg_type             ;
wire                                            dr_cell_idx             ;
wire           [   6: 0]                        dr_slot_idx             ;
wire           [   3: 0]                        dr_symb_idx             ;
wire           [15:0][7: 0]                     dr_fft_agc              ;

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

    .i_info_0                                           (beams_pick_info_0      ),
    .i_info_1                                           (beams_pick_info_1      ),

    .o_sel                                              (                       ),
    .o_sop                                              (dr_sop                 ),
    .o_eop                                              (dr_eop                 ),
    .o_vld                                              (dr_vld                 ),
    .o_dout_re                                          (dr_data_re             ),
    .o_dout_im                                          (dr_data_im             ),
    .o_shift                                            (                       ),
    .o_rbg_load                                         (dr_rbg_load            ),
    .o_beam_pwr                                         (dr_beam_pwr            ),

    .o_rbg_idx                                          (dr_rbg_idx             ),
    .o_pkg_type                                         (dr_pkg_type            ),
    .o_cell_idx                                         (dr_cell_idx            ),
    .o_slot_idx                                         (dr_slot_idx            ),
    .o_symb_idx                                         (dr_symb_idx            ),
    .o_fft_agc                                          (dr_fft_agc             ) 
);

//------------------------------------------------------------------------------------------
// store 16 beams data, output 4 beams data 
// -----------------------------------------------------------------------------------------
for(genvar i=0;i<16;i++)begin: gen_dr_data_iq
    assign o_dr_data[i] = {dr_data_re[i],dr_data_im[i]};
end

assign o_beam_pwr = dr_beam_pwr;
assign o_dr_sop   = dr_sop;
assign o_dr_eop   = dr_eop;
assign o_dr_vld   = dr_vld;
assign o_rbg_load = dr_rbg_load;

assign o_rbg_idx  = dr_rbg_idx;
assign o_pkg_type = dr_pkg_type;
assign o_cell_idx = dr_cell_idx;
assign o_slot_idx = dr_slot_idx;
assign o_symb_idx = dr_symb_idx;
assign o_fft_agc  = dr_fft_agc;


endmodule