//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/02/28 15:54:23
// Design Name: 
// Module Name: pusch_dr_top_tb
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
`timescale 1ns/1ps

`define CLOCK_PERIOD    10.0
`define T1US            1000
`define TCLK0_DELAY     `T1US*100
`define TCLK1_DELAY     `T1US*100+5
`define SIM_ENDS_TIME   4000000


module pusch_dr_top_vec128;



parameter                                           FILE_IQDATA00          = "../vector/datain/pusch_group0/LAN1.txt";
parameter                                           FILE_IQDATA01          = "../vector/datain/pusch_group0/LAN2.txt";
parameter                                           FILE_IQDATA02          = "../vector/datain/pusch_group0/LAN3.txt";
parameter                                           FILE_IQDATA03          = "../vector/datain/pusch_group0/LAN4.txt";
parameter                                           FILE_IQDATA04          = "../vector/datain/pusch_group0/LAN5.txt";
parameter                                           FILE_IQDATA05          = "../vector/datain/pusch_group0/LAN6.txt";
parameter                                           FILE_IQDATA06          = "../vector/datain/pusch_group0/LAN7.txt";
parameter                                           FILE_IQDATA07          = "../vector/datain/pusch_group0/LAN8.txt";
parameter                                           FILE_IQDATA10          = "../vector/datain/pusch_group1/LAN1.txt";
parameter                                           FILE_IQDATA11          = "../vector/datain/pusch_group1/LAN2.txt";
parameter                                           FILE_IQDATA12          = "../vector/datain/pusch_group1/LAN3.txt";
parameter                                           FILE_IQDATA13          = "../vector/datain/pusch_group1/LAN4.txt";
parameter                                           FILE_IQDATA14          = "../vector/datain/pusch_group1/LAN5.txt";
parameter                                           FILE_IQDATA15          = "../vector/datain/pusch_group1/LAN6.txt";
parameter                                           FILE_IQDATA16          = "../vector/datain/pusch_group1/LAN7.txt";
parameter                                           FILE_IQDATA17          = "../vector/datain/pusch_group1/LAN8.txt";

parameter                                           FILE_TX_DATA           = "./des_tx_data.txt";
parameter                                           FILE_RX_DATA0          = "./des_rx_data0.txt";
parameter                                           FILE_RX_DATA1          = "./des_rx_data1.txt";
parameter                                           FILE_RX_DATA2          = "./des_rx_data2.txt";
parameter                                           FILE_RX_DATA3          = "./des_rx_data3.txt";
parameter                                           FILE_RX_DATA4          = "./des_rx_data4.txt";
parameter                                           FILE_RX_DATA5          = "./des_rx_data5.txt";
parameter                                           FILE_RX_DATA6          = "./des_rx_data6.txt";
parameter                                           FILE_RX_DATA7          = "./des_rx_data7.txt";
parameter                                           FILE_UZIP_DATA0        = "./des_uzip_data0.txt";
parameter                                           FILE_UZIP_DATA1        = "./des_uzip_data1.txt";
parameter                                           FILE_UZIP_DATA2        = "./des_uzip_data2.txt";
parameter                                           FILE_UZIP_DATA3        = "./des_uzip_data3.txt";
parameter                                           FILE_UZIP_DATA4        = "./des_uzip_data4.txt";
parameter                                           FILE_UZIP_DATA5        = "./des_uzip_data5.txt";
parameter                                           FILE_UZIP_DATA6        = "./des_uzip_data6.txt";
parameter                                           FILE_UZIP_DATA7        = "./des_uzip_data7.txt";
parameter                                           FILE_BEAMS_DATA        = "./des_beams_data.txt";
parameter                                           FILE_BEAMS_PWR         = "./des_beams_pwr.txt";
parameter                                           FILE_BEAMS_SORT        = "./des_beams_sort.txt";
parameter                                           FILE_BEAMS_IDX         = "./des_beams_idx.txt";
parameter                                           FILE_CPRS_DATA         = "compress_data.txt";
parameter                                           FILE_DRIN_DATA         = "des_dr_datain.txt";
parameter                                           FILE_CPRS_OUT0         = "./des_tx_cpri0.txt";
parameter                                           FILE_CPRS_OUT1         = "./des_tx_cpri1.txt";
parameter                                           FILE_CPRS_OUT2         = "./des_tx_cpri2.txt";
parameter                                           FILE_CPRS_OUT3         = "./des_tx_cpri3.txt";
parameter                                           FILE_DROUT0_HEX        = "./des_dr_out0.txt";
parameter                                           FILE_DROUT15_HEX       = "./des_dr_out15.txt";


// Parameters
parameter                                           numSLOT                = 2     ;
parameter                                           numSYM                 = 14    ;
parameter                                           numPRB                 = 132   ;
parameter                                           numRE                  = 12    ;
parameter                                           numDL                  = 2*numPRB*numSYM*numRE*numSLOT;
parameter                                           numTDL                 = 4*numPRB*numRE;

// Parameters
parameter                                           DIN_ANTS               = 4     ;
parameter                                           ANT                    = 32    ;
parameter                                           IW                     = 32    ;
parameter                                           OW                     = 48    ;


