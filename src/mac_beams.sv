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
    input                                             i_clk                    ,

    input          [ANT*IW-1: 0]                      i_ants_data_even         ,
    input          [ANT*IW-1: 0]                      i_ants_data_odd          ,
    input                                             i_rvalid                 ,

    input          [BEAM-1:0][ANT*IW-1: 0]            i_code_word_even         ,
    input          [BEAM-1:0][ANT*IW-1: 0]            i_code_word_odd          ,

    output         [BEAM-1:0][2*OW-1: 0]              o_sum_data_even          ,
    output         [BEAM-1:0][2*OW-1: 0]              o_sum_data_odd           ,
    output         [BEAM-1:0][2*OW-1: 0]              o_sum_data               ,   
    output                                            o_tvalid                
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
wire           [BEAM-1:0][2*OW-1: 0]            even_sum_data           ;
wire           [BEAM-1:0][2*OW-1: 0]            odd_sum_data            ;
reg            [BEAM-1:0][OW-1: 0]              ants_sum_re             ;
reg            [BEAM-1:0][OW-1: 0]              ants_sum_im             ;
reg            [BEAM-1:0][2*OW-1: 0]            ants_sum_even           ;
reg            [BEAM-1:0][2*OW-1: 0]            ants_sum_odd            ;
reg            [BEAM-1:0][2*OW-1: 0]            ants_sum                ;
wire           [BEAM-1: 0]                      even_tvalid             ;
wire           [BEAM-1: 0]                      odd_tvalid              ;
reg            [   7: 0]                        tvalid_buf            =0;


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
        .i_code_word                                        (code_word_even[bi]     ),
        .o_sum_data                                         (even_sum_data [bi]     ),
        .o_tvalid                                           (even_tvalid   [bi]     ) 
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
        .i_code_word                                        (code_word_odd[bi]      ),
        .o_sum_data                                         (odd_sum_data [bi]      ),
        .o_tvalid                                           (odd_tvalid   [bi]      ) 
    );
end
endgenerate



//--------------------------------------------------------------------------------------
// EVEN + ODD ANTS REAL PART
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:even_odd_real
        ants_sum_re[k] <= signed'(even_sum_data[k][2*OW-1:OW]) + signed'(odd_sum_data[k][2*OW-1:OW]);
    end   
end


//--------------------------------------------------------------------------------------
// EVEN + ODD ANTS IMAG PART
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:even_odd_imag
        ants_sum_im[k] <= signed'(even_sum_data[k][OW-1:0]) + signed'(odd_sum_data[k][OW-1:0]);
    end   
end


//--------------------------------------------------------------------------------------
// OUTPUT 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:output_even_sum
        ants_sum_even[k] <= even_sum_data[k];
    end
end

always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:output_odd_sum
        ants_sum_odd[k] <= odd_sum_data[k];
    end
end

always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:output_sum_data
        ants_sum[k] <= {ants_sum_re[k], ants_sum_im[k]};
    end
end

always @(posedge i_clk) begin
    tvalid_buf <= {tvalid_buf[6:0], even_tvalid[0]};
end

assign o_sum_data_even = ants_sum_even;
assign o_sum_data_odd  = ants_sum_odd;
assign o_sum_data      = ants_sum;
assign o_tvalid        = tvalid_buf[0];


endmodule
