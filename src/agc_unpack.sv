//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/28 15:54:23
// Design Name: 
// Module Name: agc_unpack
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:     67 clock latency 
//                  Search the smallest data in the input data stream
//                  and output the difference between the smallest data and the input data
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module agc_unpack (
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [7:0][63: 0]                     i_cpri_data             ,
    input          [7:0][6: 0]                      i_cpri_addr             ,
    input          [   7: 0]                        i_cpri_last             ,
    input          [   7: 0]                        i_rvalid                ,
    input                                           i_rready                ,

    input          [7:0][63: 0]                     i_fft_agc               ,
    input          [   7: 0]                        i_symb_eop              ,


    output         [  15: 0]                        o_fft_agc_base          ,
    output         [7:0][63: 0]                     o_fft_agc_shift         ,

    output         [7:0][63: 0]                     o_tx_data               ,
    output         [7:0][6: 0]                      o_tx_addr               ,
    output         [   7: 0]                        o_tx_last               ,
    output         [   7: 0]                        o_tx_vld                ,
    output                                          o_tready                 
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
localparam DATA_DEPTH = 32;
genvar i;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
reg            [   4: 0]                        rvalid_buf            =0;
reg            [   4: 0]                        rx_eop_buf            =0;
reg            [31:0][7: 0]                     data_cmp_0            =0;
reg            [31:0][7: 0]                     data_cmp_1            =0;
reg            [   6: 0]                        data_cnt              =0;
reg            [   7: 0]                        temp_data_0           =8'h7F;
reg            [   7: 0]                        temp_data_1           =8'h7F;
reg            [7:0][31: 0]                     shift_num_0           =0;
reg            [7:0][31: 0]                     shift_num_1           =0;
reg            [DATA_DEPTH+2: 0]                rvld_buf              =0;

//--------------------------------------------------------------------------------------
// data buffer 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    rvalid_buf  <= {rvalid_buf[3:0], i_rvalid[0]};
    rx_eop_buf  <= {rx_eop_buf[3:0], i_symb_eop[0]};
end

assign rvalid = rvalid_buf[0];
assign rx_eop = rx_eop_buf[0];

always @ (posedge i_clk)begin
    for(int i=0;i<8;i++) begin
        for(int j=0;j<4;j++)begin
            data_cmp_0[i*4 + j] <= i_fft_agc[i][ 0+j*8 +: 8]; // even
            data_cmp_1[i*4 + j] <= i_fft_agc[i][32+j*8 +: 8]; // odd 
        end
    end
end

always @ (posedge i_clk)begin
    if(i_reset)
        data_cnt <= 7'd0;
    else if(rx_eop)
        data_cnt <= 7'd0;
    else if(data_cnt == DATA_DEPTH-1)
        data_cnt <=  DATA_DEPTH-1;
    else if(rvalid)
        data_cnt <= data_cnt + 'd1;
end

//--------------------------------------------------------------------------------------
// find min agc data 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(i_reset)
        temp_data_0 <= 8'h7F;
    else if(rx_eop)
        temp_data_0 <= 8'h7F;
    else if(rvalid && (signed'(data_cmp_0[data_cnt]) < signed'(temp_data_0)))
        temp_data_0 <= data_cmp_0[data_cnt];
end

//--------------------------------------------------------------------------------------
// find odd ants min agc data 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(i_reset)
        temp_data_1 <= 8'h7F;
    else if(rx_eop)
        temp_data_1 <= 8'h7F;
    else if(rvalid && (signed'(data_cmp_1[data_cnt]) < signed'(temp_data_1)))
        temp_data_1 <= data_cmp_1[data_cnt];
end

//--------------------------------------------------------------------------------------
// calculate the difference between the smallest data
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0;i<8;i++) begin
        for(int j=0;j<4;j++)begin
            shift_num_0[i][j*8 +: 8] <= signed'(data_cmp_0[i*4 + j]) - signed'(temp_data_0);
        end
    end
end

