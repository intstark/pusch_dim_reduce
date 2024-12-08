//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/28 15:54:23
// Design Name: 
// Module Name: beam_sort
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//                  Smaller data got the bigger score
//                  IF two data are equal, the one with smaller index got the smaller score 
//                  THE smaller score got the higher priority
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module beam_sort # (
    parameter IW     = 32,
    parameter COL    = 64
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [COL-1:0][IW-1: 0]               i_data                  ,
    input                                           i_enable                ,
    input                                           i_rready                ,
    input                                           i_rvalid                ,
    input                                           i_symb_clr              ,
    input                                           i_symb_1st              ,

    input          [   7: 0]                        i_rbg_max               ,
    input                                           i_rbg_load              ,
    input                                           i_bid_rdinit            ,

    output         [COL-1:0][7: 0]                  o_score                 ,
    output         [15:0][31: 0]                    o_data                  ,
    output         [15:0][7: 0]                     o_beam_index            ,
    output         [   5: 0]                        o_rbg_num               ,
    output                                          o_rbg_load              ,
    output                                          o_idx_sop               ,
    output                                          o_tvalid                ,
    output                                          o_tready                 
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
 genvar idx;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
reg                                             reset_syn             =0;
wire           [COL-1:0][IW-1: 0]               data                    ;
reg            [COL-1:0][7: 0]                  score                 =0;
reg                     [3:0]                   tvalid                =0;
reg                                             tready                =0;
reg            [COL-1:0][IW-1: 0]               sort_data             ='{default:0};
reg            [COL-1:0][7: 0]                  sort_addr             ='{default:0};
reg                                             data_vld              =0;

wire           [3:0][7: 0]                      w_score                 ;
wire           [   3: 0]                        w_tvalid                ;
wire           [   3: 0]                        w_tready                ;

reg            [   5: 0]                        rbg_num               =0;
reg            [  31: 0]                        enable_buf            =0;
reg                                             sort_done             =0;

reg            [COL-1:0][IW-1: 0]               data_in[3:0]          ='{default:0};
reg                                             rvalid_in             =0;
reg                                             rready_in             =0;
reg                                             enable_in             =0;
reg            [3:0][7: 0]                      data_idx              =0;
reg            [   7: 0]                        data_num              =0;
reg                                             sym_1st_done          =0;

//--------------------------------------------------------------------------------------
// data buffer 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(i_reset)
        reset_syn <= 1'b1;
    else if(i_symb_clr)
        reset_syn <= 1'b1;
    else
        reset_syn <= 1'b0;
end

//--------------------------------------------------------------------------------------
// data buffer 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(rvalid_in)
        data_num <= 'd0;
    else if(data_num==COL-4)
        data_num <= COL-4;
    else if(enable_in)
        data_num <= data_num + 'd4;
    else
        data_num <= 'd0;
end


always @ (posedge i_clk)begin
    data_idx[0] <= data_num + 8'd0;
    data_idx[1] <= data_num + 8'd1;
    data_idx[2] <= data_num + 8'd2;
    data_idx[3] <= data_num + 8'd3;

    enable_in <= i_enable;
    rvalid_in <= i_rvalid & (~sym_1st_done);
    rready_in <= i_rready;
    for(int i=0;i<4;i=i+1)begin
        data_in[i] <= i_data;
    end
end

//--------------------------------------------------------------------------------------
// compare data and generate smaller_score
//--------------------------------------------------------------------------------------
reg                                             par_vld               =0;
reg            [   7: 0]                        par_idx               =0;
wire                                            par_idx_ends            ;
reg                                             load_en               =0;
reg            [   3: 0]                        load_en_edge          =0;
reg                                             store_en              =0;
reg                                             sort_vld              =0;

generate for(idx=0; idx<4; idx=idx+1) begin: par_compare_x16
    par_compare #(
        .IW                                                 (IW                     ),
        .COL                                                (COL                    ) 
    ) par_compare (
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (reset_syn              ),
        .i_data                                             (data_in [idx]          ),
        .i_index                                            (data_idx[idx]          ),
        .i_rready                                           (rready_in              ),
        .i_rvalid                                           (rvalid_in              ),
        .o_score                                            (w_score [idx]          ),
        .o_tvalid                                           (w_tvalid[idx]          ),
        .o_tready                                           (w_tready[idx]          ) 
    );
end
endgenerate

always @ (posedge i_clk)begin
    par_vld <= w_tvalid[0];
    if(par_vld)
        par_idx <= 'd0;
    else if(load_en)
        par_idx <= par_idx + 'd4;
    else
        par_idx <= 'd0;
