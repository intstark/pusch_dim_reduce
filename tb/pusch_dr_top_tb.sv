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


`timescale 1ns/1ps
`define CLOCK_PERIOD 10.0
`define SIM_ENDS_TIME 500000

`include "params_list_pkg.sv"


module pusch_dr_top_tb;



parameter                                           FILE_IQDATA0           = "../vector/datain/ul_data_00.txt";
parameter                                           FILE_IQDATA1           = "../vector/datain/ul_data_01.txt";
parameter                                           FILE_IQDATA2           = "../vector/datain/ul_data_02.txt";
parameter                                           FILE_IQDATA3           = "../vector/datain/ul_data_03.txt";
parameter                                           FILE_IQDATA4           = "../vector/datain/ul_data_04.txt";
parameter                                           FILE_IQDATA5           = "../vector/datain/ul_data_05.txt";
parameter                                           FILE_IQDATA6           = "../vector/datain/ul_data_06.txt";
parameter                                           FILE_IQDATA7           = "../vector/datain/ul_data_07.txt";
parameter                                           FILE_TX_DATA           = "./des_tx_data.txt";
parameter                                           FILE_RX_DATA           = "./des_rx_data.txt";
parameter                                           FILE_UNZIP_DATA        = "./des_unzip_data.txt";
parameter                                           FILE_BEAMS_DATA        = "./des_beams_data.txt";
parameter                                           FILE_BEAMS_PWR         = "./des_beams_pwr.txt";
parameter                                           FILE_BEAMS_SORT        = "./des_beams_sort.txt";
parameter                                           FILE_BEAMS_IDX         = "./des_beams_idx.txt";
parameter                                           FILE_CPRS_DATA         = "compress_data.txt";

// Parameters
parameter                                           numBeams               = 64    ;
parameter                                           numPRB                 = 132   ;
parameter                                           numSYM                 = 14    ;
parameter                                           numRE                  = 12    ;
parameter                                           numDL                  = 2*numPRB*numSYM*numRE;
parameter                                           numTDL                 = 4*numPRB*numRE;

// Parameters
parameter                                           DIN_ANTS               = 4     ;
parameter                                           ANT                    = 32    ;
parameter                                           IW                     = 32    ;
parameter                                           OW                     = 48    ;


// Signals
genvar  gi,gj;
integer fid_iq_data0, fid_iq_data1, fid_iq_data2, fid_iq_data3, fid_iq_data4, fid_iq_data5, fid_iq_data6, fid_iq_data7;
integer fid_tx_data, fid_rx_data, fid_unzip_data, fid_beams_data;
integer fid_beams_pwr, fid_beams_sort,fid_beams_idx;
integer fid_cprs_data;


// Inputs
reg                                             i_clk                 =0;
reg                                             reset                 =1;
reg                                             tx_hfp                =0;
reg            [   1: 0]                        rbg_size              =2;

wire                                            iq_rx_valid             ;
wire           [  63: 0]                        iq_rx_data              ;
reg            [   6: 0]                        iq_rx_seq             =0;

wire           [   7: 0]                        cpri_clk                ;
wire           [   7: 0]                        cpri_rst                ;
wire           [7:0][63: 0]                     cpri_rx_data            ;
wire           [   7: 0]                        cpri_rx_vld             ;

wire                                            cpri_fst_word           ;



//------------------------------------------------------------------------------------------
// DL
//------------------------------------------------------------------------------------------
dl_data_gen                                             dl_data_gen
(

    .sys_clk_491_52                                     (i_clk                  ),
    .sys_rst_491_52                                     (reset                  ),
    .sys_clk_368_64                                     (i_clk                  ),
    .sys_rst_368_64                                     (reset                  ),
    .sys_clk_245_76                                     (reset                  ),
    .sys_rst_245_76                                     (reset                  ),
    .fpga_clk_250mhz                                    (i_clk                  ),
    .fpga_rst_250mhz                                    (reset                  ) 

);

