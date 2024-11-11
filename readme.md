
# PUSCH Dim Reduction
&copy; NEWHUI | [邮件](mailto:eliuhui@163.com) |

***
## 目录
[TOC]

## Introduction

## Methodology

## Tools and Software
+ 基于Quartus Prime Pro 23.2
+ Modelsim SE-64 2020.4
+ Matlab R2022a

## Releases

### 2024.11.02

#### 目录介绍
+ AlogVec: 算法提供的向量
+ Matlab: 用于进行向量比对、FPGA激励文件输入转换、仿真结果比对
+ sim: 仿真脚本和仿真输出
+ src: 源代码
  + pusch_dr_core.sv：降维核心模块顶层
    + ant_data_buffer.sv：缓存天线数据以获取并行奇偶天线数据。
    + code_word_rev.sv：读取码本矩阵数据，并选择当前运算的16 beam用到的码本数据。
    + mac_beams.sv：核心计算模块，完成16波速 32奇偶天线的矩阵运算。
    + beam_power_calc.sv：计算降维后波束的能量值。
    + beam_buffer.sv：分时缓存4组16波束能量值，输出并行的64波束能量值。。
    + beam_sort.sv：对64波束能量值进行排序，输出最大的16波束能量序号以及能量值。
    + beams_pick_top：根据最大的16波束能量序号，选择要输出的16波束降维数据。
    + compress_matrix.sv：对降维后40比特数据经过动态定标到16比特I/Q数据。
    + dr_data_buffer.sv：缓存16波束降维数据，按打包顺序并行输出4天线偶/奇天线数据。
+ tb：测试顶层及仿真所需其他文件

#### 使用方法
+ 使用方法
    1. 将Modelsim的安装目录的win64文件夹加入系统环境变量PATH，点击sim文件夹中的.bat文件
    2. 运行结束后，会在pdsch_dr_128ants_tb_work文件夹产生数据文件
    3. 运行Matlab程序dr128_vector_vfy.m进行数据分析
+ 使用方法2：打开ModleSim，在下方tcl界面输入do run_pdsch_dr_128ants_vsim.do，其他步骤同上。