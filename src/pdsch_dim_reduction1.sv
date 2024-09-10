//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: pdsch_dim_reduction 
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
module pdsch_dim_reduction #(
    parameter integer LANE               =  8    ,
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  12   ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  12   ,
    parameter integer FIFO_DEPTH         =  8    ,
    parameter integer FIFO_WIDTH         =  1    ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  15   ,    
    parameter integer INFO_WIDTH         =  1    ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [  63: 0]                        i_cpri_rx_data          ,
    input          [   6: 0]                        i_cpri_rx_seq           ,
    input                                           i_cpri_rx_vld           ,
    input                                           i_sym1_done             ,
    input          [15:0][32*32-1: 0]               i_code_word_even        ,
    input          [15:0][32*32-1: 0]               i_code_word_odd         ,
    input          [   1: 0]                        i_rbg_size              ,

    output         [LANE*4*32-1: 0]                 o_ant_even              ,
    output         [LANE*4*32-1: 0]                 o_ant_odd               ,
    output         [RADDR_WIDTH-1: 0]               o_ant_addr              ,
    output                                          o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam   BEAM =   16;     // number of data streams
localparam   ANT  =   32;     // number of data streams
localparam   IW   =   32;     // number of data streams
localparam   OW   =   48;     // output width
genvar gi;


//------------------------------------------------------------------------------------------
// RAM BLOCK FOR CPRI DATA FOR 7 SYMBOLS 
//------------------------------------------------------------------------------------------
wire           [LANE-1:0][10: 0]                unpack_iq_addr          ;
wire           [LANE-1:0][3:0][31: 0]           unpack_iq_data          ;
wire           [LANE-1: 0]                      unpack_iq_vld           ;
wire           [LANE-1: 0]                      unpack_iq_last          ;

wire           [LANE-1:0][4*32-1: 0]            ant_even                ;
wire           [LANE-1:0][4*32-1: 0]            ant_odd                 ;
wire           [LANE-1:0][11-1: 0]              ant_addr                ;
wire           [LANE-1: 0]                      ant_tvalid              ;

wire           [LANE*4*32-1: 0]                 ant_data_even           ;
wire           [LANE*4*32-1: 0]                 ant_data_odd            ;

wire           [BEAM-1:0][2*OW-1: 0]            beams_sum_even          ;
wire           [BEAM-1:0][2*OW-1: 0]            beams_sum_odd           ;
wire           [BEAM-1:0][2*OW-1: 0]            beams_sum_ants          ;
wire                                            beams_tvalid            ;
reg                                             sym1_done             =0;



generate for(gi=0;gi<LANE;gi=gi+1) begin:gen_rxdata_unpack
    // Instantiate the Unit Under Test (UUT)
    cpri_rxdata_unpack                                      cpri_rxdata_unpack_4ant
    (
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_cpri_rx_data                                     (i_cpri_rx_data         ),
        .i_cpri_rx_seq                                      (i_cpri_rx_seq          ),
        .i_cpri_rx_vld                                      (i_cpri_rx_vld          ),
        .i_sym1_done                                        (sym1_done              ),
        .o_iq_addr                                          (unpack_iq_addr[gi]     ),
        .o_iq_data                                          (unpack_iq_data[gi]     ),
        .o_iq_vld                                           (unpack_iq_vld [gi]     ),
        .o_iq_last                                          (unpack_iq_last[gi]     ) 
    );

    ant_data_buffer #(
        .ANT                                                (4                      ),
        .WDATA_WIDTH                                        (128                    ),
        .WADDR_WIDTH                                        (11                     ),
        .RDATA_WIDTH                                        (128                    ),
        .RADDR_WIDTH                                        (11                     ),
        .READ_LATENCY                                       (3                      ),
        .FIFO_DEPTH                                         (16                     ),
        .FIFO_WIDTH                                         (1                      ),
        .LOOP_WIDTH                                         (12                     ),
        .INFO_WIDTH                                         (1                      ),
        .RAM_TYPE                                           (1                      ) 
    )ant_data_buffer(
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_iq_addr                                          (unpack_iq_addr[gi]     ),
        .i_iq_data                                          (unpack_iq_data[gi]     ),
        .i_iq_vld                                           (unpack_iq_vld [gi]     ),
        .i_iq_last                                          (unpack_iq_last[gi]     ),
        .o_ant_even                                         (ant_even  [gi]         ),
        .o_ant_odd                                          (ant_odd   [gi]         ),
        .o_ant_addr                                         (ant_addr  [gi]         ),
        .o_tvalid                                           (ant_tvalid[gi]         ) 
    );

    assign ant_data_even[gi*4*32 +: 4*32] = ant_even[gi];
    assign ant_data_odd [gi*4*32 +: 4*32] = ant_odd [gi];

end
endgenerate

//------------------------------------------------------------------------------------------
// BEAMS MAC BLOCK
//------------------------------------------------------------------------------------------
mac_beams #(
    .BEAM                                               (BEAM                   ),
    .ANT                                                (ANT                    ),
    .IW                                                 (IW                     ),
    .OW                                                 (OW                     ) 
) dut_mac_beams (
    .i_clk                                              (i_clk                  ),
    .i_ants_data_even                                   (ant_data_even          ),
    .i_ants_data_odd                                    (ant_data_odd           ),
    .i_rvalid                                           (ant_tvalid[0]          ),
    .i_code_word_even                                   (i_code_word_even       ),
    .i_code_word_odd                                    (i_code_word_odd        ),
    .o_sum_data_even                                    (beams_sum_even         ),
    .o_sum_data_odd                                     (beams_sum_odd          ),
    .o_sum_data                                         (beams_sum_ants         ),
    .o_tvalid                                           (beams_tvalid           ) 
);