// Signals
genvar  gi,gj;
integer fid_iq_data00, fid_iq_data01, fid_iq_data02, fid_iq_data03, fid_iq_data04, fid_iq_data05, fid_iq_data06, fid_iq_data07;
integer fid_iq_data10, fid_iq_data11, fid_iq_data12, fid_iq_data13, fid_iq_data14, fid_iq_data15, fid_iq_data16, fid_iq_data17;
integer fid_iq_data20, fid_iq_data21, fid_iq_data22, fid_iq_data23, fid_iq_data24, fid_iq_data25, fid_iq_data26, fid_iq_data27;
integer fid_iq_data30, fid_iq_data31, fid_iq_data32, fid_iq_data33, fid_iq_data34, fid_iq_data35, fid_iq_data36, fid_iq_data37;
integer fid_tx_data, fid_beams_data;
integer fid_rx_data0,fid_rx_data1,fid_rx_data2,fid_rx_data3,fid_rx_data4,fid_rx_data5,fid_rx_data6,fid_rx_data7;
integer fid_uzip_data0,fid_uzip_data1,fid_uzip_data2,fid_uzip_data3,fid_uzip_data4,fid_uzip_data5,fid_uzip_data6,fid_uzip_data7;
integer fid_beams_pwr, fid_beams_sort,fid_beams_idx;
integer fid_dr_data;
integer fid_ants_data;
integer fid_tx_cpri0, fid_tx_cpri1, fid_tx_cpri2, fid_tx_cpri3;
integer fid_drout0_hex, fid_drout15_hex;


// Inputs
reg                                             i_clk                 =0;
reg                                             reset                 =1;
reg                                             dr1_reset             =1;
reg                                             dr2_reset             =1;
reg                                             tx_hfp                =0;
reg            [   1: 0]                        rbg_size              =2;

wire           [1:0][   7: 0]                   cpri_clk                ;
wire           [1:0][   7: 0]                   cpri_rst                ;
wire           [1:0][7:0][63: 0]                cpri_rx_data            ;
wire           [1:0][   7: 0]                   cpri_rx_vld             ;



reg            [1:0][7:0][63: 0]                cpri_datain           =0;
reg            [63: 0]                          cpri_datain_0[0:7][0:44351] ='{default:0};
reg            [63: 0]                          cpri_datain_1[0:7][0:44351] ='{default:0};
wire                                            cpri_data_vld           ;
reg                                             cpri_sopin            =0;
reg                                             cpri1_sopin           =0;
reg            [   6: 0]                        chip_num              =96;
wire                                            cpri_iq_vld             ;

wire           [3:0][63: 0]                     cpri_tx_data            ;
reg            [   3: 0]                        cpri_tx_clk           =0;
wire           [   3: 0]                        cpri_tx_vld             ;
reg                                             cpri_tx_rst           =1;
reg            [   1: 0]                        rxbuf_en              =3;
reg            [   3: 0]                        symb_dly              =0;
reg                                             srs_slot_en           =0;
reg                                             data_sel              =0;
wire           [   7: 0]                        pus_rx_rst              ;
wire           [7:0][63: 0]                     pus_rx_data             ;
wire           [   7: 0]                        pus_rx_vld              ;

//------------------------------------------------------------------------------------------
// UL data
//------------------------------------------------------------------------------------------
assign cpri_clk    [0] = {8{i_clk}};
assign cpri_rst    [0] = {8{reset}};
assign cpri_rx_data[0] = cpri_datain[0]; 
assign cpri_rx_vld [0] = {{4{cpri1_sopin}},{4{cpri_sopin}}};

assign cpri_clk    [1] = {8{i_clk}};
assign cpri_rst    [1] = {8{reset}};
assign cpri_rx_data[1] = cpri_datain[1]; 
assign cpri_rx_vld [1] = {8{cpri_sopin}};




reg            [3:0][7: 0]                      cpri_cnt              =0;
wire           [   3: 0]                        iq_tx_enable            ;
reg            [   1: 0]                        tx_hfp_buf            =0;
wire                                            tx_hfp_pos              ;

