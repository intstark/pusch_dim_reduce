onerror {resume}
quietly virtual signal -install /cpri_rxdata_8lanes_tb { /cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][31:16]} ant1_i
quietly virtual signal -install /cpri_rxdata_8lanes_tb { /cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][15:0]} ant1_q
quietly virtual signal -install /cpri_rxdata_8lanes_tb/dut_mac_beams { /cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[15:0]} buf_q
quietly virtual signal -install /cpri_rxdata_8lanes_tb/dut_mac_beams { /cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[31:16]} buf_i
quietly virtual signal -install /cpri_rxdata_8lanes_tb/dut_mac_beams { /cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[31:16]} odd_i
quietly virtual signal -install /cpri_rxdata_8lanes_tb/dut_mac_beams { /cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[15:0]} odd_q
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpri_rxdata_8lanes_tb/i_clk
add wave -noupdate /cpri_rxdata_8lanes_tb/reset
add wave -noupdate -radix unsigned /cpri_rxdata_8lanes_tb/tx_seq
add wave -noupdate /cpri_rxdata_8lanes_tb/tx_sop
add wave -noupdate /cpri_rxdata_8lanes_tb/tx_eop
add wave -noupdate /cpri_rxdata_8lanes_tb/tx_vld
add wave -noupdate -radix unsigned /cpri_rxdata_8lanes_tb/re_num
add wave -noupdate -radix decimal /cpri_rxdata_8lanes_tb/pkg_data
add wave -noupdate -radix unsigned /cpri_rxdata_8lanes_tb/prb_num
add wave -noupdate -radix unsigned /cpri_rxdata_8lanes_tb/sym_num
add wave -noupdate {/cpri_rxdata_8lanes_tb/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/rd_empty}
add wave -noupdate {/cpri_rxdata_8lanes_tb/gen_rxdata_unpack[0]/cpri_rxdata_unpack_4ant/cpri_rxdata_buffer/wr_full}
add wave -noupdate {/cpri_rxdata_8lanes_tb/gen_rxdata_unpack[7]/cpri_rxdata_unpack_4ant/i_cpri_rx_data}
add wave -noupdate -radix unsigned {/cpri_rxdata_8lanes_tb/gen_rxdata_unpack[7]/cpri_rxdata_unpack_4ant/i_cpri_rx_seq}
add wave -noupdate {/cpri_rxdata_8lanes_tb/gen_rxdata_unpack[7]/cpri_rxdata_unpack_4ant/i_cpri_rx_vld}
add wave -noupdate /cpri_rxdata_8lanes_tb/unpack_iq_data
add wave -noupdate -radix unsigned /cpri_rxdata_8lanes_tb/unpack_iq_addr
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{{/cpri_rxdata_8lanes_tb/ant1_i[31]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[30]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[29]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[28]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[27]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[26]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[25]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[24]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[23]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[22]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[21]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[20]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[19]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[18]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[17]} -radix decimal} {{/cpri_rxdata_8lanes_tb/ant1_i[16]} -radix decimal}} -subitemconfig {{/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][31]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][30]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][29]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][28]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][27]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][26]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][25]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][24]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][23]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][22]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][21]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][20]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][19]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][18]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][17]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/unpack_iq_data[0][0][16]} {-color {Orange Red} -radix decimal}} /cpri_rxdata_8lanes_tb/ant1_i
add wave -noupdate -color {Orange Red} -radix decimal /cpri_rxdata_8lanes_tb/ant1_q
add wave -noupdate /cpri_rxdata_8lanes_tb/unpack_iq_last
add wave -noupdate /cpri_rxdata_8lanes_tb/unpack_iq_vld
add wave -noupdate /cpri_rxdata_8lanes_tb/ant_even
add wave -noupdate /cpri_rxdata_8lanes_tb/ant_odd
add wave -noupdate /cpri_rxdata_8lanes_tb/ant_tvalid
add wave -noupdate -expand -group mac_beams -color {Orange Red} -radix decimal -childformat {{{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[31]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[30]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[29]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[28]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[27]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[26]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[25]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[24]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[23]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[22]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[21]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[20]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[19]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[18]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[17]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i[16]} -radix decimal}} -subitemconfig {{/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[31]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[30]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[29]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[28]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[27]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[26]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[25]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[24]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[23]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[22]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[21]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[20]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[19]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[18]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[17]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even[16]} {-color {Orange Red} -radix decimal}} /cpri_rxdata_8lanes_tb/dut_mac_beams/buf_i
add wave -noupdate -expand -group mac_beams -color {Orange Red} -radix decimal /cpri_rxdata_8lanes_tb/dut_mac_beams/buf_q
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_even
add wave -noupdate -expand -group mac_beams -color {Orange Red} -radix decimal -childformat {{{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[31]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[30]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[29]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[28]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[27]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[26]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[25]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[24]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[23]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[22]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[21]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[20]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[19]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[18]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[17]} -radix decimal} {{/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i[16]} -radix decimal}} -subitemconfig {{/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[31]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[30]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[29]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[28]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[27]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[26]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[25]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[24]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[23]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[22]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[21]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[20]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[19]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[18]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[17]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd[16]} {-color {Orange Red} -radix decimal}} /cpri_rxdata_8lanes_tb/dut_mac_beams/odd_i
add wave -noupdate -expand -group mac_beams -color {Orange Red} -radix decimal /cpri_rxdata_8lanes_tb/dut_mac_beams/odd_q
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/dut_mac_beams/i_ants_data_odd
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/dut_mac_beams/i_code_word_even
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/dut_mac_beams/i_code_word_odd
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/ovalid
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/dut_mac_beams/o_sum_data_even
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/dut_mac_beams/o_sum_data_odd
add wave -noupdate -expand -group mac_beams /cpri_rxdata_8lanes_tb/dut_mac_beams/o_sum_data
add wave -noupdate -expand -group even_b0a0 {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/o_sum_data}
add wave -noupdate -expand -group even_b0a0 {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/o_tvalid}
add wave -noupdate -expand -group even_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/u_cmpy_mult[0]/cmpy_mult_mac/dataa_real}
add wave -noupdate -expand -group even_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/u_cmpy_mult[0]/cmpy_mult_mac/dataa_imag}
add wave -noupdate -expand -group even_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/u_cmpy_mult[0]/cmpy_mult_mac/datab_real}
add wave -noupdate -expand -group even_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/u_cmpy_mult[0]/cmpy_mult_mac/datab_imag}
add wave -noupdate -expand -group even_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/u_cmpy_mult[0]/cmpy_mult_mac/result_real}
add wave -noupdate -expand -group even_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/u_cmpy_mult[0]/cmpy_mult_mac/result_imag}
add wave -noupdate {/cpri_rxdata_8lanes_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/i_rvalid}
add wave -noupdate -expand -group odd_b0a0 {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/o_sum_data}
add wave -noupdate -expand -group odd_b0a0 {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/o_tvalid}
add wave -noupdate -expand -group odd_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/dataa_imag}
add wave -noupdate -expand -group odd_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/dataa_real}
add wave -noupdate -expand -group odd_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/datab_imag}
add wave -noupdate -expand -group odd_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/datab_real}
add wave -noupdate -expand -group odd_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/result_imag}
add wave -noupdate -expand -group odd_b0a0 -radix decimal {/cpri_rxdata_8lanes_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/result_real}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3254444 ps} 0} {{Cursor 2} {39155217 ps} 0} {{Cursor 3} {54983791 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 396
configure wave -valuecolwidth 226
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
WaveRestoreZoom {205991684 ps} {206173168 ps}
