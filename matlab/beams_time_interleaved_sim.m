clc; clear all; close all;

%% 参数设置
numBeam = 16;
numAnts = 64;
numPrb = 132;
numCarriers = numPrb*12;
numSymbols = 14;

ReGenerateData = 0;
WriteFile = 1;
ReloadData = 0;



data_ii = repmat([63:-1:0 0:-1:-63 -62:1:-59], 1, 12);
data_qq = repmat([-63:1:0 0:1:63 62:-1:59], 1, 12);

uint_ii = data_ii + (data_ii<0)*2^7;
uint_qq = data_qq + (data_qq<0)*2^7;


uint_iq = uint_ii+1i*uint_qq;
data_iq = (data_ii + 1i*data_qq).';


uint_iq2 = repmat([47:-1:0], 1, 33) + 1i*(repmat([0:1:47], 1, 33));


dl_data = [uint_iq uint_iq2 uint_iq2 uint_iq];


%% 激励写入文件
if WriteFile
    write2file_fcn('../sim/beams_time_interleaced_tb_work/iq_data.txt',(dl_data).');
end

load("data64ants/codeWord_fix.mat");



if ReloadData
datafile1='../sim/beams_time_interleaced_tb_work/beam_data_even.txt';
datafile2='../sim/beams_time_interleaced_tb_work/beam_data_odd.txt';
datafile3='../sim/beams_time_interleaced_tb_work/beam_data.txt';

sim_beam_even=ReadData(datafile1,48,0);
sim_beam_even = sim_beam_even.';

sim_beam_odd=(ReadData(datafile2,48,0)).';
sim_beam_all=(ReadData(datafile3,48,2)).';




data_iq_0 = (repmat([0+1i*0; data_iq(1:end-1)],1,32)).';
data_iq_1 = (repmat([data_iq(end); data_iq(1:end-1)],1,32)).';



antData_fix = (repmat(data_iq,1,64)).';
sum_data_even  = floor((codeWord_fix(:,1:2:end) * data_iq_0));
sum_data_odd = floor((codeWord_fix(:,2:2:end) * data_iq_1));
sum_data_all = sum_data_odd + sum_data_even;

err_even = sim_beam_even - sum_data_even(:,1:length(sim_beam_even));
err_odd = sim_beam_odd - sum_data_odd(:,1:length(sim_beam_odd));
err_sum = sim_beam_all - sum_data_all(:,1:length(sim_beam_all));
fprintf('err odd  = %.2f\n',sum(err_odd ,'all'));
fprintf('err even = %.2f\n',sum(err_even,'all'));
fprintf('err sum  = %.2f\n',sum(err_sum ,'all'));
end


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

    if headLines<=0
        sim_data=importdata(datafile,',');
        sim_signed=sim_data-(sim_data>=2^(BITW-1))*2^BITW;
    else
        sim_data=importdata(datafile,',',headLines);
        sim_signed=sim_data.data-(sim_data.data>=2^(BITW-1))*2^BITW;
    end

    
    
    sim_beam_re=sim_signed(:,1:2:end);
    sim_beam_im=sim_signed(:,2:2:end);
    
    sim_beam=sim_beam_re+1i*sim_beam_im;
    save(sprintf("data64ants/%s.mat",fname),"sim_beam");

end