end

assign par_idx_ends = (par_idx==COL-4) ? 1'b1 : 1'b0;

always @ (posedge i_clk)begin
    if(par_vld)
        load_en <= 'd1;
    else if(par_idx_ends)
        load_en <= 'd0;
end

//--------------------------------------------------------------------------------------
// store the final 64 sort index 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(load_en)begin
        score[par_idx+0] <= w_score[0];
        score[par_idx+1] <= w_score[1];
        score[par_idx+2] <= w_score[2];
        score[par_idx+3] <= w_score[3];
    end
end

//--------------------------------------------------------------------------------------
// generate valid for score 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    load_en_edge <=  {load_en_edge[2:0], load_en};

    if(!load_en && load_en_edge[0])
        store_en <= 1'b1;
    else
        store_en <= 1'b0;
end

always @ (posedge i_clk)begin
    if(load_en_edge[3:2] == 2'b10)
        sort_vld <= 1'b1;
    else
        sort_vld <= 1'b0;
end



//--------------------------------------------------------------------------------------
// sort the data by score, smallest score first
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0; i<COL; i=i+1)begin
        if(store_en)
            sort_data[score[i]] <= i_data[i];
    end
end	

//--------------------------------------------------------------------------------------
// store the index of the data by score 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0; i<COL; i=i+1)begin
        if(store_en)
            sort_addr[score[i]] <= 8'(i);
    end
end	

//--------------------------------------------------------------------------------------
// store the index of the data by score 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    data_vld <= sort_vld;
    enable_buf <= {enable_buf[30:0], enable_in};
end	

always @ (posedge i_clk)begin
    if(i_reset)
        rbg_num <= 'd0;
    else if(i_symb_clr)
        rbg_num <= 'd0;
    else if(enable_buf[27]==0 && enable_buf[26]==1)
        rbg_num <= 'd0;
    else if(enable_buf[27] && sort_vld)
        rbg_num <= rbg_num + 'd1;
end


always @ (posedge i_clk)begin
    if(i_reset)
        sort_done <= 'd0;
    else if(i_symb_clr)
        sort_done <= 'd0;
    else if(sort_vld)
        sort_done <= 'd1;
end

//--------------------------------------------------------------------------------------
// Store the power of 16 beams to BRAM
//--------------------------------------------------------------------------------------
wire           [   3: 0]                        wr_addr                 ;
reg            [   3: 0]                        wr_num                =0;
wire           [   3: 0]                        rd_addr                 ;

reg                                             wr_wen                =0;
wire           [511: 0]                         wr_data                 ;
wire           [511: 0]                         rd_data                 ;

wire           [ 127: 0]                        bram_idx_rdata          ;
wire           [ 127: 0]                        bram_idx_wdata          ;
wire           [   3: 0]                        bram_idx_waddr          ;
reg            [   3: 0]                        bram_idx_raddr        =0;
reg            [   7: 0]                        wr_wen_buf            =0;
reg                                             rdout_en              =0;
reg                                             rd_vld                =0;
reg                                             rd_init               =0;
wire                                            wr_wen_pos              ;
wire                                            wr_wen_neg              ;

reg            [  10: 0]                        rd_renum              =0;
wire                                            rd_eop                  ;
reg            [  39: 0]                        bid_rdinit_buf        =0;
reg                                             bid_rden_1st          =0;
wire                                            bid_rden_2nd            ;

wire                                            fifo_rdout              ;
reg            [   2: 0]                        rdout_en_buf          =0;
reg                                             rd_init_sop           =0;

reg            [   3: 0]                        bram_pwr_raddr        =0;
reg            [   3: 0]                        bram_pwr_rdnum        =0;
reg                                             pwr_rden              =0;
reg            [15:0][31: 0]                    pwr_rdout             =0;
reg bram_pwr_rden =0;

