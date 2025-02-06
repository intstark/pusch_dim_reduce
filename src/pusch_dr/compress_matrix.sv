//-------------------------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-10-17
//File name       :  compress_matrix.sv
//--------------------------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//--------------------------------------------------------------------------------------------

module compress_matrix
#(
	parameter integer IW = 40,
	parameter integer OW = 16
)
(
    input  wire                                     clk                     ,
    input  wire                                     rst                     ,
    input  wire                                     i_sel                   ,
    input  wire                                     i_sop                   ,
    input  wire                                     i_eop                   ,
    input  wire                                     i_vld                   ,
    input  wire    [15:0][IW-1: 0]                  i_din_re                ,
    input  wire    [15:0][IW-1: 0]                  i_din_im                ,

    input  wire                                     i_rbg_load              ,
    input  wire    [15:0][31: 0]                    i_beam_pwr              ,

    input  wire    [  63: 0]                        i_info_0                ,
    input  wire    [15:0][7: 0]                     i_info_1                ,

    output wire                                     o_sel                   ,
    output wire                                     o_sop                   ,
    output wire                                     o_eop                   ,
    output wire                                     o_vld                   ,
    output reg     [15:0][OW-1: 0]                  o_dout_re               ,
    output reg     [15:0][OW-1: 0]                  o_dout_im               ,
    output reg     [   4: 0]                        o_shift                 ,
    output wire                                     o_rbg_load              ,
    output wire    [15:0][31: 0]                    o_beam_pwr              ,

    output wire    [   3: 0]                        o_rbg_idx               ,
    output wire    [   3: 0]                        o_pkg_type              ,
    output wire                                     o_cell_idx              ,
    output wire    [   6: 0]                        o_slot_idx              ,
    output wire    [   3: 0]                        o_symb_idx              ,
    output wire    [15:0][7:0]                      o_fft_agc                   
);


//--------------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------------

localparam DAT_DEPTH = 1584;
localparam CAL_CYCLE = 7;
localparam RDD_CYCLE = 4;
localparam DLY_CYCLE = DAT_DEPTH + RDD_CYCLE;
localparam TOT_CYCLE = DAT_DEPTH + CAL_CYCLE + RDD_CYCLE;

//--------------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------------
genvar gb;

reg            [DAT_DEPTH-1: 0]                 rx_vld_dly            =0;
reg                                             i_eop_d1              =0;
reg            [   5: 0]                        shift_num             =0;
reg            [  39: 0]                        max_value_iq          =0;
reg            [   5: 0]                        max_shift_dly1        =0;
reg            [   5: 0]                        max_shift_dly2        =0;
reg            [   5: 0]                        max_shift_dly3        =0;
reg            [   5: 0]                        lsb_right_shift       =0;

wire           [15:0][IW-1: 0]                  max_dout                ;
reg            [ 7:0][IW-1: 0]                  max_val_0               ;
reg            [ 3:0][IW-1: 0]                  max_val_1               ;
reg            [ 1:0][IW-1: 0]                  max_val_2               ;

//--------------------------------------------------------------------------------------------
// search max value for each channel
//--------------------------------------------------------------------------------------------
generate for(gb=0;gb<16;gb=gb+1)begin : u_search_max
    search_max #(
        .IW                                                 (IW                     ) 
    )search_max
    (
        .clk                                                (clk                    ),
        .rst                                                (rst                    ),
        .i_sop                                              (i_sop                  ),
        .i_eop                                              (i_eop                  ),
        .i_vld                                              (i_vld                  ),
        .i_din_re                                           (i_din_re[gb]           ),
        .i_din_im                                           (i_din_im[gb]           ),
        .o_max                                              (max_dout[gb]           ),
        .o_vld                                              (                       ) 
    );
end
endgenerate

//--------------------------------------------------------------------------------------------
// find max value for all channels
//--------------------------------------------------------------------------------------------
generate for(gb=0;gb<8;gb=gb+1)begin : max_pipe_0
    always @ (posedge clk)begin
        max_val_0[gb] <= (max_dout[gb*2] | max_dout[gb*2+1]);
    end
end
endgenerate

