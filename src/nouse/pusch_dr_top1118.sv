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

    input          [   1: 0]                        i_rbg_size              , // default:2'b10 16rb

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
    input                                           i_iq_tx_enable          , // cpri tx enable
    output         [  63: 0]                        o_cpri_tx_data          , // cpri data
    output                                          o_cpri_tx_vld             // cpri valid

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
wire           [LANE-1:0][63:0]                 unpack_info_1           ;

reg                                             sym1_done             =0;

wire           [LANE-1: 0]                      w_cpri_clk              ;
wire           [LANE-1: 0]                      w_cpri_rst              ;
wire           [LANE-1:0][63: 0]                w_cpri_rx_data          ;
wire           [LANE-1: 0]                      w_cpri_rx_vld           ;

wire                                            dr_sop                  ;
wire                                            dr_eop                  ;
wire                                            dr_vld                  ;
wire           [3:0][31: 0]                     dr_data                 ;
wire           [   8: 0]                        dr_prb_idx              ;



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
generate for(gi=0;gi<LANE;gi=gi+1) begin:gen_rxdata_unpack
    // Instantiate the Unit Under Test (UUT)
    cpri_rxdata_unpack                                      cpri_rxdata_unpack_4ant
    (

        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_cpri_clk                                         (w_cpri_clk    [gi]     ),
        .i_cpri_rst                                         (w_cpri_rst    [gi]     ),
        .i_cpri_rx_data                                     (w_cpri_rx_data[gi]     ),
        .i_cpri_rx_vld                                      (w_cpri_rx_vld [gi]     ),

        .o_info_0                                           (unpack_info_0 [gi]     ),  // IQ HD
        .o_info_1                                           (unpack_info_1 [gi]     ),  // FFT AGC
        .o_iq_addr                                          (unpack_iq_addr[gi]     ),  // CPRI IQ addr
        .o_iq_data                                          (unpack_iq_data[gi]     ),  // CPRI IQ data
        .o_iq_vld                                           (unpack_iq_vld [gi]     ),  // CPRI IQ valid
        .o_iq_last                                          (unpack_iq_last[gi]     )   // CPRI IQ last(132prb ends)
    );
    
end
endgenerate


//------------------------------------------------------------------------------------------
// pusch core
// -----------------------------------------------------------------------------------------
pusch_dr_core                                           pusch_dr_core(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    
    .i_rbg_size                                         (2'b10                  ),

    .i_info_0                                           (unpack_info_0          ),  // IQ HD
    .i_info_1                                           (unpack_info_1          ),  // FFT AGC
    .i_iq_addr                                          (unpack_iq_addr         ),  // 32 ants iq addr
    .i_iq_data                                          (unpack_iq_data         ),  // 32 ants iq datat
    .i_iq_vld                                           (unpack_iq_vld          ),  // 32 ants iq vld
    .i_iq_last                                          (unpack_iq_last         ),  // 32 ants iq last(132prb ends)

    .o_tx_data                                          (dr_data                ),
    .o_tx_vld                                           (dr_vld                 ),
    .o_tx_sop                                           (dr_sop                 ),
    .o_tx_eop                                           (dr_eop                 ),
    .o_prb_idx                                          (dr_prb_idx             )
);


//------------------------------------------------------------------------------------------
// cpri txdata & repack
// -----------------------------------------------------------------------------------------
cpri_txdata_top                                         cpri_txdata_top(
    .sys_clk_491_52                                     (i_clk                  ),
    .sys_rst_491_52                                     (i_reset                ),
    .sys_clk_368_64                                     (i_clk                  ),
    .sys_rst_368_64                                     (i_reset                ),
    .i_if_re_sel                                        (                       ),
    .i_if_re_vld                                        ({4{dr_vld}}            ),
    .i_if_re_sop                                        ({4{dr_sop}}            ),
    .i_if_re_eop                                        ({4{dr_eop}}            ),
    .i_if_re_ant0                                       (dr_data[0]             ),
    .i_if_re_ant1                                       (dr_data[1]             ),
    .i_if_re_ant2                                       (dr_data[2]             ),
    .i_if_re_ant3                                       (dr_data[3]             ),
    .i_if_re_slot_idx                                   (                       ),
    .i_if_re_sym_idx                                    (                       ),
    .i_if_re_prb_idx                                    (dr_prb_idx             ),
    .i_if_re_info0                                      (                       ),
    .i_if_re_info1                                      (                       ),
    .i_if_re_info2                                      (                       ),
    .i_if_re_info3                                      (                       ),
    .i_iq_tx_enable                                     (i_iq_tx_enable         ),
    .o_iq_tx_data                                       (o_cpri_tx_data         ),
    .o_iq_tx_valid                                      (o_cpri_tx_vld          ) 
);




endmodule