generate for(gi=0;gi<4;gi=gi+1) begin:gen_iq_tx_enable
    always @(posedge cpri_tx_clk[gi]) begin
        if(reset)
            cpri_cnt[gi] <= 8'd0;
        else if(cpri_cnt[gi] >= 8'd95)
            cpri_cnt[gi] <= 8'd0;
        else
            cpri_cnt[gi] <= cpri_cnt[gi] + 1'b1;
    end 

    assign iq_tx_enable[gi] = (cpri_cnt[gi] >= 8'd95);
end
endgenerate

always @ (posedge i_clk)begin
    tx_hfp_buf <= {tx_hfp_buf[0],tx_hfp};
end

assign tx_hfp_pos = tx_hfp_buf[0] & (~tx_hfp_buf[1]);


//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pusch_dr_top                                            pusch_dr_top_aiu0(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (dr1_reset              ),
    
    .i_aiu_idx                                          (2'b00                  ),// AIU index 0-3
    .i_rbg_size                                         (rbg_size               ),// default:2'b10 16rb
    .i_dr_mode                                          (2'b00                  ),// re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 
    
    .i_rx_rfp                                           (tx_hfp                 ),
    .i_enable                                           (rxbuf_en[0]            ),

    .i_l0_cpri_clk                                      (cpri_clk    [0][0]     ),// lane0 cpri rx clock
    .i_l0_cpri_rst                                      (cpri_rst    [0][0]     ),// lane0 cpri rx reset
    .i_l0_cpri_rx_data                                  (cpri_rx_data[0][0]     ),// lane0 cpri rx data
    .i_l0_cpri_rx_vld                                   (cpri_rx_vld [0][0]     ),
    
    .i_l1_cpri_clk                                      (cpri_clk    [0][1]     ),
    .i_l1_cpri_rst                                      (cpri_rst    [0][1]     ),
    .i_l1_cpri_rx_data                                  (cpri_rx_data[0][1]     ),
    .i_l1_cpri_rx_vld                                   (cpri_rx_vld [0][1]     ),

    .i_l2_cpri_clk                                      (cpri_clk    [0][2]     ),
    .i_l2_cpri_rst                                      (cpri_rst    [0][2]     ),
    .i_l2_cpri_rx_data                                  (cpri_rx_data[0][2]     ),
    .i_l2_cpri_rx_vld                                   (cpri_rx_vld [0][2]     ),
                                                                     
    .i_l3_cpri_clk                                      (cpri_clk    [0][3]     ),
    .i_l3_cpri_rst                                      (cpri_rst    [0][3]     ),
    .i_l3_cpri_rx_data                                  (cpri_rx_data[0][3]     ),
    .i_l3_cpri_rx_vld                                   (cpri_rx_vld [0][3]     ),

    .i_l4_cpri_clk                                      (cpri_clk    [0][4]     ),
    .i_l4_cpri_rst                                      (cpri_rst    [0][4]     ),
    .i_l4_cpri_rx_data                                  (cpri_rx_data[0][4]     ),
    .i_l4_cpri_rx_vld                                   (cpri_rx_vld [0][4]     ),
                                                                     
    .i_l5_cpri_clk                                      (cpri_clk    [0][5]     ),
    .i_l5_cpri_rst                                      (cpri_rst    [0][5]     ),
    .i_l5_cpri_rx_data                                  (cpri_rx_data[0][5]     ),
    .i_l5_cpri_rx_vld                                   (cpri_rx_vld [0][5]     ),
                                                         
    .i_l6_cpri_clk                                      (cpri_clk    [0][6]     ),
    .i_l6_cpri_rst                                      (cpri_rst    [0][6]     ),
    .i_l6_cpri_rx_data                                  (cpri_rx_data[0][6]     ),
    .i_l6_cpri_rx_vld                                   (cpri_rx_vld [0][6]     ),
                                                                     
    .i_l7_cpri_clk                                      (cpri_clk    [0][7]     ),
    .i_l7_cpri_rst                                      (cpri_rst    [0][7]     ),
    .i_l7_cpri_rx_data                                  (cpri_rx_data[0][7]     ),
    .i_l7_cpri_rx_vld                                   (cpri_rx_vld [0][7]     ),
	 
    .i_cpri0_tx_clk                                     (cpri_tx_clk [0]        ),
    .i_cpri0_tx_enable                                  (iq_tx_enable[0]        ),
    .o_cpri0_tx_data                                    (cpri_tx_data[0]        ),
    .o_cpri0_tx_vld                                     (cpri_tx_vld [0]        ),
                                                                     
    .i_cpri1_tx_clk                                     (cpri_tx_clk [1]        ),
    .i_cpri1_tx_enable                                  (iq_tx_enable[1]        ),
    .o_cpri1_tx_data                                    (cpri_tx_data[1]        ),
    .o_cpri1_tx_vld                                     (cpri_tx_vld [1]        ) 
);



//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pusch_dr_top                                            pusch_dr_top_aiu1(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (dr2_reset              ),
    
    .i_aiu_idx                                          (2'b01                  ),// AIU index 0-3
    .i_rbg_size                                         (rbg_size               ),// default:2'b10 16rb
    .i_dr_mode                                          (2'b00                  ),// re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 

    .i_rx_rfp                                           (tx_hfp                 ),
    .i_enable                                           (rxbuf_en[1]            ),

    .i_l0_cpri_clk                                      (cpri_clk    [1][0]     ),// lane0 cpri rx clock
    .i_l0_cpri_rst                                      (cpri_rst    [1][0]     ),// lane0 cpri rx reset
    .i_l0_cpri_rx_data                                  (cpri_rx_data[1][0]     ),// lane0 cpri rx data
    .i_l0_cpri_rx_vld                                   (cpri_rx_vld [1][0]     ),
    
    .i_l1_cpri_clk                                      (cpri_clk    [1][1]     ),
    .i_l1_cpri_rst                                      (cpri_rst    [1][1]     ),
    .i_l1_cpri_rx_data                                  (cpri_rx_data[1][1]     ),
    .i_l1_cpri_rx_vld                                   (cpri_rx_vld [1][1]     ),

    .i_l2_cpri_clk                                      (cpri_clk    [1][2]     ),
    .i_l2_cpri_rst                                      (cpri_rst    [1][2]     ),
    .i_l2_cpri_rx_data                                  (cpri_rx_data[1][2]     ),
    .i_l2_cpri_rx_vld                                   (cpri_rx_vld [1][2]     ),
                                                                     
    .i_l3_cpri_clk                                      (cpri_clk    [1][3]     ),
    .i_l3_cpri_rst                                      (cpri_rst    [1][3]     ),
    .i_l3_cpri_rx_data                                  (cpri_rx_data[1][3]     ),
    .i_l3_cpri_rx_vld                                   (cpri_rx_vld [1][3]     ),

    .i_l4_cpri_clk                                      (cpri_clk    [1][4]     ),
    .i_l4_cpri_rst                                      (cpri_rst    [1][4]     ),
    .i_l4_cpri_rx_data                                  (cpri_rx_data[1][4]     ),
    .i_l4_cpri_rx_vld                                   (cpri_rx_vld [1][4]     ),
                                                                     
    .i_l5_cpri_clk                                      (cpri_clk    [1][5]     ),
    .i_l5_cpri_rst                                      (cpri_rst    [1][5]     ),
    .i_l5_cpri_rx_data                                  (cpri_rx_data[1][5]     ),
    .i_l5_cpri_rx_vld                                   (cpri_rx_vld [1][5]     ),
                                                         
    .i_l6_cpri_clk                                      (cpri_clk    [1][6]     ),
    .i_l6_cpri_rst                                      (cpri_rst    [1][6]     ),
    .i_l6_cpri_rx_data                                  (cpri_rx_data[1][6]     ),
    .i_l6_cpri_rx_vld                                   (cpri_rx_vld [1][6]     ),
                                                                     
    .i_l7_cpri_clk                                      (cpri_clk    [1][7]     ),
    .i_l7_cpri_rst                                      (cpri_rst    [1][7]     ),
    .i_l7_cpri_rx_data                                  (cpri_rx_data[1][7]     ),
    .i_l7_cpri_rx_vld                                   (cpri_rx_vld [1][7]     ),
	 
    .i_cpri0_tx_clk                                     (cpri_tx_clk    [2]     ),
    .i_cpri0_tx_enable                                  (iq_tx_enable   [2]     ),
    .o_cpri0_tx_data                                    (cpri_tx_data   [2]     ),
    .o_cpri0_tx_vld                                     (cpri_tx_vld    [2]     ),
                                                                     
    .i_cpri1_tx_clk                                     (cpri_tx_clk    [3]     ),
    .i_cpri1_tx_enable                                  (iq_tx_enable   [3]     ),
    .o_cpri1_tx_data                                    (cpri_tx_data   [3]     ),
    .o_cpri1_tx_vld                                     (cpri_tx_vld    [3]     ) 
);

reg            [   3: 0]                        cpri_tx_sopo          =0;
wire                                            cpri_sop_cprio[0:3]     ;
wire           [  63: 0]                        cpri_dat_cprio[0:3]     ;


always @(posedge i_clk) begin
    cpri_tx_sopo <= iq_tx_enable;
end

Cpri_Ant_Prb_Rearrange_Top                              u_Cpri_Ant_Prb_Rearrange_Top(
    .clk                                                (i_clk                  ),
    .rst                                                (reset                  ),
					
    .pus_sop0_i                                         (cpri_tx_sopo [0]        ),//AIU slave
    .pus_dat0_i                                         (cpri_tx_data[0]        ),//AIU slave  			
    .pus_sop1_i                                         (cpri_tx_sopo [1]        ),//AIU slave
    .pus_dat1_i                                         (cpri_tx_data[1]        ),//AIU slave  			
    .pus_sop2_i                                         (cpri_tx_sopo [2]        ),//AIU master
    .pus_dat2_i                                         (cpri_tx_data[2]        ),//AIU master      			  
    .pus_sop3_i                                         (cpri_tx_sopo [3]        ),//AIU master
    .pus_dat3_i                                         (cpri_tx_data[3]        ),//AIU master       
							
    .pus_sop0_o                                         (cpri_sop_cprio[0]      ),
    .pus_dat0_o                                         (cpri_dat_cprio[0]      ),
    .pus_sop1_o                                         (cpri_sop_cprio[1]      ),
    .pus_dat1_o                                         (cpri_dat_cprio[1]      ),
    .pus_sop2_o                                         (cpri_sop_cprio[2]      ),
    .pus_dat2_o                                         (cpri_dat_cprio[2]      ),
    .pus_sop3_o                                         (cpri_sop_cprio[3]      ),
    .pus_dat3_o                                         (cpri_dat_cprio[3]      ) 
);

//aiu --> bbu 
for(genvar cpri_j=0;cpri_j<4;cpri_j=cpri_j+1)begin: cpri_tx_gen
    cpri_tx_gen_top                                         u_cpri_tx_gen_top(
        .wr_clk                                             (i_clk                  ),
        .wr_rst                                             (reset                  ),
        .rd_clk                                             (i_clk                  ),
        .rd_rst                                             (reset                  ),
        .i_cpri_sop                                         (cpri_sop_cprio[cpri_j] ),
        .i_cpri_wdata                                       (cpri_dat_cprio[cpri_j] ),

        .i_iq_tx_enable                                     (iq_tx_enable[cpri_j]   ),
        .o_iq_tx_valid                                      (                       ),
        .o_iq_tx_data                                       (                       ) 

    );
end


// Clock generation
initial begin
    i_clk = 0;
    forever #(`CLOCK_PERIOD/2) i_clk = ~i_clk;
end

// Tx Clock generation
initial begin
    #(`TCLK0_DELAY) cpri_tx_clk[0] = 1;
    forever #(`CLOCK_PERIOD/2) cpri_tx_clk[0] = ~cpri_tx_clk[0];
end

// Tx Clock generation
initial begin
    #(`TCLK1_DELAY) cpri_tx_clk[1] = 1;
    forever #(`CLOCK_PERIOD/2) cpri_tx_clk[1] = ~cpri_tx_clk[1];
end


// Reset generation
initial begin
    #(`CLOCK_PERIOD*10) reset = 1'b0; 
    dr1_reset = 1'b0;
    dr2_reset = 1'b0;
    #(`TCLK0_DELAY) cpri_tx_rst = 0;
//    #(`T1US*100) reset = 1'b1;
//    #(`CLOCK_PERIOD*10) reset = 1'b0;
//    #(`T1US*200) dr1_reset = 1'b1;
//    #(`CLOCK_PERIOD*10) dr1_reset = 1'b0;
//    #(`T1US*700) dr2_reset = 1'b1;
//    #(`CLOCK_PERIOD*10) dr2_reset = 1'b0;
end

// Reset generation
initial begin
    #(`CLOCK_PERIOD*4 ) tx_hfp = 1'b1;
    #(`CLOCK_PERIOD*2 ) tx_hfp = 1'b0;
    #(`T1US*500) rxbuf_en = 2'b11;
    #(`T1US*100) rxbuf_en = 2'b11;
    #(`T1US*300) srs_slot_en   = 1'b1;
    #(`T1US*300) srs_slot_en   = 1'b0;
    #(`T1US*100) tx_hfp = 1'b1;symb_dly = 2;rxbuf_en = 3;
    #(`CLOCK_PERIOD*2 ) tx_hfp = 1'b0;
    #(`T1US*1000) tx_hfp = 1'b1;
    #(`CLOCK_PERIOD*2 ) tx_hfp = 1'b0;
    #(`T1US*1000) tx_hfp = 1'b1;
    #(`CLOCK_PERIOD*2 ) tx_hfp = 1'b0;
end

// Tx Clock generation
initial begin
    #(`TCLK0_DELAY) cpri_tx_clk[2] = 1;
    forever #(`CLOCK_PERIOD/2) cpri_tx_clk[2] = ~cpri_tx_clk[2];
end

// Tx Clock generation
initial begin
    #(`TCLK1_DELAY) cpri_tx_clk[3] = 1;
    forever #(`CLOCK_PERIOD/2) cpri_tx_clk[3] = ~cpri_tx_clk[3];
end


//------------------------------------------------------------------------------------------
// Input data file
//------------------------------------------------------------------------------------------
initial begin
    fid_iq_data00   = $fopen(FILE_IQDATA00,"r");
    fid_iq_data01   = $fopen(FILE_IQDATA01,"r");
    fid_iq_data02   = $fopen(FILE_IQDATA02,"r");
    fid_iq_data03   = $fopen(FILE_IQDATA03,"r");
    fid_iq_data04   = $fopen(FILE_IQDATA04,"r");
    fid_iq_data05   = $fopen(FILE_IQDATA05,"r");
    fid_iq_data06   = $fopen(FILE_IQDATA06,"r");
    fid_iq_data07   = $fopen(FILE_IQDATA07,"r");

    fid_iq_data10   = $fopen(FILE_IQDATA10,"r");
    fid_iq_data11   = $fopen(FILE_IQDATA11,"r");
    fid_iq_data12   = $fopen(FILE_IQDATA12,"r");
    fid_iq_data13   = $fopen(FILE_IQDATA13,"r");
    fid_iq_data14   = $fopen(FILE_IQDATA14,"r");
    fid_iq_data15   = $fopen(FILE_IQDATA15,"r");
    fid_iq_data16   = $fopen(FILE_IQDATA16,"r");
    fid_iq_data17   = $fopen(FILE_IQDATA17,"r");

    if(fid_iq_data00)
        $display("succeed open file %s",FILE_TX_DATA);

    #(`SIM_ENDS_TIME);
    $fclose(fid_iq_data00);
    $fclose(fid_iq_data01);
    $fclose(fid_iq_data02);
    $fclose(fid_iq_data03);
    $fclose(fid_iq_data04);
    $fclose(fid_iq_data05);
    $fclose(fid_iq_data06);
    $fclose(fid_iq_data07);

    $fclose(fid_iq_data10);
    $fclose(fid_iq_data11);
    $fclose(fid_iq_data12);
    $fclose(fid_iq_data13);
    $fclose(fid_iq_data14);
    $fclose(fid_iq_data15);
    $fclose(fid_iq_data16);
    $fclose(fid_iq_data17);
    $stop;
end


initial begin
    $readmemh(FILE_IQDATA00, cpri_datain_0[0]);
    $readmemh(FILE_IQDATA01, cpri_datain_0[1]);
    $readmemh(FILE_IQDATA02, cpri_datain_0[2]);
    $readmemh(FILE_IQDATA03, cpri_datain_0[3]);
    $readmemh(FILE_IQDATA04, cpri_datain_0[4]);
    $readmemh(FILE_IQDATA05, cpri_datain_0[5]);
    $readmemh(FILE_IQDATA06, cpri_datain_0[6]);
    $readmemh(FILE_IQDATA07, cpri_datain_0[7]);

    $readmemh(FILE_IQDATA10, cpri_datain_1[0]);
    $readmemh(FILE_IQDATA11, cpri_datain_1[1]);
    $readmemh(FILE_IQDATA12, cpri_datain_1[2]);
    $readmemh(FILE_IQDATA13, cpri_datain_1[3]);
    $readmemh(FILE_IQDATA14, cpri_datain_1[4]);
    $readmemh(FILE_IQDATA15, cpri_datain_1[5]);
    $readmemh(FILE_IQDATA16, cpri_datain_1[6]);
    $readmemh(FILE_IQDATA17, cpri_datain_1[7]);
end


reg            [  15: 0]                        addr                  =0;
reg            [  15: 0]                        addr1                 =0;
reg            [  7: 0]                         dw_num                =0;
reg            [  11: 0]                        hold_cnt              =0;
reg                                             cpri1_en              =0;
wire                                            cpri1_data_vld          ;
wire                                            cpri1_iq_vld            ;
wire                                            dw_num_vld              ;


always_ff @ (posedge i_clk)begin
    if(reset | tx_hfp_pos)
        cpri1_en <= 1'b0;
    else if(symb_dly == 14)
        cpri1_en <= 1'b0;
    else if(symb_dly == 0)
        cpri1_en <= 1'b1;
    else if(cpri_iq_vld && addr == 3168*symb_dly)
        cpri1_en <= 1'b1;
end

always_ff @ (posedge i_clk)begin
    if(reset | tx_hfp_pos)
        addr <= 0;
    else if(addr >= 44352)
        addr <= 44352;
    else if(cpri_data_vld)
        addr <= addr + 1;

    if(reset | tx_hfp_pos)
        dw_num <= 96;
    else if(dw_num >= 95)
        dw_num <= 0;
    else
        dw_num <= dw_num + 1;

    if(reset | tx_hfp_pos)
        chip_num <= 0;
    else if(chip_num == 50 && dw_num == 95)
        chip_num <= 0;
    else if(dw_num == 95)
        chip_num <= chip_num + 1;
end

always_ff @ (posedge i_clk)begin
    if(reset | tx_hfp_pos)
        addr1 <= 0;
    else if(addr1 >= 44352)
        addr1 <= 44352;
    else if(cpri1_data_vld)
        addr1 <= addr1 + 1;
end

assign dw_num_vld = (dw_num< 96 && chip_num<33) ? 1'b1 : 1'b0;
assign cpri_data_vld = (dw_num_vld && addr <44352) ? 1'b1 : 1'b0;
assign cpri_iq_vld = (dw_num == 0) ? 1'b1 : 1'b0;

assign cpri1_data_vld = (cpri1_en && dw_num_vld && addr1 <44352) ? 1'b1 : 1'b0;;
assign cpri1_iq_vld = cpri1_en & cpri_iq_vld;

// aiu0 lane 0-3
always @ (posedge i_clk)begin
    for(int i=0; i<4; i=i+1)begin
        if(srs_slot_en)
            cpri_datain[0][i] <= 64'h0000_0080_0000_3000;
        else if(!cpri_data_vld)begin
            cpri_datain[0][i] <= 'd0;
        end else begin
            cpri_datain[0][i] <= cpri_datain_0[i][addr];
        end
    end
    cpri_sopin <= cpri_iq_vld;
end

// aiu0 lane 4-7 delay
always @ (posedge i_clk)begin
    for(int i=4; i<8; i=i+1)begin
        if(srs_slot_en)
            cpri_datain[0][i] <= 64'h0000_0080_0000_3000;
        else if(!cpri1_data_vld)begin
            cpri_datain[0][i] <= 'd0;
        end else begin
            cpri_datain[0][i] <= cpri_datain_0[i][addr1];
        end
    end
    cpri1_sopin <= cpri1_iq_vld;
end

// aiu1 lane 0-7
always @ (posedge i_clk)begin
    for(int i=0; i<8; i=i+1)begin
        if(srs_slot_en)
            cpri_datain[1][i] <= 64'h0000_0080_0000_3000;
        else if(!cpri_data_vld)begin
            cpri_datain[1][i] <= 'd0;
        end else begin
            cpri_datain[1][i] <= cpri_datain_1[i][addr];
        end
    end
end

reg            [7:0][63: 0]                     fft_agc               =0;
always @(posedge i_clk) begin
    for(int i=0; i<8; i++)begin
        if(chip_num == 4)
            fft_agc[i] <= cpri_datain[0][i];
    end
end


//------------------------------------------------------------------------------------------
// Output data check 
//------------------------------------------------------------------------------------------
reg            [3:0][7: 0]                      cpri_tx_num           =0;
reg            [3:0][63: 0]                     iq_hd_out             =0;
reg            [3:0][63: 0]                     fft_agc_out           =0;
reg            [3:0][127: 0]                    rb_agc_out            =0;
reg            [3:0][7: 0]                      cprio_rbg_num         =0;
reg            [3:0][6: 0]                      cprio_slot_num        =0;
reg            [3:0][3: 0]                      cprio_symb_num        =0;
reg            [3:0][1: 0]                      cprio_aiu_num         =0;
reg            [3:0][2: 0]                      cprio_lane_num        =0;
reg            [3:0][3: 0]                      cprio_pkg_type        =0;
wire           [   3: 0]                        cpri_tx_sop             ;

generate for(gi=0;gi<4;gi=gi+1) begin:gen_output_data_check
    always @(posedge cpri_tx_clk[gi]) begin
        if(cpri_tx_num[gi]==95)
            cpri_tx_num[gi] <= 0;
        else if(cpri_tx_vld[gi])
            cpri_tx_num[gi] <= cpri_tx_num[gi] + 1;
        else
            cpri_tx_num[gi] <= 0;
    end

    always @(posedge cpri_tx_clk[gi]) begin
        if(cpri_tx_num[gi]==3)
            iq_hd_out[gi] <= cpri_tx_data[gi];
        else if(cpri_tx_num[gi]==4)
            fft_agc_out[gi] <= cpri_tx_data[gi];
        else if(cpri_tx_num[gi]==5)
            rb_agc_out[gi][63:0] <= cpri_tx_data[gi];
        else if(cpri_tx_num[gi]==6)
            rb_agc_out[gi][127:64] <= cpri_tx_data[gi];
    end

    always @(posedge cpri_tx_clk[gi]) begin
        cprio_rbg_num [gi] <= iq_hd_out[gi][52:45];
        cprio_aiu_num [gi] <= iq_hd_out[gi][44:43];
        cprio_lane_num[gi] <= iq_hd_out[gi][42:40];
        cprio_pkg_type[gi] <= iq_hd_out[gi][39:36];
        cprio_slot_num[gi] <= iq_hd_out[gi][18:12];
        cprio_symb_num[gi] <= iq_hd_out[gi][11: 8];
    end
    
    assign cpri_tx_sop[gi] = (cpri_tx_num[gi]==0 && cpri_tx_vld[gi]) ? 1'b1 : 1'b0;

end
endgenerate



//------------------------------------------------------------------------------------------
// Output data file
//------------------------------------------------------------------------------------------
initial begin
    fid_tx_data     = $fopen(FILE_TX_DATA,"w");
    
    fid_rx_data0    = $fopen(FILE_RX_DATA0,"w");
    fid_rx_data1    = $fopen(FILE_RX_DATA1,"w");
    fid_rx_data2    = $fopen(FILE_RX_DATA2,"w");
    fid_rx_data3    = $fopen(FILE_RX_DATA3,"w");
    fid_rx_data4    = $fopen(FILE_RX_DATA4,"w");
    fid_rx_data5    = $fopen(FILE_RX_DATA5,"w");
    fid_rx_data6    = $fopen(FILE_RX_DATA6,"w");
    fid_rx_data7    = $fopen(FILE_RX_DATA7,"w");
    
    fid_uzip_data0  = $fopen(FILE_UZIP_DATA0,"w");
    fid_uzip_data1  = $fopen(FILE_UZIP_DATA1,"w");
    fid_uzip_data2  = $fopen(FILE_UZIP_DATA2,"w");
    fid_uzip_data3  = $fopen(FILE_UZIP_DATA3,"w");
    fid_uzip_data4  = $fopen(FILE_UZIP_DATA4,"w");
    fid_uzip_data5  = $fopen(FILE_UZIP_DATA5,"w");
    fid_uzip_data6  = $fopen(FILE_UZIP_DATA6,"w");
    fid_uzip_data7  = $fopen(FILE_UZIP_DATA7,"w");
    
    fid_beams_data  = $fopen(FILE_BEAMS_DATA,"w");
    fid_beams_pwr   = $fopen(FILE_BEAMS_PWR,"w");
    fid_beams_sort  = $fopen(FILE_BEAMS_SORT,"w");
    fid_beams_idx   = $fopen(FILE_BEAMS_IDX,"w");
    fid_dr_data     = $fopen(FILE_CPRS_DATA, "w");
    fid_ants_data   = $fopen(FILE_DRIN_DATA, "w");

    fid_tx_cpri0    = $fopen(FILE_CPRS_OUT0, "w");
    fid_tx_cpri1    = $fopen(FILE_CPRS_OUT1, "w");
    fid_tx_cpri2    = $fopen(FILE_CPRS_OUT2, "w");
    fid_tx_cpri3    = $fopen(FILE_CPRS_OUT3, "w");


    fid_drout0_hex  = $fopen(FILE_DROUT0_HEX, "w");
    fid_drout15_hex = $fopen(FILE_DROUT15_HEX, "w");
    
    if(fid_tx_data)
        $display("succeed open file %s",FILE_TX_DATA);
    if(fid_rx_data0)
        $display("succeed open file %s",FILE_RX_DATA0);
    if(fid_uzip_data0)
        $display("succeed open file %s",FILE_UZIP_DATA0);
    if(fid_beams_data)
        $display("succeed open file %s",FILE_BEAMS_DATA);
    if(fid_beams_pwr)
        $display("succeed open file %s",FILE_BEAMS_PWR);
    if(fid_beams_sort)
        $display("succeed open file %s",FILE_BEAMS_SORT);
    if(fid_beams_idx)
        $display("succeed open file %s",FILE_BEAMS_IDX);
    if(fid_dr_data)
        $display("succeed open file %s",FILE_CPRS_DATA);
    if(fid_ants_data)
        $display("succeed open file %s",FILE_DRIN_DATA);
    if(fid_tx_cpri0)
        $display("succeed open file %s",FILE_CPRS_OUT0);
    if(fid_tx_cpri1)
        $display("succeed open file %s",FILE_CPRS_OUT1);

    #(`SIM_ENDS_TIME);
    $fclose(fid_tx_data );
    $fclose(fid_rx_data0);$fclose(fid_rx_data1);$fclose(fid_rx_data2);$fclose(fid_rx_data3);
    $fclose(fid_rx_data4);$fclose(fid_rx_data5);$fclose(fid_rx_data6);$fclose(fid_rx_data7);
    $fclose(fid_uzip_data0);$fclose(fid_uzip_data1);$fclose(fid_uzip_data2);$fclose(fid_uzip_data3);
    $fclose(fid_uzip_data4);$fclose(fid_uzip_data5);$fclose(fid_uzip_data6);$fclose(fid_uzip_data7);
    $fclose(fid_beams_data );
    $fclose(fid_beams_pwr  );
    $fclose(fid_beams_sort );
    $fclose(fid_beams_idx  );
    $fclose(fid_dr_data    );
    $fclose(fid_ants_data  );
    $fclose(fid_tx_cpri0   );
    $fclose(fid_tx_cpri1   );
    $fclose(fid_tx_cpri2   );
    $fclose(fid_tx_cpri3   );
    $fclose(fid_drout0_hex );$fclose(fid_drout15_hex );
end


//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write_iq2file_16bit;
    input integer desfid;
    input i_clk;
    input valid;
    input [31:0] ch1_iq_data;
    input [31:0] ch2_iq_data;
    input [31:0] ch3_iq_data;
    input [31:0] ch4_iq_data;


    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d,%d,%d,%d,%d\n", 
            ch1_iq_data[31:16], ch1_iq_data[15:0] ,
            ch2_iq_data[31:16], ch2_iq_data[15:0] ,
            ch3_iq_data[31:16], ch3_iq_data[15:0] ,
            ch4_iq_data[31:16], ch4_iq_data[15:0] 
        );
endtask

//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write_dzip2file;
    input integer desfid;
    input i_clk;
    input valid;
    input [13:0] ch1_iq_data ;
    input [ 3:0] ch1_agc_data;
    input [13:0] ch2_iq_data ;
    input [ 3:0] ch2_agc_data;
    input [13:0] ch3_iq_data ;
    input [ 3:0] ch3_agc_data;
    input [13:0] ch4_iq_data ;
    input [ 3:0] ch4_agc_data;
    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
            ch1_iq_data[13:7], ch1_iq_data[6:0], ch1_agc_data[3:0],
            ch2_iq_data[13:7], ch2_iq_data[6:0], ch2_agc_data[3:0],
            ch3_iq_data[13:7], ch3_iq_data[6:0], ch3_agc_data[3:0],
            ch4_iq_data[13:7], ch4_iq_data[6:0], ch4_agc_data[3:0]
        );

endtask

//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write_beamindex;
    input integer desfid;
    input valid;
    input [15:0][7:0] sort_index;
    
    // sorted beam index 
    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
                sort_index[ 0] ,
                sort_index[ 1] ,
                sort_index[ 2] ,
                sort_index[ 3] ,
                sort_index[ 4] ,
                sort_index[ 5] ,
                sort_index[ 6] ,
                sort_index[ 7] ,
                sort_index[ 8] ,
                sort_index[ 9] ,
                sort_index[10] ,
                sort_index[11] ,
                sort_index[12] ,
                sort_index[13] ,
                sort_index[14] ,
                sort_index[15] 
        );
endtask

//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write_beam_pwr;
    input integer desfid;
    input valid;
    input [15:0][31:0] beam_sort_pwr;
    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            beam_sort_pwr[ 0] , beam_sort_pwr[ 1] , beam_sort_pwr[ 2] , beam_sort_pwr[ 3] ,
            beam_sort_pwr[ 4] , beam_sort_pwr[ 5] , beam_sort_pwr[ 6] , beam_sort_pwr[ 7] ,
            beam_sort_pwr[ 8] , beam_sort_pwr[ 9] , beam_sort_pwr[10] , beam_sort_pwr[11] ,
            beam_sort_pwr[12] , beam_sort_pwr[13] , beam_sort_pwr[14] , beam_sort_pwr[15] ,
        );