//--------------------------------------------------------------------------------------
// calculate the difference between the smallest data of odd ants
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    for(int i=0;i<8;i++) begin
        for(int j=0;j<4;j++)begin
            shift_num_1[i][j*8 +: 8] <= signed'(data_cmp_1[i*4 + j]) - signed'(temp_data_1);
        end
    end
end

reg                                             sft_num_vld           =0;
reg                                             sft_num_vld_d1        =0;
reg            [7:0][31: 0]                     shift_num0_d1         =0;
reg            [7:0][31: 0]                     shift_num1_d1         =0;
reg            [   7: 0]                        fft_agc0_d1           =0;
reg            [   7: 0]                        fft_agc1_d1           =0;
reg            [7:0][63: 0]                     shift_num_out         =0;
reg            [  15: 0]                        fft_agc_out           =0;


//--------------------------------------------------------------------------------------
// gnenerate valid and read enable signals
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(data_cnt == DATA_DEPTH-2)
        sft_num_vld <= 1'b1;
    else
        sft_num_vld <= 1'b0;

    sft_num_vld_d1 <= sft_num_vld;
    rvld_buf <= {rvld_buf[DATA_DEPTH+1:0], i_rvalid[0]};
end

assign rd_ren = rvld_buf[DATA_DEPTH];

//--------------------------------------------------------------------------------------
// store valid data
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(sft_num_vld_d1)begin
        shift_num0_d1 <= shift_num_0;
        fft_agc0_d1   <= temp_data_0;

        shift_num1_d1 <= shift_num_1;
        fft_agc1_d1   <= temp_data_1;
    end
end

//--------------------------------------------------------------------------------------
// output buffer to match delay
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    fft_agc_out   <= {fft_agc1_d1, fft_agc0_d1};
    for(int i=0;i<8;i++) begin
        shift_num_out[i] = {shift_num1_d1[i], shift_num0_d1[i]};
    end
end

//--------------------------------------------------------------------------------------
// store input data to match process delay
//--------------------------------------------------------------------------------------
wire           [7:0][71: 0]                     wr_data                 ;
wire           [7:0][71: 0]                     rd_data                 ;
wire                                            rd_vld                  ;
reg            [7:0][63: 0]                     data_out              =0;
reg            [7:0][6: 0]                      addr_out              =0;
reg            [   7: 0]                        last_out              =0;

generate for(i=0;i<8;i++) begin: gen_mem_wrdata
    assign wr_data[i] = {i_cpri_last[i], i_cpri_addr[i], i_cpri_data[i]};
end
endgenerate

mem_streams # (
    .CHANNELS                                           (8                      ),
    .WDATA_WIDTH                                        (72                     ),
    .WADDR_WIDTH                                        (7                      ),
    .RDATA_WIDTH                                        (72                     ),
    .RADDR_WIDTH                                        (7                      ),
    .READ_LATENCY                                       (3                      ),
    .RAM_TYPE                                           (1                      ) 
)mem_streams_0(
    .i_clk                                              (i_clk                  ),
    .i_reset                                            (i_reset                ),
    .i_rvalid                                           (i_rvalid[0]            ),
    .i_wr_wen                                           (i_rvalid[0]            ),
    .i_wr_data                                          (wr_data                ),
    .i_rd_ren                                           (rd_ren                 ),
    .o_rd_data                                          (rd_data                ),
    .o_rd_addr                                          (                       ),
    .o_tvalid                                           (rd_vld                 ) 
);


//--------------------------------------------------------------------------------------
// output 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    for(int i=0;i<8;i++) begin
        data_out[i] = rd_data[i][63:0];
        addr_out[i] = rd_data[i][70:64];
        last_out[i] = rd_data[i][71];
    end
end


assign o_fft_agc_base   = fft_agc_out;
assign o_fft_agc_shift  = shift_num_out;
assign o_tx_data        = data_out;
assign o_tx_addr        = addr_out;
assign o_tx_last        = last_out;
assign o_tx_vld         = {8{rvld_buf[DATA_DEPTH+2]}};



endmodule