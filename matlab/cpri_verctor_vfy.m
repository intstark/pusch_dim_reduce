
clc;clear all;close all;

%% 参数设置
numBeam = 64;
numAnts = 64;
numPrb = 132;
numCarriers = numPrb*12;
numSymbols = 14;

aau_idx = 0;
aiu_idx = 0;            % AIU编号识别
symbol_id=5;

ReadFile = 0;
MergeFile = 0;
WriteCodeMif = 0;
numSlot = 2;
SymbolXCompare = 1;


vector_dir = '../AlgoVec/ulrxDimRedu-1203-v1';
fpga_dir   = '../vfy/pusch_dr_top_vec_work';




if ReadFile
    % 读取CPRI输入数据
    for ii=1:8
        data_in = sprintf('%s/data_beforeDimRedu/pusch_group%d/LAN%d.txt',vector_dir,(aau_idx+aiu_idx),ii);
        fprintf('读取文件:\t%s\n',data_in);
        [uncprs_data_read((ii-1)*4+1:ii*4,:), cprs_data_read((ii-1)*4+1:ii*4,:),...
         rb_agc_read((ii-1)*4+1:ii*4,:), fft_agc_read((ii-1)*4+1:ii*4,:)]=ReadCpriData(data_in,7);
    end
    save('data/uncprs_data_read','uncprs_data_read');
    save('data/cprs_data_read','cprs_data_read');
    save('data/rb_agc_read','rb_agc_read');
    save('data/fft_agc_read','fft_agc_read');
    
    % 读取降维输入数据
    for ii=1:32
        data_in = sprintf('%s/group%d_data_in/ant%dand%d.txt',vector_dir,(aau_idx+aiu_idx+1),2*ii-2,2*ii-1);
        fprintf('读取文件:\t%s\n',data_in);
        dr_din_read(ii,:)=ReadHexData(data_in,16);
    end
    save('data/dr_din_read','dr_din_read');

else
    load('data/uncprs_data_read');
    load('data/cprs_data_read');
    load('data/rb_agc_read');
    load('data/fft_agc_read');
    load('data/dr_din_read');
end
    


fft_agc_eve = fft_agc_read(:, 1:33:end);
fft_agc_odd = fft_agc_read(:,18:33:end);

fft_agc_eve_base = min(fft_agc_eve,[],1);
fft_agc_odd_base = min(fft_agc_odd,[],1);

fft_agc_eve_shift = fft_agc_eve - fft_agc_eve_base;
fft_agc_odd_shift = fft_agc_odd - fft_agc_odd_base;

for ii=1:14
    factor_eve=2.^(-fft_agc_eve_shift(:,ii)); %右移
    factor_odd=2.^(-fft_agc_odd_shift(:,ii)); %右移
    unfft_data_read(:,(ii-1)*3168+1 : (ii-1)*3168+1584)    = uncprs_data_read(:,(ii-1)*3168+1 : (ii-1)*3168+1584).*factor_eve;
    unfft_data_read(:,(ii-1)*3168+1585 : (ii-1)*3168+3168) = uncprs_data_read(:,(ii-1)*3168+1585 : (ii-1)*3168+3168).*factor_odd;
end

% FPGA与本Matlab计算结果比较
fprintf('---------------------------------------------\n');
fprintf('原始数据检查比对\n');
fprintf('---------------------------------------------\n');

load('dr_mat/rx_data_freq_fixed_compressed');
load('dr_mat/rx_data_decompressed');
load('dr_mat/DecomExponent_tv');
load('dr_mat/dataout_RRU1_AIU1');

rx_cprs_symb1_eve=squeeze(rx_data_freq_fixed_compressed(1:1584,1,1:2:64)).';
rx_cprs_symb1_odd=squeeze(rx_data_freq_fixed_compressed(1:1584,1,2:2:64)).';
rx_cprs_symb1 = [rx_cprs_symb1_eve rx_cprs_symb1_odd];


rx_decprs_symb1_eve=squeeze(rx_data_decompressed(1:1584,1,1:2:64)).';
rx_decprs_symb1_odd=squeeze(rx_data_decompressed(1:1584,1,2:2:64)).';
rx_decprs_symb1 = [rx_decprs_symb1_eve rx_decprs_symb1_odd];


