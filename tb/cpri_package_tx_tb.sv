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
`define SIM_ENDS_TIME 5000





module cpri_package_tx_tb;

    parameter FILE_IQDATA  = "./iq_data.txt" ;

    // Parameters
    parameter DW     = 8;
    parameter ANT    = 8;
    parameter numPRB = 132;
    parameter numRE  = 12;

    // Signals
    genvar gi,gj;
    integer fid_iq_data, fid_ant_even, fid_cwd_odd, fid_cwd_even, fid_beam_odd, fid_beam_even, fid_beam_all;

    // Inputs
    reg                                             i_clk                 =1'b0;
    reg                                             reset                 =1'b1;
    wire           [  63: 0]                        rx_data                 ;
    wire           [   6: 0]                        rx_seq                  ;
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

    reg            [numPRB*12-1:0][6: 0]            data_i                  ;
    reg            [numPRB*12-1:0][6: 0]            data_q                  ;

    reg            [   8: 0]                        prb_num               =0;
    reg            [   7: 0]                        re_per_prb            =0;
    reg            [   7: 0]                        re_num                =0;
    reg            [  13: 0]                        pkg_data              =0;

    reg                                             tx_vld                =0;
    reg                                             tx_sop                =0;
    reg                                             tx_eop                =0;

    reg            [   3: 0]                        rb_agc                =0;
    wire                                            m_cpri_wen              ;
    wire           [6:0]                            m_cpri_waddr            ;
    wire           [63:0]                           m_cpri_wdata            ;
    wire                                            m_cpri_wlast            ; 




    package_data            package_data
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
        .o_iq_tx_valid                                      (                       ),
        .o_iq_tx_data                                       (                       ) 
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

        for(int i=0;i<numPRB*12;i++)begin
            $fscanf(fid_iq_data, "%d,%d,", data_i[i],data_q[i]);
        end
        $fclose(fid_iq_data);
    end

    always @(posedge i_clk or posedge reset) begin
        if(reset || tx_hfp)begin
            re_num <= 0;
        end else begin
            re_num <= re_num + 1;
        end
    end

    always @(posedge i_clk or posedge reset) begin
        if(reset || tx_hfp)begin
            prb_num <= 0;
        end else if(re_per_prb==11) begin
            prb_num <= prb_num + 1;
        end
    end

    always @(posedge i_clk or posedge reset) begin
            pkg_data <= {data_i[re_num],data_q[re_num]};
    end
    

    // Reset generation
    initial begin
        #(`CLOCK_PERIOD*10) reset = 1'b0;
        @(posedge i_clk) tx_hfp = 1'b1;
        @(posedge i_clk) tx_hfp = 1'b0;
    end


    always @(posedge i_clk or posedge reset) begin
        if(reset)
            tx_vld <= 0;
        else if(tx_hfp)
            tx_vld <= 1;
    end
    
    always @(posedge i_clk or posedge reset) begin
        if(reset)
            tx_sop <= 0;
        else if(tx_hfp)
            tx_sop <= 1;
        else
            tx_sop <= 0;
    end 
    
    always @(posedge i_clk or posedge reset) begin
        if(reset)
            tx_eop <= 0;
        else if(tx_hfp)
            tx_eop <= 0;
        else if(tx_seq==94)
            tx_eop <= 1;
        else
            tx_eop <= 0;
    end  

    
    always @(posedge i_clk or posedge reset) begin
        if(reset || tx_hfp)
            tx_seq <= 0;
        else if(tx_seq==95)
            tx_seq <= 0;
        else
            tx_seq <= tx_seq + 1;
    end

    always @(posedge i_clk or posedge reset) begin
        if(tx_hfp)
            re_per_prb <= 0;
        else if(re_per_prb==11)
            re_per_prb <= 0;
        else
            re_per_prb <= re_per_prb + 1;
    end

    always @(posedge i_clk or posedge reset) begin
        if(tx_hfp)
            rb_agc <= 0;
        else if(re_per_prb==11)begin
            if(rb_agc==6)
                rb_agc <= 0;
            else
                rb_agc <= rb_agc + 1;
        end
    end



endmodule