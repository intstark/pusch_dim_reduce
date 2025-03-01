//----------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-03-06
//File name       :  cri_tx_lane.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

module cpri_tx_lane
(
    input  wire                                     i_sys_clk               ,// system clock
    input  wire                                     i_sys_rst               ,// system reset

    input  wire                                     i_tx_clk                ,
    
    input  wire    [   3: 0]                        i_if_re_sel             ,
    input  wire    [   3: 0]                        i_if_re_vld             ,
    input  wire    [   3: 0]                        i_if_re_sop             ,
    input  wire    [   3: 0]                        i_if_re_eop             ,
    input  wire    [  31: 0]                        i_if_re_ant0            ,
    input  wire    [  31: 0]                        i_if_re_ant1            ,
    input  wire    [  31: 0]                        i_if_re_ant2            ,
    input  wire    [  31: 0]                        i_if_re_ant3            ,
    input  wire    [   6: 0]                        i_if_re_slot_idx        ,
    input  wire    [   3: 0]                        i_if_re_sym_idx         ,
    input  wire    [   8: 0]                        i_if_re_prb_idx         ,
    input  wire    [   7: 0]                        i_if_re_info0           ,
    input  wire    [   7: 0]                        i_if_re_info1           ,
    input  wire    [   7: 0]                        i_if_re_info2           ,
    input  wire    [   7: 0]                        i_if_re_info3           ,

    input  wire    [   3: 0]                        i_if_ch_type0           ,
    input  wire    [   3: 0]                        i_if_ch_type1           ,
    input  wire    [   3: 0]                        i_if_ch_type2           ,
    input  wire    [   3: 0]                        i_if_ch_type3           ,

    input  wire                                     i_if_cell_idx0          ,
    input  wire                                     i_if_cell_idx1          ,
    input  wire                                     i_if_cell_idx2          ,
    input  wire                                     i_if_cell_idx3          ,

    input  wire    [   1: 0]                        i_aiu_idx               ,// const
    input  wire    [   2: 0]                        i_lane_idx              ,// const
    input  wire    [   3: 0]                        i_rbg_idx               ,
    input  wire    [  31: 0]                        i_fft_agc               ,
                
    input  wire    [  31: 0]                        i_ant_power0            ,
    input  wire    [  31: 0]                        i_ant_power1            ,
    input  wire    [  31: 0]                        i_ant_power2            ,
    input  wire    [  31: 0]                        i_ant_power3            ,

    input  wire                                     i_iq_tx_enable          ,
    output wire    [  63: 0]                        o_iq_tx_data            , 
    output wire                                     o_iq_tx_valid           

);
 
wire                                            m_sel                   ;
wire                                            m_sop                   ;
wire                                            m_eop                   ;
wire                                            m_vld                   ;
wire           [  13: 0]                        m_data_ant0             ;
wire           [  13: 0]                        m_data_ant1             ;
wire           [  13: 0]                        m_data_ant2             ;
wire           [  13: 0]                        m_data_ant3             ;
wire           [   3: 0]                        m_shift0                ;
wire           [   3: 0]                        m_shift1                ;
wire           [   3: 0]                        m_shift2                ;
wire           [   3: 0]                        m_shift3                ;
wire           [   6: 0]                        m_slot_idx              ;
wire           [   3: 0]                        m_symb_idx              ;
wire           [   8: 0]                        m_prb_idx               ;
wire           [   3: 0]                        m_rbg_idx               ;
wire           [  31: 0]                        m_fft_agc               ;
wire           [   3: 0]                        m_channel_type0         ;
wire           [   3: 0]                        m_channel_type1         ;
wire           [   3: 0]                        m_channel_type2         ;
wire           [   3: 0]                        m_channel_type3         ;
wire                                            m_pkg0_cell_idx         ;
wire                                            m_pkg1_cell_idx         ;
wire                                            m_pkg2_cell_idx         ;
wire                                            m_pkg3_cell_idx         ;
wire           [   7: 0]                        m_info0                 ;
wire           [   7: 0]                        m_info1                 ;
wire           [   7: 0]                        m_info2                 ;
wire           [   7: 0]                        m_info3                 ;
wire                                            m_cpri_wen              ;
wire           [   6: 0]                        m_cpri_waddr            ;
wire           [  63: 0]                        m_cpri_wdata            ;
wire                                            m_cpri_wlast            ;

