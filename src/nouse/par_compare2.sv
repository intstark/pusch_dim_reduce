//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/28 15:54:23
// Design Name: 
// Module Name: par_compare
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

module par_compare # (
    parameter IW     = 32,
    parameter COL    = 16
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [IW-1: 0]                        i_data[COL-1:0]         ,
    input          [   7: 0]                        i_index                 ,
    input                                           i_rready                ,
    input                                           i_rvalid                ,


    output         [IW-1: 0]                        o_data[COL-1:0]         ,
    output         [7: 0]                           o_score                 ,
    output                                          o_tvalid                ,
    output                                          o_tready                 
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
 genvar gi;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
reg            [IW-1: 0]               data_buf     [COL-1:0]         ='{default:0};
reg            [IW-1: 0]               comp_data    [COL-1:0]         ='{default:0};
reg            [IW-1: 0]               datain                         =0;
reg            [   7: 0]               smaller_score[COL-1:0]         ='{default:0};
reg            [   7: 0]               idx_buf                        =0;
reg            [   7: 0]               idx                            =0;
reg            [   7: 0]               score_sum_0	 [COL/4-1:0]      ='{default:0};
reg            [   7: 0]               score_sum_all                  =0;
reg            [   7: 0]               tvalid_buf                     =0;

//--------------------------------------------------------------------------------------
// data buffer 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    idx <= i_index;
    for(int i=0;i<COL;i=i+1)begin
        data_buf[i] <= i_data[i];
    end
end

always @ (posedge i_clk)begin
    datain <= data_buf[idx];
    for(int i=0;i<COL;i=i+1)begin
        comp_data[i] <= data_buf[i];
    end
end


//--------------------------------------------------------------------------------------
// compare data and generate smaller_score
//--------------------------------------------------------------------------------------
generate
    for(gi=0;gi<COL;gi=gi+1) begin : data_compare
        always @ (posedge i_clk)begin
            if(datain < comp_data[gi])
                smaller_score[gi] <= 1;
            else if(datain == comp_data[gi])
                if(unsigned'(idx) > unsigned'(gi))
                    smaller_score[gi] <= 1;
                else
                    smaller_score[gi] <= 0;
            else
                smaller_score[gi] <= 0;
        end
    end
endgenerate


//--------------------------------------------------------------------------------------
// calculate socre pipe line 0
//--------------------------------------------------------------------------------------
generate
    for(gi=0;gi<COL/4;gi=gi+1) begin : score_sum_p0
        always @ (posedge i_clk)begin
            score_sum_0[gi] <= smaller_score[gi*4+0] + smaller_score[gi*4+1] + smaller_score[gi*4+2] + smaller_score[gi*4+3];
        end
    end
endgenerate

//--------------------------------------------------------------------------------------
// calculate socre pipe line 0
//--------------------------------------------------------------------------------------
generate if(COL == 64)begin
    reg [COL/16-1:0][7: 0] score_sum_1 ='{default:0};

    for(gi=0;gi<COL/16;gi=gi+1) begin : score_sum_p0
        always @ (posedge i_clk)begin
            score_sum_1[gi] <= score_sum_0[gi*4+0] + score_sum_0[gi*4+1] + score_sum_0[gi*4+2] + score_sum_0[gi*4+3];
        end
    end

    always @ (posedge i_clk)begin
        score_sum_all <= score_sum_1[0] + score_sum_1[1] + score_sum_1[2] + score_sum_1[3];
    end

end else if(COL == 16)begin
    always @ (posedge i_clk)begin
        score_sum_all <= score_sum_0[0] + score_sum_0[1] + score_sum_0[2] + score_sum_0[3];
    end
end

endgenerate


//--------------------------------------------------------------------------------------
// output 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    tvalid_buf[7:0] <= {tvalid_buf[6:0],i_rvalid};
end


assign o_score = score_sum_all;
assign o_tvalid= tvalid_buf[5];


endmodule