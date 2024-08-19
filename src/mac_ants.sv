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
    input                                   i_clk                              ,

    input          [ANT*IW-1: 0]            i_ants_data                        ,
    input                                   i_rvalid                           ,

    input          [ANT*IW-1: 0]            i_code_word                        ,

    output         [2*OW-1: 0]              o_sum_data                          
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
reg            [ANT-1:0][IW-1: 0]       ants_data                        ='{default:0} ;
reg            [ANT-1:0][IW-1: 0]       code_word                        ='{default:0} ;
wire           [ANT-1:0][MULT_W-1: 0]   mult_re                                        ;
wire           [ANT-1:0][MULT_W-1: 0]   mult_im                                        ;
reg            [ANT/2-1:0][MID_W-1: 0]  add0_re                          ='{default:0} ;
reg            [ANT/2-1:0][MID_W-1: 0]  add0_im                          ='{default:0} ;
reg            [ANT/4-1:0][MID_W-1: 0]  add1_re                          ='{default:0} ;
reg            [ANT/4-1:0][MID_W-1: 0]  add1_im                          ='{default:0} ;
reg            [ANT/8-1:0][MID_W-1: 0]  add2_re                          ='{default:0} ;
reg            [ANT/8-1:0][MID_W-1: 0]  add2_im                          ='{default:0} ;
reg            [ANT/16-1:0][MID_W-1: 0] add3_re                          ='{default:0} ;
reg            [ANT/16-1:0][MID_W-1: 0] add3_im                          ='{default:0} ;
reg            [0:0][MID_W-1: 0]        add4_re                          ='{default:0} ;
reg            [0:0][MID_W-1: 0]        add4_im                          ='{default:0} ;
reg            [OW-1: 0]                dout_re                          ='{default:0} ;
reg            [OW-1: 0]                dout_im                          ='{default:0} ;

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
//  complex mult 
//--------------------------------------------------------------------------------------
generate for(gi=0; gi<ANT; gi++)
begin:u_cmpy_mult
    cmpy_mult_s16xs16                               cmpy_mult_mac
    (
        .clock                                      (i_clk                             ),//   input,   width = 1,       clock.clk

        .dataa_real                                 (ants_data[gi][31:16]              ),//   input,   width = 8,  dataa_real.dataa_real
        .dataa_imag                                 (ants_data[gi][15: 0]              ),//   input,   width = 8,  dataa_imag.dataa_imag
        .datab_real                                 (code_word[gi][31:16]              ),//   input,  width = 16,  datab_real.datab_real
        .datab_imag                                 (code_word[gi][15: 0]              ),//   input,  width = 16,  datab_imag.datab_imag
        .result_real                                (mult_re[gi]                       ),//  output,  width = 24, result_real.result_real
        .result_imag                                (mult_im[gi]                       ) //  output,  width = 24, result_imag.result_imag
    );
end
endgenerate


//--------------------------------------------------------------------------------------
//  ADD Pipeline 0
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/2; k++)begin:add_pipe_0
        add0_re[k] <= signed'(mult_re[2*k]) + signed'(mult_re[2*k+1]);
        add0_im[k] <= signed'(mult_im[2*k]) + signed'(mult_im[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  ADD Pipeline 1
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/4; k++)begin:add_pipe_1
        add1_re[k] <= signed'(add0_re[2*k]) + signed'(add0_re[2*k+1]);
        add1_im[k] <= signed'(add0_im[2*k]) + signed'(add0_im[2*k+1]);
    end   
end


//--------------------------------------------------------------------------------------
//  ADD Pipeline 2
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/8; k++)begin:add_pipe_2
        add2_re[k] <= signed'(add1_re[2*k]) + signed'(add1_re[2*k+1]);
        add2_im[k] <= signed'(add1_im[2*k]) + signed'(add1_im[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  ADD Pipeline 3
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/16; k++)begin:add_pipe_3
        add3_re[k] <= signed'(add2_re[2*k]) + signed'(add2_re[2*k+1]);
        add3_im[k] <= signed'(add2_im[2*k]) + signed'(add2_im[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  ADD Pipeline 4
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT/32; k++)begin:add_pipe_4
        add4_re[k] <= signed'(add3_re[2*k]) + signed'(add3_re[2*k+1]);
        add4_im[k] <= signed'(add3_im[2*k]) + signed'(add3_im[2*k+1]);
    end   
end

//--------------------------------------------------------------------------------------
//  Ouput 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    dout_re <= add4_re[0][MID_W-1:MID_W-OW];
    dout_im <= add4_im[0][MID_W-1:MID_W-OW];
end


assign o_sum_data={dout_re, dout_im};







endmodule