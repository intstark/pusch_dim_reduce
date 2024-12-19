`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-03-07
//File name       :  ul_compress_data.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------


module ul_compress_data
(
    input  wire                                     clk                     ,
    input  wire                                     rst                     ,
    input  wire    [   3: 0]                        i_sel                   ,
    input  wire    [   3: 0]                        i_sop                   ,
    input  wire    [   3: 0]                        i_eop                   ,
    input  wire    [   3: 0]                        i_vld                   ,
    input  wire    [  31: 0]                        i_din_ant0              ,
    input  wire    [  31: 0]                        i_din_ant1              ,
    input  wire    [  31: 0]                        i_din_ant2              ,
    input  wire    [  31: 0]                        i_din_ant3              ,
    input  wire    [   6: 0]                        i_slot_idx              ,
    input  wire    [   3: 0]                        i_symb_idx              ,
    input  wire    [   8: 0]                        i_prb_idx               ,
    input  wire    [   3: 0]                        i_rbg_idx               ,
    input  wire    [  31: 0]                        i_fft_agc               ,
    input  wire    [   3: 0]                        i_channel_type0         ,
    input  wire    [   3: 0]                        i_channel_type1         ,
    input  wire    [   3: 0]                        i_channel_type2         ,
    input  wire    [   3: 0]                        i_channel_type3         ,
    input  wire                                     i_cell_idx0             ,
    input  wire                                     i_cell_idx1             ,
    input  wire                                     i_cell_idx2             ,
    input  wire                                     i_cell_idx3             ,
    input  wire    [   7: 0]                        i_info0                 ,
    input  wire    [   7: 0]                        i_info1                 ,
    input  wire    [   7: 0]                        i_info2                 ,
    input  wire    [   7: 0]                        i_info3                 ,

    input  wire    [  31: 0]                        i_ant_power0            ,
    input  wire    [  31: 0]                        i_ant_power1            ,
    input  wire    [  31: 0]                        i_ant_power2            ,
    input  wire    [  31: 0]                        i_ant_power3            ,

    output wire                                     o_sel                   ,
    output wire                                     o_sop                   ,
    output wire                                     o_eop                   ,
    output wire                                     o_vld                   ,
    output wire    [  13: 0]                        o_data_ant0             ,
    output wire    [  13: 0]                        o_data_ant1             ,
    output wire    [  13: 0]                        o_data_ant2             ,
    output wire    [  13: 0]                        o_data_ant3             ,
    output wire    [   3: 0]                        o_shift0                ,
    output wire    [   3: 0]                        o_shift1                ,
    output wire    [   3: 0]                        o_shift2                ,
    output wire    [   3: 0]                        o_shift3                ,
    output wire    [   6: 0]                        o_slot_idx              ,
    output wire    [   3: 0]                        o_symb_idx              ,
    output wire    [   8: 0]                        o_prb_idx               ,
    output wire    [   3: 0]                        o_rbg_idx               ,
    output wire    [  31: 0]                        o_fft_agc               ,
    output wire    [   3: 0]                        o_channel_type0         ,
    output wire    [   3: 0]                        o_channel_type1         ,
    output wire    [   3: 0]                        o_channel_type2         ,
    output wire    [   3: 0]                        o_channel_type3         ,
    output wire                                     o_cell_idx0             ,
    output wire                                     o_cell_idx1             ,
    output wire                                     o_cell_idx2             ,
    output wire                                     o_cell_idx3             ,
    output wire    [   7: 0]                        o_info0                 ,
    output wire    [   7: 0]                        o_info1                 ,
    output wire    [   7: 0]                        o_info2                 ,
    output wire    [   7: 0]                        o_info3                 ,

    output wire    [  31: 0]                        o_pkg0_power            ,
    output wire    [  31: 0]                        o_pkg1_power            ,
    output wire    [  31: 0]                        o_pkg2_power            ,
    output wire    [  31: 0]                        o_pkg3_power           
);         

compress_bit #
(
    .Num                                                (7                      ) 
)
u0_compress_bit
(
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .i_sel                                              (i_sel[0]               ),
    .i_sop                                              (i_sop[0]               ),
    .i_eop                                              (i_eop[0]               ),
    .i_vld                                              (i_vld[0]               ),
    .i_din                                              (i_din_ant0             ),
    .i_slot_idx                                         (i_slot_idx             ),
    .i_symb_idx                                         (i_symb_idx             ),
    .i_prb_idx                                          (i_prb_idx              ),
    .i_ch_type                                          (i_channel_type0        ),
    .i_info                                             (i_info0                ),
    .o_sel                                              (o_sel                  ),
    .o_sop                                              (o_sop                  ),
    .o_eop                                              (o_eop                  ),
    .o_vld                                              (o_vld                  ),
    .o_dout                                             (o_data_ant0            ),
    .o_shift                                            (o_shift0               ),
    .o_slot_idx                                         (o_slot_idx             ),
    .o_symb_idx                                         (o_symb_idx             ),
    .o_prb_idx                                          (o_prb_idx              ),
    .o_type                                             (o_channel_type0        ),
    .o_info                                             (o_info0                ) 
);

compress_bit #
(
    .Num                                                (7                      ) 
)
u1_compress_bit
(
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .i_sel                                              (i_sel[1]               ),
    .i_sop                                              (i_sop[1]               ),
    .i_eop                                              (i_eop[1]               ),
    .i_vld                                              (i_vld[1]               ),
    .i_din                                              (i_din_ant1             ),
    .i_ch_type                                          (i_channel_type1        ),
    .i_info                                             (i_info1                ),
    .o_dout                                             (o_data_ant1            ),
    .o_shift                                            (o_shift1               ),
    .o_type                                             (o_channel_type1        ),
    .o_info                                             (o_info1                ) 
);

compress_bit #
(
    .Num                                                (7                      ) 
)
u2_compress_bit
(
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .i_sel                                              (i_sel[2]               ),
    .i_sop                                              (i_sop[2]               ),
    .i_eop                                              (i_eop[2]               ),
    .i_vld                                              (i_vld[2]               ),
    .i_din                                              (i_din_ant2             ),
    .i_ch_type                                          (i_channel_type2        ),
    .i_info                                             (i_info2                ),
    .o_dout                                             (o_data_ant2            ),
    .o_shift                                            (o_shift2               ),
    .o_type                                             (o_channel_type2        ),
    .o_info                                             (o_info2                ) 
);

compress_bit #
(
    .Num                                                (7                      ) 
)
u3_compress_bit
(
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .i_sel                                              (i_sel[3]               ),
    .i_sop                                              (i_sop[3]               ),
    .i_eop                                              (i_eop[3]               ),
    .i_vld                                              (i_vld[3]               ),
    .i_din                                              (i_din_ant3             ),
    .i_ch_type                                          (i_channel_type3        ),
    .i_info                                             (i_info3                ),
    .o_dout                                             (o_data_ant3            ),
    .o_shift                                            (o_shift3               ),
    .o_type                                             (o_channel_type3        ),
    .o_info                                             (o_info3                ) 
);


register_shift # (
    .WIDTH                                              (4                      ),
    .DEPTH                                              (19                     ) 
)u_dly_rbg_idx(                                        
    .clk                                                (clk                    ),
    .in                                                 (i_rbg_idx              ),
    .out                                                (o_rbg_idx              ) 
);

register_shift # (
    .WIDTH                                              (32                     ),
    .DEPTH                                              (19                     ) 
)u_dly_fft_agc(                                        
    .clk                                                (clk                    ),
    .in                                                 (i_fft_agc              ),
    .out                                                (o_fft_agc              ) 
);
//--------------------------------------------------------------------------------------
// ant power unpack
//--------------------------------------------------------------------------------------
wire           [3:0][31: 0]                     ant_pwr                 ;
wire           [3:0][31: 0]                     ant_pwr_dly             ;

assign ant_pwr[0] = i_ant_power0;
assign ant_pwr[1] = i_ant_power1;
assign ant_pwr[2] = i_ant_power2;
assign ant_pwr[3] = i_ant_power3;


//--------------------------------------------------------------------------------------
// ant power delay
//--------------------------------------------------------------------------------------
generate for (genvar gi = 0; gi < 4; gi++) begin : gen_ant_power
    register_shift # (
        .WIDTH                                              (32                     ),
        .DEPTH                                              (19                     ) 
    )u_dly_ant_pwr(                                        
        .clk                                                (clk                    ),
        .in                                                 (ant_pwr    [gi]        ),
        .out                                                (ant_pwr_dly[gi]        ) 
    );
end
endgenerate

//--------------------------------------------------------------------------------------
// ant power output 
//--------------------------------------------------------------------------------------
assign o_pkg0_power = ant_pwr_dly[0];
assign o_pkg1_power = ant_pwr_dly[1];
assign o_pkg2_power = ant_pwr_dly[2];   
assign o_pkg3_power = ant_pwr_dly[3];   

register_shift # (
    .WIDTH                                              (1                      ),
    .DEPTH                                              (19                     ) 
)u_dly_cell_idx0(                                        
    .clk                                                (clk                    ),
    .in                                                 (i_cell_idx0            ),
    .out                                                (o_cell_idx0            ) 
);

register_shift # (
    .WIDTH                                              (1                      ),
    .DEPTH                                              (19                     ) 
)u_dly_cell_idx1(                                        
    .clk                                                (clk                    ),
    .in                                                 (i_cell_idx1            ),
    .out                                                (o_cell_idx1            ) 
);

register_shift # (
    .WIDTH                                              (1                      ),
    .DEPTH                                              (19                     ) 
)u_dly_cell_idx2(                                        
    .clk                                                (clk                    ),
    .in                                                 (i_cell_idx2            ),
    .out                                                (o_cell_idx2            ) 
);

register_shift # (
    .WIDTH                                              (1                      ),
    .DEPTH                                              (19                     ) 
)u_dly_cell_idx3(                                        
    .clk                                                (clk                    ),
    .in                                                 (i_cell_idx3            ),
    .out                                                (o_cell_idx3            ) 
);

endmodule
