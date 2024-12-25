# --------------------------------------------------
# NEWHUI @ 2014
# ModelSim simulation script
# --------------------------------------------------
# top-level testbench name
set TOP_LEVEL_NAME "pusch_dr_top_dz_tb"

# top-level testbench file directory
set TB_DIR "../../tb"
set TB_FILE $TB_DIR/$TOP_LEVEL_NAME.sv

# 创建仿真文件夹
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

# 建库
vlib work

# compile quartus eda simulation files
dev_com


# 编译文件
vlog $TB_FILE
vlog -f $CURRENT_DIR/design.files
vlog -work work -refresh -force_refresh


# 仿真
vsim -voptargs=+acc  -L altera_lnsim_ver -L altera_mf_ver $TOP_LEVEL_NAME 



# 添加波形
if [file exists $CURRENT_DIR/$TOP_LEVEL_NAME\_wave.do] {
    source $CURRENT_DIR/$TOP_LEVEL_NAME\_wave.do
} else {
    add wave -r /*
}


# 运行仿真
run -all
