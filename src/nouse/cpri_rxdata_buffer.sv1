//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/02/28 15:54:23
// Design Name: 
// Module Name: cpri_rxdata_unpack
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

module cpri_rxdata_buffer #(
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  14   ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  14   ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  14   ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [  63: 0]                        i_cpri_rx_data          ,
    input          [   6: 0]                        i_cpri_rx_seq           ,
    input                                           i_cpri_rx_vld           ,
    input                                           i_ready,

    output         [  63: 0]                        o_cpri_data             ,
    output         [   6: 0]                        o_cpri_addr             ,
    output                                          o_data_vld               
);



wire                                            wr_wen                  ;
wire                                            rd_ren                  ;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;
wire           [WDATA_WIDTH-1: 0]               wr_data                 ;
reg            [RADDR_WIDTH-1: 0]               rd_addr               =0;
wire           [RDATA_WIDTH-1: 0]               rd_data                 ;
reg                                             data_vld              =0;
reg            [   6: 0]                        seq_num               =0;
reg            [   2: 0]                        data_vld_buf          =0;



assign wr_wen = i_cpri_rx_vld;
assign wr_data = i_cpri_rx_data;

always @ (posedge i_clk)begin
    if(i_reset)
        wr_addr <= 0;
    else if(wr_addr==11094)
        wr_addr <= 0;
    else if(wr_wen)
        wr_addr <= wr_addr + 1;    
end


always @ (posedge i_clk)begin
    if(wr_addr<=1)
        data_vld <= 0;
    else if(i_ready)
        data_vld <= 1;
    else
        data_vld <= 0;
end

always @ (posedge i_clk)begin
    if(i_reset)
        rd_addr<= 0;
    else if(rd_addr==11094)
        rd_addr <= 0;
    else if(data_vld)
        rd_addr <= rd_addr + 1;
end

always @ (posedge i_clk)begin
    if(i_reset)
        seq_num <= 0;
    else if(seq_num==95)
        seq_num <= 0;
    else if(data_vld_buf[2])
        seq_num <= seq_num + 1;
end

always @ (posedge i_clk)begin
    data_vld_buf <= {data_vld_buf[1:0],data_vld};
end


Simple_Dual_Port_BRAM_XPM_intel
#(
    .WDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_A                                         ((2**LOOP_WIDTH)        ),
    .RDATA_WIDTH                                        (WDATA_WIDTH            ),
    .NUMWORDS_B                                         ((2**LOOP_WIDTH)        ),
    .INI_FILE                                           (                       ) 
)
INST_DRAM
(
    .clock                                              (i_clk                  ),
    .wren                                               (wr_wen                 ),
    .wraddress                                          ({wr_addr}              ),
    .data                                               (wr_data[WDATA_WIDTH-1:0]),
    .rdaddress                                          ({rd_addr}              ),
    .q                                                  (rd_data[RDATA_WIDTH-1:0]) 
);

assign o_cpri_data = rd_data[RDATA_WIDTH-1:0];
assign o_cpri_addr = seq_num;
assign o_data_vld = data_vld_buf[2];



endmodule
