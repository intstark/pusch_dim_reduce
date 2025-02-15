//-------------------------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-10-17
//File name       :  compress_shift.sv
//--------------------------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//--------------------------------------------------------------------------------------------

module compress_shift
#(
	parameter integer IW        = 40,
	parameter integer OW        = 16,
    parameter integer DLY_CYCLE = 1584
)
(
    input  wire                                     clk                     ,
    input  wire                                     rst                     ,
    input  wire                                     i_sel                   ,
    input  wire                                     i_sop                   ,
    input  wire                                     i_eop                   ,
    input  wire                                     i_vld                   ,
    input  wire    [IW-1: 0]                        i_din_re                ,
    input  wire    [IW-1: 0]                        i_din_im                ,
    input  wire    [   5: 0]                        i_shift_num             ,


    output reg     [OW-1: 0]                        o_dout_re               ,
    output reg     [OW-1: 0]                        o_dout_im                
);

//--------------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------------
genvar gb;

reg            [DLY_CYCLE-1: 0]                 rx_vld_dly            =0;
reg                                             i_eop_d1              =0;
reg            [  11: 0]                        wr_addr               =0;
reg            [  11: 0]                        rd_addr               =0;
wire           [2*IW-1: 0]                      data_dly                ;
reg            [IW-1: 0]                        data_shift_i          =0;
reg            [IW-1: 0]                        data_shift_q          =0;
reg            [IW-1: 0]                        rounding_i            =0;
reg            [IW-1: 0]                        rounding_q            =0;
reg            [IW-1: 0]                        data_shift_i_dly      =0;
reg            [IW-1: 0]                        data_shift_q_dly      =0;
reg            [IW-1: 0]                        result_i0             =0;
reg            [IW-1: 0]                        result_q0             =0;



always @ (posedge clk)
begin
	if(rst)
		wr_addr <= 'd0;
    else if(i_eop)
        wr_addr <= 'd0;
	else if(i_vld)
		wr_addr <= wr_addr + 'd1;
	else
        wr_addr <= 'd0;
//        wr_addr <= wr_addr;
end


always @ (posedge clk)
    rx_vld_dly <= {rx_vld_dly[DLY_CYCLE-2:0],i_vld};  


always @ (posedge clk)
begin
	if(rst)
        rd_addr <= 'd0;
    else if(i_eop)
        rd_addr <= 'd0;
    else if (rx_vld_dly[DLY_CYCLE-1])
        rd_addr <= rd_addr + 'd1;       
    else
        rd_addr <= 'd0;
//        rd_addr <= rd_addr;
end

always@(posedge clk)
begin
    data_shift_i <= data_dly[2*IW-1:IW] << i_shift_num;
    data_shift_q <= data_dly[1*IW-1: 0] << i_shift_num;
end

always@(posedge clk)
begin
    if(data_shift_i[IW-1] == 1'b0 && data_shift_i[IW-OW-1])begin // pose
        if(data_shift_i[IW-2:IW-OW]=={(OW-1){1'b1}}) // pos max
            rounding_i <= 40'h00_0000_0000;
        else
            rounding_i <= 40'h00_0100_0000;
    end else if(data_shift_i[IW-1] == 1'b1 && data_shift_i[IW-OW-1] && (|data_shift_i[IW-OW-2:0]) ) // neg
        rounding_i <= 40'h00_0100_0000;
    else
        rounding_i <= 40'h00_0000_0000;
end

always@(posedge clk)
begin          
    if(data_shift_q[IW-1] == 1'b0 && data_shift_q[IW-OW-1])begin // pose
        if(data_shift_q[IW-2:IW-OW]=={(OW-1){1'b1}}) // pos max
            rounding_q <= 40'h00_0000_0000;
        else
            rounding_q <= 40'h00_0100_0000;
    end else if(data_shift_q[IW-1] == 1'b1 && data_shift_q[IW-OW-1] && (|data_shift_q[IW-OW-2:0]) ) // neg
        rounding_q <= 40'h00_0100_0000;
    else
        rounding_q <= 40'h00_0000_0000;
end
    
always@(posedge clk)
begin
    data_shift_i_dly <= data_shift_i;
    data_shift_q_dly <= data_shift_q;
end 
    
always@(posedge clk)
begin
    result_i0 <= data_shift_i_dly + rounding_i;
    result_q0 <= data_shift_q_dly + rounding_q;
end
   
always @ (posedge clk)begin
    o_dout_re <= {result_i0[IW-1:(IW-OW)]};   
    o_dout_im <= {result_q0[IW-1:(IW-OW)]};   
end


//--------------------------------------------------------------------------------------------
// intel:dram/fifo
//--------------------------------------------------------------------------------------------
Simple_Dual_Port_BRAM_XPM_intel
#(
    .WDATA_WIDTH                                        (IW*2                   ),
    .NUMWORDS_A                                         (DLY_CYCLE*2            ),
    .RDATA_WIDTH                                        (IW*2                   ),
    .NUMWORDS_B                                         (DLY_CYCLE*2            ),
    .INI_FILE                                           (                       ) 
)
u_bram_bit_32w_128d
(
    .clock                                              (clk                    ),
    .wren                                               (i_vld                  ),
    .wraddress                                          (wr_addr                ),
    .data                                               ({i_din_re,i_din_im}    ),
    .rdaddress                                          (rd_addr                ),
    .q                                                  (data_dly               ) 
);




endmodule
