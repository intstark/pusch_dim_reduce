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
`define SIM_BF_PRB



module mac_ants_tb;

    parameter FILE_ANT  = "./ant_data.txt" ;
    parameter FILE_CWD  = "./code_word.txt";
    parameter FILE_DES  = "./beam_data.txt";

    parameter numCarriers = 40*12;
    parameter numBeams = 16;

    // Parameters
    parameter ANT = 32;
    parameter IW = 32;
    parameter OW = 32;

    // Signals
    genvar gi,gj;
    integer srcfid, cwdfid, beamfid;

    reg                                               i_clk                    ;
    wire           [ANT*IW-1: 0]                      i_ants_data              ;
    wire           [ANT*IW-1: 0]                      i_code_word              ;
    reg                                               i_rvalid                 ;
    wire           [OW-1: 0]                          o_sum_data               ;
    reg            [  15: 0]                          re_num                 =0;
    reg            [numCarriers-1:0][ANT*2-1:0][15: 0]ants_data_pre          ='{default:0};
    wire           [numCarriers-1:0][ANT-1:0][31: 0]  ants_data_mem            ;
    wire           [numCarriers-1:0][ANT*IW-1: 0]     ants_data                ;
    reg            [numBeams-1:0][ANT*2-1:0][15: 0]   code_word_pre          ='{default:0};
    reg            [numBeams-1:0][ANT-1:0][31: 0]     code_word                ;
    reg                                               reset                  =1'b1;

    // Instantiate the DUT
    mac_ants #(
        .ANT                                                  (ANT                     ),
        .IW                                                   (IW                      ),
        .OW                                                   (OW                      ) 
    ) dut (
        .i_clk                                                (i_clk                   ),
        .i_ants_data                                          (i_ants_data             ),
        .i_rvalid                                             (i_rvalid                ),
        .i_code_word                                          (i_code_word             ),
        .o_sum_data                                           (o_sum_data              ) 
    );


`ifdef SIM_MAC_BEAMS
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
`endif


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
        srcfid = $fopen(FILE_ANT,"r");
        if(srcfid)
            $display("succeed open file %s",FILE_ANT);


        for(int i=0; i<numCarriers; i++)begin
            for(int j=0; j<ANT*2; j++)begin
                $fscanf(srcfid, "%d,", ants_data_pre[i][j]);
                $display("ant_data_pre[i][j] = %d,", ants_data_pre[i][j]);
            end
        end
        $fclose(srcfid);
    end


    initial begin
        cwdfid = $fopen(FILE_CWD,"r");
        if(cwdfid)
            $display("succeed open file %s",FILE_CWD);


        for(int i=0; i<numBeams; i++)begin
            for(int j=0; j<ANT*2; j++)begin
                $fscanf(srcfid, "%d,", code_word_pre[i][j]);
                $display("code_word_pre[i][j] = %d,", code_word_pre[i][j]);
            end
        end
        $fclose(srcfid);
    end


    generate 
    for(gi=0; gi<numCarriers; gi++)begin:repack_ants_data
        for(gj=0; gj<ANT; gj++)begin:repack_ant_data
            assign ants_data_mem[gi][gj] = {ants_data_pre[gi][gj],ants_data_pre[gi][gj+ANT]};
            assign ants_data[gi][IW*gj +: IW] = ants_data_mem[gi][gj];
        end
    end
    endgenerate 

    generate 
    for( gi=0; gi<numBeams; gi++)begin:repack_code_word
        for(gj=0; gj<ANT; gj++)begin
            assign code_word[gi][gj] = {code_word_pre[gi][gj],code_word_pre[gi][gj+ANT]};
            assign i_code_word[IW*gj+:IW] = code_word[0][gj];
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

    assign i_ants_data = ants_data[re_num];


    initial begin
        beamfid = $fopen(FILE_DES,"w");
        if(beamfid )
            $display("succeed open file %s",FILE_DES);

        #5000;
        $fclose(beamfid);
        $stop;
    end

    always @(posedge i_clk)begin
        if(!reset)
            $fwrite(beamfid, "%d,%d\n", dut.add4_re[0],dut.add4_im[0]);
    end


endmodule