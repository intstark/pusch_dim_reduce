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
    parameter WIDTH     = 32,
    parameter DEPTH     = 64
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_enable                ,

    output         [DEPTH-1:0][WIDTH*ANTS-1: 0]     o_cw_even               ,
    output         [DEPTH-1:0][WIDTH*ANTS-1: 0]     o_cw_odd                ,
    output                                          o_tvalid                 
);





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
wire           [   6: 0]                        ant_num                 ;
reg            [   2: 0]                        rom_vld               =0;
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

    rom_vld <= {rom_vld[1:0], cwd_valid};
end

always @(posedge i_clk) begin
    ant_num_buf[0] <= codeword_rdnum;
    for(int i=1;i<3;i++)begin
        ant_num_buf[i] <= ant_num_buf[i-1];
    end
end

assign ant_num = ant_num_buf[2];

always @(posedge i_clk) begin
    codeword_map_0[ant_num] <= codeword_rdata_even[1*WIDTH*ANTS-1: WIDTH*0   ];
    codeword_map_1[ant_num] <= codeword_rdata_odd [1*WIDTH*ANTS-1: WIDTH*0   ];
end



assign o_cw_even = codeword_map_0;
assign o_cw_odd  = codeword_map_1;
assign o_tvalid  = rom_vld[2];

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







endmodule
