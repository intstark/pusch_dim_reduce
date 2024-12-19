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

    input                                           i_bid_rden              ,
    input          [   7: 0]                        i_rbg_max               ,

    output         [COL-1:0][IW-1: 0]               o_data                  ,
    output         [COL-1:0][7: 0]                  o_score                 ,
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
reg            [COL-1:0][IW-1: 0]               data_in               ='{default:0};
reg                                             rvalid_in             =0;
reg                                             rready_in             =0;
reg                                             enable_in             =0;
wire           [COL-1:0][7: 0]                  score                   ;
wire           [COL-1: 0]                       tvalid                  ;
wire           [COL-1: 0]                       tready                  ;
reg            [COL-1:0][IW-1: 0]               sort_data             ='{default:0};
reg            [COL-1:0][7: 0]                  sort_addr             ='{default:0};
reg                                             data_vld              =0;



//--------------------------------------------------------------------------------------
// data buffer 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    enable_in <= i_enable;
    rvalid_in <= i_rvalid;
    rready_in <= i_rready;
    for(int i=0;i<COL;i=i+1)begin
        data_in[i] <= i_data[i];
    end
end

//--------------------------------------------------------------------------------------
// compare data and generate smaller_score
//--------------------------------------------------------------------------------------
generate for(idx=0; idx<COL; idx=idx+1) begin: par_compare_x16
    par_compare #(
        .IW                                                 (IW                     ),
        .COL                                                (COL                    ) 
    ) par_compare (
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_data                                             (data_in                ),
        .i_index                                            (8'(idx)                ),
        .i_rready                                           (rready_in              ),
        .i_rvalid                                           (rvalid_in              ),
        .o_score                                            (score [idx]            ),
        .o_tvalid                                           (tvalid[idx]            ),
        .o_tready                                           (tready[idx]            ) 
    );
end
endgenerate


//--------------------------------------------------------------------------------------
// sort the data by score, smallest score first
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0; i<COL; i=i+1)begin
        if(tvalid[i])
            sort_data[score[i]] <= i_data[i];
    end
end	

//--------------------------------------------------------------------------------------
// store the index of the data by score 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0; i<COL; i=i+1)begin
        sort_addr[score[i]] <= 8'(i);
    end
end	

//--------------------------------------------------------------------------------------
// store the index of the data by score 
//--------------------------------------------------------------------------------------
reg            [   5: 0]                        rbg_num               =0;
reg            [   7: 0]                        enable_buf            =0;
reg                                             sort_done             =0;


always @ (posedge i_clk)begin
    data_vld <= tvalid[0];
    enable_buf <= {enable_buf[6:0], enable_in};
end	

always @ (posedge i_clk)begin
    if(i_reset)
        rbg_num <= 'd0;
    else if(enable_buf[7]==0 && enable_buf[6]==1)
        rbg_num <= 'd0;
    else if(enable_buf[7] && tvalid[0])
        rbg_num <= rbg_num + 'd1;
end

always @ (posedge i_clk)begin
    if(i_reset)
        sort_done <= 'd0;
    else if(tvalid[0])
        sort_done <= 'd1;

end

//--------------------------------------------------------------------------------------
// Store the power of 16 beams to BRAM
//--------------------------------------------------------------------------------------
wire           [   7: 0]                        wr_addr                 ;
reg            [   3: 0]                        wr_num                =0;
reg            [   7: 0]                        rd_addr               =0;

reg                                             wr_wen                =0;
wire           [IW-1: 0]                        wr_data                 ;
wire           [IW-1: 0]                        rd_data                 ;


always @(posedge i_clk) begin
    if(tvalid[0])
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


assign wr_addr = {rbg_num[3:0], wr_num[3:0]};
assign wr_data = sort_data[wr_num];

  
//--------------------------------------------------------------------------------------
// bram for beams power
//--------------------------------------------------------------------------------------
Simple_Dual_Port_BRAM_XPM_intel
#(
    
    .WDATA_WIDTH                                        (IW                     ),
    .NUMWORDS_A                                         (256                    ),
    .RDATA_WIDTH                                        (IW                     ),
    .NUMWORDS_B                                         (256                    ),
    .INI_FILE                                           (                       ) 
)
dram_beam_power
(
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
wire           [ 127: 0]                        bram_idx_rdata          ;
wire           [ 127: 0]                        bram_idx_wdata          ;
wire           [   3: 0]                        bram_idx_waddr          ;
reg            [   3: 0]                        bram_idx_raddr        =0;
reg            [   7: 0]                        wr_wen_buf            =0;
reg                                             rdout_en              =0;
reg            [   3: 0]                        rd_vld                =0;
wire                                            rd_init                 ;
wire                                            wr_wen_pos              ;
wire                                            wr_wen_neg              ;

assign bram_idx_wdata = sort_addr[15:0];
assign bram_idx_waddr = {rbg_num[3:0]};

always @ (posedge i_clk)begin
    wr_wen_buf <= {wr_wen_buf[6:0], wr_wen};

    if(i_reset)
        rdout_en <= 1'b0;
    else if(rbg_num==2)
        rdout_en <= 1'b1;
end

assign wr_wen_pos = wr_wen_buf[0] & (~wr_wen_buf[1]);
assign wr_wen_neg = wr_wen_buf[7] & (~wr_wen_buf[6]);

always @ (posedge i_clk)begin
    rd_vld <= {rd_vld[2:0], rdout_en};
end

always @(posedge i_clk) begin
    if(i_reset)
        bram_idx_raddr <= 'd0;
    else if(i_bid_rden || rd_init)begin
        if(bram_idx_raddr==i_rbg_max)
            bram_idx_raddr <= 'd0;
        else
            bram_idx_raddr <= bram_idx_raddr + 'd1;
    end
end

// debug
reg            [   7: 0]                        renum                 =0;
reg            [   7: 0]                        renum2                =0;
always @ (posedge i_clk) begin
    if(sort_done)begin
       if(wr_wen_pos)
            renum <= 8'd0;
        else
            renum <= renum + 8'd1;
    end else
        renum <= 8'd0;
end

always @ (posedge i_clk) begin
    if(sort_done)begin
       if(rd_init)
            renum2 <= 8'd0;
        else
            renum2 <= renum2 + 8'd1;
    end else
        renum2 <= 8'd0;
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


FIFO_SYNC_XPM_intel #(
    .NUMWORDS                                           (512                    ),
    .DATA_WIDTH                                         (1                      ) 
)INST_INFO                                            
(                                                                   
    .rst                                                (i_reset                ),
    .clk                                                (i_clk                  ),
    .wr_en                                              (sort_done              ),
    .din                                                (wr_wen_pos             ),
    .rd_en                                              (rdout_en               ),
    .dout                                               (rd_init                ),
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

always @ (posedge i_clk)begin
    if(i_reset)
        rbg_sop <= 1'b0;
    else if(rbg_num==1)
        rbg_sop <= wr_wen_pos;
end

assign o_data                 = sort_data;
assign o_score                = score;
assign o_rbg_load             = data_vld;
assign o_rbg_num              = rbg_num;
assign o_tvalid               = rd_vld[3];
assign o_idx_sop              = rbg_sop;



generate 
for(idx=0; idx<16; idx=idx+1) begin: index_out_vec
    assign o_beam_index[idx] = bram_idx_rdata[idx*8 +: 8];
end
endgenerate



endmodule