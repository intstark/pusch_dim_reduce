//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/28 15:54:23
// Design Name: 
// Module Name: code_word_rev
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module code_word_rev # (
    parameter ANTS      = 32,
    parameter IW        = 32,
    parameter BEAM      = 16,
    parameter WIDTH     = 32
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_enable                ,
    input          [   7: 0]                        i_re_num                ,
    input          [   7: 0]                        i_rbg_num               ,
    input                                           i_rbg_load              ,

    input                                           i_rvalid                ,
    input                                           i_sop                   ,
    input                                           i_eop                   ,
    input          [ANTS*IW-1: 0]                   i_ant_even              ,
    input          [ANTS*IW-1: 0]                   i_ant_odd               ,
    // input header info
    input          [  63: 0]                        i_info_0                ,// IQ HD 
    input          [  15: 0]                        i_info_1                ,// FFT AGC{odd,even}

    input          [BEAM-1:0][7: 0]                 i_beam_idx              ,
    input          [   7: 0]                        i_symb_idx              ,
    input                                           i_symb_clr              ,
    input                                           i_symb_1st              ,

    output                                          o_ant_vld               ,
    output                                          o_ant_sop               ,
    output                                          o_ant_eop               ,
    output         [ANTS*IW-1: 0]                   o_ant_even              ,
    output         [ANTS*IW-1: 0]                   o_ant_odd               ,
    output         [  63: 0]                        o_info_0                ,// IQ HD 
    output         [  15: 0]                        o_info_1                ,// FFT AGC{odd,even}

    output                                          o_symb_clr              ,
    output                                          o_symb_1st              ,
    output         [   7: 0]                        o_re_num                ,
    output         [   7: 0]                        o_rbg_num               ,
    output                                          o_rbg_load              ,
    
    output         [BEAM-1:0][WIDTH*ANTS-1: 0]      o_cw_even               ,
    output         [BEAM-1:0][WIDTH*ANTS-1: 0]      o_cw_odd                ,
    output                                          o_tvalid                ,
    output                                          o_bid_rden               
);

localparam DEPTH = 64;



//--------------------------------------------------------------------------------------
// Store the index of sorted beams to BRAM
//--------------------------------------------------------------------------------------
wire           [WIDTH*ANTS-1: 0]                codeword_rdata_even     ;
wire           [WIDTH*ANTS-1: 0]                codeword_rdata_odd      ;
reg            [   6: 0]                        codeword_rdnum        =0;
reg            [   5: 0]                        codeword_raddr        =0;
reg                                             codeword_rden         =0;
reg            [DEPTH-1:0][WIDTH*ANTS-1: 0]     codeword_map_0        =0;
reg            [DEPTH-1:0][WIDTH*ANTS-1: 0]     codeword_map_1        =0;
reg            [   2:0][6:0]                    ant_num_buf           =0;
(* DONT_TOUCH = "TRUE" *) reg [   6: 0]         ant_num_0             =0;
(* DONT_TOUCH = "TRUE" *) reg [   6: 0]         ant_num_1             =0;
reg            [   3: 0]                        rom_vld               =0;
reg                                             cwd_valid             =0;




always @(posedge i_clk) begin
    if(i_reset)
        codeword_rdnum<= 'd0;
    else if(i_enable)begin
        if(codeword_rdnum == DEPTH)
            codeword_rdnum <= codeword_rdnum;
        else
            codeword_rdnum <= codeword_rdnum + 'd1;
    end
end

always @(posedge i_clk) begin
    if(i_reset)
        codeword_rden <= 1'b0;
    else if(codeword_rdnum == DEPTH)
        codeword_rden <= 1'b0;
    else if(i_enable)
        codeword_rden <= 1'b1;
end

always @(posedge i_clk) begin
    codeword_raddr <= codeword_rdnum[5:0];
end

always @(posedge i_clk) begin
    if(i_reset)
        cwd_valid <= 1'b0;
    else if(codeword_rdnum == DEPTH)
        cwd_valid <= 1'b1;
    else
        cwd_valid <= 1'b0;

    if(i_reset)
        rom_vld <= 'd0;
    else
        rom_vld <= {rom_vld[2:0], cwd_valid};
end

