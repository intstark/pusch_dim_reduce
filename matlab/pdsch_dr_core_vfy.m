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

MAC_DW = 40;



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
    write2file_fcn('../vfy/pdsch_dr_core_tb_work/code_word_even.txt',cw_eve);
    write2file_fcn('../vfy/pdsch_dr_core_tb_work/code_word_odd.txt' ,cw_odd);
end



if ReloadData
    datafile0='../vfy/vector/dl_data_sim.txt';
    datafile1='../vfy/pdsch_dr_core_tb_work/des_tx_data.txt';
    datafile2='../vfy/pdsch_dr_core_tb_work/des_rx_data.txt';
    datafile3='../vfy/pdsch_dr_core_tb_work/des_unzip_data.txt';
    datafile4='../vfy/pdsch_dr_core_tb_work/des_beams_data.txt';
    datafile5='../vfy/pdsch_dr_core_tb_work/des_beams_pwr.txt';
    datafile6='../vfy/pdsch_dr_core_tb_work/des_beams_sort.txt';
    datafile7='../vfy/pdsch_dr_core_tb_work/des_beams_idx.txt';
    
    ant_datain =ReadHexData(datafile0,16);
    sim_beams_data = ReadData(datafile4,MAC_DW,0);
    sim_beams_pwr  = ReadData(datafile5,MAC_DW,0);
    sim_beams_sort = ReadData(datafile6,MAC_DW,0);
    sim_beams_idx  = ReadData(datafile7,8,0);
end


%% 波束计算

% 分离出发送端的奇偶天线数据（单Lane 8天线）
ant4_tx_eve = ant_datain(1:numCarriers,:);
ant4_tx_odd = ant_datain(numCarriers+1:2*numCarriers,:);

% 复制扩展成8 Lane 64天线数据
ant32_tx_eve = repmat(ant4_tx_eve,1,8);
ant32_tx_odd = repmat(ant4_tx_odd,1,8);


% 32奇偶天线数据和码本数据矩阵相乘
beams_eve = ant32_tx_eve * cw_eve.';
beams_odd = ant32_tx_odd * cw_odd.';

beams_sum = beams_eve + beams_odd;


SIM_BEAMS = length(sim_beams_data(:,1));

numBeamBlk = 4; %floor(SIM_BEAMS/numCarriers);

for ii=1:numBeamBlk
    sim_beams_eve_i(:, (ii-1)*16+1:ii*16) = sim_beams_data((ii-1)*numCarriers+1:ii*numCarriers, 1:4:end);
    sim_beams_eve_q(:, (ii-1)*16+1:ii*16) = sim_beams_data((ii-1)*numCarriers+1:ii*numCarriers, 2:4:end);
    sim_beams_odd_i(:, (ii-1)*16+1:ii*16) = sim_beams_data((ii-1)*numCarriers+1:ii*numCarriers, 3:4:end);
    sim_beams_odd_q(:, (ii-1)*16+1:ii*16) = sim_beams_data((ii-1)*numCarriers+1:ii*numCarriers, 4:4:end);
end

sim_beams_eve = sim_beams_eve_i + 1i*sim_beams_eve_q;
sim_beams_odd = sim_beams_odd_i + 1i*sim_beams_odd_q;

err_beam_eve = beams_eve(:,1:16*numBeamBlk) - sim_beams_eve;
err_beam_odd = beams_odd(:,1:16*numBeamBlk) - sim_beams_odd;
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


beams_sum_scale = floor(beams_sum/2^8);

beams_sum_abs = abs(real(beams_sum_scale)) +abs(imag(beams_sum_scale));

for bb= 1:64
    pwt = 0;
    for ii=1:1:rbGMaxNum
        % 前132PRB 不完整的rbG放在开头
        if(ii==1 && aiu_idx==0)
            rbG_sum(ii,bb) = sum(beams_sum_abs(pwt+1:rbGMaxMod*12, bb));
            pwt = rbGMaxMod*12;
        % 后132PRB 不完整的rbG放在末尾
        elseif(ii==rbGMaxNum && aiu_idx==1)
            rbG_sum(ii,bb) = sum(beams_sum_abs(pwt+1:pwt+rbGMaxMod*12, bb));
            pwt = rbGMaxMod*12;
        else
            rbG_sum(ii,bb) = sum(beams_sum_abs(pwt+1:pwt+numRE_rbG,bb));
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