generate for(gb=0;gb<4;gb=gb+1)begin : max_pipe_1
    always @ (posedge clk)begin
        max_val_1[gb] <= (max_val_0[gb*2] | max_val_0[gb*2+1]);
    end
end
endgenerate

generate for(gb=0;gb<2;gb=gb+1)begin : max_pipe_2
    always @ (posedge clk)begin
        max_val_2[gb] <= (max_val_1[gb*2] | max_val_1[gb*2+1]);
    end
end
endgenerate


always @ (posedge clk)
	max_value_iq <= (max_val_2[0] | max_val_2[1]);



//--------------------------------------------------------------------------------------------
// Get the shift number based on the max value
//--------------------------------------------------------------------------------------------
always @ (posedge clk)                      
begin
    casex(max_value_iq[39:0])//14-0;14-n=shift
        40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001 : shift_num <= 6'd38;  
        40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_001x : shift_num <= 6'd37;  
        40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx : shift_num <= 6'd36;  
        40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx : shift_num <= 6'd35;  
        40'b0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx : shift_num <= 6'd34;  
        40'b0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx : shift_num <= 6'd33;  
        40'b0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx : shift_num <= 6'd32;  
        40'b0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx : shift_num <= 6'd31;  
        40'b0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx : shift_num <= 6'd30;  
        40'b0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx : shift_num <= 6'd29;  
        40'b0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx : shift_num <= 6'd28;  
        40'b0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx : shift_num <= 6'd27;  
        40'b0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx : shift_num <= 6'd26;  
        40'b0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx : shift_num <= 6'd25;  
        40'b0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx : shift_num <= 6'd24;  
        40'b0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx : shift_num <= 6'd23;  
        40'b0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd22;  
        40'b0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd21;  
        40'b0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd20;  
        40'b0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd19;  
        40'b0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd18;  
        40'b0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd17;        
        40'b0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd16;   
        40'b0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd15;   
        40'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd14;
        40'b0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd13;
        40'b0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd12;
        40'b0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd11;
        40'b0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd10;
        40'b0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd9 ;
        40'b0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd8 ;
        40'b0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd7 ;
        40'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd6 ;
        40'b0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd5 ;
        40'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd4 ;
        40'b0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd3 ;
        40'b0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd2 ;
        40'b001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd1 ;
        40'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd0 ;
        40'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : shift_num <= 6'd0 ;
        default 	                        : shift_num <= 6'd24;
    endcase
end



//--------------------------------------------------------------------------------------------
// compress data by shifting input data
//--------------------------------------------------------------------------------------------
wire           [15:0][OW-1: 0]                  cprs_dout_re            ;
wire           [15:0][OW-1: 0]                  cprs_dout_im            ;

generate for(gb=0;gb<16;gb=gb+1)begin : compress_shift_gen
    // Instantiate the unit under test
    compress_shift #(
        .IW                                                 (IW                     ),
        .OW                                                 (OW                     ),
        .DLY_CYCLE                                          (DLY_CYCLE              ) 
    )compress_shift (
        .clk                                                (clk                    ),
        .rst                                                (rst                    ),
        .i_sel                                              (i_sel                  ),
        .i_sop                                              (i_sop                  ),
        .i_eop                                              (i_eop                  ),
        .i_vld                                              (i_vld                  ),
        .i_din_re                                           (i_din_re    [gb]       ),
        .i_din_im                                           (i_din_im    [gb]       ),
        .i_shift_num                                        (shift_num              ),  
        .o_dout_re                                          (cprs_dout_re[gb]       ),
        .o_dout_im                                          (cprs_dout_im[gb]       ) 
    );
end
endgenerate



//--------------------------------------------------------------------------------------------
// Ouput data
//--------------------------------------------------------------------------------------------

assign o_dout_re = cprs_dout_re;
assign o_dout_im = cprs_dout_im;


always@(posedge clk)
begin
    max_shift_dly1 <= shift_num   ;
    max_shift_dly2 <= max_shift_dly1;
    max_shift_dly3 <= max_shift_dly2;
    o_shift        <= max_shift_dly3;
end

always@(posedge clk)
begin
    lsb_right_shift <= max_shift_dly2 - 'd10; // 29-MSB = 29-(39-shift_num)
