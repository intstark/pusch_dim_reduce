//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/07/25 15:54:23
// Design Name: 
// Module Name: mac_beams
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

module mac_beams #(
    parameter   BEAM =   16,     // number of data streams
    parameter   ANT  =   32,     // number of data streams
    parameter   IW   =   32,     // number of data streams
    parameter   OW   =   48      // output width
)(
    input                                           i_clk                   ,

    input          [ANT*IW-1: 0]                    i_ants_data_even        ,
    input          [ANT*IW-1: 0]                    i_ants_data_odd         ,
    input                                           i_rvalid                ,
    input                                           i_sop                   ,
    input                                           i_eop                   ,

    input          [ANT*IW-1: 0]          i_code_word_even[BEAM-1:0]        ,
    input          [ANT*IW-1: 0]          i_code_word_odd [BEAM-1:0]        ,

    // debug
    output         [BEAM-1:0][OW-1: 0]              o_data_even_i           ,
    output         [BEAM-1:0][OW-1: 0]              o_data_even_q           ,
    output         [BEAM-1:0][OW-1: 0]              o_data_odd_i            ,
    output         [BEAM-1:0][OW-1: 0]              o_data_odd_q            ,

    // output
    output         [BEAM-1:0][OW-1: 0]              o_data_i                ,
    output         [BEAM-1:0][OW-1: 0]              o_data_q                ,
    output                                          o_sop                   , 
    output                                          o_eop                   , 
    output                                          o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
genvar bi;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
reg            [BEAM-1:0][ANT*IW-1: 0]          code_word_even        ='{default:0};
reg            [BEAM-1:0][ANT*IW-1: 0]          code_word_odd         ='{default:0};

wire           [BEAM-1:0][OW-1: 0]              even_ants_re            ;
wire           [BEAM-1:0][OW-1: 0]              even_ants_im            ;
wire           [BEAM-1:0][OW-1: 0]              odd_ants_re             ;
wire           [BEAM-1:0][OW-1: 0]              odd_ants_im             ;

reg            [BEAM-1:0][OW-1: 0]              ants_sum_re           =0;
reg            [BEAM-1:0][OW-1: 0]              ants_sum_im           =0;

reg            [BEAM-1:0][OW-1: 0]              ants_even_re          =0;
reg            [BEAM-1:0][OW-1: 0]              ants_even_im          =0;
reg            [BEAM-1:0][OW-1: 0]              ants_odd_re           =0;
reg            [BEAM-1:0][OW-1: 0]              ants_odd_im           =0;

wire           [BEAM-1: 0]                      even_tvalid             ;
wire           [BEAM-1: 0]                      odd_tvalid              ;
wire           [BEAM-1: 0]                      even_sop                ;
wire           [BEAM-1: 0]                      even_eop                ;
wire           [BEAM-1: 0]                      odd_sop                 ;
wire           [BEAM-1: 0]                      odd_eop                 ;
reg            [   7: 0]                        tvalid_buf            =0;
reg                                             eop_out               =0;
reg                                             sop_out               =0;

//-----------------------------------------------------------------
//  input register
//-----------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:data_re_pipe
        code_word_even[k] <= i_code_word_even[k];
        code_word_odd [k] <= i_code_word_odd [k];
    end   
end

//--------------------------------------------------------------------------------------
// EVEN ANTS of 16 Beams 
//--------------------------------------------------------------------------------------
generate for(bi=0; bi<BEAM; bi++) begin : even_ants_of_16beams
    // Instantiate the DUT
    mac_ants #(
        .ANT                                                (ANT                    ),
        .IW                                                 (IW                     ),
        .OW                                                 (OW                     ) 
    ) mac_ants_even (
        .i_clk                                              (i_clk                  ),
        .i_ants_data                                        (i_ants_data_even       ),
        .i_rvalid                                           (i_rvalid               ),
        .i_sop                                              (i_sop                  ),
        .i_eop                                              (i_eop                  ),
        .i_code_word                                        (i_code_word_even[bi]   ),
        .o_data_i                                           (even_ants_re    [bi]   ),
        .o_data_q                                           (even_ants_im    [bi]   ),
        .o_sop                                              (even_sop        [bi]   ), 
        .o_eop                                              (even_eop        [bi]   ), 
        .o_tvalid                                           (even_tvalid     [bi]   ) 
    );
end
endgenerate

//--------------------------------------------------------------------------------------
// ODD ANTS of 16 Beams 
//--------------------------------------------------------------------------------------
generate for(bi=0; bi<BEAM; bi++) begin : odd_ants_of_16beams
    // Instantiate the DUT
    mac_ants #(
        .ANT                                                (ANT                    ),
        .IW                                                 (IW                     ),
        .OW                                                 (OW                     ) 
    ) mac_ants_odd (
        .i_clk                                              (i_clk                  ),
        .i_ants_data                                        (i_ants_data_odd        ),
        .i_rvalid                                           (i_rvalid               ),
        .i_sop                                              (i_sop                  ),
        .i_eop                                              (i_eop                  ),
        .i_code_word                                        (i_code_word_odd[bi]    ),
        .o_data_i                                           (odd_ants_re    [bi]    ),
        .o_data_q                                           (odd_ants_im    [bi]    ),
        .o_sop                                              (odd_sop        [bi]    ), 
        .o_eop                                              (odd_eop        [bi]    ), 
        .o_tvalid                                           (odd_tvalid     [bi]    ) 
    );
end
endgenerate



//--------------------------------------------------------------------------------------
// EVEN + ODD ANTS REAL PART
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:even_odd_real
        ants_sum_re[k] <= signed'(even_ants_re[k][OW-1:0]) + signed'(odd_ants_re[k][OW-1:0]);
    end   
end


//--------------------------------------------------------------------------------------
// EVEN + ODD ANTS IMAG PART
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:even_odd_imag
        ants_sum_im[k] <= signed'(even_ants_im[k][OW-1:0]) + signed'(odd_ants_im[k][OW-1:0]);
    end   
end


//--------------------------------------------------------------------------------------
// OUTPUT 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:output_even_sum
        ants_even_re[k] <= even_ants_re[k];
        ants_even_im[k] <= even_ants_im[k];
    end
end

always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:output_odd_sum
        ants_odd_re[k] <= odd_ants_re[k];
        ants_odd_im[k] <= odd_ants_im[k];
    end
end

always @(posedge i_clk) begin
    tvalid_buf <= {tvalid_buf[6:0], even_tvalid[0]};
    sop_out <= even_sop[0];
    eop_out <= even_eop[0];
end


assign o_data_even_i    = ants_even_re;
assign o_data_even_q    = ants_even_im;
assign o_data_odd_i     = ants_odd_re ;
assign o_data_odd_q     = ants_odd_im ;
assign o_data_i         = ants_sum_re ;
assign o_data_q         = ants_sum_im ;
assign o_tvalid         = tvalid_buf[0];
assign o_sop            = sop_out;
assign o_eop            = eop_out;


endmodule
