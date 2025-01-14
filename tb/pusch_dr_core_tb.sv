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


module pusch_dr_core_tb;



parameter                                           FILE_IQDATA            = "../vector/dl_data_sim.txt";
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
parameter                                           ANT                    = 32    ;
parameter                                           IW                     = 32    ;
parameter                                           OW                     = 48    ;


// Signals
genvar gi,gj;
integer fid_iq_data, fid_ant_data, fid_cwd_odd, fid_cwd_even;
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

reg            [32*4-1: 0]                      ant_datain            =0;
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
reg            [4*32-1: 0]                      ant_dataout           =0;
reg            [  10: 0]                        rd_mem_addr           =0;
wire           [4*32-1: 0]                      ant_dout_data           ;
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
assign iq_data = {8{ant_dout_data}};
assign iq_vld  = {8{ant_dout_vld}};
assign iq_last = {8{ant_dout_last}};


//------------------------------------------------------------------------------------------
// UL -- dut
//------------------------------------------------------------------------------------------
pusch_dr_core                                           pusch_dr_core(
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
    fid_iq_data = $fopen(FILE_IQDATA,"r");
    if(fid_iq_data)
        $display("succeed open file %s",FILE_IQDATA);
    else
        $display("failed open file %s",FILE_IQDATA);

    #(`SIM_ENDS_TIME);
    $fclose(fid_iq_data);
end



always @(posedge i_clk) begin
    if(reset==0)begin
        $fscanf(fid_iq_data, "%h\n", ant_datain);
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
ant_symbol_buffer #(
    .WDATA_WIDTH                                        (128                    ),
    .WADDR_WIDTH                                        (12                     ),
    .RDATA_WIDTH                                        (128                    ),
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
    .i_rx_data                                          (ant_datain             ),
    .i_rvalid                                           (ant_data_vld           ),
    .i_rready                                           (1'b1                   ),
    .o_tx_data                                          (ant_dout_data          ),
    .o_tx_addr                                          (ant_dout_addr          ),
    .o_tx_last                                          (ant_dout_last          ),
    .o_tvalid                                           (ant_dout_vld           ) 
);

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
    if(pusch_dr_core.beams_tvalid)
        $fwrite(fid_beams_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,\
                         %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
                            pusch_dr_core.mac_beams.o_data_even_i[ 0] ,pusch_dr_core.mac_beams.o_data_even_q[ 0] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 0] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 0] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 1] ,pusch_dr_core.mac_beams.o_data_even_q[ 1] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 1] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 1] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 2] ,pusch_dr_core.mac_beams.o_data_even_q[ 2] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 2] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 2] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 3] ,pusch_dr_core.mac_beams.o_data_even_q[ 3] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 3] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 3] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 4] ,pusch_dr_core.mac_beams.o_data_even_q[ 4] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 4] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 4] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 5] ,pusch_dr_core.mac_beams.o_data_even_q[ 5] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 5] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 5] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 6] ,pusch_dr_core.mac_beams.o_data_even_q[ 6] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 6] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 6] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 7] ,pusch_dr_core.mac_beams.o_data_even_q[ 7] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 7] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 7] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 8] ,pusch_dr_core.mac_beams.o_data_even_q[ 8] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 8] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 8] ,
                            pusch_dr_core.mac_beams.o_data_even_i[ 9] ,pusch_dr_core.mac_beams.o_data_even_q[ 9] ,  pusch_dr_core.mac_beams.o_data_odd_i[ 9] ,  pusch_dr_core.mac_beams.o_data_odd_q[ 9] ,
                            pusch_dr_core.mac_beams.o_data_even_i[10] ,pusch_dr_core.mac_beams.o_data_even_q[10] ,  pusch_dr_core.mac_beams.o_data_odd_i[10] ,  pusch_dr_core.mac_beams.o_data_odd_q[10] ,
                            pusch_dr_core.mac_beams.o_data_even_i[11] ,pusch_dr_core.mac_beams.o_data_even_q[11] ,  pusch_dr_core.mac_beams.o_data_odd_i[11] ,  pusch_dr_core.mac_beams.o_data_odd_q[11] ,
                            pusch_dr_core.mac_beams.o_data_even_i[12] ,pusch_dr_core.mac_beams.o_data_even_q[12] ,  pusch_dr_core.mac_beams.o_data_odd_i[12] ,  pusch_dr_core.mac_beams.o_data_odd_q[12] ,
                            pusch_dr_core.mac_beams.o_data_even_i[13] ,pusch_dr_core.mac_beams.o_data_even_q[13] ,  pusch_dr_core.mac_beams.o_data_odd_i[13] ,  pusch_dr_core.mac_beams.o_data_odd_q[13] ,
                            pusch_dr_core.mac_beams.o_data_even_i[14] ,pusch_dr_core.mac_beams.o_data_even_q[14] ,  pusch_dr_core.mac_beams.o_data_odd_i[14] ,  pusch_dr_core.mac_beams.o_data_odd_q[14] ,
                            pusch_dr_core.mac_beams.o_data_even_i[15] ,pusch_dr_core.mac_beams.o_data_even_q[15] ,  pusch_dr_core.mac_beams.o_data_odd_i[15] ,  pusch_dr_core.mac_beams.o_data_odd_q[15] 
        );
