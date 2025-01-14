//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/02/28 15:54:23
// Design Name: 
// Module Name: tb
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


module pusch_dr_tb;



parameter                                           FILE_IQDATA            = "./iq_data.txt";
parameter                                           FILE_ANTDATA           = "./ant_data.txt";
parameter                                           FILE_CWD_ODD           = "./code_word_odd.txt";
parameter                                           FILE_CWD_EVEN          = "./code_word_even.txt";
parameter                                           FILE_TX_DATA           = "./des_tx_data.txt";
parameter                                           FILE_RX_DATA           = "./des_rx_data.txt";
parameter                                           FILE_UNZIP_DATA        = "./des_unzip_data.txt";
parameter                                           FILE_BEAMS_DATA        = "./des_beams_data.txt";
parameter                                           FILE_BEAMS_PWR         = "./des_beams_pwr.txt";
parameter                                           FILE_BEAMS_SORT        = "./des_beams_sort.txt";
parameter                                           FILE_BEAMS_IDX         = "./des_beams_idx.txt";

// Parameters
parameter                                           numBeams               = 64    ;
parameter                                           numPRB                 = 132   ;
parameter                                           numSYM                 = 14    ;
parameter                                           numRE                  = 12    ;
parameter                                           numDL                  = 2*numPRB*numSYM*numRE;
parameter                                           numTDL                 = 4*numPRB*numRE;

// Parameters
parameter                                           ANT                    = 32    ;
parameter                                           IW                     = 32    ;
parameter                                           OW                     = 48    ;


// Signals
genvar gi,gj;
integer fid_iq_data, fid_ant_data, fid_cwd_odd, fid_cwd_even;
integer fid_tx_data, fid_rx_data, fid_unzip_data, fid_beams_data;
integer fid_rb_agc;
integer fid_beams_pwr, fid_beams_sort,fid_beams_idx;

// Inputs
reg                                             i_clk                 =1'b0;
reg                                             reset                 =1'b1;
wire                                            iq_rx_valid             ;
wire           [  63: 0]                        iq_rx_data              ;
reg            [   6: 0]                        iq_rx_seq             =0;
wire           [  63: 0]                        rx_mask                 ;
wire           [   7: 0]                        rx_crtl                 ;

reg                                             tx_hfp                =0;

wire                                            m_cpri_wen              ;
wire           [   6: 0]                        m_cpri_waddr            ;
wire           [  63: 0]                        m_cpri_wdata            ;
wire                                            m_cpri_wlast            ;

reg            [   1: 0]                        rbg_size              =2;

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

assign cpri_fst_word = (iq_rx_valid && (iq_rx_seq==0)) ? 1'b1 : 1'b0;

wire           [   7: 0]                        cpri_clk                ;
wire           [   7: 0]                        cpri_rst                ;
wire           [7:0][63: 0]                     cpri_rx_data            ;
wire           [7:0][6: 0]                      cpri_rx_seq             ;
wire           [   7: 0]                        cpri_rx_vld             ;


assign cpri_clk     = {8{i_clk}};
assign cpri_rst     = {8{reset}};
assign cpri_rx_data = '{8{iq_rx_data}};
assign cpri_rx_seq  = '{8{iq_rx_seq}};
assign cpri_rx_vld  = {8{cpri_fst_word}};



