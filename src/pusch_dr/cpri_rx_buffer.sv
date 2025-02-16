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
    parameter integer FIFO_WIDTH         =  64   ,
    parameter integer READ_LATENCY       =  3    ,
    parameter integer LOOP_WIDTH         =  15   ,    
    parameter integer INFO_WIDTH         =  64   ,    
    parameter integer RAM_TYPE           =  1
)(
    input                                           i_cpri_clk              ,
    input                                           i_cpri_reset            ,

    input                                           i_clk                   ,
    input                                           i_reset                 ,
    input          [   1: 0]                        i_dr_mode               ,

    input                                           i_rx_rfp                ,
    input                                           i_enable                ,
    
    input          [WDATA_WIDTH-1: 0]               i_rx_data               ,
    input                                           i_rvalid                ,
    input                                           i_rready                ,

    input                                           i_rd_en                 ,
    output                                          o_rd_vld                ,
    output                                          o_rx_sop                ,
    output                                          o_symb_1st              ,
    output                                          o_symb_clr              ,
    output                                          o_symb_eop              ,

    output         [  63: 0]                        o_fft_agc               ,// fft agc
    output         [RDATA_WIDTH-1: 0]               o_tx_data               ,// cpri data
    output         [   6: 0]                        o_tx_addr               ,// cpri chip addr
    output                                          o_tx_last               ,// cpri chip last
    output                                          o_tready                ,
    output                                          o_tvalid                ,

    // bist
    output                                          o_rx_err                 // rx data error flag
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
wire                                            rrst_rfp                ;
wire                                            rrst_wr_sync            ;
reg                                             cpri_reset            =0;
reg                                             rd_rdy                =0;
reg                                             wr_wlast                ;
reg                                             wr_wen                =0;
reg            [WADDR_WIDTH-1: 0]               wr_addr               =0;
reg            [WDATA_WIDTH-1: 0]               wr_data               =0;
reg            [RADDR_WIDTH-1: 0]               rd_addr               =0;
wire           [RDATA_WIDTH-1: 0]               rd_data                 ;
wire           [INFO_WIDTH-1: 0]                wr_info                 ;
wire           [INFO_WIDTH-1: 0]                rd_info                 ;
reg                                             rd_ren                =0;
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

reg            [   4: 0]                        rx_vld_buf            =0;
reg            [4:0][63: 0]                     rx_data_buf           =0;
reg            [   6: 0]                        slot_idx              =0;
reg            [   3: 0]                        symb_idx              =0;
reg            [   7: 0]                        prb0_idx              =0;
reg            [   7: 0]                        prb1_idx              =0;
reg            [   3: 0]                        pkg_type              =0;
reg            [   3: 0]                        ant0_idx              =0;
reg            [   3: 0]                        ant1_idx              =0;
reg                                             rx_vld                =0;
reg            [  63: 0]                        cpri_rx_data          =0;
reg                                             cpri_rx_vld           =0;
reg            [   6: 0]                        slot_idx_out          =0;
reg            [   3: 0]                        symb_idx_out          =0;
reg            [   7: 0]                        prb1_idx_out          =0;
reg                                             pusch_en              =0;
reg                                             pusch_pkg             =0;
reg                                             rx_sop                =0;
reg            [   3: 0]                        symb_in_loc           =0;

//--------------------------------------------------------------------------------------
// Reset synchronizer 
//--------------------------------------------------------------------------------------
alt_reset_synchronizer #(.depth(2),.rst_value(1)) wreset_sync (.clk(i_cpri_clk),.reset_n(!i_reset),.rst_out(rrst_wr_sync));

alt_reset_synchronizer #(.depth(2),.rst_value(1)) rfprst_sync (.clk(i_cpri_clk),.reset_n(!i_rx_rfp),.rst_out(rrst_rfp));

always @ (posedge i_cpri_clk)begin
    if(i_cpri_reset)
        cpri_reset <= 1'b1;
    else if(rrst_rfp)
        cpri_reset <= 1'b1;
    else if(rrst_wr_sync)
        cpri_reset <= 1'b1;
    else
        cpri_reset <= 1'b0;
end

//--------------------------------------------------------------------------------------
// Slot filter
//--------------------------------------------------------------------------------------
always @(posedge i_cpri_clk) begin
    rx_vld_buf[4:0] <= {rx_vld_buf[3:0],i_rvalid};
    if(cpri_reset)begin
        pkg_type <= 'd0;
        prb0_idx <= 'd0;
        prb1_idx <= 'd0;
        slot_idx <= 'd0;
        symb_idx <= 'd0;
        ant0_idx <= 'd0;
        ant1_idx <= 'd0;
    end else if(rx_vld_buf[2])begin
        pkg_type <= i_rx_data[39:36];
        prb0_idx <= i_rx_data[35:28];
        prb1_idx <= i_rx_data[27:20];
        slot_idx <= i_rx_data[18:12];
        symb_idx <= i_rx_data[11: 8];
        ant0_idx <= i_rx_data[ 7: 4];
        ant1_idx <= i_rx_data[ 3: 0];
    end
end

// filter up-stream
always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        pusch_pkg <= 1'b0;
    else if(pkg_type == 4'd8)
        pusch_pkg <= 1'b1;
    else begin
        pusch_pkg <= 1'b0;
    end
end

// filter up-stream slots
always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        pusch_en <= 1'b0;
    else begin
        case(slot_idx)
            7'd4    :   pusch_en <= 1'b1;
            7'd9    :   pusch_en <= 1'b1;
            7'd14   :   pusch_en <= 1'b1;
            7'd19   :   pusch_en <= 1'b1;
            7'd24   :   pusch_en <= 1'b1;
            7'd29   :   pusch_en <= 1'b1;
            7'd34   :   pusch_en <= 1'b1;
            7'd39   :   pusch_en <= 1'b1;
            7'd44   :   pusch_en <= 1'b1;
            7'd49   :   pusch_en <= 1'b1;
            7'd54   :   pusch_en <= 1'b1;
            7'd59   :   pusch_en <= 1'b1;
            7'd64   :   pusch_en <= 1'b1;
            7'd69   :   pusch_en <= 1'b1;
            7'd74   :   pusch_en <= 1'b1;
            7'd79   :   pusch_en <= 1'b1;
            default :   pusch_en <= 1'b0;
        endcase
    end
end

// generate cpri valid
always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        rx_sop <= 1'b0;
    else if(!i_enable) 
        rx_sop <= 1'b0;
    else if(pusch_en && pusch_pkg && symb_idx == 4'd0 && prb0_idx==0 && prb1_idx==4)
        rx_sop <= 1'b1;
end

always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        cpri_rx_vld <= 1'b0;
    else if(i_enable && pusch_en && pusch_pkg)
        cpri_rx_vld <= 1'b1;
    else
        cpri_rx_vld <= 1'b0; 
end

// generate cpri data
always @(posedge i_cpri_clk) begin
    rx_data_buf[0] <= i_rx_data;
    cpri_rx_data   <= rx_data_buf[4];
    for(int i=1; i<5; i=i+1)begin
        rx_data_buf[i] <= rx_data_buf[i-1];
    end 
end

always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        symb_in_loc <= 0;
    else if(symb_in_loc=='d13 && wr_wlast)
        symb_in_loc = 0;
    else if(wr_wlast)
        symb_in_loc <= symb_in_loc + 'd1;
end

reg            [   3: 0]                        symb_idx_d1           =0;
reg                                             symb_mismatch         =0;
always @(posedge i_cpri_clk) begin
    symb_idx_d1 <= symb_idx;
    if(cpri_reset)
        symb_mismatch <= 1'b0;
    else if(!pusch_en)
        symb_mismatch <= 1'b0;
    else if((symb_in_loc ^ symb_idx_d1))
        symb_mismatch <= 1'b1;
end

assign o_rx_err = {7'd0,symb_mismatch};

//--------------------------------------------------------------------------------------
// Write logic
//--------------------------------------------------------------------------------------
always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        wr_wen <= 1'b0;
    else if(rx_sop && cpri_rx_vld)
        wr_wen <= 1'b1;
    else if(wr_wlast)
        wr_wen <= 1'b0;
    else
        wr_wen <= 1'b0;
end

always @(posedge i_cpri_clk) begin
    wr_data <= cpri_rx_data;
end

always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        wr_addr <= 'd0;
    else if(wr_addr==DATA_DEPTH)
        wr_addr <= 'd0;
    else if(wr_wen)
        wr_addr <= wr_addr + 'd1;
end

always @(posedge i_cpri_clk) begin
    if(cpri_reset)
        wr_wlast <= 1'b0;
    else if(wr_addr==DATA_DEPTH-1)
        wr_wlast <= 1'b1;
    else
        wr_wlast <= 1'b0;
end

reg            [  31: 0]                        fft_agc_eve           =0;
reg            [  31: 0]                        fft_agc_odd           =0;
always @(posedge i_cpri_clk) begin
    if(wr_addr == 'd4)
        fft_agc_eve <= wr_data[63:32];
    else if(wr_addr == 'd1636)
        fft_agc_odd <= wr_data[63:32];
end
assign wr_info = {fft_agc_odd, fft_agc_eve};


//--------------------------------------------------------------------------------------
// READ CLOCK Domain
//--------------------------------------------------------------------------------------
wire                                            wrst_rd_sync            ;
reg                                             rd_reset              =0;


//--------------------------------------------------------------------------------------
// Reset synchronizer 
//--------------------------------------------------------------------------------------
alt_reset_synchronizer #(.depth(2),.rst_value(1)) rreset_sync (.clk(i_clk),.reset_n(!i_cpri_reset),.rst_out(wrst_rd_sync));

always @ (posedge i_clk)begin
    if(i_reset)
        rd_reset <= 1'b1;
    else if(wrst_rd_sync)
        rd_reset <= 1'b1;
    else
        rd_reset <= 1'b0;
end

//--------------------------------------------------------------------------------------
// dr re-calcuate mode ctrl 
//--------------------------------------------------------------------------------------
reg                                             symb_1st_d1           =0;
reg                                             symb_1st_d2           =0;
wire                                            symb_clr                ;

always @(posedge i_clk) begin
    symb_1st_d2 <= symb_1st_d1;
    case(i_dr_mode)
        2'b00:  symb_1st_d1 <= 1'b0;
        2'b01:  begin // every slot 4 & symbol 0
                    if(symb_idx_out == 0 && slot_idx_out == 4)
                        symb_1st_d1 <= 1'b1;
                    else
                        symb_1st_d1 <= 1'b0;
                end
        2'b10:  begin // every symbol 0
                    if(symb_idx_out == 0)
                        symb_1st_d1 <= 1'b1;
                    else
                        symb_1st_d1 <= 1'b0;
                end
        default:symb_1st_d1 <= 1'b0;
    endcase
end

assign symb_clr = symb_1st_d1 && (~symb_1st_d2);

//--------------------------------------------------------------------------------------
// Read logic
//--------------------------------------------------------------------------------------
assign raddr_full           = (rd_addr == DATA_DEPTH) ? 1'b1 : 1'b0;
assign raddr_almost_full    = (rd_addr == DATA_DEPTH-1) ? 1'b1 : 1'b0;
assign raddr_least_2        = (rd_addr == DATA_DEPTH-2) ? 1'b1 : 1'b0;

always @ (posedge i_clk)begin
    if(rd_reset)
        rd_ren <= 'd0;
    else
        rd_ren <= i_rd_en;
end 

assign rd_en = i_rready & rd_ren;


always @ (posedge i_clk)begin
    if(rd_reset)
        rd_sym_num <= 8'd0;
    else if(symb_clr)
        rd_sym_num <= 8'd0;
    else if(rd_sym_num == 4)
        rd_sym_num <= 8'd4;
    else if(i_rready && rd_rlast)
        rd_sym_num <= rd_sym_num + 8'd1;
end

always @ (posedge i_clk)begin
    if(rd_reset)
        sym1_done <= 1'b0;
    else if(symb_clr)
        sym1_done <= 1'b0;
    else if(rd_sym_num==3 && raddr_least_2)
        sym1_done <= 1'b1;
end

always @ (posedge i_clk)begin
    if(rd_reset)
        rd_addr <= 'd0;
    else if(rd_rlast)
        rd_addr <= 'd0;
    else if(rd_en)
        rd_addr <= rd_addr + 'd1;
end

always @ (posedge i_clk)begin
    if(rd_reset)
        rd_rlast <= 1'b0;
    else if(i_rready && raddr_almost_full)
        rd_rlast <= 1'b1;
    else
        rd_rlast <= 1'b0;
end

always @ (posedge i_clk)begin
    if(rd_reset)begin
        rd_rlast_buf<= 'd0;
        rd_en_buf   <= 'd0;
    end else begin
        rd_rlast_buf<= {rd_rlast_buf[1:0],rd_rlast};
        rd_en_buf   <= {rd_en_buf[1:0],rd_en};
    end
end

always @ (posedge i_clk)begin
    if(i_rready && sym1_done && raddr_almost_full)
        rd_rdy <= 1'b1;
    else
        rd_rdy <= 1'b0;
end

always @ (posedge i_clk)begin
    if(rd_reset)
        seq_num <= 'd0;
    else if(seq_num==CHIP_DW)
        seq_num <= 'd0;
    else if(rd_en_buf[2])
        seq_num <= seq_num + 'd1;
end

always @ (posedge i_clk)begin
    if(rd_reset)
        data_last <= 1'b0;
    else if(seq_num == CHIP_DW-1)
        data_last <= 1'b1;
    else
        data_last <= 1'b0;
end

//------------------------------------------------------------------------------------------
// RAM BLOCK FOR CPRI DATA FOR 8 SYMBOLS 
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
    .wr_rst                                             (cpri_reset             ),
    .wr_clk                                             (i_cpri_clk             ),
    .rd_rst                                             (rd_reset               ),
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
reg            [4:0][RDATA_WIDTH-1: 0]          rx_data_out           =0;
reg            [   4:0][6:0]                    tx_addr_out           =0;
reg            [   4: 0]                        tvalid_out            =0;
reg            [   4: 0]                        txlast_out            =0;
reg            [   9: 0]                        symb_1st_out          =0;
reg            [3:0][63: 0]                     rd_info_buf           =0;
reg            [2:0][RADDR_WIDTH-1: 0]          rd_addr_buf           =0;
reg            [  31: 0]                        fft_agc               =0;
reg            [   4: 0]                        symb_eop_out          =0;
wire                                            symb_eop                ;

//--------------------------------------------------------------------------------------
// debug 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    symb_1st_out<= {symb_1st_out[8:0], ~sym1_done};
end

always @(posedge i_clk) begin
    if(seq_num == 3)begin
        slot_idx_out <= rd_data[18:12];
        symb_idx_out <= rd_data[11: 8];
    end
end

//--------------------------------------------------------------------------------------
// FFT AGC
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(rd_en)
        rd_info_buf[0] <= rd_info;
    else
        rd_info_buf[0] <= rd_info_buf[0];

    for(int i=1; i<4; i=i+1)begin
        rd_info_buf[i] <= rd_info_buf[i-1];
    end
end


always @(posedge i_clk) begin
    rd_addr_buf[0] <= rd_addr;
    for(int i=1; i<3; i=i+1)begin
        rd_addr_buf[i] <= rd_addr_buf[i-1];
    end
end

always @(posedge i_clk) begin
    if(rd_addr_buf[2] == 'd4)
        fft_agc <= rd_data[63:32];
    else if(rd_addr_buf[2] == 'd1540) //1636
        fft_agc <= rd_data[31: 0];
end

assign symb_eop = (rd_addr_buf[2] == 'd3167) ? 1'b1 : 1'b0;

always @(posedge i_clk) begin
    if(rd_reset)
        symb_eop_out <= 'd0;
    else
        symb_eop_out <= {symb_eop_out[3:0], symb_eop};
end

//--------------------------------------------------------------------------------------
// Ouput delay match 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk)begin
    rx_data_out[0] <= rd_data[RDATA_WIDTH-1:0];
    tx_addr_out[0] <= seq_num;
    for(int i=1; i<5; i=i+1)begin
        rx_data_out[i] <= rx_data_out[i-1];
        tx_addr_out[i] <= tx_addr_out[i-1];
    end

    if(rd_reset)begin
        tvalid_out  <= 'd0;
        txlast_out  <= 'd0;
    end else begin
        tvalid_out  <= {tvalid_out [3:0], rd_en_buf[2]};
        txlast_out  <= {txlast_out [3:0], data_last};
    end 
end


assign o_tx_data  = rx_data_out[0];
assign o_tx_addr  = tx_addr_out[0];
assign o_tvalid   = tvalid_out [0];
assign o_tx_last  = txlast_out [0];
assign o_fft_agc  = rd_info_buf[3];
assign o_symb_eop = symb_eop_out[0];

assign o_tready   = (free_size==0) ? 1'b0 : 1'b1;
assign o_rd_vld   = rd_vld;
assign o_rx_sop   = rx_sop;

assign o_symb_1st = symb_1st_out[5];
assign o_symb_clr = symb_clr;


endmodule