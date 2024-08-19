clc; clear all; close all;

%% 参数设置
numBeam = 16;
numAnts = 64;
numPrb = 132;
numCarriers = numPrb*12;
numSymbols = 14;

ReGenerateData = 0;
WriteFile = 0;
ReloadData = 1;

%% 激励数据产生
if ReGenerateData
    codeWord = exp(1i*randn([numBeam,numAnts]));
    antData  = exp(1i*randn([numAnts,numCarriers]));
    
    
    save("data64ants/codeWord.mat","codeWord");
    save("data64ants/antData.mat","antData");
    
    % Quarlize
    codeWord_fix = quantize(quantizer('fix',[16,15]),codeWord)*2^15;
    antData_fix = quantize(quantizer('fix',[16,15]),antData)*2^15;
    
    save("data64ants/codeWord_fix.mat","codeWord_fix");
    save("data64ants/antData_fix.mat","antData_fix");
else
    load("data64ants/codeWord_fix.mat");
    load("data64ants/antData_fix.mat");
end


%% 激励写入文件
if WriteFile
    write2file_fcn('../sim/mac_beams_tb_work/ant_data_odd.txt',(antData_fix(1:2:end,:)).');
    write2file_fcn('../sim/mac_beams_tb_work/ant_data_even.txt',(antData_fix(2:2:end,:)).');

    write2file_fcn('../sim/mac_beams_tb_work/code_word_odd.txt',codeWord_fix(:,1:2:end));
    write2file_fcn('../sim/mac_beams_tb_work/code_word_even.txt',codeWord_fix(:,2:2:end));
end



if ReloadData
    datafile1='../sim/mac_beams_tb_work/beam_data_odd.txt';
    datafile2='../sim/mac_beams_tb_work/beam_data_even.txt';
    datafile3='../sim/mac_beams_tb_work/beam_data.txt';

    sim_beam_odd =ReadData(datafile1,48,11);
    sim_beam_even=ReadData(datafile2,48,11);
    sim_beam_all =ReadData(datafile3,48,13);
else
    load("data64ants/sim_beam.mat");
end



%% 结果比对
for ci = 1:1%numCarriers
    for bi = 1:numBeam
        re_cmpy(bi,:)=codeWord_fix(bi,:) .* antData_fix(:,ci).';
    end
    cmpy_sum(:,ci) = sum(re_cmpy,2);
    cmpy_sum_odd(:,ci) = sum(re_cmpy(:,1:2:end),2);
    cmpy_sum_even(:,ci) = sum(re_cmpy(:,2:2:end),2);
end

cmpy_sum_odd_scale = cmpy_sum_odd/2^4;
cmpy_sum_even_scale = cmpy_sum_even/2^4;

sum_data = codeWord_fix * antData_fix;
sum_data_scale = floor(sum_data);

sum_data_odd  = floor((codeWord_fix(:,1:2:end) * antData_fix(1:2:end,:)));
sum_data_even = floor((codeWord_fix(:,2:2:end) * antData_fix(2:2:end,:)));
sum_data_all = sum_data_odd + sum_data_even;


SIM_LEN = length(sim_beam_odd);
err_odd = sum_data_odd(:,1:SIM_LEN).' - sim_beam_odd;
err_even= sum_data_even(:,1:SIM_LEN).' - sim_beam_even;
err_sum = sum_data_all(:,1:length(sim_beam_all)).' - sim_beam_all;
fprintf('err odd  = %.2f\n',sum(err_odd ));
fprintf('err even = %.2f\n',sum(err_even));
fprintf('err sum  = %.2f\n',sum(err_sum));


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