//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pusch_dim_reduction                                     pusch_dim_reduction(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_rbg_size                                         (rbg_size               ),

    .i_l0_cpri_clk                                      (cpri_clk    [0]        ),// lane0 cpri rx clock
    .i_l0_cpri_rst                                      (cpri_rst               ),// lane0 cpri rx reset
    .i_l0_cpri_rx_data                                  (cpri_rx_data[0]        ),// lane0 cpri rx data
    .i_l0_cpri_rx_vld                                   (cpri_rx_vld            ),
    
    .i_l1_cpri_clk                                      (cpri_clk    [1]        ),
    .i_l1_cpri_rst                                      (cpri_rst               ),
    .i_l1_cpri_rx_data                                  (cpri_rx_data[1]        ),
    .i_l1_cpri_rx_vld                                   (cpri_rx_vld            ),

    .i_l2_cpri_clk                                      (cpri_clk    [2]        ),
    .i_l2_cpri_rst                                      (cpri_rst               ),
    .i_l2_cpri_rx_data                                  (cpri_rx_data[2]        ),
    .i_l2_cpri_rx_vld                                   (cpri_rx_vld            ),
    
    .i_l3_cpri_clk                                      (cpri_clk    [3]        ),
    .i_l3_cpri_rst                                      (cpri_rst               ),
    .i_l3_cpri_rx_data                                  (cpri_rx_data[3]        ),
    .i_l3_cpri_rx_vld                                   (cpri_rx_vld            ),

    .i_l4_cpri_clk                                      (cpri_clk    [4]        ),
    .i_l4_cpri_rst                                      (cpri_rst               ),
    .i_l4_cpri_rx_data                                  (cpri_rx_data[4]        ),
    .i_l4_cpri_rx_vld                                   (cpri_rx_vld            ),
    
    .i_l5_cpri_clk                                      (cpri_clk    [5]        ),
    .i_l5_cpri_rst                                      (cpri_rst               ),
    .i_l5_cpri_rx_data                                  (cpri_rx_data[5]        ),
    .i_l5_cpri_rx_vld                                   (cpri_rx_vld            ),

    .i_l6_cpri_clk                                      (cpri_clk    [6]        ),
    .i_l6_cpri_rst                                      (cpri_rst               ),
    .i_l6_cpri_rx_data                                  (cpri_rx_data[6]        ),
    .i_l6_cpri_rx_vld                                   (cpri_rx_vld            ),
    
    .i_l7_cpri_clk                                      (cpri_clk    [7]        ),
    .i_l7_cpri_rst                                      (cpri_rst               ),
    .i_l7_cpri_rx_data                                  (cpri_rx_data[7]        ),
    .i_l7_cpri_rx_vld                                   (cpri_rx_vld            ),
	 
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


//------------------------------------------------------------------------------------------
// Task data write to file
//------------------------------------------------------------------------------------------
task write_iqmatrix2file;
    input i_clk;
    input valid;
    input integer desfid;
    input [15:0][95:0] iq_data;


    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
            iq_data[ 0][95:48], iq_data[ 0][47:0],
            iq_data[ 1][95:48], iq_data[ 1][47:0],
            iq_data[ 2][95:48], iq_data[ 2][47:0],
            iq_data[ 3][95:48], iq_data[ 3][47:0],
            iq_data[ 4][95:48], iq_data[ 4][47:0],
            iq_data[ 5][95:48], iq_data[ 5][47:0],
            iq_data[ 6][95:48], iq_data[ 6][47:0],
            iq_data[ 7][95:48], iq_data[ 7][47:0],
            iq_data[ 8][95:48], iq_data[ 8][47:0],
            iq_data[ 9][95:48], iq_data[ 9][47:0],
            iq_data[10][95:48], iq_data[10][47:0],
            iq_data[11][95:48], iq_data[11][47:0],
            iq_data[12][95:48], iq_data[12][47:0],
            iq_data[13][95:48], iq_data[13][47:0],
            iq_data[14][95:48], iq_data[14][47:0],
            iq_data[15][95:48], iq_data[15][47:0]
        );
endtask

//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write_iq2file;
    input i_clk;
    input valid;
    input integer desfid;
    input [13:0] iq_data;


    if(valid)
        $fwrite(desfid, "%d,%d\n", 
            iq_data[13:7], iq_data[6:0]
        );
