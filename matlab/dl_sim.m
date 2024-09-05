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
    write2file_fcn('../sim/dl_ul_tb_work/iq_data.txt',(dl_data).');
end

load("data64ants/codeWord_fix.mat");



if ReloadData
    datafile1='../sim/dl_ul_tb_work/des_tx_data.txt';
    datafile2='../sim/dl_ul_tb_work/des_rx_data.txt';
    datafile3='../sim/dl_ul_tb_work/des_unzip_data.txt';
    
    [sim_tx_data,tx_cmpy,tx_agc] = ReadZipData(datafile1,0);
    [sim_rx_data,rx_cmpy,rx_agc]  = ReadZipData(datafile2,0);
    sim_unzip_data = ReadData(datafile3,16,0);
end


% sim_beam_odd_frac = ReadDataFrac(datafile2,7,7,0);
% sim_beam_odd_frac_exp = sim_beam_odd_frac*2^3;
% 
% sim_beam_even_frac = ReadDataFrac(datafile1,16,14,0);
% sim_beam_frac = ReadDataFrac(datafile3,16,14,0);



LEN=length(sim_tx_data);
LEN=3168;
err1 = sim_tx_data(1:LEN) - sim_rx_data(1:LEN);
err1_sum=sum(abs(err1));
fprintf("发送与接收数据+AGC:\t err1_sum = %d\n",err1_sum);


err2 = tx_cmpy(1:LEN) - rx_cmpy(1:LEN);
err2_sum=sum(abs(err2));
fprintf("发送与接收数据(7bit):\t err2_sum = %d\n",err2_sum);

err3 = tx_agc(1:LEN) - rx_agc(1:LEN);
err3_sum=sum(abs(err3));
fprintf("发送与接收AGC(4bit):\t err3_sum = %d\n",err3_sum);

err4 = sim_unzip_data(1:LEN) - sim_tx_data(1:LEN);
err4_sum=sum(abs(err4));
fprintf("解压后与发送前(16bit):\t err4_sum = %d\n",err4_sum);



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

% 读取压缩IQ数据及AGC，格式COL=I|Q|AGC
function [sint_unzip_cmpy,sint_cmpy,agc_data]=ReadZipData(datafile,headLines)
    DBITW = 7;

    [fpath,fname,fext] = fileparts(datafile);

    if headLines<=0
        data_in=importdata(datafile,',');
        sim_data=data_in;
    else
        data_in=importdata(datafile,',',headLines);
        sim_data=data_in.data;
    end

    uint_data = sim_data(:,1:end-1);
    sint_data=uint_data-(uint_data>=2^(DBITW-1))*2^DBITW;
    
    agc_data = sim_data(:,end);

    sint_cmpy = sint_data(:,1:2:end) +1i*sint_data(:,2:2:end);
    sint_unzip_cmpy = sint_cmpy .* (2.^agc_data);

    save(sprintf("data64ants/%s.mat",fname),"sint_unzip_cmpy",...
                "sint_cmpy","agc_data");
end



% 读取无符号/有符号数
function [uint_data,sint_data]=ReadUint(datafile,BITW,headLines)

    [fpath,fname,fext] = fileparts(datafile);

    if headLines<=0
        data_in=importdata(datafile,',');
        uint_data=data_in;
    else
        data_in=importdata(datafile,',',headLines);
        uint_data=data_in.data;
    end

    sint_data=uint_data-(uint_data>=2^(BITW-1))*2^BITW;

    save(sprintf("data64ants/%s.mat",fname),"sint_data","uint_data");
end

% 读取有符号整型IQ数据，格式COL=I0|Q0|....In|Qn
function sim_beam=ReadData(datafile,BITW,headLines)

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


% 读取有符号定点IQ数据，格式COL=I0|Q0|....In|Qn
function sim_beam=ReadDataFrac(datafile,S,Q,headLines)

    [fpath,fname,fext] = fileparts(datafile);

    if headLines<=0
        sim_data=importdata(datafile,',');
        sim_signed=sim_data-(sim_data>=2^(S-1))*2^S;
    else
        sim_data=importdata(datafile,',',headLines);
        sim_signed=sim_data.data-(sim_data.data>=2^(S-1))*2^S;
    end
    
    sim_beam_re=sim_signed(:,1:2:end)*2^(0-Q);
    sim_beam_im=sim_signed(:,2:2:end)*2^(0-Q);
    
    sim_beam=sim_beam_re+1i*sim_beam_im;
    save(sprintf("data64ants/%s.mat",fname),"sim_beam");
end