err_rx_cprs = cprs_data_read(:,1:3168)-rx_cprs_symb1;
err_rx_decprs = unfft_data_read(:,1:3168)-rx_decprs_symb1;

err_rx_cprs_max=max(abs(err_rx_cprs),[],[1,2]);
fprintf('压缩数据读取与Mat数据比对误差:\t err_rx_cprs_max=\t%d\n',err_rx_cprs_max);

err_rx_decprs_max=max(abs(err_rx_decprs),[],[1,2]);
fprintf('解压数据读取与Mat数据比对误差:\t err_rx_decprs_max=\t%d\n',err_rx_decprs_max);

rx_rb_agc_eve=squeeze(DecomExponent_tv(1:132,1,1:2:64)).';
rx_rb_agc_odd=squeeze(DecomExponent_tv(1:132,1,2:2:64)).';
rx_rb_agc = [rx_rb_agc_eve rx_rb_agc_odd];
err_rx_agc= rb_agc_read(:,1:264)-rx_rb_agc;

err_rx_agc_max=max(abs(err_rx_agc),[],[1,2]);
fprintf('AGC数据读取与Mat数据比对误差:\t err_rx_agc_max=\t%d\n',err_rx_agc_max);


rx_dr_data = squeeze(dataout_RRU1_AIU1(1:1584,1,:));



if ReadFile
    % 读取天线数据

    for ii=1:16
        data_in = sprintf('%s/data_out/beam%d.txt',vector_dir,ii-1);
        fprintf('读取文件:\t%s\n',data_in);
        dr_data_read(:,ii)=ReadHexData(data_in,16);
    end

    % 读取序号
    data_in = sprintf('%s/BeamIndex/RUU%dAIU%d.txt',vector_dir,aau_idx+1,aiu_idx+1);
    fprintf('读取文件:\t%s\n',data_in);
    BeamIndex_read_0=ReadHexData(data_in,8,'real');
    BeamIndex0 = (reshape(BeamIndex_read_0,16,9)).'-1; %修正序号从0开始

    % 读取能量
    data_in = sprintf('%s/PowSort/RUU%dAIU%d.txt',vector_dir,aau_idx+1,aiu_idx+1);
    fprintf('读取文件:\t%s\n',data_in);
    BeamPwr_read0=ReadHexData(data_in,64,'real');
    BeamPwr0 = (reshape(BeamPwr_read0,16,9)).';


    % 读取W0
    data_in = sprintf('%s/ReduMatrix/W_0_after.txt',vector_dir);
    fprintf('读取文件:\t%s\n',data_in);
    w0_data_read=ReadHexData(data_in,16);
    
    
    % 读取W1
    data_in = sprintf('%s/ReduMatrix/W_1_after.txt',vector_dir);
    fprintf('读取文件:\t%s\n',data_in);
    w1_data_read=ReadHexData(data_in,16);

    save('dr_data_read','dr_data_read');
    save('BeamPwr0','BeamPwr0'); 
    save('BeamIndex0','BeamIndex0'); 
    save('w0_data_read','w0_data_read');
    save('w1_data_read','w1_data_read');
else
    load('dr_data_read.mat');
    load('w0_data_read.mat');
    load('w1_data_read.mat');
    load('BeamPwr0.mat');
    load('BeamIndex0.mat');
end

w0_data_read=conj(w0_data_read);
w1_data_read=conj(w1_data_read);




%% 写FPGA仿真激励
%  合并64天线输入数据
if MergeFile
    totalFiles = 8;
    for ii=1:totalFiles
        [br,bc] = size(ant_data_read);
        
        numCol = br/totalFiles;

        temp = (ant_data_read((ii-1)*numCol+1 : ii*numCol,:)).';
        if(numSlot==1)
            ant_data_lane=temp;
        elseif(numSlot==2)
            ant_data_lane=[temp; temp];
        end

        write2hex_fcn(sprintf('../sim/vector/datain/ul_data_0%d.txt',ii-1),ant_data_lane,16);
    end
end

