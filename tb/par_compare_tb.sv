`timescale 1ns / 1ps

module par_compare_tb;

// Parameters
parameter IW  = 32;
parameter COL = 64;

genvar idx;
// Inputs
reg                                             i_clk                   ;
reg                                             i_reset                 ;
reg            [COL-1:0][IW-1: 0]               i_data                  ;
reg            [   7: 0]                        i_index                 ;
reg                                             i_rready                ;
wire                                            i_enable                ;
wire                                            i_rvalid                ;

// Outputs
wire           [COL-1:0][IW-1: 0]               data                    ;
wire           [COL-1:0][7: 0]                  score                   ;
wire           [COL-1: 0]                       tvalid                  ;
wire           [COL-1: 0]                       tready                  ;
reg            [COL-1:0][IW-1: 0]               sort_data             ='{default:0};
reg            [COL-1:0][7: 0]                  sort_addr             ='{default:0};



//--------------------------------------------------------------------------------------
//  dut
//--------------------------------------------------------------------------------------
generate for(idx=0; idx<COL; idx=idx+1) begin: par_compare_x16
    par_compare #(
        .IW                                                 (IW                     ),
        .COL                                                (COL                    ) 
    ) par_compare (
        .i_clk                                              (i_clk                  ),
        .i_reset                                            (i_reset                ),
        .i_data                                             (i_data                 ),
        .i_index                                            (idx                    ),
        .i_rready                                           (i_rready               ),
        .i_rvalid                                           (i_rvalid               ),
        .o_score                                            (score [idx]            ),
        .o_tvalid                                           (tvalid[idx]            ),
        .o_tready                                           (tready[idx]            ) 
    );
end
endgenerate

beam_sort # (
    .IW                                                 (32                     ),
    .COL                                                (64                     ) 
)beam_sort(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_data                                             (i_data                 ),
    .i_rready                                           (i_rready               ),
    .i_enable                                           (i_enable               ),
    .i_rvalid                                           (i_rvalid               ),
    .o_data                                             (                       ),
    .o_score                                            (                       ),
    .o_tvalid                                           (                       ),
    .o_tready                                           (                       ) 
);

beam_sort1 # (
    .IW                                                 (32                     ),
    .COL                                                (64                     ) 
)beam_sort1(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_data                                             (i_data                 ),
    .i_rready                                           (i_rready               ),
    .i_enable                                           (i_enable               ),
    .i_rvalid                                           (i_rvalid               ),
    .o_data                                             (                       ),
    .o_score                                            (                       ),
    .o_tvalid                                           (                       ),
    .o_tready                                           (                       ) 
);


//--------------------------------------------------------------------------------------
// sort the data by score, smallest score first
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0; i<COL; i=i+1)begin
        sort_data[score[i]] <= i_data[i];
    end
end	


//--------------------------------------------------------------------------------------
// store the index of the data by score 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0; i<COL; i=i+1)begin
        sort_addr[score[i]] <= 8'(i);
    end
end	

// Clock generation
always #5 i_clk = ~i_clk;

initial begin
    // Initialize Inputs
    i_clk = 0;
    i_reset = 1;
    i_data = 0;
    i_index = 0;
    i_rready = 0;

    // Wait for global reset to finish
    #15;
    i_reset = 0;

    // Test Case 1: Happy Path
    i_data = {  
                32'h00000011, 32'h00000012, 32'h00000003, 32'h00000004, 
                32'h00000015, 32'h00000016, 32'h00000007, 32'h00000008, 
                32'h00000019, 32'h0000001A, 32'h0000000B, 32'h0000000C, 
                32'h0000000D, 32'h0000001E, 32'h00000001, 32'h00000001,

                32'h00000011, 32'h00000012, 32'h00000003, 32'h00000004, 
                32'h00000015, 32'h00000016, 32'h00000007, 32'h00000008, 
                32'h00000019, 32'h0000001A, 32'h0000000B, 32'h0000000C, 
                32'h0000000D, 32'h0000001E, 32'h00000001, 32'h00000001,
                
                32'h00000011, 32'h00000012, 32'h00000003, 32'h00000004, 
                32'h00000015, 32'h00000016, 32'h00000007, 32'h00000008, 
                32'h00000019, 32'h0000001A, 32'h0000000B, 32'h0000000C, 
                32'h0000000D, 32'h0000001E, 32'h00000001, 32'h00000001,
                
                32'h00000011, 32'h00000012, 32'h00000003, 32'h00000004, 
                32'h00000015, 32'h00000016, 32'h00000007, 32'h00000008, 
                32'h00000019, 32'h0000001A, 32'h0000000B, 32'h0000000C, 
                32'h0000000D, 32'h0000001E, 32'h00000001, 32'h00000001
            };
    i_index = 8'd0;
    i_rready = 1;
end

reg [7:0] re_num =0;
reg [7:0] rbg_num =0;
reg data_tvld = 0;  
always @ (posedge i_clk)begin
    if(i_reset)
        data_tvld <= 0;
    else
        data_tvld <= 1;
end

always @ (posedge i_clk)begin
    if(i_reset)
        re_num <= 0;
    else if(re_num==191)
        re_num <= 0;
    else if(data_tvld)
        re_num <= re_num + 1;
end

assign i_rvalid = (data_tvld && re_num==0 && rbg_num<=8) ? 1'b1 : 1'b0;
assign i_enable = (data_tvld && re_num<=191 && rbg_num<=8) ? 1'b1 : 1'b0;

always @ (posedge i_clk)begin
    if(i_reset)
        rbg_num <= 0;
    else if(rbg_num==15 && i_rvalid)
        rbg_num <= 0;
    else if(i_rvalid)
        rbg_num <= rbg_num + 1;
end

endmodule