endtask

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
task write_iq2file_48bit;
    input integer desfid;
    input i_clk;
    input valid;
    input [95:0] ch01_iq_data;
    input [95:0] ch02_iq_data;
    input [95:0] ch03_iq_data;
    input [95:0] ch04_iq_data;
    input [95:0] ch05_iq_data;
    input [95:0] ch06_iq_data;
    input [95:0] ch07_iq_data;
    input [95:0] ch08_iq_data;
    input [95:0] ch09_iq_data;
    input [95:0] ch10_iq_data;
    input [95:0] ch11_iq_data;
    input [95:0] ch12_iq_data;
    input [95:0] ch13_iq_data;
    input [95:0] ch14_iq_data;
    input [95:0] ch15_iq_data;
    input [95:0] ch16_iq_data;
    input [95:0] ch17_iq_data;
    input [95:0] ch18_iq_data;
    input [95:0] ch19_iq_data;
    input [95:0] ch20_iq_data;
    input [95:0] ch21_iq_data;
    input [95:0] ch22_iq_data;
    input [95:0] ch23_iq_data;
    input [95:0] ch24_iq_data;
    input [95:0] ch25_iq_data;
    input [95:0] ch26_iq_data;
    input [95:0] ch27_iq_data;
    input [95:0] ch28_iq_data;
    input [95:0] ch29_iq_data;
    input [95:0] ch30_iq_data;
    input [95:0] ch31_iq_data;
    input [95:0] ch32_iq_data;

    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,\
                         %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
            ch01_iq_data[95:48], ch01_iq_data[47:0] , ch02_iq_data[95:48], ch02_iq_data[47:0] ,
            ch03_iq_data[95:48], ch03_iq_data[47:0] , ch04_iq_data[95:48], ch04_iq_data[47:0] ,
            ch05_iq_data[95:48], ch05_iq_data[47:0] , ch06_iq_data[95:48], ch06_iq_data[47:0] ,
            ch07_iq_data[95:48], ch07_iq_data[47:0] , ch08_iq_data[95:48], ch08_iq_data[47:0] ,
            ch09_iq_data[95:48], ch09_iq_data[47:0] , ch10_iq_data[95:48], ch10_iq_data[47:0] ,
            ch11_iq_data[95:48], ch11_iq_data[47:0] , ch12_iq_data[95:48], ch12_iq_data[47:0] ,
            ch13_iq_data[95:48], ch13_iq_data[47:0] , ch14_iq_data[95:48], ch14_iq_data[47:0] ,
            ch15_iq_data[95:48], ch15_iq_data[47:0] , ch16_iq_data[95:48], ch16_iq_data[47:0] ,
            ch17_iq_data[95:48], ch17_iq_data[47:0] , ch18_iq_data[95:48], ch18_iq_data[47:0] ,
            ch19_iq_data[95:48], ch19_iq_data[47:0] , ch20_iq_data[95:48], ch20_iq_data[47:0] ,
            ch21_iq_data[95:48], ch21_iq_data[47:0] , ch22_iq_data[95:48], ch22_iq_data[47:0] ,
            ch23_iq_data[95:48], ch23_iq_data[47:0] , ch24_iq_data[95:48], ch24_iq_data[47:0] ,
            ch25_iq_data[95:48], ch25_iq_data[47:0] , ch26_iq_data[95:48], ch26_iq_data[47:0] ,
            ch27_iq_data[95:48], ch27_iq_data[47:0] , ch28_iq_data[95:48], ch28_iq_data[47:0] ,
            ch29_iq_data[95:48], ch29_iq_data[47:0] , ch30_iq_data[95:48], ch30_iq_data[47:0] ,
            ch31_iq_data[95:48], ch31_iq_data[47:0] , ch32_iq_data[95:48], ch32_iq_data[47:0] 
        );
endtask