% 转换码本矩阵
if WriteCodeMif
    write_mif('../prj/ip/rom_code_word_even',w0_data_read,1024,64);
    write_mif('../prj/ip/rom_code_word_odd',w1_data_read,1024,64);
end


ant_data_in = unfft_data_read;

%% Matlab算法实现
%取出奇偶天线的第1个符号的数据

ant_data_0 = ant_data_in(:,   1:1584); %前1584,奇天线
ant_data_1 = ant_data_in(:,1585:3168); %后1584,偶天线
beams_eve = w0_data_read*ant_data_0; %奇天线 [64,32]*[32*1584]
beams_odd = w1_data_read*ant_data_1; %偶天线 [64,32]*[32*1584]

beams_sum = beams_eve + beams_odd;

%% rbG能量和计算

rbGSize=16;             % 每个rbG包含的RB数
numRE_rbG = rbGSize*12; % 每个rbG包含的RE数
rbGMaxNum = ceil(numPrb/rbGSize); % rbG个数
rbGMaxMod = mod(numPrb,rbGSize);  % 不被整除的rbG中包含的RB数



% 右移8位
beams_sum_scale = floor(beams_sum/2^8);

% 实部和虚部绝对值之和
beams_sum_abs = abs(real(beams_sum_scale)) +abs(imag(beams_sum_scale));


% 在rbG内对上述绝对值和进行累加
for bb= 1:64
    pwt = 0;
    for ii=1:1:rbGMaxNum
        % 前132PRB 不完整的rbG放在开头
        if(ii==1 && aiu_idx==0)
            rbG_sum(ii,bb) = sum(beams_sum_abs(bb,pwt+1:rbGMaxMod*12));
            pwt = rbGMaxMod*12;
        % 后132PRB 不完整的rbG放在末尾
        elseif(ii==rbGMaxNum && aiu_idx==1)
            rbG_sum(ii,bb) = sum(beams_sum_abs(bb,pwt+1:pwt+rbGMaxMod*12));
            pwt = rbGMaxMod*12;
        else
            rbG_sum(ii,bb) = sum(beams_sum_abs(bb,pwt+1:pwt+numRE_rbG));
            pwt = pwt + numRE_rbG;
        end
    end
end


%% rbG能量排序
%  对SYMBOL1的64 Beam能能在一个rbG内的所有能量从大到小排序
[rbG_sort_sum, rbG_sort_addr] = sort(rbG_sum,2,'descend');

% 起始序号修正为0开始
rbG_sort_addr = rbG_sort_addr - 1;

dec2hex(rbG_sort_addr(1,1:16))


% dataout_sft_fix=dynamic_truncation(rbG_sort_sum,24);
% dec2hex(dataout_sft_fix(1,1:16))

pwt = 0;
for jj=1:rbGMaxNum
    % 前132PRB 不完整的rbG放在开头
    if(jj==1 && aiu_idx==0)
        for ii=1:16
            beams16_sym1_sort(pwt+1:rbGMaxMod*12, ii) = beams_sum(rbG_sort_addr(jj,ii)+1, pwt+1:rbGMaxMod*12);
        end        
        pwt = rbGMaxMod*12;

    % 后132PRB 不完整的rbG放在末尾
    elseif(jj==rbGMaxNum && aiu_idx==1)
        for ii=1:16
            beams16_sym1_sort(pwt+1:pwt+rbGMaxMod*12, ii) = beams_sum(rbG_sort_addr(jj,ii)+1, pwt+1:pwt+rbGMaxMod*12);
        end
        pwt = rbGMaxMod*12;
    else
        for ii=1:16
            beams16_sym1_sort(pwt+1:pwt+numRE_rbG, ii) = beams_sum(rbG_sort_addr(jj,ii)+1, pwt+1:pwt+numRE_rbG);
        end
        pwt = pwt + numRE_rbG;
    end
end

BeamPower=rbG_sort_sum(:,1:16);
BeamIndex=rbG_sort_addr(:,1:16);

%% 动态定标比对
beams_sum_sft_fix=dynamic_truncation(beams16_sym1_sort,16);



%% 读取FPGA仿真数据
uiwait(msgbox('FPGA仿真运行完毕'));

MAC_DW=40;


