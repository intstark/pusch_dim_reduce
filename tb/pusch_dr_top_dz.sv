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
`timescale 100ps/1ps

`define CLOCK_PERIOD    27.126
`define CLK245_PERIOD   40.690
`define T1US            10000
`define TCLK0_DELAY     `T1US*50
`define TCLK1_DELAY     `T1US*50+5
`define SIM_ENDS_TIME   2000*(`T1US)


module pusch_dr_top_dz;



parameter                                           FILE_IQDATA00          = "../vector/datain/LAN1.txt";
parameter                                           FILE_IQDATA01          = "../vector/datain/LAN2.txt";
parameter                                           FILE_IQDATA02          = "../vector/datain/LAN3.txt";
parameter                                           FILE_IQDATA03          = "../vector/datain/LAN4.txt";
parameter                                           FILE_IQDATA04          = "../vector/datain/LAN5.txt";
parameter                                           FILE_IQDATA05          = "../vector/datain/LAN6.txt";
parameter                                           FILE_IQDATA06          = "../vector/datain/LAN7.txt";
parameter                                           FILE_IQDATA07          = "../vector/datain/LAN8.txt";
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
integer fid_tx_cpri0, fid_tx_cpri1;
integer fid_drout0_hex, fid_drout15_hex;


// Inputs
reg                                             i_clk                 =0;
reg                                             clk245                =0;
reg                                             reset                 =0;
reg                                             tx_hfp                =0;
reg            [   1: 0]                        rbg_size              =2;

wire           [   7: 0]                        cpri_clk                ;
wire           [   7: 0]                        cpri_rst                ;
wire           [7:0][63: 0]                     cpri_rx_data            ;
wire           [   7: 0]                        cpri_rx_vld             ;



reg            [7:0][63: 0]                     cpri_datain           =0;
reg                                             cpri_data_vld         =0;
reg            [   6: 0]                        chip_num              =0;
wire                                            cpri_iq_vld             ;

wire           [1:0][63: 0]                     cpri_tx_data            ;
reg            [   1: 0]                        cpri_tx_clk           =0;
wire           [   1: 0]                        cpri_tx_vld             ;

//------------------------------------------------------------------------------------------
// UL data
//------------------------------------------------------------------------------------------
reg                                             src_reset             =0;
reg            [1:0][7: 0]                      cpri_cnt              =0;
wire           [  15: 0]                        io_rst                  ;
wire           [   1: 0]                        iq_tx_enable            ;
reg            [  23: 0]                        chip_cnt              =0;
reg            [   3: 0]                        slot_cnt              =0;
reg                                             slot_head             =0;
reg            [   1: 0]                        tx_hfp_buf            =0;
wire                                            tx_hfp_pos              ;
wire                                            cpri_gen_rst            ;
wire           [   7: 0]                        cpri_slot_num           ;
wire                                            cpri_slot_head          ;


assign io_rst = {1'b1, 14'd0, src_reset};

generate for(gi=0;gi<2;gi=gi+1) begin:gen_lane
    always @(posedge cpri_tx_clk[gi]) begin
        if(io_rst[0])
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

