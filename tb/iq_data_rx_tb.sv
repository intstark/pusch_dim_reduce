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





module iq_data_rx_tb;

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


    assign rx_data = tx_data;
    assign rx_mask = tx_mask;
    assign rx_crtl = tx_crtl;
    assign rx_seq  = tx_seq ;


    // Instantiate the Unit Under Test (UUT)
    iq_data_rx #(
        .DW                                                 (DW                     ),
        .ANT                                                (ANT                    ),
        .numRE                                              (numRE                  ) 
    ) uut (
        .i_clk                                              (i_clk                  ),
        .i_cpri_rx_data                                     (rx_data                ),
        .i_cpri_rx_seq                                      (rx_seq                 ),
        .i_cpri_rx_mask                                     (rx_mask                ),
        .i_cpri_rx_crtl                                     (rx_crtl                ),
        .o_iq_data                                          (o_iq_data              ),
        .o_cm_data                                          (o_cm_data              ) 
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

    wire           [numPRB*12-1:0][13: 0]           data_iq_14bit           ;
    wire           [numPRB*12*14-1: 0]              data_iq_block           ;
    reg            [numPRB*12*14-1: 0]              data_iq_sft             ;

    generate
        for(gi=0;gi<numPRB*12;gi++) begin
            assign data_iq_14bit[gi] = {data_i[gi],data_q[gi]};
        end
    endgenerate

    generate
        for(gi=0;gi<numPRB*12/8;gi=gi+1) begin
            for(gj=0;gj<8;gj=gj+1) begin
                assign data_iq_block[gi*8*14+gj*14 +: 14] = data_iq_14bit[gi*8+gj];
            end 
        end
    endgenerate



    // Reset generation
    initial begin
        #(`CLOCK_PERIOD*10) reset = 1'b0;
        @(posedge i_clk) tx_hfp = 1'b1;
        @(posedge i_clk) tx_hfp = 1'b0;
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
        if(reset || tx_hfp || tx_x==19)begin
            iq_data <= 64'd0;
            data_iq_sft <= data_iq_block;
        end else if(tx_seq==4)
            iq_data <= 64'h11114321_11114321;
        else if(tx_seq==5)
            iq_data <= 64'h11114321_11114321;
        else if(tx_seq>=6 && tx_seq<=26)begin
            iq_data <= {4{data_iq_sft[15:0]}};
            data_iq_sft <= data_iq_sft>>16;
        end else if(tx_seq>=27 && tx_seq<=47)begin
            iq_data <= 64'd0;
        end else begin
            iq_data <= {4{data_iq_sft[15:0]}};
            data_iq_sft <= data_iq_sft>>16;
        end
    end


    always @(posedge i_clk or posedge reset) begin
        if(reset || tx_hfp)
            tx_x <= 0;
        else if(tx_x==255)
            tx_x <= 0;
        else if(tx_seq==95)
            tx_x <= tx_x + 1;
    end

    assign tx_crtl = (tx_seq==0 || tx_seq==1) ? 8'hFF : 8'h00;


    assign iq_mask = {64{1'b1}};

    assign cm_data =  (tx_x==81 ) ? 64'h5100_0000_0000_0000 : 
                      (tx_x==144) ? 64'h9000_0000_0000_0000 : 
                      (tx_x==145) ? 64'h9100_0000_0000_0000 : 
                      (tx_x==208) ? 64'hD000_0000_0000_0000 : 
                      (tx_x==209) ? 64'hD100_0000_0000_0000 : 
                      64'd0;

    assign cm_mask  = (tx_x==81 ) ? {64{1'b1}} : 
                      (tx_x==144) ? {64{1'b1}} : 
                      (tx_x==145) ? {64{1'b1}} : 
                      (tx_x==208) ? {64{1'b1}} : 
                      (tx_x==209) ? {64{1'b1}} : 
                      {64{1'b0}};


    assign tx_data = (|tx_crtl) ? cm_data : iq_data;
    assign tx_mask = (|tx_crtl) ? cm_mask : iq_mask;




endmodule