//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/07/25 15:54:23
// Design Name: 
// Module Name: mac_ants
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

module mac_ants #(
    parameter   ANT =   32,     // number of data streams
    parameter   IW  =   32,     // number of data streams
    parameter   OW  =   48      // output width
)(
    input                                           i_clk                   ,

    input          [ANT*IW-1: 0]                    i_ants_data             ,
    input                                           i_rvalid                ,

    input          [ANT*IW-1: 0]                    i_code_word             ,

    output         [OW-1: 0]                        o_sum_data              ,
    output                                          o_tvalid                 
);




//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
localparam  MULT_W  =   32;
localparam  MID_W   =   OW;
genvar gi;

//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
reg            [ANT-1:0][IW-1: 0]               ants_data             ='{default:0};
reg            [ANT-1:0][IW-1: 0]               code_word             ='{default:0};
wire           [ANT-1:0][MULT_W-1: 0]           mult_re                 ;
wire           [ANT-1:0][MULT_W-1: 0]           mult_im                 ;
reg            [ANT/2-1:0][MID_W-1: 0]          add0_abs               ='{default:0};
reg            [ANT/4-1:0][MID_W-1: 0]          add1_abs               ='{default:0};
reg            [ANT/8-1:0][MID_W-1: 0]          add2_abs               ='{default:0};
reg            [ANT/16-1:0][MID_W-1: 0]         add3_abs               ='{default:0};
reg            [0:0][MID_W-1: 0]                add4_abs               ='{default:0};
reg            [OW-1: 0]                        dout_abs               ='{default:0};
reg            [   4: 0]                        mult_valid            =0;
reg            [   7: 0]                        tvalid_buf            =0;

reg            [ANT-1:0][MULT_W-1: 0]           mult_re_abs           =0;
reg            [ANT-1:0][MULT_W-1: 0]           mult_im_abs           =0;
reg            [ANT-1:0][MULT_W-1: 0]           mult_abs              =0;



//--------------------------------------------------------------------------------------
//  input register
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        ants_data[k] <= i_ants_data[IW*k +: IW];
    end
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[k] <= i_code_word[IW*k +: IW];
    end
end



//--------------------------------------------------------------------------------------
//  complex mult Latency=4
//--------------------------------------------------------------------------------------
generate for(gi=0; gi<ANT; gi++)
begin:u_cmpy_mult
    cmpy_mult_s16xs16                                       cmpy_mult_mac
    (
        .clock                                              (i_clk                  ),//   input,   width = 1,       clock.clk

        .dataa_real                                         (ants_data[gi][31:16]   ),//   input,   width = 8,  dataa_real.dataa_real
        .dataa_imag                                         (ants_data[gi][15: 0]   ),//   input,   width = 8,  dataa_imag.dataa_imag
        .datab_real                                         (code_word[gi][31:16]   ),//   input,  width = 16,  datab_real.datab_real
        .datab_imag                                         (code_word[gi][15: 0]   ),//   input,  width = 16,  datab_imag.datab_imag
        .result_real                                        (mult_re[gi]            ),//  output,  width = 24, result_real.result_real
        .result_imag                                        (mult_im[gi]            ) //  output,  width = 24, result_imag.result_imag
    );
end
endgenerate

always @(posedge i_clk) begin
    mult_valid[4:0] <= {mult_valid[3:0], i_rvalid};
end



always @(posedge i_clk) begin
    for(int k=0; k<ANT; k++)begin: calc_re_abs
        if(mult_re[k][MULT_W-1] == 1'b0)
            mult_re_abs[k] <= mult_re[k];
        else
            mult_re_abs[k] <= ~mult_re[k] + 'd1;
    end
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k++)begin: calc_im_abs
        if(mult_im[k][MULT_W-1] == 1'b0)
            mult_im_abs[k] <= mult_im[k];
        else
            mult_im_abs[k] <= ~mult_im[k] + 'd1;
    end
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k++)begin: calc_abs
        mult_abs[k] <= signed'(mult_re_abs[k]) + signed'(mult_im_abs[k]);
    end   
end

//--------------------------------------------------------------------------------------
//  ADD Pipeline 0
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/2; k++)begin:add_pipe_0
        add0_abs[k] <= signed'(mult_abs[2*k]) + signed'(mult_abs[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  ADD Pipeline 1
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/4; k++)begin:add_pipe_1
        add1_abs[k] <= signed'(add0_abs[2*k]) + signed'(add0_abs[2*k+1]);
    end   
end


//--------------------------------------------------------------------------------------
//  ADD Pipeline 2
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/8; k++)begin:add_pipe_2
        add2_abs[k] <= signed'(add1_abs[2*k]) + signed'(add1_abs[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  ADD Pipeline 3
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/16; k++)begin:add_pipe_3
        add3_abs[k] <= signed'(add2_abs[2*k]) + signed'(add2_abs[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  ADD Pipeline 4
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/32; k++)begin:add_pipe_4
        add4_abs[k] <= signed'(add3_abs[2*k]) + signed'(add3_abs[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  Ouput 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    dout_abs <= add4_abs[0][MID_W-1:MID_W-OW];
end

always @(posedge i_clk) begin
    tvalid_buf[7:0] <= {tvalid_buf[6:0], mult_valid[4]};
end

// ouput Latency=1+4+6=11
assign o_sum_data   = dout_abs;
assign o_tvalid     = tvalid_buf[7]; 







endmodule