always @(posedge i_clk) begin
    ant_num_buf[0] <= codeword_rdnum;
    for(int i=1;i<3;i++)begin
        ant_num_buf[i] <= ant_num_buf[i-1];
    end
end

always @(posedge i_clk) begin
    ant_num_0 <= ant_num_buf[1];
    ant_num_1 <= ant_num_buf[1];
end

always @(posedge i_clk) begin
    codeword_map_0[ant_num_0] <= codeword_rdata_even[1*WIDTH*ANTS-1: WIDTH*0   ];
    codeword_map_1[ant_num_1] <= codeword_rdata_odd [1*WIDTH*ANTS-1: WIDTH*0   ];
end


//--------------------------------------------------------------------------------------
// rom for codeword even: 4 clock cycle delay
//--------------------------------------------------------------------------------------
rom_codeword_even    u_rom_codeword_even
(
    .q                                                  (codeword_rdata_even    ),//  output,  width = 64,       q.dataout
    .rden                                               (codeword_rden          ),
    .address                                            (codeword_raddr         ),//   input,   width = 8, address.address
    .clock                                              (i_clk                  ) //   input,   width = 1,   clock.clk
);

rom_codeword_odd     u_rom_codeword_odd
(
    .q                                                  (codeword_rdata_odd     ),//  output,  width = 64,       q.dataout
    .rden                                               (codeword_rden          ),
    .address                                            (codeword_raddr         ),//   input,   width = 8, address.address
    .clock                                              (i_clk                  ) //   input,   width = 1,   clock.clk
);

