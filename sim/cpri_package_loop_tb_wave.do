onerror {resume}
quietly virtual function -install /cpri_package_loop_tb/uut -env /cpri_package_loop_tb { &{/cpri_package_loop_tb/uut/ant_package[0][13], /cpri_package_loop_tb/uut/ant_package[0][12], /cpri_package_loop_tb/uut/ant_package[0][11], /cpri_package_loop_tb/uut/ant_package[0][10], /cpri_package_loop_tb/uut/ant_package[0][9], /cpri_package_loop_tb/uut/ant_package[0][8], /cpri_package_loop_tb/uut/ant_package[0][7] }} ii
quietly virtual function -install /cpri_package_loop_tb/uut -env /cpri_package_loop_tb { &{/cpri_package_loop_tb/uut/ant_package[0][6], /cpri_package_loop_tb/uut/ant_package[0][5], /cpri_package_loop_tb/uut/ant_package[0][4], /cpri_package_loop_tb/uut/ant_package[0][3], /cpri_package_loop_tb/uut/ant_package[0][2], /cpri_package_loop_tb/uut/ant_package[0][1], /cpri_package_loop_tb/uut/ant_package[0][0] }} qq
quietly virtual signal -install /cpri_package_loop_tb/uut { /cpri_package_loop_tb/uut/cpri_iq_data[13:7]} i0
quietly virtual signal -install /cpri_package_loop_tb/uut { /cpri_package_loop_tb/uut/cpri_iq_data[6:0]} q0
quietly virtual function -install /cpri_package_loop_tb -env /cpri_package_loop_tb { &{/cpri_package_loop_tb/pkg_data[13], /cpri_package_loop_tb/pkg_data[12], /cpri_package_loop_tb/pkg_data[11], /cpri_package_loop_tb/pkg_data[10], /cpri_package_loop_tb/pkg_data[9], /cpri_package_loop_tb/pkg_data[8], /cpri_package_loop_tb/pkg_data[7] }} i1
quietly virtual function -install /cpri_package_loop_tb -env /cpri_package_loop_tb { &{/cpri_package_loop_tb/pkg_data[6], /cpri_package_loop_tb/pkg_data[5], /cpri_package_loop_tb/pkg_data[4], /cpri_package_loop_tb/pkg_data[3], /cpri_package_loop_tb/pkg_data[2], /cpri_package_loop_tb/pkg_data[1], /cpri_package_loop_tb/pkg_data[0] }} q1
quietly virtual function -install /cpri_package_loop_tb/uut -env /cpri_package_loop_tb { &{/cpri_package_loop_tb/uut/data_unpack[0][31], /cpri_package_loop_tb/uut/data_unpack[0][30], /cpri_package_loop_tb/uut/data_unpack[0][29], /cpri_package_loop_tb/uut/data_unpack[0][28], /cpri_package_loop_tb/uut/data_unpack[0][27], /cpri_package_loop_tb/uut/data_unpack[0][26], /cpri_package_loop_tb/uut/data_unpack[0][25], /cpri_package_loop_tb/uut/data_unpack[0][24], /cpri_package_loop_tb/uut/data_unpack[0][23], /cpri_package_loop_tb/uut/data_unpack[0][22], /cpri_package_loop_tb/uut/data_unpack[0][21], /cpri_package_loop_tb/uut/data_unpack[0][20], /cpri_package_loop_tb/uut/data_unpack[0][19], /cpri_package_loop_tb/uut/data_unpack[0][18], /cpri_package_loop_tb/uut/data_unpack[0][17], /cpri_package_loop_tb/uut/data_unpack[0][16] }} upk_i0
quietly virtual function -install /cpri_package_loop_tb/uut -env /cpri_package_loop_tb { &{/cpri_package_loop_tb/uut/data_unpack[0][15], /cpri_package_loop_tb/uut/data_unpack[0][14], /cpri_package_loop_tb/uut/data_unpack[0][13], /cpri_package_loop_tb/uut/data_unpack[0][12], /cpri_package_loop_tb/uut/data_unpack[0][11], /cpri_package_loop_tb/uut/data_unpack[0][10], /cpri_package_loop_tb/uut/data_unpack[0][9], /cpri_package_loop_tb/uut/data_unpack[0][8], /cpri_package_loop_tb/uut/data_unpack[0][7], /cpri_package_loop_tb/uut/data_unpack[0][6], /cpri_package_loop_tb/uut/data_unpack[0][5], /cpri_package_loop_tb/uut/data_unpack[0][4], /cpri_package_loop_tb/uut/data_unpack[0][3], /cpri_package_loop_tb/uut/data_unpack[0][2], /cpri_package_loop_tb/uut/data_unpack[0][1], /cpri_package_loop_tb/uut/data_unpack[0][0] }} upk_q0
quietly virtual signal -install /cpri_package_loop_tb/ant_data_buffer { /cpri_package_loop_tb/ant_data_buffer/even_rdata[15:0]} even_q0
quietly virtual signal -install /cpri_package_loop_tb/ant_data_buffer { /cpri_package_loop_tb/ant_data_buffer/even_rdata[31:16]} even_i0
quietly virtual signal -install /cpri_package_loop_tb/ant_data_buffer { /cpri_package_loop_tb/ant_data_buffer/odd_rdata[15:0]} odd_q0
quietly virtual signal -install /cpri_package_loop_tb/ant_data_buffer { /cpri_package_loop_tb/ant_data_buffer/odd_rdata[31:16]} odd_i0
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpri_package_loop_tb/i_clk
add wave -noupdate /cpri_package_loop_tb/reset
add wave -noupdate /cpri_package_loop_tb/tx_hfp
add wave -noupdate -radix unsigned /cpri_package_loop_tb/tx_seq
add wave -noupdate /cpri_package_loop_tb/package_data/i_vld
add wave -noupdate /cpri_package_loop_tb/package_data/i_sop
add wave -noupdate /cpri_package_loop_tb/package_data/i_eop
add wave -noupdate /cpri_package_loop_tb/sym_num
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{(6) -radix decimal} {(5) -radix decimal} {(4) -radix decimal} {(3) -radix decimal} {(2) -radix decimal} {(1) -radix decimal} {(0) -radix decimal}} -subitemconfig {{/cpri_package_loop_tb/pkg_data[13]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/pkg_data[12]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/pkg_data[11]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/pkg_data[10]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/pkg_data[9]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/pkg_data[8]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/pkg_data[7]} {-color {Orange Red} -radix decimal}} /cpri_package_loop_tb/i1
add wave -noupdate -color {Orange Red} -radix decimal /cpri_package_loop_tb/q1
add wave -noupdate /cpri_package_loop_tb/pkg_data
add wave -noupdate -radix unsigned /cpri_package_loop_tb/re_num
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/i_pkg0_data
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/i_pkg0_shift
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/free_size
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/rbadr
add wave -noupdate -group package_tx -radix unsigned /cpri_package_loop_tb/package_data/u_pkg_ram/rd_addr
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/rd_data
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/rd_rdy
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/rd_vld
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/wbadr
add wave -noupdate -group package_tx -radix unsigned /cpri_package_loop_tb/package_data/u_pkg_ram/wr_addr
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/wr_data
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/wr_full
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/rd_empty
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/wr_wen
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/wr_wlast
add wave -noupdate -group package_tx -radix unsigned /cpri_package_loop_tb/prb_num
add wave -noupdate -group package_tx -color Violet /cpri_package_loop_tb/package_data/pkg_sel_1
add wave -noupdate -group package_tx -radix unsigned /cpri_package_loop_tb/package_data/i_pkg0_prb_idx
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/pkg_head
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/ant0_shift
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/u_pkg_ram/wr_info
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/pkg_rinfo
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/cpri_head0
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/cpri_head1
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/cpri_head2
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/cpri_head3
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/a0_data
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/a0_pkg_data
add wave -noupdate -group package_tx -color {Indian Red} /cpri_package_loop_tb/package_data/o_cpri_wdata
add wave -noupdate -group package_tx -color {Indian Red} -radix unsigned /cpri_package_loop_tb/package_data/o_cpri_waddr
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/o_cpri_wen
add wave -noupdate -group package_tx /cpri_package_loop_tb/package_data/o_cpri_wlast
add wave -noupdate -group package_tx /cpri_package_loop_tb/u_cpri_tx_gen/o_iq_tx_data
add wave -noupdate -group package_tx /cpri_package_loop_tb/u_cpri_tx_gen/o_iq_tx_valid
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/i_rx_data
add wave -noupdate -expand -group cpri_rx_buffer -radix unsigned /cpri_package_loop_tb/uut/cpri_rxdata_buffer/i_rx_seq
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/wr_wen
add wave -noupdate -expand -group cpri_rx_buffer -color Violet -radix unsigned /cpri_package_loop_tb/uut/cpri_rxdata_buffer/wr_addr
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/wr_data
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/data_vld
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/i_rready
add wave -noupdate -expand -group cpri_rx_buffer -color Violet -radix unsigned /cpri_package_loop_tb/uut/cpri_rxdata_buffer/rd_addr
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/rd_data
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/o_tvalid
add wave -noupdate -expand -group cpri_rx_buffer -radix unsigned /cpri_package_loop_tb/uut/cpri_rxdata_buffer/o_tx_addr
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/o_tx_last
add wave -noupdate -expand -group cpri_rx_buffer /cpri_package_loop_tb/uut/cpri_rxdata_buffer/o_tx_data
add wave -noupdate /cpri_package_loop_tb/uut/i_cpri_rx_data
add wave -noupdate -radix unsigned /cpri_package_loop_tb/uut/i_cpri_rx_seq
add wave -noupdate /cpri_package_loop_tb/uut/cpri_iq_vld
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/i_rready
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/cpri_rdy
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/cpri_rvld
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/rd_valid
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/o_tready
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/wr_wen
add wave -noupdate -color Pink -radix unsigned /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/wbadr
add wave -noupdate -radix unsigned /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/wr_addr
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/wr_data
add wave -noupdate -color Pink -radix unsigned /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/rbadr
add wave -noupdate -radix unsigned /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/rd_addr
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/rd_data
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/free_size
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/rd_empty
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/wr_full
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/u_fifo_buffer_64w_16d_0/dout_valid
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/u_fifo_buffer_64w_16d_0/wr_en
add wave -noupdate /cpri_package_loop_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/u_fifo_buffer_64w_16d_0/rd_en
add wave -noupdate -radix decimal -childformat {{{/cpri_package_loop_tb/uut/i0[13]} -radix decimal} {{/cpri_package_loop_tb/uut/i0[12]} -radix decimal} {{/cpri_package_loop_tb/uut/i0[11]} -radix decimal} {{/cpri_package_loop_tb/uut/i0[10]} -radix decimal} {{/cpri_package_loop_tb/uut/i0[9]} -radix decimal} {{/cpri_package_loop_tb/uut/i0[8]} -radix decimal} {{/cpri_package_loop_tb/uut/i0[7]} -radix decimal}} -subitemconfig {{/cpri_package_loop_tb/uut/cpri_iq_data[13]} {-radix decimal} {/cpri_package_loop_tb/uut/cpri_iq_data[12]} {-radix decimal} {/cpri_package_loop_tb/uut/cpri_iq_data[11]} {-radix decimal} {/cpri_package_loop_tb/uut/cpri_iq_data[10]} {-radix decimal} {/cpri_package_loop_tb/uut/cpri_iq_data[9]} {-radix decimal} {/cpri_package_loop_tb/uut/cpri_iq_data[8]} {-radix decimal} {/cpri_package_loop_tb/uut/cpri_iq_data[7]} {-radix decimal}} /cpri_package_loop_tb/uut/i0
add wave -noupdate -radix decimal /cpri_package_loop_tb/uut/q0
add wave -noupdate -color Gold -subitemconfig {{/cpri_package_loop_tb/uut/cpri_iq_data[63]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[62]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[61]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[60]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[59]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[58]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[57]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[56]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[55]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[54]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[53]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[52]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[51]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[50]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[49]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[48]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[47]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[46]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[45]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[44]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[43]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[42]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[41]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[40]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[39]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[38]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[37]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[36]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[35]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[34]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[33]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[32]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[31]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[30]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[29]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[28]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[27]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[26]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[25]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[24]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[23]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[22]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[21]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[20]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[19]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[18]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[17]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[16]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[15]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[14]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[13]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[12]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[11]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[10]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[9]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[8]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[7]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[6]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[5]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[4]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[3]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[2]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[1]} {-color Gold} {/cpri_package_loop_tb/uut/cpri_iq_data[0]} {-color Gold}} /cpri_package_loop_tb/uut/cpri_iq_data
add wave -noupdate -color Gold -radix unsigned /cpri_package_loop_tb/uut/cpri_iq_raddr
add wave -noupdate -color {Medium Orchid} -radix unsigned /cpri_package_loop_tb/uut/re_cnt_cycle
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{(6) -radix decimal} {(5) -radix decimal} {(4) -radix decimal} {(3) -radix decimal} {(2) -radix decimal} {(1) -radix decimal} {(0) -radix decimal}} -subitemconfig {{/cpri_package_loop_tb/uut/ant_package[0][13]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/ant_package[0][12]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/ant_package[0][11]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/ant_package[0][10]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/ant_package[0][9]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/ant_package[0][8]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/ant_package[0][7]} {-color {Orange Red} -radix decimal}} /cpri_package_loop_tb/uut/ii
add wave -noupdate -color {Orange Red} -radix decimal /cpri_package_loop_tb/uut/qq
add wave -noupdate /cpri_package_loop_tb/uut/rb_agc
add wave -noupdate /cpri_package_loop_tb/uut/ant_package_valid
add wave -noupdate -radix unsigned /cpri_package_loop_tb/uut/re_cnt_prb
add wave -noupdate -color {Medium Orchid} -radix unsigned /cpri_package_loop_tb/uut/prb_cnt
add wave -noupdate /cpri_package_loop_tb/uut/prb_cnt_cycle
add wave -noupdate -expand /cpri_package_loop_tb/uut/ant_package
add wave -noupdate -expand /cpri_package_loop_tb/uut/rb_shift
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{(15) -radix decimal} {(14) -radix decimal} {(13) -radix decimal} {(12) -radix decimal} {(11) -radix decimal} {(10) -radix decimal} {(9) -radix decimal} {(8) -radix decimal} {(7) -radix decimal} {(6) -radix decimal} {(5) -radix decimal} {(4) -radix decimal} {(3) -radix decimal} {(2) -radix decimal} {(1) -radix decimal} {(0) -radix decimal}} -subitemconfig {{/cpri_package_loop_tb/uut/data_unpack[0][31]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][30]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][29]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][28]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][27]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][26]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][25]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][24]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][23]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][22]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][21]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][20]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][19]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][18]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][17]} {-color {Orange Red} -radix decimal} {/cpri_package_loop_tb/uut/data_unpack[0][16]} {-color {Orange Red} -radix decimal}} /cpri_package_loop_tb/uut/upk_i0
add wave -noupdate -color {Orange Red} -radix decimal /cpri_package_loop_tb/uut/upk_q0
add wave -noupdate /cpri_package_loop_tb/uut/data_unpack
add wave -noupdate /cpri_package_loop_tb/uut/data_unpack_vld
add wave -noupdate -radix unsigned /cpri_package_loop_tb/uut/iq_addr
add wave -noupdate /cpri_package_loop_tb/uut/prb_reached_132
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/ant_sel
add wave -noupdate -expand -group ant_data_buffer -color {Orange Red} -radix unsigned /cpri_package_loop_tb/ant_data_buffer/wr_addr
add wave -noupdate -expand -group ant_data_buffer -color {Orange Red} /cpri_package_loop_tb/ant_data_buffer/wr_data
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/u_ram_even/wbadr
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/u_ram_odd/wbadr
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/u_ram_even/rbadr
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/u_ram_odd/rbadr
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/wr_wen_even
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/wr_wen_odd
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/wr_wlast_even
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/wr_wlast_odd
add wave -noupdate -expand -group ant_data_buffer -color {Orange Red} -radix decimal /cpri_package_loop_tb/ant_data_buffer/even_i0
add wave -noupdate -expand -group ant_data_buffer -color {Orange Red} -radix decimal /cpri_package_loop_tb/ant_data_buffer/even_q0
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/even_rdata
add wave -noupdate -expand -group ant_data_buffer -color {Orange Red} -radix decimal /cpri_package_loop_tb/ant_data_buffer/odd_q0
add wave -noupdate -expand -group ant_data_buffer -color {Orange Red} -radix decimal /cpri_package_loop_tb/ant_data_buffer/odd_i0
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/odd_rdata
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/even_rvld
add wave -noupdate -expand -group ant_data_buffer -radix unsigned /cpri_package_loop_tb/ant_data_buffer/sync_raddr
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/sync_rd_rdy
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/o_ant_even
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/odd_rvld
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/o_tvalid
add wave -noupdate -expand -group ant_data_buffer /cpri_package_loop_tb/ant_data_buffer/o_ant_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3230555 ps} 0} {{Cursor 2} {55125000 ps} 0} {{Cursor 3} {21125000 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 351
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {21083867 ps} {21176659 ps}