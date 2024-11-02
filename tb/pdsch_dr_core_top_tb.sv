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


module pdsch_dr_core_top_tb;



parameter                                           FILE_IQDATA0           = "../vector/datain/ul_data_00.txt";
parameter                                           FILE_IQDATA1           = "../vector/datain/ul_data_01.txt";
parameter                                           FILE_IQDATA2           = "../vector/datain/ul_data_02.txt";
parameter                                           FILE_IQDATA3           = "../vector/datain/ul_data_03.txt";
parameter                                           FILE_IQDATA4           = "../vector/datain/ul_data_04.txt";
parameter                                           FILE_IQDATA5           = "../vector/datain/ul_data_05.txt";
parameter                                           FILE_IQDATA6           = "../vector/datain/ul_data_06.txt";
parameter                                           FILE_IQDATA7           = "../vector/datain/ul_data_07.txt";
parameter                                           FILE_CWD_ODD           = "./code_word_odd.txt";
parameter                                           FILE_CWD_EVEN          = "./code_word_even.txt";
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
genvar gi,gj;
integer fid_iq_data0, fid_iq_data1, fid_iq_data2, fid_iq_data3, fid_iq_data4, fid_iq_data5, fid_iq_data6, fid_iq_data7;
integer fid_ant_data, fid_cwd_odd, fid_cwd_even;
integer fid_tx_data, fid_rx_data, fid_unzip_data, fid_beams_data;
integer fid_rb_agc;
integer fid_beams_pwr, fid_beams_sort,fid_beams_idx;
integer fid_cprs_data;




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



reg            [7:0][32*4-1: 0]                 ant_datain            =0;
reg                                             ant_data_vld          =0;
reg            [  10: 0]                        ant_re_num            =0;
wire                                            ant_re_last             ;
wire           [7:0][10: 0]                     iq_addr                 ;
wire           [7:0][4*32-1: 0]                 iq_data                 ;
wire           [   7: 0]                        iq_vld                  ;
wire           [   7: 0]                        iq_last                 ;

reg            [7:0][3167:0][4*32-1: 0]         ant_sym_mem           =0;
reg            [   2: 0]                        wr_page               =0;
reg            [   7: 0]                        ant_mem_vld           =0;
reg            [  10: 0]                        rd_mem_addr           =0;
wire           [7:0][4*32-1: 0]                 ant_dout_data           ;
wire           [  10: 0]                        ant_dout_addr           ;
wire                                            ant_dout_vld            ;
wire                                            ant_dout_last           ;
reg            [   2: 0]                        rd_page               =0;
wire           [   2: 0]                        dout_page               ;

wire                                            dr_sop                  ;
wire                                            dr_eop                  ;
wire                                            dr_vld                  ;
wire           [15:0][15: 0]                    dr_data_re              ;
wire           [15:0][15: 0]                    dr_data_im              ;


//------------------------------------------------------------------------------------------
// 8 Lanes data
//------------------------------------------------------------------------------------------
assign iq_addr = {8{ant_dout_addr}};
assign iq_data =    ant_dout_data;
assign iq_vld  = {8{ant_dout_vld}};
assign iq_last = {8{ant_dout_last}};




//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pdsch_dr_core                                           pdsch_dr_core(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    
    .i_rbg_size                                         (rbg_size               ),

    .i_iq_addr                                          (iq_addr                ),// 32 ants iq addrk
    .i_iq_data                                          (iq_data                ),// 32 ants iq datat
    .i_iq_vld                                           (iq_vld                 ),// 32 ants iq vld
    .i_iq_last                                          (iq_last                ),// 32 ants iq last(132prb ends)

    .o_dr_sop                                           (dr_sop                 ),
    .o_dr_eop                                           (dr_eop                 ),
    .o_dr_vld                                           (dr_vld                 ),
    .o_dr_data_re                                       (dr_data_re             ),
    .o_dr_data_im                                       (dr_data_im             ) 
);


reg    [15:0]  sim_cnt;
reg    [6:0]   iq_tx_cnt;
reg            iq_tx_enable;
reg    [8:0]   chip_num;


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

wire [15:0][31:0] dr_data_iq;
for(genvar i=0;i<16;i++)begin
    assign dr_data_iq[i] = {dr_data_re[i],dr_data_im[i]};
end

wire           [   3:0][31:0]                   dr_txdata               ;
wire                                            dr_tx_vld               ;
wire                                            dr_tx_sop               ;
wire                                            dr_tx_eop               ;
wire           [   8: 0]                        dr_prb_idx              ;

