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

module cpri_rxdata_unpack # (
    parameter DW     = 32,
    parameter ANT    = 4 
)(
    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_cpri_clk              ,
    input                                           i_cpri_rst              ,
    input          [  63: 0]                        i_cpri_rx_data          ,
    input                                           i_cpri_rx_vld           ,

    output         [   3: 0]                        o_pkg_type              ,
    output         [   6: 0]                        o_slot_idx              ,
    output         [   3: 0]                        o_symb_idx              ,
    output                                          o_cell_idx              ,
    output         [  63: 0]                        o_info_0                ,
    output         [  63: 0]                        o_info_1                ,
    output         [  10: 0]                        o_iq_addr               ,
    output         [ANT*32-1: 0]                    o_iq_data               ,
    output                                          o_iq_vld                ,
    output                                          o_iq_last                
);


//--------------------------------------------------------------------------------------
// PARAMETERS
//--------------------------------------------------------------------------------------
genvar ant;


//--------------------------------------------------------------------------------------
// WIRE AND REGISTER
//--------------------------------------------------------------------------------------
wire                                            re_reached_12           ;
reg                                             fifo_wr_en            =0;
reg            [20:0][63: 0]                    data_rx_buf           ='{default:0};
reg            [   2: 0]                        re_cnt_cycle          =0;
wire           [   7: 0]                        cpri_iq_raddr           ;
reg            [   7: 0]                        prb_cnt               =0;
reg            [   7: 0]                        re_cnt_prb            =0;
reg            [ 127: 0]                        rb_agc                =0;
wire           [3:0][31: 0]                     data_unpack             ;
wire           [3:0][15: 0]                     data_unpack_i           ;
wire           [3:0][15: 0]                     data_unpack_q           ;

// agc
reg            [   7: 0]                        prb_valid             =0;

// rom
reg            [ANT-1:0][12*32-1: 0]            wdata                 =0;
wire           [ANT-1:0][12*32-1: 0]            rdata                   ;
reg            [ANT-1: 0]                       wen                   =0;
reg            [ANT-1: 0]                       ren                   =0;
reg            [ANT-1:0][7: 0]                  waddr                 =0;
reg            [ANT-1:0][7: 0]                  raddr                 =0;

reg                                             prb_reached_132       =0;

wire           [ 255: 0]                        cpri_rx_info            ;
wire           [  63: 0]                        cpri_iq_data            ;
reg            [  63: 0]                        cpri_iq_data_r1       =0;
wire                                            cpri_iq_vld             ;
wire                                            unpack_ready            ;
reg            [   1: 0]                        unpack_vld_buf        =0;
reg                                             ant_package_valid     =0;
reg                                             data_unpack_vld       =0;
reg            [3:0][13: 0]                     ant_package           ='{default:0};
reg            [3:0][3: 0]                      rb_shift              ='{default:0};
reg            [   2: 0]                        prb_cnt_cycle         =0;
reg            [  10: 0]                        iq_addr               =0;


wire           [  63: 0]                        cpri_data_buf           ;
wire           [   6: 0]                        cpri_addr_buf           ;
wire                                            cpri_buf_vld            ;
wire                                            cpri_buf_last           ;


reg            [   3: 0]                        rx_vld_buf            =0;
reg            [   3: 0]                        symb_idx              =0;
reg                                             rx_vld                =0;
reg            [3:0][63: 0]                     rx_data_buf           =0;
reg            [  63: 0]                        cpri_rx_data          =0;
reg                                             cpri_rx_vld           =0;




always @(posedge i_clk) begin
    rx_vld_buf[3:0] <= {rx_vld_buf[2:0],i_cpri_rx_vld};
    if(rx_vld_buf[2])
        symb_idx <= i_cpri_rx_data[11:8];
end

always @(posedge i_clk) begin
    cpri_rx_vld <= rx_vld_buf[3];
    if(symb_idx ==0 && rx_vld_buf[3])
        rx_vld <= 1'b1;
end

always @(posedge i_clk) begin
    rx_data_buf[0] <= i_cpri_rx_data;
    cpri_rx_data   <= rx_data_buf[3];
    for(int i=1; i<4; i=i+1)begin
        rx_data_buf[i] <= rx_data_buf[i-1];
    end 
end


