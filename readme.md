
# PUSCH Dim Reduction

&copy; NEWHUI | [邮件](mailto:eliuhui@163.com) |

***

## 目录

[TOC]

## Introduction
### 背景介绍
在通信领域中，发射机通过对发送信号进行处理后将信号发射，通过多天线信道，接收机在接收到信号后，需要对其进行译码，才能获知其中传输的内容。在译码前上行接收机通常需要对天线接收到的信号进行相关处理，如信道估计、信道均衡等，而随着大规模MIMO场景下天线规模的增大，使得上行接收机接收到的数据信号维度也增大，在进行相关处理时，将面临大量高维度的矩阵运算，由于运算量呈几何倍数增加，从而降低了上行接收机的工作效率，功耗也将增大。

因此，基于此问题，我们对大规模MIMO场景下上行接收机的数据进行降维处理，旨在降低接收信号数据维度的同时，最大限度的保留数据信号的特征，以便接收机进行信号处理时，以牺牲一定性能的代价，大幅降低运算复杂度，节省成本。而本问题场景下，我们采用的是基于固定离散傅里叶变换(Discrete Fourier Transform, DFT)码本的数据降维方法，该方法本质上属于线性降维方法。

### 算法方案
不进行降维处理的上行接收机处理流程图如图 2 1所示。上行发射信号经过射频传输之后，基站对接收到的数据做快速傅里叶变换(Fast Fourier Transform, FFT)映射到频域后，经过信道估计与信道均衡后，进行信号的译码。
<div align="center"><img src="./上行-不降维.jpg" width=800></div>

不进行降维处理的上行接收机处理流程图如图 2 1所示。上行发射信号经过射频传输之后，基站对接收到的数据做快速傅里叶变换(Fast Fourier Transform, FFT)映射到频域后，经过信道估计与信道均衡后，进行信号的译码。
<div align="center"><img src="./上行-降维.jpg" width=800></div>

PUSCH信道降维模块大致可以划分为如下3个大模块：频域数据接收、降维计算、数据发送。各个模块的主要功能为：
+ 频域数据接收：接收CPRI数据，进行解包、解压缩处理；
+ 降维计算：对收到的64天线数据进行降维计算，输出降维后16天线数据；
+ 数据发送：将降维后16天线数据进行压缩、并打包成CPRI数据格式发送出去。

<div align="center"><img src="./AIU上行处理流程.png" width=800></div>

### 功能介绍
下图为降维核心算法的内部结构，主要包括码本选择，矩阵运算，能量计算，能量排序，动态定标以及一些缓存和数据对齐的模块。
<div align="center"><img src="./AIU降维处理流程.png" width=800></div>

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


### 2024.12.03
**此版本，通过了从CPRI输入到降维后16Bit数据的向量比对**。
+ 修改FFT AGC解析为奇偶天线并行输出，涉及模块包括：
  + cpri_rx_bufer: 在buffer输入端获取奇偶AGC值，并行输出
  + agc_unpack：并行寻找奇偶AGC基值和差值
  + cpri_rxdata_unpack：ant_sel区分奇偶天线，选取AGC值
+ FFT AGC恢复方式修改：
  + cpri_rxdata_unpack：算术右移
 + 完善打包信息，增加pkg_type和cell_idx：
   + cpri_tx_lane：增加pkg_type和cell_idx端口连接
   + dl_compress_data: 增加pkg_type和cell_idx延时


### 2024.12.06

+ 修复FFT AGC相关问题，涉及模块包括：
  + cpri_rx_bufer: o_symb_eop只在31678处产生
  + agc_unpack：修改FFT AGC按照有符号数进行判断

+ 修复降维输出在重新进入分组计算码本索引时，仍会产生无效输出数据和Valid的问题，涉及模块包括有： 
  + pusch_dr_core：将dr_mode相关逻辑纳入纳入ant_data_buffer 
  + ant_data_buffer：增加dr_mode相关逻辑，并且将symb_clr提前rbg_load
  + beam_sort：修改一些状态的复位条件，用i_symb_clr而不是同步后的reset_syn

+ 完善IQ_HD信息，增加了[44:40]字段的信息，涉及的模块包括：
  + cpri_txdata_top：增加i_aiu_idx接口等
  + txdata_queue：增加了lane_idx输出
  + cpri_tx_lane：增加了i_aiu_idx和i_lane_idx接口
  + ul_compress_data：增加了i_aiu_idx和i_lane_idx接口以及[44:40]字段的填入

### 2024.12.10
**此版本，通过了从CPRI输入到降维后CPRI输出的向量比对**。
+ 修复打包中IQ_HD字段问题：
  + 第1/2组rbg号bit位填反的问题
  + cpri_tx_gen最后输出valid问题
  + Lane1中IQ_HD字段[7:0]修改：8/10/12/14为天线组2，9/11/13/15为天线组3
  + Lane1中power值为0问题(i_rbg_load没接)
  + cpri_rx_buffer中对slot号过滤
  + cpri_rx_gen中rd_valid & cpri_rvld
  + compress_bit里面负数绝对值暂时不加1，后续待定(*包括matlab相应的修改*)

