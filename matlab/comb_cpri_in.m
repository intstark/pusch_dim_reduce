%--------------------------------------------------------------------------
% Author：NEWHUI
% Date  ：2024/12/12
% 本程序是用于合并CPRI输入的16进制数据
% 输入向量：
%           1. 多个8 Lane CPRI数据
% 输出向量：
%           1. 1个8 Lane CPRI数据
%
%--------------------------------------------------------------------------

clc;clear all;close all;


aau_idx = 0;    % AAU编号识别
aiu_idx = 0;    % AIU编号识别

vector_dir1 = '../../../AlgoVec/ulrxDimRedu-1209';
vector_dir2 = '../../../AlgoVec/ulrxDimRedu-1213';
fpga_dir   = '../vfy/vector/datain';

for ii=1:8
    data_in1 = sprintf('%s/data_beforeDimRedu/pusch_group%d/LAN%d.txt',vector_dir1,(aau_idx+aiu_idx),ii);
    data_in2 = sprintf('%s/data_beforeDimRedu/pusch_group%d/LAN%d.txt',vector_dir2,(aau_idx+aiu_idx),ii);
    fprintf('读取文件:\t%s\n',data_in1);


    fid=fopen(data_in1);
    data_cell1=textscan(fid,'%s');
    fclose(fid);

    fid=fopen(data_in2);
    data_cell2=textscan(fid,'%s');
    fclose(fid);

    data_cell = {data_cell1,data_cell2,data_cell1,data_cell2};

    c=length(data_cell);
    r=length(data_cell1{1});
    
    data_out = sprintf('%s/LAN%d.txt',fpga_dir,ii);
    fprintf('写入文件:\t%s\n',data_out);
    fdes=fopen(data_out,'w');

    for ii=1:c
        for jj=1:r
            temp = data_cell{1,ii}{1,1}{jj,1};
            fprintf('%s\n',temp);
            puts = sprintf('%s\n',temp);
            fwrite(fdes,puts);
        end
    end
    fclose(fdes);
end

