//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: dr_data_buffer
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
module dr_data_buffer#(
    parameter integer WDATA_WIDTH        =  128  ,
    parameter integer WADDR_WIDTH        =  11   ,
    parameter integer RDATA_WIDTH        =  128  ,
    parameter integer RADDR_WIDTH        =  11   ,
    parameter integer FIFO_DEPTH         =  4    ,
    parameter integer FIFO_WIDTH         =  1    ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  13   ,    
    parameter integer INFO_WIDTH         =  1    ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [15:0][31: 0]                    i_rx_data               ,
    input                                           i_rx_vld                ,
    input                                           i_rx_sop                ,
    input                                           i_rx_eop                ,
    input                                           i_rready                ,

    output         [3:0][31: 0]                     o_tx_data               ,
    output                                          o_tx_vld                , 
    output                                          o_tx_sop                ,
    output                                          o_tx_eop                ,
    output         [   8: 0]                        o_prb_idx                
);

//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam [WADDR_WIDTH-1: 0] DATA_DEPTH = 1583;
localparam [10: 0]            HLF_SYMBOLS = 1583;

//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
genvar gi;
reg            [   3: 0]                        rd_rdy                  ;
reg                                             wr_wlast                ;
reg                                             wr_wen                =0;
reg            [   3: 0]                        rd_ren                =0;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;
reg            [WDATA_WIDTH-1: 0]               wr_data[3:0]          ='{default:0};
reg            [3:0][RADDR_WIDTH-1: 0]          rd_addr               =0;
wire           [RDATA_WIDTH-1: 0]               rd_data[3:0]            ;
wire                                            rd_en                   ;
reg            [  10: 0]                        seq_num               =0;
wire           [3:0]                            rd_vld                  ;

reg            [   3: 0]                        rd_rlast              =0;
reg            [   2: 0]                        rd_rlast_buf          =0;
reg            [   2: 0]                        rd_en_buf             =0;
reg            [   7: 0]                        rd_sym_num            =0;
wire           [LOOP_WIDTH-WADDR_WIDTH: 0]      free_size               ;





//--------------------------------------------------------------------------------------
// Write logic
//--------------------------------------------------------------------------------------
reg            [4:0][WDATA_WIDTH-1: 0]          wr_data0_buf          =0;
reg            [   5: 0]                        rx_vld_buf            =0;

always @ (posedge i_clk)begin
    if(i_reset)
        wr_wen <= 1'b0;
    else
        wr_wen <= i_rx_vld;
end

always @ (posedge i_clk)begin
    wr_data[0] <= {i_rx_data[ 6],i_rx_data[ 4],i_rx_data[ 2],i_rx_data[ 0]};
    wr_data[1] <= {i_rx_data[ 7],i_rx_data[ 5],i_rx_data[ 3],i_rx_data[ 1]};
    wr_data[2] <= {i_rx_data[14],i_rx_data[12],i_rx_data[10],i_rx_data[ 8]};
    wr_data[3] <= {i_rx_data[15],i_rx_data[13],i_rx_data[11],i_rx_data[ 9]};
end


always @ (posedge i_clk)begin
    rx_vld_buf <= {rx_vld_buf[4:0],i_rx_vld};    

    wr_data0_buf[0] <= wr_data[0];
    for(int i=1;i<5;i=i+1) begin
        wr_data0_buf[i] <= wr_data0_buf[i-1];
    end
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
    else if(wr_addr == DATA_DEPTH-1)
        wr_wlast <= 1'b1;
    else
        wr_wlast <= 1'b0;
end

assign wr_info = (wr_addr==1) ? 1'b1 : 1'b0;



reg [1:0] wr_block_num = 2'd0;
always @ (posedge i_clk)begin
    if(i_reset)
        wr_block_num <= 2'd0;
    else if(wr_wlast)
        wr_block_num <= wr_block_num + 2'd1;
end

//--------------------------------------------------------------------------------------
// Read logic
//--------------------------------------------------------------------------------------
reg            [   1: 0]                        rd_block_num          =0;
reg            [   3: 0]                        raddr_almost_full     =0;
reg            [RDATA_WIDTH-1: 0]               rd_dout               =0;
reg            [2:0][3: 0]                      rd_ren_buf            =0;
reg                                             rd_dout_vld           =0;


always @ (posedge i_clk)begin
    if(i_reset)
        rd_block_num <= 2'd0;
    else if(|raddr_almost_full)
        rd_block_num <= rd_block_num + 2'd1;
end

always @ (posedge i_clk)begin
    case(rd_block_num)
        2'd0    : rd_ren[3:0] <= {3'd0,rx_vld_buf[4] | rd_vld[0]     };
        2'd1    : rd_ren[3:0] <= {2'd0,rx_vld_buf[4] | rd_vld[1],1'b0};
        2'd2    : rd_ren[3:0] <= {1'd0,rx_vld_buf[4] | rd_vld[2],2'd0};
        2'd3    : rd_ren[3:0] <= {     rx_vld_buf[4] | rd_vld[3],3'd0};
        default : rd_ren[3:0] <= 4'd0;
    endcase
