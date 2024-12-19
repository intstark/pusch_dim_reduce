//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/02/28 15:54:23
// Design Name: 
// Module Name: iq_data_rx
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

module iq_data_rx #(
    parameter DW     = 8,
    parameter numTX  = 8,
    parameter numSTS = 8,
    parameter numRE  = 12
)(
    input                                             i_clk                    ,

    input          [  63: 0]                          i_cpri_rx_data           ,
    input          [   6: 0]                          i_cpri_rx_seq            ,
    input          [  63: 0]                          i_cpri_rx_mask           ,
    input          [   7: 0]                          i_cpri_rx_crtl           ,

    output         [numTX-1:0][DW-1: 0]               o_iq_data                ,
    output         [numTX-1:0][DW-1: 0]               o_cm_data                 
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
genvar ant;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
wire                                              stage_is_iq              ;
reg                                               fifo_wr_en             =1'b0;
reg            [6:0][63: 0]                       data_rx_buf            ='{default:0};
reg            [   2: 0]                          dw_cnt                 =3'd0;
reg            [   7: 0]                          prb_cnt                =4'd0;
reg            [   3: 0]                          prb_re_cnt             =4'd0;
reg            [ 127: 0]                          rb_agc                 =0;
reg            [3:0][111: 0]                      data_rx_comb             ;
reg            [3:0][255: 0]                      data_rx_unpack         ='{default:0};

//--------------------------------------------------------------------------------------
//  input register
//--------------------------------------------------------------------------------------

assign stage_is_iq = (i_cpri_rx_seq>7'd6 && i_cpri_rx_seq<7'd91) ? 1'b1 : 1'b0;
assign stage_is_rbagc = (i_cpri_rx_seq==7'd5 || i_cpri_rx_seq==7'd6) ? 1'b1 : 1'b0;


always @(posedge i_clk) begin
    if(i_cpri_rx_seq==7'd5)
        rb_agc[63:0] <= i_cpri_rx_data;
    else if(i_cpri_rx_seq==7'd6)
        rb_agc[127:64] <= i_cpri_rx_data;
end


always @(posedge i_clk) begin
    if(dw_cnt == 3'd6) 
        dw_cnt <= 3'd0;
    else if(stage_is_iq)
        dw_cnt <= dw_cnt + 3'd1;
    else
        dw_cnt <= 3'd0;
end

always @(posedge i_clk) begin
    if(prb_re_cnt == 4'd11) 
        prb_re_cnt <= 4'd0;
    else if(stage_is_iq)
        prb_re_cnt <= prb_re_cnt + 4'd1;
end

always @(posedge i_clk) begin
    if(prb_cnt == 8'd7) 
        prb_cnt <= 8'd0;
    else if(prb_re_cnt == 4'd11)
        prb_cnt <= prb_cnt + 8'd1;
end

always @(posedge i_clk) begin
    if(stage_is_iq)
        data_rx_buf[0] <= i_cpri_rx_data;

    for(int k=1; k<7; k++) begin
        data_rx_buf[k] <= data_rx_buf[k-1];
    end
end


generate for(ant=0; ant<4; ant++) begin
    always_comb begin
        for(int k=0; k<7; k++) begin
            data_rx_comb[ant][16*k +: 16] = data_rx_buf[k][ant*16 +: 16];
        end
    end
end
endgenerate

generate for(ant=0; ant<4; ant++) begin
    always @(posedge i_clk) begin
        for(int k=0; k<8; k++) begin
            data_rx_unpack[ant][32*k +: 32] = {16'(signed'(data_rx_comb[ant][k*14+7 +: 7])<<2), 16'(signed'(data_rx_comb[ant][k*14 +: 7])<<2)};
        end
    end
end
endgenerate





endmodule
