//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/07/25 15:54:23
// Design Name: 
// Module Name: rbg_acc 
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

module rbg_acc #(
    parameter   BEAM =   16,     // number of data streams
    parameter   ANT  =   32,     // number of data streams
    parameter   IW   =   32,     // number of data streams
    parameter   OW   =   48      // output width
)(
    input                                             i_clk                    ,


    input          [BEAM-1:0][IW-1: 0]                i_beam_data              ,


    output         [BEAM-1:0][2*OW-1: 0]              o_rbg_sum                
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
genvar bi;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
reg            [BEAM-1:0][ANT*IW-1: 0]            code_word_even         ='{default:0};
reg            [BEAM-1:0][ANT*IW-1: 0]            code_word_odd          ='{default:0};
wire           [BEAM-1:0][2*OW-1: 0]              even_sum_data            ;
wire           [BEAM-1:0][2*OW-1: 0]              odd_sum_data             ;
reg            [BEAM-1:0][OW-1: 0]                ants_sum_re              ;
reg            [BEAM-1:0][OW-1: 0]                ants_sum_im              ;
reg            [BEAM-1:0][2*OW-1: 0]              ants_sum_even            ;
reg            [BEAM-1:0][2*OW-1: 0]              ants_sum_odd             ;
reg            [BEAM-1:0][2*OW-1: 0]              ants_sum                 ;



//--------------------------------------------------------------------------------------
//  input register
//--------------------------------------------------------------------------------------











//--------------------------------------------------------------------------------------
// EVEN ANTS of 16 Beams 
//--------------------------------------------------------------------------------------


















endmodule