end

always @ (posedge i_clk)begin
    for(int i=0;i<4;i=i+1) begin
        if(rd_addr[i] == DATA_DEPTH-1)
            rd_rlast[i] <= 1'b1;
        else
            rd_rlast[i] <= 1'b0;
    end
end

always @ (posedge i_clk)begin
    for(int i=0;i<4;i=i+1) begin
        if(rd_rlast[i])
            rd_addr[i] <= 'd0;
        else if(rd_ren[i])
            rd_addr[i] <= rd_addr[i] + 'd1;
    end
end


always @ (posedge i_clk)begin
    for(int i=0;i<4;i=i+1) begin
        if(rd_addr[i] == DATA_DEPTH-2)
            raddr_almost_full[i] <= 1'b1;
        else
            raddr_almost_full[i] <= 1'b0;
    end
end

always @ (posedge i_clk)begin
    for(int i=0;i<4;i=i+1) begin
        if(raddr_almost_full[i])
            rd_rdy[i] <= 1'b1;
        else
            rd_rdy[i] <= 1'b0;
    end
end



always @ (posedge i_clk)begin
    rd_ren_buf[0] <= rd_ren;
    for(int i=1;i<3;i=i+1) begin
        rd_ren_buf[i] <= rd_ren_buf[i-1];
    end
end

always @ (posedge i_clk)begin
    case(rd_ren_buf[2])
        4'd1    : rd_dout <= rd_data[0];
        4'd2    : rd_dout <= rd_data[1];
        4'd4    : rd_dout <= rd_data[2];
        4'd8    : rd_dout <= rd_data[3];
        default : rd_dout <= 'd0;
    endcase
end

always @ (posedge i_clk)begin
    if(|rd_ren_buf[2])
        rd_dout_vld <= 1'b1;
    else
        rd_dout_vld <= 1'b0;
end

//--------------------------------------------------------------------------------------
// 
//--------------------------------------------------------------------------------------
reg            [   3: 0]                        dr_renum              =0;
reg            [   3: 0]                        dr_rbnum              =0;
reg            [   8: 0]                        dr_prb_idx            =0;
wire                                            re_sop                  ;
wire                                            re_eop                  ;


always @(posedge i_clk) begin
    if(i_reset)
        dr_renum <= 0;
    else if(dr_renum == 11)
        dr_renum <= 0;
    else if(rd_dout_vld)
        dr_renum <= dr_renum + 1;
end

always @(posedge i_clk) begin
    if(i_reset)
        dr_rbnum <= 0;
    else if(dr_rbnum == 3 && re_eop)
        dr_rbnum <= 0;
    else if(re_eop)
        dr_rbnum <= dr_rbnum + 1;
end

always @(posedge i_clk) begin
    if(i_reset)
        dr_prb_idx <= 0;
    else if(dr_prb_idx == 131 && re_eop)
        dr_prb_idx <= 0;
    else if(re_eop)
        dr_prb_idx <= dr_prb_idx + 1;
end



assign re_eop = (rd_dout_vld && (dr_renum == 11)) ? 1'b1 : 1'b0;
assign re_sop = (rd_dout_vld && dr_renum == 0 && (dr_rbnum == 0)) ? 1'b1 : 1'b0;



//------------------------------------------------------------------------------------------
// RAM BLOCK FOR 16 BEAMS 
//------------------------------------------------------------------------------------------
generate
    for(gi=0;gi<4;gi=gi+1) begin: gen_ram_block
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
        )loop_buffer_sync
        (
            .syn_rst                                            (i_reset                ),
            .clk                                                (i_clk                  ),
            .wr_wen                                             (wr_wen                 ),
            .wr_addr                                            (wr_addr                ),
            .wr_data                                            (wr_data[gi]            ),
            .wr_wlast                                           (wr_wlast               ),
            .wr_info                                            (wr_info                ),
            .free_size                                          (                       ),
            .rd_addr                                            (rd_addr[gi]            ),
            .rd_data                                            (rd_data[gi]            ),
            .rd_vld                                             (rd_vld [gi]            ),
            .rd_info                                            (                       ),
            .rd_rdy                                             (rd_rdy [gi]            ) 
        );
    end
endgenerate


//--------------------------------------------------------------------------------------
// Output 
//--------------------------------------------------------------------------------------

assign o_tx_data[0] = rd_dout[0*32 +: 32];
assign o_tx_data[1] = rd_dout[1*32 +: 32];
assign o_tx_data[2] = rd_dout[2*32 +: 32];
assign o_tx_data[3] = rd_dout[3*32 +: 32];
assign o_tx_vld     = rd_dout_vld;
assign o_tx_sop     = re_sop;
assign o_tx_eop     = re_eop;
assign o_prb_idx    = dr_prb_idx;






endmodule