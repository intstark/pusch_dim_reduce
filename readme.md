
# PUSCH Dim Reduction

&copy; NEWHUI | [邮件](mailto:eliuhui@163.com) |

***

## 目录

[TOC]

## Introduction

<div align="center"><img src="./AIU上行处理流程.png" width=800></div>

### 功能介绍

<div align="center"><img src="./AIU降维处理流程.png" width=800></div>

### 目录介绍

+ AlogVec: 算法提供的向量
+ Matlab: 用于进行向量比对、FPGA激励文件输入转换、仿真结果比对
+ sim: 仿真脚本和仿真输出
+ src: 源代码
  + pusch_dr_top.sv：顶层模块,接收CPRI数据，并将降维数据通过CPRI发出
    + cpri_rxdata_top.sv: 接收CPRI数据，并解析info和iq_data字段
      + cpri_rx_buffer.sv：缓存CPRI数据，对齐不同Lane延时差
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
    2. 运行结束后，会在pdsch_dr_128ants_tb_work文件夹产生数据文件
    3. 运行Matlab程序dr128_vector_vfy.m进行数据分析
+ 使用方法2：打开ModleSim，在下方tcl界面输入do run_pdsch_dr_128ants_vsim.do，其他步骤同上。

## Methodology

## Tools and Software

+ Quartus Prime Pro 23.2
+ Modelsim SE-64 2020.4
+ Matlab R2022a

## Releases

### 2024.11.02

+ 根据时序分析结果，改进了code word选择部分的实现，主要涉及pdsch_dr_core模块
+ 根据向量比对结果，修正了4RB置于头和尾不同case时的问题，主要涉及pdsch_dr_core模块和beam_sort模块
+ 根据向量比对结果，修正了压缩算法中的四舍五入误差问题，主要涉及compress_shift模块和max_search模块
+ 增加了dr_data_buffer模块用于缓存降维后的16天线数据，缓放4天线数据发送0/2/4/6->1/3/5/7->8/10/12/14->9/11/13/15
+ 增加了cpri_txdata_top用于打包并行4天线数据成cpri数据格式。

### 2024.11.08

+ 增加能量值的读出，涉及修改的模块有：
  + beam_sort：能量值读取时序
  + beams_pick_top：能量值伴随延迟
  + cpmpress_matrix：能量值伴随延时
  + dr_data_buffer：能量值伴随读取
  
+ 对pusch_dr_core模块进行了结构优化，涉及修改的模块有：
  + code_word_rev：码本选择相关全部纳入
  + beam_power_calc：绝对值计算和能量累加
  + mac_beams：收纳ant_data的1拍延时

+ 增加了对IQ_HD和AGC_FFT字段的解析，涉及修改的模块有：
  + cpri_rxdata_unpack：解析IQ_HD和AGC_FFT字段
  + pusc_dr_core：增加i_info0/i_info1接口

+ 其他问题：
  + cpri_rx_gen：cpri_wen问题
  + mem_stream：wr_addr问题
  + 文件名问题：所有pdsch开头的文件都改成了pusch

### 2024.11.19

+ 全链路打通了IQ_HD以及beam power的打包输出
+ 修改降维后的16天线通过两条CPRI传输，分别传输ant0-ant7和ant8-ant15
+ 修改了解压缩模块
  + 增加了decompress_bit文件
  + 修复了compress_bit模块中的饱和问题以及绝对值反码加1问题
+ 修改了解包的反压逻辑，不会造成速率不匹配问题，涉及模块包括：
  + cpri_rx_gen模块，raddr从7开始
  + cpri_rx_buffer模块，DATA_DEPTH
+ 修改解包解压缩架构，涉及模块：
  + 增加了cpri_rxdata_top模块
  + 增加了cpri_rx_buffer模块，缓存8个符号，同时读取以对齐不同Lane延时差

### 2024.11.21

+ 增加何时重新计算降维码本选择序号的模式

### 2024.11.29

+ 增加FFT AGC相关功能，涉及的模块包括：
  + cpri_rx_buffer：分奇偶天线解析FFT AGC字段
  + agc_unpack：比较所有偶或奇天线中FFT AGC的值大小，找到最小值作为基值，并计算差值作为移位值
  + cpri_rxdata_unpack：在解压缩之后，将FFT AGC应用到数据中
  + beams_mem_pick：根据选出来的波束序号对降维后的16天线进行奇偶判断，并根据奇偶选择输出的FFT AGC基值
  + txdata_queue：将8天线FFT AGC处理成4天线偶/奇天线
  + dl_package_data：每4RB采样FFT AGC值放置在DW5字段中
+ 波束能量值打包输出按前4A和后4A的方式打包，涉及的模块包括：
  + txdata_queue：将8天线能量值处理成4天线偶/奇天线
  + dl_package_data：每4RB采样能量值放置在DW5字段中