//------------------------------------------------------------------------------------------
// Task iq write to file
//------------------------------------------------------------------------------------------
task write2file_48bit;
    input integer desfid;
    input i_clk;
    input valid;
    input [47:0] ch01_iq_data;
    input [47:0] ch02_iq_data;
    input [47:0] ch03_iq_data;
    input [47:0] ch04_iq_data;
    input [47:0] ch05_iq_data;
    input [47:0] ch06_iq_data;
    input [47:0] ch07_iq_data;
    input [47:0] ch08_iq_data;
    input [47:0] ch09_iq_data;
    input [47:0] ch10_iq_data;
    input [47:0] ch11_iq_data;
    input [47:0] ch12_iq_data;
    input [47:0] ch13_iq_data;
    input [47:0] ch14_iq_data;
    input [47:0] ch15_iq_data;
    input [47:0] ch16_iq_data;
    input [47:0] ch17_iq_data;
    input [47:0] ch18_iq_data;
    input [47:0] ch19_iq_data;
    input [47:0] ch20_iq_data;
    input [47:0] ch21_iq_data;
    input [47:0] ch22_iq_data;
    input [47:0] ch23_iq_data;
    input [47:0] ch24_iq_data;
    input [47:0] ch25_iq_data;
    input [47:0] ch26_iq_data;
    input [47:0] ch27_iq_data;
    input [47:0] ch28_iq_data;
    input [47:0] ch29_iq_data;
    input [47:0] ch30_iq_data;
    input [47:0] ch31_iq_data;
    input [47:0] ch32_iq_data;

    if(valid)
        $fwrite(desfid, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
            ch01_iq_data[47:0] , ch02_iq_data[47:0] ,
            ch03_iq_data[47:0] , ch04_iq_data[47:0] ,
            ch05_iq_data[47:0] , ch06_iq_data[47:0] ,
            ch07_iq_data[47:0] , ch08_iq_data[47:0] ,
            ch09_iq_data[47:0] , ch10_iq_data[47:0] ,
            ch11_iq_data[47:0] , ch12_iq_data[47:0] ,
            ch13_iq_data[47:0] , ch14_iq_data[47:0] ,
            ch15_iq_data[47:0] , ch16_iq_data[47:0] ,
            ch17_iq_data[47:0] , ch18_iq_data[47:0] ,
            ch19_iq_data[47:0] , ch20_iq_data[47:0] ,
            ch21_iq_data[47:0] , ch22_iq_data[47:0] ,
            ch23_iq_data[47:0] , ch24_iq_data[47:0] ,
            ch25_iq_data[47:0] , ch26_iq_data[47:0] ,
            ch27_iq_data[47:0] , ch28_iq_data[47:0] ,
            ch29_iq_data[47:0] , ch30_iq_data[47:0] ,
            ch31_iq_data[47:0] , ch32_iq_data[47:0] 
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


// tx data before package
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_tx_data,
                        i_clk,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_vld,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg0_data  ,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg0_shift ,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg1_data  ,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg1_shift ,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg2_data  ,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg2_shift ,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg3_data  ,
                        dl_data_gen.ant_parallel[0].u_dl_symb_if.u_package_data.i_pkg3_shift
                    );
end

// rx data after package
always @(posedge i_clk) begin
    write_dzip2file(
                        fid_rx_data,
                        i_clk,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_unzip_data, 
                            i_clk, 
                            pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pusch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    if(pusch_dim_reduction.beams_tvalid)
        $fwrite(fid_beams_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,\
                         %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 0] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 0] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 0] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 0] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 1] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 1] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 1] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 1] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 2] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 2] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 2] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 2] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 3] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 3] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 3] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 3] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 4] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 4] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 4] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 4] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 5] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 5] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 5] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 5] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 6] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 6] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 6] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 6] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 7] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 7] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 7] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 7] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 8] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 8] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 8] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 8] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[ 9] ,pusch_dim_reduction.mac_beams.o_data_even_q[ 9] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[ 9] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[ 9] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[10] ,pusch_dim_reduction.mac_beams.o_data_even_q[10] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[10] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[10] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[11] ,pusch_dim_reduction.mac_beams.o_data_even_q[11] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[11] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[11] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[12] ,pusch_dim_reduction.mac_beams.o_data_even_q[12] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[12] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[12] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[13] ,pusch_dim_reduction.mac_beams.o_data_even_q[13] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[13] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[13] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[14] ,pusch_dim_reduction.mac_beams.o_data_even_q[14] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[14] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[14] ,
                            pusch_dim_reduction.mac_beams.o_data_even_i[15] ,pusch_dim_reduction.mac_beams.o_data_even_q[15] ,  pusch_dim_reduction.mac_beams.o_data_odd_i[15] ,  pusch_dim_reduction.mac_beams.o_data_odd_q[15] 
        );
end

