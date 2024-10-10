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
`define SIM_ENDS_TIME 250000

`include "params_list_pkg.sv"


module dl_ul_beams_tb;



parameter                                           FILE_IQDATA            = "./iq_data.txt";
parameter                                           FILE_ANTDATA           = "./ant_data.txt";
parameter                                           FILE_CWD_ODD           = "./code_word_odd.txt";
parameter                                           FILE_CWD_EVEN          = "./code_word_even.txt";
parameter                                           FILE_TX_DATA           = "./des_tx_data.txt";
parameter                                           FILE_RX_DATA           = "./des_rx_data.txt";
parameter                                           FILE_UNZIP_DATA        = "./des_unzip_data.txt";
parameter                                           FILE_BEAMS_DATA        = "./des_beams_data.txt";
parameter                                           FILE_BEAMS_PWR         = "./des_beams_pwr.txt";
parameter                                           FILE_BEAMS_SORT         = "./des_beams_sort.txt";

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
integer fid_beams_pwr, fid_beams_sort;

// Inputs
reg                                             i_clk                 =1'b0;
reg                                             reset                 =1'b1;
wire                                            iq_rx_valid             ;
wire           [  63: 0]                        iq_rx_data              ;
reg            [  63: 0]                        rx_data               =0;
reg            [   6: 0]                        rx_seq                =0;
wire           [  63: 0]                        rx_mask                 ;
wire           [   7: 0]                        rx_crtl                 ;

reg                                             tx_hfp                =0;

wire                                            m_cpri_wen              ;
wire           [   6: 0]                        m_cpri_waddr            ;
wire           [  63: 0]                        m_cpri_wdata            ;
wire                                            m_cpri_wlast            ;
wire           [numBeams-1:0][ANT*IW-1: 0]      i_code_word_odd         ;
wire           [numBeams-1:0][ANT*IW-1: 0]      i_code_word_even        ;


reg            [numBeams-1:0][ANT*2-1:0][15: 0] code_word_odd_pre     ='{default:0};
reg            [numBeams-1:0][ANT*2-1:0][15: 0] code_word_even_pre    ='{default:0};
reg            [numBeams-1:0][ANT-1:0][31: 0]   code_word_odd           ;
reg            [numBeams-1:0][ANT-1:0][31: 0]   code_word_even          ;
reg            [   1: 0]                        rbg_size              =2;




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
    if(rx_seq==95)
        rx_seq <= 0;
    else if(iq_rx_valid)
        rx_seq <= rx_seq + 1;
    else
        rx_seq <= 0;
end

wire           [   7: 0]                        cpri_clk                ;
wire           [   7: 0]                        cpri_rst                ;
wire           [7:0][63: 0]                     cpri_rx_data            ;
wire           [7:0][6: 0]                      cpri_rx_seq             ;
wire           [   7: 0]                        cpri_rx_vld             ;


assign cpri_clk     = {8{i_clk}};
assign cpri_rst     = {8{reset}};
assign cpri_rx_data = '{8{iq_rx_data}};
assign cpri_rx_seq  = '{8{rx_seq}};
assign cpri_rx_vld  = {8{iq_rx_valid}};



//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pdsch_dim_reduction                                     pdsch_dim_reduction(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),

    .i_cpri_clk                                         (cpri_clk               ),
    .i_cpri_rst                                         (cpri_rst               ),
    .i_cpri_rx_data                                     (cpri_rx_data           ),
    .i_cpri_rx_seq                                      (cpri_rx_seq            ),
    .i_cpri_rx_vld                                      (cpri_rx_vld            ),
    
    .i_code_word_even                                   (i_code_word_even       ),
    .i_code_word_odd                                    (i_code_word_odd        ),
    
    .i_rbg_size                                         (rbg_size               ),
    
    .o_ant_even                                         (                       ),
    .o_ant_odd                                          (                       ),
    .o_ant_addr                                         (                       ),
    .o_tvalid                                           (                       ) 
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
// CodeWord ODD
//------------------------------------------------------------------------------------------
initial begin
    fid_cwd_odd = $fopen(FILE_CWD_ODD,"r");
    if(fid_cwd_odd)
        $display("succeed open file %s",FILE_CWD_ODD);


    for(int i=0; i<numBeams; i++)begin
        for(int j=0; j<ANT*2; j++)begin
            $fscanf(fid_cwd_odd, "%d,", code_word_odd_pre[i][j]);
            $display("code_word_odd_pre[i][j] = %d,", code_word_odd_pre[i][j]);
        end
    end
    $fclose(fid_cwd_odd);