dr_data_buffer                                          dr_data_buffer(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (reset                  ),
    .i_rx_data                                          (dr_data_iq             ),
    .i_rx_vld                                           (dr_vld                 ),
    .i_rx_sop                                           (dr_sop                 ),
    .i_rx_eop                                           (dr_eop                 ),
    .i_rready                                           (1'b1                   ),
    .o_tx_data                                          (dr_txdata              ),
    .o_tx_vld                                           (dr_tx_vld              ),
    .o_tx_sop                                           (dr_tx_sop              ),
    .o_tx_eop                                           (dr_tx_eop              ),
    .o_prb_idx                                          (dr_prb_idx             )
);


//------------------------------------------------------------------------------------------
// cpri txdata & repack: TODO
// -----------------------------------------------------------------------------------------
cpri_txdata_top                                         cpri_txdata_top(
    .sys_clk_491_52                                     (i_clk                  ),
    .sys_rst_491_52                                     (reset                  ),
    .sys_clk_368_64                                     (i_clk                  ),
    .sys_rst_368_64                                     (reset                  ),
    .i_if_re_sel                                        (                       ),
    .i_if_re_vld                                        ({4{dr_tx_vld}}         ),
    .i_if_re_sop                                        ({4{dr_tx_sop}}         ),
    .i_if_re_eop                                        ({4{dr_tx_eop}}         ),
    .i_if_re_ant0                                       (dr_txdata[0]           ),
    .i_if_re_ant1                                       (dr_txdata[1]           ),
    .i_if_re_ant2                                       (dr_txdata[2]           ),
    .i_if_re_ant3                                       (dr_txdata[3]           ),
    .i_if_re_slot_idx                                   (0                      ),
    .i_if_re_sym_idx                                    (0                      ),
    .i_if_re_prb_idx                                    (dr_prb_idx             ),
    .i_if_re_info0                                      (0                      ),
    .i_if_re_info1                                      (0                      ),
    .i_if_re_info2                                      (0                      ),
    .i_if_re_info3                                      (0                      ),
    .i_iq_tx_enable                                     (iq_tx_enable           ),
    .o_iq_tx_valid                                      (                       ),
    .o_iq_tx_data                                       (                       ) 
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
    fid_iq_data0 = $fopen(FILE_IQDATA0,"r");
    fid_iq_data1 = $fopen(FILE_IQDATA1,"r");
    fid_iq_data2 = $fopen(FILE_IQDATA2,"r");
    fid_iq_data3 = $fopen(FILE_IQDATA3,"r");
    fid_iq_data4 = $fopen(FILE_IQDATA4,"r");
    fid_iq_data5 = $fopen(FILE_IQDATA5,"r");
    fid_iq_data6 = $fopen(FILE_IQDATA6,"r");
    fid_iq_data7 = $fopen(FILE_IQDATA7,"r");

    if(fid_iq_data0)
        $display("succeed open file %s",FILE_IQDATA0);
    else
        $display("failed open file %s",FILE_IQDATA0);

    #(`SIM_ENDS_TIME);
    $fclose(fid_iq_data0);
    $fclose(fid_iq_data1);
    $fclose(fid_iq_data2);
    $fclose(fid_iq_data3);
    $fclose(fid_iq_data4);
    $fclose(fid_iq_data5);
    $fclose(fid_iq_data6);
    $fclose(fid_iq_data7);
end



always @(posedge i_clk) begin
    if(reset==0)begin
        $fscanf(fid_iq_data0, "%h\n", ant_datain[0]);
        $fscanf(fid_iq_data1, "%h\n", ant_datain[1]);
        $fscanf(fid_iq_data2, "%h\n", ant_datain[2]);
        $fscanf(fid_iq_data3, "%h\n", ant_datain[3]);
        $fscanf(fid_iq_data4, "%h\n", ant_datain[4]);
        $fscanf(fid_iq_data5, "%h\n", ant_datain[5]);
        $fscanf(fid_iq_data6, "%h\n", ant_datain[6]);
        $fscanf(fid_iq_data7, "%h\n", ant_datain[7]);

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
            .i_rx_data                                          (ant_datain   [ch]      ),
            .i_rvalid                                           (ant_data_vld           ),
            .i_rready                                           (1'b1                   ),
            .o_tx_data                                          (ant_dout_data[ch]      ),
            .o_tx_addr                                          (ant_dout_addr          ),
            .o_tx_last                                          (ant_dout_last          ),
            .o_tvalid                                           (ant_dout_vld           ) 
        );
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


// data after beams calculation 
always @(posedge i_clk) begin
    if(pdsch_dr_core.beams_tvalid)
        $fwrite(fid_beams_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,\
                         %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
                            pdsch_dr_core.mac_beams.o_data_even_i[ 0] ,pdsch_dr_core.mac_beams.o_data_even_q[ 0] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 0] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 0] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 1] ,pdsch_dr_core.mac_beams.o_data_even_q[ 1] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 1] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 1] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 2] ,pdsch_dr_core.mac_beams.o_data_even_q[ 2] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 2] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 2] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 3] ,pdsch_dr_core.mac_beams.o_data_even_q[ 3] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 3] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 3] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 4] ,pdsch_dr_core.mac_beams.o_data_even_q[ 4] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 4] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 4] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 5] ,pdsch_dr_core.mac_beams.o_data_even_q[ 5] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 5] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 5] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 6] ,pdsch_dr_core.mac_beams.o_data_even_q[ 6] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 6] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 6] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 7] ,pdsch_dr_core.mac_beams.o_data_even_q[ 7] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 7] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 7] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 8] ,pdsch_dr_core.mac_beams.o_data_even_q[ 8] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 8] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 8] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[ 9] ,pdsch_dr_core.mac_beams.o_data_even_q[ 9] ,  pdsch_dr_core.mac_beams.o_data_odd_i[ 9] ,  pdsch_dr_core.mac_beams.o_data_odd_q[ 9] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[10] ,pdsch_dr_core.mac_beams.o_data_even_q[10] ,  pdsch_dr_core.mac_beams.o_data_odd_i[10] ,  pdsch_dr_core.mac_beams.o_data_odd_q[10] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[11] ,pdsch_dr_core.mac_beams.o_data_even_q[11] ,  pdsch_dr_core.mac_beams.o_data_odd_i[11] ,  pdsch_dr_core.mac_beams.o_data_odd_q[11] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[12] ,pdsch_dr_core.mac_beams.o_data_even_q[12] ,  pdsch_dr_core.mac_beams.o_data_odd_i[12] ,  pdsch_dr_core.mac_beams.o_data_odd_q[12] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[13] ,pdsch_dr_core.mac_beams.o_data_even_q[13] ,  pdsch_dr_core.mac_beams.o_data_odd_i[13] ,  pdsch_dr_core.mac_beams.o_data_odd_q[13] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[14] ,pdsch_dr_core.mac_beams.o_data_even_q[14] ,  pdsch_dr_core.mac_beams.o_data_odd_i[14] ,  pdsch_dr_core.mac_beams.o_data_odd_q[14] ,
                            pdsch_dr_core.mac_beams.o_data_even_i[15] ,pdsch_dr_core.mac_beams.o_data_even_q[15] ,  pdsch_dr_core.mac_beams.o_data_odd_i[15] ,  pdsch_dr_core.mac_beams.o_data_odd_q[15] 
        );
