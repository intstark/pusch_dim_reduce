onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pusch_dr_128ants_tb/i_clk
add wave -noupdate /pusch_dr_128ants_tb/reset
add wave -noupdate -expand -group aiu0 /pusch_dr_128ants_tb/pusch_dr_core_aiu0/beam_sort_idx
add wave -noupdate -expand -group aiu0 /pusch_dr_128ants_tb/pusch_dr_core_aiu0/beam_sort_load
add wave -noupdate -expand -group aiu0 /pusch_dr_128ants_tb/pusch_dr_core_aiu0/beam_sort_pwr
add wave -noupdate -expand -group aiu0 /pusch_dr_128ants_tb/pusch_dr_core_aiu0/dr_data_re
add wave -noupdate -expand -group aiu0 /pusch_dr_128ants_tb/pusch_dr_core_aiu0/dr_data_im
add wave -noupdate -expand -group aiu1 /pusch_dr_128ants_tb/pusch_dr_core_aiu1/beam_sort_idx
add wave -noupdate -expand -group aiu1 /pusch_dr_128ants_tb/pusch_dr_core_aiu1/beam_sort_load
add wave -noupdate -expand -group aiu1 /pusch_dr_128ants_tb/pusch_dr_core_aiu1/beam_sort_pwr
add wave -noupdate -expand -group aiu1 /pusch_dr_128ants_tb/pusch_dr_core_aiu1/dr_data_re
add wave -noupdate -expand -group aiu1 /pusch_dr_128ants_tb/pusch_dr_core_aiu1/dr_data_im
add wave -noupdate -expand -group aiu2 /pusch_dr_128ants_tb/pusch_dr_core_aiu2/beam_sort_idx
add wave -noupdate -expand -group aiu2 /pusch_dr_128ants_tb/pusch_dr_core_aiu2/beam_sort_pwr
add wave -noupdate -expand -group aiu2 /pusch_dr_128ants_tb/pusch_dr_core_aiu2/dr_data_re
add wave -noupdate -expand -group aiu2 /pusch_dr_128ants_tb/pusch_dr_core_aiu2/dr_data_im
add wave -noupdate -expand -group aiu3 /pusch_dr_128ants_tb/pusch_dr_core_aiu3/beam_sort_idx
add wave -noupdate -expand -group aiu3 /pusch_dr_128ants_tb/pusch_dr_core_aiu3/beam_sort_pwr
add wave -noupdate -expand -group aiu3 /pusch_dr_128ants_tb/pusch_dr_core_aiu3/dr_data_re
add wave -noupdate -expand -group aiu3 /pusch_dr_128ants_tb/pusch_dr_core_aiu3/dr_data_im
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 260
configure wave -valuecolwidth 109
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