//--------------------------------------------------------------------------------------
// select codewrds for each beam
//--------------------------------------------------------------------------------------
reg            [   1: 0]                        symb_phx              =0;
reg            [BEAM-1: 0]                      rbg_load_vec          =0;
reg            [BEAM-1:0][1: 0]                 symb_phx_vec          =0;
reg            [BEAM-1: 0]                      symb_1st_vec          ={BEAM{1'b1}};


reg            [BEAM-1:0][ANTS*WIDTH-1: 0]      code_word_even        ='{default:0};
reg            [BEAM-1:0][ANTS*WIDTH-1: 0]      code_word_odd         ='{default:0};
reg            [BEAM-1:0][ANTS*WIDTH-1: 0]      cw_even_select        ='{default:0};
reg            [BEAM-1:0][ANTS*WIDTH-1: 0]      cw_odd_select         ='{default:0};
reg            [BEAM-1:0][7: 0]                 beam_idx                ;
reg                                             bid_rden_out            ;


always @(posedge i_clk) begin
    symb_phx    <= i_symb_idx[1:0];
    rbg_load_vec<= {BEAM{i_rbg_load}};
end

always @(posedge i_clk) begin
    for(int i=0;i<BEAM;i=i+1) begin
        if(i_symb_clr)begin
            symb_1st_vec[i] <= 1'b1;
            symb_phx_vec[i] <= 2'b0;
        end else begin
            symb_1st_vec[i] <= i_symb_1st;
            symb_phx_vec[i] <= symb_phx;
        end
    end
end

always @(posedge i_clk) begin
    for(int i=0;i<BEAM;i=i+1) begin
        if(i_symb_clr)begin
                code_word_even[i]  <= codeword_map_0[i];
                code_word_odd [i]  <= codeword_map_1[i];
        end else if(symb_1st_vec[i])begin
            case(symb_phx_vec[i])
            2'd0:   begin
                        code_word_even[i]  <= codeword_map_0[i];
                        code_word_odd [i]  <= codeword_map_1[i];
                    end
            2'd1:   begin
                        code_word_even[i]  <= codeword_map_0[i+16];
                        code_word_odd [i]  <= codeword_map_1[i+16];
                    end
            2'd2:   begin
                        code_word_even[i]  <= codeword_map_0[i+32];
                        code_word_odd [i]  <= codeword_map_1[i+32];
                    end
            2'd3:   begin
                        code_word_even[i]  <= codeword_map_0[i+48];
                        code_word_odd [i]  <= codeword_map_1[i+48];
                    end
            default:begin
                        code_word_even[i]  <= codeword_map_0[i];
                        code_word_odd [i]  <= codeword_map_1[i];
                    end
            endcase
        end else begin
                code_word_even[i]  <= cw_even_select[i];
                code_word_odd [i]  <= cw_odd_select [i];
        end
    end
end

always @(posedge i_clk) begin
    for(int i=0;i<BEAM;i=i+1) begin
        beam_idx[i] <= i_beam_idx[i];
    end
end

always @(posedge i_clk) begin
    for(int i=0;i<BEAM;i=i+1) begin
        if(rbg_load_vec[i])begin
            cw_even_select[i] <= codeword_map_0[beam_idx[i]];
            cw_odd_select[i]  <= codeword_map_1[beam_idx[i]];
        end
    end
end

always @(posedge i_clk) begin
    bid_rden_out <= rbg_load_vec[0];
end




//-----------------------------------------------------------------------------
// ant data latency match: 2 Clock Latency
//-----------------------------------------------------------------------------
reg            [   1: 0]                        symb_clr_out          =0;
reg            [   1: 0]                        symb_1st_out          =0;
reg            [   1: 0]                        rvld_out              =0;
reg            [   1: 0]                        sop_out               =0;
reg            [   1: 0]                        eop_out               =0;
reg            [ANTS*IW-1: 0]                   r1_ant_even           =0;
reg            [ANTS*IW-1: 0]                   r1_ant_odd            =0;
reg            [ANTS*IW-1: 0]                   r2_ant_even           =0;
reg            [ANTS*IW-1: 0]                   r2_ant_odd            =0;

reg            [1:0][63: 0]                     info0_out             =0;
reg            [1:0][15: 0]                     info1_out             =0;
reg            [1:0][7: 0]                      re_num_out            =0;
reg            [1:0][7: 0]                      rbg_num_out           =0;
reg                                             rbg_load_out          =0;


always @ (posedge i_clk) begin
    if(i_reset)begin
        rvld_out    <= 'd0;
        sop_out     <= 'd0;
        eop_out     <= 'd0;

        symb_clr_out<= 'd0;
        symb_1st_out<= 'd0;
        rbg_load_out<= 'd0;
    end else begin
        rvld_out <= {rvld_out[0], i_rvalid};
        sop_out  <= {sop_out [0], i_sop   };
        eop_out  <= {eop_out [0], i_eop   };

        symb_clr_out <= {symb_clr_out [0], i_symb_clr};
        symb_1st_out <= {symb_1st_out [0], i_symb_1st};
        rbg_load_out <= rbg_load_vec[0];
    end
end

always @(posedge i_clk) begin
    r1_ant_even <= i_ant_even;       
    r1_ant_odd  <= i_ant_odd ;

    r2_ant_even <= r1_ant_even;       
    r2_ant_odd  <= r1_ant_odd ;
end

// info latency match
always @(posedge i_clk) begin
    info0_out[0] <= i_info_0;
    info1_out[0] <= i_info_1;
    for(int i=1; i<2; i++)begin
        info0_out[i] <= info0_out[i-1];
        info1_out[i] <= info1_out[i-1];
    end
end

// re_num/rbg_num/rbg_load latency match
always @ (posedge i_clk)begin
    if(i_reset)begin
        for(int i=0; i<2; i++)begin
            re_num_out [i] <='d0;
            rbg_num_out[i] <='d0;
        end
    end else begin
        re_num_out [0]  <= i_re_num;
        rbg_num_out[0]  <= i_rbg_num;
        for(int i=1; i<2; i++)begin
            re_num_out [i] <= re_num_out [i-1];
            rbg_num_out[i] <= rbg_num_out[i-1];
        end
    end
end

//-----------------------------------------------------------------------------
// Output Assignment 
//-----------------------------------------------------------------------------
assign o_ant_vld  = rvld_out[1];
assign o_ant_sop  = sop_out [1];
assign o_ant_eop  = eop_out [1];
assign o_ant_even = r2_ant_even;
assign o_ant_odd  = r2_ant_odd ;
assign o_info_0   = info0_out[1];
assign o_info_1   = info1_out[1];

assign o_re_num   = re_num_out [1];
assign o_rbg_num  = rbg_num_out[1];
assign o_rbg_load = rbg_load_out;
assign o_symb_clr = symb_clr_out[0];
assign o_symb_1st = symb_1st_out[0];

assign o_cw_even  = code_word_even;
assign o_cw_odd   = code_word_odd ;
assign o_tvalid   = rom_vld[3];
assign o_bid_rden = bid_rden_out;


endmodule
