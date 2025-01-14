`timescale 1ns/1ps


`timescale 1ns/1ps
`define CLOCK_PERIOD 10.0
`define SIM_ENDS_TIME 32000


module compress_40b16b_tb;

// Parameters
parameter integer Num = 16;
parameter string FILE_IQDATA = "ul_datain.txt";
parameter string FILE_CPRS_DATA = "compress_data.txt";


integer                                         fid_iq_data             ;
integer                                         fid_cprs_data           ;
wire           [15:0][39: 0]                    ant_data_i              ;
wire           [15:0][39: 0]                    ant_data_q              ;
reg            [  11: 0]                        ant_re_num            =0;

// Registers and wires
reg                                             clk                     ;
reg                                             rst                     ;
reg                                             i_sel                   ;
wire                                            i_sop                   ;
wire                                            i_eop                   ;
reg                                             i_vld                 =0;
wire           [  15:0][39:0]                   i_din_re                ;
wire           [  15:0][39:0]                   i_din_im                ;
reg            [   6: 0]                        i_slot_idx              ;
reg            [   3: 0]                        i_symb_idx              ;
reg            [   8: 0]                        i_prb_idx               ;
reg            [   3: 0]                        i_ch_type               ;
reg            [   7: 0]                        i_info                  ;

wire                                            o_sel                   ;
wire                                            o_sop                   ;
wire                                            o_eop                   ;
wire                                            o_vld                   ;
wire           [15:0][Num-1: 0]                 o_dout_re               ;
wire           [15:0][Num-1: 0]                 o_dout_im               ;
wire           [   4: 0]                        o_shift                 ;
wire           [   6: 0]                        o_slot_idx              ;
wire           [   3: 0]                        o_symb_idx              ;
wire           [   8: 0]                        o_prb_idx               ;
wire           [   3: 0]                        o_type                  ;
wire           [   7: 0]                        o_info                  ;

