//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: beam_power_calc 
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
module beam_power_calc # (
    parameter                                       BEAM                   = 16    ,
    parameter                                       IW                     = 40    ,
    parameter                                       OW                     = 40    
)(
    input                                           i_clk                   ,   // data clock
    input                                           i_reset                 ,   // reset

    input          [   1: 0]                        i_rbg_size              ,   // default:2'b10 16rb
    input                                           i_symb_clr              ,
    input                                           i_symb_1st              ,

    // cpri rxdata
    input          [BEAM-1:0][IW-1: 0]              i_data_re               ,// 4 ants iq addr
    input          [BEAM-1:0][IW-1: 0]              i_data_im               ,// 4 ants iq data
    input                                           i_data_vld              ,
    input                                           i_data_eop              ,
    input                                           i_data_sop              ,

    input          [   7: 0]                        i_re_num                ,
    input          [   7: 0]                        i_rbg_num               ,
    input                                           i_rbg_load              ,


    // output power
    output         [BEAM-1:0][OW-1: 0]              o_data_sum              ,
    output         [   7: 0]                        o_data_addr             ,
    output                                          o_data_vld              ,
    output                                          o_data_load             ,
    output                                          o_data_wen               

);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
genvar gi;
reg            [   5: 0]                        symb_clr_dly          =0;
reg            [   5: 0]                        symb_1st_dly          =0;



//------------------------------------------------------------------------------------------
// delay symb_clr and symb_1st
//------------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    symb_clr_dly <= {symb_clr_dly[4:0], i_symb_clr};
    symb_1st_dly <= {symb_1st_dly[4:0], i_symb_1st};
end

//------------------------------------------------------------------------------------------
// ABS |I|+|Q|: 2 clock cycle
//------------------------------------------------------------------------------------------
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_sft_i        ;
wire     signed[BEAM-1:0][OW-1: 0]              beams_ants_sft_q        ;
reg            [BEAM-1:0][OW-1: 0]              beams_ants_abs_iq     =0;
reg            [BEAM-1:0][OW-1: 0]              beams_ants_abs_i      =0;
reg            [BEAM-1:0][OW-1: 0]              beams_ants_abs_q      =0;
reg            [   4: 0]                        beam_tvalid_buf       =0;
reg            [   2: 0]                        beam_tlast_buf        =0;
wire                                            iq_abs_vld              ;
wire                                            rbg_acc_valid           ;
wire                                            rbg_acc_tlast           ;

// right shift 6 bits SQ(40,21)
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_shift
    assign beams_ants_sft_i[gi] = signed'(i_data_re[gi])>>>8;
    assign beams_ants_sft_q[gi] = signed'(i_data_im[gi])>>>8;
end
endgenerate

