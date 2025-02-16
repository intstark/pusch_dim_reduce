//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: cpri_rxdata_top
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
module cpri_rxdata_top # (
    parameter                                       LANE                   = 8     ,
    parameter                                       DW                     = 32    ,
    parameter                                       ANT                    = 4     
)(
    input                                           i_clk                   ,// data clock
    input                                           i_reset                 ,// system reset
    input          [   1: 0]                        i_dr_mode               ,// re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 
    
    input                                           i_rx_rfp                ,
    input                                           i_enable                ,

    input          [LANE-1: 0]                      i_cpri_clk              ,// cpri rx clock
    input          [LANE-1: 0]                      i_cpri_rst              ,// cpri rx reset
    input          [LANE-1:0][63:0]                 i_cpri_rx_data          ,// cpri rx data
    input          [LANE-1: 0]                      i_cpri_rx_vld           ,// cpri rx valid

    output         [   3: 0]                        o_pkg_type              ,// package type
    output         [   6: 0]                        o_slot_idx              ,// slot index
    output         [   3: 0]                        o_symb_idx              ,// symbol index
    output                                          o_cell_idx              ,// cell index
    output         [LANE-1:0][63: 0]                o_info_0                ,// IQ HD
    output         [LANE-1:0][ 7: 0]                o_info_1                ,// FFT AGC
    output         [LANE-1:0][10: 0]                o_iq_addr               ,// CPRI addr 0-1583
    output         [LANE-1:0][ANT*32-1: 0]          o_iq_data               ,// CPRI data
    output         [LANE-1:0]                       o_iq_vld                ,// CPRI valid
    output         [LANE-1: 0]                      o_iq_last               ,
    output         [  15: 0]                        o_rx_err                 
);


//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------






//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
genvar gi;

wire           [LANE-1: 0]                      rx_buf_sop              ;
wire           [LANE-1: 0]                      rx_buf_vld              ;
wire           [LANE-1: 0]                      symb_eop                ;
wire                                            rx_buf_rden             ;
wire           [LANE-1:0]                       cpri_rx_ready           ;
wire           [LANE-1:0][63: 0]                cpri_data_buf           ;
wire           [LANE-1:0][63: 0]                fft_agc_buf             ;

wire           [LANE-1:0][7: 0]                 cpri_rx_err             ;
wire           [LANE-1:0][6: 0]                 cpri_addr_buf           ;
wire           [LANE-1: 0]                      cpri_buf_last           ;
wire           [LANE-1: 0]                      cpri_buf_vld            ;
wire           [LANE-1: 0]                      cpri_buf_rdy            ;

wire           [LANE-1:0][10: 0]                iq_addr                 ;
wire           [LANE-1:0][ANT*32-1: 0]          iq_data                 ;
wire           [LANE-1: 0]                      iq_vld                  ;
wire           [LANE-1: 0]                      iq_last                 ;
wire           [LANE-1:0][3: 0]                 pkg_type                ;
wire           [LANE-1:0][6: 0]                 slot_idx                ;
wire           [LANE-1:0][3: 0]                 symb_idx                ;
wire           [LANE-1: 0]                      cell_idx                ;
wire           [LANE-1:0][63: 0]                info_0                  ;
wire           [LANE-1:0][ 7: 0]                info_1                  ;

wire           [LANE-1:0][63: 0]                tx_data                 ;
wire           [LANE-1:0][6: 0]                 tx_addr                 ;
wire           [LANE-1: 0]                      tx_last                 ;
wire           [LANE-1: 0]                      tx_vld                  ;
wire           [LANE-1: 0]                      tx_rdy                  ;
wire           [   15: 0]                       fft_agc_base            ;
wire           [LANE-1:0][63: 0]                fft_agc_shift           ;


//--------------------------------------------------------------------------------------
// Reset synchronizer 
//--------------------------------------------------------------------------------------
reg                                             sys_reset               =0;
wire                                            cpri_rst_sync            ;

alt_reset_synchronizer #(.depth(2),.rst_value(1)) rreset_sync (.clk(i_clk),.reset_n(!(|i_cpri_rst)),.rst_out(cpri_rst_sync));

always @ (posedge i_clk)begin
    if(i_reset)
        sys_reset <= 1'b1;
    else if(cpri_rst_sync)
        sys_reset <= 1'b1;
    else
        sys_reset <= 1'b0;
end