for ii=1:8
    datafile3=sprintf('%s/des_uzip_data%d.txt' ,fpga_dir,ii-1);
    datafile2=sprintf('%s/des_rx_data%d.txt' ,fpga_dir,ii-1);
    
    sim_uzip_data(ii,:,:) = ReadData(datafile3,16,0,'IQ');
    [rx_data(ii,:,:),rx_cmps(ii,:,:),rx_agc(ii,:,:)]  = ReadZipData(datafile2,0);

    sim_rx_data(:,(ii-1)*4+1:ii*4) = squeeze(rx_data(ii,:,:));
    sim_rx_cmps(:,(ii-1)*4+1:ii*4) = squeeze(rx_cmps(ii,:,:));
    sim_rx_agc(:,(ii-1)*4+1:ii*4) = squeeze(rx_agc(ii,:,:));
    sim_unzip_data(:,(ii-1)*4+1:ii*4) = squeeze(sim_uzip_data(ii,:,:));
end

datafile1=sprintf('%s/compress_data.txt' ,fpga_dir);
datafile8=sprintf('%s/des_dr_datain.txt' ,fpga_dir);
datafile4=sprintf('%s/des_beams_data.txt',fpga_dir);
datafile5=sprintf('%s/des_beams_pwr.txt' ,fpga_dir);
datafile6=sprintf('%s/des_beams_sort.txt',fpga_dir);
datafile7=sprintf('%s/des_beams_idx.txt' ,fpga_dir);


sim_beams_data = ReadData(datafile4,MAC_DW,0);
sim_beams_pwr  = ReadData(datafile5,MAC_DW,0);
sim_beams_sort = ReadData(datafile6,32,0);
sim_beams_idx  = ReadData(datafile7,8,0);
sim_compress_data = ReadData(datafile1,16,0,'IQ');
sim_ants_data = ReadData(datafile8,16,0,'IQ');







% FPGA与本Matlab计算结果比较
fprintf('---------------------------------------------\n');
fprintf('AIU编号:%d\n',aiu_idx);
fprintf('FPGA与本Matlab计算结果比较\n');
fprintf('---------------------------------------------\n');

sim_symb = 1;
Vants = 1:32;
err_uzip = sim_unzip_data((sim_symb-1)*numCarriers*2+1 : (sim_symb)*numCarriers*2,Vants)-(uncprs_data_read(Vants,(sim_symb-1)*numCarriers*2+1 : (sim_symb)*numCarriers*2)).';
err_uzip_max=max(abs(err_uzip),[],[1,2]);
find(err_uzip~=0);
fprintf('解压数据误差分析(MAX):\t err_uzip_max=\t%d\n',err_uzip_max);


err_cmps = sim_rx_cmps((sim_symb-1)*numCarriers*2+1 : (sim_symb)*numCarriers*2,Vants)-(cprs_data_read(Vants,(sim_symb-1)*numCarriers*2+1 : (sim_symb)*numCarriers*2)).';
err_cmps_max=max(abs(err_cmps),[],[1,2]);
fprintf('压缩数据误差分析(MAX):\t err_cmps_max=\t%d\n',err_cmps_max);


for ii=1:32
    temp = rb_agc_read(ii,:);
    temp2=repmat(temp,12,1);
    re_agc_read(:,ii) = (reshape(temp2,1,12*length(temp))).';
end


err_agc = sim_rx_agc((sim_symb-1)*numCarriers*2+1 : (sim_symb)*numCarriers*2,Vants)-(re_agc_read((1-1)*numCarriers*2+1 : (1)*numCarriers*2,Vants));
err_agc_max=max(abs(err_agc),[],[1,2]);
fprintf('RB AGC误差分析(MAX):\t err_agc_max=\t%d\n',err_agc_max);

err_unfft = unfft_data_read(:,1:3168)-sim_ants_data(1:3168,:).';
err_unfft_max=max(abs(err_unfft),[],[1,2]);
fprintf('拉齐FFT误差分析(MAX):\t err_unfft_max=\t%d\n',err_unfft_max);