err_sort_idx = sim_beams_idx - rbG_sort_addr(:,1:16);
fprintf("rbG能量序号(8bit):\t err_beam_sort = %d\n",sum(err_sort_idx,[1,2]));


err_beam_sort = sum(sim_beams_sort(1:rbGMaxNum,:) - rbG_sort_sum,[1,2]);
fprintf("rbG总能量排序(48bit):\t err_beam_sort = %d\n",err_beam_sort);


% for ii=1:16
%     beams16_sorted(:,ii) = beams_sum(:,rbG_sort_addr(1,ii)+1);
% end
% 
% save('beams16_sorted.mat','beams16_sorted');

pwt = 0;
for jj=1:rbGMaxNum
    % 前132PRB 不完整的rbG放在开头
    if(jj==1 && aiu_idx==0)
        for ii=1:16
            beams16_sym1_sort(pwt+1:rbGMaxMod*12, ii) = beams_sum(pwt+1:rbGMaxMod*12,rbG_sort_addr(jj,ii)+1);
        end        
        pwt = rbGMaxMod*12;

    % 后132PRB 不完整的rbG放在末尾
    elseif(jj==rbGMaxNum && aiu_idx==1)
        for ii=1:16
            beams16_sym1_sort(pwt+1:pwt+rbGMaxMod*12, ii) = beams_sum(pwt+1:pwt+rbGMaxMod*12,rbG_sort_addr(jj,ii)+1);
        end
        pwt = rbGMaxMod*12;
    else
        for ii=1:16
            beams16_sym1_sort(pwt+1:pwt+numRE_rbG, ii) = beams_sum(pwt+1:pwt+numRE_rbG, rbG_sort_addr(jj,ii)+1);
        end
        pwt = pwt + numRE_rbG;
    end
end


%% 动态定标比对
symbol_id =1;
beams_sum_i = real(beams16_sym1_sort);
beams_sum_q = imag(beams16_sym1_sort);

abs_beams_i = abs(beams_sum_i);
abs_beams_q = abs(beams_sum_q);

i_max = max(abs_beams_i,[],[1,2]);
q_max = max(abs_beams_q,[],[1,2]);

iq_max = max([i_max q_max]);

idx = floor(log2(iq_max)+1);


fprintf('i_max\t=\t%d\nq_max\t=\t%d\niq_max\t=\t%d\n',i_max,q_max,iq_max);


factor_shift = idx - 15;


beams_sum_sft = beams16_sym1_sort/2^factor_shift;
beams_sum_sft_fix = round(beams_sum_sft);


datafile1='../vfy/pdsch_dr_core_tb_work/compress_data.txt';
sim_compress_data = ReadData(datafile1,16,0,'IQ');


err_cprs = sim_compress_data((symbol_id-1)*numCarriers+1 : (symbol_id)*numCarriers,:)-beams_sum_sft_fix;

err_cprs_sum=sum(err_cprs,[1,2]);

fprintf('对比误差err_cprs_sum\t=\t%d\n',err_cprs_sum);

%% 后续符号运算
%  采用对SYMBOL1筛选出来的最大16beam序号的码本与天线数据相乘降维，每个rbG不同
clear beams_eve;
clear beams_odd;
clear sim_beams_eve_i;
clear sim_beams_eve_q;
clear sim_beams_odd_i;
clear sim_beams_odd_q;
clear sim_beams_eve;
clear sim_beams_odd;
clear err_beam_eve;
clear err_beam_odd;

symbol_id = 2;


% 分离出发送端的奇偶天线数据（单Lane 8天线）
ant4_tx_eve = ant_datain((2*symbol_id-2)*numCarriers+1 : (2*symbol_id-1)*numCarriers, :);
ant4_tx_odd = ant_datain((2*symbol_id-1)*numCarriers+1 : (2*symbol_id-0)*numCarriers, :);

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

        % 32奇偶天线数据和码本数据矩阵相乘
        beams_eve(pwt+1:rbGMaxMod*12, :) = ant32_tx_eve(pwt+1:rbGMaxMod*12, :) * cw_eve.';
        beams_odd(pwt+1:rbGMaxMod*12, :) = ant32_tx_odd(pwt+1:rbGMaxMod*12, :) * cw_odd.';

        pwt = rbGMaxMod*12;

    % 后132PRB 不完整的rbG放在末尾
    elseif(jj==rbGMaxNum && aiu_idx==1)

        % 32奇偶天线数据和码本数据矩阵相乘
        beams_eve(pwt+1:pwt+rbGMaxMod*12, :) = ant32_tx_eve(pwt+1:pwt+rbGMaxMod*12, :) * cw_eve.';
        beams_odd(pwt+1:pwt+rbGMaxMod*12, :) = ant32_tx_odd(pwt+1:pwt+rbGMaxMod*12, :) * cw_odd.';

        pwt = rbGMaxMod*12;
    else
        % 32奇偶天线数据和码本数据矩阵相乘
        beams_eve(pwt+1:pwt+numRE_rbG, :) = ant32_tx_eve(pwt+1:pwt+numRE_rbG, :) * cw_eve.';
        beams_odd(pwt+1:pwt+numRE_rbG, :) = ant32_tx_odd(pwt+1:pwt+numRE_rbG, :) * cw_odd.';

        pwt = pwt + numRE_rbG;
    end