end

// 64 beams data after buffer aligned 
always @(posedge i_clk) begin
    if(pdsch_dr_core.rbg_buffer_vld)
        $fwrite(fid_beams_pwr, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pdsch_dr_core.rbg_buffer_out[ 0] , pdsch_dr_core.rbg_buffer_out[ 1] , pdsch_dr_core.rbg_buffer_out[ 2] , pdsch_dr_core.rbg_buffer_out[ 3] ,
            pdsch_dr_core.rbg_buffer_out[ 4] , pdsch_dr_core.rbg_buffer_out[ 5] , pdsch_dr_core.rbg_buffer_out[ 6] , pdsch_dr_core.rbg_buffer_out[ 7] ,
            pdsch_dr_core.rbg_buffer_out[ 8] , pdsch_dr_core.rbg_buffer_out[ 9] , pdsch_dr_core.rbg_buffer_out[10] , pdsch_dr_core.rbg_buffer_out[11] ,
            pdsch_dr_core.rbg_buffer_out[12] , pdsch_dr_core.rbg_buffer_out[13] , pdsch_dr_core.rbg_buffer_out[14] , pdsch_dr_core.rbg_buffer_out[15] ,
            pdsch_dr_core.rbg_buffer_out[16] , pdsch_dr_core.rbg_buffer_out[17] , pdsch_dr_core.rbg_buffer_out[18] , pdsch_dr_core.rbg_buffer_out[19] ,
            pdsch_dr_core.rbg_buffer_out[20] , pdsch_dr_core.rbg_buffer_out[21] , pdsch_dr_core.rbg_buffer_out[22] , pdsch_dr_core.rbg_buffer_out[23] ,
            pdsch_dr_core.rbg_buffer_out[24] , pdsch_dr_core.rbg_buffer_out[25] , pdsch_dr_core.rbg_buffer_out[26] , pdsch_dr_core.rbg_buffer_out[27] ,
            pdsch_dr_core.rbg_buffer_out[28] , pdsch_dr_core.rbg_buffer_out[29] , pdsch_dr_core.rbg_buffer_out[30] , pdsch_dr_core.rbg_buffer_out[31] ,
            pdsch_dr_core.rbg_buffer_out[32] , pdsch_dr_core.rbg_buffer_out[33] , pdsch_dr_core.rbg_buffer_out[34] , pdsch_dr_core.rbg_buffer_out[35] ,
            pdsch_dr_core.rbg_buffer_out[36] , pdsch_dr_core.rbg_buffer_out[37] , pdsch_dr_core.rbg_buffer_out[38] , pdsch_dr_core.rbg_buffer_out[39] ,
            pdsch_dr_core.rbg_buffer_out[40] , pdsch_dr_core.rbg_buffer_out[41] , pdsch_dr_core.rbg_buffer_out[42] , pdsch_dr_core.rbg_buffer_out[43] ,
            pdsch_dr_core.rbg_buffer_out[44] , pdsch_dr_core.rbg_buffer_out[45] , pdsch_dr_core.rbg_buffer_out[46] , pdsch_dr_core.rbg_buffer_out[47] ,
            pdsch_dr_core.rbg_buffer_out[48] , pdsch_dr_core.rbg_buffer_out[49] , pdsch_dr_core.rbg_buffer_out[50] , pdsch_dr_core.rbg_buffer_out[51] ,
            pdsch_dr_core.rbg_buffer_out[52] , pdsch_dr_core.rbg_buffer_out[53] , pdsch_dr_core.rbg_buffer_out[54] , pdsch_dr_core.rbg_buffer_out[55] ,
            pdsch_dr_core.rbg_buffer_out[56] , pdsch_dr_core.rbg_buffer_out[57] , pdsch_dr_core.rbg_buffer_out[58] , pdsch_dr_core.rbg_buffer_out[59] ,
            pdsch_dr_core.rbg_buffer_out[60] , pdsch_dr_core.rbg_buffer_out[61] , pdsch_dr_core.rbg_buffer_out[62] , pdsch_dr_core.rbg_buffer_out[63] 
        );
