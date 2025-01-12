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
// Description: 14 Clocks latency
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

    input                                           i_rvalid                ,
    input                                           i_sop                   ,
    input                                           i_eop                   ,
    input                                           i_symb_clr              ,
    input                                           i_symb_1st              ,

    input          [ANT*IW-1: 0]                    i_ants_data_even        ,
    input          [ANT*IW-1: 0]                    i_ants_data_odd         ,
    input          [BEAM-1:0][ANT*IW-1: 0]          i_code_word_even        ,
    input          [BEAM-1:0][ANT*IW-1: 0]          i_code_word_odd         ,
    
    // input header info
    input          [  63: 0]                        i_info_0                ,// IQ HD 
    input          [  15: 0]                        i_info_1                ,// FFT AGC{odd,even}

    input          [   7: 0]                        i_re_num                ,
    input          [   7: 0]                        i_rbg_num               ,
    input                                           i_rbg_load              ,

    // output header info
    output         [  63: 0]                        o_info_0                ,// IQ HD 
    output         [  15: 0]                        o_info_1                ,// FFT AGC{odd,even}

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
    output                                          o_tvalid                ,

    output         [   7: 0]                        o_re_num                ,
    output         [   7: 0]                        o_rbg_num               ,
    output                                          o_rbg_load              ,

    output                                          o_symb_clr              ,
    output                                          o_symb_1st               
);

//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
genvar bi;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
reg            [   2: 0]                        rvalid                =0;
reg            [   2: 0]                        sop                   =0;
reg            [   2: 0]                        eop                   =0;

reg            [ANT*IW-1: 0]                    r1_ants_data_even     =0;
reg            [ANT*IW-1: 0]                    r1_ants_data_odd      =0;

reg            [ANT*IW-1: 0]                    r2_ants_data_even     =0;
reg            [ANT*IW-1: 0]                    r2_ants_data_odd      =0;

reg            [ANT*IW-1: 0]                    ants_data_even        =0;
reg            [ANT*IW-1: 0]                    ants_data_odd         =0;

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
reg            [   1: 0]                        tvld_out              =0;
reg            [   1: 0]                        eop_out               =0;
reg            [   1: 0]                        sop_out               =0;

//-----------------------------------------------------------------
//  input register: 2 Clock Latency
//-----------------------------------------------------------------
always @ (posedge i_clk) begin
    rvalid <= {rvalid[1:0], i_rvalid};
    sop    <= {sop   [1:0], i_sop   };
    eop    <= {eop   [1:0], i_eop   };
end

always @(posedge i_clk) begin
    r1_ants_data_even <= i_ants_data_even;       
    r1_ants_data_odd  <= i_ants_data_odd ;

    r2_ants_data_even <= r1_ants_data_even;       
    r2_ants_data_odd  <= r1_ants_data_odd ;
    
    ants_data_even <= r1_ants_data_even;       
    ants_data_odd  <= r1_ants_data_odd ;
end

always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:data_re_pipe
        code_word_even[k] <= i_code_word_even[k];
        code_word_odd [k] <= i_code_word_odd [k];
    end   
end

//--------------------------------------------------------------------------------------
// EVEN ANTS of 16 Beams: 11 Clock Latency 
//--------------------------------------------------------------------------------------
generate for(bi=0; bi<BEAM; bi++) begin : even_ants_of_16beams
    // Instantiate the DUT
    mac_ants #(
        .ANT                                                (ANT                    ),
        .IW                                                 (IW                     ),
        .OW                                                 (OW                     ) 
    ) mac_ants_even (
        .i_clk                                              (i_clk                  ),
        .i_ants_data                                        (ants_data_even         ),
        .i_rvalid                                           (rvalid[1]              ),
        .i_sop                                              (sop   [1]              ),
        .i_eop                                              (eop   [1]              ),
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
// ODD ANTS of 16 Beams: 11 Clock Latency
//--------------------------------------------------------------------------------------
generate for(bi=0; bi<BEAM; bi++) begin : odd_ants_of_16beams
    // Instantiate the DUT
    mac_ants #(
        .ANT                                                (ANT                    ),
        .IW                                                 (IW                     ),
        .OW                                                 (OW                     ) 
    ) mac_ants_odd (
        .i_clk                                              (i_clk                  ),
        .i_ants_data                                        (ants_data_odd          ),
        .i_rvalid                                           (rvalid[1]              ),
        .i_sop                                              (sop   [1]              ),
        .i_eop                                              (eop   [1]              ),
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
// EVEN + ODD ANTS REAL PART: 1 Clock Latency
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:even_odd_real
        ants_sum_re[k] <= signed'(even_ants_re[k][OW-1:0]) + signed'(odd_ants_re[k][OW-1:0]);
    end   
end


//--------------------------------------------------------------------------------------
// EVEN + ODD ANTS IMAG PART: 1 Clock Latency
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int k=0; k<BEAM; k++)begin:even_odd_imag
        ants_sum_im[k] <= signed'(even_ants_im[k][OW-1:0]) + signed'(odd_ants_im[k][OW-1:0]);
    end   
