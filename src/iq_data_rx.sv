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
    parameter ANT    = 8,
    parameter numSTS = 8,
    parameter numRE  = 12
)(
    input                                           i_clk                   ,

    input          [  63: 0]                        i_cpri_rx_data          ,
    input          [   6: 0]                        i_cpri_rx_seq           ,
    input          [  63: 0]                        i_cpri_rx_mask          ,
    input          [   7: 0]                        i_cpri_rx_crtl          ,

    output         [ANT-1:0][DW-1: 0]               o_iq_data               ,
    output         [ANT-1:0][DW-1: 0]               o_cm_data                
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
genvar ant;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
wire                                            stage_is_iq             ;
wire                                            re_reached_24           ;
reg                                             fifo_wr_en            =0;
reg            [20:0][63: 0]                    data_rx_buf           ='{default:0};
reg            [   2: 0]                        dw_cnt                =0;
reg            [   7: 0]                        prb_cnt               =0;
reg            [   7: 0]                        prb_index_align       =0;
reg            [   7: 0]                        agc_prb_idx           =0;
reg            [   7: 0]                        prb_re_cnt            =0;
reg            [ 127: 0]                        rb_agc                =0;
reg            [3:0][24*14-1: 0]                data_rx_comb          ='{default:0};
reg            [3:0][24*32-1: 0]                data_rx_unpack        ='{default:0};
reg            [3:0][12*14-1: 0]                data_rx_prb           ='{default:0};

// agc
reg            [   7: 0]                        agc_prb_idx_r1        =0;
reg            [   7: 0]                        agc_prb_idx_r2        =0;
reg            [   7: 0]                        prb_valid             =0;

// rom
reg            [ANT-1:0][12*32-1: 0]            wdata                 =0;
wire           [ANT-1:0][12*32-1: 0]            rdata                   ;
reg            [ANT-1: 0]                       wen                   =0;
reg            [ANT-1: 0]                       ren                   =0;
reg            [ANT-1:0][7: 0]                  waddr                 =0;
reg            [ANT-1:0][7: 0]                  raddr                 =0;

wire                                            prb_reached_132         ;
reg                                             ant_odd_even          =0;

//--------------------------------------------------------------------------------------
// assignment for stage_is_rbagc and re_reached_24
//--------------------------------------------------------------------------------------
assign stage_is_iq = (i_cpri_rx_seq>7'd6 && i_cpri_rx_seq<7'd91) ? 1'b1 : 1'b0;
assign stage_is_rbagc = (i_cpri_rx_seq==7'd5 || i_cpri_rx_seq==7'd6) ? 1'b1 : 1'b0;
assign re_reached_24 = (prb_re_cnt==20) ? 1'b1 : 1'b0;


//--------------------------------------------------------------------------------------
// receive rb agc data
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(i_cpri_rx_seq==7'd5)
        rb_agc[63:0] <= i_cpri_rx_data;
    else if(i_cpri_rx_seq==7'd6)
        rb_agc[127:64] <= i_cpri_rx_data;
end


//--------------------------------------------------------------------------------------
// generate DW number 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(dw_cnt == 3'd6) 
        dw_cnt <= 3'd0;
    else if(stage_is_iq)
        dw_cnt <= dw_cnt + 3'd1;
    else
        dw_cnt <= 3'd0;
end

always @(posedge i_clk) begin
    if(re_reached_24) 
        prb_re_cnt <= 8'd0;
    else if(stage_is_iq)
        prb_re_cnt <= prb_re_cnt + 4'd1;
end

always @(posedge i_clk) begin
    if(stage_is_rbagc)
        agc_prb_idx <= 0;
    else if(re_reached_24)
        agc_prb_idx <= agc_prb_idx + 2;
end

always @(posedge i_clk) begin
    if(re_reached_24)begin
        if(prb_cnt == 8'd132) 
            prb_cnt <= 8'd0;
        else
            prb_cnt <= prb_cnt + 8'd2;
    end
end


//--------------------------------------------------------------------------------------
// Buffer 21 DW, which contains 24 re
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(stage_is_iq)
        data_rx_buf[0] <= i_cpri_rx_data;

    for(int k=1; k<21; k++) begin
        data_rx_buf[k] <= data_rx_buf[k-1];
    end
end

always @(posedge i_clk) begin
    prb_valid <= {prb_valid[6:0], re_reached_24};
end

//--------------------------------------------------------------------------------------
// combine 14 bit data cross DW 
//--------------------------------------------------------------------------------------
generate for(ant=0; ant<4; ant++) begin
    always @(posedge i_clk) begin
        if(prb_valid[0]) begin
            for(int k=0; k<21; k++) begin
                data_rx_comb[ant][16*k +: 16] <= data_rx_buf[20-k][ant*16 +: 16];
            end
        end
    end
end
endgenerate

//--------------------------------------------------------------------------------------
// serialize prb block 
//--------------------------------------------------------------------------------------
generate for(ant=0; ant<4; ant++) begin
    always @(posedge i_clk) begin
        if(prb_valid[1]) 
            data_rx_prb[ant] <= data_rx_comb[ant][12*14*0 +: 12*14];
        else if(prb_valid[2])
            data_rx_prb[ant] <= data_rx_comb[ant][12*14*1 +: 12*14];
    end
end
endgenerate

//--------------------------------------------------------------------------------------
// generate agc index
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(prb_valid[0])begin
        agc_prb_idx_r1 <= agc_prb_idx-2;
        agc_prb_idx_r2 <= agc_prb_idx-1;
    end
end

//--------------------------------------------------------------------------------------
// generate agc index
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(prb_cnt==0)
        prb_index_align <= 0;
    else if(prb_valid[1])
        prb_index_align <= prb_cnt - 1;
end

//--------------------------------------------------------------------------------------
// generate even/odd ant flag
//--------------------------------------------------------------------------------------
assign prb_reached_132 = (prb_cnt==132 && re_reached_24) ? 1'b1 : 1'b0;

always @ (posedge i_clk)begin
    if(prb_reached_132)
        ant_odd_even <= ant_odd_even + 1;
end

//--------------------------------------------------------------------------------------
// data unpack logic
//--------------------------------------------------------------------------------------
generate for(ant=0; ant<4; ant++) begin
    always @(posedge i_clk) begin
        for(int k=0; k<12; k++) begin
            data_rx_unpack[ant][32*k +: 32] <= {16'(signed'(data_rx_comb[ant][k*14+7 +: 7])<<rb_agc[ant*32+agc_prb_idx_r1*4 +: 4]), 
                                                16'(signed'(data_rx_comb[ant][k*14   +: 7])<<rb_agc[ant*32+agc_prb_idx_r1*4 +: 4])};

            data_rx_unpack[ant][32*(k+12) +: 32] <= {   16'(signed'(data_rx_comb[ant][(k+12)*14+7 +: 7])<<rb_agc[ant*32+agc_prb_idx_r2*4 +: 4]),
                                                        16'(signed'(data_rx_comb[ant][(k+12)*14   +: 7])<<rb_agc[ant*32+agc_prb_idx_r2*4 +: 4])};
        end
    end
