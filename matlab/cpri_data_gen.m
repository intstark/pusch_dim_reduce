clc; clear all; close all;

%% 参数设置
numBeam = 16;
numAnts = 64;
numPrb = 132;
numCarriers = numPrb*12;
numSymbols = 14;

ReGenerateData = 0;
WriteFile = 0;
ReloadData = 0;


data_ii = repmat([63:-1:0 0:-1:-63 -62:1:-59], 1, 12);
data_qq = repmat([-63:1:0 0:1:63 62:-1:59], 1, 12);


uint_ii = data_ii + (data_ii<0)*2^7;
uint_qq = data_qq + (data_qq<0)*2^7;


uint_iq = uint_ii+1i*uint_qq;
data_iq = (data_ii + 1i*data_qq).';

%% 激励写入文件
if WriteFile
    write2file_fcn('../sim/cpri_package_loop_tb_work/iq_data.txt',(uint_iq).');
end



datafile1='../sim/cpri_package_loop_tb_work/ant_data.txt';
sim_ant_data =ReadData(datafile1,16,1);

rep = [sim_ant_data(:,1); sim_ant_data(:,5)];

err = rep(1:length(data_iq))-data_iq;

%% 相关函数

% 写仿真激励文件
function write2file_fcn(desfile,WrData)
    fid=fopen(desfile,'w');
    
    [r,c] = size(WrData);
    for sr= 1:r
            fprintf('%d,',real(WrData(sr,:)),imag(WrData(sr,:)));
            fprintf('\n');
            puts = sprintf('%d,',real(WrData(sr,:)),imag(WrData(sr,:)));
            fwrite(fid,puts);
            fwrite(fid,newline);
    end
    
    fclose(fid);

end

% 读取仿真波形文件
function sim_beam=ReadData(datafile,BITW,headLines)
%     des_path='../sim/mac_beams_tb_work/beam_data_odd.txt';
%     BITW=36;

    [fpath,fname,fext] = fileparts(datafile);

    sim_data=importdata(datafile,',',headLines);
    sim_signed=sim_data.data-(sim_data.data>=2^(BITW-1))*2^BITW;
    
    sim_beam_re=sim_signed(:,1:2:end);
    sim_beam_im=sim_signed(:,2:2:end);
    
    sim_beam=sim_beam_re+1i*sim_beam_im;
    save(sprintf("data64ants/%s.mat",fname),"sim_beam");

end