always @ (posedge i_clk)begin
    if(tx_hfp_pos)
        chip_cnt <= 'd0;
    else if(chip_cnt == 'd230399)
        chip_cnt <= 'd0;
    else
        chip_cnt <= chip_cnt + 1'b1;
end

always @ (posedge i_clk)begin
    if(tx_hfp_pos)
        slot_cnt <= 'd0;
    else if(chip_cnt == 'd230399)
        slot_cnt <= slot_cnt + 'd1;
end

always @ (posedge i_clk)begin
    if(tx_hfp_pos)
        slot_head <= 'd1;
    else if(chip_cnt == 'd230399 && slot_cnt <'d15)
        slot_head <= 'd1;
    else
        slot_head <= 'd0;
end

//------------------------------------------------------------------------------------
// TBU
//------------------------------------------------------------------------------------
reg start;

always @ (posedge i_clk) begin
if(io_rst[0])
	start <=0;
else if(cpri_slot_head)
	case(cpri_slot_num)
		0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75:start <=1;
		default:start <=0;
	endcase
else
	start <=0;
end

assign cpri_gen_rst = io_rst[15] ? slot_head : start;

//---------------------------------------------------------------------------//
//--cpri gen
sys_tbu #(
//   SIM_TEST:  for sim,it=1;for prj,it=0.
//   CLK_SET:   1=122.88, 2=245.76, 4=491.52
    .SIM_TEST                                           (1'd0                   ),
    .CLK_SET                                            (3'd2                   ) 
)u_sys_tbu(
    .clk                                                (clk245                 ),//sys_clk_491_52
    .rst                                                (reset                  ),//sys_rst_491_52
    .i_ref_10ms_head                                    (                       ),//gps      
    .i_ref_80ms_head                                    (                       ),//gps      
    .i_ref_cpri_head                                    (tx_hfp                 ),
    .i_ref_frame_num                                    ('d0                    ),
    .i_sys_max_delay                                    (32'b0                  ),
    .i_10ms_ul_dl_gap                                   (32'b0                  ),
//---------------------------------------------------------------------------//
//--local uplink    
    .i_ul_0_frame_pos                                   (32'h10                 ),


    .i_ul_1_frame_pos                                   (32'h10                 ),

//---------------------------------------------------------------------------//
//--local downlink
    .i_dl_0_frame_pos                                   (32'h10                 ),

//---------------------------------------------------------------------------//
//--cpri gen                                                              
    .i_cpri_frame_pos                                   (32'd80                 ),
    .o_cpri_half_frame_num                              (                       ),
    .o_cpri_frame_num                                   (                       ),
    .o_cpri_slot_num                                    (cpri_slot_num          ),
    .o_cpri_symb_num                                    (                       ),
    .o_cpri_half_frame_head                             (                       ),
    .o_cpri_half_frame_last                             (                       ),
    .o_cpri_frame_head                                  (                       ),
    .o_cpri_frame_last                                  (                       ),
    .o_cpri_slot_head                                   (cpri_slot_head         ),
    .o_cpri_symb_head                                   (                       ) 
);


wire                                            sop_cpri                ;
wire           [64-1: 0]                        dat_cpri0               ;
wire           [64-1: 0]                        dat_cpri1               ;
wire           [64-1: 0]                        dat_cpri2               ;
wire           [64-1: 0]                        dat_cpri3               ;
wire           [64-1: 0]                        dat_cpri4               ;
wire           [64-1: 0]                        dat_cpri5               ;
wire           [64-1: 0]                        dat_cpri6               ;
wire           [64-1: 0]                        dat_cpri7               ;
      
cpri_prb_comb_gen                                       u_cpri_prb_comb_gen(
    .clk                                                (i_clk                  ),
    .rst                                                (io_rst[0]              ),
    .aux_rx_rfp_rise                                    (cpri_gen_rst           ),/////dbg

    .sop_cpri_o                                         (sop_cpri               ),
    .dat_cpri0_o                                        (dat_cpri0              ),
    .dat_cpri1_o                                        (dat_cpri1              ),
    .dat_cpri2_o                                        (dat_cpri2              ),
    .dat_cpri3_o                                        (dat_cpri3              ),
    .dat_cpri4_o                                        (dat_cpri4              ),
    .dat_cpri5_o                                        (dat_cpri5              ),
    .dat_cpri6_o                                        (dat_cpri6              ),
    .dat_cpri7_o                                        (dat_cpri7              ) 
);


//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pusch_dr_top                                            pusch_dr_top(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_aiu_idx                                          (2'b00                  ),
    .i_rbg_size                                         (rbg_size               ),
    .i_dr_mode                                          (2'b00                  ),

    .i_l0_cpri_clk                                      (i_clk                  ),// lane0 cpri rx clock
    .i_l0_cpri_rst                                      (io_rst[0]              ),// lane0 cpri rx reset
    .i_l0_cpri_rx_data                                  (dat_cpri0              ),// lane0 cpri rx data
    .i_l0_cpri_rx_vld                                   (sop_cpri               ),
    
    .i_l1_cpri_clk                                      (i_clk                  ),
    .i_l1_cpri_rst                                      (io_rst[0]              ),
    .i_l1_cpri_rx_data                                  (dat_cpri1              ),
    .i_l1_cpri_rx_vld                                   (sop_cpri               ),

    .i_l2_cpri_clk                                      (i_clk                  ),
    .i_l2_cpri_rst                                      (io_rst[0]              ),
    .i_l2_cpri_rx_data                                  (dat_cpri2              ),
    .i_l2_cpri_rx_vld                                   (sop_cpri               ),
    
    .i_l3_cpri_clk                                      (i_clk                  ),
    .i_l3_cpri_rst                                      (io_rst[0]              ),
    .i_l3_cpri_rx_data                                  (dat_cpri3              ),
    .i_l3_cpri_rx_vld                                   (sop_cpri               ),

    .i_l4_cpri_clk                                      (i_clk                  ),
    .i_l4_cpri_rst                                      (io_rst[0]              ),
    .i_l4_cpri_rx_data                                  (dat_cpri4              ),
    .i_l4_cpri_rx_vld                                   (sop_cpri               ),
    
    .i_l5_cpri_clk                                      (i_clk                  ),
    .i_l5_cpri_rst                                      (io_rst[0]              ),
    .i_l5_cpri_rx_data                                  (dat_cpri5              ),
    .i_l5_cpri_rx_vld                                   (sop_cpri               ),

    .i_l6_cpri_clk                                      (i_clk                  ),
    .i_l6_cpri_rst                                      (io_rst[0]              ),
    .i_l6_cpri_rx_data                                  (dat_cpri6              ),
    .i_l6_cpri_rx_vld                                   (sop_cpri               ),
    
    .i_l7_cpri_clk                                      (i_clk                  ),
    .i_l7_cpri_rst                                      (io_rst[0]              ),
    .i_l7_cpri_rx_data                                  (dat_cpri7              ),
    .i_l7_cpri_rx_vld                                   (sop_cpri               ),

    .i_cpri0_tx_clk                                     (cpri_tx_clk    [0]     ),
    .i_cpri0_tx_enable                                  (iq_tx_enable   [0]     ),
    .o_cpri0_tx_data                                    (cpri_tx_data   [0]     ),
    .o_cpri0_tx_vld                                     (cpri_tx_vld    [0]     ),
                                                                     
    .i_cpri1_tx_clk                                     (cpri_tx_clk    [1]     ),
    .i_cpri1_tx_enable                                  (iq_tx_enable   [1]     ),
    .o_cpri1_tx_data                                    (cpri_tx_data   [1]     ),
    .o_cpri1_tx_vld                                     (cpri_tx_vld    [1]     ) 
);


// Clock generation
initial begin
    i_clk = 0;
    forever #(`CLOCK_PERIOD/2) i_clk = ~i_clk;
end

// Clock generation
initial begin
    clk245 = 0;
    forever #(`CLK245_PERIOD/2) clk245 = ~clk245;
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
    #(`CLOCK_PERIOD/2*9) src_reset = 1'b1;
    #(`CLOCK_PERIOD*10) src_reset = 1'b0;
    #(`CLOCK_PERIOD*10) reset = 1'b1;
    #(`CLOCK_PERIOD*10) reset = 1'b0;
`ifdef SIM_RESET_CASE
    #(`T1US*300) src_reset = 1'b1;
    #(`T1US*500) src_reset = 1'b0;

    #(212455) src_reset = 1'b1;
    #(`CLOCK_PERIOD*10) src_reset = 1'b0;

    #(212465) reset = 1'b1;
    #(`T1US*200) reset = 1'b0;

    #(112455) src_reset = 1'b1;
    #(`CLOCK_PERIOD*10) src_reset = 1'b0;
`endif
end

// Reset generation
initial begin
    #(`CLOCK_PERIOD*40) tx_hfp = 1'b1;
    #(`CLOCK_PERIOD*2 ) tx_hfp = 1'b0;
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
    $stop;
end



always @(posedge i_clk) begin
    if(!reset)begin
        $fscanf(fid_iq_data00, "%h\n", cpri_datain[0]);
        $fscanf(fid_iq_data01, "%h\n", cpri_datain[1]);
        $fscanf(fid_iq_data02, "%h\n", cpri_datain[2]);
        $fscanf(fid_iq_data03, "%h\n", cpri_datain[3]);
        $fscanf(fid_iq_data04, "%h\n", cpri_datain[4]);
        $fscanf(fid_iq_data05, "%h\n", cpri_datain[5]);
        $fscanf(fid_iq_data06, "%h\n", cpri_datain[6]);
        $fscanf(fid_iq_data07, "%h\n", cpri_datain[7]);

        cpri_data_vld <= 1'b1;

        if(chip_num == 95)
            chip_num <= 0;
        else if(cpri_data_vld)
            chip_num <= chip_num + 1;
    end
end

assign cpri_iq_vld = (cpri_data_vld && chip_num == 0) ? 1'b1 : 1'b0;

reg            [7:0][63: 0]                     fft_agc               =0;
always @(posedge i_clk) begin
    for(int i=0; i<8; i++)begin
        if(chip_num == 4)
            fft_agc[i] <= cpri_datain[i];
    end
end

//------------------------------------------------------------------------------------------
// Output data check 
//------------------------------------------------------------------------------------------
reg            [1:0][7: 0]                      cpri_tx_num           =0;
reg            [1:0][63: 0]                     iq_hd_out             =0;
reg            [1:0][63: 0]                     fft_agc_out           =0;
reg            [1:0][127: 0]                    rb_agc_out            =0;
reg            [1:0][7: 0]                      cprio_rbg_num         =0;
reg            [1:0][6: 0]                      cprio_slot_num        =0;
reg            [1:0][3: 0]                      cprio_symb_num        =0;
reg            [1:0][1: 0]                      cprio_aiu_num         =0;
reg            [1:0][2: 0]                      cprio_lane_num        =0;
reg            [1:0][3: 0]                      cprio_pkg_type        =0;

generate for(gi=0;gi<2;gi=gi+1) begin:gen_output_data_check
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


// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data0, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data1, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data2, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data3, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data4, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data5, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data6, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_uzip_data7, 
                            i_clk, 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end







// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data0,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end


// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data1,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[1].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data2,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[2].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data3,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[3].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data4,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[4].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data5,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[5].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data6,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[6].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// data before uncompress 
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data7,
                        i_clk,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dr_top.cpri_rxdata_top.gen_rxdata_unpack[7].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end
//------------------------------------------------------------------------------------------
// Write dr datain 
//------------------------------------------------------------------------------------------
always @(posedge i_clk) 
    write_dr_datain(
                        fid_ants_data, 
                        pusch_dr_top.unpack_iq_vld,
                        pusch_dr_top.unpack_iq_data
    );


//------------------------------------------------------------------------------------------
// Write beam power 
//------------------------------------------------------------------------------------------
always @(posedge i_clk) 
    write_beam_pwr(
                        fid_beams_sort, 
                        pusch_dr_top.pusch_dr_core.beam_sort_load,
                        pusch_dr_top.pusch_dr_core.beam_sort_pwr
    );


//------------------------------------------------------------------------------------------
// Write beam index
//------------------------------------------------------------------------------------------
always @(posedge i_clk) 
    write_beamindex(
                        fid_beams_idx, 
                        pusch_dr_top.pusch_dr_core.beam_sort.data_vld,
                        pusch_dr_top.pusch_dr_core.beam_sort.sort_addr
    );

//------------------------------------------------------------------------------------------
// Write dr data 
//------------------------------------------------------------------------------------------
always @(posedge i_clk) 
    write_dr_data(
                        fid_dr_data, 
                        pusch_dr_top.pusch_dr_core.compress_matrix.o_vld,
                        pusch_dr_top.pusch_dr_core.compress_matrix.o_dout_re,
                        pusch_dr_top.pusch_dr_core.compress_matrix.o_dout_im
    );

// Lane0 tx cpri data
always @(posedge cpri_tx_clk[0]) begin
    if(pusch_dr_top.o_cpri0_tx_vld)begin
        $fwrite(fid_tx_cpri0, "%h\n", pusch_dr_top.o_cpri0_tx_data);
    end
end

// Lane1 tx cpri data
always @(posedge cpri_tx_clk[1]) begin
    if(pusch_dr_top.o_cpri1_tx_vld)begin
        $fwrite(fid_tx_cpri1, "%h\n", pusch_dr_top.o_cpri1_tx_data);
    end
end


// Dr data output by beams in hex format
always @(posedge i_clk) begin
    if(pusch_dr_top.pusch_dr_core.compress_matrix.o_vld)begin
        $fwrite(fid_drout0_hex, "%h\n", {pusch_dr_top.pusch_dr_core.compress_matrix.o_dout_re[0],pusch_dr_top.pusch_dr_core.compress_matrix.o_dout_im[0]});
    end
end

// Dr data output by beams in hex format
always @(posedge i_clk) begin
    if(pusch_dr_top.pusch_dr_core.compress_matrix.o_vld)begin
        $fwrite(fid_drout15_hex, "%h\n", {pusch_dr_top.pusch_dr_core.compress_matrix.o_dout_re[15],pusch_dr_top.pusch_dr_core.compress_matrix.o_dout_im[15]});
    end
end




endmodule