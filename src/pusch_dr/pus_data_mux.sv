//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2025/02/14 17:09:23
// Design Name: 
// Module Name: pus_data_mux
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
module pus_data_mux #(
    parameter integer FIFO_DEPTH         =  16   ,
    parameter integer FIFO_WIDTH         =  65   
)(
    input                                           i_clk                   ,// data clock
    input                                           i_reset                 ,// reset

    input                                           i_data_sel              ,// AIU index 0-3

    // tv data
    input          [7:0][63: 0]                     i_tv_data               ,// cpri data
    input          [   7: 0]                        i_tv_vld                ,// cpri valid

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
    output         [   7: 0]                        o_pus_rx_rst            ,// rx rst 
    output         [7:0][63: 0]                     o_pus_rx_data           ,// cpri data
    output         [   7: 0]                        o_pus_rx_vld             // rx vld 
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
genvar gi;
wire           [   7: 0]                        w_cpri_clk              ;
wire           [   7: 0]                        w_cpri_rst              ;
wire           [7:0][63: 0]                     w_cpri_data             ;
wire           [   7: 0]                        w_cpri_vld              ;

wire           [7:0][64: 0]                     wr_data                 ;
wire           [7:0][64: 0]                     rd_data                 ;
wire           [   7: 0]                        wr_en                   ;
wire           [   7: 0]                        rd_en                   ;
wire           [   7: 0]                        rd_vld                  ;
wire           [   7: 0]                        wr_full                 ;
wire           [   7: 0]                        rd_empty                ;
wire           [   7: 0]                        rst_syn                 ;

reg            [7:0][63: 0]                     rx_data               =0;
reg            [   7: 0]                        rx_rst                =0;
reg            [   7: 0]                        rx_vld                =0;




//------------------------------------------------------------------------------------------
// arrange cpri data for 8 lanes
//------------------------------------------------------------------------------------------
assign w_cpri_clk       = { i_l7_cpri_clk, i_l6_cpri_clk, i_l5_cpri_clk, i_l4_cpri_clk,
                            i_l3_cpri_clk, i_l2_cpri_clk, i_l1_cpri_clk, i_l0_cpri_clk};

assign w_cpri_rst       = { i_l7_cpri_rst, i_l6_cpri_rst, i_l5_cpri_rst, i_l4_cpri_rst,
                            i_l3_cpri_rst, i_l2_cpri_rst, i_l1_cpri_rst, i_l0_cpri_rst};

assign w_cpri_vld       = { i_l7_cpri_rx_vld, i_l6_cpri_rx_vld, i_l5_cpri_rx_vld, i_l4_cpri_rx_vld,
                            i_l3_cpri_rx_vld, i_l2_cpri_rx_vld, i_l1_cpri_rx_vld, i_l0_cpri_rx_vld};

assign w_cpri_data[0]   = i_l0_cpri_rx_data;
assign w_cpri_data[1]   = i_l1_cpri_rx_data;
assign w_cpri_data[2]   = i_l2_cpri_rx_data;
assign w_cpri_data[3]   = i_l3_cpri_rx_data;
assign w_cpri_data[4]   = i_l4_cpri_rx_data;
assign w_cpri_data[5]   = i_l5_cpri_rx_data;
assign w_cpri_data[6]   = i_l6_cpri_rx_data;
assign w_cpri_data[7]   = i_l7_cpri_rx_data;

//------------------------------------------------------------------------------------------
// cpri data cdc
//------------------------------------------------------------------------------------------
generate for(gi=0; gi<8; gi++)begin

    assign wr_data[gi]  = {w_cpri_vld[gi],w_cpri_data[gi]};
    assign wr_en  [gi]  = ~wr_full[gi];
    assign rd_en  [gi]  = ~rd_empty[gi] && rd_vld[gi];
    
    // cpri rst sync
    alt_reset_synchronizer #(.depth(2),.rst_value(1)) wreset_sync (.clk(w_cpri_clk[gi]),.reset_n(!w_cpri_rst[gi]),.rst_out(rst_syn[gi]));

    // cpri data sync
    FIFO_ASYNC_XPM_intel #(
        .NUMWORDS                                           (FIFO_DEPTH             ),
        .DATA_WIDTH_A                                       (FIFO_WIDTH             ),
        .DATA_WIDTH_Q                                       (FIFO_WIDTH             ) 
    )u_fifo_buffer_64w_16d_0
    (
        .aclr                                               (w_cpri_rst[gi]         ),
        .wclk                                               (w_cpri_clk[gi]         ),
        .wr_en                                              (wr_en     [gi]         ),
        .din                                                (wr_data   [gi]         ),
        .rclk                                               (i_clk                  ),
        .rd_en                                              (rd_en     [gi]         ),
        .dout                                               (rd_data   [gi]         ),
        .dout_valid                                         (rd_vld    [gi]         ),
        .empty                                              (rd_empty  [gi]         ),
        .full                                               (wr_full   [gi]         ) 
    );
end
endgenerate

//------------------------------------------------------------------------------------------
// data mux
//------------------------------------------------------------------------------------------
always_ff @ (posedge i_clk)begin
    for(int i=0;i<8;i++)begin
        if(i_data_sel)begin
            rx_data[i] <= i_tv_data[i];
            rx_vld [i] <= i_tv_vld [i];
            rx_rst [i] <= i_reset     ;
        end else begin
            rx_data[i] <= rd_data[i][63: 0];
            rx_vld [i] <= rd_data[i][64];
            rx_rst [i] <= rst_syn[i];
        end
    end
end

//------------------------------------------------------------------------------------------
// output assignment
//------------------------------------------------------------------------------------------
generate for(gi=0; gi<8; gi++)begin
    assign o_pus_rx_rst [gi]  =  rx_rst [gi];
    assign o_pus_rx_data[gi]  =  rx_data[gi];
    assign o_pus_rx_vld [gi]  =  rx_vld [gi];
end
endgenerate


endmodule