err_unfft2 = dr_din_read(:,1:3168)-sim_ants_data(1:3168,:).';
err_unfft2_max=max(abs(err_unfft2),[],[1,2]);
fprintf('拉齐FFT误差分析(MAX):\t err_unfft2_max=\t%d\n',err_unfft2_max);


err_sort_idx = BeamIndex-sim_beams_idx(1:9,:);
fprintf("rbG波束序号的误差和:\t err_sort_idx = %d\n",sum(err_sort_idx,[1,2,3]));


err_beam_sort = BeamPower-sim_beams_sort(1:9,:);
fprintf("rbG波束能量值误差和:\t err_beam_sort = %d\n",sum(err_beam_sort,[1,2,3]));

err_cprs = sim_compress_data((sim_symb-1)*numCarriers+1 : (sim_symb)*numCarriers,:)-beams_sum_sft_fix;
err_cprs_sum=sum(err_cprs,[1,2,3]);
fprintf('压缩后降维数据误差和:\t err_cprs_sum=\t%d\n',err_cprs_sum);


% FPGA与向量文本比较
fprintf('---------------------------------------------\n');
fprintf('FPGA与向量文本比较\n');
fprintf('---------------------------------------------\n');

err_sort_idx2 = sim_beams_idx(1:9,:) - BeamIndex0;
fprintf("rbG波束序号的误差和:\t err_beam_sort = %d\n",sum(err_sort_idx2,[1,2]));

err_beam_pwr2 = sim_beams_sort(1:9,:) - BeamPwr0;
fprintf("rbG波束能量值误差和:\t err_beam_pwr = %d\n",sum(err_beam_pwr2,[1,2]));
pct_err_pwr2 = err_beam_pwr2/BeamPwr0;
fprintf("rbG波束能量值误差比:\t pct_err_pwr_max = %d\n",max(abs(pct_err_pwr2),[],[1,2]));

err_cprs2 = sim_compress_data((sim_symb-1)*numCarriers+1 : (sim_symb)*numCarriers,:)-rx_dr_data((sim_symb-1)*numCarriers+1 : (sim_symb)*numCarriers,:);
err_cprs2_sum=sum(err_cprs2,[1,2]);
fprintf('压缩后降维数据误差和:\t err_cprs2_sum=\t%d\n',err_cprs2_sum);


%% 后续符号对比
%  采用对SYMBOL1筛选出来的最大16beam序号的码本与天线数据相乘降维，每个rbG不同
if(SymbolXCompare)
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
    clear beams_sum_sft_fix;
    
    
    %% 分析开始
    fprintf('---------------------------------------------\n');
    fprintf("第%d个符号分析如下：\n",symbol_id);
    fprintf('---------------------------------------------\n');
    
    % 分离出发送端的奇偶天线数据（单Lane 8天线）
    ant32_tx_eve = ant_data_in(:, (2*symbol_id-2)*numCarriers+1 : (2*symbol_id-1)*numCarriers);
    ant32_tx_odd = ant_data_in(:, (2*symbol_id-1)*numCarriers+1 : (2*symbol_id-0)*numCarriers);
    
    
    pwt = 0;
    for jj=1:rbGMaxNum
        for ii=1:16
            w0_data_sel(ii,:) = w0_data_read(rbG_sort_addr(jj,ii)+1, :);
            w1_data_sel(ii,:) = w1_data_read(rbG_sort_addr(jj,ii)+1, :);
        end
    
        % 前132PRB 不完整的rbG放在开头
        if(jj==1 && aiu_idx==0)
    
            % 32奇偶天线数据和码本数据矩阵相乘
            beams_eve(:,pwt+1:rbGMaxMod*12) = w0_data_sel * ant32_tx_eve(:,pwt+1:rbGMaxMod*12);
            beams_odd(:,pwt+1:rbGMaxMod*12) = w1_data_sel * ant32_tx_odd(:,pwt+1:rbGMaxMod*12);
    
            pwt = rbGMaxMod*12;
    
        % 后132PRB 不完整的rbG放在末尾
        elseif(jj==rbGMaxNum && aiu_idx==1)
    
            % 32奇偶天线数据和码本数据矩阵相乘
            beams_eve(:,pwt+1:pwt+rbGMaxMod*12) = w0_data_sel * ant32_tx_eve(:,pwt+1:pwt+rbGMaxMod*12);
            beams_odd(:,pwt+1:pwt+rbGMaxMod*12) = w1_data_sel * ant32_tx_odd(:,pwt+1:pwt+rbGMaxMod*12);
    
            pwt = rbGMaxMod*12;
        else
            % 32奇偶天线数据和码本数据矩阵相乘
            beams_eve(:,pwt+1:pwt+numRE_rbG) = w0_data_sel * ant32_tx_eve(:,pwt+1:pwt+numRE_rbG);
            beams_odd(:,pwt+1:pwt+numRE_rbG) = w1_data_sel * ant32_tx_odd(:,pwt+1:pwt+numRE_rbG);
    
            pwt = pwt + numRE_rbG;
        end
    end
    
    beams_sum = beams_eve + beams_odd;
    beams_sum = beams_sum.';
    
    
    %% 动态定标
    beams_sum_sft_fix=dynamic_truncation(beams_sum,16);
    
    %% 比对结果
    err_cprs = sim_compress_data((symbol_id-1)*numCarriers+1 : (symbol_id)*numCarriers,:)-beams_sum_sft_fix;
    err_cprs_sum=sum(err_cprs,[1,2]);
    fprintf('压缩后降维数据误差（与Matlab比）:\t%d\n',err_cprs_sum);
    
    err_cprs2 = sim_compress_data((sim_symb-1)*numCarriers+1 : (sim_symb)*numCarriers,:)-rx_dr_data((sim_symb-1)*numCarriers+1 : (sim_symb)*numCarriers,:);
    err_cprs2_sum=sum(err_cprs2,[1,2]);
    fprintf('压缩后降维数据误差（与向量文本比）:\t%d\n',err_cprs2_sum);