end

//------------------------------------------------------------------------------------------
// CodeWord EVEN
//------------------------------------------------------------------------------------------
initial begin
    fid_cwd_even = $fopen(FILE_CWD_EVEN,"r");
    if(fid_cwd_even)
        $display("succeed open file %s",FILE_CWD_EVEN);


    for(int i=0; i<numBeams; i++)begin
        for(int j=0; j<ANT*2; j++)begin
            $fscanf(fid_cwd_even, "%d,", code_word_even_pre[i][j]);
            $display("code_word_even_pre[i][j] = %d,", code_word_even_pre[i][j]);
        end
    end
    $fclose(fid_cwd_even);
end

generate 
for( gi=0; gi<numBeams; gi++)begin:repack_code_word_odd
    for(gj=0; gj<ANT; gj++)begin
        assign code_word_odd[gi][gj] = {code_word_odd_pre[gi][gj],code_word_odd_pre[gi][gj+ANT]};
        assign i_code_word_odd[gi][IW*gj+:IW] = code_word_odd[gi][gj];
    end
end
endgenerate 

generate 
for( gi=0; gi<numBeams; gi++)begin:repack_code_word_even
    for(gj=0; gj<ANT; gj++)begin
        assign code_word_even[gi][gj] = {code_word_even_pre[gi][gj],code_word_even_pre[gi][gj+ANT]};
        assign i_code_word_even[gi][IW*gj+:IW] = code_word_even[gi][gj];
    end
end
endgenerate 


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

    #(`SIM_ENDS_TIME);
    $fclose(fid_tx_data );
    $fclose(fid_rx_data);
    $fclose(fid_unzip_data );
    $fclose(fid_beams_data );
    $fclose(fid_beams_pwr  );
    $fclose(fid_beams_sort );
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
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package_valid,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[0]   ,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [0]   ,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[1]   ,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [1]   ,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[2]   ,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [2]   ,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.ant_package[3]   ,
                        pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.rb_shift   [3]   
                    );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write_iq2file_16bit(    
                            fid_unzip_data, 
                            i_clk, 
                            pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack_vld , 
                            pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[0]  ,
                            pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[1]  ,
                            pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[2]  ,
                            pdsch_dim_reduction.gen_rxdata_unpack[0].cpri_rxdata_unpack_4ant.data_unpack[3]  
                        );
end

// rx data after uncompress
always @(posedge i_clk) begin
    write2file_48bit(    
                            fid_beams_data, 
                            i_clk, 
                            pdsch_dim_reduction.beams_tvalid      , 
                            pdsch_dim_reduction.beams_sum_even[ 0] , pdsch_dim_reduction.beams_sum_odd[ 0]  ,
                            pdsch_dim_reduction.beams_sum_even[ 1] , pdsch_dim_reduction.beams_sum_odd[ 1]  ,
                            pdsch_dim_reduction.beams_sum_even[ 2] , pdsch_dim_reduction.beams_sum_odd[ 2]  ,
                            pdsch_dim_reduction.beams_sum_even[ 3] , pdsch_dim_reduction.beams_sum_odd[ 3]  ,
                            pdsch_dim_reduction.beams_sum_even[ 4] , pdsch_dim_reduction.beams_sum_odd[ 4]  ,
                            pdsch_dim_reduction.beams_sum_even[ 5] , pdsch_dim_reduction.beams_sum_odd[ 5]  ,
                            pdsch_dim_reduction.beams_sum_even[ 6] , pdsch_dim_reduction.beams_sum_odd[ 6]  ,
                            pdsch_dim_reduction.beams_sum_even[ 7] , pdsch_dim_reduction.beams_sum_odd[ 7]  ,
                            pdsch_dim_reduction.beams_sum_even[ 8] , pdsch_dim_reduction.beams_sum_odd[ 8]  ,
                            pdsch_dim_reduction.beams_sum_even[ 9] , pdsch_dim_reduction.beams_sum_odd[ 9]  ,
                            pdsch_dim_reduction.beams_sum_even[10] , pdsch_dim_reduction.beams_sum_odd[10]  ,
                            pdsch_dim_reduction.beams_sum_even[11] , pdsch_dim_reduction.beams_sum_odd[11]  ,
                            pdsch_dim_reduction.beams_sum_even[12] , pdsch_dim_reduction.beams_sum_odd[12]  ,
                            pdsch_dim_reduction.beams_sum_even[13] , pdsch_dim_reduction.beams_sum_odd[13]  ,
                            pdsch_dim_reduction.beams_sum_even[14] , pdsch_dim_reduction.beams_sum_odd[14]  ,
                            pdsch_dim_reduction.beams_sum_even[15] , pdsch_dim_reduction.beams_sum_odd[15]  
                        );