// real part abs
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_abs_re
    always @(posedge i_clk) begin
        if(beams_ants_sft_i[gi][OW-1] == 1'b0)
            beams_ants_abs_i[gi] <= beams_ants_sft_i[gi];
        else
            beams_ants_abs_i[gi] <= ~beams_ants_sft_i[gi] + 'd1;
    end
end
endgenerate

// imaginary part abs
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_abs_im
    always @(posedge i_clk) begin
        if(beams_ants_sft_q[gi][OW-1] == 1'b0)
            beams_ants_abs_q[gi] <= beams_ants_sft_q[gi];
        else
            beams_ants_abs_q[gi] <= ~beams_ants_sft_q[gi] + 'd1;
    end
end
endgenerate

// |real| + |imaginary|
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_sum_re_im
    always @(posedge i_clk) begin
        beams_ants_abs_iq[gi] <= beams_ants_abs_i[gi] + beams_ants_abs_q[gi];
    end
end
endgenerate

// delay valid
always @(posedge i_clk) begin
    beam_tvalid_buf <= {beam_tvalid_buf[3:0], i_data_vld};
    beam_tlast_buf <= {beam_tlast_buf[1:0], i_data_eop};
end

assign iq_abs_vld    = beam_tvalid_buf[1] && symb_1st_dly[1];   // 2 clock cycle delay
assign rbg_acc_valid = beam_tvalid_buf[4];  // 4 clock cycle delay
assign rbg_acc_tlast = beam_tlast_buf[2];  // 4 clock cycle delay

//------------------------------------------------------------------------------------------
// rbG sum 
//------------------------------------------------------------------------------------------
reg            [BEAM-1:0][OW-1: 0]              rbg_acc_re            ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_sum_abs           ='{default:0};
reg            [14:0][7: 0]                     re_num_dly            ='{default:0};
reg            [14:0][7: 0]                     rbg_num_dly           ='{default:0};
reg            [  14: 0]                        rbg_load_dly          =0;
wire           [   7: 0]                        rbg_num_acc             ;
wire           [   7: 0]                        re_num_acc              ;
wire                                            rbg_load_acc            ;

reg                                             rbg_sum_load          =0;
wire                                            rbg_sum_load_lp         ;
wire                                            rbg_sum_vld_lp          ;
reg                                             rbg_sum_wen           =0;
reg                                             rbg_sum_vld           =0;
reg            [   7: 0]                        rbg_abs_addr          =0;
reg            [   2: 0]                        rbg_store_en          =0;


always @ (posedge i_clk)begin
    re_num_dly[0]   <= i_re_num;
    rbg_num_dly[0]  <= i_rbg_num;
    rbg_load_dly    <= {rbg_load_dly[13:0], i_rbg_load};

    for(int i=0; i<14; i++) begin
        re_num_dly[i+1] <= re_num_dly[i];
        rbg_num_dly[i+1] <= rbg_num_dly[i];
    end
end

assign re_num_acc   = re_num_dly  [14];
assign rbg_num_acc  = rbg_num_dly [14];
assign rbg_load_acc = rbg_load_dly[14];


// re accumulator
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_acc
    always @(posedge i_clk) begin
        if(iq_abs_vld==0)
            rbg_acc_re[gi] <= 'd0;
        else if(rbg_load_acc)
            rbg_acc_re[gi] <= signed'(beams_ants_abs_iq[gi]);
        else
            rbg_acc_re[gi] <= signed'(rbg_acc_re[gi]) + signed'(beams_ants_abs_iq[gi]);
    end
end
endgenerate

// store sum when rbG ends
generate for(gi=0;gi<BEAM;gi=gi+1) begin:gen_rbg_sum
    always @(posedge i_clk) begin
        if(rbg_load_acc || rbg_acc_tlast) begin
            rbg_sum_abs[gi] <= rbg_acc_re[gi];
        end
    end

end
endgenerate

always @(posedge i_clk) begin
    rbg_store_en <= {rbg_store_en[1:0], rbg_load_acc || rbg_acc_tlast};
end


lp_buffer_syn # (
    .DATA_WIDTH                                         (2                                  ),
    .ADDR_WIDTH                                         (8                                  ) 
)lp_buffer_0(
    .i_clk                                              (i_clk                              ),
    .i_reset                                            (i_reset                            ),
    .i_wr_data                                          ({rbg_load_acc,iq_abs_vld}          ),
    .i_wr_wen                                           (rbg_load_acc                       ),
    .i_wr_vld                                           (iq_abs_vld                         ),
    .o_rd_data                                          ({rbg_sum_load_lp,rbg_sum_vld_lp}   ),
    .o_rd_vld                                           (                                   ),
    .o_rd_sop                                           (                                   ) 
);

always @ (posedge i_clk) begin
    if(rbg_sum_vld_lp)
        rbg_sum_wen <= rbg_store_en[1];
    else 
        rbg_sum_wen <= 0;
    rbg_sum_vld  <= rbg_sum_vld_lp;
    rbg_sum_load <= rbg_sum_load_lp;
end

always @ (posedge i_clk) begin
    if(i_data_sop)
        rbg_abs_addr <= 8'd0;
    else if(rbg_sum_vld && rbg_sum_wen)
        rbg_abs_addr <= rbg_abs_addr + 8'd1;
end



assign o_data_sum  = rbg_sum_abs;
assign o_data_addr = rbg_abs_addr;
assign o_data_vld  = rbg_sum_vld;
assign o_data_load = rbg_sum_load;
assign o_data_wen  = rbg_sum_wen;

endmodule