
clc;clear all;close all;

%% 参数设置
numBeam = 64;
numAnts = 64;
numPrb = 132;
numCarriers = numPrb*12;
numSymbols = 14;

aau_idx = 0;
aiu_idx = 0;            % AIU编号识别
symbol_id=2;

ReadFile = 0;
MergeFile = 0;
WriteCodeMif = 0;

vector_dir = '../AlgoVec/ulrxDimRedu20241104';
fpga_dir   = '../vfy/pusch_dr_core_vec_work';

if ReadFile
    % 读取天线数据
    for ii=1:32
        data_in = sprintf('%s/group%d_data_in/ant%dand%d.txt',vector_dir,(aau_idx+aiu_idx+1),2*ii-2,2*ii-1);
        fprintf('读取文件:\t%s\n',data_in);
        ant_data_read(ii,:)=ReadHexData(data_in,16);
    end
    
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

    save('ant_data_read','ant_data_read');
    save('dr_data_read','dr_data_read');
    save('BeamPwr0','BeamPwr0'); 
    save('BeamIndex0','BeamIndex0'); 
    save('w0_data_read','w0_data_read');
    save('w1_data_read','w1_data_read');
else
    load('ant_data_read.mat');
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

        ant_data_lane = (ant_data_read((ii-1)*numCol+1 : ii*numCol,:)).';

        write2hex_fcn(sprintf('../vfy/vector/datain/ul_data_%d.txt',ii-1),ant_data_lane,16);
    end
end

% 转换码本矩阵
if WriteCodeMif
    write_mif('../prj/ip/rom_code_word_even',w0_data_read,1024,64);
    write_mif('../prj/ip/rom_code_word_odd',w1_data_read,1024,64);
end




%% Matlab算法实现
%取出奇偶天线的第1个符号的数据

ant_data_0 = ant_data_read(:,   1:1584); %前1584,奇天线
ant_data_1 = ant_data_read(:,1585:3168); %后1584,偶天线
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

%% 动态定标比对
beams_sum_sft_fix=dynamic_truncation(beams16_sym1_sort,16);



%% 读取FPGA仿真数据
uiwait(msgbox('FPGA仿真运行完毕'));

MAC_DW=40;

datafile1=sprintf('%s/compress_data.txt' ,fpga_dir);
datafile4=sprintf('%s/des_beams_data.txt',fpga_dir);
datafile5=sprintf('%s/des_beams_pwr.txt' ,fpga_dir);
datafile6=sprintf('%s/des_beams_sort.txt',fpga_dir);
datafile7=sprintf('%s/des_beams_idx.txt' ,fpga_dir);



sim_beams_data = ReadData(datafile4,MAC_DW,0);
sim_beams_pwr  = ReadData(datafile5,MAC_DW,0);
sim_beams_sort = ReadData(datafile6,32,0);
sim_beams_idx  = ReadData(datafile7,8,0);
sim_compress_data = ReadData(datafile1,16,0,'IQ');



% FPGA与本Matlab计算结果比较
fprintf('---------------------------------------------\n');
fprintf('AIU编号:%d\n',aiu_idx);
fprintf('FPGA与本Matlab计算结果比较\n');
fprintf('---------------------------------------------\n');

err_beam_pwr = sum(sim_beams_pwr(1:rbGMaxNum,:) - rbG_sum,[1,2]);
fprintf("rbG总能量(48bit):\t err_beam_pwr = %d\n",err_beam_pwr);

err_sort_idx = sim_beams_idx - rbG_sort_addr(:,1:16);
fprintf("rbG能量序号(8bit):\t err_beam_sort = %d\n",sum(err_sort_idx,[1,2]));


err_beam_sort = sum(sim_beams_sort(1:rbGMaxNum,:) - rbG_sort_sum(:,1:16),[1,2]);
fprintf("rbG总能量排序(48bit):\t err_beam_sort = %d\n",err_beam_sort);

err_cprs = sim_compress_data((1-1)*numCarriers+1 : (1)*numCarriers,:)-beams_sum_sft_fix;
err_cprs_sum=sum(err_cprs,[1,2]);
fprintf('压缩后降维数据(16bit):\t err_cprs_sum=\t%d\n',err_cprs_sum);




% FPGA与向量文本比较
fprintf('---------------------------------------------\n');
fprintf('FPGA与向量文本比较\n');
fprintf('---------------------------------------------\n');

err_sort_idx2 = sim_beams_idx - BeamIndex0(:,1:16);
fprintf("rbG能量序号(8bit):\t err_beam_sort = %d\n",sum(err_sort_idx2,[1,2]));

err_beam_pwr2 = rbG_sort_sum(:,1:16) - BeamPwr0;
fprintf("rbG总能量降序(48bit):\t err_beam_pwr = %d\n",sum(err_beam_pwr2,[1,2]));
pct_err_pwr2 = err_beam_pwr2/BeamPwr0;
fprintf("rbG总能量降序(48bit):\t pct_err_pwr_max = %d\n",max(abs(pct_err_pwr2),[],[1,2]));



err_cprs2 = sim_compress_data((1-1)*numCarriers+1 : (1)*numCarriers,1)-dr_data_read((1-1)*numCarriers+1 : (1)*numCarriers,1);
err_cprs2_sum=sum(err_cprs2,[1,2]);
fprintf('压缩后降维数据(16bit):\t err_cprs2_sum=\t%d\n',err_cprs2_sum);


%% 后续符号对比
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
clear beams_sum_sft_fix;


%% 分析开始
fprintf("#----------------------------------------------------------\n");
fprintf("# 第%d个符号分析如下：\n",symbol_id);
fprintf("#----------------------------------------------------------\n");

% 分离出发送端的奇偶天线数据（单Lane 8天线）
ant32_tx_eve = ant_data_read(:, (2*symbol_id-2)*numCarriers+1 : (2*symbol_id-1)*numCarriers);
ant32_tx_odd = ant_data_read(:, (2*symbol_id-1)*numCarriers+1 : (2*symbol_id-0)*numCarriers);


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

fprintf('降维压缩后数据:\t err_cprs_sum = %d\n',err_cprs_sum);


%%
fprintf('---------------------------------------------\n');
fprintf('分析完毕！\n');
fprintf('---------------------------------------------\n');















%% 相关函数
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

% 动态定标截断
function dataout_sft_fix=dynamic_truncation(datain,OW)

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
    dataout_sft_fix = round(dataout_sft);

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