end

%%
fprintf('---------------------------------------------\n');
fprintf('分析完毕！\n');
fprintf('---------------------------------------------\n');















%% 相关函数
function [uncps_data,signed_data,ants_rb_agc,ants_fft_agc]=ReadCpriData(data_in,BITW,varargin)
    reverse_bit =0;
    transpose_rc =0;
    complex_data = 1;

    fid=fopen(data_in);
    data_cell=textscan(fid,'%s');
    c=length(data_cell);
    r=length(data_cell{1});

    numCHIP = r/96;

    if(nargin>2)
        if(varargin{1}=="reverse")
            reverse_bit = 1;
        elseif(varargin{1}=="turn")
            transpose_rc = 1;
        elseif(varargin{1}=="real")
            complex_data = 0;
        end
    end

    vv=0;
    for chip=1:numCHIP
        mod96=mod(chip,96);
    
        INDEX_HD = 4+ (chip-1)*96;
        INDEX_FFTAGC = 5+ (chip-1)*96;
        INDEX_RBAGC1 = 6+ (chip-1)*96;
        INDEX_RBAGC2 = 7+ (chip-1)*96;
        INDEX_RE = 8+ (chip-1)*96;
    
        hd_hex = data_cell{1,1}{INDEX_HD,1};
        fft_agc_hex = data_cell{1,1}{INDEX_FFTAGC,1};
        rb_agc_hex  = [data_cell{1,1}{INDEX_RBAGC2,1} data_cell{1,1}{INDEX_RBAGC1,1}];

        for ii=1:4
            ants_fft_agc(ii  ,chip) = hex2dec(fft_agc_hex(8-(ii-1)*2-1:8-(ii-1)*2));
