//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/28 15:54:23
// Design Name: 
// Module Name: beam_sort
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//                  Smaller data got the bigger score
//                  IF two data are equal, the one with smaller index got the smaller score 
//                  THE smaller score got the higher priority
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module beam_sort # (
    parameter IW     = 32,
    parameter COL    = 64
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [COL-1:0][IW-1: 0]               i_data                  ,
    input                                           i_rready                ,
    input                                           i_rvalid                ,


    output         [COL-1:0][IW-1: 0]               o_data                  ,
    output         [COL-1:0][7: 0]                  o_score                 ,
    output         [15:0][7: 0]                     o_beam_index            ,
    output                                          o_tvalid                ,
    output                                          o_tready                 
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
 genvar idx;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
wire           [COL-1:0][IW-1: 0]               data                    ;
wire           [COL-1:0][7: 0]                  score                   ;
wire           [COL-1: 0]                       tvalid                  ;
wire           [COL-1: 0]                       tready                  ;
reg            [COL-1:0][IW-1: 0]               sort_data             ='{default:0};
reg            [COL-1:0][7: 0]                  sort_addr             ='{default:0};



//--------------------------------------------------------------------------------------
// compare data and generate smaller_score
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



//--------------------------------------------------------------------------------------
// output 
//--------------------------------------------------------------------------------------
assign o_data = sort_data;
assign o_score = score;
assign o_beam_index = sort_addr[15:0];


endmodule