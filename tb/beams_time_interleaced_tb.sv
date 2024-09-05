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
`define SIM_ENDS_TIME 60000

`include "params_list_pkg.sv"


module beams_time_interleaced_tb;



parameter                                           FILE_IQDATA            = "./iq_data.txt";
parameter                                           FILE_ANTDATA           = "./ant_data.txt";
parameter                                           FILE_CWD_ODD           = "./code_word_odd.txt";
parameter                                           FILE_CWD_EVEN          = "./code_word_even.txt";
parameter                                           FILE_BEAM_ODD          = "./beam_data_odd.txt";
parameter                                           FILE_BEAM_EVEN         = "./beam_data_even.txt";
parameter                                           FILE_BEAM_ALL          = "./beam_data.txt";

// Parameters
parameter                                           DW                     = 8     ;
parameter                                           numBeams               = 16    ;
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
integer fid_beam_odd, fid_beam_even, fid_beam_all;

// Inputs
reg                                             i_clk                 =1'b0;
reg                                             reset                 =1'b1;
wire                                            iq_rx_valid             ;
wire           [  63: 0]                        iq_rx_data              ;
reg            [  63: 0]                        rx_data               =0;
reg            [   6: 0]                        rx_seq                =0;
wire           [  63: 0]                        rx_mask                 ;
wire           [   7: 0]                        rx_crtl                 ;

wire           [  63: 0]                        tx_data                 ;
wire           [  63: 0]                        tx_mask                 ;
wire           [   7: 0]                        tx_crtl                 ;
reg            [   6: 0]                        tx_seq                =0;
reg            [   7: 0]                        tx_x                  =0;
reg                                             tx_hfp                =0;

reg            [  63: 0]                        iq_data                 ;
wire           [  63: 0]                        iq_mask                 ;
wire           [  63: 0]                        cm_data                 ;
wire           [  63: 0]                        cm_mask                 ;

// Outputs
wire           [ANT-1:0][DW-1: 0]               o_iq_data               ;
wire           [ANT-1:0][DW-1: 0]               o_cm_data               ;

reg            [numTDL-1:0][6: 0]               data_i                  ;
reg            [numTDL-1:0][6: 0]               data_q                  ;

reg            [   8: 0]                        prb_num               =0;
reg            [   7: 0]                        re_per_prb            =0;
reg            [  15: 0]                        re_num                =0;
reg            [  13: 0]                        pkg_data              =0;
reg            [   3: 0]                        sym_num               =0;

reg                                             tx_vld                =0;
wire                                            tx_sop                  ;
wire                                            tx_eop                  ;

reg            [   3: 0]                        rb_agc                =0;
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