end
endgenerate

//------------------------------------------------------------------------------------------
// EVEN ANT MEM BLOCK 
//------------------------------------------------------------------------------------------
generate for(ant=0; ant<4; ant++) begin
    //--------------------------------------------------------------------------------------
    // ram write logic 
    //--------------------------------------------------------------------------------------
    always @(posedge i_clk) begin
        if(prb_reached_132)
            wen  [ant]  <= 0;
        else if(prb_valid[2] && (!ant_odd_even))
            wen  [ant]  <= 1;
        else if(prb_valid[3] && (!ant_odd_even))
            wen  [ant]  <= 1;
        else
            wen[ant]    <= 0;
    end

    always @(posedge i_clk) begin
        if(prb_reached_132)
            waddr[ant]  <= 0;
        else if(wen[ant])
            waddr[ant]  <= waddr[ant] + 1;
    end

    always @(posedge i_clk) begin
        if(prb_valid[2] && (!ant_odd_even))
            wdata[ant]  <= data_rx_unpack[ant][12*32*0 +: 12*32];
        else if(prb_valid[3] && (!ant_odd_even))
            wdata[ant]  <= data_rx_unpack[ant][12*32*1 +: 12*32];
    end

    //--------------------------------------------------------------------------------------
    // ram read logic 
    //--------------------------------------------------------------------------------------
    always @(posedge i_clk) begin
        if(prb_valid[4] && (!ant_odd_even))
            ren[ant] <= 1;
        else if (prb_valid[5] && (!ant_odd_even))
            ren[ant] <= 1;
        else
            ren[ant] <= 0;
    end

    always @(posedge i_clk) begin
        if(prb_reached_132)
            raddr[ant]  <= 0;
        else if(ren[ant])
            raddr[ant]  <= raddr[ant] + 1;
    end

    //--------------------------------------------------------------------------------------
    // ram for re data for very antenna 
    //--------------------------------------------------------------------------------------
    rxdata_dual_ram                                         rxdata_dual_ram (
        .data                                               (wdata[ant]             ),//      data.datain
        .q                                                  (rdata[ant]             ),//         q.dataout
        .wraddress                                          (waddr[ant]             ),// wraddress.wraddress
        .rdaddress                                          (raddr[ant]             ),// rdaddress.rdaddress
        .wren                                               (wen  [ant]             ),//      wren.wren
        .rden                                               (ren  [ant]             ),//      wren.wren
        .clock                                              (i_clk                  ) //     clock.clk
    );