end


//--------------------------------------------------------------------------------------------
// info_0 
//--------------------------------------------------------------------------------------------
wire           [   3: 0]                        pkg_type                ;
wire                                            cell_idx                ;
wire           [   6: 0]                        slot_idx                ;
wire           [   3: 0]                        symb_idx                ;

assign pkg_type  = i_info_0[39:36];
assign cell_idx  = i_info_0[19];
assign slot_idx  = i_info_0[18:12];
assign symb_idx  = i_info_0[11:8];

//--------------------------------------------------------------------------------------------
// Delay match 
//--------------------------------------------------------------------------------------------
wire                                            rbg_load_dly            ;
wire           [15:0][7: 0]                     fft_agc                 ;
reg            [15:0][7: 0]                     fft_agc_out           =0;

register_shift # (
    .WIDTH                                              (4                      ),
    .DEPTH                                              (TOT_CYCLE              ) 
)u_dly_vld(
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .in                                                 ({i_sel,i_sop,i_eop,i_vld}),
    .out                                                ({o_sel,o_sop,o_eop,o_vld}) 
);

register_shift # (
    .WIDTH                                              (1                      ),
    .DEPTH                                              (TOT_CYCLE-1            ) 
)u_dly_rbg_load(
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .in                                                 (i_rbg_load             ),
    .out                                                (rbg_load_dly           ) 
);

register_shift # (
    .WIDTH                                              (16                     ),
    .DEPTH                                              (TOT_CYCLE              ) 
)u_dly_info_0(
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .in                                                 ({pkg_type,cell_idx,slot_idx,symb_idx}),
    .out                                                ({o_pkg_type,o_cell_idx,o_slot_idx,o_symb_idx}) 
);

generate for(gb=0;gb<16;gb=gb+1)begin : dly_info1 
    register_shift # (
        .WIDTH                                              (8                      ),
        .DEPTH                                              (TOT_CYCLE-1            ) 
    )u_dly_info_1(
        .clk                                                (clk                    ),
        .rst                                                (rst                    ),
        .in                                                 (i_info_1[gb]           ),
        .out                                                (fft_agc [gb]           ) 
    );

    always @ (posedge clk)
    begin
        fft_agc_out[gb] <= fft_agc[gb] + 8'(signed'(lsb_right_shift)); //lsb_right_shift | max_shift_dly3
    end

    assign o_fft_agc[gb] = fft_agc_out[gb];

end
endgenerate


//--------------------------------------------------------------------------------------
// beam power memory
//--------------------------------------------------------------------------------------
wire           [15:0][31: 0]                    rd_beam_pwr             ;
wire           [   3: 0]                        rd_addr                 ;
reg            [15:0][31: 0]                    rd_beam_pwr_out       =0;
reg                                             rbg_load_out          =0;

mem_streams_ram # (
    .CHANNELS                                           (16                     ),
    .WDATA_WIDTH                                        (32                     ),
    .WADDR_WIDTH                                        (4                      ),
    .RDATA_WIDTH                                        (32                     ),
    .RADDR_WIDTH                                        (4                      ),
    .READ_LATENCY                                       (3                      ),
    .RAM_TYPE                                           (1                      ) 
)mem_beam_pwr(
    .i_clk                                              (clk                    ),
    .i_reset                                            (1'b0                   ),
    .i_rvalid                                           (i_vld                  ),
    .i_wr_wen                                           (i_rbg_load             ),
    .i_wr_data                                          (i_beam_pwr             ),
    .i_rd_ren                                           (rbg_load_dly           ),
    .o_rd_data                                          (rd_beam_pwr            ),
    .o_rd_addr                                          (rd_addr                ),
    .o_tvalid                                           (                       ) 
);

always @(posedge clk) begin
    rbg_load_out <= rbg_load_dly;
    if(rbg_load_dly)
        rd_beam_pwr_out <= rd_beam_pwr;
    else
        rd_beam_pwr_out <= rd_beam_pwr_out;
end

assign o_rbg_load = rbg_load_out;
assign o_beam_pwr = rd_beam_pwr_out;
assign o_rbg_idx  = rd_addr[3:0];


endmodule
