onerror {resume}
quietly virtual function -install /cpri_rxdata_unpack_tb/uut -env /cpri_rxdata_unpack_tb { &{/cpri_rxdata_unpack_tb/uut/ant_package[0][6], /cpri_rxdata_unpack_tb/uut/ant_package[0][5], /cpri_rxdata_unpack_tb/uut/ant_package[0][4], /cpri_rxdata_unpack_tb/uut/ant_package[0][3], /cpri_rxdata_unpack_tb/uut/ant_package[0][2], /cpri_rxdata_unpack_tb/uut/ant_package[0][1], /cpri_rxdata_unpack_tb/uut/ant_package[0][0] }} ll
quietly virtual function -install /cpri_rxdata_unpack_tb/uut -env /cpri_rxdata_unpack_tb { &{/cpri_rxdata_unpack_tb/uut/ant_package[0][13], /cpri_rxdata_unpack_tb/uut/ant_package[0][12], /cpri_rxdata_unpack_tb/uut/ant_package[0][11], /cpri_rxdata_unpack_tb/uut/ant_package[0][10], /cpri_rxdata_unpack_tb/uut/ant_package[0][9], /cpri_rxdata_unpack_tb/uut/ant_package[0][8], /cpri_rxdata_unpack_tb/uut/ant_package[0][7] }} qq
quietly virtual signal -install /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen { /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[6:0]} ii1
quietly virtual signal -install /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen { /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[13:7]} qq2
quietly virtual function -install /cpri_rxdata_unpack_tb -env /cpri_rxdata_unpack_tb { &{/cpri_rxdata_unpack_tb/iq_data[6], /cpri_rxdata_unpack_tb/iq_data[5], /cpri_rxdata_unpack_tb/iq_data[4], /cpri_rxdata_unpack_tb/iq_data[3], /cpri_rxdata_unpack_tb/iq_data[2], /cpri_rxdata_unpack_tb/iq_data[1], /cpri_rxdata_unpack_tb/iq_data[0] }} ii0
quietly virtual function -install /cpri_rxdata_unpack_tb -env /cpri_rxdata_unpack_tb { &{/cpri_rxdata_unpack_tb/iq_data[13], /cpri_rxdata_unpack_tb/iq_data[12], /cpri_rxdata_unpack_tb/iq_data[11], /cpri_rxdata_unpack_tb/iq_data[10], /cpri_rxdata_unpack_tb/iq_data[9], /cpri_rxdata_unpack_tb/iq_data[8], /cpri_rxdata_unpack_tb/iq_data[7] }} qq0
quietly virtual signal -install /cpri_rxdata_unpack_tb { /cpri_rxdata_unpack_tb/data_iq_block[6:0]} fas
quietly virtual signal -install /cpri_rxdata_unpack_tb { /cpri_rxdata_unpack_tb/data_iq_block[13:7]} fbs
quietly virtual signal -install /cpri_rxdata_unpack_tb { /cpri_rxdata_unpack_tb/data_iq_block[20:14]} a
quietly virtual signal -install /cpri_rxdata_unpack_tb { /cpri_rxdata_unpack_tb/data_iq_block[27:21]} z
quietly virtual signal -install /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen { /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[6:0]} i
quietly virtual signal -install /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen { /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[13:7]} q
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpri_rxdata_unpack_tb/i_clk
add wave -noupdate /cpri_rxdata_unpack_tb/reset
add wave -noupdate /cpri_rxdata_unpack_tb/tx_hfp
add wave -noupdate -radix decimal /cpri_rxdata_unpack_tb/ii0
add wave -noupdate -radix decimal /cpri_rxdata_unpack_tb/qq0
add wave -noupdate /cpri_rxdata_unpack_tb/iq_data
add wave -noupdate -color {Slate Blue} -radix unsigned /cpri_rxdata_unpack_tb/uut/i_cpri_rx_seq
add wave -noupdate /cpri_rxdata_unpack_tb/uut/i_cpri_rx_data
add wave -noupdate -radix unsigned /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_waddr
add wave -noupdate -radix decimal -childformat {{{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1[6]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1[5]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1[4]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1[3]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1[2]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1[1]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1[0]} -radix decimal}} -subitemconfig {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[6]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[5]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[4]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[3]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[2]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[1]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[0]} {-radix decimal}} /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/ii1
add wave -noupdate -radix decimal -childformat {{{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2[13]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2[12]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2[11]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2[10]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2[9]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2[8]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2[7]} -radix decimal}} -subitemconfig {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[13]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[12]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[11]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[10]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[9]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[8]} {-radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata[7]} {-radix decimal}} /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/qq2
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wdata
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wen
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i_cpri_wlast
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/rbadr
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/wbadr
add wave -noupdate -radix unsigned /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/MEMORY_TYPE/genblk1/INST_BRAM/wraddress
add wave -noupdate -radix unsigned /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/u_cpri_rx_ram/MEMORY_TYPE/genblk1/INST_BRAM/rdaddress
add wave -noupdate -color {Dark Orchid} -radix unsigned -childformat {{{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[6]} -radix unsigned} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[5]} -radix unsigned} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[4]} -radix unsigned} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[3]} -radix unsigned} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[2]} -radix unsigned} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[1]} -radix unsigned} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[0]} -radix unsigned}} -subitemconfig {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[6]} {-color {Dark Orchid} -height 15 -radix unsigned} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[5]} {-color {Dark Orchid} -height 15 -radix unsigned} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[4]} {-color {Dark Orchid} -height 15 -radix unsigned} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[3]} {-color {Dark Orchid} -height 15 -radix unsigned} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[2]} {-color {Dark Orchid} -height 15 -radix unsigned} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[1]} {-color {Dark Orchid} -height 15 -radix unsigned} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr[0]} {-color {Dark Orchid} -height 15 -radix unsigned}} /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_raddr
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i[6]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i[5]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i[4]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i[3]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i[2]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i[1]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i[0]} -radix decimal}} -subitemconfig {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[6]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[5]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[4]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[3]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[2]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[1]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[0]} {-color {Orange Red} -radix decimal}} /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/i
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q[13]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q[12]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q[11]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q[10]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q[9]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q[8]} -radix decimal} {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q[7]} -radix decimal}} -subitemconfig {{/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[13]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[12]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[11]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[10]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[9]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[8]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata[7]} {-color {Orange Red} -radix decimal}} /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/q
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdata
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rdy
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rinfo
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/cpri_rvld
add wave -noupdate /cpri_rxdata_unpack_tb/uut/u_cpri_rx_gen/rd_valid
add wave -noupdate -color {Dark Orchid} -radix unsigned /cpri_rxdata_unpack_tb/uut/cpri_iq_raddr
add wave -noupdate /cpri_rxdata_unpack_tb/uut/cpri_iq_data
add wave -noupdate /cpri_rxdata_unpack_tb/uut/cpri_iq_data_r1
add wave -noupdate /cpri_rxdata_unpack_tb/uut/iq_rx_ready
add wave -noupdate -radix unsigned /cpri_rxdata_unpack_tb/uut/re_cnt_cycle
add wave -noupdate -color {Orange Red} -radix decimal /cpri_rxdata_unpack_tb/uut/qq
add wave -noupdate -color {Orange Red} -radix decimal -childformat {{(6) -radix decimal} {(5) -radix decimal} {(4) -radix decimal} {(3) -radix decimal} {(2) -radix decimal} {(1) -radix decimal} {(0) -radix decimal}} -subitemconfig {{/cpri_rxdata_unpack_tb/uut/ant_package[0][6]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/ant_package[0][5]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/ant_package[0][4]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/ant_package[0][3]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/ant_package[0][2]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/ant_package[0][1]} {-color {Orange Red} -radix decimal} {/cpri_rxdata_unpack_tb/uut/ant_package[0][0]} {-color {Orange Red} -radix decimal}} /cpri_rxdata_unpack_tb/uut/ll
add wave -noupdate /cpri_rxdata_unpack_tb/uut/ant_package
add wave -noupdate /cpri_rxdata_unpack_tb/uut/cpri_iq_vld
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1194604 ps} 0} {{Cursor 2} {1365327 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 279
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
WaveRestoreZoom {2050185 ps} {2355385 ps}