//--------------------------------------------------------------------------------------
// cpri rx data buffer
//--------------------------------------------------------------------------------------
cpri_rxdata_buffer                                      cpri_rxdata_buffer
(
    .i_clk                                              (i_cpri_clk             ),
    .i_reset                                            (i_cpri_rst             ),
    .i_rx_data                                          (cpri_rx_data           ),
    .i_rvalid                                           (cpri_rx_vld            ),
    .i_rready                                           (cpri_rx_ready          ),
    .i_sym1_done                                        (1'b0                   ),
    .o_tx_data                                          (cpri_data_buf          ),
    .o_tx_addr                                          (cpri_addr_buf          ),
    .o_tx_last                                          (cpri_buf_last          ),
    .o_tvalid                                           (cpri_buf_vld           ) 
);



//--------------------------------------------------------------------------------------
// cpri data rx generator 
//--------------------------------------------------------------------------------------
cpri_rx_gen                                             u_cpri_rx_gen
(
    .wr_clk                                             (i_cpri_clk             ),
    .wr_rst                                             (i_cpri_rst             ),
    .rd_clk                                             (i_clk                  ),
    .rd_rst                                             (i_reset                ),
    .i_cpri_wen                                         (cpri_buf_vld           ),
    .i_cpri_waddr                                       (cpri_addr_buf          ),
    .i_cpri_wdata                                       (cpri_data_buf          ),
    .i_cpri_wlast                                       (cpri_buf_last          ),
    .i_rready                                           (unpack_ready           ),
    .i_rx_enable                                        (1'b1                   ),
    .o_tvalid                                           (cpri_iq_vld            ),
    .o_tready                                           (cpri_rx_ready          ),
    .o_iq_raddr                                         (cpri_iq_raddr          ),
    .o_rx_info                                          (cpri_rx_info           ),
    .o_iq_rx_data                                       (cpri_iq_data           ) 
);


//--------------------------------------------------------------------------------------
// assignment for re_reached_12
//--------------------------------------------------------------------------------------
assign re_reached_12    = (re_cnt_prb==11) ? 1'b1 : 1'b0;

//--------------------------------------------------------------------------------------
// generate DW number 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    ant_package_valid <= cpri_iq_vld;
end

always @(posedge i_clk) begin
    if(re_reached_12)
        re_cnt_prb <= 8'd0;
    else if(ant_package_valid)
        re_cnt_prb <= re_cnt_prb + 8'd1;
end

assign unpack_ready = (re_cnt_cycle==7'd3) ? 1'b0 : 1'b1;
//assign unpack_ready = 1'b1;

always @(posedge i_clk) begin
    if(cpri_iq_vld)
        re_cnt_cycle <= re_cnt_cycle + 3'd1;
    else
        re_cnt_cycle <= re_cnt_cycle;
end

//--------------------------------------------------------------------------------------
// generate prb number
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    if(re_reached_12)begin
        if(prb_cnt == 8'd131) 
            prb_cnt <= 8'd0;
        else
            prb_cnt <= prb_cnt + 8'd1;
    end
end


always @(posedge i_clk) begin
    if(i_reset)
        prb_cnt_cycle <= 0;
    else if(re_reached_12)begin
        prb_cnt_cycle <= prb_cnt_cycle + 3'd1;
    end
end

//--------------------------------------------------------------------------------------
// unpack compressed ant data from cpri data 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    cpri_iq_data_r1 <= cpri_iq_data;
end

generate
    for(ant=0; ant<ANT; ant++) begin: unpack_ant_data
        always @(posedge i_clk) begin
            case(re_cnt_cycle)
                3'd0:       ant_package[ant] <=  cpri_iq_data[ant*16 +: 14];
                3'd1:       ant_package[ant] <= {cpri_iq_data[ant*16 +: 12],cpri_iq_data_r1[ant*16+15 : ant*16+14]};
                3'd2:       ant_package[ant] <= {cpri_iq_data[ant*16 +: 10],cpri_iq_data_r1[ant*16+15 : ant*16+12]};
                3'd3:       ant_package[ant] <= {cpri_iq_data[ant*16 +:  8],cpri_iq_data_r1[ant*16+15 : ant*16+10]};
                3'd4:       ant_package[ant] <= {cpri_iq_data[ant*16 +:  6],cpri_iq_data_r1[ant*16+15 : ant*16+ 8]};
                3'd5:       ant_package[ant] <= {cpri_iq_data[ant*16 +:  4],cpri_iq_data_r1[ant*16+15 : ant*16+ 6]};
                3'd6:       ant_package[ant] <= {cpri_iq_data[ant*16 +:  2],cpri_iq_data_r1[ant*16+15 : ant*16+ 4]};
                3'd7:       ant_package[ant] <=  cpri_iq_data[ant*16+15 : ant*16+2];
                default:    ant_package[ant] <=  0;
            endcase
        end
    end
endgenerate


//--------------------------------------------------------------------------------------
// receive rb agc data
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    rb_agc <= cpri_rx_info[255:128];
end


//--------------------------------------------------------------------------------------
// unpack rb shift data from agc data 
//--------------------------------------------------------------------------------------
generate
    for(ant=0; ant<ANT; ant++) begin: unpack_rb_agc
        always @( * ) begin
            case(prb_cnt_cycle)
                3'd0:       rb_shift[ant] = rb_agc[ant*32 + 4*0 +: 4]; 
                3'd1:       rb_shift[ant] = rb_agc[ant*32 + 4*1 +: 4]; 
                3'd2:       rb_shift[ant] = rb_agc[ant*32 + 4*2 +: 4]; 
                3'd3:       rb_shift[ant] = rb_agc[ant*32 + 4*3 +: 4]; 
                3'd4:       rb_shift[ant] = rb_agc[ant*32 + 4*4 +: 4]; 
                3'd5:       rb_shift[ant] = rb_agc[ant*32 + 4*5 +: 4]; 
                3'd6:       rb_shift[ant] = rb_agc[ant*32 + 4*6 +: 4]; 
                3'd7:       rb_shift[ant] = rb_agc[ant*32 + 4*7 +: 4]; 
                default:    rb_shift[ant] = rb_agc[ant*32 + 4*0 +: 4]; 
            endcase
        end
    end
endgenerate

//--------------------------------------------------------------------------------------
// data uncompress logic
//--------------------------------------------------------------------------------------
generate
    for(ant=0; ant<ANT; ant++) begin: data_unpack_inst
        decompress_bit # (
            .SHIFT_WIDTH                                        (4                      ),
            .DATA_WIDTH                                         (7                      ),
            .DECM_WIDTH                                         (16                     ) 
        )decompress_bit_i (
            .clk                                                (i_clk                  ),
            .i_cpmr_agc                                         (rb_shift[ant]          ),
            .i_cpmr_din                                         (ant_package[ant][13:7] ),
            .o_cpmr_dout                                        (data_unpack_i[ant]     ) 
        );

        decompress_bit # (
            .SHIFT_WIDTH                                        (4                      ),
            .DATA_WIDTH                                         (7                      ),
            .DECM_WIDTH                                         (16                     ) 
        )decompress_bit_q (
            .clk                                                (i_clk                  ),
            .i_cpmr_agc                                         (rb_shift[ant]          ),
            .i_cpmr_din                                         (ant_package[ant][ 6:0] ),
            .o_cpmr_dout                                        (data_unpack_q[ant]     ) 
        );

        assign data_unpack[ant] = {data_unpack_i[ant],data_unpack_q[ant]};
    end
endgenerate



//--------------------------------------------------------------------------------------
// receive header data
//--------------------------------------------------------------------------------------
wire           [  63: 0]                        header_info_0           ;
wire           [  63: 0]                        header_info_1           ;
reg            [3:0][63:0]                      dout_info0            =0;
reg            [3:0][63:0]                      dout_info1            =0;

assign header_info_0 = cpri_rx_info[63:0];
assign header_info_1 = cpri_rx_info[127:64];


//--------------------------------------------------------------------------------------
// generate valid 
//--------------------------------------------------------------------------------------
always @ (posedge i_clk) begin
    if(prb_cnt==131 && re_reached_12)
        prb_reached_132 <= 1;
    else
        prb_reached_132 <= 0;
end

always @(posedge i_clk) begin
    unpack_vld_buf  <= {unpack_vld_buf[0],ant_package_valid};
    data_unpack_vld <= unpack_vld_buf[1];
end

always @(posedge i_clk) begin
    if(i_reset)
        iq_addr <= 0;
    else if(iq_addr == 'd1583)
        iq_addr <= 0;
    else if(data_unpack_vld)
        iq_addr <= iq_addr + 'd1;
    else
        iq_addr <= iq_addr;
end


//--------------------------------------------------------------------------------------
// output 
//--------------------------------------------------------------------------------------
reg            [ANT*32-1: 0]                    iq_data_out           =0;
reg                                             iq_vld_out            =0;
reg                                             iq_last_out           =0;
reg            [  10: 0]                        iq_addr_out           =0;


always @(posedge i_clk) begin
    for(int i=0; i<ANT; i++)begin
        if(data_unpack_vld) begin
            iq_data_out[i*32 +: 32] <= data_unpack[i];
        end
    end
end

always @(posedge i_clk) begin
    iq_vld_out  <= data_unpack_vld;
    iq_addr_out <= iq_addr;
    if(iq_addr == 'd1583)
        iq_last_out <= 1;
    else
        iq_last_out <= 0;
end

always @(posedge i_clk) begin
    dout_info0[0] <= header_info_0;
    dout_info1[0] <= header_info_1;
    for(int i=1; i<4; i++)begin
        dout_info0[i] <= dout_info0[i-1];
        dout_info1[i] <= dout_info1[i-1];
    end
end

reg            [   3: 0]                        pkg_type_out          =0;
reg                                             cell_idx_out          =0;
reg            [   6: 0]                        slot_idx_out          =0;
reg            [   3: 0]                        symb_idx_out          =0;

always @(posedge i_clk) begin
    pkg_type_out <= dout_info0[3][39:36];
    cell_idx_out <= dout_info0[3][19];
    slot_idx_out <= dout_info0[3][18:12];
    symb_idx_out <= dout_info0[3][11:8];
end


assign o_iq_data = iq_data_out;
assign o_iq_addr = iq_addr_out;
assign o_iq_vld  = iq_vld_out;
assign o_iq_last = iq_last_out;
assign o_info_0  = dout_info0;
assign o_info_1  = dout_info1;
assign o_pkg_type = pkg_type_out;
assign o_cell_idx = cell_idx_out;
assign o_slot_idx = slot_idx_out;
assign o_symb_idx = symb_idx_out;


endmodule