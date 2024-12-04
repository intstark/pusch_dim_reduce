//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: cpri_txdata_top
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

module cpri_txdata_top 
(
    input  wire                                     i_clk                   ,
    input  wire                                     i_reset                 ,


    input  wire                                     i_rx_sel                ,
    input  wire                                     i_rx_vld                ,
    input  wire                                     i_rx_sop                ,
    input  wire                                     i_rx_eop                ,
    input  wire                                     i_rbg_load              ,

    input  wire    [15:0][31: 0]                    i_ant_data              ,
    input  wire    [15:0][31: 0]                    i_ant_pwr               ,


    input          [   3: 0]                        i_rbg_idx               ,
    input          [   3: 0]                        i_pkg_type              ,
    input                                           i_cell_idx              ,
    input          [   6: 0]                        i_slot_idx              ,
    input          [   3: 0]                        i_symb_idx              ,
    input          [  15:0][7:0]                    i_fft_agc               ,
                
    input  wire                                     i_iq_tx_enable          ,

    output wire    [  63: 0]                        o_iq_tx0_data           ,   // lane 0
    output wire                                     o_iq_tx0_valid          ,
    output wire    [  63: 0]                        o_iq_tx1_data           ,   // lane 1
    output wire                                     o_iq_tx1_valid      
);

//------------------------------------------------------------------------------------------
// WIRE & REGISTER DECLARATION
// -----------------------------------------------------------------------------------------
wire           [3:0][31: 0]                     tx0_data                ;
wire                                            tx0_vld                 ;
wire                                            tx0_sop                 ;
wire                                            tx0_eop                 ;

wire           [3:0][31: 0]                     tx1_data                ;
wire                                            tx1_vld                 ;
wire                                            tx1_sop                 ;
wire                                            tx1_eop                 ;

wire           [3:0][31: 0]                     tx0_ant_pwr             ;
wire           [   3: 0]                        tx0_rbg_idx             ;
wire           [   3: 0]                        tx0_pkg_type            ;
wire                                            tx0_cell_idx            ;
wire           [   6: 0]                        tx0_slot_idx            ;
wire           [   3: 0]                        tx0_symb_idx            ;
wire           [  31: 0]                        tx0_fft_agc             ;
wire           [  8: 0]                         tx0_prb_idx             ;
wire           [3:0][7: 0]                      tx0_pkg_info            ;

wire           [3:0][31: 0]                     tx1_ant_pwr             ;
wire           [   3: 0]                        tx1_rbg_idx             ;
wire           [   3: 0]                        tx1_pkg_type            ;
wire                                            tx1_cell_idx            ;
wire           [   6: 0]                        tx1_slot_idx            ;
wire           [   3: 0]                        tx1_symb_idx            ;
wire           [  31: 0]                        tx1_fft_agc             ;
wire           [  8: 0]                         tx1_prb_idx             ;
wire           [3:0][7: 0]                      tx1_pkg_info            ;



