

# 得到当前工作路径
set QSYS_SIMDIR ./sim_script


# quartus env
do $QSYS_SIMDIR/mentor/msim_setup.tcl


# compile quartus eda simulation files
#dev_com

# compile quartus-generated IP simulation files
#com

# 建库
vlib work


# 编译文件
# vlog -f bf_tb.sv -incr -cover bcestf
vlog -f tb_filelist.f

set TOP_LEVEL_NAME "mac_ants_tb"


# 仿真
# vsim -coverage -novopt fifo_asy_tb
vsim -voptargs=+acc mac_ants_tb

# elab



# 添加波形
# add wave *

source wave.do
# source wave_bf_top.do


# 运行仿真
run 10us

# coverage report -file ../dut_tb_report.txt
# coverage save ../dut_tb_ucdb

# quit