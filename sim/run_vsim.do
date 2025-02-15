
set TOP_LEVEL_NAME "mac_beams_tb"


if ![info exists WORK_DIR] { 
    set CURRENT_DIR  [pwd]
    set WORK_DIR  $TOP_LEVEL_NAME\_work

    # 创建工作目录
    if ![file exists $WORK_DIR] {
        mkdir $WORK_DIR
    }
    # 进入工作目录
    cd $WORK_DIR
} else {
    set CURRENT_DIR  [file dirname [pwd]]
}

# 得到当前工作路径
set QSYS_SIMDIR $CURRENT_DIR/sim_script



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
vlog -f $CURRENT_DIR/$TOP_LEVEL_NAME.files




# 仿真
# vsim -coverage -novopt fifo_asy_tb
vsim -voptargs=+acc $TOP_LEVEL_NAME 

# elab



# 添加波形
if [file exists $CURRENT_DIR/$TOP_LEVEL_NAME\_wave.do] {
    source $CURRENT_DIR/$TOP_LEVEL_NAME\_wave.do
} else {
    add wave -r /*
}



# 运行仿真
run 10us

# coverage report -file ../dut_tb_report.txt
# coverage save ../dut_tb_ucdb

# quit