end

// 64 beams data after buffer aligned 
always @(posedge i_clk) begin
    if(pusch_dr_core.rbg_buffer_vld)
        $fwrite(fid_beams_pwr, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pusch_dr_core.rbg_buffer_out[ 0] , pusch_dr_core.rbg_buffer_out[ 1] , pusch_dr_core.rbg_buffer_out[ 2] , pusch_dr_core.rbg_buffer_out[ 3] ,
            pusch_dr_core.rbg_buffer_out[ 4] , pusch_dr_core.rbg_buffer_out[ 5] , pusch_dr_core.rbg_buffer_out[ 6] , pusch_dr_core.rbg_buffer_out[ 7] ,
            pusch_dr_core.rbg_buffer_out[ 8] , pusch_dr_core.rbg_buffer_out[ 9] , pusch_dr_core.rbg_buffer_out[10] , pusch_dr_core.rbg_buffer_out[11] ,
            pusch_dr_core.rbg_buffer_out[12] , pusch_dr_core.rbg_buffer_out[13] , pusch_dr_core.rbg_buffer_out[14] , pusch_dr_core.rbg_buffer_out[15] ,
            pusch_dr_core.rbg_buffer_out[16] , pusch_dr_core.rbg_buffer_out[17] , pusch_dr_core.rbg_buffer_out[18] , pusch_dr_core.rbg_buffer_out[19] ,
            pusch_dr_core.rbg_buffer_out[20] , pusch_dr_core.rbg_buffer_out[21] , pusch_dr_core.rbg_buffer_out[22] , pusch_dr_core.rbg_buffer_out[23] ,
            pusch_dr_core.rbg_buffer_out[24] , pusch_dr_core.rbg_buffer_out[25] , pusch_dr_core.rbg_buffer_out[26] , pusch_dr_core.rbg_buffer_out[27] ,
            pusch_dr_core.rbg_buffer_out[28] , pusch_dr_core.rbg_buffer_out[29] , pusch_dr_core.rbg_buffer_out[30] , pusch_dr_core.rbg_buffer_out[31] ,
            pusch_dr_core.rbg_buffer_out[32] , pusch_dr_core.rbg_buffer_out[33] , pusch_dr_core.rbg_buffer_out[34] , pusch_dr_core.rbg_buffer_out[35] ,
            pusch_dr_core.rbg_buffer_out[36] , pusch_dr_core.rbg_buffer_out[37] , pusch_dr_core.rbg_buffer_out[38] , pusch_dr_core.rbg_buffer_out[39] ,
            pusch_dr_core.rbg_buffer_out[40] , pusch_dr_core.rbg_buffer_out[41] , pusch_dr_core.rbg_buffer_out[42] , pusch_dr_core.rbg_buffer_out[43] ,
            pusch_dr_core.rbg_buffer_out[44] , pusch_dr_core.rbg_buffer_out[45] , pusch_dr_core.rbg_buffer_out[46] , pusch_dr_core.rbg_buffer_out[47] ,
            pusch_dr_core.rbg_buffer_out[48] , pusch_dr_core.rbg_buffer_out[49] , pusch_dr_core.rbg_buffer_out[50] , pusch_dr_core.rbg_buffer_out[51] ,
            pusch_dr_core.rbg_buffer_out[52] , pusch_dr_core.rbg_buffer_out[53] , pusch_dr_core.rbg_buffer_out[54] , pusch_dr_core.rbg_buffer_out[55] ,
            pusch_dr_core.rbg_buffer_out[56] , pusch_dr_core.rbg_buffer_out[57] , pusch_dr_core.rbg_buffer_out[58] , pusch_dr_core.rbg_buffer_out[59] ,
            pusch_dr_core.rbg_buffer_out[60] , pusch_dr_core.rbg_buffer_out[61] , pusch_dr_core.rbg_buffer_out[62] , pusch_dr_core.rbg_buffer_out[63] 
        );
end

