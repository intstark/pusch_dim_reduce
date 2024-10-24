//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: cpri_rxdata_buffer
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
module cpri_rxdata_buffer#(
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  12   ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  12   ,
    parameter integer FIFO_DEPTH         =  8    ,
    parameter integer FIFO_WIDTH         =  1    ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  15   ,    
    parameter integer INFO_WIDTH         =  1    ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [WDATA_WIDTH-1: 0]               i_rx_data               ,
    input                                           i_rvalid                ,
    input                                           i_rready                ,
    input                                           i_sym1_done             ,

    output         [RDATA_WIDTH-1: 0]               o_tx_data               ,
    output         [   6: 0]                        o_tx_addr               ,
    output                                          o_tx_last               ,                 
    output                                          o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam [WADDR_WIDTH-1: 0] DATA_DEPTH = 1585*2-1;
localparam [6: 0]             CHIP_DW    = 95;

//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
reg                                             rd_rdy                  ;
reg                                             wr_wlast                ;
reg                                             wr_wen                =0;
wire                                            rd_ren                  ;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;
reg            [WDATA_WIDTH-1: 0]               wr_data               =0;
reg            [RADDR_WIDTH-1: 0]               rd_addr               =0;
wire           [RDATA_WIDTH-1: 0]               rd_data                 ;
wire                                            rd_en                   ;
reg            [   6: 0]                        seq_num               =0;
wire                                            rd_vld                  ;
reg                                             data_last             =0;
reg            [   2: 0]                        data_vld_buf          =0;

reg                                             rd_rlast              =0;
reg            [   2: 0]                        rd_rlast_buf          =0;
reg            [   2: 0]                        rd_en_buf             =0;
reg            [   7: 0]                        rd_sym_num            =0;
wire           [LOOP_WIDTH-WADDR_WIDTH: 0]      free_size               ;
reg                                             sym1_done             =0;
wire                                            raddr_least_2           ;
wire                                            raddr_almost_full       ;

//--------------------------------------------------------------------------------------
// Write logic
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(i_reset)
        wr_wen <= 1'b0;
    else if(i_rvalid)
        wr_wen <= 1'b1;
end

always @ (posedge i_clk)begin
    wr_data <= i_rx_data;
end


always @ (posedge i_clk)begin
    if(i_reset)
        wr_addr <= 'd0;
    else if(wr_addr==DATA_DEPTH)
        wr_addr <= 'd0;
    else if(wr_wen)
        wr_addr <= wr_addr + 'd1;    
end

always @ (posedge i_clk)begin
    if(i_reset)
        wr_wlast <= 1'b0;
    else if(wr_addr==DATA_DEPTH-1)
        wr_wlast <= 1'b1;
    else
        wr_wlast <= 1'b0;
end

assign wr_info = (wr_addr==1) ? 1'b1 : 1'b0;


//--------------------------------------------------------------------------------------
// Read logic
//--------------------------------------------------------------------------------------
assign rd_en  = i_rready & rd_vld;
assign raddr_full = (rd_addr == DATA_DEPTH) ? 1'b1 : 1'b0;
assign raddr_almost_full = (rd_addr == DATA_DEPTH-1) ? 1'b1 : 1'b0;
assign raddr_least_2 = (rd_addr == DATA_DEPTH-2) ? 1'b1 : 1'b0;

always @ (posedge i_clk)begin
    if(i_reset)
        rd_sym_num <= 8'd0;
    else if(i_rready && rd_rlast)
        rd_sym_num <= rd_sym_num + 8'd1;
end


always @ (posedge i_clk)begin
    if(i_reset)
        sym1_done <= 1'b0;
    else if(rd_sym_num==3 && raddr_least_2)
        sym1_done <= 1'b1;
end


always @ (posedge i_clk)begin
    if(i_reset)
        rd_addr<= 'd0;
    else if(rd_rlast)
        rd_addr <= 'd0;
    else if(rd_en)
        rd_addr <= rd_addr + 'd1;
end



always @ (posedge i_clk)begin
    if(i_reset)
        rd_rlast <= 1'b0;
    else if(i_rready && raddr_almost_full)
        rd_rlast <= 1'b1;
    else
        rd_rlast <= 1'b0;
