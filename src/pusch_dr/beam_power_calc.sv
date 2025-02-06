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
    input                                           i_clk                   ,// data clock
    input                                           i_reset                 ,// reset

    input                                           i_aiu_idx               ,
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
    output                                          o_data_wen              ,               
    output                                          o_symb_clr              ,               
    output                                          o_symb_1st               

);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
genvar gi;
reg            [   1: 0]                        symb_clr_dly          =0;
reg            [   1: 0]                        symb_1st_dly          =0;



//------------------------------------------------------------------------------------------
// delay symb_clr and symb_1st
//------------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    symb_clr_dly <= {symb_clr_dly[0], i_symb_clr};
    symb_1st_dly <= {symb_1st_dly[0], i_symb_1st};
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
assign rbg_acc_tlast = beam_tlast_buf[2];   // 3 clock cycle delay

//------------------------------------------------------------------------------------------
// rbG sum 
//------------------------------------------------------------------------------------------
reg            [BEAM-1:0][OW-1: 0]              rbg_acc_re            ='{default:0};
reg            [BEAM-1:0][OW-1: 0]              rbg_sum_abs           ='{default:0};
reg            [15:0][7: 0]                     re_num_dly            ='{default:0};
reg            [15:0][7: 0]                     rbg_num_dly           ='{default:0};
reg            [  15: 0]                        rbg_load_dly          =0;
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
    rbg_load_dly    <= {rbg_load_dly[14:0], i_rbg_load};

    for(int i=0; i<15; i++) begin
        re_num_dly[i+1] <= re_num_dly[i];
        rbg_num_dly[i+1] <= rbg_num_dly[i];
    end
end

assign re_num_acc   = re_num_dly  [1];
assign rbg_num_acc  = rbg_num_dly [1];
assign rbg_load_acc = rbg_load_dly[1];


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


reg            [ 192: 0]                        rbg_sum_load_obuf     =0;
reg            [ 192: 0]                        rbg_sum_vld_obuf      =0;
reg            [ 192: 0]                        symb_1st_dly_obuf     =0;
wire           [   7: 0]                        dly_num                 ;
reg                                             rbg_sum_load_out      =0;
reg                                             rbg_sum_vld_out       =0;
reg                                             symb_1st_out          =0;
reg                                             symb_1st              =0;

assign dly_num = (i_aiu_idx) ? 8'd192 : 8'd48;

always @(posedge i_clk) begin
    if(i_reset)begin
        rbg_sum_load_obuf <= 'd0;
        rbg_sum_vld_obuf  <= 'd0;
        symb_1st_dly_obuf <= 'd0;
    end else begin
        rbg_sum_load_obuf <= {rbg_sum_load_obuf[191:0], rbg_load_acc & iq_abs_vld};
        rbg_sum_vld_obuf  <= {rbg_sum_vld_obuf [191:0], iq_abs_vld};
        symb_1st_dly_obuf <= {symb_1st_dly_obuf[191:0], symb_1st_dly[1]};
    end
end

always @(posedge i_clk) begin
    rbg_sum_load_out <= rbg_sum_load_obuf[dly_num];
    rbg_sum_vld_out  <= rbg_sum_vld_obuf [dly_num];
    symb_1st_out     <= symb_1st_dly_obuf[dly_num];
end

always @ (posedge i_clk) begin
    if(rbg_sum_vld_out)
        rbg_sum_wen <= rbg_store_en[1];
    else 
        rbg_sum_wen <= 0;
    rbg_sum_vld  <= rbg_sum_vld_out;
    rbg_sum_load <= rbg_sum_load_out;
    symb_1st     <= symb_1st_out;
end

always @ (posedge i_clk) begin
    if(i_data_sop)
        rbg_abs_addr <= 8'd0;
    else if(!rbg_sum_vld)
        rbg_abs_addr <= 8'd0;
    else if(rbg_sum_wen)
        rbg_abs_addr <= rbg_abs_addr + 8'd1;
end



assign o_data_sum  = rbg_sum_abs;
assign o_data_addr = rbg_abs_addr;
assign o_data_vld  = rbg_sum_vld;
assign o_data_load = rbg_sum_load;
assign o_data_wen  = rbg_sum_wen;
assign o_symb_1st  = symb_1st;

endmodule