assign iq_rx_data  = dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_valid = dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;

always @(posedge i_clk) begin
    if(iq_rx_seq==95)
        iq_rx_seq <= 0;
    else if(iq_rx_valid)
        iq_rx_seq <= iq_rx_seq + 1;
    else
        iq_rx_seq <= 0;
end

reg            [  63: 0]                        l1_iq_rx_data           ;
reg                                             l1_iq_rx_valid          ;
always @(posedge i_clk) begin
    l1_iq_rx_data <= iq_rx_data;
    l1_iq_rx_valid <= cpri_fst_word;
end

assign cpri_fst_word = (iq_rx_valid && (iq_rx_seq==0)) ? 1'b1 : 1'b0;

assign cpri_clk     =  {8{i_clk}};
assign cpri_rst     =  {8{reset}};
assign cpri_rx_data =  {{7{iq_rx_data}},l1_iq_rx_data};
assign cpri_rx_vld  =  {{7{cpri_fst_word}},l1_iq_rx_valid};



reg            [  15: 0]                        sim_cnt                 ;
reg            [   6: 0]                        iq_tx_cnt               ;
reg                                             iq_tx_enable            ;
reg            [   8: 0]                        chip_num                ;


always @ (posedge i_clk)
 begin 
  if (reset == 1'd0)  
     if (sim_cnt ==16'd100 )  
         sim_cnt <= sim_cnt;   
      else 
         sim_cnt <= sim_cnt + 1;    
   else
     sim_cnt <= 0;   
 end

always @ (posedge i_clk)
 begin 
     if (sim_cnt ==16'd100  )  
          if (iq_tx_cnt ==7'd95 )  
             iq_tx_cnt <= 7'd0; 
          else  
             iq_tx_cnt <= iq_tx_cnt+1;   
      else 
         iq_tx_cnt <= 7'd0;     
 end


always @ (posedge i_clk)
 begin 
     if (iq_tx_cnt ==7'd95  )  
         iq_tx_enable <=1'd1; 
      else 
         iq_tx_enable <=1'd0; 
 end

//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pusch_dr_top                                            pusch_dr_top(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_rbg_size                                         (rbg_size               ),

    .i_l0_cpri_clk                                      (cpri_clk    [0]        ),// lane0 cpri rx clock
    .i_l0_cpri_rst                                      (cpri_rst    [0]        ),// lane0 cpri rx reset
    .i_l0_cpri_rx_data                                  (cpri_rx_data[0]        ),// lane0 cpri rx data
    .i_l0_cpri_rx_vld                                   (cpri_rx_vld [0]        ),
    
    .i_l1_cpri_clk                                      (cpri_clk    [1]        ),
    .i_l1_cpri_rst                                      (cpri_rst    [1]        ),
    .i_l1_cpri_rx_data                                  (cpri_rx_data[1]        ),
    .i_l1_cpri_rx_vld                                   (cpri_rx_vld [1]        ),

    .i_l2_cpri_clk                                      (cpri_clk    [2]        ),
    .i_l2_cpri_rst                                      (cpri_rst    [2]        ),
    .i_l2_cpri_rx_data                                  (cpri_rx_data[2]        ),
    .i_l2_cpri_rx_vld                                   (cpri_rx_vld [2]        ),
                                                         
    .i_l3_cpri_clk                                      (cpri_clk    [3]        ),
    .i_l3_cpri_rst                                      (cpri_rst    [3]        ),
    .i_l3_cpri_rx_data                                  (cpri_rx_data[3]        ),
    .i_l3_cpri_rx_vld                                   (cpri_rx_vld [3]        ),

    .i_l4_cpri_clk                                      (cpri_clk    [4]        ),
    .i_l4_cpri_rst                                      (cpri_rst    [4]        ),
    .i_l4_cpri_rx_data                                  (cpri_rx_data[4]        ),
    .i_l4_cpri_rx_vld                                   (cpri_rx_vld [4]        ),
                                                         
    .i_l5_cpri_clk                                      (cpri_clk    [5]        ),
    .i_l5_cpri_rst                                      (cpri_rst    [5]        ),
    .i_l5_cpri_rx_data                                  (cpri_rx_data[5]        ),
    .i_l5_cpri_rx_vld                                   (cpri_rx_vld [5]        ),
                                                         
    .i_l6_cpri_clk                                      (cpri_clk    [6]        ),
    .i_l6_cpri_rst                                      (cpri_rst    [6]        ),
    .i_l6_cpri_rx_data                                  (cpri_rx_data[6]        ),
    .i_l6_cpri_rx_vld                                   (cpri_rx_vld [6]        ),
                                                         
    .i_l7_cpri_clk                                      (cpri_clk    [7]        ),
    .i_l7_cpri_rst                                      (cpri_rst    [7]        ),
    .i_l7_cpri_rx_data                                  (cpri_rx_data[7]        ),
    .i_l7_cpri_rx_vld                                   (cpri_rx_vld [7]        ),
	 
    .i_iq_tx_enable                                     (iq_tx_enable           ),
    .o_cpri_tx_data                                     (                       ),
    .o_cpri_tx_vld                                      (                       ) 
);


// Clock generation
initial begin
    i_clk = 0;
    forever #(`CLOCK_PERIOD/2) i_clk = ~i_clk;
end


// Reset generation
initial begin
    #(`CLOCK_PERIOD*10) reset = 1'b0;
    tx_hfp = 1'b1;
    #(`CLOCK_PERIOD) tx_hfp = 1'b0;
end

//------------------------------------------------------------------------------------------
// Output data file
//------------------------------------------------------------------------------------------
initial begin
    fid_tx_data     = $fopen(FILE_TX_DATA,"w");
    fid_rx_data     = $fopen(FILE_RX_DATA,"w");
    fid_unzip_data  = $fopen(FILE_UNZIP_DATA,"w");
    fid_beams_data  = $fopen(FILE_BEAMS_DATA,"w");
    fid_beams_pwr   = $fopen(FILE_BEAMS_PWR,"w");
    fid_beams_sort  = $fopen(FILE_BEAMS_SORT,"w");
    fid_beams_idx   = $fopen(FILE_BEAMS_IDX,"w");
    
    if(fid_tx_data)
        $display("succeed open file %s",FILE_TX_DATA);
    if(fid_rx_data)
        $display("succeed open file %s",FILE_RX_DATA);
    if(fid_unzip_data)
        $display("succeed open file %s",FILE_UNZIP_DATA);
    if(fid_beams_data)
        $display("succeed open file %s",FILE_BEAMS_DATA);
    if(fid_beams_pwr)
        $display("succeed open file %s",FILE_BEAMS_PWR);
    if(fid_beams_sort)
        $display("succeed open file %s",FILE_BEAMS_SORT);
    if(fid_beams_idx)
        $display("succeed open file %s",FILE_BEAMS_IDX);

    #(`SIM_ENDS_TIME);
    $fclose(fid_tx_data );
    $fclose(fid_rx_data);
    $fclose(fid_unzip_data );
    $fclose(fid_beams_data );
    $fclose(fid_beams_pwr  );
    $fclose(fid_beams_sort );
    $fclose(fid_beams_idx  );
    $stop;
end


reg [63:0] cpri_heager_0 = 0;
reg [63:0] cpri_heager_1 = 0;
reg [63:0] rb_agc_0 = 0;
reg [63:0] rb_agc_1 = 0;

always @(posedge i_clk) begin
    if(iq_rx_seq==3)
        cpri_heager_0 <= iq_rx_data;
    else if(iq_rx_seq==3)
        cpri_heager_1 <= iq_rx_data;
    else if(iq_rx_seq==5)
        rb_agc_0 <= iq_rx_data;
    else if(iq_rx_seq==6)
        rb_agc_1 <= iq_rx_data;
end


endmodule