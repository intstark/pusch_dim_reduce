//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: cpri_rxdata_top
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
module cpri_rxdata_top # (
    parameter                                       LANE                   = 8     ,
    parameter                                       DW                     = 32    ,
    parameter                                       ANT                    = 4     
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [LANE-1: 0]                      i_cpri_clk              ,
    input          [LANE-1: 0]                      i_cpri_rst              ,
    input          [LANE-1:0][63:0]                 i_cpri_rx_data          ,
    input          [LANE-1: 0]                      i_cpri_rx_vld           ,

    output         [   3: 0]                        o_pkg_type              ,
    output         [   6: 0]                        o_slot_idx              ,
    output         [   3: 0]                        o_symb_idx              ,
    output                                          o_cell_idx              ,
    output         [LANE-1:0][63: 0]                o_info_0                ,
    output         [LANE-1:0][63: 0]                o_info_1                ,
    output         [LANE-1:0][10: 0]                o_iq_addr               ,
    output         [LANE-1:0][ANT*32-1: 0]          o_iq_data               ,
    output         [LANE-1:0]                       o_iq_vld                ,
    output         [LANE-1:0]                       o_iq_last                
);


//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------






//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
genvar gi;

wire           [LANE-1: 0]                      rx_buf_vld              ;
wire                                            rx_buf_rden             ;
wire           [LANE-1:0]                       cpri_rx_ready           ;
wire           [LANE-1:0][63: 0]                cpri_data_buf           ;

wire           [LANE-1:0][6: 0]                 cpri_addr_buf           ;
wire           [LANE-1: 0]                      cpri_buf_last           ;
wire           [LANE-1: 0]                      cpri_buf_vld            ;
wire           [LANE-1: 0]                      cpri_buf_rdy            ;

wire           [LANE-1:0][10: 0]                iq_addr                 ;
wire           [LANE-1:0][ANT*32-1: 0]          iq_data                 ;
wire           [LANE-1: 0]                      iq_vld                  ;
wire           [LANE-1: 0]                      iq_last                 ;
wire           [LANE-1:0][3: 0]                 pkg_type                ;
wire           [LANE-1:0][6: 0]                 slot_idx                ;
wire           [LANE-1:0][3: 0]                 symb_idx                ;
wire           [LANE-1: 0]                      cell_idx                ;
wire           [LANE-1:0][63: 0]                info_0                  ;
wire           [LANE-1:0][63: 0]                info_1                  ;


//--------------------------------------------------------------------------------------
// cpri rx data buffer
//--------------------------------------------------------------------------------------
assign rx_buf_rden = &rx_buf_vld;

generate for(gi=0;gi<LANE;gi=gi+1) begin: gen_rx_buffer
    cpri_rx_buffer                                          cpri_rx_buffer
    (
        .i_cpri_clk                                         (i_cpri_clk    [gi]     ),
        .i_cpri_reset                                       (i_cpri_rst    [gi]     ),
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_rx_data                                          (i_cpri_rx_data[gi]     ),
        .i_rvalid                                           (i_cpri_rx_vld [gi]     ),
        .i_rready                                           (cpri_rx_ready [gi]     ),
        .i_rd_en                                            (rx_buf_rden            ),
        .o_rd_vld                                           (rx_buf_vld    [gi]     ),
        .o_tx_data                                          (cpri_data_buf [gi]     ),
        .o_tx_addr                                          (cpri_addr_buf [gi]     ),
        .o_tx_last                                          (cpri_buf_last [gi]     ),
        .o_tready                                           (cpri_buf_rdy  [gi]     ),
        .o_tvalid                                           (cpri_buf_vld  [gi]     ) 
    );
end
endgenerate


//------------------------------------------------------------------------------------------
//cpri unpack
//------------------------------------------------------------------------------------------
generate for(gi=0;gi<LANE;gi=gi+1) begin:gen_rxdata_unpack
    cpri_rxdata_unpack                                      cpri_rxdata_unpack_4ant
    (

        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),

        .i_cpri_data                                        (cpri_data_buf[gi]      ),
        .i_cpri_addr                                        (cpri_addr_buf[gi]      ),
        .i_cpri_last                                        (cpri_buf_last[gi]      ),
        .i_cpri_vld                                         (cpri_buf_vld [gi]      ),

        .o_tready                                           (cpri_rx_ready[gi]      ), 

        .o_pkg_type                                         (pkg_type     [gi]      ),
        .o_slot_idx                                         (slot_idx     [gi]      ),
        .o_symb_idx                                         (symb_idx     [gi]      ),
        .o_cell_idx                                         (cell_idx     [gi]      ),
        .o_info_0                                           (info_0       [gi]      ),// IQ HD
        .o_info_1                                           (info_1       [gi]      ),// FFT AGC
        .o_iq_addr                                          (iq_addr      [gi]      ),// CPRI IQ addr
        .o_iq_data                                          (iq_data      [gi]      ),// CPRI IQ data
        .o_iq_vld                                           (iq_vld       [gi]      ),// CPRI IQ valid
        .o_iq_last                                          (iq_last      [gi]      ) // CPRI IQ last(132prb ends)
    );
end
endgenerate

//------------------------------------------------------------------------------------------
// Ouput assignment
//------------------------------------------------------------------------------------------
assign o_iq_data = iq_data;
assign o_iq_addr = iq_addr;
assign o_iq_vld  = iq_vld;
assign o_iq_last = iq_last;
assign o_info_0  = info_0;
assign o_info_1  = info_1;

assign o_pkg_type = pkg_type[0];
assign o_slot_idx = slot_idx[0];
assign o_symb_idx = symb_idx[0];
assign o_cell_idx = cell_idx[0];



endmodule