end

// 64 beams power after sorted 
always @(posedge i_clk) begin
    if(pdsch_dr_core.beam_sort_load)
        $fwrite(fid_beams_sort, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pdsch_dr_core.beam_sort_out[ 0] , pdsch_dr_core.beam_sort_out[ 1] , pdsch_dr_core.beam_sort_out[ 2] , pdsch_dr_core.beam_sort_out[ 3] ,
            pdsch_dr_core.beam_sort_out[ 4] , pdsch_dr_core.beam_sort_out[ 5] , pdsch_dr_core.beam_sort_out[ 6] , pdsch_dr_core.beam_sort_out[ 7] ,
            pdsch_dr_core.beam_sort_out[ 8] , pdsch_dr_core.beam_sort_out[ 9] , pdsch_dr_core.beam_sort_out[10] , pdsch_dr_core.beam_sort_out[11] ,
            pdsch_dr_core.beam_sort_out[12] , pdsch_dr_core.beam_sort_out[13] , pdsch_dr_core.beam_sort_out[14] , pdsch_dr_core.beam_sort_out[15] ,
            pdsch_dr_core.beam_sort_out[16] , pdsch_dr_core.beam_sort_out[17] , pdsch_dr_core.beam_sort_out[18] , pdsch_dr_core.beam_sort_out[19] ,
            pdsch_dr_core.beam_sort_out[20] , pdsch_dr_core.beam_sort_out[21] , pdsch_dr_core.beam_sort_out[22] , pdsch_dr_core.beam_sort_out[23] ,
            pdsch_dr_core.beam_sort_out[24] , pdsch_dr_core.beam_sort_out[25] , pdsch_dr_core.beam_sort_out[26] , pdsch_dr_core.beam_sort_out[27] ,
            pdsch_dr_core.beam_sort_out[28] , pdsch_dr_core.beam_sort_out[29] , pdsch_dr_core.beam_sort_out[30] , pdsch_dr_core.beam_sort_out[31] ,
            pdsch_dr_core.beam_sort_out[32] , pdsch_dr_core.beam_sort_out[33] , pdsch_dr_core.beam_sort_out[34] , pdsch_dr_core.beam_sort_out[35] ,
            pdsch_dr_core.beam_sort_out[36] , pdsch_dr_core.beam_sort_out[37] , pdsch_dr_core.beam_sort_out[38] , pdsch_dr_core.beam_sort_out[39] ,
            pdsch_dr_core.beam_sort_out[40] , pdsch_dr_core.beam_sort_out[41] , pdsch_dr_core.beam_sort_out[42] , pdsch_dr_core.beam_sort_out[43] ,
            pdsch_dr_core.beam_sort_out[44] , pdsch_dr_core.beam_sort_out[45] , pdsch_dr_core.beam_sort_out[46] , pdsch_dr_core.beam_sort_out[47] ,
            pdsch_dr_core.beam_sort_out[48] , pdsch_dr_core.beam_sort_out[49] , pdsch_dr_core.beam_sort_out[50] , pdsch_dr_core.beam_sort_out[51] ,
            pdsch_dr_core.beam_sort_out[52] , pdsch_dr_core.beam_sort_out[53] , pdsch_dr_core.beam_sort_out[54] , pdsch_dr_core.beam_sort_out[55] ,
            pdsch_dr_core.beam_sort_out[56] , pdsch_dr_core.beam_sort_out[57] , pdsch_dr_core.beam_sort_out[58] , pdsch_dr_core.beam_sort_out[59] ,
            pdsch_dr_core.beam_sort_out[60] , pdsch_dr_core.beam_sort_out[61] , pdsch_dr_core.beam_sort_out[62] , pdsch_dr_core.beam_sort_out[63] 
        );
