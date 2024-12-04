# Details

Date : 2024-12-02 14:17:28

Directory e:\\Openlab\\gitlib\\project\\pusch\\pusch_dim_reduce\\src

Total : 62 files,  13547 codes, 3049 comments, 2584 blanks, all 19180 lines

[Summary](results.md) / Details / [Diff Summary](diff.md) / [Diff Details](diff-details.md)

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [src/agc_unpack.sv](/src/agc_unpack.sv) | SystemVerilog | 135 | 50 | 34 | 219 |
| [src/ant_data_buffer.sv](/src/ant_data_buffer.sv) | SystemVerilog | 210 | 43 | 47 | 300 |
| [src/beam_buffer.sv](/src/beam_buffer.sv) | SystemVerilog | 209 | 46 | 37 | 292 |
| [src/beam_power_calc.sv](/src/beam_power_calc.sv) | SystemVerilog | 159 | 40 | 36 | 235 |
| [src/beam_sort.sv](/src/beam_sort.sv) | SystemVerilog | 421 | 73 | 92 | 586 |
| [src/beams_mem_pick.sv](/src/beams_mem_pick.sv) | SystemVerilog | 352 | 53 | 66 | 471 |
| [src/beams_pick_top.sv](/src/beams_pick_top.sv) | SystemVerilog | 103 | 27 | 23 | 153 |
| [src/code_word_rev.sv](/src/code_word_rev.sv) | SystemVerilog | 142 | 29 | 38 | 209 |
| [src/compress_bit.v](/src/compress_bit.v) | Verilog | 275 | 56 | 31 | 362 |
| [src/compress_matrix.sv](/src/compress_matrix.sv) | SystemVerilog | 227 | 43 | 44 | 314 |
| [src/compress_shift.sv](/src/compress_shift.sv) | SystemVerilog | 118 | 18 | 25 | 161 |
| [src/cpri_package_tx_zyl/Simple_Dual_Port_URAM_XPM.v](/src/cpri_package_tx_zyl/Simple_Dual_Port_URAM_XPM.v) | Verilog | 63 | 281 | 25 | 369 |
| [src/cpri_package_tx_zyl/compress_bit.v](/src/cpri_package_tx_zyl/compress_bit.v) | Verilog | 275 | 56 | 31 | 362 |
| [src/cpri_package_tx_zyl/compress_data.v](/src/cpri_package_tx_zyl/compress_data.v) | Verilog | 139 | 12 | 9 | 160 |
| [src/cpri_package_tx_zyl/cpri_tx_gen.v](/src/cpri_package_tx_zyl/cpri_tx_gen.v) | Verilog | 116 | 18 | 23 | 157 |
| [src/cpri_package_tx_zyl/cpri_tx_pkg.v](/src/cpri_package_tx_zyl/cpri_tx_pkg.v) | Verilog | 176 | 47 | 47 | 270 |
| [src/cpri_package_tx_zyl/dl_data_gen.sv](/src/cpri_package_tx_zyl/dl_data_gen.sv) | SystemVerilog | 365 | 179 | 130 | 674 |
| [src/cpri_package_tx_zyl/dl_data_gen_old.v](/src/cpri_package_tx_zyl/dl_data_gen_old.v) | Verilog | 366 | 177 | 132 | 675 |
| [src/cpri_package_tx_zyl/dl_sym_if.v](/src/cpri_package_tx_zyl/dl_sym_if.v) | Verilog | 164 | 13 | 22 | 199 |
| [src/cpri_package_tx_zyl/intel_xpm/common/ASYNC_Dual_Port_BRAM_XPM_intel.v](/src/cpri_package_tx_zyl/intel_xpm/common/ASYNC_Dual_Port_BRAM_XPM_intel.v) | Verilog | 83 | 26 | 6 | 115 |
| [src/cpri_package_tx_zyl/intel_xpm/common/FIFO_ASYNC_XPM_intel.v](/src/cpri_package_tx_zyl/intel_xpm/common/FIFO_ASYNC_XPM_intel.v) | Verilog | 56 | 12 | 3 | 71 |
| [src/cpri_package_tx_zyl/intel_xpm/common/FIFO_SYNC_XPM_intel.v](/src/cpri_package_tx_zyl/intel_xpm/common/FIFO_SYNC_XPM_intel.v) | Verilog | 52 | 10 | 3 | 65 |
| [src/cpri_package_tx_zyl/intel_xpm/common/Simple_Dual_Port_BRAM_XPM_intel.v](/src/cpri_package_tx_zyl/intel_xpm/common/Simple_Dual_Port_BRAM_XPM_intel.v) | Verilog | 80 | 25 | 5 | 110 |
| [src/cpri_package_tx_zyl/intel_xpm/common/loop_buffer2_sync_intel.v](/src/cpri_package_tx_zyl/intel_xpm/common/loop_buffer2_sync_intel.v) | Verilog | 175 | 25 | 47 | 247 |
| [src/cpri_package_tx_zyl/intel_xpm/common/loop_buffer_async_intel.v](/src/cpri_package_tx_zyl/intel_xpm/common/loop_buffer_async_intel.v) | Verilog | 159 | 28 | 32 | 219 |
| [src/cpri_package_tx_zyl/intel_xpm/common/loop_buffer_sync_intel.v](/src/cpri_package_tx_zyl/intel_xpm/common/loop_buffer_sync_intel.v) | Verilog | 153 | 27 | 42 | 222 |
| [src/cpri_package_tx_zyl/loop_buffer_async.v](/src/cpri_package_tx_zyl/loop_buffer_async.v) | Verilog | 162 | 25 | 37 | 224 |
| [src/cpri_package_tx_zyl/loop_buffer_sync.v](/src/cpri_package_tx_zyl/loop_buffer_sync.v) | Verilog | 156 | 25 | 38 | 219 |
| [src/cpri_package_tx_zyl/package_data.v](/src/cpri_package_tx_zyl/package_data.v) | Verilog | 495 | 64 | 64 | 623 |
| [src/cpri_package_tx_zyl/package_data_intel.v](/src/cpri_package_tx_zyl/package_data_intel.v) | Verilog | 471 | 104 | 65 | 640 |
| [src/cpri_package_tx_zyl/pcie_bf_para.v](/src/cpri_package_tx_zyl/pcie_bf_para.v) | Verilog | 165 | 21 | 38 | 224 |
| [src/cpri_package_tx_zyl/ul_compress_data.sv](/src/cpri_package_tx_zyl/ul_compress_data.sv) | SystemVerilog | 186 | 21 | 20 | 227 |
| [src/cpri_package_tx_zyl/ul_package_data.v](/src/cpri_package_tx_zyl/ul_package_data.v) | Verilog | 585 | 58 | 72 | 715 |
| [src/cpri_package_tx_zyl/ul_package_data111.v](/src/cpri_package_tx_zyl/ul_package_data111.v) | Verilog | 567 | 97 | 72 | 736 |
| [src/cpri_rx_buffer.sv](/src/cpri_rx_buffer.sv) | SystemVerilog | 300 | 53 | 56 | 409 |
| [src/cpri_rx_gen.sv](/src/cpri_rx_gen.sv) | SystemVerilog | 165 | 73 | 38 | 276 |
| [src/cpri_rxdata_top.sv](/src/cpri_rxdata_top.sv) | SystemVerilog | 130 | 37 | 33 | 200 |
| [src/cpri_rxdata_unpack.sv](/src/cpri_rxdata_unpack.sv) | SystemVerilog | 277 | 64 | 69 | 410 |
| [src/cpri_tx_gen.v](/src/cpri_tx_gen.v) | Verilog | 116 | 18 | 23 | 157 |
| [src/cpri_tx_lane.sv](/src/cpri_tx_lane.sv) | SystemVerilog | 198 | 13 | 30 | 241 |
| [src/cpri_txdata_top.sv](/src/cpri_txdata_top.sv) | SystemVerilog | 175 | 28 | 39 | 242 |
| [src/decompress_bit.v](/src/decompress_bit.v) | Verilog | 37 | 12 | 7 | 56 |
| [src/dl_symb_cmpr/compress_bit.v](/src/dl_symb_cmpr/compress_bit.v) | Verilog | 265 | 47 | 30 | 342 |
| [src/dl_symb_cmpr/compress_data.v](/src/dl_symb_cmpr/compress_data.v) | Verilog | 139 | 12 | 9 | 160 |
| [src/dl_symb_cmpr/cpri_tx_gen.v](/src/dl_symb_cmpr/cpri_tx_gen.v) | Verilog | 100 | 18 | 18 | 136 |
| [src/dl_symb_cmpr/dl_data_gen.v](/src/dl_symb_cmpr/dl_data_gen.v) | Verilog | 366 | 179 | 132 | 677 |
| [src/dl_symb_cmpr/dl_package_data.sv](/src/dl_symb_cmpr/dl_package_data.sv) | SystemVerilog | 521 | 76 | 71 | 668 |
| [src/dl_symb_cmpr/dl_symb_if.v](/src/dl_symb_cmpr/dl_symb_if.v) | Verilog | 164 | 13 | 22 | 199 |
| [src/dl_symb_cmpr/package_data.v](/src/dl_symb_cmpr/package_data.v) | Verilog | 509 | 66 | 69 | 644 |
| [src/lp_buffer_syn.sv](/src/lp_buffer_syn.sv) | SystemVerilog | 70 | 34 | 21 | 125 |
| [src/mac_ants.sv](/src/mac_ants.sv) | SystemVerilog | 114 | 50 | 35 | 199 |
| [src/mac_beams.sv](/src/mac_beams.sv) | SystemVerilog | 171 | 49 | 40 | 260 |
| [src/mem_streams.sv](/src/mem_streams.sv) | SystemVerilog | 82 | 38 | 25 | 145 |
| [src/mem_streams_ram.sv](/src/mem_streams_ram.sv) | SystemVerilog | 96 | 38 | 29 | 163 |
| [src/par_compare.sv](/src/par_compare.sv) | SystemVerilog | 72 | 42 | 24 | 138 |
| [src/pusch_dr_core.sv](/src/pusch_dr_core.sv) | SystemVerilog | 411 | 64 | 82 | 557 |
| [src/pusch_dr_top.sv](/src/pusch_dr_top.sv) | SystemVerilog | 161 | 39 | 43 | 243 |
| [src/register_shift.sv](/src/register_shift.sv) | SystemVerilog | 18 | 0 | 8 | 26 |
| [src/search_max.sv](/src/search_max.sv) | SystemVerilog | 90 | 27 | 18 | 135 |
| [src/txdata_queue.sv](/src/txdata_queue.sv) | SystemVerilog | 445 | 49 | 80 | 574 |
| [src/ul_compress_data.sv](/src/ul_compress_data.sv) | SystemVerilog | 188 | 21 | 21 | 230 |
| [src/ul_package_data.v](/src/ul_package_data.v) | Verilog | 607 | 60 | 76 | 743 |

[Summary](results.md) / Details / [Diff Summary](diff.md) / [Diff Details](diff-details.md)