package_data                                            package_data
(
    .clk                                                (i_clk                  ),
    .rst                                                (reset                  ),
    .i_sel                                              (                       ),
    .i_vld                                              (tx_vld                 ),
    .i_sop                                              (tx_sop                 ),
    .i_eop                                              (tx_eop                 ),
    .i_pkg0_ch_type                                     (0                      ),
    .i_pkg0_cell_idx                                    (0                      ),
    .i_pkg0_ant_idx                                     (0                      ),
    .i_pkg0_slot_idx                                    (0                      ),
    .i_pkg0_sym_idx                                     (0                      ),
    .i_pkg0_prb_idx                                     (prb_num                ),
    .i_pkg0_info                                        (0                      ),
    .i_pkg0_data                                        (pkg_data               ),
    .i_pkg0_shift                                       (rb_agc                 ),
                
    .i_pkg1_ch_type                                     (0                      ),
    .i_pkg1_cell_idx                                    (0                      ),
    .i_pkg1_ant_idx                                     (0                      ),
    .i_pkg1_slot_idx                                    (0                      ),
    .i_pkg1_sym_idx                                     (0                      ),
    .i_pkg1_prb_idx                                     (prb_num                ),
    .i_pkg1_info                                        (0                      ),
    .i_pkg1_data                                        (pkg_data               ),
    .i_pkg1_shift                                       (rb_agc                 ),
                
    .i_pkg2_ch_type                                     (0                      ),
    .i_pkg2_cell_idx                                    (0                      ),
    .i_pkg2_ant_idx                                     (0                      ),
    .i_pkg2_slot_idx                                    (0                      ),
    .i_pkg2_sym_idx                                     (0                      ),
    .i_pkg2_prb_idx                                     (prb_num                ),
    .i_pkg2_info                                        (0                      ),
    .i_pkg2_data                                        (pkg_data               ),
    .i_pkg2_shift                                       (rb_agc                 ),
                
    .i_pkg3_ch_type                                     (0                      ),
    .i_pkg3_cell_idx                                    (0                      ),
    .i_pkg3_ant_idx                                     (0                      ),
    .i_pkg3_slot_idx                                    (0                      ),
    .i_pkg3_sym_idx                                     (0                      ),
    .i_pkg3_prb_idx                                     (prb_num                ),
    .i_pkg3_info                                        (0                      ),
    .i_pkg3_data                                        (pkg_data               ),
    .i_pkg3_shift                                       (rb_agc                 ),
                
    .o_cpri_wen                                         (m_cpri_wen             ),
    .o_cpri_waddr                                       (m_cpri_waddr           ),
    .o_cpri_wdata                                       (m_cpri_wdata           ),
    .o_cpri_wlast                                       (m_cpri_wlast           ) 
);

                
cpri_tx_gen                                             u_cpri_tx_gen
(
    .wr_clk                                             (i_clk                  ),
    .wr_rst                                             (reset                  ),
    .rd_clk                                             (i_clk                  ),
    .rd_rst                                             (reset                  ),
    .i_cpri_wen                                         (m_cpri_wen             ),
    .i_cpri_waddr                                       (m_cpri_waddr           ),
    .i_cpri_wdata                                       (m_cpri_wdata           ),
    .i_cpri_wlast                                       (m_cpri_wlast           ),
    .i_iq_tx_enable                                     (1'b1                   ),
    .o_iq_tx_valid                                      (iq_rx_valid            ),
    .o_iq_tx_data                                       (iq_rx_data             ) 
);

always @(posedge i_clk) begin
    if(rx_seq==95)
        rx_seq <= 0;
    else if(iq_rx_valid)
        rx_seq <= rx_seq + 1;
    else
        rx_seq <= 0;
end

wire           [   7:0][10:0]                   unpack_iq_addr          ;
wire           [7:0][3:0][31: 0]                unpack_iq_data          ;
wire           [   7: 0]                        unpack_iq_vld           ;
wire           [   7: 0]                        unpack_iq_last          ;

wire           [7:0][4*32-1: 0]                 ant_even                ;
wire           [7:0][4*32-1: 0]                 ant_odd                 ;
wire           [7:0][11-1: 0]                   ant_addr                ;
wire           [   7: 0]                        ant_tvalid              ;

wire           [32*32-1: 0]                     ant_data_even           ;
wire           [32*32-1: 0]                     ant_data_odd            ;
wire                                            mac_beams_tvalid        ;
reg                                             sym1_done             =0;





generate for(gi=0;gi<8;gi=gi+1) begin:gen_rxdata_unpack
    // Instantiate the Unit Under Test (UUT)
    cpri_rxdata_unpack                                      cpri_rxdata_unpack_4ant
    (
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (reset                  ),
        .i_cpri_rx_data                                     (iq_rx_data             ),
        .i_cpri_rx_seq                                      (rx_seq                 ),
        .i_cpri_rx_vld                                      (iq_rx_valid            ),
        .i_sym1_done                                        (sym1_done              ),
        .o_iq_addr                                          (unpack_iq_addr[gi]     ),
        .o_iq_data                                          (unpack_iq_data[gi]     ),
        .o_iq_vld                                           (unpack_iq_vld [gi]     ),
        .o_iq_last                                          (unpack_iq_last[gi]     ) 
    );

    ant_data_buffer #(
        .ANT                                                (4                      ),
        .WDATA_WIDTH                                        (128                    ),
        .WADDR_WIDTH                                        (11                     ),
        .RDATA_WIDTH                                        (128                    ),
        .RADDR_WIDTH                                        (11                     ),
        .READ_LATENCY                                       (3                      ),
        .FIFO_DEPTH                                         (16                     ),
        .FIFO_WIDTH                                         (1                      ),
        .LOOP_WIDTH                                         (12                     ),
        .INFO_WIDTH                                         (1                      ),
        .RAM_TYPE                                           (1                      ) 
    )ant_data_buffer(
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (reset                  ),
        .i_iq_addr                                          (unpack_iq_addr[gi]     ),
        .i_iq_data                                          (unpack_iq_data[gi]     ),
        .i_iq_vld                                           (unpack_iq_vld [gi]     ),
        .i_iq_last                                          (unpack_iq_last[gi]     ),
        .o_ant_even                                         (ant_even  [gi]         ),
        .o_ant_odd                                          (ant_odd   [gi]         ),
        .o_ant_addr                                         (ant_addr  [gi]         ),
        .o_tvalid                                           (ant_tvalid[gi]         ) 
    );

    assign ant_data_even[gi*4*32 +: 4*32] = ant_even[gi];
    assign ant_data_odd [gi*4*32 +: 4*32] = ant_odd [gi];