end

// tx data before package
always @(posedge i_clk) begin
    if(pdsch_dim_reduction.rbg_buffer_vld)
        $fwrite(fid_beams_pwr, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pdsch_dim_reduction.rbg_buffer_out[ 0] , pdsch_dim_reduction.rbg_buffer_out[ 1] , pdsch_dim_reduction.rbg_buffer_out[ 2] , pdsch_dim_reduction.rbg_buffer_out[ 3] ,
            pdsch_dim_reduction.rbg_buffer_out[ 4] , pdsch_dim_reduction.rbg_buffer_out[ 5] , pdsch_dim_reduction.rbg_buffer_out[ 6] , pdsch_dim_reduction.rbg_buffer_out[ 7] ,
            pdsch_dim_reduction.rbg_buffer_out[ 8] , pdsch_dim_reduction.rbg_buffer_out[ 9] , pdsch_dim_reduction.rbg_buffer_out[10] , pdsch_dim_reduction.rbg_buffer_out[11] ,
            pdsch_dim_reduction.rbg_buffer_out[12] , pdsch_dim_reduction.rbg_buffer_out[13] , pdsch_dim_reduction.rbg_buffer_out[14] , pdsch_dim_reduction.rbg_buffer_out[15] ,
            pdsch_dim_reduction.rbg_buffer_out[16] , pdsch_dim_reduction.rbg_buffer_out[17] , pdsch_dim_reduction.rbg_buffer_out[18] , pdsch_dim_reduction.rbg_buffer_out[19] ,
            pdsch_dim_reduction.rbg_buffer_out[20] , pdsch_dim_reduction.rbg_buffer_out[21] , pdsch_dim_reduction.rbg_buffer_out[22] , pdsch_dim_reduction.rbg_buffer_out[23] ,
            pdsch_dim_reduction.rbg_buffer_out[24] , pdsch_dim_reduction.rbg_buffer_out[25] , pdsch_dim_reduction.rbg_buffer_out[26] , pdsch_dim_reduction.rbg_buffer_out[27] ,
            pdsch_dim_reduction.rbg_buffer_out[28] , pdsch_dim_reduction.rbg_buffer_out[29] , pdsch_dim_reduction.rbg_buffer_out[30] , pdsch_dim_reduction.rbg_buffer_out[31] ,
            pdsch_dim_reduction.rbg_buffer_out[32] , pdsch_dim_reduction.rbg_buffer_out[33] , pdsch_dim_reduction.rbg_buffer_out[34] , pdsch_dim_reduction.rbg_buffer_out[35] ,
            pdsch_dim_reduction.rbg_buffer_out[36] , pdsch_dim_reduction.rbg_buffer_out[37] , pdsch_dim_reduction.rbg_buffer_out[38] , pdsch_dim_reduction.rbg_buffer_out[39] ,
            pdsch_dim_reduction.rbg_buffer_out[40] , pdsch_dim_reduction.rbg_buffer_out[41] , pdsch_dim_reduction.rbg_buffer_out[42] , pdsch_dim_reduction.rbg_buffer_out[43] ,
            pdsch_dim_reduction.rbg_buffer_out[44] , pdsch_dim_reduction.rbg_buffer_out[45] , pdsch_dim_reduction.rbg_buffer_out[46] , pdsch_dim_reduction.rbg_buffer_out[47] ,
            pdsch_dim_reduction.rbg_buffer_out[48] , pdsch_dim_reduction.rbg_buffer_out[49] , pdsch_dim_reduction.rbg_buffer_out[50] , pdsch_dim_reduction.rbg_buffer_out[51] ,
            pdsch_dim_reduction.rbg_buffer_out[52] , pdsch_dim_reduction.rbg_buffer_out[53] , pdsch_dim_reduction.rbg_buffer_out[54] , pdsch_dim_reduction.rbg_buffer_out[55] ,
            pdsch_dim_reduction.rbg_buffer_out[56] , pdsch_dim_reduction.rbg_buffer_out[57] , pdsch_dim_reduction.rbg_buffer_out[58] , pdsch_dim_reduction.rbg_buffer_out[59] ,
            pdsch_dim_reduction.rbg_buffer_out[60] , pdsch_dim_reduction.rbg_buffer_out[61] , pdsch_dim_reduction.rbg_buffer_out[62] , pdsch_dim_reduction.rbg_buffer_out[63] 
        );
