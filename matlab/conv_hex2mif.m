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
aiu_idx = 1;    % AIU编号识别
width = 64;
depth = 44352;

vector_dir1 = '../../../../AlgoVec/ulrxDimRedu-0109';
fpga_dir   = sprintf('pusch_group%d_mif',(aau_idx*2+aiu_idx));

for ii=1:8
    data_in1 = sprintf('%s/data_beforeDimRedu/pusch_group%d/LAN%d.txt',vector_dir1,(aau_idx*2+aiu_idx),ii);
    fprintf('读取文件:\t%s\n',data_in1);


    fid=fopen(data_in1);
    data_cell1=textscan(fid,'%s');
    fclose(fid);


    data_cell = data_cell1;

    c=length(data_cell);
    r=length(data_cell1{1});
    
    data_out = sprintf('%s/LAN%d.mif',fpga_dir,ii);
    fprintf('写入文件:\t%s\n',data_out);
    fdes=fopen(data_out,'w');

    puts = sprintf('WIDTH = %d;\nDEPTH = %d;\n\nADDRESS_RADIX = UNS;\nDATA_RADIX =HEX;\n\n',...
        width, depth);
    fwrite(fdes,puts);
    
    puts = sprintf('CONTENT BEGIN\n');
    fwrite(fdes,puts);



    for ii=1:c
        for jj=1:depth
            temp = data_cell{1,1}{jj,1};
            fprintf('\t%d\t:\t%s;\n',jj-1,temp);
            puts = sprintf('\t%d\t:\t%s;\n', jj-1, temp);
            fwrite(fdes,puts);
        end
    end
    puts = sprintf('END;\n');
    fwrite(fdes,puts);
    
    fclose(fdes);
end


