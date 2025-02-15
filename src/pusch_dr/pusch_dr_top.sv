//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: pusch_dr_top
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
module pusch_dr_top #(
    parameter integer LANE  =   8 
)(
    input                                           i_clk                   , // data clock
    input                                           i_reset                 , // reset

    input          [   1: 0]                        i_aiu_idx               , // AIU index 0-3
    input          [   1: 0]                        i_rbg_size              , // default:2'b10 16rb
    input          [   1: 0]                        i_dr_mode               , // re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 

    input                                           i_rx_rfp                ,
    input                                           i_enable                ,
    // cpri rxdata
    input                                           i_l0_cpri_clk           , // cpri clkout
    input                                           i_l0_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l0_cpri_rx_data       , // cpri data
    input                                           i_l0_cpri_rx_vld        , // cpri valid

    input                                           i_l1_cpri_clk           , // cpri clkout
    input                                           i_l1_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l1_cpri_rx_data       , // cpri data
    input                                           i_l1_cpri_rx_vld        , // cpri valid

    input                                           i_l2_cpri_clk           , // cpri clkout
    input                                           i_l2_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l2_cpri_rx_data       , // cpri data
    input                                           i_l2_cpri_rx_vld        , // cpri valid

    input                                           i_l3_cpri_clk           , // cpri clkout
    input                                           i_l3_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l3_cpri_rx_data       , // cpri data
    input                                           i_l3_cpri_rx_vld        , // cpri valid

    input                                           i_l4_cpri_clk           , // cpri clkout
    input                                           i_l4_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l4_cpri_rx_data       , // cpri data
    input                                           i_l4_cpri_rx_vld        , // cpri valid

    input                                           i_l5_cpri_clk           , // cpri clkout
    input                                           i_l5_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l5_cpri_rx_data       , // cpri data
    input                                           i_l5_cpri_rx_vld        , // cpri valid

    input                                           i_l6_cpri_clk           , // cpri clkout
    input                                           i_l6_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l6_cpri_rx_data       , // cpri data
    input                                           i_l6_cpri_rx_vld        , // cpri valid

    input                                           i_l7_cpri_clk           , // cpri clkout
    input                                           i_l7_cpri_rst           , // cpri reset
    input          [  63: 0]                        i_l7_cpri_rx_data       , // cpri data
    input                                           i_l7_cpri_rx_vld        , // cpri valid


    // cpri txdata

    input                                           i_cpri0_tx_clk          , // cpri tx clock 
    input                                           i_cpri0_tx_enable       , // cpri tx enable
    output         [  63: 0]                        o_cpri0_tx_data         , // cpri data
    output                                          o_cpri0_tx_vld          , // cpri valid

    input                                           i_cpri1_tx_clk          , // cpri tx clock 
    input                                           i_cpri1_tx_enable       , // cpri tx enable
    output         [  63: 0]                        o_cpri1_tx_data         , // cpri data
    output                                          o_cpri1_tx_vld            // cpri valid
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
// WIRE & REGISTER DECLARATION 
//------------------------------------------------------------------------------------------
wire           [LANE-1:0][10: 0]                unpack_iq_addr          ;
wire           [LANE-1:0][4*32-1: 0]            unpack_iq_data          ;
wire           [LANE-1: 0]                      unpack_iq_vld           ;
wire           [LANE-1: 0]                      unpack_iq_last          ;
wire           [LANE-1:0][63:0]                 unpack_info_0           ;
wire           [LANE-1:0][ 7:0]                 unpack_info_1           ;
wire           [   3: 0]                        pkg_type                ;
wire           [   6: 0]                        slot_idx                ;
wire           [   3: 0]                        symb_idx                ;
wire                                            cell_idx                ;

wire           [LANE-1: 0]                      w_cpri_clk              ;
wire           [LANE-1: 0]                      w_cpri_rst              ;
wire           [LANE-1:0][63: 0]                w_cpri_rx_data          ;
wire           [LANE-1: 0]                      w_cpri_rx_vld           ;

wire                                            dr_rbg_load             ;
wire                                            dr_sop                  ;
wire                                            dr_eop                  ;
wire                                            dr_vld                  ;
wire           [15:0][31: 0]                    dr_data                 ;
wire           [   3: 0]                        dr_rbg_idx              ;
wire           [   3: 0]                        dr_pkg_type             ;
wire                                            dr_cell_idx             ;
wire           [   6: 0]                        dr_slot_idx             ;
wire           [   3: 0]                        dr_symb_idx             ;
wire           [15:0][ 7: 0]                    dr_fft_agc              ;
wire           [15:0][31: 0]                    dr_beam_pwr             ;


//------------------------------------------------------------------------------------------
// arrange cpri data for 8 lanes
//------------------------------------------------------------------------------------------
assign w_cpri_clk       = { i_l7_cpri_clk, i_l6_cpri_clk, i_l5_cpri_clk, i_l4_cpri_clk,
                            i_l3_cpri_clk, i_l2_cpri_clk, i_l1_cpri_clk, i_l0_cpri_clk};

assign w_cpri_rst       = { i_l7_cpri_rst, i_l6_cpri_rst, i_l5_cpri_rst, i_l4_cpri_rst,
                            i_l3_cpri_rst, i_l2_cpri_rst, i_l1_cpri_rst, i_l0_cpri_rst};

assign w_cpri_rx_vld    = { i_l7_cpri_rx_vld, i_l6_cpri_rx_vld, i_l5_cpri_rx_vld, i_l4_cpri_rx_vld,
                            i_l3_cpri_rx_vld, i_l2_cpri_rx_vld, i_l1_cpri_rx_vld, i_l0_cpri_rx_vld};

assign w_cpri_rx_data[0] = i_l0_cpri_rx_data;
assign w_cpri_rx_data[1] = i_l1_cpri_rx_data;
assign w_cpri_rx_data[2] = i_l2_cpri_rx_data;
assign w_cpri_rx_data[3] = i_l3_cpri_rx_data;
assign w_cpri_rx_data[4] = i_l4_cpri_rx_data;
assign w_cpri_rx_data[5] = i_l5_cpri_rx_data;
assign w_cpri_rx_data[6] = i_l6_cpri_rx_data;
assign w_cpri_rx_data[7] = i_l7_cpri_rx_data;




//------------------------------------------------------------------------------------------
//cpri rxdata & unpack
//------------------------------------------------------------------------------------------

cpri_rxdata_top                                         cpri_rxdata_top
(

    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_dr_mode                                          (i_dr_mode              ),// re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 

    .i_rx_rfp                                           (i_rx_rfp               ),
    .i_enable                                           (i_enable               ),
    
    .i_cpri_clk                                         (w_cpri_clk             ),
    .i_cpri_rst                                         (w_cpri_rst             ),
    .i_cpri_rx_data                                     (w_cpri_rx_data         ),
    .i_cpri_rx_vld                                      (w_cpri_rx_vld          ),

    .o_pkg_type                                         (pkg_type               ),
    .o_slot_idx                                         (slot_idx               ),
    .o_symb_idx                                         (symb_idx               ),
    .o_cell_idx                                         (cell_idx               ),
    .o_info_0                                           (unpack_info_0          ),// IQ HD
    .o_info_1                                           (unpack_info_1          ),// FFT AGC
    .o_iq_addr                                          (unpack_iq_addr         ),// CPRI IQ addr
    .o_iq_data                                          (unpack_iq_data         ),// CPRI IQ data
    .o_iq_vld                                           (unpack_iq_vld          ),// CPRI IQ valid
    .o_iq_last                                          (unpack_iq_last         ) // CPRI IQ last(132prb ends)
);



//------------------------------------------------------------------------------------------
// pusch core
// -----------------------------------------------------------------------------------------
pusch_dr_core                                           pusch_dr_core(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),

    .i_aiu_idx                                          (i_aiu_idx              ),
    .i_rbg_size                                         (i_rbg_size             ),// default:2'b10 16rb
    .i_dr_mode                                          (i_dr_mode              ),// re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 

    .i_pkg_type                                         (pkg_type               ),
    .i_slot_idx                                         (slot_idx               ),
    .i_symb_idx                                         (symb_idx               ),
    .i_cell_idx                                         (cell_idx               ),
    .i_info_0                                           (unpack_info_0          ),// IQ HD
    .i_info_1                                           (unpack_info_1          ),// FFT AGC
    .i_iq_addr                                          (unpack_iq_addr         ),// 32 ants iq addr
    .i_iq_data                                          (unpack_iq_data         ),// 32 ants iq datat
    .i_iq_vld                                           (unpack_iq_vld          ),// 32 ants iq vld
    .i_iq_last                                          (unpack_iq_last         ),// 32 ants iq last(132prb ends)

    .o_beam_pwr                                         (dr_beam_pwr            ),
    .o_dr_data                                          (dr_data                ),
    .o_dr_vld                                           (dr_vld                 ),
    .o_dr_sop                                           (dr_sop                 ),
    .o_dr_eop                                           (dr_eop                 ),
    .o_rbg_load                                         (dr_rbg_load            ),

    .o_rbg_idx                                          (dr_rbg_idx             ),
    .o_pkg_type                                         (dr_pkg_type            ),
    .o_cell_idx                                         (dr_cell_idx            ),
    .o_slot_idx                                         (dr_slot_idx            ),
    .o_symb_idx                                         (dr_symb_idx            ),
    .o_fft_agc                                          (dr_fft_agc             ) 
);


