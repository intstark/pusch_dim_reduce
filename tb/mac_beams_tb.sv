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



module mac_beams_tb;

    parameter FILE_ANT_ODD  = "./ant_data_odd.txt" ;
    parameter FILE_ANT_EVEN = "./ant_data_even.txt";
    parameter FILE_CWD_ODD  = "./code_word_odd.txt";
    parameter FILE_CWD_EVEN = "./code_word_even.txt";
    parameter FILE_BEAM_ODD = "./beam_data_odd.txt";
    parameter FILE_BEAM_EVEN= "./beam_data_even.txt";
    parameter FILE_BEAM_ALL = "./beam_data.txt";

    parameter numCarriers = 40*12;
    parameter numBeams = 16;

    // Parameters
    parameter ANT = 32;
    parameter IW = 32;
    parameter OW = 48;

    // Signals
    genvar gi,gj;
    integer fid_ant_odd, fid_ant_even, fid_cwd_odd, fid_cwd_even, fid_beam_odd, fid_beam_even, fid_beam_all;

    reg                                               i_clk                    ;
    wire           [ANT*IW-1: 0]                      i_ants_data_odd          ;
    wire           [ANT*IW-1: 0]                      i_ants_data_even         ;
    wire           [numBeams-1:0][ANT*IW-1: 0]        i_code_word_odd          ;
    wire           [numBeams-1:0][ANT*IW-1: 0]        i_code_word_even         ;
    reg                                               i_rvalid                 ;
    wire           [OW-1: 0]                          o_sum_data               ;
    reg            [  15: 0]                          re_num                 =0;
    reg            [numCarriers-1:0][ANT*2-1:0][15: 0]ants_odd_pre           ='{default:0};
    reg            [numCarriers-1:0][ANT*2-1:0][15: 0]ants_even_pre          ='{default:0};
    wire           [numCarriers-1:0][ANT-1:0][31: 0]  ants_odd_mem             ;
    wire           [numCarriers-1:0][ANT-1:0][31: 0]  ants_even_mem            ;
    wire           [numCarriers-1:0][ANT*IW-1: 0]     ants_data_odd            ;
    wire           [numCarriers-1:0][ANT*IW-1: 0]     ants_data_even           ;
    reg            [numBeams-1:0][ANT*2-1:0][15: 0]   code_word_odd_pre      ='{default:0};
    reg            [numBeams-1:0][ANT*2-1:0][15: 0]   code_word_even_pre     ='{default:0};
    reg            [numBeams-1:0][ANT-1:0][31: 0]     code_word_odd            ;
    reg            [numBeams-1:0][ANT-1:0][31: 0]     code_word_even           ;
    reg                                               reset                  =1'b1;

    // DUT
    mac_beams #(
        .BEAM                                                 (numBeams                ),
        .ANT                                                  (ANT                     ),
        .IW                                                   (IW                      ),
        .OW                                                   (OW                      ) 
    ) dut_mac_beams (
        .i_clk                                                (i_clk                   ),
        .i_ants_data_even                                     (i_ants_data_even        ),
        .i_ants_data_odd                                      (i_ants_data_odd         ),
        .i_rvalid                                             (i_rvalid                ),
        .i_code_word_even                                     (i_code_word_even        ),
        .i_code_word_odd                                      (i_code_word_odd         ),
        .o_sum_data                                           () 
    );


    // Clock generation
    initial begin
        i_clk = 0;
        forever #(`CLOCK_PERIOD/2) i_clk = ~i_clk;
    end


    // Reset generation
    initial begin
        // Initialize inputs
        i_rvalid = 0;
        #(`CLOCK_PERIOD*10);
        reset = 1'b0;
    end


    initial begin
        fid_ant_odd = $fopen(FILE_ANT_ODD,"r");
        if(fid_ant_odd)
            $display("succeed open file %s",FILE_ANT_ODD);


        for(int i=0; i<numCarriers; i++)begin
            for(int j=0; j<ANT*2; j++)begin
                $fscanf(fid_ant_odd, "%d,", ants_odd_pre[i][j]);
                $display("ant_odd_pre[i][j] = %d,", ants_odd_pre[i][j]);
            end
        end
        $fclose(fid_ant_odd);
    end

    initial begin
        fid_ant_even= $fopen(FILE_ANT_EVEN,"r");
        if(fid_ant_even)
            $display("succeed open file %s",FILE_ANT_EVEN);


        for(int i=0; i<numCarriers; i++)begin
            for(int j=0; j<ANT*2; j++)begin
                $fscanf(fid_ant_even, "%d,", ants_even_pre[i][j]);
                $display("ant_even_pre[i][j] = %d,", ants_even_pre[i][j]);
            end
        end
        $fclose(fid_ant_even);
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
    for(gi=0; gi<numCarriers; gi++)begin:repack_ants_odd_data
        for(gj=0; gj<ANT; gj++)begin
            assign ants_odd_mem[gi][gj] = {ants_odd_pre[gi][gj],ants_odd_pre[gi][gj+ANT]};
            assign ants_data_odd[gi][IW*gj +: IW] = ants_odd_mem[gi][gj];
        end
    end
    endgenerate 

    generate 
    for(gi=0; gi<numCarriers; gi++)begin:repack_ants_even_data
        for(gj=0; gj<ANT; gj++)begin
            assign ants_even_mem[gi][gj] = {ants_even_pre[gi][gj],ants_even_pre[gi][gj+ANT]};
            assign ants_data_even[gi][IW*gj +: IW] = ants_even_mem[gi][gj];
        end
    end
    endgenerate 

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

    always @ (posedge i_clk)begin
        if(reset)
            re_num = 'd0;
        else if(re_num >= numCarriers-1)
            re_num = 'd0;
        else
            re_num <= re_num + 'd1;        
    end

    assign i_ants_data_odd  = ants_data_odd [re_num];
    assign i_ants_data_even = ants_data_even[re_num];


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

    always @(posedge i_clk)begin
        if(!reset)
            $fwrite(fid_beam_odd, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
                dut_mac_beams.odd_sum_data[ 0][95:48], dut_mac_beams.odd_sum_data[ 0][47:0],
                dut_mac_beams.odd_sum_data[ 1][95:48], dut_mac_beams.odd_sum_data[ 1][47:0],
                dut_mac_beams.odd_sum_data[ 2][95:48], dut_mac_beams.odd_sum_data[ 2][47:0],
                dut_mac_beams.odd_sum_data[ 3][95:48], dut_mac_beams.odd_sum_data[ 3][47:0],
                dut_mac_beams.odd_sum_data[ 4][95:48], dut_mac_beams.odd_sum_data[ 4][47:0],
                dut_mac_beams.odd_sum_data[ 5][95:48], dut_mac_beams.odd_sum_data[ 5][47:0],
                dut_mac_beams.odd_sum_data[ 6][95:48], dut_mac_beams.odd_sum_data[ 6][47:0],
                dut_mac_beams.odd_sum_data[ 7][95:48], dut_mac_beams.odd_sum_data[ 7][47:0],
                dut_mac_beams.odd_sum_data[ 8][95:48], dut_mac_beams.odd_sum_data[ 8][47:0],
                dut_mac_beams.odd_sum_data[ 9][95:48], dut_mac_beams.odd_sum_data[ 9][47:0],
                dut_mac_beams.odd_sum_data[10][95:48], dut_mac_beams.odd_sum_data[10][47:0],
                dut_mac_beams.odd_sum_data[11][95:48], dut_mac_beams.odd_sum_data[11][47:0],
                dut_mac_beams.odd_sum_data[12][95:48], dut_mac_beams.odd_sum_data[12][47:0],
                dut_mac_beams.odd_sum_data[13][95:48], dut_mac_beams.odd_sum_data[13][47:0],
                dut_mac_beams.odd_sum_data[14][95:48], dut_mac_beams.odd_sum_data[14][47:0],
                dut_mac_beams.odd_sum_data[15][95:48], dut_mac_beams.odd_sum_data[15][47:0]
            );
    end

    always @(posedge i_clk)begin
        if(!reset)
            $fwrite(fid_beam_even, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
                dut_mac_beams.even_sum_data[ 0][95:48], dut_mac_beams.even_sum_data[ 0][47:0],
                dut_mac_beams.even_sum_data[ 1][95:48], dut_mac_beams.even_sum_data[ 1][47:0],
                dut_mac_beams.even_sum_data[ 2][95:48], dut_mac_beams.even_sum_data[ 2][47:0],
                dut_mac_beams.even_sum_data[ 3][95:48], dut_mac_beams.even_sum_data[ 3][47:0],
                dut_mac_beams.even_sum_data[ 4][95:48], dut_mac_beams.even_sum_data[ 4][47:0],
                dut_mac_beams.even_sum_data[ 5][95:48], dut_mac_beams.even_sum_data[ 5][47:0],
                dut_mac_beams.even_sum_data[ 6][95:48], dut_mac_beams.even_sum_data[ 6][47:0],
                dut_mac_beams.even_sum_data[ 7][95:48], dut_mac_beams.even_sum_data[ 7][47:0],
                dut_mac_beams.even_sum_data[ 8][95:48], dut_mac_beams.even_sum_data[ 8][47:0],
                dut_mac_beams.even_sum_data[ 9][95:48], dut_mac_beams.even_sum_data[ 9][47:0],
                dut_mac_beams.even_sum_data[10][95:48], dut_mac_beams.even_sum_data[10][47:0],
                dut_mac_beams.even_sum_data[11][95:48], dut_mac_beams.even_sum_data[11][47:0],
                dut_mac_beams.even_sum_data[12][95:48], dut_mac_beams.even_sum_data[12][47:0],
                dut_mac_beams.even_sum_data[13][95:48], dut_mac_beams.even_sum_data[13][47:0],
                dut_mac_beams.even_sum_data[14][95:48], dut_mac_beams.even_sum_data[14][47:0],
                dut_mac_beams.even_sum_data[15][95:48], dut_mac_beams.even_sum_data[15][47:0]
            );
    end

    always @(posedge i_clk)begin
        if(!reset)
            $fwrite(fid_beam_all, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", 
                dut_mac_beams.ants_sum[ 0][95:48], dut_mac_beams.ants_sum[ 0][47:0],
                dut_mac_beams.ants_sum[ 1][95:48], dut_mac_beams.ants_sum[ 1][47:0],
                dut_mac_beams.ants_sum[ 2][95:48], dut_mac_beams.ants_sum[ 2][47:0],
                dut_mac_beams.ants_sum[ 3][95:48], dut_mac_beams.ants_sum[ 3][47:0],
                dut_mac_beams.ants_sum[ 4][95:48], dut_mac_beams.ants_sum[ 4][47:0],
                dut_mac_beams.ants_sum[ 5][95:48], dut_mac_beams.ants_sum[ 5][47:0],
                dut_mac_beams.ants_sum[ 6][95:48], dut_mac_beams.ants_sum[ 6][47:0],
                dut_mac_beams.ants_sum[ 7][95:48], dut_mac_beams.ants_sum[ 7][47:0],
                dut_mac_beams.ants_sum[ 8][95:48], dut_mac_beams.ants_sum[ 8][47:0],
                dut_mac_beams.ants_sum[ 9][95:48], dut_mac_beams.ants_sum[ 9][47:0],
                dut_mac_beams.ants_sum[10][95:48], dut_mac_beams.ants_sum[10][47:0],
                dut_mac_beams.ants_sum[11][95:48], dut_mac_beams.ants_sum[11][47:0],
                dut_mac_beams.ants_sum[12][95:48], dut_mac_beams.ants_sum[12][47:0],
                dut_mac_beams.ants_sum[13][95:48], dut_mac_beams.ants_sum[13][47:0],
                dut_mac_beams.ants_sum[14][95:48], dut_mac_beams.ants_sum[14][47:0],
                dut_mac_beams.ants_sum[15][95:48], dut_mac_beams.ants_sum[15][47:0]
            );
    end


endmodule