endtask

//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write_dr_data;
    input integer desfid;
    input valid;
    input [15:0][15:0] o_dout_re;
    input [15:0][15:0] o_dout_im;

    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d\n", 
                                o_dout_re[ 0][15: 0] , o_dout_im[ 0][15: 0],
                                o_dout_re[ 1][15: 0] , o_dout_im[ 1][15: 0],
                                o_dout_re[ 2][15: 0] , o_dout_im[ 2][15: 0],
                                o_dout_re[ 3][15: 0] , o_dout_im[ 3][15: 0],
                                o_dout_re[ 4][15: 0] , o_dout_im[ 4][15: 0],
                                o_dout_re[ 5][15: 0] , o_dout_im[ 5][15: 0],
                                o_dout_re[ 6][15: 0] , o_dout_im[ 6][15: 0],
                                o_dout_re[ 7][15: 0] , o_dout_im[ 7][15: 0],
                                o_dout_re[ 8][15: 0] , o_dout_im[ 8][15: 0],
                                o_dout_re[ 9][15: 0] , o_dout_im[ 9][15: 0],
                                o_dout_re[10][15: 0] , o_dout_im[10][15: 0],
                                o_dout_re[11][15: 0] , o_dout_im[11][15: 0],
                                o_dout_re[12][15: 0] , o_dout_im[12][15: 0],
                                o_dout_re[13][15: 0] , o_dout_im[13][15: 0],
                                o_dout_re[14][15: 0] , o_dout_im[14][15: 0],
                                o_dout_re[15][15: 0] , o_dout_im[15][15: 0]
    );