end

// tx data before package
always @(posedge i_clk) begin
    if(pdsch_dim_reduction.beam_sort_vld)
        $fwrite(fid_beams_sort, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pdsch_dim_reduction.beam_sort_out[ 0] , pdsch_dim_reduction.beam_sort_out[ 1] , pdsch_dim_reduction.beam_sort_out[ 2] , pdsch_dim_reduction.beam_sort_out[ 3] ,
            pdsch_dim_reduction.beam_sort_out[ 4] , pdsch_dim_reduction.beam_sort_out[ 5] , pdsch_dim_reduction.beam_sort_out[ 6] , pdsch_dim_reduction.beam_sort_out[ 7] ,
            pdsch_dim_reduction.beam_sort_out[ 8] , pdsch_dim_reduction.beam_sort_out[ 9] , pdsch_dim_reduction.beam_sort_out[10] , pdsch_dim_reduction.beam_sort_out[11] ,
            pdsch_dim_reduction.beam_sort_out[12] , pdsch_dim_reduction.beam_sort_out[13] , pdsch_dim_reduction.beam_sort_out[14] , pdsch_dim_reduction.beam_sort_out[15] ,
            pdsch_dim_reduction.beam_sort_out[16] , pdsch_dim_reduction.beam_sort_out[17] , pdsch_dim_reduction.beam_sort_out[18] , pdsch_dim_reduction.beam_sort_out[19] ,
            pdsch_dim_reduction.beam_sort_out[20] , pdsch_dim_reduction.beam_sort_out[21] , pdsch_dim_reduction.beam_sort_out[22] , pdsch_dim_reduction.beam_sort_out[23] ,
            pdsch_dim_reduction.beam_sort_out[24] , pdsch_dim_reduction.beam_sort_out[25] , pdsch_dim_reduction.beam_sort_out[26] , pdsch_dim_reduction.beam_sort_out[27] ,
            pdsch_dim_reduction.beam_sort_out[28] , pdsch_dim_reduction.beam_sort_out[29] , pdsch_dim_reduction.beam_sort_out[30] , pdsch_dim_reduction.beam_sort_out[31] ,
            pdsch_dim_reduction.beam_sort_out[32] , pdsch_dim_reduction.beam_sort_out[33] , pdsch_dim_reduction.beam_sort_out[34] , pdsch_dim_reduction.beam_sort_out[35] ,
            pdsch_dim_reduction.beam_sort_out[36] , pdsch_dim_reduction.beam_sort_out[37] , pdsch_dim_reduction.beam_sort_out[38] , pdsch_dim_reduction.beam_sort_out[39] ,
            pdsch_dim_reduction.beam_sort_out[40] , pdsch_dim_reduction.beam_sort_out[41] , pdsch_dim_reduction.beam_sort_out[42] , pdsch_dim_reduction.beam_sort_out[43] ,
            pdsch_dim_reduction.beam_sort_out[44] , pdsch_dim_reduction.beam_sort_out[45] , pdsch_dim_reduction.beam_sort_out[46] , pdsch_dim_reduction.beam_sort_out[47] ,
            pdsch_dim_reduction.beam_sort_out[48] , pdsch_dim_reduction.beam_sort_out[49] , pdsch_dim_reduction.beam_sort_out[50] , pdsch_dim_reduction.beam_sort_out[51] ,
            pdsch_dim_reduction.beam_sort_out[52] , pdsch_dim_reduction.beam_sort_out[53] , pdsch_dim_reduction.beam_sort_out[54] , pdsch_dim_reduction.beam_sort_out[55] ,
            pdsch_dim_reduction.beam_sort_out[56] , pdsch_dim_reduction.beam_sort_out[57] , pdsch_dim_reduction.beam_sort_out[58] , pdsch_dim_reduction.beam_sort_out[59] ,
            pdsch_dim_reduction.beam_sort_out[60] , pdsch_dim_reduction.beam_sort_out[61] , pdsch_dim_reduction.beam_sort_out[62] , pdsch_dim_reduction.beam_sort_out[63] 
        );
end

endmodule