### 2024.12.11
**此版本，通过了从CPRI输入到降维后CPRI输出的向量比对(FFT AGC加入动态定标值)**。
+ 在FFT AGC中加入了动态定标的标值，涉及的模块包括：
  + compress_matrix：输出的FFT AGC加上了shift_num

+ Slot号过滤正式启用，涉及的模块包括：
  + cpri_rx_buffer：pusch_en=1时使能vld，以及slot=4时重新计算
  + ant_data_buffer：slot=4时重新计算

### 2024.12.12
**此版本，通过了4个Slot(DUDU)从CPRI输入到降维后CPRI输出的向量比对**。
+ 修复了从空闲Slot进入重新计算码本序号的Slot时，码本选择和能量计算不正确问题，涉及的模块包括：
  + code_word_rev：
    + 增加了i_symb_clr接口，用于清除码本选择相关状态
    + 修改codeword_map_0/1类型并增加一级寄存器
    + 复制了ant_num以优化时序
  + beam_power_calc：iq_abs_valid修复:与上symb_1st_dly[1]

+ 修改IQ_HD字段[7:0]信息：天线组只有0/1，涉及的模块包括：
  + txdata_queue：将IQ_HD字段[7:0]修改为0/1

### 2024.12.19
**此版本，通过了以ROM打桩方式的20241213版本向量**。
+ 修复了输入异步缓存Buffer读写两端复位问题，涉及的模块包括：
  + cpri_rx_bufer：
    + 修复了读写时钟域误用问题
    + 对读写两端输入的复位信号进行了交互同步
    + 输入pusch_en和cpri_rx_vld复位赋值
    + 读使能rd_en的复位问题
  + 增加了alt_reset_synchronizer相关文件
+ 修复了此前对code_word_rev进行的非压缩数组及打拍操作，会导致资源暴增。

### 2024.12.23
**此版本，通过了以ROM打桩方式的20241213版本向量的硬件测试**。
+ 修复输入缓存buffer数据写使能问题，涉及的模块包括：
  + cpri_rx_bufer：加入prb_idx=0判断条件
+ 修复内部清零不完全导致的问题，涉及的模块包括：
  + mem_stream：rd_en复位
  + cpri_rxdata_unpack：
    + 修复了re_cnt_prb/re_cnt_cycle/prb_cnt/prb_cnt_cycle清零问题
    + 修复了ant_sel的产生逻辑
  + pusch_dr_core：
    + 修复了re_num/rbg_num清零问题
  + abt_data_buffer：
    + 修复了ant_sel的清零问题
+ 修改cpri_tx_gen：恢复之前的从3开始读取ram，使得tx_enable和第0个数据只差一拍
  + **待确认输出valid是否修改**

### 2024.12.24
+ 将发送模块两条CPRI通道的时钟以及iq_tx_enable信号独立，涉及的模块包括：
  + cpri_tx_lane：加入i_tx_clk
  + cpri_txdata_top：加入i_tx0_clk/i_tx1_clk和i_tx0_enable/i_tx1_enable
  + cpri_dr_top：加入i_cpri0_tx_clk/i_cpri1_tx_clk和i_cpri0_tx_enable/i_cpri1_tx_enable

### 2025.01.09
+ 优化码本选择模块时序:
  + code_word_rev：beam_index打拍，拆分cw_even_symb1/cw_odd_symb1
+ 修改动态定标输出的标值结果：
  + compress_matrix：输出标值为29-(39-shift_num)，shift_num位宽改为6，增加15:0之后的移位判断
  + compress_shift：i_shift_num位宽改为6
+ 修复pusch_dr_core中aiu_idx的用法，通过bit0判断

### 2025.01.11
+ 优化码本选择模块时序:
  + code_word_rev：：输出码本相比原始ant数据整体延时2拍
    + beam_index打拍，去掉cw_even_symb1/cw_odd_symb1
    + 在cw_even_select时用i_rbg_load，从而使得码本输出再延时1拍
  + mac_beams：
    + 为匹配码本选择中的1拍延时，输入信号打两怕
    + 将re_num/rbg_num/rbg_load拿到mac_beams中延时该模块处理时间
    + 增加了参数O_LATENCY
  + pusch_dr_core：为匹配修改的码本模块，beam_sort模块输入的i_rbg_load需要延时1拍
  + beam_power_calc：由于输入的re_num/rbg_num/rbg_load已经在mac_beams中延时，所以模块内只需要延时处理的2拍延时。

### 2025.01.12
**此版本，通过了AIU输入打桩的物理层联调**。
+ 优化码本选择模块时序:
  + code_word_rev：输出码本相比原始ant数据整体延时3拍
    + rbg_load打拍，从而使得码本输出再延时1拍
    + 将ant_data、re_num、info等伴随信号，在本模块延时对齐
    + 专门输出bid_rden给beam_sort模块
  + mac_beams：
    + 将之前的re_num/rbg_num/rbg_load输入延时对齐放到code_word_rev中
    + 本模块目前延时13拍（1+11+1）