// tx data before package
always @(posedge i_clk) begin
    if(pusch_dim_reduction.rbg_buffer_vld)
        $fwrite(fid_beams_pwr, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pusch_dim_reduction.rbg_buffer_out[ 0] , pusch_dim_reduction.rbg_buffer_out[ 1] , pusch_dim_reduction.rbg_buffer_out[ 2] , pusch_dim_reduction.rbg_buffer_out[ 3] ,
            pusch_dim_reduction.rbg_buffer_out[ 4] , pusch_dim_reduction.rbg_buffer_out[ 5] , pusch_dim_reduction.rbg_buffer_out[ 6] , pusch_dim_reduction.rbg_buffer_out[ 7] ,
            pusch_dim_reduction.rbg_buffer_out[ 8] , pusch_dim_reduction.rbg_buffer_out[ 9] , pusch_dim_reduction.rbg_buffer_out[10] , pusch_dim_reduction.rbg_buffer_out[11] ,
            pusch_dim_reduction.rbg_buffer_out[12] , pusch_dim_reduction.rbg_buffer_out[13] , pusch_dim_reduction.rbg_buffer_out[14] , pusch_dim_reduction.rbg_buffer_out[15] ,
            pusch_dim_reduction.rbg_buffer_out[16] , pusch_dim_reduction.rbg_buffer_out[17] , pusch_dim_reduction.rbg_buffer_out[18] , pusch_dim_reduction.rbg_buffer_out[19] ,
            pusch_dim_reduction.rbg_buffer_out[20] , pusch_dim_reduction.rbg_buffer_out[21] , pusch_dim_reduction.rbg_buffer_out[22] , pusch_dim_reduction.rbg_buffer_out[23] ,
            pusch_dim_reduction.rbg_buffer_out[24] , pusch_dim_reduction.rbg_buffer_out[25] , pusch_dim_reduction.rbg_buffer_out[26] , pusch_dim_reduction.rbg_buffer_out[27] ,
            pusch_dim_reduction.rbg_buffer_out[28] , pusch_dim_reduction.rbg_buffer_out[29] , pusch_dim_reduction.rbg_buffer_out[30] , pusch_dim_reduction.rbg_buffer_out[31] ,
            pusch_dim_reduction.rbg_buffer_out[32] , pusch_dim_reduction.rbg_buffer_out[33] , pusch_dim_reduction.rbg_buffer_out[34] , pusch_dim_reduction.rbg_buffer_out[35] ,
            pusch_dim_reduction.rbg_buffer_out[36] , pusch_dim_reduction.rbg_buffer_out[37] , pusch_dim_reduction.rbg_buffer_out[38] , pusch_dim_reduction.rbg_buffer_out[39] ,
            pusch_dim_reduction.rbg_buffer_out[40] , pusch_dim_reduction.rbg_buffer_out[41] , pusch_dim_reduction.rbg_buffer_out[42] , pusch_dim_reduction.rbg_buffer_out[43] ,
            pusch_dim_reduction.rbg_buffer_out[44] , pusch_dim_reduction.rbg_buffer_out[45] , pusch_dim_reduction.rbg_buffer_out[46] , pusch_dim_reduction.rbg_buffer_out[47] ,
            pusch_dim_reduction.rbg_buffer_out[48] , pusch_dim_reduction.rbg_buffer_out[49] , pusch_dim_reduction.rbg_buffer_out[50] , pusch_dim_reduction.rbg_buffer_out[51] ,
            pusch_dim_reduction.rbg_buffer_out[52] , pusch_dim_reduction.rbg_buffer_out[53] , pusch_dim_reduction.rbg_buffer_out[54] , pusch_dim_reduction.rbg_buffer_out[55] ,
            pusch_dim_reduction.rbg_buffer_out[56] , pusch_dim_reduction.rbg_buffer_out[57] , pusch_dim_reduction.rbg_buffer_out[58] , pusch_dim_reduction.rbg_buffer_out[59] ,
            pusch_dim_reduction.rbg_buffer_out[60] , pusch_dim_reduction.rbg_buffer_out[61] , pusch_dim_reduction.rbg_buffer_out[62] , pusch_dim_reduction.rbg_buffer_out[63] 
        );
end

