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
    input                                           i_eop                   ,
    input          [15:0][WDATA_WIDTH-1: 0]         i_data_re               ,
    input          [15:0][WDATA_WIDTH-1: 0]         i_data_im               ,

    input          [15:0][7: 0]                     i_sort_idx              ,
    input                                           i_sort_sop              ,

    input                                           i_sym_1st               ,

    output         [15:0][RDATA_WIDTH-1: 0]         o_data_re               ,
    output         [15:0][RDATA_WIDTH-1: 0]         o_data_im               ,
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
    .i_wr_eop                                           (i_eop                  ),
    .i_wr_data                                          (i_data_re              ),

    .i_sort_idx                                         (i_sort_idx             ),
    .i_sort_sop                                         (i_sort_sop             ),

    .i_sym_1st                                          (i_sym_1st              ),

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
    .i_wr_eop                                           (i_eop                  ),
    .i_wr_data                                          (i_data_im              ),

    .i_sort_idx                                         (i_sort_idx             ),
    .i_sort_sop                                         (i_sort_sop             ),

    .i_sym_1st                                          (i_sym_1st              ),

    .o_rd_data                                          (o_data_im              ),
    .o_rd_addr                                          (                       ),
    .o_sop                                              (                       ),
    .o_eop                                              (                       ),
    .o_tvalid                                           (                       ) 
);



endmodule