%             ants_fft_agc(ii+4,chip) = hex2dec(fft_agc_hex(16-(ii-1)*2-1:16-(ii-1)*2));
        end

        for ii=1:4
            for jj=1:8
                ants_rb_agc(ii,jj+(chip-1)*8) = hex2dec(rb_agc_hex(33-(ii-1)*8-jj));
            end
        end
    
        for ii=1:84
            vv = vv +1;
            mod7 = mod(ii,7);
            if(mod7 == 1)
                temp0 = '0000000000000000';
            else
                temp0 = data_cell{1,1}{INDEX_RBAGC2-1+ii,1};
            end
    
            temp1 = data_cell{1,1}{INDEX_RBAGC2+ii,1};

            if(mod7 == 1)
                for jj=1:4
                    hextemp1=temp1(13-(jj-1)*4:16-(jj-1)*4);
                    temp2 = bitshift(hex2dec(hextemp1),0,'uint16');
        
                    ant_q(jj,vv) = bitand(temp2,hex2dec('7F'));
                    ant_i(jj,vv) = bitand(bitshift(temp2,-7,'uint16'),hex2dec('7F'));           
                end
            elseif(mod7 == 0)
                for jj=1:4
                    hextemp0=temp0(13-(jj-1)*4:16-(jj-1)*4);
                    hextemp1=temp1(13-(jj-1)*4:16-(jj-1)*4);
                    temp2 = bitshift(hex2dec(hextemp1),2*(7-1),'uint16')+bitshift(hex2dec(hextemp0),2*(7-1)-16,'uint16');
                    temp3 = bitshift(hex2dec(hextemp1),-2,'uint16');
        
                    ant_q(jj,vv) = bitand(temp2,hex2dec('7F'));
                    ant_i(jj,vv) = bitand(bitshift(temp2,-7,'uint16'),hex2dec('7F'));
                    ant_q(jj,vv+1) = bitand(temp3,hex2dec('7F'));
                    ant_i(jj,vv+1) = bitand(bitshift(temp3,-7,'uint16'),hex2dec('7F'));               
                end
                vv = vv + 1;
            else
                for jj=1:4
                    hextemp0=temp0(13-(jj-1)*4:16-(jj-1)*4);
                    hextemp1=temp1(13-(jj-1)*4:16-(jj-1)*4);
                    temp2 = bitshift(hex2dec(hextemp1),2*(mod7-1),'uint16')+bitshift(hex2dec(hextemp0),2*(mod7-1)-16,'uint16');
        
                    ant_q(jj,vv) = bitand(temp2,hex2dec('7F'));
                    ant_i(jj,vv) = bitand(bitshift(temp2,-7,'uint16'),hex2dec('7F'));           
                end
            end
        end
    end
    
    signed_i = ant_i - (ant_i > 2^(BITW-1)-1)*(2^BITW);
    signed_q = ant_q - (ant_q > 2^(BITW-1)-1)*(2^BITW);
    
    signed_data = signed_i + 1i*signed_q;
    for jj=1:4
        for rb=1:length(signed_data)/12
            uncps_data(jj, (rb-1)*12+1:rb*12) = signed_data(jj,(rb-1)*12+1:rb*12)*2^(9-ants_rb_agc(jj,rb));
%             uncps_data(jj, (rb-1)*12+1:rb*12) = signed_data(jj,(rb-1)*12+1:rb*12)*2^(ants_rb_agc(jj,rb));
        end
    end

    if(transpose_rc)
        ants_fft_agc = ants_fft_agc.';
        ants_rb_agc = ants_rb_agc.';
        signed_data = signed_data.';
        uncps_data = uncps_data.';
    end
end



function signed_data=ReadHexData(data_in,BITW,varargin)
    reverse_bit =0;
    transpose_rc =0;
    complex_data = 1;

    fid=fopen(data_in);
    data_cell=textscan(fid,'%s');
    c=length(data_cell);
    r=length(data_cell{1});
    
    HexB = BITW/4;

    if(nargin>2)
        if(varargin{1}=="reverse")
            reverse_bit = 1;
        elseif(varargin{1}=="turn")
            transpose_rc = 1;
        elseif(varargin{1}=="real")
            complex_data = 0;
        end
    end



    for ii=1:r
        temp = data_cell{1,1}{ii,1};
        [temp_r,temp_c] = size(temp);
    
        HexB_GRP = HexB*(complex_data+1);
        DataWords = temp_c/HexB_GRP;
        
        for kk=1:DataWords
            hex_i = temp((kk-1)*HexB_GRP+1 : (kk-1)*HexB_GRP+HexB);
            if(complex_data)
                hex_q = temp((kk-1)*HexB_GRP+1+HexB : (kk-1)*HexB_GRP+HexB*2);
            else
                hex_q = hex_i;
            end

            if(reverse_bit)
                data_i(ii,DataWords+1-kk)=hex2dec(hex_i);
                data_q(ii,DataWords+1-kk)=hex2dec(hex_q);
            else
                data_i(ii,kk)=hex2dec(hex_i);
                data_q(ii,kk)=hex2dec(hex_q);
            end
        end
    end
    
    signed_i = data_i - (data_i > 2^(BITW-1)-1)*(2^BITW);
    signed_q = data_q - (data_q > 2^(BITW-1)-1)*(2^BITW);

    if complex_data
        signed_data = signed_i + 1i*signed_q;
    else
        signed_data = signed_i;
    end
    
    if(transpose_rc)
        signed_data = signed_data.';
    end

    fclose(fid);
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
    sint_unzip_cmpy = sint_cmpy .* (2.^(9-agc_data));