//------------------------------------------------------------------------------------------
// cpri txdata & repack
// -----------------------------------------------------------------------------------------
cpri_txdata_top                                         cpri_txdata_top(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),

    .i_rx_sel                                           (1'b0                   ),
    .i_rx_vld                                           (dr_vld                 ),
    .i_rx_sop                                           (dr_sop                 ),
    .i_rx_eop                                           (dr_eop                 ),

    .i_rbg_load                                         (dr_rbg_load            ),
    .i_ant_data                                         (dr_data                ),
    .i_ant_pwr                                          (dr_beam_pwr            ),

    .i_aiu_idx                                          (i_aiu_idx              ),
    .i_rbg_idx                                          (dr_rbg_idx             ),
    .i_pkg_type                                         (dr_pkg_type            ),
    .i_cell_idx                                         (dr_cell_idx            ),
    .i_slot_idx                                         (dr_slot_idx            ),
    .i_symb_idx                                         (dr_symb_idx            ),
    .i_fft_agc                                          (dr_fft_agc             ),
    
    .i_tx0_clk                                          (i_cpri0_tx_clk         ),// lane 0 txdata clock
    .i_tx0_enable                                       (i_cpri0_tx_enable      ),// lane 0 txdata enable
    .o_tx0_data                                         (o_cpri0_tx_data        ),// lane 0 txdata
    .o_tx0_valid                                        (o_cpri0_tx_vld         ),// lane 0 txdata valid
    
    .i_tx1_clk                                          (i_cpri1_tx_clk         ),// lane 1 txdata clock
    .i_tx1_enable                                       (i_cpri1_tx_enable      ),// lane 1 txdata enable
    .o_tx1_data                                         (o_cpri1_tx_data        ),// lane 1 txdata
    .o_tx1_valid                                        (o_cpri1_tx_vld         ) // lane 1 txdata valid
);




endmodule