wire           [  31: 0]                        m_pkg0_power            ;
wire           [  31: 0]                        m_pkg1_power            ;
wire           [  31: 0]                        m_pkg2_power            ;
wire           [  31: 0]                        m_pkg3_power            ;
wire           [  31: 0]                        m_pkg4_power            ;
wire           [  31: 0]                        m_pkg5_power            ;
wire           [  31: 0]                        m_pkg6_power            ;
wire           [  31: 0]                        m_pkg7_power            ;

    
ul_compress_data                                        ul_compress_data 
(   
    .clk                                                (i_sys_clk              ),
    .rst                                                (i_sys_rst              ),
    .i_sel                                              (i_if_re_sel            ),
    .i_sop                                              (i_if_re_sop            ),
    .i_eop                                              (i_if_re_eop            ),
    .i_vld                                              (i_if_re_vld            ),
    .i_din_ant0                                         (i_if_re_ant0           ),
    .i_din_ant1                                         (i_if_re_ant1           ),
    .i_din_ant2                                         (i_if_re_ant2           ),
    .i_din_ant3                                         (i_if_re_ant3           ),
    .i_slot_idx                                         (i_if_re_slot_idx[6:0]  ),
    .i_symb_idx                                         (i_if_re_sym_idx        ),
    .i_prb_idx                                          (i_if_re_prb_idx        ),
    .i_rbg_idx                                          (i_rbg_idx              ),
    .i_fft_agc                                          (i_fft_agc              ),
    .i_channel_type0                                    (i_if_ch_type0          ),
    .i_channel_type1                                    (i_if_ch_type1          ),
    .i_channel_type2                                    (i_if_ch_type2          ),
    .i_channel_type3                                    (i_if_ch_type3          ),
    .i_cell_idx0                                        (i_if_cell_idx0         ),
    .i_cell_idx1                                        (i_if_cell_idx1         ),
    .i_cell_idx2                                        (i_if_cell_idx2         ),
    .i_cell_idx3                                        (i_if_cell_idx3         ),
    .i_info0                                            (i_if_re_info0          ),
    .i_info1                                            (i_if_re_info1          ),
    .i_info2                                            (i_if_re_info2          ),
    .i_info3                                            (i_if_re_info3          ),
    .i_ant_power0                                       (i_ant_power0           ),
    .i_ant_power1                                       (i_ant_power1           ),
    .i_ant_power2                                       (i_ant_power2           ),
    .i_ant_power3                                       (i_ant_power3           ),
    .o_sel                                              (m_sel                  ),
    .o_sop                                              (m_sop                  ),
    .o_eop                                              (m_eop                  ),
    .o_vld                                              (m_vld                  ),
    .o_data_ant0                                        (m_data_ant0            ),
    .o_data_ant1                                        (m_data_ant1            ),
    .o_data_ant2                                        (m_data_ant2            ),
    .o_data_ant3                                        (m_data_ant3            ),
    .o_shift0                                           (m_shift0               ),
    .o_shift1                                           (m_shift1               ),
    .o_shift2                                           (m_shift2               ),
    .o_shift3                                           (m_shift3               ),
    .o_slot_idx                                         (m_slot_idx             ),
    .o_symb_idx                                         (m_symb_idx             ),
    .o_prb_idx                                          (m_prb_idx              ),
    .o_rbg_idx                                          (m_rbg_idx              ),
    .o_fft_agc                                          (m_fft_agc              ),
    .o_channel_type0                                    (m_channel_type0        ),
    .o_channel_type1                                    (m_channel_type1        ),
    .o_channel_type2                                    (m_channel_type2        ),
    .o_channel_type3                                    (m_channel_type3        ),
    .o_cell_idx0                                        (m_pkg0_cell_idx        ),
    .o_cell_idx1                                        (m_pkg1_cell_idx        ),
    .o_cell_idx2                                        (m_pkg2_cell_idx        ),
    .o_cell_idx3                                        (m_pkg3_cell_idx        ),
    .o_info0                                            (m_info0                ),
    .o_info1                                            (m_info1                ),
    .o_info2                                            (m_info2                ),
    .o_info3                                            (m_info3                ),

    .o_pkg0_power                                       (m_pkg0_power           ),
    .o_pkg1_power                                       (m_pkg1_power           ),
    .o_pkg2_power                                       (m_pkg2_power           ),
    .o_pkg3_power                                       (m_pkg3_power           )
);