//--------------------------------------------------------------------------------------
// BIST 
//--------------------------------------------------------------------------------------
(* DONT_TOUCH = "True" *) reg                     rx_vld_fst            =0;
(* DONT_TOUCH = "True" *) reg                     rx_vld_lst            =0;
(* DONT_TOUCH = "True" *) reg                     rx_vld_hit            =0;
(* DONT_TOUCH = "True" *) reg                     rx_buf_err            =0;
(* DONT_TOUCH = "True" *) reg                     rx_skew_err           =0;
(* DONT_TOUCH = "True" *) reg      [  15: 0]      rx_skew_num           =0;
(* DONT_TOUCH = "True" *) reg      [  15: 0]      rx_err                =0;

// count rx data skew number
always @ (posedge i_clk)begin
    rx_vld_fst <= |rx_buf_vld;
    rx_vld_lst <= &rx_buf_vld;
    if(i_reset)
        rx_vld_hit <= 1'b0;
    else if((!rx_vld_fst) && (|rx_buf_vld))
        rx_vld_hit <= 1'b0;
    else if(!(&rx_buf_vld) && rx_vld_lst)
        rx_vld_hit <= 1'b1;

    if(i_reset)
        rx_skew_num <= 16'd0;
    else if((!rx_vld_fst) && (|rx_buf_vld))
        rx_skew_num <= 'd0;
    else if((!rx_vld_hit) && (rx_vld_fst) && (!rx_vld_lst))
        rx_skew_num <= rx_skew_num + 'd1;
end