// Instantiate the unit under test
compress_matrix                                         uut (
    .clk                                                (clk                    ),
    .rst                                                (rst                    ),
    .i_sel                                              (i_sel                  ),
    .i_sop                                              (i_sop                  ),
    .i_eop                                              (i_eop                  ),
    .i_vld                                              (i_vld                  ),
    .i_din_re                                           (i_din_re               ),
    .i_din_im                                           (i_din_im               ),
    .i_slot_idx                                         (i_slot_idx             ),
    .i_symb_idx                                         (i_symb_idx             ),
    .i_prb_idx                                          (i_prb_idx              ),
    .i_ch_type                                          (i_ch_type              ),
    .i_info                                             (i_info                 ),
    .o_sel                                              (o_sel                  ),
    .o_sop                                              (o_sop                  ),
    .o_eop                                              (o_eop                  ),
    .o_vld                                              (o_vld                  ),
    .o_dout_re                                          (o_dout_re              ),
    .o_dout_im                                          (o_dout_im              ), 
    .o_shift                                            (o_shift                ),
    .o_slot_idx                                         (o_slot_idx             ),
    .o_symb_idx                                         (o_symb_idx             ),
    .o_prb_idx                                          (o_prb_idx              ),
    .o_type                                             (o_type                 ),
    .o_info                                             (o_info                 ) 
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock
end

// Test procedure
initial begin
    // Initialize inputs
    rst = 1;
    i_sel = 0;
    i_slot_idx = 7'd0;
    i_symb_idx = 4'd0;
    i_prb_idx = 9'd0;
    i_ch_type = 4'd0;
    i_info = 8'd0;
    
    // Reset
    #10 rst = 0;
    
    // Happy path test
    // Valid input data
    i_sel = 1;
    i_slot_idx = 7'd5;
    i_symb_idx = 4'd3;
    i_prb_idx = 9'd9;
    i_ch_type = 4'd2;
    i_info = 8'd1;

end


reg [79:0] ant_data_mem0  [0:2047] = '{default:0};
reg [79:0] ant_data_mem1  [0:2047] = '{default:0};
reg [79:0] ant_data_mem2  [0:2047] = '{default:0};
reg [79:0] ant_data_mem3  [0:2047] = '{default:0};
reg [79:0] ant_data_mem4  [0:2047] = '{default:0};
reg [79:0] ant_data_mem5  [0:2047] = '{default:0};
reg [79:0] ant_data_mem6  [0:2047] = '{default:0};
reg [79:0] ant_data_mem7  [0:2047] = '{default:0};
reg [79:0] ant_data_mem8  [0:2047] = '{default:0};
reg [79:0] ant_data_mem9  [0:2047] = '{default:0};
reg [79:0] ant_data_mem10 [0:2047] = '{default:0};
reg [79:0] ant_data_mem11 [0:2047] = '{default:0};
reg [79:0] ant_data_mem12 [0:2047] = '{default:0};
reg [79:0] ant_data_mem13 [0:2047] = '{default:0};
reg [79:0] ant_data_mem14 [0:2047] = '{default:0};
reg [79:0] ant_data_mem15 [0:2047] = '{default:0};

//------------------------------------------------------------------------------------------
// Read data input
//------------------------------------------------------------------------------------------
initial begin
    $readmemh("ul_datain_0.txt" , ant_data_mem0);
    $readmemh("ul_datain_1.txt" , ant_data_mem1);
    $readmemh("ul_datain_2.txt" , ant_data_mem2);
    $readmemh("ul_datain_3.txt" , ant_data_mem3);
    $readmemh("ul_datain_4.txt" , ant_data_mem4);
    $readmemh("ul_datain_5.txt" , ant_data_mem5);
    $readmemh("ul_datain_6.txt" , ant_data_mem6);
    $readmemh("ul_datain_7.txt" , ant_data_mem7);
    $readmemh("ul_datain_8.txt" , ant_data_mem8);
    $readmemh("ul_datain_9.txt" , ant_data_mem9);
    $readmemh("ul_datain_10.txt", ant_data_mem10);
    $readmemh("ul_datain_11.txt", ant_data_mem11);
    $readmemh("ul_datain_12.txt", ant_data_mem12);
    $readmemh("ul_datain_13.txt", ant_data_mem13);
    $readmemh("ul_datain_14.txt", ant_data_mem14);
    $readmemh("ul_datain_15.txt", ant_data_mem15);
end



always @(posedge clk) begin
    if(rst==0)begin
        i_vld <= 1'b1;
        if(ant_re_num==1584)
            ant_re_num <= 1584;
        else if(i_vld)
            ant_re_num <= ant_re_num + 1;
    end
end
assign ant_data_i[ 0] = ant_data_mem0 [ant_re_num][79:40];
assign ant_data_i[ 1] = ant_data_mem1 [ant_re_num][79:40];
assign ant_data_i[ 2] = ant_data_mem2 [ant_re_num][79:40];
assign ant_data_i[ 3] = ant_data_mem3 [ant_re_num][79:40];
assign ant_data_i[ 4] = ant_data_mem4 [ant_re_num][79:40];
assign ant_data_i[ 5] = ant_data_mem5 [ant_re_num][79:40];
assign ant_data_i[ 6] = ant_data_mem6 [ant_re_num][79:40];
assign ant_data_i[ 7] = ant_data_mem7 [ant_re_num][79:40];
assign ant_data_i[ 8] = ant_data_mem8 [ant_re_num][79:40];
assign ant_data_i[ 9] = ant_data_mem9 [ant_re_num][79:40];
assign ant_data_i[10] = ant_data_mem10[ant_re_num][79:40];
assign ant_data_i[11] = ant_data_mem11[ant_re_num][79:40];
assign ant_data_i[12] = ant_data_mem12[ant_re_num][79:40];
assign ant_data_i[13] = ant_data_mem13[ant_re_num][79:40];
assign ant_data_i[14] = ant_data_mem14[ant_re_num][79:40];
assign ant_data_i[15] = ant_data_mem15[ant_re_num][79:40];

assign ant_data_q[ 0] = ant_data_mem0 [ant_re_num][39: 0];
assign ant_data_q[ 1] = ant_data_mem1 [ant_re_num][39: 0];
assign ant_data_q[ 2] = ant_data_mem2 [ant_re_num][39: 0];
assign ant_data_q[ 3] = ant_data_mem3 [ant_re_num][39: 0];
assign ant_data_q[ 4] = ant_data_mem4 [ant_re_num][39: 0];
assign ant_data_q[ 5] = ant_data_mem5 [ant_re_num][39: 0];
assign ant_data_q[ 6] = ant_data_mem6 [ant_re_num][39: 0];
assign ant_data_q[ 7] = ant_data_mem7 [ant_re_num][39: 0];
assign ant_data_q[ 8] = ant_data_mem8 [ant_re_num][39: 0];
assign ant_data_q[ 9] = ant_data_mem9 [ant_re_num][39: 0];
assign ant_data_q[10] = ant_data_mem10[ant_re_num][39: 0];
assign ant_data_q[11] = ant_data_mem11[ant_re_num][39: 0];
assign ant_data_q[12] = ant_data_mem12[ant_re_num][39: 0];
assign ant_data_q[13] = ant_data_mem13[ant_re_num][39: 0];
assign ant_data_q[14] = ant_data_mem14[ant_re_num][39: 0];
assign ant_data_q[15] = ant_data_mem15[ant_re_num][39: 0];

assign i_din_re = ant_data_i;
assign i_din_im = ant_data_q;
assign i_sop = (ant_re_num==0 && i_vld) ? 1'b1 : 1'b0;
assign i_eop = (ant_re_num==1583) ? 1'b1 : 1'b0;


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
always @(posedge clk) begin
    if(o_vld)
        $fwrite(fid_cprs_data, "%d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d, %d,%d,%d,%d\n", 
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
end



endmodule