assign o_ant_even = ant_data_even ;
assign o_ant_odd  = ant_data_odd  ;
assign o_ant_addr = ant_addr[0]   ;
assign o_tvalid   = ant_tvalid[0] ;

//------------------------------------------------------------------------------------------
// beams process counter
//------------------------------------------------------------------------------------------
reg                                             beams_tvalid_r        =0;
reg                                             beams_tvld_pos        =0;
reg                                             beams_tvld_neg        =0;
reg            [   7: 0]                        beams_blk_num         =0;

always @ (posedge i_clk) begin
    beams_tvalid_r <= beams_tvalid;

    if(beams_tvalid & (~beams_tvalid_r))
        beams_tvld_pos <= 1'b1;
    else
        beams_tvld_pos <= 1'b0;

    if(~beams_tvalid & (beams_tvalid_r))
        beams_tvld_neg <= 1'b1;
    else
        beams_tvld_neg <= 1'b0;

end

always @ (posedge i_clk) begin
    if(i_reset)
        beams_blk_num <= 0;
    else if(beams_tvld_neg)
        beams_blk_num <= beams_blk_num + 1;
end

always @ (posedge i_clk) begin
    if(i_reset)
        sym1_done <= 0;
    else if(beams_blk_num==3 && beams_tvld_neg)
        sym1_done <= 1;
end



//------------------------------------------------------------------------------------------
// rbG sum 
//------------------------------------------------------------------------------------------
reg            [  15: 0]                        re_num_per_rbg        =0;
reg            [  15: 0]                        re_num                =0;
reg            [   7: 0]                        rbg_num               =0;
reg            [BEAM-1:0][OW-1: 0]              rbg_acc_re            ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_acc_im            ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_sum_re            ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_sum_im            ='{default:0};



always @ (posedge i_clk) begin
    case(i_rbg_size)
        2'b00:   re_num_per_rbg <= 'd48;
        2'b01:   re_num_per_rbg <= 'd96;  
        2'b10:   re_num_per_rbg <= 'd192;
        default: re_num_per_rbg <= 'd48;
    endcase
end


always @ (posedge i_clk)begin
    if(re_num == re_num_per_rbg-1)
        re_num <= 'd0;
    else if(beams_tvalid_r)
        re_num <= re_num + 1'b1;
end

assign rbg_slip = (re_num==re_num_per_rbg-1) ? 1'b1 : 1'b0;
assign rbg_load = (re_num==0) ? 1'b1 : 1'b0;

always @ (posedge i_clk)begin
    if(beams_tvalid_r==0)
        rbg_num <= 'd0;
    else if(rbg_slip)
        rbg_num <= rbg_num + 'd1;
end



generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_acc
    always @(posedge i_clk) begin
        if(beams_tvalid_r==0)
            rbg_acc_re[gi] <= 'd0;
        else if(rbg_load)
            rbg_acc_re[gi] <= signed'(beams_sum_ants[gi][2*OW-1:OW]);
        else
            rbg_acc_re[gi] <= signed'(rbg_acc_re[gi]) + signed'(beams_sum_ants[gi][2*OW-1:OW]);
    end

    always @(posedge i_clk) begin
        if(beams_tvalid_r==0)
            rbg_acc_im[gi] <= 'd0;
        else if(rbg_load)
            rbg_acc_im[gi] <= signed'(beams_sum_ants[gi][OW-1:0]);
        else
            rbg_acc_im[gi] <= signed'(rbg_acc_im[gi]) + signed'(beams_sum_ants[gi][OW-1:0]);
    end
end
endgenerate

generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum
    always @(posedge i_clk) begin
        if((beams_tvalid_r && rbg_load) || beams_tvld_neg)begin
            rbg_sum_re[gi] <= rbg_acc_re[gi];
            rbg_sum_im[gi] <= rbg_acc_im[gi];
        end
    end
end
endgenerate

//------------------------------------------------------------------------------------------
// abs
//------------------------------------------------------------------------------------------

reg            [BEAM-1:0][OW-1: 0]              rbg_sum_re_abs        ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_sum_im_abs        ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_sum_abs           ='{default:0};



generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum_abs_re
    always @(posedge i_clk) begin
        if(rbg_sum_re[gi][OW-1] == 1'b0)
            rbg_sum_re_abs[gi] <= rbg_sum_re[gi];
        else
            rbg_sum_re_abs[gi] <= ~rbg_sum_re[gi] + 'd1;
    end
end
endgenerate

generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum_abs_im
    always @(posedge i_clk) begin
        if(rbg_sum_im[gi][OW-1] == 1'b0)
            rbg_sum_im_abs[gi] <= rbg_sum_im[gi];
        else
            rbg_sum_im_abs[gi] <= ~rbg_sum_im[gi] + 'd1;
    end
end
endgenerate


//------------------------------------------------------------------------------------------
// abs sum 
//------------------------------------------------------------------------------------------
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum_abs
    always @(posedge i_clk) begin
        rbg_sum_abs[gi] <= rbg_sum_re_abs[gi] + rbg_sum_im_abs[gi];
    end
end
endgenerate



endmodule