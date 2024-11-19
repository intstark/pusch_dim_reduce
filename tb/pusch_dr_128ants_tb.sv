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


module pusch_dr_128ants_tb;



parameter                                           FILE_IQDATA00           = "../vector/datain/ul_data_00.txt";
parameter                                           FILE_IQDATA01           = "../vector/datain/ul_data_01.txt";
parameter                                           FILE_IQDATA02           = "../vector/datain/ul_data_02.txt";
parameter                                           FILE_IQDATA03           = "../vector/datain/ul_data_03.txt";
parameter                                           FILE_IQDATA04           = "../vector/datain/ul_data_04.txt";
parameter                                           FILE_IQDATA05           = "../vector/datain/ul_data_05.txt";
parameter                                           FILE_IQDATA06           = "../vector/datain/ul_data_06.txt";
parameter                                           FILE_IQDATA07           = "../vector/datain/ul_data_07.txt";

parameter                                           FILE_IQDATA10           = "../vector/datain/ul_data_10.txt";
parameter                                           FILE_IQDATA11           = "../vector/datain/ul_data_11.txt";
parameter                                           FILE_IQDATA12           = "../vector/datain/ul_data_12.txt";
parameter                                           FILE_IQDATA13           = "../vector/datain/ul_data_13.txt";
parameter                                           FILE_IQDATA14           = "../vector/datain/ul_data_14.txt";
parameter                                           FILE_IQDATA15           = "../vector/datain/ul_data_15.txt";
parameter                                           FILE_IQDATA16           = "../vector/datain/ul_data_16.txt";
parameter                                           FILE_IQDATA17           = "../vector/datain/ul_data_17.txt";

parameter                                           FILE_IQDATA20           = "../vector/datain/ul_data_20.txt";
parameter                                           FILE_IQDATA21           = "../vector/datain/ul_data_21.txt";
parameter                                           FILE_IQDATA22           = "../vector/datain/ul_data_22.txt";
parameter                                           FILE_IQDATA23           = "../vector/datain/ul_data_23.txt";
parameter                                           FILE_IQDATA24           = "../vector/datain/ul_data_24.txt";
parameter                                           FILE_IQDATA25           = "../vector/datain/ul_data_25.txt";
parameter                                           FILE_IQDATA26           = "../vector/datain/ul_data_26.txt";
parameter                                           FILE_IQDATA27           = "../vector/datain/ul_data_27.txt";
                                                                                                        
parameter                                           FILE_IQDATA30           = "../vector/datain/ul_data_30.txt";
parameter                                           FILE_IQDATA31           = "../vector/datain/ul_data_31.txt";
parameter                                           FILE_IQDATA32           = "../vector/datain/ul_data_32.txt";
parameter                                           FILE_IQDATA33           = "../vector/datain/ul_data_33.txt";
parameter                                           FILE_IQDATA34           = "../vector/datain/ul_data_34.txt";
parameter                                           FILE_IQDATA35           = "../vector/datain/ul_data_35.txt";
parameter                                           FILE_IQDATA36           = "../vector/datain/ul_data_36.txt";
parameter                                           FILE_IQDATA37           = "../vector/datain/ul_data_37.txt";

parameter                                           FILE_UNZIP_DATA        = "./des_unzip_data.txt";
parameter                                           FILE_BEAMS_DATA        = "./des_beams_data.txt";
parameter                                           FILE_BEAMS_SORT0       = "./des_beams_sort0.txt";
parameter                                           FILE_BEAMS_SORT1       = "./des_beams_sort1.txt";
parameter                                           FILE_BEAMS_SORT2       = "./des_beams_sort2.txt";
parameter                                           FILE_BEAMS_SORT3       = "./des_beams_sort3.txt";
parameter                                           FILE_BEAMS_IDX0        = "./des_beams_idx0.txt";
parameter                                           FILE_BEAMS_IDX1        = "./des_beams_idx1.txt";
parameter                                           FILE_BEAMS_IDX2        = "./des_beams_idx2.txt";
parameter                                           FILE_BEAMS_IDX3        = "./des_beams_idx3.txt";
parameter                                           FILE_CPRS_DATA0        = "compress_data0.txt";
parameter                                           FILE_CPRS_DATA1        = "compress_data1.txt";
parameter                                           FILE_CPRS_DATA2        = "compress_data2.txt";
parameter                                           FILE_CPRS_DATA3        = "compress_data3.txt";

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
genvar gi,gj;
integer fid_iq_data00, fid_iq_data01, fid_iq_data02, fid_iq_data03, fid_iq_data04, fid_iq_data05, fid_iq_data06, fid_iq_data07;
integer fid_iq_data10, fid_iq_data11, fid_iq_data12, fid_iq_data13, fid_iq_data14, fid_iq_data15, fid_iq_data16, fid_iq_data17;
integer fid_iq_data20, fid_iq_data21, fid_iq_data22, fid_iq_data23, fid_iq_data24, fid_iq_data25, fid_iq_data26, fid_iq_data27;
integer fid_iq_data30, fid_iq_data31, fid_iq_data32, fid_iq_data33, fid_iq_data34, fid_iq_data35, fid_iq_data36, fid_iq_data37;