end


//--------------------------------------------------------------------------------------
// OUTPUT: 2+11+1=14 Clock Latency
//--------------------------------------------------------------------------------------
localparam                                      O_LATENCY             =14;

reg            [O_LATENCY-2: 0]                 symb_clr_buf          =0;
reg            [O_LATENCY-2: 0]                 symb_1st_buf          =0;
reg            [63:0]                           dout_info0 [O_LATENCY-1:0] ='{default:0};
reg            [15:0]                           dout_info1 [O_LATENCY-1:0] ='{default:0};
reg            [O_LATENCY-1:0][7: 0]            re_num_dly            =0;
reg            [O_LATENCY-1:0][7: 0]            rbg_num_dly           =0;
reg            [O_LATENCY-1: 0]                 rbg_load_dly          =0;


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

// tvalid latency match
always @(posedge i_clk) begin
    tvld_out  <= {tvld_out[0], even_tvalid[0]};
    sop_out   <= {sop_out[0], even_sop[0]};
    eop_out   <= {eop_out[0], even_eop[0]};
end

// info latency match
always @(posedge i_clk) begin
    dout_info0[0] <= i_info_0;
    dout_info1[0] <= i_info_1;
    for(int i=1; i<O_LATENCY; i++)begin
        dout_info0[i] <= dout_info0[i-1];
        dout_info1[i] <= dout_info1[i-1];
    end
end

// re_num/rbg_num/rbg_load latency match
always @ (posedge i_clk)begin
    re_num_dly[0]   <= i_re_num;
    rbg_num_dly[0]  <= i_rbg_num;
    rbg_load_dly    <= {rbg_load_dly[O_LATENCY-2:0], i_rbg_load};

    for(int i=1; i<O_LATENCY; i++)begin
        re_num_dly [i] <= re_num_dly [i-1];
        rbg_num_dly[i] <= rbg_num_dly[i-1];
    end
end

// symb_clr/symb_1st latency match
always @(posedge i_clk) begin
    symb_1st_buf<= {symb_1st_buf[O_LATENCY-3:0], i_symb_1st};
    symb_clr_buf<= {symb_clr_buf[O_LATENCY-3:0], i_symb_clr};
end

// output assignment
assign o_data_even_i    = ants_even_re;
assign o_data_even_q    = ants_even_im;
assign o_data_odd_i     = ants_odd_re ;
assign o_data_odd_q     = ants_odd_im ;
assign o_data_i         = ants_sum_re ;
assign o_data_q         = ants_sum_im ;
assign o_tvalid         = tvld_out[0];
assign o_sop            = sop_out [0];
assign o_eop            = eop_out [0];

assign o_info_0         = dout_info0  [O_LATENCY-1];
assign o_info_1         = dout_info1  [O_LATENCY-1];
assign o_re_num         = re_num_dly  [O_LATENCY-1];
assign o_rbg_num        = rbg_num_dly [O_LATENCY-1];
assign o_rbg_load       = rbg_load_dly[O_LATENCY-1];

assign o_symb_clr       = symb_clr_buf[O_LATENCY-2];
assign o_symb_1st       = symb_1st_buf[O_LATENCY-2];


endmodule
