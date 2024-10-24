//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: pdsch_dr_top
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
module pdsch_dr_top #(
    parameter integer LANE  =   8 
)(
    input                                           i_clk                   ,// data clock
    input                                           i_reset                 ,// reset

    input          [   1: 0]                        i_rbg_size              ,// default:2'b10 16rb

    // cpri rxdata
    input                                           i_l0_cpri_clk           ,// cpri clkout
    input                                           i_l0_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l0_cpri_rx_data       ,// cpri data
    input                                           i_l0_cpri_rx_vld        ,// cpri valid

    input                                           i_l1_cpri_clk           ,// cpri clkout
    input                                           i_l1_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l1_cpri_rx_data       ,// cpri data
    input                                           i_l1_cpri_rx_vld        ,// cpri valid

    input                                           i_l2_cpri_clk           ,// cpri clkout
    input                                           i_l2_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l2_cpri_rx_data       ,// cpri data
    input                                           i_l2_cpri_rx_vld        ,// cpri valid

    input                                           i_l3_cpri_clk           ,// cpri clkout
    input                                           i_l3_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l3_cpri_rx_data       ,// cpri data
    input                                           i_l3_cpri_rx_vld        ,// cpri valid

    input                                           i_l4_cpri_clk           ,// cpri clkout
    input                                           i_l4_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l4_cpri_rx_data       ,// cpri data
    input                                           i_l4_cpri_rx_vld        ,// cpri valid

    input                                           i_l5_cpri_clk           ,// cpri clkout
    input                                           i_l5_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l5_cpri_rx_data       ,// cpri data
    input                                           i_l5_cpri_rx_vld        ,// cpri valid

    input                                           i_l6_cpri_clk           ,// cpri clkout
    input                                           i_l6_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l6_cpri_rx_data       ,// cpri data
    input                                           i_l6_cpri_rx_vld        ,// cpri valid

    input                                           i_l7_cpri_clk           ,// cpri clkout
    input                                           i_l7_cpri_rst           ,// cpri reset
    input          [  63: 0]                        i_l7_cpri_rx_data       ,// cpri data
    input                                           i_l7_cpri_rx_vld        ,// cpri valid


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
wire           [LANE-1:0][10: 0]                unpack_iq_addr          ;
wire           [LANE-1:0][4*32-1: 0]            unpack_iq_data          ;
wire           [LANE-1: 0]                      unpack_iq_vld           ;
wire           [LANE-1: 0]                      unpack_iq_last          ;

reg                                             sym1_done             =0;

wire           [LANE-1: 0]                      w_cpri_clk              ;
wire           [LANE-1: 0]                      w_cpri_rst              ;
wire           [LANE-1:0][63: 0]                w_cpri_rx_data          ;
wire           [LANE-1: 0]                      w_cpri_rx_vld           ;



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
// unpack cpri data for 8 lanes
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
        .i_sym1_done                                        (sym1_done              ),
        .o_iq_addr                                          (unpack_iq_addr[gi]     ),
        .o_iq_data                                          (unpack_iq_data[gi]     ),
        .o_iq_vld                                           (unpack_iq_vld [gi]     ),
        .o_iq_last                                          (unpack_iq_last[gi]     ) 
    );
    
end
endgenerate


//------------------------------------------------------------------------------------------
// pdsch core
// -----------------------------------------------------------------------------------------
pdsch_dr_core                                           pdsch_dr_core(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    
    .i_rbg_size                                         (2'b10                  ),

    .i_iq_addr                                          (unpack_iq_addr         ),// 32 ants iq addr
    .i_iq_data                                          (unpack_iq_data         ),// 32 ants iq datat
    .i_iq_vld                                           (unpack_iq_vld          ),// 32 ants iq vld
    .i_iq_last                                          (unpack_iq_last         ),// 32 ants iq last(132prb ends)

    .o_cpri_tx_data                                     (o_cpri_tx_data         ),
    .o_cpri_tx_vld                                      (o_cpri_tx_vld          ) 
);








endmodule