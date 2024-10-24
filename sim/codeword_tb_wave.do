onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /codeword_tb/i_clk
add wave -noupdate /codeword_tb/i_reset
add wave -noupdate /codeword_tb/i_enable
add wave -noupdate /codeword_tb/uut/codeword_rdata_even
add wave -noupdate /codeword_tb/uut/codeword_rdata_odd
add wave -noupdate -color {Medium Orchid} -radix unsigned /codeword_tb/uut/ant_num
add wave -noupdate /codeword_tb/uut/rom_vld
add wave -noupdate /codeword_tb/uut/codeword_map_0
add wave -noupdate /codeword_tb/uut/codeword_map_1
add wave -noupdate -radix unsigned -childformat {{{/codeword_tb/uut/codeword_raddr[5]} -radix unsigned} {{/codeword_tb/uut/codeword_raddr[4]} -radix unsigned} {{/codeword_tb/uut/codeword_raddr[3]} -radix unsigned} {{/codeword_tb/uut/codeword_raddr[2]} -radix unsigned} {{/codeword_tb/uut/codeword_raddr[1]} -radix unsigned} {{/codeword_tb/uut/codeword_raddr[0]} -radix unsigned}} -subitemconfig {{/codeword_tb/uut/codeword_raddr[5]} {-height 15 -radix unsigned} {/codeword_tb/uut/codeword_raddr[4]} {-height 15 -radix unsigned} {/codeword_tb/uut/codeword_raddr[3]} {-height 15 -radix unsigned} {/codeword_tb/uut/codeword_raddr[2]} {-height 15 -radix unsigned} {/codeword_tb/uut/codeword_raddr[1]} {-height 15 -radix unsigned} {/codeword_tb/uut/codeword_raddr[0]} {-height 15 -radix unsigned}} /codeword_tb/uut/codeword_raddr
add wave -noupdate /codeword_tb/uut/codeword_rden
add wave -noupdate -expand -group rom_even /codeword_tb/uut/u_rom_codeword_even/rden
add wave -noupdate -expand -group rom_even -radix unsigned /codeword_tb/uut/u_rom_codeword_even/address
add wave -noupdate -expand -group rom_even /codeword_tb/uut/u_rom_codeword_even/clock
add wave -noupdate -expand -group rom_even /codeword_tb/uut/u_rom_codeword_even/q
add wave -noupdate -expand -group rom_odd /codeword_tb/uut/u_rom_codeword_odd/rden
add wave -noupdate -expand -group rom_odd -radix unsigned /codeword_tb/uut/u_rom_codeword_odd/address
add wave -noupdate -expand -group rom_odd /codeword_tb/uut/u_rom_codeword_odd/clock
add wave -noupdate -expand -group rom_odd /codeword_tb/uut/u_rom_codeword_odd/q
add wave -noupdate /codeword_tb/uut/o_cw_even
add wave -noupdate /codeword_tb/uut/o_cw_odd
add wave -noupdate /codeword_tb/uut/o_tvalid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 376
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1050 ns}
