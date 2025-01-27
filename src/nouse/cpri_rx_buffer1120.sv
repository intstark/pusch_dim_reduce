//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: cpri_rx_buffer
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
module cpri_rx_buffer#(
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
    input                                           i_cpri_clk              ,
    input                                           i_cpri_reset            ,

    input                                           i_clk                   ,
    input                                           i_reset                 ,


    input          [WDATA_WIDTH-1: 0]               i_rx_data               ,
    input                                           i_rvalid                ,
    input                                           i_rready                ,

    input                                           i_rd_en                 ,
    output                                          o_rd_vld                ,

    output         [RDATA_WIDTH-1: 0]               o_tx_data               ,
    output         [   6: 0]                        o_tx_addr               ,
    output                                          o_tx_last               ,
    output                                          o_tready                ,
    output                                          o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam [WADDR_WIDTH-1: 0] DATA_DEPTH = 1584*2-1;
localparam [6: 0]             CHIP_DW    = 95;

//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
genvar gi;

reg                                             rd_rdy                  ;
reg                                             wr_wlast                ;
reg                                             wr_wen                =0;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;
reg            [WDATA_WIDTH-1: 0]               wr_data               =0;
reg            [RADDR_WIDTH-1: 0]               rd_addr               =0;
wire           [RDATA_WIDTH-1: 0]               rd_data                 ;
wire                                            rd_en                   ;
reg            [   6: 0]                        seq_num               =0;
wire                                            rd_vld                  ;
reg                                             data_last             =0;

reg                                             rd_rlast              =0;
reg            [   2: 0]                        rd_rlast_buf          =0;
reg            [   2: 0]                        rd_en_buf             =0;
reg            [   7: 0]                        rd_sym_num            =0;
wire           [LOOP_WIDTH-WADDR_WIDTH: 0]      free_size               ;
reg                                             sym1_done             =0;
wire                                            raddr_full              ;
wire                                            raddr_least_2           ;
wire                                            raddr_almost_full       ;

reg            [   3: 0]                        rx_vld_buf            =0;
reg            [   3: 0]                        symb_idx              =0;
reg                                             rx_vld                =0;
reg            [3:0][63: 0]                     rx_data_buf           =0;
reg            [  63: 0]                        cpri_rx_data          =0;
reg                                             cpri_rx_vld           =0;



//--------------------------------------------------------------------------------------
// From Symbol 0 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    rx_vld_buf[3:0] <= {rx_vld_buf[2:0],i_rvalid};
    if(rx_vld_buf[2])
        symb_idx <= i_rx_data[11:8];
end

always @(posedge i_clk) begin
    cpri_rx_vld <= rx_vld_buf[3];
    if(symb_idx ==0 && rx_vld_buf[3])
        rx_vld <= 1'b1;
end

always @(posedge i_clk) begin
    rx_data_buf[0] <= i_rx_data;
    cpri_rx_data   <= rx_data_buf[3];
    for(int i=1; i<4; i=i+1)begin
        rx_data_buf[i] <= rx_data_buf[i-1];
    end 
end

//--------------------------------------------------------------------------------------
// Write logic
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(i_reset)
        wr_wen <= 1'b0;
    else if(cpri_rx_vld)
        wr_wen <= 1'b1;
end

always @ (posedge i_clk)begin
    wr_data <= cpri_rx_data;
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
assign rd_en                = i_rready & i_rd_en;
assign raddr_full           = (rd_addr == DATA_DEPTH) ? 1'b1 : 1'b0;
assign raddr_almost_full    = (rd_addr == DATA_DEPTH-1) ? 1'b1 : 1'b0;
assign raddr_least_2        = (rd_addr == DATA_DEPTH-2) ? 1'b1 : 1'b0;

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
        rd_addr <= 'd0;
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
    rd_rlast_buf<= {rd_rlast_buf[1:0],rd_rlast};
    rd_en_buf   <= {rd_en_buf[1:0],rd_en};
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
    else if(seq_num==CHIP_DW)
        seq_num <= 'd0;
    else if(rd_en_buf[2])
        seq_num <= seq_num + 'd1;
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
loop_buffer_async_intel #(
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
)cpri_rx_buffer_async(
    .wr_rst                                             (i_cpri_reset           ),
    .wr_clk                                             (i_cpri_clk             ),
    .rd_rst                                             (i_reset                ),
    .rd_clk                                             (i_clk                  ),
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
reg            [   6: 0]                        tx_addr_out           =0;
reg                                             tvalid_out            =0;
reg                                             txlast_out            =0;

always @ (posedge i_clk)begin
    rx_data_out <= rd_data[RDATA_WIDTH-1:0];
    tx_addr_out <= seq_num;
    tvalid_out  <= rd_en_buf[2];
    txlast_out  <= data_last;
end

assign o_tx_data = rx_data_out;
assign o_tx_addr = tx_addr_out;
assign o_tvalid  = tvalid_out ;
assign o_tx_last = txlast_out ;
assign o_rd_vld  = rd_vld;
assign o_tready  = (free_size==0) ? 1'b0 : 1'b1;



endmodule