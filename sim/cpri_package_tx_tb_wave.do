onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpri_package_tx_tb/i_clk
add wave -noupdate /cpri_package_tx_tb/reset
add wave -noupdate /cpri_package_tx_tb/tx_hfp
add wave -noupdate -radix unsigned /cpri_package_tx_tb/tx_seq
add wave -noupdate /cpri_package_tx_tb/package_data/i_eop
add wave -noupdate /cpri_package_tx_tb/package_data/i_sop
add wave -noupdate /cpri_package_tx_tb/package_data/i_vld
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/INST_INFO/empty
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/INST_INFO/full
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/INST_INFO/rd_en
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/INST_INFO/wr_en
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/INST_INFO/dout_valid
add wave -noupdate /cpri_package_tx_tb/pkg_data
add wave -noupdate -radix unsigned /cpri_package_tx_tb/re_num
add wave -noupdate /cpri_package_tx_tb/package_data/i_pkg0_data
add wave -noupdate /cpri_package_tx_tb/package_data/i_pkg0_shift
add wave -noupdate /cpri_package_tx_tb/package_data/i_pkg1_data
add wave -noupdate /cpri_package_tx_tb/package_data/i_pkg2_data
add wave -noupdate /cpri_package_tx_tb/package_data/i_pkg3_data
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/free_size
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/rbadr
add wave -noupdate -radix unsigned /cpri_package_tx_tb/package_data/u_pkg_ram/rd_addr
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/rd_data
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/rd_rdy
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/rd_vld
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/wbadr
add wave -noupdate -radix unsigned /cpri_package_tx_tb/package_data/u_pkg_ram/wr_addr
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/wr_data
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/wr_full
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/wr_wen
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/wr_wlast
add wave -noupdate /cpri_package_tx_tb/package_data/pkg_sel_1
add wave -noupdate /cpri_package_tx_tb/package_data/pkg_head
add wave -noupdate /cpri_package_tx_tb/package_data/ant0_shift
add wave -noupdate /cpri_package_tx_tb/package_data/ant1_shift
add wave -noupdate /cpri_package_tx_tb/package_data/ant2_shift
add wave -noupdate /cpri_package_tx_tb/package_data/ant3_shift
add wave -noupdate /cpri_package_tx_tb/package_data/u_pkg_ram/wr_info
add wave -noupdate /cpri_package_tx_tb/package_data/cpri_head0
add wave -noupdate /cpri_package_tx_tb/package_data/cpri_head1
add wave -noupdate /cpri_package_tx_tb/package_data/cpri_head2
add wave -noupdate /cpri_package_tx_tb/package_data/cpri_head3
add wave -noupdate /cpri_package_tx_tb/package_data/a0_data
add wave -noupdate /cpri_package_tx_tb/package_data/a0_data_d1
add wave -noupdate /cpri_package_tx_tb/package_data/a0_pkg_data
add wave -noupdate /cpri_package_tx_tb/package_data/pkg_rvld_d4
add wave -noupdate -radix unsigned /cpri_package_tx_tb/package_data/group_cnt_d4
add wave -noupdate /cpri_package_tx_tb/package_data/re_cnt_d4
add wave -noupdate /cpri_package_tx_tb/package_data/o_cpri_wdata
add wave -noupdate -radix unsigned /cpri_package_tx_tb/package_data/o_cpri_waddr
add wave -noupdate /cpri_package_tx_tb/package_data/o_cpri_wen
add wave -noupdate /cpri_package_tx_tb/package_data/o_cpri_wlast
add wave -noupdate /cpri_package_tx_tb/u_cpri_tx_gen/o_iq_tx_data
add wave -noupdate /cpri_package_tx_tb/u_cpri_tx_gen/o_iq_tx_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2723661 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 332
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
WaveRestoreZoom {2559942 ps} {2807803 ps}