end

// sorted beam index 
always @(posedge i_clk) begin
    if(pdsch_dr_core.beam_sort.data_vld)
        $fwrite(fid_beams_idx, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
                pdsch_dr_core.beam_sort.sort_addr[ 0] ,
                pdsch_dr_core.beam_sort.sort_addr[ 1] ,
                pdsch_dr_core.beam_sort.sort_addr[ 2] ,
                pdsch_dr_core.beam_sort.sort_addr[ 3] ,
                pdsch_dr_core.beam_sort.sort_addr[ 4] ,
                pdsch_dr_core.beam_sort.sort_addr[ 5] ,
                pdsch_dr_core.beam_sort.sort_addr[ 6] ,
                pdsch_dr_core.beam_sort.sort_addr[ 7] ,
                pdsch_dr_core.beam_sort.sort_addr[ 8] ,
                pdsch_dr_core.beam_sort.sort_addr[ 9] ,
                pdsch_dr_core.beam_sort.sort_addr[10] ,
                pdsch_dr_core.beam_sort.sort_addr[11] ,
                pdsch_dr_core.beam_sort.sort_addr[12] ,
                pdsch_dr_core.beam_sort.sort_addr[13] ,
                pdsch_dr_core.beam_sort.sort_addr[14] ,
                pdsch_dr_core.beam_sort.sort_addr[15] 
        );
end


initial begin
    fid_cprs_data = $fopen(FILE_CPRS_DATA, "w");
    if(fid_cprs_data)
        $display("succeed open file %s",FILE_CPRS_DATA);
    else
        $display("failed open file %s",FILE_CPRS_DATA);

    #(`SIM_ENDS_TIME);
    $stop;
end

//------------------------------------------------------------------------------------------
// Write data output
//------------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(pdsch_dr_core.compress_matrix.o_vld)
        $fwrite(fid_cprs_data, "%d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d\n", 
                                pdsch_dr_core.compress_matrix.o_dout_re[ 0][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 0][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 1][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 1][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 2][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 2][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 3][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 3][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 4][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 4][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 5][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 5][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 6][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 6][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 7][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 7][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 8][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 8][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[ 9][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[ 9][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[10][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[10][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[11][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[11][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[12][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[12][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[13][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[13][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[14][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[14][15: 0],
                                pdsch_dr_core.compress_matrix.o_dout_re[15][15: 0] , pdsch_dr_core.compress_matrix.o_dout_im[15][15: 0]
    );
end


endmodule