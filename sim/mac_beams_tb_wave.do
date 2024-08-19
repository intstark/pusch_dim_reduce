onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mac_beams_tb/i_clk
add wave -noupdate /mac_beams_tb/re_num
add wave -noupdate /mac_beams_tb/reset
add wave -noupdate /mac_beams_tb/ants_even_mem
add wave -noupdate /mac_beams_tb/ants_odd_mem
add wave -noupdate /mac_beams_tb/code_word_even_pre
add wave -noupdate /mac_beams_tb/code_word_odd_pre
add wave -noupdate /mac_beams_tb/dut_mac_beams/i_ants_data_even
add wave -noupdate /mac_beams_tb/dut_mac_beams/i_clk
add wave -noupdate /mac_beams_tb/dut_mac_beams/i_code_word_even
add wave -noupdate /mac_beams_tb/dut_mac_beams/i_code_word_odd
add wave -noupdate /mac_beams_tb/dut_mac_beams/even_sum_data
add wave -noupdate -expand /mac_beams_tb/dut_mac_beams/odd_sum_data
add wave -noupdate /mac_beams_tb/dut_mac_beams/ants_sum
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/dataa_imag}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/dataa_real}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/datab_imag}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/datab_real}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/result_imag}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[0]/cmpy_mult_mac/result_real}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[1]/cmpy_mult_mac/dataa_imag}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[1]/cmpy_mult_mac/dataa_real}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[1]/cmpy_mult_mac/datab_imag}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[1]/cmpy_mult_mac/datab_real}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[1]/cmpy_mult_mac/result_imag}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/u_cmpy_mult[1]/cmpy_mult_mac/result_real}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/add4_im}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/add4_re}
add wave -noupdate -radix hexadecimal {/mac_beams_tb/dut_mac_beams/odd_ants_of_16beams[0]/mac_ants_odd/o_sum_data}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/add4_im}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/add4_re}
add wave -noupdate -radix decimal {/mac_beams_tb/dut_mac_beams/even_ants_of_16beams[0]/mac_ants_even/o_sum_data}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 358
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
WaveRestoreZoom {2471338 ps} {5133088 ps}