always @(posedge i_clk) begin
    if(sort_vld)
        wr_wen <= 1'b1;
    else if(wr_num == 'd15)
        wr_wen <= 1'b0;
end

always @ (posedge i_clk)begin
    if(wr_wen)
        wr_num <= wr_num + 'd1;
    else
        wr_num <= 'd0;
end


assign wr_addr = rbg_num[3:0];

for(genvar i=0; i<16; i=i+1)begin: gen_wr_data
    assign wr_data[i*32 +: 32] = sort_data[i][31:0];
end


always @(posedge i_clk) begin
    if(reset_syn)
        pwr_rden <= 1'b0;
    else if(rd_init_sop)
        pwr_rden <= 1'b1;
    else if(sort_done && bram_pwr_rden)
        pwr_rden <= 1'b1;
    else if(bram_pwr_rdnum == 15)
        pwr_rden <= 1'b0;
end 

always @(posedge i_clk) begin
    if(reset_syn)
        bram_pwr_raddr <= 'd0;
    else if(sort_done && bram_pwr_rden)begin
        if(bram_pwr_raddr==i_rbg_max)
            bram_pwr_raddr <= 'd0;
        else
            bram_pwr_raddr <= bram_pwr_raddr + 'd1;
    end
end


assign rd_addr = bram_pwr_raddr[3:0];



//--------------------------------------------------------------------------------------
// bram for beams power
//--------------------------------------------------------------------------------------
Simple_Dual_Port_BRAM_XPM_intel #(
    
    .WDATA_WIDTH                                        (512                    ),
    .NUMWORDS_A                                         (16                     ),
    .RDATA_WIDTH                                        (512                    ),
    .NUMWORDS_B                                         (16                     ),
    .INI_FILE                                           (                       ) 
)dram_beam_power(
    .clock                                              (i_clk                  ),
    .wren                                               (wr_wen                 ),
    .wraddress                                          (wr_addr                ),
    .data                                               (wr_data                ),
    .rdaddress                                          (rd_addr                ),
    .q                                                  (rd_data                ) 
);



//--------------------------------------------------------------------------------------
// Store the index of sorted beams to BRAM
//--------------------------------------------------------------------------------------
assign bram_idx_wdata = sort_addr[15:0];
assign bram_idx_waddr = {rbg_num[3:0]};

always @ (posedge i_clk)begin
    wr_wen_buf <= {wr_wen_buf[6:0], wr_wen};

    if(reset_syn)
        rdout_en <= 1'b0;
    else if(rbg_num==2)
        rdout_en <= 1'b1;
end

assign wr_wen_pos = wr_wen_buf[0] & (~wr_wen_buf[1]);
assign wr_wen_neg = wr_wen_buf[7] & (~wr_wen_buf[6]);


assign bid_rden_2nd = (sym_1st_done) ? i_rbg_load : rd_init;


always @(posedge i_clk) begin
    if(reset_syn)
        bram_idx_raddr <= 'd0;
    else if(rd_eop)
        bram_idx_raddr <= 'd0;
    else if(sort_done && bid_rden_2nd)begin
        if(bram_idx_raddr==i_rbg_max)
            bram_idx_raddr <= 'd0;
        else
            bram_idx_raddr <= bram_idx_raddr + 'd1;
    end
end

always @ (posedge i_clk) begin
    if(rd_vld)begin
       if(rd_renum == 1583)
            rd_renum <= 11'd0;
        else
            rd_renum <= rd_renum + 11'd1;
    end else
        rd_renum <= 11'd0;
end

assign rd_eop = (rd_renum == 11'd1583) ? 1'b1 : 1'b0;


//--------------------------------------------------------------------------------------
// debug
//--------------------------------------------------------------------------------------
reg            [   7: 0]                        renum                 =0;


always @ (posedge i_clk) begin
    if(sort_done)begin
       if(wr_wen_pos)
            renum <= 8'd0;
        else
            renum <= renum + 8'd1;
    end else
        renum <= 8'd0;
end

//--------------------------------------------------------------------------------------
// bram for beams index: 4 clock cycle delay
//--------------------------------------------------------------------------------------
Simple_Dual_Port_BRAM_XPM_intel
#(
    .WDATA_WIDTH                                        (128                    ),
    .NUMWORDS_A                                         (16                     ),
    .RDATA_WIDTH                                        (128                    ),
    .NUMWORDS_B                                         (16                     ),
    .INI_FILE                                           (                       ) 
)
dram_beam_index
(
    .clock                                              (i_clk                  ),
    .wren                                               (wr_wen                 ),
    .wraddress                                          (bram_idx_waddr         ),
    .data                                               (bram_idx_wdata         ),
    .rdaddress                                          (bram_idx_raddr         ),
    .q                                                  (bram_idx_rdata         ) 
);

//--------------------------------------------------------------------------------------
// the first read out 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(i_reset)
        sym_1st_done <= 1'b0;
    else if(i_symb_clr)
        sym_1st_done <= 1'b0;
    else if(rd_eop)
        sym_1st_done <= 1'b1;
