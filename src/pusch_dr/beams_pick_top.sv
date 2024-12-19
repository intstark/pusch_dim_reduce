//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: beams_pick_top
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
module beams_pick_top # (
    parameter integer WDATA_WIDTH        =  40   ,
    parameter integer WADDR_WIDTH        =  11   ,
    parameter integer RDATA_WIDTH        =  40   ,
    parameter integer RADDR_WIDTH        =  11    
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_rvld                  ,
    input                                           i_sop                   ,
    input                                           i_eop                   ,
    input          [15:0][WDATA_WIDTH-1: 0]         i_data_re               ,
    input          [15:0][WDATA_WIDTH-1: 0]         i_data_im               ,
    
    input          [15:0][31: 0]                    i_sort_pwr              ,
    input          [15:0][7: 0]                     i_sort_idx              ,
    input                                           i_sort_sop              ,
    input                                           i_rbg_load              ,

    input                                           i_sym_1st               ,
    
    // input header info
    input          [  63: 0]                        i_info_0                ,// IQ HD 
    input          [  15: 0]                        i_info_1                ,// FFT AGC

    // output header info
    output         [  63: 0]                        o_info_0                ,// IQ HD 
    output         [15:0][7: 0]                     o_info_1                ,// FFT AGC

    output         [15:0][31: 0]                    o_sort_pwr              ,
    output         [15:0][RDATA_WIDTH-1: 0]         o_data_re               ,
    output         [15:0][RDATA_WIDTH-1: 0]         o_data_im               ,
    output                                          o_rbg_load              ,
    output                                          o_sop                   ,
    output                                          o_eop                   ,
    output                                          o_tvld                   
);


//------------------------------------------------------------------------------------------
// beam sort
//------------------------------------------------------------------------------------------
beams_mem_pick # (
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .WADDR_WIDTH                                        (WADDR_WIDTH            ),
    .RDATA_WIDTH                                        (RDATA_WIDTH            ),
    .RADDR_WIDTH                                        (RADDR_WIDTH            ) 
)beams_mem_pick_i(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rvld                 ),
    .i_wr_wen                                           (i_rvld                 ),
    .i_wr_sop                                           (i_sop                  ),
    .i_wr_eop                                           (i_eop                  ),
    .i_wr_data                                          (i_data_re              ),

    .i_sort_idx                                         (i_sort_idx             ),
    .i_sort_sop                                         (i_sort_sop             ),
    .i_sym_1st                                          (i_sym_1st              ),
    .i_rbg_load                                         (i_rbg_load             ),

    .i_info_0                                           (i_info_0               ),  // IQ HD
    .i_info_1                                           (i_info_1               ),  // FFT AGC

    .o_info_0                                           (o_info_0               ),  // IQ HD
    .o_info_1                                           (o_info_1               ),  // FFT AGC

    .o_rd_data                                          (o_data_re              ),
    .o_rd_addr                                          (                       ),
    .o_sop                                              (o_sop                  ),
    .o_eop                                              (o_eop                  ),
    .o_tvalid                                           (o_tvld                 ) 
);

beams_mem_pick # (
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .WADDR_WIDTH                                        (WADDR_WIDTH            ),
    .RDATA_WIDTH                                        (RDATA_WIDTH            ),
    .RADDR_WIDTH                                        (RADDR_WIDTH            ) 
)beams_mem_pick_q(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rvld                 ),
    .i_wr_wen                                           (i_rvld                 ),
    .i_wr_sop                                           (i_sop                  ),
    .i_wr_eop                                           (i_eop                  ),
    .i_wr_data                                          (i_data_im              ),

    .i_sort_idx                                         (i_sort_idx             ),
    .i_sort_sop                                         (i_sort_sop             ),
    .i_sym_1st                                          (i_sym_1st              ),

    .i_info_0                                           (                       ),// IQ HD
    .i_info_1                                           (                       ),// FFT AGC

    .o_info_0                                           (                       ),// IQ HD
    .o_info_1                                           (                       ),// FFT AGC

    .o_rd_data                                          (o_data_im              ),
    .o_rd_addr                                          (                       ),
    .o_sop                                              (                       ),
    .o_eop                                              (                       ),
    .o_tvalid                                           (                       ) 
);

//------------------------------------------------------------------------------------------
// beam power delay match 
//------------------------------------------------------------------------------------------
register_shift # (
    .WIDTH                                              (1                      ),
    .DEPTH                                              (4                      ) 
)dly_rbg_load(
    .clk                                                (i_clk                  ),
    .in                                                 (i_rbg_load             ),
    .out                                                (o_rbg_load             ) 
);


generate for (genvar i = 0; i < 16; i++) begin : delay_match
    register_shift #(
        .WIDTH                                              (32                     ),
        .DEPTH                                              (4                      ) 
    )dly_sort_pwr(
        .clk                                                (i_clk                  ),
        .in                                                 (i_sort_pwr[i]          ),
        .out                                                (o_sort_pwr[i]          ) 
    );
end
endgenerate


endmodule