//------------------------------------------------------------------------------------------
// LANE 0 CPRI TX
// -----------------------------------------------------------------------------------------
txdata_queue                                            txdata_queue_0
(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),

    .i_ant_data                                         (i_ant_data[7:0]        ),
    .i_ant_pwr                                          (i_ant_pwr [7:0]        ),
    .i_rx_vld                                           (i_rx_vld               ),
    .i_rx_sop                                           (i_rx_sop               ),
    .i_rx_eop                                           (i_rx_eop               ),
    .i_rbg_load                                         (i_rbg_load             ),
    .i_rready                                           (1'b1                   ),
    
    .i_ant0_idx                                         (4'd0                   ), // ant0-7
    .i_rbg_idx                                          (i_rbg_idx              ),
    .i_pkg_type                                         (i_pkg_type             ),
    .i_cell_idx                                         (i_cell_idx             ),
    .i_slot_idx                                         (i_slot_idx             ),
    .i_symb_idx                                         (i_symb_idx             ),
    .i_fft_agc                                          (i_fft_agc[7:0]         ),

    .o_tx_data                                          (tx0_data               ),
    .o_tx_vld                                           (tx0_vld                ),
    .o_tx_sop                                           (tx0_sop                ),
    .o_tx_eop                                           (tx0_eop                ),

    .o_ant_pwr                                          (tx0_ant_pwr            ),
    .o_rbg_idx                                          (tx0_rbg_idx            ),
    .o_pkg_type                                         (tx0_pkg_type           ),
    .o_cell_idx                                         (tx0_cell_idx           ),
    .o_slot_idx                                         (tx0_slot_idx           ),
    .o_symb_idx                                         (tx0_symb_idx           ),
    .o_fft_agc                                          (tx0_fft_agc            ),
    .o_pkg_info                                         (tx0_pkg_info           ),
    .o_prb_idx                                          (tx0_prb_idx            ) 
);

cpri_tx_lane                                            cpri_tx_lane_0
(
    .sys_clk_491_52                                     (i_clk                  ),
    .sys_rst_491_52                                     (i_reset                ),
    .sys_clk_368_64                                     (i_clk                  ),
    .sys_rst_368_64                                     (i_reset                ),
    .i_if_re_sel                                        (4'd0                   ),
    .i_if_re_vld                                        ({4{tx0_vld}}           ),
    .i_if_re_sop                                        ({4{tx0_sop}}           ),
    .i_if_re_eop                                        ({4{tx0_eop}}           ),
    .i_if_re_ant0                                       (tx0_data[0]            ),
    .i_if_re_ant1                                       (tx0_data[1]            ),
    .i_if_re_ant2                                       (tx0_data[2]            ),
    .i_if_re_ant3                                       (tx0_data[3]            ),
    .i_if_re_slot_idx                                   (tx0_slot_idx           ),
    .i_if_re_sym_idx                                    (tx0_symb_idx           ),
    .i_if_re_prb_idx                                    (tx0_prb_idx            ),
    .i_if_re_info0                                      (tx0_pkg_info[0]        ),
    .i_if_re_info1                                      (tx0_pkg_info[1]        ),
    .i_if_re_info2                                      (tx0_pkg_info[2]        ),
    .i_if_re_info3                                      (tx0_pkg_info[3]        ),

    .i_if_ch_type0                                      (tx0_pkg_type           ),
    .i_if_ch_type1                                      (tx0_pkg_type           ),
    .i_if_ch_type2                                      (tx0_pkg_type           ),
    .i_if_ch_type3                                      (tx0_pkg_type           ),

    .i_if_cell_idx0                                     (tx0_cell_idx           ),
    .i_if_cell_idx1                                     (tx0_cell_idx           ),
    .i_if_cell_idx2                                     (tx0_cell_idx           ),
    .i_if_cell_idx3                                     (tx0_cell_idx           ),
    
    .i_rbg_idx                                          (tx0_rbg_idx            ),
    .i_fft_agc                                          (tx0_fft_agc            ),

    .i_ant_power0                                       (tx0_ant_pwr[0]         ),
    .i_ant_power1                                       (tx0_ant_pwr[1]         ),
    .i_ant_power2                                       (tx0_ant_pwr[2]         ),
    .i_ant_power3                                       (tx0_ant_pwr[3]         ),

    .i_iq_tx_enable                                     (i_iq_tx_enable         ),
    .o_iq_tx_data                                       (o_iq_tx0_data          ),
    .o_iq_tx_valid                                      (o_iq_tx0_valid         ) 
);

                                 
//------------------------------------------------------------------------------------------
// LANE 1 CPRI TX
// -----------------------------------------------------------------------------------------
txdata_queue                                            txdata_queue_1
(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),

    .i_ant_data                                         (i_ant_data[15:8]       ),
    .i_ant_pwr                                          (i_ant_pwr [15:8]       ),   
    .i_rx_vld                                           (i_rx_vld               ),
    .i_rx_sop                                           (i_rx_sop               ),
    .i_rx_eop                                           (i_rx_eop               ),
    .i_rready                                           (1'b1                   ),
    
    .i_ant0_idx                                         (4'd8                   ),// ant8-15
    .i_rbg_idx                                          (i_rbg_idx              ),
    .i_pkg_type                                         (i_pkg_type             ),
    .i_cell_idx                                         (i_cell_idx             ),
    .i_slot_idx                                         (i_slot_idx             ),
    .i_symb_idx                                         (i_symb_idx             ),
    .i_fft_agc                                          (i_fft_agc[15:8]        ),

    .o_tx_data                                          (tx1_data               ),
    .o_tx_vld                                           (tx1_vld                ),
    .o_tx_sop                                           (tx1_sop                ),
    .o_tx_eop                                           (tx1_eop                ),

    .o_ant_pwr                                          (tx1_ant_pwr            ),
    .o_rbg_idx                                          (tx1_rbg_idx            ),
    .o_pkg_type                                         (tx1_pkg_type           ),
    .o_cell_idx                                         (tx1_cell_idx           ),
    .o_slot_idx                                         (tx1_slot_idx           ),
    .o_symb_idx                                         (tx1_symb_idx           ),
    .o_fft_agc                                          (tx1_fft_agc            ),
    .o_pkg_info                                         (tx1_pkg_info           ),
    .o_prb_idx                                          (tx1_prb_idx            )
);

cpri_tx_lane                                            cpri_tx_lane_1
(
    .sys_clk_491_52                                     (i_clk                  ),
    .sys_rst_491_52                                     (i_reset                ),
    .sys_clk_368_64                                     (i_clk                  ),
    .sys_rst_368_64                                     (i_reset                ),
    .i_if_re_sel                                        (4'd0                   ),
    .i_if_re_vld                                        ({4{tx1_vld}}           ),
    .i_if_re_sop                                        ({4{tx1_sop}}           ),
    .i_if_re_eop                                        ({4{tx1_eop}}           ),
    .i_if_re_ant0                                       (tx1_data[0]            ),
    .i_if_re_ant1                                       (tx1_data[1]            ),
    .i_if_re_ant2                                       (tx1_data[2]            ),
    .i_if_re_ant3                                       (tx1_data[3]            ),
    .i_if_re_slot_idx                                   (tx1_slot_idx           ),
    .i_if_re_sym_idx                                    (tx1_symb_idx           ),
    .i_if_re_prb_idx                                    (tx1_prb_idx            ),
    .i_if_re_info0                                      (tx1_pkg_info[0]        ),
    .i_if_re_info1                                      (tx1_pkg_info[1]        ),
    .i_if_re_info2                                      (tx1_pkg_info[2]        ),
    .i_if_re_info3                                      (tx1_pkg_info[3]        ),

    .i_if_ch_type0                                      (tx1_pkg_type           ),
    .i_if_ch_type1                                      (tx1_pkg_type           ),
    .i_if_ch_type2                                      (tx1_pkg_type           ),
    .i_if_ch_type3                                      (tx1_pkg_type           ),

    .i_if_cell_idx0                                     (tx1_cell_idx           ),
    .i_if_cell_idx1                                     (tx1_cell_idx           ),
    .i_if_cell_idx2                                     (tx1_cell_idx           ),
    .i_if_cell_idx3                                     (tx1_cell_idx           ),
    
    .i_rbg_idx                                          (tx1_rbg_idx            ),
    .i_fft_agc                                          (tx1_fft_agc            ),

    .i_ant_power0                                       (tx1_ant_pwr[0]         ),
    .i_ant_power1                                       (tx1_ant_pwr[1]         ),
    .i_ant_power2                                       (tx1_ant_pwr[2]         ),
    .i_ant_power3                                       (tx1_ant_pwr[3]         ),

    .i_iq_tx_enable                                     (i_iq_tx_enable         ),
    .o_iq_tx_data                                       (o_iq_tx1_data          ),
    .o_iq_tx_valid                                      (o_iq_tx1_valid         ) 
);

         
                                  
endmodule


