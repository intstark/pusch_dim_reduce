onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pdsch_dr_top_tb/i_clk
add wave -noupdate /pdsch_dr_top_tb/reset
add wave -noupdate /pdsch_dr_top_tb/ant_dout_addr
add wave -noupdate /pdsch_dr_top_tb/ant_dout_data
add wave -noupdate /pdsch_dr_top_tb/ant_dout_last
add wave -noupdate /pdsch_dr_top_tb/ant_dout_vld
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/i_iq_addr
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/i_iq_data
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/i_iq_last
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/i_iq_vld
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/rbg_load
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/re_num
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/rbg_num
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/rbg_slip
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/rbg_sum_all
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/rbg_sum_load
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/rbg_sum_vld
add wave -noupdate /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/rbg_sum_wen
add wave -noupdate -expand -group mac_beams /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/mac_beams/o_data_i
add wave -noupdate -expand -group mac_beams /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/mac_beams/o_data_q
add wave -noupdate -expand -group mac_beams /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/mac_beams/o_eop
add wave -noupdate -expand -group mac_beams /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/mac_beams/o_sop
add wave -noupdate -expand -group mac_beams /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/mac_beams/o_tvalid
add wave -noupdate -expand -group beam_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_buffer/o_rd_addr
add wave -noupdate -expand -group beam_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_buffer/o_rd_data
add wave -noupdate -expand -group beam_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_buffer/o_rd_vld
add wave -noupdate -expand -group beam_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_buffer/o_tvalid
add wave -noupdate -expand -group beam_sort /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_sort/o_beam_index
add wave -noupdate -expand -group beam_sort /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_sort/o_data
add wave -noupdate -expand -group beam_sort /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_sort/o_idx_sop
add wave -noupdate -expand -group beam_sort /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beam_sort/o_rbg_load
add wave -noupdate -expand -group beam_pick /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beams_pick_top/o_data_im
add wave -noupdate -expand -group beam_pick /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beams_pick_top/o_data_re
add wave -noupdate -expand -group beam_pick /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beams_pick_top/o_eop
add wave -noupdate -expand -group beam_pick /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beams_pick_top/o_sop
add wave -noupdate -expand -group beam_pick /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/beams_pick_top/o_tvld
add wave -noupdate -expand -group dr_compress /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/compress_matrix/o_dout_im
add wave -noupdate -expand -group dr_compress /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/compress_matrix/o_dout_re
add wave -noupdate -expand -group dr_compress /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/compress_matrix/o_eop
add wave -noupdate -expand -group dr_compress /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/compress_matrix/o_sop
add wave -noupdate -expand -group dr_buffer -radix unsigned /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/dr_data_buffer/o_prb_idx
add wave -noupdate -expand -group dr_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/dr_data_buffer/o_tx_data
add wave -noupdate -expand -group dr_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/dr_data_buffer/o_tx_sop
add wave -noupdate -expand -group dr_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/dr_data_buffer/o_tx_eop
add wave -noupdate -expand -group dr_buffer /pdsch_dr_top_tb/pdsch_dr_top/pdsch_dr_core/dr_data_buffer/o_tx_vld
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/i_iq_tx_enable
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/u_compress_data/i_din_ant0
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/u_compress_data/i_din_ant1
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/u_compress_data/i_din_ant2
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/u_compress_data/i_din_ant3
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/u_compress_data/i_eop
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/u_compress_data/i_sop
add wave -noupdate -expand -group cpri_txdata -radix unsigned /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/u_compress_data/i_prb_idx
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/o_iq_tx_data
add wave -noupdate -expand -group cpri_txdata /pdsch_dr_top_tb/pdsch_dr_top/cpri_txdata_top/o_iq_tx_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {211254962 ps} 0} {{Cursor 2} {195424724 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 342
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
WaveRestoreZoom {229419838 ps} {230524016 ps}