end
always @ (posedge i_clk)begin
    bid_rdinit_buf <=  {bid_rdinit_buf[38:0], i_bid_rdinit};

    if(sym_1st_done)
        bid_rden_1st <= 1'b0;
    else
        bid_rden_1st <= bid_rdinit_buf[34];
end

always @ (posedge i_clk)begin
    rdout_en_buf[2:0] <=  {rdout_en_buf[1:0], rdout_en};

    if(!rdout_en)begin
        rd_init     <= 0;
        rd_init_sop <= 0;
    end else if(rdout_en_buf[2])begin
        rd_init     <= fifo_rdout;
        rd_init_sop <= 0;   
    end else begin
        rd_init     <= 0;
        rd_init_sop <= fifo_rdout;
    end
end

FIFO_SYNC_XPM_intel #(
    .NUMWORDS                                           (512                    ),
    .DATA_WIDTH                                         (1                      ) 
)fifo_sync_rdinit(                                                                   
    .rst                                                (reset_syn              ),
    .clk                                                (i_clk                  ),
    .wr_en                                              (sort_done              ),
    .din                                                (bid_rden_1st           ),
    .rd_en                                              (rdout_en               ),
    .dout                                               (fifo_rdout             ),
    .dout_valid                                         (                       ),
    .empty                                              (                       ),
    .full                                               (                       ),
    .usedw                                              (                       ),
    .almost_full                                        (                       ),
    .almost_empty                                       (                       ) 
); 

//--------------------------------------------------------------------------------------
// output 
//--------------------------------------------------------------------------------------
reg                                             rbg_sop               =0;
reg                                             rbg_sop_out           =0;
reg            [15:0][7: 0]                     beam_index_out        =0;
reg            [2:0][5: 0]                      rbg_num_out           =0;
reg            [   4: 0]                        rbg_load_1st_buf      =0;
reg            [  11: 0]                        rbg_load_2nd_buf      =0;
reg            [   2: 0]                        rbg_load_out_buf      =0;
reg            [   3: 0]                        sym_1st_done_buf      =0;


always @ (posedge i_clk)begin
    if(sym_1st_done)
        rbg_sop_out <= i_rbg_load;
    else
        rbg_sop_out <= rd_init_sop;
end

always @ (posedge i_clk)begin
    rbg_load_1st_buf <= {rbg_load_1st_buf[ 3:0], rd_init | rd_init_sop};
    rbg_load_2nd_buf <= {rbg_load_2nd_buf[10:0], i_rbg_load};
    sym_1st_done_buf <= {sym_1st_done_buf[2:0], sym_1st_done};
end

always @ (posedge i_clk)begin
    if(i_reset)
        rd_vld <= 1'b0;
    else if(rd_init_sop)
        rd_vld <= 1'b1;
    else if(rd_eop)
        rd_vld <= 1'b0;
end

always @(posedge i_clk) begin
    for(int i=0; i<16; i=i+1) begin: index_out_vec
        beam_index_out[i] <= bram_idx_rdata[i*8 +: 8];
    end
end
reg            [15:0][7: 0]                     beam_index_out2       =0;
always @(posedge i_clk) begin
    for(int i=0; i<16; i=i+1) begin: index_out_vec
        if(!sym_1st_done)
            beam_index_out2[i] <= bram_idx_rdata[i*8 +: 8];
        else if(i_rbg_load)
            beam_index_out2[i] <= bram_idx_rdata[i*8 +: 8];
    end
end

always @(posedge i_clk) begin
    rbg_num_out[0] <= {2'b00,bram_idx_raddr};
    for(int i=1; i<3; i=i+1) begin: rbg_num_out_dly
        rbg_num_out[i] <= rbg_num_out[i-1];
    end
end



always @(posedge i_clk) begin
    for(int i=0; i<16; i=i+1)begin
        if(bram_pwr_rden)
            pwr_rdout[i] <= rd_data[i*32 +: 32];
    end
end


always @(posedge i_clk) begin
    if(sym_1st_done_buf[3])
        bram_pwr_rden <= rbg_load_2nd_buf[7];
    else
        bram_pwr_rden <= rbg_load_1st_buf[0];
end

always @ (posedge i_clk)begin
    rbg_load_out_buf <= {rbg_load_out_buf[1:0], bram_pwr_rden};
end


assign o_data                 = pwr_rdout;
assign o_score                = score;
assign o_rbg_load             = rbg_load_out_buf[0];
assign o_rbg_num              = rbg_num_out[2];
assign o_tvalid               = rd_vld;
assign o_idx_sop              = rbg_sop_out;
assign o_beam_index           = beam_index_out;


endmodule