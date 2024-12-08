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

    input          [   1: 0]                        i_dr_mode               ,// re-sort @ 0:inital once; 1: slot0symb0: 2 per symb0 

    // header info
    input          [  63: 0]                        i_info_0                ,// IQ HD 
    input          [   7: 0]                        i_info_1                ,// FFT AGC

    input          [WADDR_WIDTH-1: 0]               i_iq_addr               ,
    input          [ANT-1:0][31: 0]                 i_iq_data               ,
    input                                           i_iq_vld                ,
    input                                           i_iq_last               ,

    output         [  63: 0]                        o_info_0                ,// IQ HD 
    output         [  15: 0]                        o_info_1                ,// FFT AGC: {odd, even}
    output         [   6: 0]                        o_slot_idx              ,//slot index
    output         [   3: 0]                        o_symb_idx              ,// symbol index

    output         [ANT*32-1: 0]                    o_ant_even              ,
    output         [ANT*32-1: 0]                    o_ant_odd               ,
    output         [RADDR_WIDTH-1: 0]               o_ant_addr              ,
    output                                          o_ant_sop               ,
    output                                          o_ant_eop               ,
    output                                          o_tvalid                ,
    output                                          o_symb_clr
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
wire                                            sync_rd_sop             ;
wire                                            sync_rd_eop             ;

reg            [ANT*32-1: 0]                    wr_data               =0;
reg                                             wr_wen_even           =0;
reg                                             wr_wen_odd            =0;
reg                                             wr_wlast_even         =0;
reg                                             wr_wlast_odd          =0;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;

reg                                             ant_sel               =0;
reg            [   2: 0]                        tvalid_out            =0;
reg            [   2: 0]                        tsop_out              =0;
reg            [   2: 0]                        teop_out              =0;

reg            [INFO_WIDTH-1: 0]                wr_info               =0;

reg            [4:0][127:0]                     dout_info0            =0;


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
    wr_info  <= {i_info_1, i_info_0};

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
assign sync_rd_sop = (sync_raddr == 1)? 1'd1 : 1'd0;
assign sync_rd_eop = (sync_raddr == RE_DEPTH)? 1'd1 : 1'd0;

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
    .wr_info                                            (wr_info                ),
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
    .wr_info                                            (wr_info                ),
    .free_size                                          (                       ),
    .rd_addr                                            (sync_raddr             ),
    .rd_data                                            (odd_rdata              ),
    .rd_vld                                             (odd_rvld               ),
    .rd_info                                            (odd_rinfo              ),
    .rd_rdy                                             (sync_rd_rdy            ) 
);

always @ (posedge i_clk)begin
   tvalid_out[2:0] <= {tvalid_out[1:0], odd_rvld };
   tsop_out[2:0]   <= {tsop_out[1:0], sync_rd_sop};
   teop_out[2:0]   <= {teop_out[1:0], sync_rd_eop};
end

reg            [   7: 0]                        fft_agc_even          =0;
reg            [   7: 0]                        fft_agc_odd           =0;
reg            [1:0][15: 0]                     dout_fft_agc          =0;


always @(posedge i_clk) begin
    if(odd_rvld)begin
        fft_agc_even <= even_rinfo[71:64];
        fft_agc_odd  <= odd_rinfo[71:64];
    end else begin
        fft_agc_even <= fft_agc_even;
        fft_agc_odd  <= fft_agc_odd;
    end 
end

always @(posedge i_clk) begin
    dout_fft_agc[0] <= {fft_agc_odd, fft_agc_even};
    for(int i=1; i<2; i++)begin
        dout_fft_agc[i] <= dout_fft_agc[i-1];
    end
end




always @(posedge i_clk) begin
//    if(even_rvld)
//        dout_info0[0] <= even_rinfo;
    if(odd_rvld)
        dout_info0[0] <= odd_rinfo;
    else
        dout_info0[0] <= dout_info0[0];

    for(int i=1; i<5; i++)begin
        dout_info0[i] <= dout_info0[i-1];
    end
end


//------------------------------------------------------------------------------------------
// clear flag for dr re-calculation 
//------------------------------------------------------------------------------------------
reg                                             symb_1st_d1           =0;
reg                                             symb_1st_d2           =0;
wire                                            symb_clr                ;
wire           [   6: 0]                        slot_idx_pre            ;
wire           [   3: 0]                        symb_idx_pre            ;



assign slot_idx_pre = dout_info0[0][18:12]  ;
assign symb_idx_pre = dout_info0[0][11:8]   ;

always @ (posedge i_clk)begin
    symb_1st_d2 <= symb_1st_d1;
    case(i_dr_mode)
        2'b00:  symb_1st_d1 <= 1'b0;
        2'b01:  begin // every slot 0 & symbol 0
                    if(symb_idx_pre == 0 && slot_idx_pre == 0)
                        symb_1st_d1 <= 1'b1;
                    else
                        symb_1st_d1 <= 1'b0;
                end
        2'b10:  begin // every symbol 0
                    if(symb_idx_pre == 0)
                        symb_1st_d1 <= 1'b1;
                    else
                        symb_1st_d1 <= 1'b0;
                end
        default:symb_1st_d1 <= 1'b0;
    endcase
end

assign symb_clr = symb_1st_d1 && (~symb_1st_d2);



//------------------------------------------------------------------------------------------
// Debug signal
//------------------------------------------------------------------------------------------
wire           [   3: 0]                        pkg_type_out            ;
wire                                            cell_idx_out            ;
wire           [   6: 0]                        slot_idx_out            ;
wire           [   3: 0]                        symb_idx_out            ;
wire           [  63: 0]                        fft_agc_out             ;



assign pkg_type_out = dout_info0[2][39:36]  ;
assign cell_idx_out = dout_info0[2][19]     ;
assign slot_idx_out = dout_info0[2][18:12]  ;
assign symb_idx_out = dout_info0[2][11:8]   ;
assign fft_agc_out  = dout_info0[2][127:64] ;

//------------------------------------------------------------------------------------------
// Ouptut assignment
//------------------------------------------------------------------------------------------
assign o_ant_even = even_rdata      ;
assign o_ant_odd  = odd_rdata       ;
assign o_tvalid   = tvalid_out[2]   ;
assign o_ant_sop  = tsop_out  [1]   ;
assign o_ant_eop  = teop_out  [2]   ;

assign o_info_0   = dout_info0[2][63: 0];
assign o_info_1   = dout_fft_agc[1];
assign o_symb_idx = symb_idx_out;
assign o_slot_idx = slot_idx_out;
assign o_symb_clr = symb_clr;


endmodule
