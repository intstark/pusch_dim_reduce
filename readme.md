
# PUSCH Dim Reduction
&copy; NEWHUI | [邮件](mailto:eliuhui@163.com) |

***
## 目录
[TOC]

### Introduction

### 目录介绍
+ AlogVec: 算法提供的向量
+ Matlab: 用于进行向量比对、FPGA激励文件输入转换、仿真结果比对
+ sim: 仿真脚本和仿真输出
+ src: 源代码
  + pusch_dr_top.sv：顶层模块,接收CPRI数据，并将降维数据通过CPRI发出
    + cpri_rxdata_top.sv: 接收CPRI数据，并解析info和iq_data字段
      + cpri_rx_buffer.sv：缓存CPRI数据，对齐不同Lane延时差
      + agc_unpack.sv：寻找偶/奇天线FFT AGC基值，并计算用于拉齐的移位值
      + cpri_rxdata_unpack.sv：解析IQ_HD和AGC_FFT字段
        + cpri_rx_gen.sv：按4RB缓存数据
        + decompress_bit.sv：解压7比特数据到16比特数据
    + pusch_dr_core.sv：降维核心模块顶层
      + ant_data_buffer.sv：缓存天线数据以获取并行奇偶天线数据。
      + code_word_rev.sv：读取码本矩阵数据，并选择当前运算的16 beam用到的码本数据。
      + mac_beams.sv：核心计算模块，完成16波速 32奇偶天线的矩阵运算。
      + beam_power_calc.sv：计算降维后波束的能量值。
      + beam_buffer.sv：分时缓存4组16波束能量值，输出并行的64波束能量值。
      + beam_sort.sv：对64波束能量值进行排序，输出最大的16波束能量序号以及能量值。
      + beams_pick_top：根据最大的16波束能量序号，选择要输出的16波束降维数据。
      + compress_matrix.sv：对降维后40比特数据经过动态定标到16比特I/Q数据。
    + cpri_txdata_top.sv：将降维后16天线数据打包成CPRI数据格式
      + txdata_queue.sv：缓存8波束降维数据，按打包顺序并行输出4天线偶/奇天线数据。
      + cpri_tx_lane.sv：输入info等信息以及4天线数据，输出CPRI数据格式
        + ul_compress_data.v: 16比特I/Q数据压缩成7比特
        + ul_package_data.v: 组包
        + cpri_tx_gen.v: 输出CPRI数据
+ tb：测试顶层及仿真所需其他文件


### 使用方法
+ 使用方法
    1. 将Modelsim的安装目录的win64文件夹加入系统环境变量PATH，点击sim文件夹中的.bat文件
    2. 运行结束后，会在pusch_dr_top_dz_tb_work文件夹产生数据文件
    3. 最终输出的CPRI数据文件为sim/pusch_dr_top_dz_tb_work/des_tx_cpri0.txt和des_tx_cpri1.txt，可利用文本比对工具与向量DimRedu164To16中LAN1.txt和LAN2.txt进行比对。
+ 使用方法2：打开ModleSim，在下方tcl界面输入do run_pdsch_dr_top_dz_tb.do，其他步骤同上。


## Methodology



## Tools and Software
+ 基于Quartus Prime Pro 23.2
+ Modelsim SE-64 2020.4
+ Matlab R2022a



## Releases

### 2024.12.23
**此版本，通过了以ROM打桩方式的20241213版本向量的硬件测试**。
+ 修复输入缓存buffer数据写使能问题。
+ 修复异常复位状态下内部清零不完全导致的问题。