//pkg=ant
ul_package_data                                         ul_package_data
(                                            
    .clk                                                (i_sys_clk              ),
    .rst                                                (i_sys_rst              ),
    .i_sel                                              (m_sel                  ),
    .i_vld                                              (m_vld                  ),
    .i_sop                                              (m_sop                  ),
    .i_eop                                              (m_eop                  ),
    .i_pkg0_ch_type                                     (m_channel_type0        ),
    .i_pkg0_cell_idx                                    (m_pkg0_cell_idx        ),
    .i_pkg0_ant_idx                                     (2'd0                   ),
    .i_pkg0_slot_idx                                    (m_slot_idx             ),
    .i_pkg0_sym_idx                                     (m_symb_idx             ),
    .i_pkg0_prb_idx                                     (m_prb_idx              ),
    .i_pkg0_info                                        (m_info0                ),
    .i_pkg0_data                                        (m_data_ant0            ),
    .i_pkg0_shift                                       (m_shift0               ),
    .i_pkg1_ch_type                                     (m_channel_type1        ),
    .i_pkg1_cell_idx                                    (m_pkg1_cell_idx        ),
    .i_pkg1_ant_idx                                     (2'd1                   ),
    .i_pkg1_slot_idx                                    (m_slot_idx             ),
    .i_pkg1_sym_idx                                     (m_symb_idx             ),
    .i_pkg1_prb_idx                                     (m_prb_idx              ),
    .i_pkg1_info                                        (m_info1                ),
    .i_pkg1_data                                        (m_data_ant1            ),
    .i_pkg1_shift                                       (m_shift1               ),
    .i_pkg2_ch_type                                     (m_channel_type2        ),
    .i_pkg2_cell_idx                                    (m_pkg2_cell_idx        ),
    .i_pkg2_ant_idx                                     (2'd2                   ),
    .i_pkg2_slot_idx                                    (m_slot_idx             ),
    .i_pkg2_sym_idx                                     (m_symb_idx             ),
    .i_pkg2_prb_idx                                     (m_prb_idx              ),
    .i_pkg2_info                                        (m_info2                ),
    .i_pkg2_data                                        (m_data_ant2            ),
    .i_pkg2_shift                                       (m_shift2               ),
    .i_pkg3_ch_type                                     (m_channel_type3        ),
    .i_pkg3_cell_idx                                    (m_pkg3_cell_idx        ),
    .i_pkg3_ant_idx                                     (2'd3                   ),
    .i_pkg3_slot_idx                                    (m_slot_idx             ),
    .i_pkg3_sym_idx                                     (m_symb_idx             ),
    .i_pkg3_prb_idx                                     (m_prb_idx              ),
    .i_pkg3_info                                        (m_info3                ),
    .i_pkg3_data                                        (m_data_ant3            ),
    .i_pkg3_shift                                       (m_shift3               ),

    .i_aiu_idx                                          (i_aiu_idx              ),      
    .i_lane_idx                                         (i_lane_idx             ),  
    .i_rbg_idx                                          (m_rbg_idx              ),
    .i_fft_agc                                          (m_fft_agc              ),

    .i_pkg0_power                                       (m_pkg0_power           ),
    .i_pkg1_power                                       (m_pkg1_power           ),
    .i_pkg2_power                                       (m_pkg2_power           ),
    .i_pkg3_power                                       (m_pkg3_power           ),

    .o_cpri_wen                                         (m_cpri_wen             ),
    .o_cpri_waddr                                       (m_cpri_waddr           ),
    .o_cpri_wdata                                       (m_cpri_wdata           ),
    .o_cpri_wlast                                       (m_cpri_wlast           ) 
);


//--------------------------------------------------------------------------------------
// Reset synchronizer 
//--------------------------------------------------------------------------------------
wire                                            w_tx_rst                ;
// tx reset synchronizer
alt_reset_synchronizer #(
    .depth                                              (2                      ),
    .rst_value                                          (1                      ) 
)tx_rst_sync(
    .clk                                                (i_tx_clk               ),
    .reset_n                                            (!i_sys_rst             ),
    .rst_out                                            (w_tx_rst               ) 
);

	              
cpri_tx_gen                                             u_cpri_tx_gen
(
    .wr_clk                                             (i_sys_clk              ),
    .wr_rst                                             (i_sys_rst              ),
    .rd_clk                                             (i_tx_clk               ),
    .rd_rst                                             (w_tx_rst               ),
    .i_cpri_wen                                         (m_cpri_wen             ),
    .i_cpri_waddr                                       (m_cpri_waddr           ),
    .i_cpri_wdata                                       (m_cpri_wdata           ),
    .i_cpri_wlast                                       (m_cpri_wlast           ),
    .i_iq_tx_enable                                     (i_iq_tx_enable         ),
    .o_iq_tx_valid                                      (o_iq_tx_valid          ),
    .o_iq_tx_data                                       (o_iq_tx_data           ) 
       
);



                                 
          
                                  
endmodule