// 64 beams power after sorted 
always @(posedge i_clk) begin
    if(pusch_dr_core.beam_sort_load)
        $fwrite(fid_beams_sort, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d,\
                                %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
            pusch_dr_core.beam_sort_out[ 0] , pusch_dr_core.beam_sort_out[ 1] , pusch_dr_core.beam_sort_out[ 2] , pusch_dr_core.beam_sort_out[ 3] ,
            pusch_dr_core.beam_sort_out[ 4] , pusch_dr_core.beam_sort_out[ 5] , pusch_dr_core.beam_sort_out[ 6] , pusch_dr_core.beam_sort_out[ 7] ,
            pusch_dr_core.beam_sort_out[ 8] , pusch_dr_core.beam_sort_out[ 9] , pusch_dr_core.beam_sort_out[10] , pusch_dr_core.beam_sort_out[11] ,
            pusch_dr_core.beam_sort_out[12] , pusch_dr_core.beam_sort_out[13] , pusch_dr_core.beam_sort_out[14] , pusch_dr_core.beam_sort_out[15] ,
            pusch_dr_core.beam_sort_out[16] , pusch_dr_core.beam_sort_out[17] , pusch_dr_core.beam_sort_out[18] , pusch_dr_core.beam_sort_out[19] ,
            pusch_dr_core.beam_sort_out[20] , pusch_dr_core.beam_sort_out[21] , pusch_dr_core.beam_sort_out[22] , pusch_dr_core.beam_sort_out[23] ,
            pusch_dr_core.beam_sort_out[24] , pusch_dr_core.beam_sort_out[25] , pusch_dr_core.beam_sort_out[26] , pusch_dr_core.beam_sort_out[27] ,
            pusch_dr_core.beam_sort_out[28] , pusch_dr_core.beam_sort_out[29] , pusch_dr_core.beam_sort_out[30] , pusch_dr_core.beam_sort_out[31] ,
            pusch_dr_core.beam_sort_out[32] , pusch_dr_core.beam_sort_out[33] , pusch_dr_core.beam_sort_out[34] , pusch_dr_core.beam_sort_out[35] ,
            pusch_dr_core.beam_sort_out[36] , pusch_dr_core.beam_sort_out[37] , pusch_dr_core.beam_sort_out[38] , pusch_dr_core.beam_sort_out[39] ,
            pusch_dr_core.beam_sort_out[40] , pusch_dr_core.beam_sort_out[41] , pusch_dr_core.beam_sort_out[42] , pusch_dr_core.beam_sort_out[43] ,
            pusch_dr_core.beam_sort_out[44] , pusch_dr_core.beam_sort_out[45] , pusch_dr_core.beam_sort_out[46] , pusch_dr_core.beam_sort_out[47] ,
            pusch_dr_core.beam_sort_out[48] , pusch_dr_core.beam_sort_out[49] , pusch_dr_core.beam_sort_out[50] , pusch_dr_core.beam_sort_out[51] ,
            pusch_dr_core.beam_sort_out[52] , pusch_dr_core.beam_sort_out[53] , pusch_dr_core.beam_sort_out[54] , pusch_dr_core.beam_sort_out[55] ,
            pusch_dr_core.beam_sort_out[56] , pusch_dr_core.beam_sort_out[57] , pusch_dr_core.beam_sort_out[58] , pusch_dr_core.beam_sort_out[59] ,
            pusch_dr_core.beam_sort_out[60] , pusch_dr_core.beam_sort_out[61] , pusch_dr_core.beam_sort_out[62] , pusch_dr_core.beam_sort_out[63] 
        );
end

// sorted beam index 
always @(posedge i_clk) begin
    if(pusch_dr_core.beam_sort.data_vld)
        $fwrite(fid_beams_idx, "%d,%d,%d,%d,%d,%d,%d,%d, %d,%d,%d,%d,%d,%d,%d,%d\n", 
                pusch_dr_core.beam_sort.sort_addr[ 0] ,
                pusch_dr_core.beam_sort.sort_addr[ 1] ,
                pusch_dr_core.beam_sort.sort_addr[ 2] ,
                pusch_dr_core.beam_sort.sort_addr[ 3] ,
                pusch_dr_core.beam_sort.sort_addr[ 4] ,
                pusch_dr_core.beam_sort.sort_addr[ 5] ,
                pusch_dr_core.beam_sort.sort_addr[ 6] ,
                pusch_dr_core.beam_sort.sort_addr[ 7] ,
                pusch_dr_core.beam_sort.sort_addr[ 8] ,
                pusch_dr_core.beam_sort.sort_addr[ 9] ,
                pusch_dr_core.beam_sort.sort_addr[10] ,
                pusch_dr_core.beam_sort.sort_addr[11] ,
                pusch_dr_core.beam_sort.sort_addr[12] ,
                pusch_dr_core.beam_sort.sort_addr[13] ,
                pusch_dr_core.beam_sort.sort_addr[14] ,
                pusch_dr_core.beam_sort.sort_addr[15] 
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
    if(pusch_dr_core.compress_matrix.o_vld)
        $fwrite(fid_cprs_data, "%d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d\n", 
                                pusch_dr_core.compress_matrix.o_dout_re[ 0][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 0][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 1][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 1][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 2][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 2][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 3][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 3][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 4][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 4][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 5][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 5][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 6][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 6][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 7][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 7][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 8][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 8][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[ 9][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[ 9][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[10][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[10][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[11][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[11][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[12][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[12][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[13][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[13][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[14][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[14][15: 0],
                                pusch_dr_core.compress_matrix.o_dout_re[15][15: 0] , pusch_dr_core.compress_matrix.o_dout_im[15][15: 0]
    );
end


endmodule