end
endgenerate



// DUT
mac_beams #(
    .BEAM                                               (numBeams               ),
    .ANT                                                (ANT                    ),
    .IW                                                 (IW                     ),
    .OW                                                 (OW                     ) 
) dut_mac_beams (
    .i_clk                                              (i_clk                  ),
    .i_ants_data_even                                   (ant_data_even          ),
    .i_ants_data_odd                                    (ant_data_odd           ),
    .i_rvalid                                           (ant_tvalid[0]          ),
    .i_code_word_even                                   (i_code_word_even       ),
    .i_code_word_odd                                    (i_code_word_odd        ),
    .o_sum_data_even                                    (                       ),
    .o_sum_data_odd                                     (                       ),
    .o_sum_data                                         (                       ),
    .o_tvalid                                           (mac_beams_tvalid       ) 
);

// Clock generation
initial begin
    i_clk = 0;
    forever #(`CLOCK_PERIOD/2) i_clk = ~i_clk;
end


initial begin
    fid_iq_data = $fopen(FILE_IQDATA,"r");
    if(fid_iq_data)
    $display("succeed open file %s",FILE_IQDATA);

    for(int i=0;i<numTDL;i++)begin
        $fscanf(fid_iq_data, "%d,%d,", data_i[i],data_q[i]);
    end
    $fclose(fid_iq_data);
end

// re_num 
always @(posedge i_clk) begin
    if(reset || tx_hfp)
        re_num <= 0;
    else if(re_num == numTDL-1)
        re_num <= 0;
    else 
        re_num <= re_num + 1;
    
end

always @(posedge i_clk) begin
    if(reset || tx_hfp)
        pkg_data <= 0;
    else
        pkg_data <= {data_i[re_num], data_q[re_num]};
end

// Reset generation
initial begin
    #(`CLOCK_PERIOD*10) reset = 1'b0;
    tx_hfp = 1'b1;
    #(`CLOCK_PERIOD) tx_hfp = 1'b0;
end


always @(posedge i_clk) begin
    if(reset)
        tx_vld <= 0;
    else if(tx_hfp)
        tx_vld <= 1;
end

assign tx_sop = (re_per_prb ==0 ) ? 1'b1 : 1'b0;
assign tx_eop = (re_per_prb ==11) ? 1'b1 : 1'b0;

