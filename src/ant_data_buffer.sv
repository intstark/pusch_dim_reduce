//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2024/08/15 15:54:23
// Design Name: 
// Module Name: ant_data_buffer 
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

module ant_data_buffer #(
    parameter   ANT             = 4     ,
    parameter   WDATA_WIDTH     = 128   ,
    parameter   WADDR_WIDTH     = 11    ,
    parameter   RDATA_WIDTH     = 128   ,
    parameter   RADDR_WIDTH     = 11    ,
    parameter   READ_LATENCY    = 3     ,
    parameter   FIFO_DEPTH      = 16    ,
    parameter   FIFO_WIDTH      = 1     ,
    parameter   LOOP_WIDTH      = 12    ,
    parameter   INFO_WIDTH      = 1     ,
    parameter   RAM_TYPE        = 1     
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input          [WADDR_WIDTH-1: 0]               i_iq_addr               ,
    input          [ANT*32-1:0][31: 0]              i_iq_data               ,
    input                                           i_iq_vld                ,
    input                                           i_iq_last               ,

    output         [ANT*32*2-1: 0]                  o_ant_data              ,
    output         [RADDR_WIDTH-1: 0]               o_ant_addr              ,
    output                                          o_tvalid                 
);


//------------------------------------------------------------------------------------------
// PARAMETER
//------------------------------------------------------------------------------------------
localparam [RADDR_WIDTH-1: 0] RE_DEPTH = 132*12-1 ;


//------------------------------------------------------------------------------------------
// WIRE & REGISTER
//------------------------------------------------------------------------------------------
reg            [RADDR_WIDTH-1: 0]               even_raddr            =0;
reg            [RADDR_WIDTH-1: 0]               sync_raddr            =0;
wire           [RDATA_WIDTH-1: 0]               even_rdata              ;
wire           [RDATA_WIDTH-1: 0]               odd_rdata               ;
wire                                            even_rvld               ;
wire                                            odd_rvld                ;
wire           [INFO_WIDTH-1: 0]                even_rinfo              ;
wire           [INFO_WIDTH-1: 0]                odd_rinfo               ;
wire                                            even_rdy                ;
wire                                            sync_rd_rdy             ;

reg            [ANT*32-1: 0]                    wr_data               =0;
reg                                             wr_wen_even           =0;
reg                                             wr_wen_odd            =0;
reg                                             wr_wlast_even         =0;
reg                                             wr_wlast_odd          =0;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;

reg                                             ant_sel               =0;
reg            [   2: 0]                        tvalid_out            =0;

//------------------------------------------------------------------------------------------
// ant_sel=0: even antenna, ant_sel=1: odd antenna
//------------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(i_reset)
        ant_sel <= 0;
    else if(i_iq_last)
        ant_sel <= ant_sel + 1;
end


//------------------------------------------------------------------------------------------
// wr logic 
//------------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    wr_addr  <= i_iq_addr;
    
    for(int ant=0;ant<ANT;ant=ant+1) begin
        wr_data[ant*32 +: 32] <= i_iq_data[ant];
    end
end

always @(posedge i_clk) begin
    if(i_iq_vld && (!ant_sel))begin
        wr_wen_even     <= 1'b1;
        wr_wlast_even   <= i_iq_last;
    end else begin
        wr_wen_even     <= 1'b0;
        wr_wlast_even   <= 1'b0;
    end
end

always @(posedge i_clk) begin
    if(i_iq_vld && ant_sel)begin
        wr_wen_odd      <= 1'b1;
        wr_wlast_odd    <= i_iq_last;
    end else begin
        wr_wen_odd      <= 1'b0;
        wr_wlast_odd    <= 1'b0;
    end
end


//------------------------------------------------------------------------------------------
// READ logic 
//------------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    if(odd_rvld)
        begin
            if(sync_raddr == RE_DEPTH)
                sync_raddr <= 'd0;
            else
                sync_raddr <= sync_raddr + 'd1;
        end           
    else
        sync_raddr <= 'd0;
end

assign sync_rd_rdy = (odd_rvld && (sync_raddr == RE_DEPTH))? 1'd1 : 1'd0;

//------------------------------------------------------------------------------------------
// EVEN ANT MEM BLOCK 
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
)u_ram_even
(
    .syn_rst                                            (i_reset                ),
    .clk                                                (i_clk                  ),
    .wr_wen                                             (wr_wen_even            ),
    .wr_addr                                            (wr_addr                ),
    .wr_data                                            (wr_data                ),
    .wr_wlast                                           (wr_wlast_even          ),
    .wr_info                                            (wr_wlast_even          ),
    .free_size                                          (                       ),
    .rd_addr                                            (sync_raddr             ),
    .rd_data                                            (even_rdata             ),
    .rd_vld                                             (even_rvld              ),
    .rd_info                                            (even_rinfo             ),
    .rd_rdy                                             (sync_rd_rdy            ) 
);


//------------------------------------------------------------------------------------------
// ODD ANT MEM BLOCK 
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
)u_ram_odd
(
    .syn_rst                                            (i_reset                ),
    .clk                                                (i_clk                  ),
    .wr_wen                                             (wr_wen_odd             ),
    .wr_addr                                            (wr_addr                ),
    .wr_data                                            (wr_data                ),
    .wr_wlast                                           (wr_wlast_odd           ),
    .wr_info                                            (wr_wlast_odd           ),
    .free_size                                          (                       ),
    .rd_addr                                            (sync_raddr             ),
    .rd_data                                            (odd_rdata              ),
    .rd_vld                                             (odd_rvld               ),
    .rd_info                                            (odd_rinfo              ),
    .rd_rdy                                             (sync_rd_rdy            ) 
);

always @ (posedge i_clk)begin
   tvalid_out[2:0] <= {tvalid_out[1:0], odd_rvld};
end

assign o_ant_data = {odd_rdata, even_rdata};
assign o_tvalid = tvalid_out[2];

endmodule