integer fid_ant_data, fid_cwd_odd, fid_cwd_even;
integer fid_rx_data;
integer fid_rb_agc;

integer fid_beams_sort0,fid_beams_idx0,fid_dr_data0;
integer fid_beams_sort1,fid_beams_idx1,fid_dr_data1;
integer fid_beams_sort2,fid_beams_idx2,fid_dr_data2;
integer fid_beams_sort3,fid_beams_idx3,fid_dr_data3;



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



reg            [3:0][7:0][32*4-1: 0]            ant_datain            =0;
reg                                             ant_data_vld          =0;
reg            [  10: 0]                        ant_re_num            =0;
wire                                            ant_re_last             ;

wire           [7:0][10: 0]                     iq0_addr                ;
wire           [7:0][4*32-1: 0]                 iq0_data                ;
wire           [   7: 0]                        iq0_vld                 ;
wire           [   7: 0]                        iq0_last                ;

wire           [7:0][10: 0]                     iq1_addr                ;
wire           [7:0][4*32-1: 0]                 iq1_data                ;
wire           [   7: 0]                        iq1_vld                 ;
wire           [   7: 0]                        iq1_last                ;

wire           [7:0][10: 0]                     iq2_addr                ;
wire           [7:0][4*32-1: 0]                 iq2_data                ;
wire           [   7: 0]                        iq2_vld                 ;
wire           [   7: 0]                        iq2_last                ;

wire           [7:0][10: 0]                     iq3_addr                ;
wire           [7:0][4*32-1: 0]                 iq3_data                ;
wire           [   7: 0]                        iq3_vld                 ;
wire           [   7: 0]                        iq3_last                ;


reg            [7:0][3167:0][4*32-1: 0]         ant_sym_mem           =0;
reg            [   2: 0]                        wr_page               =0;
reg            [   7: 0]                        ant_mem_vld           =0;
reg            [  10: 0]                        rd_mem_addr           =0;
wire           [3:0][7:0][4*32-1: 0]            ant_dout_data           ;
wire           [  10: 0]                        ant_dout_addr           ;
wire                                            ant_dout_vld            ;
wire                                            ant_dout_last           ;
reg            [   2: 0]                        rd_page               =0;
wire           [   2: 0]                        dout_page               ;

wire                                            dr0_sop                 ;
wire                                            dr0_eop                 ;
wire                                            dr0_vld                 ;
wire           [3:0][31: 0]                     dr0_data                ;

wire                                            dr1_sop                  ;
wire                                            dr1_eop                  ;
wire                                            dr1_vld                  ;
wire           [15:0][15: 0]                    dr1_data                 ;

wire                                            dr2_sop                  ;
wire                                            dr2_eop                  ;
wire                                            dr2_vld                  ;
wire           [15:0][15: 0]                    dr2_data                 ;

wire                                            dr3_sop                  ;
wire                                            dr3_eop                  ;
wire                                            dr3_vld                  ;
wire           [15:0][15: 0]                    dr3_data                 ;

//------------------------------------------------------------------------------------------
// 8 Lanes data
//------------------------------------------------------------------------------------------
assign iq0_addr = {8{ant_dout_addr}};
assign iq0_data = ant_dout_data[0];
assign iq0_vld  = {8{ant_dout_vld}};
assign iq0_last = {8{ant_dout_last}};

assign iq1_addr = {8{ant_dout_addr}};
assign iq1_data = ant_dout_data[1];
assign iq1_vld  = {8{ant_dout_vld}};
assign iq1_last = {8{ant_dout_last}};

