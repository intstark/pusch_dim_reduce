clc; clear all; close all;

%% 参数设置
numBeam = 64;
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



%% 激励数据产生
if ReGenerateData
    codeWord = exp(1i*randn([numBeam,numAnts]));

    % Quarlize
    codeWord_fix = quantize(quantizer('fix',[16,15]),codeWord)*2^15;

    save("data64ants/codeWord64.mat","codeWord");
    save("data64ants/codeWord64_fix.mat","codeWord_fix");
else
    load("data64ants/codeWord64_fix.mat");
end

cw_eve = codeWord_fix(:,1:2:end);
cw_odd = codeWord_fix(:,2:2:end);

%% 激励写入文件
if WriteFile
    write2file_fcn('../sim/dl_ul_beams_tb_work/code_word_even.txt',cw_eve);
    write2file_fcn('../sim/dl_ul_beams_tb_work/code_word_odd.txt' ,cw_odd);
end



%% 激励写入文件
if WriteFile
    write2file_fcn('../sim/dl_ul_beams_tb_work/iq_data.txt',(dl_data).');
end

% load("data64ants/codeWord_fix.mat");



if ReloadData
    datafile1='../sim/dl_ul_beams_tb_work/des_tx_data.txt';
    datafile2='../sim/dl_ul_beams_tb_work/des_rx_data.txt';
    datafile3='../sim/dl_ul_beams_tb_work/des_unzip_data.txt';
    datafile4='../sim/dl_ul_beams_tb_work/des_beams_data.txt';
    datafile5='../sim/dl_ul_beams_tb_work/des_beams_pwr.txt';
    datafile6='../sim/dl_ul_beams_tb_work/des_beams_sort.txt';
    
    [sim_tx_data,tx_cmpy,tx_agc] = ReadZipData(datafile1,0);
    [sim_rx_data,rx_cmpy,rx_agc]  = ReadZipData(datafile2,0);
    sim_unzip_data = ReadData(datafile3,16,0,'IQ');
    sim_beams_data = ReadData(datafile4,48,0);
    sim_beams_pwr  = ReadData(datafile5,48,0);
    sim_beams_sort  = ReadData(datafile6,48,0);
end


% sim_beam_odd_frac = ReadDataFrac(datafile2,7,7,0);
% sim_beam_odd_frac_exp = sim_beam_odd_frac*2^3;
% 
% sim_beam_even_frac = ReadDataFrac(datafile1,16,14,0);
% sim_beam_frac = ReadDataFrac(datafile3,16,14,0);



LEN=length(sim_tx_data);
LEN=3168;

err1 = sim_tx_data(1:LEN,:) - sim_rx_data(1:LEN,:);
err1_sum=sum(abs(err1),[1,2]);
fprintf("发送与接收数据+AGC:\t err1_sum = %d\n",err1_sum);


err2 = tx_cmpy(1:LEN,:) - rx_cmpy(1:LEN,:);
err2_sum=sum(abs(err2),[1,2]);
fprintf("发送与接收数据(7bit):\t err2_sum = %d\n",err2_sum);

err3 = tx_agc(1:LEN,:) - rx_agc(1:LEN,:);
err3_sum=sum(abs(err3),[1,2]);
fprintf("发送与接收AGC(4bit):\t err3_sum = %d\n",err3_sum);

err4 = sim_unzip_data(1:LEN,:) - sim_tx_data(1:LEN,:);
err4_sum=sum(abs(err4),[1,2]);
fprintf("解压后与发送前(16bit):\t err4_sum = %d\n",err4_sum);


%% 波束计算

% 分离出发送端的奇偶天线数据（单Lane 8天线）
ant4_tx_eve = sim_tx_data(1:numCarriers,:);
ant4_tx_odd = sim_tx_data(numCarriers+1:2*numCarriers,:);

% 复制扩展成8 Lane 64天线数据
ant32_tx_eve = repmat(ant4_tx_eve,1,8);
ant32_tx_odd = repmat(ant4_tx_odd,1,8);


% Debug: 波束1中，各个天线与码本乘积（未求和）
for ii= 1:numCarriers
    beams_eve_re(ii,:,:) = ant32_tx_eve(ii,:) .* cw_eve;
    beams_odd_re(ii,:,:) = ant32_tx_odd(ii,:) .* cw_odd;
end

beams_eve_abs = abs(real(beams_eve_re)) + abs(imag(beams_eve_re));
beams_odd_abs = abs(real(beams_odd_re)) + abs(imag(beams_odd_re));

for ii= 1:numCarriers
    beams_eve_sum(ii,:)=sum(beams_eve_abs(ii,:,:),3);
    beams_odd_sum(ii,:)=sum(beams_odd_abs(ii,:,:),3);
end
beams_sum = beams_eve_sum + beams_odd_sum;


SIM_BEAMS = length(sim_beams_data(:,1));

numBeamBlk = 4; %floor(SIM_BEAMS/numCarriers);

for ii=1:numBeamBlk
    sim_beams_eve(:,(ii-1)*16+1:ii*16) = sim_beams_data((ii-1)*numCarriers+1:ii*numCarriers,1:2:end);
    sim_beams_odd(:,(ii-1)*16+1:ii*16) = sim_beams_data((ii-1)*numCarriers+1:ii*numCarriers,2:2:end);
end


err_beam_eve = beams_eve_sum(:,1:16*numBeamBlk) - sim_beams_eve;
err_beam_odd = beams_odd_sum(:,1:16*numBeamBlk) - sim_beams_odd;
err_beam_eve_sum=sum(abs(err_beam_eve),[1,2]);
err_beam_odd_sum=sum(abs(err_beam_odd),[1,2]);


fprintf("波束计算偶天线(48bit):\t err_beam_eve_sum = %d\n",err_beam_eve_sum);
fprintf("波束计算奇天线(48bit):\t err_beam_odd_sum = %d\n",err_beam_odd_sum);


%% rbG能量和计算

rbGSize=16;
numRE_rbG = rbGSize*12;
rbGMaxNum = ceil(numPrb/rbGSize);
rbGMaxMod = mod(numPrb,rbGSize);
aiu_idx = 1; % AIU编号识别

for bb= 1:64
    pwt = 0;
    for ii=1:1:rbGMaxNum
        % 前132PRB 不完整的rbG放在开头
        if(ii==1 && aiu_idx==0)
            rbG_sum(ii,bb) = sum(beams_sum(pwt+1:rbGMaxMod*12, bb));
            pwt = rbGMaxMod*12;
        % 后132PRB 不完整的rbG放在末尾
        elseif(ii==rbGMaxNum && aiu_idx==1)
            rbG_sum(ii,bb) = sum(beams_sum(pwt+1:pwt+rbGMaxMod*12, bb));
            pwt = rbGMaxMod*12;
        else
            rbG_sum(ii,bb) = sum(beams_sum(pwt+1:pwt+numRE_rbG,bb));
            pwt = pwt + numRE_rbG;
        end
    end
end

err_beam_pwr = sum(sim_beams_pwr(1:rbGMaxNum,:) - rbG_sum,[1,2]);
fprintf("rbG总能量(48bit):\t err_beam_pwr = %d\n",err_beam_pwr);


%% rbG能量排序
%  对SYMBOL1的64 Beam能能在一个rbG内的所有能量从大到小排序

[rbG_sort_sum, rbG_sort_addr] = sort(rbG_sum,2,'descend');
rbG_sort_addr = rbG_sort_addr - 1;

err_beam_sort = sum(sim_beams_sort(1:rbGMaxNum,:) - rbG_sort_sum,[1,2]);
fprintf("rbG总能量排序(48bit):\t err_beam_sort = %d\n",err_beam_sort);


%% 后续符号运算
%  采用对SYMBOL1筛选出来的最大16beam序号的码本与天线数据相乘降维，每个rbG不同
clear beams_eve_re;
clear beams_odd_re;
clear beams_eve_abs;
clear beams_odd_abs;
clear beams_eve_sum;
clear beams_odd_sum;
clear sim_beams_eve;
clear sim_beams_odd;
clear err_beam_eve;
clear err_beam_odd;


% 分离出发送端的奇偶天线数据（单Lane 8天线）
ant4_tx_eve = sim_tx_data(2*numCarriers+1:3*numCarriers,:);
ant4_tx_odd = sim_tx_data(3*numCarriers+1:4*numCarriers,:);

% 复制扩展成8 Lane 64天线数据
ant32_tx_eve = repmat(ant4_tx_eve,1,8);
ant32_tx_odd = repmat(ant4_tx_odd,1,8);


pwt = 0;
for jj=1:rbGMaxNum
    for ii=1:16
        codeWord16_fix(ii,:) = codeWord_fix(rbG_sort_addr(jj,ii)+1,:);
    end

    % 奇偶码本
    cw_eve = codeWord16_fix(:,1:2:end);
    cw_odd = codeWord16_fix(:,2:2:end);


    % 前132PRB 不完整的rbG放在开头
    if(jj==1 && aiu_idx==0)
        % Debug: 波束1中，各个天线与码本乘积（未求和）
        for kk= pwt+1:rbGMaxMod*12
            beams_eve_re(kk,:,:) = ant32_tx_eve(kk,:) .* cw_eve;
            beams_odd_re(kk,:,:) = ant32_tx_odd(kk,:) .* cw_odd;
        end
        pwt = rbGMaxMod*12;

    % 后132PRB 不完整的rbG放在末尾
    elseif(jj==rbGMaxNum && aiu_idx==1)
        % Debug: 波束1中，各个天线与码本乘积（未求和）
        for kk= pwt+1:pwt+rbGMaxMod*12
            beams_eve_re(kk,:,:) = ant32_tx_eve(kk,:) .* cw_eve;
            beams_odd_re(kk,:,:) = ant32_tx_odd(kk,:) .* cw_odd;
        end
        pwt = rbGMaxMod*12;
    else
        % Debug: 波束1中，各个天线与码本乘积（未求和）
        for kk= pwt+1:pwt+numRE_rbG
            beams_eve_re(kk,:,:) = ant32_tx_eve(kk,:) .* cw_eve;
            beams_odd_re(kk,:,:) = ant32_tx_odd(kk,:) .* cw_odd;
        end
        pwt = pwt + numRE_rbG;
    end
end


beams_eve_abs = abs(real(beams_eve_re)) + abs(imag(beams_eve_re));
beams_odd_abs = abs(real(beams_odd_re)) + abs(imag(beams_odd_re));


for ii= 1:numCarriers
    beams_eve_sum(ii,:)=sum(beams_eve_abs(ii,:,:),3);
    beams_odd_sum(ii,:)=sum(beams_odd_abs(ii,:,:),3);
end
beams_sum = beams_eve_sum + beams_odd_sum;


SIM_BEAMS = length(sim_beams_data(:,1));

numBeamBlk = 1;

for ii=1:numBeamBlk
    sim_beams_eve(:,(ii-1)*16+1:ii*16) = sim_beams_data((ii-1+4)*numCarriers+1:(ii+4)*numCarriers,1:2:end);
    sim_beams_odd(:,(ii-1)*16+1:ii*16) = sim_beams_data((ii-1+4)*numCarriers+1:(ii+4)*numCarriers,2:2:end);
end


err_beam_eve = beams_eve_sum(:,1:16*numBeamBlk) - sim_beams_eve;
err_beam_odd = beams_odd_sum(:,1:16*numBeamBlk) - sim_beams_odd;
err_beam_eve_sum=sum(abs(err_beam_eve),[1,2]);
err_beam_odd_sum=sum(abs(err_beam_odd),[1,2]);


fprintf("第2个符号，波束能量(48bit):\t err_beam_eve_sum = %d\n",err_beam_eve_sum);
fprintf("第2个符号，波束能量(48bit):\t err_beam_odd_sum = %d\n",err_beam_odd_sum);


%% 分析完毕
fprintf("#----------------------------------------------------------\n");
fprintf("# 分析完毕！\n");
fprintf("#----------------------------------------------------------\n");







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

    uint_data_i = sim_data(:,1:3:end);
    uint_data_q = sim_data(:,2:3:end);
    agc_data    = sim_data(:,3:3:end);

    sint_data_i=uint_data_i-(uint_data_i>=2^(DBITW-1))*2^DBITW;
    sint_data_q=uint_data_q-(uint_data_q>=2^(DBITW-1))*2^DBITW;
    
    

    sint_cmpy = sint_data_i +1i*sint_data_q;
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
function sim_beam=ReadData(datafile,BITW,headLines,varargin)

    [fpath,fname,fext] = fileparts(datafile);

    if headLines<=0
        sim_data=importdata(datafile,',');
        sim_signed=sim_data-(sim_data>=2^(BITW-1))*2^BITW;
    else
        sim_data=importdata(datafile,',',headLines);
        sim_signed=sim_data.data-(sim_data.data>=2^(BITW-1))*2^BITW;
    end

    if(nargin>3)
        if(varargin{1}=="IQ")  
            sim_beam=sim_signed(:,1:2:end)+1i*sim_signed(:,2:2:end);
        else
            sim_beam=sim_signed;
        end
    else
        sim_beam=sim_signed;
    end
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