end

% 动态定标截断
function [dataout_sft_fix,factor_shift]=dynamic_truncation(datain,OW,varargin)

    datain_i = real(datain);
    datain_q = imag(datain);
    
    abs_data_i = abs(datain_i);
    abs_data_q = abs(datain_q);
    
    i_max = max(abs_data_i,[],[1,2]);
    q_max = max(abs_data_q,[],[1,2]);
    
    iq_max = max([i_max q_max]);
    
    idx = floor(log2(iq_max)+1);
    
    
    factor_shift = idx - (OW-1);
    
    
    dataout_sft = datain/2^factor_shift;

    if(nargin>2)
        if(varargin{1}=="round")
            truncation_mode = 'round';
        elseif(varargin{1}=="floor")  
            truncation_mode = 'floor';
        elseif(varargin{1}=="ceil")  
            truncation_mode = 'ceil';
        elseif(varargin{1}=="fix")  
            truncation_mode = 'fix';
        end
    else
        truncation_mode = 'round';
    end

    warning('off');
    dataout_sft_fix = quantize(quantizer('fixed',truncation_mode,'saturate',[OW,0]),dataout_sft);
    warning('on');
end

% 写仿真激励文件HEX
function write2hex_fcn(desfile,WrData,BITW)
    fid=fopen(desfile,'w');
    HexB=BITW/4;

    [r,c] = size(WrData);
    for sr= 1:r
        WrDataHex=[];
        for sc = 1:c
            WrDataHex = [dec2hex(real(WrData(sr,sc)),HexB) dec2hex(imag(WrData(sr,sc)),HexB) WrDataHex];
            fprintf('%s',WrDataHex);
            fprintf('\n');
        end
            fprintf('Hex Bit Per Row:\t%d\n',length(WrDataHex));
            puts = sprintf('%s',WrDataHex);
            fwrite(fid,puts);
            fwrite(fid,newline);
    end
    fclose(fid);
end

% 写ROM文件
function write_hex2mif(coe_name,datain,width,depth,varargin)
    
    reverse_bit = 0;
    
    fid_mif = fopen(sprintf('%s.mif',coe_name),'wb');
    
    puts = sprintf('WIDTH = %d;\nDEPTH = %d;\n\nADDRESS_RADIX = UNS;\nDATA_RADIX =HEX;\n\n',...
        width, depth);
    
    fwrite(fid_mif,puts);
    
    
    puts = sprintf('CONTENT BEGIN\n');
    fwrite(fid_mif,puts);
    
    
    fid=fopen(datain);
    data_cell=textscan(fid,'%s');
    c=length(data_cell);
    r=length(data_cell{1});
    
    if(nargin>4)
        if(varargin{1}=="reverse")
            reverse_bit = 1;
        end
    end

    for ii = 1:r
        temp = data_cell{1,1}{ii,1};
        [temp_r,temp_c] = size(temp);
        
        if(reverse_bit)
            temp_rvs = [];
            for jj=1:temp_c/8
                temp_dw = temp((jj-1)*8+1:jj*8);
                temp_rvs = [temp_dw temp_rvs];
            end
            temp=temp_rvs;
        end

        puts = sprintf('\t%d\t:\t%s;\n', ii-1, temp);
        fwrite(fid_mif,puts);
    end
    
    puts = sprintf('END;\n');
    fwrite(fid_mif,puts);
    
    
    fclose(fid_mif);

end
