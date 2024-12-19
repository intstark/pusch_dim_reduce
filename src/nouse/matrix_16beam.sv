//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/02/28 15:54:23
// Design Name: 
// Module Name: mac8x8
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

module matrix_16beam #(
    parameter ANT = 32,  // number of data streams
    parameter IW  = 32,  // number of data streams
    parameter OW  = 26  // output width
)(
    input                                   i_clk                              ,

    input          [ANT*IW-1: 0]            i_ant_data                         ,
    input                                   i_rvalid                           ,

    input          [ANT*IW-1: 0]            i_code_word_b0                     ,
    input          [ANT*IW-1: 0]            i_code_word_b1                     ,
    input          [ANT*IW-1: 0]            i_code_word_b2                     ,
    input          [ANT*IW-1: 0]            i_code_word_b3                     ,
    input          [ANT*IW-1: 0]            i_code_word_b4                     ,
    input          [ANT*IW-1: 0]            i_code_word_b5                     ,
    input          [ANT*IW-1: 0]            i_code_word_b6                     ,
    input          [ANT*IW-1: 0]            i_code_word_b7                     ,
    input          [ANT*IW-1: 0]            i_code_word_b8                     ,
    input          [ANT*IW-1: 0]            i_code_word_b9                     ,
    input          [ANT*IW-1: 0]            i_code_word_b10                    ,
    input          [ANT*IW-1: 0]            i_code_word_b11                    ,
    input          [ANT*IW-1: 0]            i_code_word_b12                    ,
    input          [ANT*IW-1: 0]            i_code_word_b13                    ,
    input          [ANT*IW-1: 0]            i_code_word_b14                    ,
    input          [ANT*IW-1: 0]            i_code_word_b15                    ,

    output         [OW-1: 0]                o_sum_b0                           ,
    output         [OW-1: 0]                o_sum_b1                           ,
    output         [OW-1: 0]                o_sum_b2                           ,
    output         [OW-1: 0]                o_sum_b3                           ,
    output         [OW-1: 0]                o_sum_b4                           ,
    output         [OW-1: 0]                o_sum_b5                           ,
    output         [OW-1: 0]                o_sum_b6                           ,
    output         [OW-1: 0]                o_sum_b7                           ,
    output         [OW-1: 0]                o_sum_b8                           ,
    output         [OW-1: 0]                o_sum_b9                           ,
    output         [OW-1: 0]                o_sum_b10                          ,
    output         [OW-1: 0]                o_sum_b11                          ,
    output         [OW-1: 0]                o_sum_b12                          ,
    output         [OW-1: 0]                o_sum_b13                          ,
    output         [OW-1: 0]                o_sum_b14                          ,
    output         [OW-1: 0]                o_sum_b15                           


);

localparam BEAM = 16;


reg [IW-1:0] ant_data [0:ANT-1] = '{default:0};
reg [IW-1:0] code_word [0:BEAM-1][0:ANT-1] = '{default:0};


//-----------------------------------------------------------------
//  input register
//-----------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        ant_data[k] <= i_ant_data[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[0][k] <= i_code_word_b0[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[1][k] <= i_code_word_b1[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[2][k] <= i_code_word_b2[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[3][k] <= i_code_word_b3[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[4][k] <= i_code_word_b4[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[5][k] <= i_code_word_b5[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[6][k] <= i_code_word_b6[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[7][k] <= i_code_word_b7[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[8][k] <= i_code_word_b8[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[9][k] <= i_code_word_b9[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[10][k] <= i_code_word_b10[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[11][k] <= i_code_word_b11[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[12][k] <= i_code_word_b12[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[13][k] <= i_code_word_b13[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[14][k] <= i_code_word_b14[IW*k +: IW];
    end   
end

always @(posedge i_clk) begin
    for(int k=0; k<ANT; k=k+1)begin:data_re_pipe
        code_word[15][k] <= i_code_word_b15[IW*k +: IW];
    end   
end




//-----------------------------------------------------------------
//  complex mult 
//-----------------------------------------------------------------
generate for(gi=0; gi<ANT; gi++)
begin:u_cmpy_mult
    cmpy_mult           cmpy_mult_mac
    (
        .clock          (i_clk),        //   input,   width = 1,       clock.clk

        .dataa_real     (ant_data[gi][31:16]),  //   input,   width = 8,  dataa_real.dataa_real
        .dataa_imag     (ant_data[gi][15: 0]),  //   input,   width = 8,  dataa_imag.dataa_imag
        .datab_real     (code_word[0][gi][31:16]),  //   input,  width = 16,  datab_real.datab_real
        .datab_imag     (code_word[0][gi][15: 0]),  //   input,  width = 16,  datab_imag.datab_imag
        .result_real    (mult_re[0][gi]),  //  output,  width = 24, result_real.result_real
        .result_imag    (mult_im[0][gi])   //  output,  width = 24, result_imag.result_imag
    );
end
endgenerate










endmodule