end
endgenerate


//------------------------------------------------------------------------------------------
// ODD ANT MEM BLOCK 
//------------------------------------------------------------------------------------------
generate for(ant=4; ant<8; ant++) begin
    //--------------------------------------------------------------------------------------
    // ram write logic 
    //--------------------------------------------------------------------------------------
    always @(posedge i_clk) begin
        if(prb_reached_132)
            wen  [ant]  <= 0;
        else if(prb_valid[2] && ant_odd_even)
            wen  [ant]  <= 1;
        else if(prb_valid[3] && ant_odd_even)
            wen  [ant]  <= 1;
        else
            wen[ant]    <= 0;
    end

    always @(posedge i_clk) begin
        if(prb_reached_132)
            waddr[ant]  <= 0;
        else if(wen[ant])
            waddr[ant]  <= waddr[ant] + 1;

    end

    always @(posedge i_clk) begin
        if(prb_valid[2] && ant_odd_even)
            wdata[ant]  <= data_rx_unpack[ant-4][12*32*0 +: 12*32];
        else if(prb_valid[3] && ant_odd_even)
            wdata[ant]  <= data_rx_unpack[ant-4][12*32*1 +: 12*32];
    end

    //--------------------------------------------------------------------------------------
    // ram read logic 
    //--------------------------------------------------------------------------------------
    always @(posedge i_clk) begin
        if(prb_valid[4] && ant_odd_even)
            ren[ant] <= 1;
        else if (prb_valid[5] && ant_odd_even)
            ren[ant] <= 1;
        else
            ren[ant] <= 0;
    end

    always @(posedge i_clk) begin
        if(prb_reached_132)
            raddr[ant]  <= 0;
        else if(ren[ant])
            raddr[ant]  <= raddr[ant] + 1;
    end

    //--------------------------------------------------------------------------------------
    // ram for re data for very antenna 
    //--------------------------------------------------------------------------------------
    rxdata_dual_ram                                         rxdata_dual_ram (
        .data                                               (wdata[ant]             ),//      data.datain
        .q                                                  (rdata[ant]             ),//         q.dataout
        .wraddress                                          (waddr[ant]             ),// wraddress.wraddress
        .rdaddress                                          (raddr[ant]             ),// rdaddress.rdaddress
        .wren                                               (wen  [ant]             ),//      wren.wren
        .rden                                               (ren  [ant]             ),//      wren.wren
        .clock                                              (i_clk                  ) //     clock.clk
    );
end

endgenerate







endmodule