end

always @ (posedge i_clk)begin
    rd_rlast_buf <= {rd_rlast_buf[1:0],rd_rlast};
    rd_en_buf <= {rd_en_buf[1:0],rd_en};
end

always @ (posedge i_clk)begin
    if(i_rready && sym1_done && raddr_almost_full)
        rd_rdy <= 1'b1;
    else
        rd_rdy <= 1'b0;
end

always @ (posedge i_clk)begin
    if(i_reset)
        seq_num <= 'd0;
    else if(~sym1_done && (rd_rlast_buf[2] || rd_rlast_buf[1]))
        seq_num <= 'd0;
    else if(seq_num==CHIP_DW)
        seq_num <= 'd0;
    else if(data_vld_buf[2] && rd_en_buf[2])
        seq_num <= seq_num + 'd1;
end

always @ (posedge i_clk)begin
    data_vld_buf <= {data_vld_buf[1:0],rd_vld};
end

always @ (posedge i_clk)begin
    if(i_reset)
        data_last <= 1'b0;
    else if(seq_num == CHIP_DW-1)
        data_last <= 1'b1;
    else
        data_last <= 1'b0;
end

//------------------------------------------------------------------------------------------
// RAM BLOCK FOR CPRI DATA FOR 7 SYMBOLS 
//------------------------------------------------------------------------------------------
loop_buffer_sync_intel #
(
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .WADDR_WIDTH                                        (WADDR_WIDTH            ),
    .RDATA_WIDTH                                        (RDATA_WIDTH            ),
    .RADDR_WIDTH                                        (RADDR_WIDTH            ),
    .READ_LATENCY                                       (READ_LATENCY           ),
    .FIFO_DEPTH                                         (FIFO_DEPTH             ),
    .FIFO_WIDTH                                         (FIFO_WIDTH             ),
    .LOOP_WIDTH                                         (LOOP_WIDTH             ),
    .INFO_WIDTH                                         (INFO_WIDTH             ),
    .RAM_TYPE                                           (RAM_TYPE               ) 
)u_loop_buffer_sync
(
    .syn_rst                                            (i_reset                ),
    .clk                                                (i_clk                  ),
    .wr_wen                                             (wr_wen                 ),
    .wr_addr                                            (wr_addr                ),
    .wr_data                                            (wr_data                ),
    .wr_wlast                                           (wr_wlast               ),
    .wr_info                                            (wr_info                ),
    .free_size                                          (free_size              ),
    .rd_addr                                            (rd_addr                ),
    .rd_data                                            (rd_data                ),
    .rd_vld                                             (rd_vld                 ),
    .rd_info                                            (rd_info                ),
    .rd_rdy                                             (rd_rdy                 ) 
);


//--------------------------------------------------------------------------------------
// Output 
//--------------------------------------------------------------------------------------
reg            [RDATA_WIDTH-1: 0]               rx_data_out           =0;
reg            [  10: 0]                        tx_addr_out           =0;
reg                                             tvalid_out            =0;
reg                                             txlast_out            =0;

always @ (posedge i_clk)begin
    rx_data_out <= rd_data[RDATA_WIDTH-1:0];
    tx_addr_out <= seq_num;
    tvalid_out  <= data_vld_buf[2];
    txlast_out  <= data_last;
end

assign o_tx_data    = rx_data_out;
assign o_tx_addr    = tx_addr_out;
assign o_tvalid     = tvalid_out ;
assign o_tx_last    = txlast_out ;

//--------------------------------------------------------------------------------------
// DEBUG PORT
//--------------------------------------------------------------------------------------
`ifdef SIM_PRJ
reg [6:0] prb_num = 0;
reg [3:0] symbol_num = 0;

always @ (posedge i_clk)begin
    if(i_reset)begin
        prb_num <= 'd0;
        symbol_num <= 'd0;
    end else if(prb_num == 131)begin
        prb_num <= 'd0;
        symbol_num <= symbol_num + 'd1;
    end else if(wr_wen) begin
        prb_num <= prb_num + 'd1;
    end
    
    $display("NO %d Symbol", symbol_num);
end

`endif




endmodule