// cpri sequence number 0-95
always @(posedge i_clk) begin
    if(reset || tx_hfp)
        tx_seq <= 0;
    else if(tx_seq==95)
        tx_seq <= 0;
    else
        tx_seq <= tx_seq + 1;
end

// re number per prb 0-11
always @(posedge i_clk) begin
    if(tx_hfp)
        re_per_prb <= 0;
    else if(re_per_prb==11)
        re_per_prb <= 0;
    else
        re_per_prb <= re_per_prb + 1;
end

// PRB number 0-131
always @(posedge i_clk) begin
    if(reset || tx_hfp)
        prb_num <= 0;
    else if(prb_num == numPRB-1 && re_per_prb==numRE-1)
        prb_num <= 0;
    else if(re_per_prb==numRE-1) 
        prb_num <= prb_num + 1;
end

// Symbol number 0-13
always @(posedge i_clk) begin
    if(reset || tx_hfp)
        sym_num <= 0;
    else if(sym_num == numSYM-1 && prb_num==numPRB-1) 
        sym_num <= 0;
    else if(prb_num==numPRB-1 && re_per_prb==numRE-1) 
        sym_num <= sym_num + 1;
end




always @(posedge i_clk) begin
    if(tx_hfp)
        rb_agc <= 0;
    else if(re_per_prb==11)begin
        rb_agc <= 0;
//        if(rb_agc==6)
//            rb_agc <= 0;
//        else
//            rb_agc <= rb_agc + 1;
    end
end


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




initial begin
    fid_beam_odd= $fopen(FILE_BEAM_ODD,"w");
    fid_beam_even= $fopen(FILE_BEAM_EVEN,"w");
    fid_beam_all = $fopen(FILE_BEAM_ALL,"w");
    if(fid_beam_odd)
        $display("succeed open file %s",FILE_BEAM_ODD);
    if(fid_beam_even)
        $display("succeed open file %s",FILE_BEAM_EVEN);
    if(fid_beam_all)
        $display("succeed open file %s",FILE_BEAM_ALL);

    #(`SIM_ENDS_TIME);
    $fclose(fid_beam_odd);
    $fclose(fid_beam_even);
    $fclose(fid_beam_all);
    $stop;
end

task write_data2file;
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

reg                                             ovalid                  ;
reg                                             ovalid_r                ;
wire                                            ovalid_pos              ;
wire                                            ovalid_neg              ;
wire                                            ovalid_edge             ;
reg            [   3: 0]                        sym_num_beams           ;

always @(posedge i_clk)begin
    ovalid <= #(`CLOCK_PERIOD*10) ant_tvalid[0];
end

always @(posedge i_clk)begin
    ovalid_r <= ovalid;
end

assign ovalid_pos = ovalid && (~ovalid_r);
assign ovalid_neg = ~ovalid && (ovalid_r);
assign ovalid_edge = ovalid_neg;

// Symbol number 0-13
always @(posedge i_clk) begin
    if(reset || tx_hfp)
        sym_num_beams <= 0;
    else if(sym_num_beams == 7 && ovalid_edge)
        sym_num_beams <= 0;
    else if(sym_num_beams == numSYM-1 && ovalid_edge) 
        sym_num_beams <= 0;
    else if( ovalid_edge) 
        sym_num_beams <= sym_num_beams + 1;
end

always @(posedge i_clk) begin
    if(sym_num_beams == 2 && ovalid_edge) 
        sym1_done <= 1;
end

always @(posedge i_clk) write_data2file(i_clk, ovalid, fid_beam_even, dut_mac_beams.even_sum_data);
always @(posedge i_clk) write_data2file(i_clk, ovalid, fid_beam_odd , dut_mac_beams.odd_sum_data );
always @(posedge i_clk) write_data2file(i_clk, ovalid, fid_beam_all , dut_mac_beams.ants_sum     );



endmodule