// rx data skew larger than 4 symbol error
always @ (posedge i_clk)begin
    if(i_reset)
        rx_skew_err <= 1'b0;
    else if((!rx_vld_fst) && (|rx_buf_vld))
        rx_skew_err <= 1'b0;
    else if(rx_skew_num > 16'd12672) // 4 symbol
        rx_skew_err <= 1'b1;
end

// rx buffer overflow error 
always @ (posedge i_clk)begin
    if(i_reset)
        rx_buf_err <= 1'b0;
    else if(&cpri_buf_rdy)
        rx_buf_err <= 1'b1;
    else
        rx_buf_err <= 1'b0;
end

//--------------------------------------------------------------------------------------
// output rx error flag
//--------------------------------------------------------------------------------------
// 0:   rx buffer overflow error
// 1:   rx data skew error
// 9:2  rx buffer symbol mismatch error
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    rx_err = {  6'd0                ,   // reserved
                cpri_rx_err[7][0]   ,   // rx buffer7 symbol mismatch
                cpri_rx_err[6][0]   ,   // rx buffer6 symbol mismatch
                cpri_rx_err[5][0]   ,   // rx buffer5 symbol mismatch
                cpri_rx_err[4][0]   ,   // rx buffer4 symbol mismatch
                cpri_rx_err[3][0]   ,   // rx buffer3 symbol mismatch
                cpri_rx_err[2][0]   ,   // rx buffer2 symbol mismatch
                cpri_rx_err[1][0]   ,   // rx buffer1 symbol mismatch
                cpri_rx_err[0][0]   ,   // rx buffer0 symbol mismatch
                rx_skew_err         ,   // rx skew error
                rx_buf_err              // rx buffer overflow error
            };
end

assign o_rx_err = rx_err;


//--------------------------------------------------------------------------------------
// cpri rx data buffer
//--------------------------------------------------------------------------------------
reg                                             rx_sop_fst            =0;
reg                                             rx_sop_lst            =0;
reg                                             rx_sop_hit            =0;
reg                                             rx_buf_clr            =0;
reg            [   7: 0]                        rx_skew_err_buf       =0;

// if skew is beyond 4 symbol, clear buffer and disable buffer read
assign rx_buf_rden = (&rx_buf_vld) & (!rx_skew_err);

always @ (posedge i_clk)begin
    rx_buf_clr <= rx_skew_err_buf[0] && (!rx_skew_err_buf[7]);

    if(i_reset)
        rx_skew_err_buf <= 8'd0;
    else
        rx_skew_err_buf <= {rx_skew_err_buf[7:0],rx_skew_err};
end


generate for(gi=0;gi<LANE;gi=gi+1) begin: gen_rx_buffer
    cpri_rx_buffer                                          cpri_rx_buffer
    (
        .i_cpri_clk                                         (i_cpri_clk    [gi]     ),
        .i_cpri_reset                                       (i_cpri_rst    [gi]     ),
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_dr_mode                                          (i_dr_mode              ),
        
        .i_rx_rfp                                           (i_rx_rfp | rx_buf_clr  ),
        .i_enable                                           (i_enable               ),
        
        .i_rx_data                                          (i_cpri_rx_data[gi]     ),
        .i_rvalid                                           (i_cpri_rx_vld [gi]     ),
        .i_rready                                           (cpri_rx_ready [gi]     ),
        .i_rd_en                                            (rx_buf_rden            ),
        .o_rd_vld                                           (rx_buf_vld    [gi]     ),
        .o_rx_sop                                           (rx_buf_sop    [gi]     ),
        .o_symb_eop                                         (symb_eop      [gi]     ),
        .o_fft_agc                                          (fft_agc_buf   [gi]     ),
        .o_tx_data                                          (cpri_data_buf [gi]     ),
        .o_tx_addr                                          (cpri_addr_buf [gi]     ),
        .o_tx_last                                          (cpri_buf_last [gi]     ),
        .o_tready                                           (cpri_buf_rdy  [gi]     ),
        .o_tvalid                                           (cpri_buf_vld  [gi]     ), 
        .o_rx_err                                           (cpri_rx_err   [gi]     ) 
    );
end
endgenerate

//--------------------------------------------------------------------------------------
// FFT AGC 
//--------------------------------------------------------------------------------------
agc_unpack                                              agc_unpack
(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (sys_reset              ),

    .i_cpri_data                                        (cpri_data_buf          ),
    .i_cpri_addr                                        (cpri_addr_buf          ),
    .i_cpri_last                                        (cpri_buf_last          ),
    .i_rvalid                                           (cpri_buf_vld           ),
    .i_rready                                           (                       ),

    .i_fft_agc                                          (fft_agc_buf            ),
    .i_symb_eop                                         (symb_eop               ),

    .o_fft_agc_base                                     (fft_agc_base           ),// {odd, even}
    .o_fft_agc_shift                                    (fft_agc_shift          ),// {odd, even}
    .o_tx_data                                          (tx_data                ),
    .o_tx_addr                                          (tx_addr                ),
    .o_tx_last                                          (tx_last                ),
    .o_tx_vld                                           (tx_vld                 ),
    .o_tready                                           (                       ) 
);



//------------------------------------------------------------------------------------------
//cpri unpack
//------------------------------------------------------------------------------------------
generate for(gi=0;gi<LANE;gi=gi+1) begin:gen_rxdata_unpack
    cpri_rxdata_unpack                                      cpri_rxdata_unpack_4ant
    (

        .i_clk                                              (i_clk                  ),
        .i_reset                                            (sys_reset              ),

        .i_cpri_data                                        (tx_data      [gi]      ),
        .i_cpri_addr                                        (tx_addr      [gi]      ),
        .i_cpri_last                                        (tx_last      [gi]      ),
        .i_cpri_vld                                         (tx_vld       [gi]      ),

        .i_fft_agc                                          (fft_agc_base           ),//{odd, even}
        .i_fft_shift                                        (fft_agc_shift[gi]      ),//{odd, even}

        .o_tready                                           (cpri_rx_ready[gi]      ), 

        .o_pkg_type                                         (pkg_type     [gi]      ),
        .o_slot_idx                                         (slot_idx     [gi]      ),
        .o_symb_idx                                         (symb_idx     [gi]      ),
        .o_cell_idx                                         (cell_idx     [gi]      ),
        .o_info_0                                           (info_0       [gi]      ),// IQ HD
        .o_info_1                                           (info_1       [gi]      ),// FFT AGC
        .o_iq_addr                                          (iq_addr      [gi]      ),// CPRI IQ addr
        .o_iq_data                                          (iq_data      [gi]      ),// CPRI IQ data
        .o_iq_vld                                           (iq_vld       [gi]      ),// CPRI IQ valid
        .o_iq_last                                          (iq_last      [gi]      ) // CPRI IQ last(132prb ends)
    );
end
endgenerate

//------------------------------------------------------------------------------------------
// Ouput assignment
//------------------------------------------------------------------------------------------
assign o_iq_data = iq_data;
assign o_iq_addr = iq_addr;
assign o_iq_vld  = iq_vld;
assign o_iq_last = iq_last;
assign o_info_0  = info_0;
assign o_info_1  = info_1;

assign o_pkg_type = pkg_type[0];
assign o_slot_idx = slot_idx[0];
assign o_symb_idx = symb_idx[0];
assign o_cell_idx = cell_idx[0];



endmodule