endtask

//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write_dr_datain;
    input integer desfid;
    input valid;
    input [7:0][127:0] din;

    if(valid)
        $fwrite(desfid,"%d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d,\
                        %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d\n", 
                        din[ 0][0*32+16 +: 16],din[ 0][0*32 +: 16], din[ 0][1*32+16 +: 16],din[ 0][1*32 +: 16], din[ 0][2*32+16 +: 16],din[ 0][2*32 +: 16], din[ 0][3*32+16 +: 16],din[ 0][3*32 +: 16],
                        din[ 1][0*32+16 +: 16],din[ 1][0*32 +: 16], din[ 1][1*32+16 +: 16],din[ 1][1*32 +: 16], din[ 1][2*32+16 +: 16],din[ 1][2*32 +: 16], din[ 1][3*32+16 +: 16],din[ 1][3*32 +: 16],
                        din[ 2][0*32+16 +: 16],din[ 2][0*32 +: 16], din[ 2][1*32+16 +: 16],din[ 2][1*32 +: 16], din[ 2][2*32+16 +: 16],din[ 2][2*32 +: 16], din[ 2][3*32+16 +: 16],din[ 2][3*32 +: 16],
                        din[ 3][0*32+16 +: 16],din[ 3][0*32 +: 16], din[ 3][1*32+16 +: 16],din[ 3][1*32 +: 16], din[ 3][2*32+16 +: 16],din[ 3][2*32 +: 16], din[ 3][3*32+16 +: 16],din[ 3][3*32 +: 16],
                        din[ 4][0*32+16 +: 16],din[ 4][0*32 +: 16], din[ 4][1*32+16 +: 16],din[ 4][1*32 +: 16], din[ 4][2*32+16 +: 16],din[ 4][2*32 +: 16], din[ 4][3*32+16 +: 16],din[ 4][3*32 +: 16],
                        din[ 5][0*32+16 +: 16],din[ 5][0*32 +: 16], din[ 5][1*32+16 +: 16],din[ 5][1*32 +: 16], din[ 5][2*32+16 +: 16],din[ 5][2*32 +: 16], din[ 5][3*32+16 +: 16],din[ 5][3*32 +: 16],
                        din[ 6][0*32+16 +: 16],din[ 6][0*32 +: 16], din[ 6][1*32+16 +: 16],din[ 6][1*32 +: 16], din[ 6][2*32+16 +: 16],din[ 6][2*32 +: 16], din[ 6][3*32+16 +: 16],din[ 6][3*32 +: 16],
                        din[ 7][0*32+16 +: 16],din[ 7][0*32 +: 16], din[ 7][1*32+16 +: 16],din[ 7][1*32 +: 16], din[ 7][2*32+16 +: 16],din[ 7][2*32 +: 16], din[ 7][3*32+16 +: 16],din[ 7][3*32 +: 16]
    );
endtask



// Lane0 tx cpri data
always @(posedge cpri_tx_clk[0]) begin
    if(pusch_dr_top_aiu0.o_cpri0_tx_vld)begin
        $fwrite(fid_tx_cpri0, "%h\n", pusch_dr_top_aiu0.o_cpri0_tx_data);
    end
end

// Lane1 tx cpri data
always @(posedge cpri_tx_clk[1]) begin
    if(pusch_dr_top_aiu0.o_cpri1_tx_vld)begin
        $fwrite(fid_tx_cpri1, "%h\n", pusch_dr_top_aiu0.o_cpri1_tx_data);
    end
end

// Lane0 tx cpri data
always @(posedge cpri_tx_clk[0]) begin
    if(pusch_dr_top_aiu1.o_cpri0_tx_vld)begin
        $fwrite(fid_tx_cpri2, "%h\n", pusch_dr_top_aiu1.o_cpri0_tx_data);
    end
end

// Lane1 tx cpri data
always @(posedge cpri_tx_clk[1]) begin
    if(pusch_dr_top_aiu1.o_cpri1_tx_vld)begin
        $fwrite(fid_tx_cpri3, "%h\n", pusch_dr_top_aiu1.o_cpri1_tx_data);
    end
end

endmodule