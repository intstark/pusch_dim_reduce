onerror {resume}
quietly virtual signal -install /pdsch_dim_reduction_tb/pdsch_dim_reduction { /pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][95:48]} b0_i
quietly virtual signal -install /pdsch_dim_reduction_tb/pdsch_dim_reduction { /pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][47:0]} b0_q
quietly virtual signal -install /pdsch_dim_reduction_tb/pdsch_dim_reduction {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[0]  } acc_b0_i
quietly virtual signal -install /pdsch_dim_reduction_tb/pdsch_dim_reduction {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0]  } acc_b0_q
quietly WaveActivateNextPane {} 0
add wave -noupdate /pdsch_dim_reduction_tb/i_clk
add wave -noupdate /pdsch_dim_reduction_tb/reset
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/re_num
add wave -noupdate /pdsch_dim_reduction_tb/pkg_data
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/prb_num
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/sym_num
add wave -noupdate /pdsch_dim_reduction_tb/tx_data
add wave -noupdate /pdsch_dim_reduction_tb/tx_eop
add wave -noupdate /pdsch_dim_reduction_tb/tx_hfp
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/tx_seq
add wave -noupdate /pdsch_dim_reduction_tb/tx_sop
add wave -noupdate /pdsch_dim_reduction_tb/tx_vld
add wave -noupdate /pdsch_dim_reduction_tb/tx_x
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/i_code_word_even
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/i_code_word_odd
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_data
add wave -noupdate -radix unsigned -childformat {{{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[6]} -radix unsigned} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[5]} -radix unsigned} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[4]} -radix unsigned} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[3]} -radix unsigned} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[2]} -radix unsigned} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[1]} -radix unsigned} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[0]} -radix unsigned}} -subitemconfig {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[6]} {-height 15 -radix unsigned} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[5]} {-height 15 -radix unsigned} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[4]} {-height 15 -radix unsigned} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[3]} {-height 15 -radix unsigned} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[2]} {-height 15 -radix unsigned} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[1]} {-height 15 -radix unsigned} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq[0]} {-height 15 -radix unsigned}} /pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_seq
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/i_cpri_rx_vld
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/i_rbg_size
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/pdsch_dim_reduction/re_num_per_rbg
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_tvalid
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_tvld_pos
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_tvld_neg
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_blk_num
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_slip
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/i_rready}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/rd_data}
add wave -noupdate -expand -group ant0b0_buffer -radix unsigned {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/seq_num}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/i_sym1_done}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/sym1_done}
add wave -noupdate -expand -group ant0b0_buffer -radix unsigned {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/rd_sym_num}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/rbadr}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/rd_rlast}
add wave -noupdate -expand -group ant0b0_buffer -radix unsigned {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/rd_addr}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/rd_rdy}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/wbadr}
add wave -noupdate -expand -group ant0b0_buffer -radix unsigned {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/wr_addr}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/wr_wen}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/wr_wlast}
add wave -noupdate -expand -group ant0b0_buffer {/pdsch_dim_reduction_tb/pdsch_dim_reduction/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/u_loop_buffer_sync/free_size}
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/dut_mac_beams/i_ants_data_even
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/dut_mac_beams/i_ants_data_odd
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_load
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/pdsch_dim_reduction/re_num
add wave -noupdate -radix unsigned /pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_num
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[95]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[94]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[93]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[92]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[91]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[90]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[89]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[88]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[87]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[86]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[85]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[84]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[83]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[82]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[81]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[80]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[79]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[78]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[77]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[76]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[75]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[74]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[73]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[72]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[71]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[70]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[69]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[68]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[67]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[66]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[65]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[64]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[63]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[62]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[61]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[60]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[59]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[58]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[57]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[56]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[55]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[54]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[53]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[52]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[51]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[50]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[49]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i[48]} -radix decimal}} -subitemconfig {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][95]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][94]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][93]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][92]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][91]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][90]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][89]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][88]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][87]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][86]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][85]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][84]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][83]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][82]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][81]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][80]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][79]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][78]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][77]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][76]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][75]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][74]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][73]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][72]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][71]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][70]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][69]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][68]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][67]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][66]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][65]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][64]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][63]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][62]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][61]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][60]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][59]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][58]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][57]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][56]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][55]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][54]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][53]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][52]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][51]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][50]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][49]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][48]} {-color {Orange Red} -radix decimal}} /pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_i
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[47]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[46]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[45]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[44]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[43]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[42]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[41]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[40]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[39]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[38]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[37]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[36]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[35]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[34]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[33]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[32]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[31]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[30]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[29]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[28]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[27]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[26]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[25]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[24]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[23]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[22]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[21]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[20]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[19]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[18]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[17]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[16]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[15]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[14]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[13]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[12]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[11]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[10]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[9]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[8]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[7]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[6]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[5]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[4]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[3]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[2]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[1]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q[0]} -radix decimal}} -subitemconfig {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][47]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][46]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][45]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][44]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][43]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][42]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][41]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][40]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][39]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][38]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][37]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][36]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][35]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][34]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][33]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][32]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][31]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][30]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][29]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][28]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][27]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][26]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][25]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][24]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][23]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][22]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][21]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][20]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][19]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][18]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][17]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][16]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][15]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][14]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][13]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][12]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][11]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][10]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][9]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][8]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][7]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][6]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][5]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][4]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][3]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][2]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][1]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants[0][0]} {-color {Orange Red} -radix decimal}} /pdsch_dim_reduction_tb/pdsch_dim_reduction/b0_q
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/beams_sum_ants
add wave -noupdate -color {Orange Red} -label acc_b0i -radix decimal -childformat {{{[47]} -radix decimal} {{[46]} -radix decimal} {{[45]} -radix decimal} {{[44]} -radix decimal} {{[43]} -radix decimal} {{[42]} -radix decimal} {{[41]} -radix decimal} {{[40]} -radix decimal} {{[39]} -radix decimal} {{[38]} -radix decimal} {{[37]} -radix decimal} {{[36]} -radix decimal} {{[35]} -radix decimal} {{[34]} -radix decimal} {{[33]} -radix decimal} {{[32]} -radix decimal} {{[31]} -radix decimal} {{[30]} -radix decimal} {{[29]} -radix decimal} {{[28]} -radix decimal} {{[27]} -radix decimal} {{[26]} -radix decimal} {{[25]} -radix decimal} {{[24]} -radix decimal} {{[23]} -radix decimal} {{[22]} -radix decimal} {{[21]} -radix decimal} {{[20]} -radix decimal} {{[19]} -radix decimal} {{[18]} -radix decimal} {{[17]} -radix decimal} {{[16]} -radix decimal} {{[15]} -radix decimal} {{[14]} -radix decimal} {{[13]} -radix decimal} {{[12]} -radix decimal} {{[11]} -radix decimal} {{[10]} -radix decimal} {{[9]} -radix decimal} {{[8]} -radix decimal} {{[7]} -radix decimal} {{[6]} -radix decimal} {{[5]} -radix decimal} {{[4]} -radix decimal} {{[3]} -radix decimal} {{[2]} -radix decimal} {{[1]} -radix decimal} {{[0]} -radix decimal}} -subitemconfig {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][47]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][46]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][45]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][44]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][43]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][42]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][41]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][40]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][39]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][38]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][37]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][36]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][35]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][34]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][33]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][32]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][31]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][30]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][29]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][28]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][27]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][26]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][25]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][24]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][23]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][22]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][21]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][20]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][19]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][18]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][17]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][16]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][15]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][14]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][13]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][12]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][11]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][10]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][9]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][8]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][7]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][6]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][5]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][4]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][3]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][2]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][1]} {-color {Orange Red} -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0][0]} {-color {Orange Red} -radix decimal}} /pdsch_dim_reduction_tb/pdsch_dim_reduction/acc_b0_q
add wave -noupdate -childformat {{{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[15]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[14]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[13]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[12]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[11]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[10]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[9]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[8]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[7]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[6]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[5]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[4]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[3]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[2]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[1]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0]} -radix decimal}} -subitemconfig {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[15]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[14]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[13]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[12]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[11]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[10]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[9]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[8]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[7]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[6]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[5]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[4]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[3]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[2]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[1]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re[0]} {-height 15 -radix decimal}} /pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_re
add wave -noupdate -color {Orange Red} -label acc_b0q -radix decimal /pdsch_dim_reduction_tb/pdsch_dim_reduction/acc_b0_i
add wave -noupdate -childformat {{{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[15]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[14]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[13]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[12]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[11]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[10]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[9]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[8]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[7]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[6]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[5]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[4]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[3]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[2]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[1]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[0]} -radix decimal}} -subitemconfig {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[15]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[14]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[13]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[12]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[11]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[10]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[9]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[8]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[7]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[6]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[5]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[4]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[3]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[2]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[1]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im[0]} {-height 15 -radix decimal}} /pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_acc_im
add wave -noupdate -childformat {{{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[15]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[14]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[13]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[12]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[11]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[10]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[9]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[8]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[7]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[6]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[5]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[4]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[3]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[2]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[1]} -radix decimal} {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[0]} -radix decimal}} -subitemconfig {{/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[15]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[14]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[13]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[12]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[11]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[10]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[9]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[8]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[7]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[6]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[5]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[4]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[3]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[2]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[1]} {-height 15 -radix decimal} {/pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re[0]} {-height 15 -radix decimal}} /pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_re
add wave -noupdate /pdsch_dim_reduction_tb/pdsch_dim_reduction/rbg_sum_im
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {232798805 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 355
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
WaveRestoreZoom {0 ps} {315 us}