end

beams_sum = beams_eve + beams_odd;


sim_beams_eve_i(:, 1:16) = sim_beams_data((symbol_id+2)*numCarriers+1 : (symbol_id+3)*numCarriers, 1:4:end);
sim_beams_eve_q(:, 1:16) = sim_beams_data((symbol_id+2)*numCarriers+1 : (symbol_id+3)*numCarriers, 2:4:end);
sim_beams_odd_i(:, 1:16) = sim_beams_data((symbol_id+2)*numCarriers+1 : (symbol_id+3)*numCarriers, 3:4:end);
sim_beams_odd_q(:, 1:16) = sim_beams_data((symbol_id+2)*numCarriers+1 : (symbol_id+3)*numCarriers, 4:4:end);

sim_beams_eve = sim_beams_eve_i + 1i*sim_beams_eve_q;
sim_beams_odd = sim_beams_odd_i + 1i*sim_beams_odd_q;

err_beam_eve = beams_eve - sim_beams_eve;
err_beam_odd = beams_odd - sim_beams_odd;
err_beam_eve_sum=sum(abs(err_beam_eve),[1,2]);
err_beam_odd_sum=sum(abs(err_beam_odd),[1,2]);


fprintf("第%d个符号，波束能量(48bit):\t err_beam_eve_sum = %d\n",symbol_id, err_beam_eve_sum);
fprintf("第%d个符号，波束能量(48bit):\t err_beam_odd_sum = %d\n",symbol_id, err_beam_odd_sum);

%% 动态定标比对
beams_sum_i = real(beams_sum);
beams_sum_q = imag(beams_sum);

abs_beams_i = abs(beams_sum_i);
abs_beams_q = abs(beams_sum_q);

i_max = max(abs_beams_i,[],[1,2]);
q_max = max(abs_beams_q,[],[1,2]);

iq_max = max([i_max q_max]);

idx = floor(log2(iq_max)+1);


fprintf('i_max\t=\t%d\nq_max\t=\t%d\niq_max\t=\t%d\n',i_max,q_max,iq_max);


factor_shift = idx - 15;


beams_sum_sft = beams_sum/2^factor_shift;
beams_sum_sft_fix = round(beams_sum_sft);


datafile1='../vfy/pdsch_dr_core_tb_work/compress_data.txt';
sim_compress_data = ReadData(datafile1,16,0,'IQ');


err_cprs = sim_compress_data((symbol_id-1)*numCarriers+1 : (symbol_id)*numCarriers,:)-beams_sum_sft_fix;

err_cprs_sum=sum(err_cprs,[1,2]);

fprintf('对比误差err_cprs_sum\t=\t%d\n',err_cprs_sum);



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


function signed_data=ReadHexData(data_in,BITW)

    fid=fopen(data_in);
    data_cell=textscan(fid,'%s');
    c=length(data_cell);
    r=length(data_cell{1});

    for ii=1:r
        temp = data_cell{1,1}{ii,1};
        
        for kk=1:4
            hex_i = temp((kk-1)*8+1 : (kk-1)*8+4);
            hex_q = temp((kk-1)*8+5 : (kk-1)*8+8);
            data_i(ii,5-kk)=hex2dec(hex_i);
            data_q(ii,5-kk)=hex2dec(hex_q);
        end
    end
    
    signed_i = data_i - (data_i > 2^(BITW-1)-1)*(2^BITW);
    signed_q = data_q - (data_q > 2^(BITW-1)-1)*(2^BITW);

    signed_data = signed_i + 1i*signed_q;

    fclose(fid);
end









