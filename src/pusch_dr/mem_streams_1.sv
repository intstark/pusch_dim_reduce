//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: mac_beams_mem
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
module mem_streams_1 # (
    parameter integer CHANNELS           =  16   ,
    parameter integer WDATA_WIDTH        =  64   ,
    parameter integer WADDR_WIDTH        =  11   ,
    parameter integer RDATA_WIDTH        =  64   ,
    parameter integer RADDR_WIDTH        =  11   ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_rvalid                ,
    input                                           i_wr_wen                ,
    input          [WADDR_WIDTH-1: 0]               i_wr_addr               ,
    input          [CHANNELS-1:0][WDATA_WIDTH-1: 0] i_wr_data               ,
    input                                           i_rd_ren                ,
    input          [RADDR_WIDTH-1: 0]               i_rd_addr               ,

    output         [CHANNELS-1:0][RDATA_WIDTH-1: 0] o_rd_data               ,
    output         [RADDR_WIDTH-1: 0]               o_rd_addr               ,
    output                                          o_tvalid                 
);

//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
localparam RDATA_DEPTH = 1<<RADDR_WIDTH;
localparam WDATA_DEPTH = 1<<WADDR_WIDTH;

//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
genvar gi;

reg            [CHANNELS-1:0][WDATA_WIDTH-1: 0] wr_data               =0;
reg            [CHANNELS-1:0][WADDR_WIDTH-1: 0] wr_addr               =0;
reg            [CHANNELS-1: 0]                  wr_wen                =0;
reg            [CHANNELS-1: 0]                  rd_ren                =0;
reg            [CHANNELS-1:0][RADDR_WIDTH-1: 0] rd_addr               =0;
wire           [CHANNELS-1:0][RDATA_WIDTH-1: 0] rd_data                 ;

reg            [   2: 0]                        rvalid_r              =0;
wire                                            rvld_neg                ;



//--------------------------------------------------------------------------------------
// rvalid buffer
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    rvalid_r <= {rvalid_r[1:0],i_rvalid};
end

assign rvld_neg = ~i_rvalid & (rvalid_r[0]);


//--------------------------------------------------------------------------------------
// generate blocks write enable signal
//--------------------------------------------------------------------------------------
reg            [RADDR_WIDTH-1: 0]               rd_addr_syn           =0;
wire           [CHANNELS-1: 0]                  data_vld                ;
wire           [CHANNELS-1: 0]                  rd_empty                ;
wire           [CHANNELS-1: 0]                  wr_full                 ;

always @(posedge i_clk) begin
    if(i_reset)
        wr_wen <= {CHANNELS{1'b0}};
    else
        wr_wen <= {CHANNELS{i_wr_wen}};
    
    for(int i=0;i<CHANNELS;i=i+1) begin
        wr_addr[i] <= i_wr_addr;
        wr_data[i] <= i_wr_data[i];
        rd_addr[i] <= i_rd_addr;
    end
end

//--------------------------------------------------------------------------------------
// Store CHANNELS blocks of data in memory at different time
// Read data from memory at the same time
//--------------------------------------------------------------------------------------
generate for(gi=0;gi<CHANNELS;gi=gi+1)begin : fifo_blocks
    Simple_Dual_Port_BRAM_XPM_intel #(
        
        .WDATA_WIDTH                                        (WDATA_WIDTH            ),
        .NUMWORDS_A                                         (WDATA_DEPTH            ),
        .RDATA_WIDTH                                        (RDATA_WIDTH            ),
        .NUMWORDS_B                                         (RDATA_DEPTH            ),
        .INI_FILE                                           (                       ) 
    )INST_RAM(
        .clock                                              (i_clk                  ),
        .wren                                               (wr_wen [gi]            ),
        .wraddress                                          (wr_addr[gi]            ),
        .data                                               (wr_data[gi]            ),
        .rdaddress                                          (rd_addr[gi]            ),
        .q                                                  (rd_data[gi]            ) 
    );
end
endgenerate

//--------------------------------------------------------------------------------------
// output valid signal
//--------------------------------------------------------------------------------------

assign o_tvalid = data_vld[0];
assign o_rd_data = rd_data;





endmodule