// tx data before package
always @(posedge i_clk) begin
    if(pusch_dim_reduction.beam_sort_vld)
        $fwrite(fid_beams_sort, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pusch_dim_reduction.beam_sort_out[ 0] , pusch_dim_reduction.beam_sort_out[ 1] , pusch_dim_reduction.beam_sort_out[ 2] , pusch_dim_reduction.beam_sort_out[ 3] ,
            pusch_dim_reduction.beam_sort_out[ 4] , pusch_dim_reduction.beam_sort_out[ 5] , pusch_dim_reduction.beam_sort_out[ 6] , pusch_dim_reduction.beam_sort_out[ 7] ,
            pusch_dim_reduction.beam_sort_out[ 8] , pusch_dim_reduction.beam_sort_out[ 9] , pusch_dim_reduction.beam_sort_out[10] , pusch_dim_reduction.beam_sort_out[11] ,
            pusch_dim_reduction.beam_sort_out[12] , pusch_dim_reduction.beam_sort_out[13] , pusch_dim_reduction.beam_sort_out[14] , pusch_dim_reduction.beam_sort_out[15] ,
            pusch_dim_reduction.beam_sort_out[16] , pusch_dim_reduction.beam_sort_out[17] , pusch_dim_reduction.beam_sort_out[18] , pusch_dim_reduction.beam_sort_out[19] ,
            pusch_dim_reduction.beam_sort_out[20] , pusch_dim_reduction.beam_sort_out[21] , pusch_dim_reduction.beam_sort_out[22] , pusch_dim_reduction.beam_sort_out[23] ,
            pusch_dim_reduction.beam_sort_out[24] , pusch_dim_reduction.beam_sort_out[25] , pusch_dim_reduction.beam_sort_out[26] , pusch_dim_reduction.beam_sort_out[27] ,
            pusch_dim_reduction.beam_sort_out[28] , pusch_dim_reduction.beam_sort_out[29] , pusch_dim_reduction.beam_sort_out[30] , pusch_dim_reduction.beam_sort_out[31] ,
            pusch_dim_reduction.beam_sort_out[32] , pusch_dim_reduction.beam_sort_out[33] , pusch_dim_reduction.beam_sort_out[34] , pusch_dim_reduction.beam_sort_out[35] ,
            pusch_dim_reduction.beam_sort_out[36] , pusch_dim_reduction.beam_sort_out[37] , pusch_dim_reduction.beam_sort_out[38] , pusch_dim_reduction.beam_sort_out[39] ,
            pusch_dim_reduction.beam_sort_out[40] , pusch_dim_reduction.beam_sort_out[41] , pusch_dim_reduction.beam_sort_out[42] , pusch_dim_reduction.beam_sort_out[43] ,
            pusch_dim_reduction.beam_sort_out[44] , pusch_dim_reduction.beam_sort_out[45] , pusch_dim_reduction.beam_sort_out[46] , pusch_dim_reduction.beam_sort_out[47] ,
            pusch_dim_reduction.beam_sort_out[48] , pusch_dim_reduction.beam_sort_out[49] , pusch_dim_reduction.beam_sort_out[50] , pusch_dim_reduction.beam_sort_out[51] ,
            pusch_dim_reduction.beam_sort_out[52] , pusch_dim_reduction.beam_sort_out[53] , pusch_dim_reduction.beam_sort_out[54] , pusch_dim_reduction.beam_sort_out[55] ,
            pusch_dim_reduction.beam_sort_out[56] , pusch_dim_reduction.beam_sort_out[57] , pusch_dim_reduction.beam_sort_out[58] , pusch_dim_reduction.beam_sort_out[59] ,
            pusch_dim_reduction.beam_sort_out[60] , pusch_dim_reduction.beam_sort_out[61] , pusch_dim_reduction.beam_sort_out[62] , pusch_dim_reduction.beam_sort_out[63] 
        );
end

// tx data before package
always @(posedge i_clk) begin
    if(pusch_dim_reduction.beam_sort.data_vld)
        $fwrite(fid_beams_idx, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
                pusch_dim_reduction.beam_sort.sort_addr[ 0] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 1] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 2] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 3] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 4] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 5] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 6] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 7] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 8] ,
                pusch_dim_reduction.beam_sort.sort_addr[ 9] ,
                pusch_dim_reduction.beam_sort.sort_addr[10] ,
                pusch_dim_reduction.beam_sort.sort_addr[11] ,
                pusch_dim_reduction.beam_sort.sort_addr[12] ,
                pusch_dim_reduction.beam_sort.sort_addr[13] ,
                pusch_dim_reduction.beam_sort.sort_addr[14] ,
                pusch_dim_reduction.beam_sort.sort_addr[15] 
        );
end

endmodule