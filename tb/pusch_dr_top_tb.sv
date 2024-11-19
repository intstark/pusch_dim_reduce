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
integer fid_tx_data, fid_beams_data;
integer fid_rx_data0,fid_rx_data1,fid_rx_data2,fid_rx_data3,fid_rx_data4,fid_rx_data5,fid_rx_data6,fid_rx_data7;
integer fid_uzip_data0,fid_uzip_data1,fid_uzip_data2,fid_uzip_data3,fid_uzip_data4,fid_uzip_data5,fid_uzip_data6,fid_uzip_data7;
integer fid_beams_pwr, fid_beams_sort,fid_beams_idx;
integer fid_cprs_data;


// Inputs
reg                                             i_clk                 =0;
reg                                             reset                 =1;
reg                                             tx_hfp                =0;
reg            [   1: 0]                        rbg_size              =2;

wire           [   7: 0]                        iq_rx_vld               ;
wire           [7:0][63: 0]                     iq_rx_data              ;
reg            [7:0][6: 0]                      iq_rx_seq             =0;
wire           [   7: 0]                        cpri_iq_vld           ;

wire           [   7: 0]                        cpri_clk                ;
wire           [   7: 0]                        cpri_rst                ;
wire           [7:0][63: 0]                     cpri_rx_data            ;
wire           [   7: 0]                        cpri_rx_vld             ;



reg            [ 127: 0]                        ul0_data_sim[0: numDL-1];
reg            [ 127: 0]                        ul1_data_sim[0: numDL-1];
reg            [ 127: 0]                        ul2_data_sim[0: numDL-1];
reg            [ 127: 0]                        ul3_data_sim[0: numDL-1];
reg            [ 127: 0]                        ul4_data_sim[0: numDL-1];
reg            [ 127: 0]                        ul5_data_sim[0: numDL-1];
reg            [ 127: 0]                        ul6_data_sim[0: numDL-1];
reg            [ 127: 0]                        ul7_data_sim[0: numDL-1];

reg            [ 127: 0]                        ul_data_sim[0:7][0:numDL-1];

//------------------------------------------------------------------------------------------
// UL data
//------------------------------------------------------------------------------------------
initial $readmemh (FILE_IQDATA0, ul0_data_sim);
initial $readmemh (FILE_IQDATA1, ul1_data_sim);
initial $readmemh (FILE_IQDATA2, ul2_data_sim);
initial $readmemh (FILE_IQDATA3, ul3_data_sim);
initial $readmemh (FILE_IQDATA4, ul4_data_sim);
initial $readmemh (FILE_IQDATA5, ul5_data_sim);
initial $readmemh (FILE_IQDATA6, ul6_data_sim);
initial $readmemh (FILE_IQDATA7, ul7_data_sim);


assign ul_data_sim[0] = ul0_data_sim;
assign ul_data_sim[1] = ul1_data_sim;
assign ul_data_sim[2] = ul2_data_sim;
assign ul_data_sim[3] = ul3_data_sim;
assign ul_data_sim[4] = ul4_data_sim;
assign ul_data_sim[5] = ul5_data_sim;
assign ul_data_sim[6] = ul6_data_sim;
assign ul_data_sim[7] = ul7_data_sim;


//------------------------------------------------------------------------------------------
// DL
//------------------------------------------------------------------------------------------
generate for (gi=0; gi<8; gi=gi+1) begin:gen_dl_data 
    dl_data_gen                                             dl_data_gen
    (

        .sys_clk_491_52                                     (i_clk                  ),
        .sys_rst_491_52                                     (reset                  ),
        .sys_clk_368_64                                     (i_clk                  ),
        .sys_rst_368_64                                     (reset                  ),
        .sys_clk_245_76                                     (reset                  ),
        .sys_rst_245_76                                     (reset                  ),
        .fpga_clk_250mhz                                    (i_clk                  ),
        .fpga_rst_250mhz                                    (reset                  ),
        .dl_data_sim                                        (ul_data_sim[gi]        )
    );
end
endgenerate


assign iq_rx_data[0] = gen_dl_data[0].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [0] = gen_dl_data[0].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;
assign iq_rx_data[1] = gen_dl_data[1].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [1] = gen_dl_data[1].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;
assign iq_rx_data[2] = gen_dl_data[2].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [2] = gen_dl_data[2].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;
assign iq_rx_data[3] = gen_dl_data[3].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [3] = gen_dl_data[3].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;
assign iq_rx_data[4] = gen_dl_data[4].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [4] = gen_dl_data[4].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;
assign iq_rx_data[5] = gen_dl_data[5].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [5] = gen_dl_data[5].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;
assign iq_rx_data[6] = gen_dl_data[6].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [6] = gen_dl_data[6].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;
assign iq_rx_data[7] = gen_dl_data[7].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_data;
assign iq_rx_vld [7] = gen_dl_data[7].dl_data_gen.ant_parallel[0].u_dl_symb_if.o_iq_tx_valid;


always @(posedge i_clk) begin
    for(int i=0; i<8; i++) begin
        if(iq_rx_seq[i] == 95)
            iq_rx_seq[i] <= 0;
        else if(iq_rx_vld[i])
            iq_rx_seq[i] <= iq_rx_seq[i] + 1;
        else
            iq_rx_seq[i] <= 0;
    end
end

reg            [  63: 0]                        l1_iq_rx_data           ;
reg                                             l1_iq_rx_vld            ;
always @(posedge i_clk) begin
    l1_iq_rx_data <= iq_rx_data[0];
    l1_iq_rx_vld <= cpri_iq_vld[0];
end

generate for (gi=0; gi<8; gi=gi+1) begin: gen_cpri_vld 
    assign cpri_iq_vld[gi] = (iq_rx_vld[gi] && (iq_rx_seq[gi] == 0)) ? 1'b1 : 1'b0;
end
endgenerate



assign cpri_clk          = {8{i_clk}};
assign cpri_rst          = {8{reset}};
//assign cpri_rx_data[0]   = l1_iq_rx_data;
//assign cpri_rx_vld [0]   = l1_iq_rx_vld;
assign cpri_rx_data[7:0] = iq_rx_data [7:0];
assign cpri_rx_vld [7:0] = cpri_iq_vld[7:0];
//assign cpri_rx_data[7:0] = {8{iq_rx_data [0]}};
//assign cpri_rx_vld [7:0] = {8{cpri_iq_vld[0]}};


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
    .o_cpri0_tx_data                                    (                       ),
    .o_cpri0_tx_vld                                     (                       ),
    .o_cpri1_tx_data                                    (                       ),
    .o_cpri1_tx_vld                                     (                       ) 
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
    $stop;
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



endmodule