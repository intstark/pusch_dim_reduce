`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-04-06
//File name       :  decompress_bit.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------
module decompress_bit # (

    parameter integer SHIFT_WIDTH           = 4            ,
    parameter integer DATA_WIDTH            = 7            ,
    parameter integer DECM_WIDTH            = 16           
)(
    input  wire                             clk              ,
    input  wire  [SHIFT_WIDTH-1:0]          i_cpmr_agc       ,
    input  wire  [DATA_WIDTH-1:0]           i_cpmr_din       ,
    output reg   [DECM_WIDTH-1:0]           o_cpmr_dout      
);                                        
  
 reg [DATA_WIDTH-1:0]   cpmr_din_d1    ; 
 reg [SHIFT_WIDTH-1:0]  cpmr_agc_d1    ;  
 reg [DECM_WIDTH-1:0]   decmpr_data    ; 

  always @ (posedge clk)
    begin
        cpmr_agc_d1 <= i_cpmr_agc ;
        cpmr_din_d1 <= i_cpmr_din ;
    end

  always @ (posedge clk)
    begin
        case (cpmr_agc_d1) 
            4'd0 :   decmpr_data <= {cpmr_din_d1, {9{1'b0}}}   ;
            4'd1 :   decmpr_data <= {{1{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {8{1'b0}}}   ;
            4'd2 :   decmpr_data <= {{2{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {7{1'b0}}}   ;
            4'd3 :   decmpr_data <= {{3{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {6{1'b0}}}   ;
            4'd4 :   decmpr_data <= {{4{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {5{1'b0}}}   ;
            4'd5 :   decmpr_data <= {{5{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {4{1'b0}}}   ;
            4'd6 :   decmpr_data <= {{6{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {3{1'b0}}}   ;
            4'd7 :   decmpr_data <= {{7{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {2{1'b0}}}   ;
            4'd8 :   decmpr_data <= {{8{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1, {1{1'b0}}}   ;
            default: decmpr_data <= {{9{cpmr_din_d1[DATA_WIDTH-1]}}, cpmr_din_d1}   ;
        endcase
    
    end
    
   always @ (posedge clk)    
     o_cpmr_dout <= decmpr_data ;

endmodule