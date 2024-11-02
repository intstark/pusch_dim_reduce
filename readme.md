
# PUSCH Dim Reduction
## Introduction

## Methodology

## Releases

### 2024.11.02

+ 根据时序分析结果，改进了code word选择部分的实现，主要涉及pdsch_dr_core模块
+ 根据向量比对结果，修正了4RB置于头和尾不同case时的问题，主要涉及pdsch_dr_core模块和beam_sort模块
+ 根据向量比对结果，修正了压缩算法中的四舍五入误差问题，主要涉及compress_shift模块和max_search模块
+ 增加了dr_data_buffer模块用于缓存降维后的16天线数据，缓放4天线数据发送0/2/4/6->1/3/5/7->8/10/12/14->9/11/13/15
+ 增加了cpri_txdata_top用于打包并行4天线数据成cpri数据格式