assign iq2_addr = {8{ant_dout_addr}};
assign iq2_data = ant_dout_data[2];
assign iq2_vld  = {8{ant_dout_vld}};
assign iq2_last = {8{ant_dout_last}};

assign iq3_addr = {8{ant_dout_addr}};
assign iq3_data = ant_dout_data[3];
assign iq3_vld  = {8{ant_dout_vld}};
assign iq3_last = {8{ant_dout_last}};



//------------------------------------------------------------------------------------------
// AAU1-AIU1
//------------------------------------------------------------------------------------------
pusch_dr_core                                           pusch_dr_core_aiu0(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_rbg_size                                         (rbg_size               ),
    .i_aiu_idx                                          (1'b0                   ),

    .i_iq_addr                                          (iq0_addr               ),// 32 ants iq addrk
    .i_iq_data                                          (iq0_data               ),// 32 ants iq datat
    .i_iq_vld                                           (iq0_vld                ),// 32 ants iq vld
    .i_iq_last                                          (iq0_last               ),// 32 ants iq last(132prb ends)

    .o_dr_data                                          (dr0_data               ),
    .o_dr_vld                                           (dr0_vld                ),
    .o_dr_sop                                           (dr0_sop                ),
    .o_dr_eop                                           (dr0_eop                )
);

//------------------------------------------------------------------------------------------
// AAU1-AIU2
//------------------------------------------------------------------------------------------
pusch_dr_core                                           pusch_dr_core_aiu1(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_rbg_size                                         (rbg_size               ),
    .i_aiu_idx                                          (1'b1                   ),

    .i_iq_addr                                          (iq1_addr               ),// 32 ants iq addrk
    .i_iq_data                                          (iq1_data               ),// 32 ants iq datat
    .i_iq_vld                                           (iq1_vld                ),// 32 ants iq vld
    .i_iq_last                                          (iq1_last               ),// 32 ants iq last(132prb ends)

    .o_dr_data                                          (dr1_data               ),
    .o_dr_vld                                           (dr1_vld                ),
    .o_dr_sop                                           (dr1_sop                ),
    .o_dr_eop                                           (dr1_eop                )
);

//------------------------------------------------------------------------------------------
// AAU2-AIU1
//------------------------------------------------------------------------------------------
pusch_dr_core                                           pusch_dr_core_aiu2(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_rbg_size                                         (rbg_size               ),
    .i_aiu_idx                                          (1'b0                   ),

    .i_iq_addr                                          (iq2_addr               ),// 32 ants iq addrk
    .i_iq_data                                          (iq2_data               ),// 32 ants iq datat
    .i_iq_vld                                           (iq2_vld                ),// 32 ants iq vld
    .i_iq_last                                          (iq2_last               ),// 32 ants iq last(132prb ends)

    .o_dr_data                                          (dr2_data               ),
    .o_dr_vld                                           (dr2_vld                ),
    .o_dr_sop                                           (dr2_sop                ),
    .o_dr_eop                                           (dr2_eop                )
);

//------------------------------------------------------------------------------------------
// AAU2-AIU2
//------------------------------------------------------------------------------------------
pusch_dr_core                                           pusch_dr_core_aiu3(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_rbg_size                                         (rbg_size               ),
    .i_aiu_idx                                          (1'b1                   ),

    .i_iq_addr                                          (iq3_addr               ),// 32 ants iq addrk
    .i_iq_data                                          (iq3_data               ),// 32 ants iq datat
    .i_iq_vld                                           (iq3_vld                ),// 32 ants iq vld
    .i_iq_last                                          (iq3_last               ),// 32 ants iq last(132prb ends)

    .o_dr_data                                          (dr3_data               ),
    .o_dr_vld                                           (dr3_vld                ),
    .o_dr_sop                                           (dr3_sop                ),
    .o_dr_eop                                           (dr3_eop                )
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
// Read data intput 
//------------------------------------------------------------------------------------------
initial begin
    fid_iq_data00 = $fopen(FILE_IQDATA00,"r");
    fid_iq_data01 = $fopen(FILE_IQDATA01,"r");
    fid_iq_data02 = $fopen(FILE_IQDATA02,"r");
    fid_iq_data03 = $fopen(FILE_IQDATA03,"r");
    fid_iq_data04 = $fopen(FILE_IQDATA04,"r");
    fid_iq_data05 = $fopen(FILE_IQDATA05,"r");
    fid_iq_data06 = $fopen(FILE_IQDATA06,"r");
    fid_iq_data07 = $fopen(FILE_IQDATA07,"r");
                                      
    fid_iq_data10 = $fopen(FILE_IQDATA10,"r");
    fid_iq_data11 = $fopen(FILE_IQDATA11,"r");
    fid_iq_data12 = $fopen(FILE_IQDATA12,"r");
    fid_iq_data13 = $fopen(FILE_IQDATA13,"r");
    fid_iq_data14 = $fopen(FILE_IQDATA14,"r");
    fid_iq_data15 = $fopen(FILE_IQDATA15,"r");
    fid_iq_data16 = $fopen(FILE_IQDATA16,"r");
    fid_iq_data17 = $fopen(FILE_IQDATA17,"r");
                                      
    fid_iq_data20 = $fopen(FILE_IQDATA20,"r");
    fid_iq_data21 = $fopen(FILE_IQDATA21,"r");
    fid_iq_data22 = $fopen(FILE_IQDATA22,"r");
    fid_iq_data23 = $fopen(FILE_IQDATA23,"r");
    fid_iq_data24 = $fopen(FILE_IQDATA24,"r");
    fid_iq_data25 = $fopen(FILE_IQDATA25,"r");
    fid_iq_data26 = $fopen(FILE_IQDATA26,"r");
    fid_iq_data27 = $fopen(FILE_IQDATA27,"r");
                                       
    fid_iq_data30 = $fopen(FILE_IQDATA30,"r");
    fid_iq_data31 = $fopen(FILE_IQDATA31,"r");
    fid_iq_data32 = $fopen(FILE_IQDATA32,"r");
    fid_iq_data33 = $fopen(FILE_IQDATA33,"r");
    fid_iq_data34 = $fopen(FILE_IQDATA34,"r");
    fid_iq_data35 = $fopen(FILE_IQDATA35,"r");
    fid_iq_data36 = $fopen(FILE_IQDATA36,"r");
    fid_iq_data37 = $fopen(FILE_IQDATA37,"r");


    #(`SIM_ENDS_TIME);
    $fclose(fid_iq_data00); $fclose(fid_iq_data10); $fclose(fid_iq_data20); $fclose(fid_iq_data30);
    $fclose(fid_iq_data01); $fclose(fid_iq_data11); $fclose(fid_iq_data21); $fclose(fid_iq_data31);
    $fclose(fid_iq_data02); $fclose(fid_iq_data12); $fclose(fid_iq_data22); $fclose(fid_iq_data32);
    $fclose(fid_iq_data03); $fclose(fid_iq_data13); $fclose(fid_iq_data23); $fclose(fid_iq_data33);
    $fclose(fid_iq_data04); $fclose(fid_iq_data14); $fclose(fid_iq_data24); $fclose(fid_iq_data34);
    $fclose(fid_iq_data05); $fclose(fid_iq_data15); $fclose(fid_iq_data25); $fclose(fid_iq_data35);
    $fclose(fid_iq_data06); $fclose(fid_iq_data16); $fclose(fid_iq_data26); $fclose(fid_iq_data36);
    $fclose(fid_iq_data07); $fclose(fid_iq_data17); $fclose(fid_iq_data27); $fclose(fid_iq_data37);
end



always @(posedge i_clk) begin
    if(reset==0)begin
        $fscanf(fid_iq_data00, "%h\n", ant_datain[0][0]);
        $fscanf(fid_iq_data01, "%h\n", ant_datain[0][1]);
        $fscanf(fid_iq_data02, "%h\n", ant_datain[0][2]);
        $fscanf(fid_iq_data03, "%h\n", ant_datain[0][3]);
        $fscanf(fid_iq_data04, "%h\n", ant_datain[0][4]);
        $fscanf(fid_iq_data05, "%h\n", ant_datain[0][5]);
        $fscanf(fid_iq_data06, "%h\n", ant_datain[0][6]);
        $fscanf(fid_iq_data07, "%h\n", ant_datain[0][7]);
                                                  
        $fscanf(fid_iq_data10, "%h\n", ant_datain[1][0]);
        $fscanf(fid_iq_data11, "%h\n", ant_datain[1][1]);
        $fscanf(fid_iq_data12, "%h\n", ant_datain[1][2]);
        $fscanf(fid_iq_data13, "%h\n", ant_datain[1][3]);
        $fscanf(fid_iq_data14, "%h\n", ant_datain[1][4]);
        $fscanf(fid_iq_data15, "%h\n", ant_datain[1][5]);
        $fscanf(fid_iq_data16, "%h\n", ant_datain[1][6]);
        $fscanf(fid_iq_data17, "%h\n", ant_datain[1][7]);
                                                  
        $fscanf(fid_iq_data20, "%h\n", ant_datain[2][0]);
        $fscanf(fid_iq_data21, "%h\n", ant_datain[2][1]);
        $fscanf(fid_iq_data22, "%h\n", ant_datain[2][2]);
        $fscanf(fid_iq_data23, "%h\n", ant_datain[2][3]);
        $fscanf(fid_iq_data24, "%h\n", ant_datain[2][4]);
        $fscanf(fid_iq_data25, "%h\n", ant_datain[2][5]);
        $fscanf(fid_iq_data26, "%h\n", ant_datain[2][6]);
        $fscanf(fid_iq_data27, "%h\n", ant_datain[2][7]);
                                                  
        $fscanf(fid_iq_data30, "%h\n", ant_datain[3][0]);
        $fscanf(fid_iq_data31, "%h\n", ant_datain[3][1]);
        $fscanf(fid_iq_data32, "%h\n", ant_datain[3][2]);
        $fscanf(fid_iq_data33, "%h\n", ant_datain[3][3]);
        $fscanf(fid_iq_data34, "%h\n", ant_datain[3][4]);
        $fscanf(fid_iq_data35, "%h\n", ant_datain[3][5]);
        $fscanf(fid_iq_data36, "%h\n", ant_datain[3][6]);
        $fscanf(fid_iq_data37, "%h\n", ant_datain[3][7]);

        ant_data_vld <= 1'b1;

        if(ant_re_num==1583)
            ant_re_num <= 0;
        else if(ant_data_vld)
            ant_re_num <= ant_re_num + 1;
    end
end

assign ant_re_last = (ant_re_num==1583) ? 1'b1 : 1'b0;


//--------------------------------------------------------------------------------------
// cpri rx data buffer
//--------------------------------------------------------------------------------------
generate
    genvar ch;
    for(ch=0;ch<8;ch=ch+1) begin: ant_symbol_buffer 
        ant_symbol_buffer #(
            .WDATA_WIDTH                                        (32*DIN_ANTS            ),
            .WADDR_WIDTH                                        (12                     ),
            .RDATA_WIDTH                                        (32*DIN_ANTS            ),
            .RADDR_WIDTH                                        (12                     ),
            .FIFO_DEPTH                                         (8                      ),
            .FIFO_WIDTH                                         (1                      ),
            .READ_LATENCY                                       (3                      ),
            .LOOP_WIDTH                                         (15                     ),
            .INFO_WIDTH                                         (1                      ),
            .RAM_TYPE                                           (1                      ) 
        )ant_symbol_buffer(
            .i_clk                                              (i_clk                  ),
            .i_reset                                            (reset                  ),
            .i_rx_data                                          (ant_datain   [0][ch]   ),
            .i_rvalid                                           (ant_data_vld           ),
            .i_rready                                           (1'b1                   ),
            .o_tx_data                                          (ant_dout_data[0][ch]   ),
            .o_tx_addr                                          (ant_dout_addr          ),
            .o_tx_last                                          (ant_dout_last          ),
            .o_tvalid                                           (ant_dout_vld           ) 
        );
    end
endgenerate

generate
    for(ch=0;ch<8;ch=ch+1) begin: ant_symbol_buffer1
        ant_symbol_buffer #(
            .WDATA_WIDTH                                        (32*DIN_ANTS            ),
            .WADDR_WIDTH                                        (12                     ),
            .RDATA_WIDTH                                        (32*DIN_ANTS            ),
            .RADDR_WIDTH                                        (12                     ),
            .FIFO_DEPTH                                         (8                      ),
            .FIFO_WIDTH                                         (1                      ),
            .READ_LATENCY                                       (3                      ),
            .LOOP_WIDTH                                         (15                     ),
            .INFO_WIDTH                                         (1                      ),
            .RAM_TYPE                                           (1                      ) 
        )ant_symbol_buffer_1(
            .i_clk                                              (i_clk                  ),
            .i_reset                                            (reset                  ),
            .i_rx_data                                          (ant_datain   [1][ch]   ),
            .i_rvalid                                           (ant_data_vld           ),
            .i_rready                                           (1'b1                   ),
            .o_tx_data                                          (ant_dout_data[1][ch]   ),
            .o_tx_addr                                          (                       ),
            .o_tx_last                                          (                       ),
            .o_tvalid                                           (                       ) 
        );
    end
endgenerate

generate
    for(ch=0;ch<8;ch=ch+1) begin: ant_symbol_buffer2
        ant_symbol_buffer #(
            .WDATA_WIDTH                                        (32*DIN_ANTS            ),
            .WADDR_WIDTH                                        (12                     ),
            .RDATA_WIDTH                                        (32*DIN_ANTS            ),
            .RADDR_WIDTH                                        (12                     ),
            .FIFO_DEPTH                                         (8                      ),
            .FIFO_WIDTH                                         (1                      ),
            .READ_LATENCY                                       (3                      ),
            .LOOP_WIDTH                                         (15                     ),
            .INFO_WIDTH                                         (1                      ),
            .RAM_TYPE                                           (1                      ) 
        )ant_symbol_buffer_2(
            .i_clk                                              (i_clk                  ),
            .i_reset                                            (reset                  ),
            .i_rx_data                                          (ant_datain   [2][ch]   ),
            .i_rvalid                                           (ant_data_vld           ),
            .i_rready                                           (1'b1                   ),
            .o_tx_data                                          (ant_dout_data[2][ch]   ),
            .o_tx_addr                                          (                       ),
            .o_tx_last                                          (                       ),
            .o_tvalid                                           (                       ) 
        );
    end
endgenerate

generate
    for(ch=0;ch<8;ch=ch+1) begin: ant_symbol_buffer3
        ant_symbol_buffer #(
            .WDATA_WIDTH                                        (32*DIN_ANTS            ),
            .WADDR_WIDTH                                        (12                     ),
            .RDATA_WIDTH                                        (32*DIN_ANTS            ),
            .RADDR_WIDTH                                        (12                     ),
            .FIFO_DEPTH                                         (8                      ),
            .FIFO_WIDTH                                         (1                      ),
            .READ_LATENCY                                       (3                      ),
            .LOOP_WIDTH                                         (15                     ),
            .INFO_WIDTH                                         (1                      ),
            .RAM_TYPE                                           (1                      ) 
        )ant_symbol_buffer_3(
            .i_clk                                              (i_clk                  ),
            .i_reset                                            (reset                  ),
            .i_rx_data                                          (ant_datain   [3][ch]   ),
            .i_rvalid                                           (ant_data_vld           ),
            .i_rready                                           (1'b1                   ),
            .o_tx_data                                          (ant_dout_data[3][ch]   ),
            .o_tx_addr                                          (                       ),
            .o_tx_last                                          (                       ),
            .o_tvalid                                           (                       ) 
        );
    end
endgenerate

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
// Output data file
//------------------------------------------------------------------------------------------
initial begin
    fid_beams_sort0 = $fopen(FILE_BEAMS_SORT0,"w");
    fid_beams_sort1 = $fopen(FILE_BEAMS_SORT1,"w");
    fid_beams_sort2 = $fopen(FILE_BEAMS_SORT2,"w");
    fid_beams_sort3 = $fopen(FILE_BEAMS_SORT3,"w");
    fid_beams_idx0  = $fopen(FILE_BEAMS_IDX0,"w");
    fid_beams_idx1  = $fopen(FILE_BEAMS_IDX1,"w");
    fid_beams_idx2  = $fopen(FILE_BEAMS_IDX2,"w");
    fid_beams_idx3  = $fopen(FILE_BEAMS_IDX3,"w");
    fid_dr_data0    = $fopen(FILE_CPRS_DATA0, "w");
    fid_dr_data1    = $fopen(FILE_CPRS_DATA1, "w");
    fid_dr_data2    = $fopen(FILE_CPRS_DATA2, "w");
    fid_dr_data3    = $fopen(FILE_CPRS_DATA3, "w");

    #(`SIM_ENDS_TIME);
    $fclose(fid_beams_sort0 );
    $fclose(fid_beams_sort1 );
    $fclose(fid_beams_sort2 );
    $fclose(fid_beams_sort3 );
    $fclose(fid_beams_idx0  );
    $fclose(fid_beams_idx1  );
    $fclose(fid_beams_idx2  );
    $fclose(fid_beams_idx3  );
    $fclose(fid_dr_data0);
    $fclose(fid_dr_data1);
    $fclose(fid_dr_data2);
    $fclose(fid_dr_data3);
    $stop;
end

//------------------------------------------------------------------------------------------
// Write beam power 
//------------------------------------------------------------------------------------------
// aiu0
always @(posedge i_clk) 
    write_beam_pwr(
                        fid_beams_sort0, 
                        pusch_dr_core_aiu0.beam_sort_load,
                        pusch_dr_core_aiu0.beam_sort_pwr
    );
// aiu1
always @(posedge i_clk) 
    write_beam_pwr(
                        fid_beams_sort1, 
                        pusch_dr_core_aiu1.beam_sort_load,
                        pusch_dr_core_aiu1.beam_sort_pwr
    );
// aiu2
always @(posedge i_clk) 
    write_beam_pwr(
                        fid_beams_sort2, 
                        pusch_dr_core_aiu2.beam_sort_load,
                        pusch_dr_core_aiu2.beam_sort_pwr
    );
// aiu3
always @(posedge i_clk) 
    write_beam_pwr(
                        fid_beams_sort3, 
                        pusch_dr_core_aiu3.beam_sort_load,
                        pusch_dr_core_aiu3.beam_sort_pwr
    );

//------------------------------------------------------------------------------------------
// Write beam index
//------------------------------------------------------------------------------------------
// aiu0 beam index 
always @(posedge i_clk) 
    write_beamindex(
                        fid_beams_idx0, 
                        pusch_dr_core_aiu0.beam_sort.data_vld,
                        pusch_dr_core_aiu0.beam_sort.sort_addr
    );

// aiu2 beam index 
always @(posedge i_clk) 
    write_beamindex(
                        fid_beams_idx1, 
                        pusch_dr_core_aiu1.beam_sort.data_vld,
                        pusch_dr_core_aiu1.beam_sort.sort_addr
    );

// aiu2 beam index 
always @(posedge i_clk) 
    write_beamindex(
                        fid_beams_idx2, 
                        pusch_dr_core_aiu2.beam_sort.data_vld,
                        pusch_dr_core_aiu2.beam_sort.sort_addr
    );

// aiu3 beam index 
always @(posedge i_clk) 
    write_beamindex(
                        fid_beams_idx3, 
                        pusch_dr_core_aiu3.beam_sort.data_vld,
                        pusch_dr_core_aiu3.beam_sort.sort_addr
    );


//------------------------------------------------------------------------------------------
// Write dr data 
//------------------------------------------------------------------------------------------

// aiu0
always @(posedge i_clk) 
    write_dr_data(
                        fid_dr_data0, 
                        pusch_dr_core_aiu0.compress_matrix.o_vld,
                        pusch_dr_core_aiu0.compress_matrix.o_dout_re,
                        pusch_dr_core_aiu0.compress_matrix.o_dout_im
    );

// aiu1
always @(posedge i_clk) 
    write_dr_data(
                        fid_dr_data1, 
                        pusch_dr_core_aiu1.compress_matrix.o_vld,
                        pusch_dr_core_aiu1.compress_matrix.o_dout_re,
                        pusch_dr_core_aiu1.compress_matrix.o_dout_im
    );

// aiu2
always @(posedge i_clk) 
    write_dr_data(
                        fid_dr_data2, 
                        pusch_dr_core_aiu2.compress_matrix.o_vld,
                        pusch_dr_core_aiu2.compress_matrix.o_dout_re,
                        pusch_dr_core_aiu2.compress_matrix.o_dout_im
    );

// aiu3
always @(posedge i_clk) 
    write_dr_data(
                        fid_dr_data3, 
                        pusch_dr_core_aiu3.compress_matrix.o_vld,
                        pusch_dr_core_aiu3.compress_matrix.o_dout_re,
                        pusch_dr_core_aiu3.compress_matrix.o_dout_im
    );



endmodule