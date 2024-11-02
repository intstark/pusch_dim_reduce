
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
SymbolXCompare = 0;

if ReadFile
    vv=1;
    for aau_idx = 0:1
        for aiu_idx = 0:1
            % 读取天线数据
            for ii=1:32
                data_in = sprintf('../../ulrxDimRedu20241028/group%d_data_in/ant%dand%d.txt',(aau_idx*2+aiu_idx+1),2*ii-2+aau_idx*64,2*ii-1+aau_idx*64);
                fprintf('读取文件:\t%s\n',data_in);
                AntDataRead128(vv,ii,:)=ReadHexData(data_in,16);
            end

            vv = vv +1;
        end
    end

    save('AntDataRead128','AntDataRead128');
else
    load('AntDataRead128.mat');
end

if ReadFile
    vv=1;
    BeamIndex0=[];
    BeamPwr0=[];
    for aau_idx = 0:1
        for aiu_idx = 0:1
            % 读取序号
            data_in = sprintf('../../ulrxDimRedu20241028/BeamIndex/RUU%dAIU%d.txt',aau_idx+1,aiu_idx+1);
            fprintf('读取文件:\t%s\n',data_in);
            BeamIndex_read_0=ReadHexData(data_in,8,'real');
            BN = length(BeamIndex_read_0);
            if(BN>144)
                BeamIndex_read_0=BeamIndex_read_0(145:end);
            end
            BeamIndexRead128(vv,:,:) = (reshape(BeamIndex_read_0,length(BeamIndex_read_0)/9,9)).'-1;
        
            % 读取能量
            data_in = sprintf('../../ulrxDimRedu20241028/PowSort/RUU%dAIU%d.txt',aau_idx+1,aiu_idx+1);
            fprintf('读取文件:\t%s\n',data_in);
            BeamPwr_read0=ReadHexData(data_in,64,'real');
            if(BN>144)
                BeamPwr_read0=BeamPwr_read0(145:end);
            end
            BeamPowerRead128(vv,:,:) = (reshape(BeamPwr_read0,length(BeamPwr_read0)/9,9)).'-1;

            vv = vv+1;
        end
    end

    save('BeamPowerRead128','BeamPowerRead128'); 
    save('BeamIndexRead128','BeamIndexRead128'); 
else
    load('BeamPowerRead128.mat');
    load('BeamIndexRead128.mat');
end

if ReadFile
    % 读取W0
    data_in = sprintf('../../ulrxDimRedu20241028/ReduMatrix/W_0_after.txt');
    fprintf('读取文件:\t%s\n',data_in);
    w0_data_read=ReadHexData(data_in,16);
    
    % 读取W1
    data_in = sprintf('../../ulrxDimRedu20241028/ReduMatrix/W_1_after.txt');
    fprintf('读取文件:\t%s\n',data_in);
    w1_data_read=ReadHexData(data_in,16);

    % 读取天线数据
    for ii=1:16
        data_in = sprintf('../../ulrxDimRedu20241028/data_out/beam%d.txt',ii-1);
        fprintf('读取文件:\t%s\n',data_in);
        dr_data_read(:,ii)=ReadHexData(data_in,16);
    end

    save('dr_data_read','dr_data_read');
    save('w0_data_read','w0_data_read');
    save('w1_data_read','w1_data_read');
else
    load('dr_data_read.mat');
    load('w0_data_read.mat');
    load('w1_data_read.mat');
end


w0_data_read=conj(w0_data_read);
w1_data_read=conj(w1_data_read);



%% 写FPGA仿真激励
%  合并64天线输入数据
if MergeFile
    totalFiles = 8;
    vv=1;
    for aau_idx = 0:1
        for aiu_idx = 0:1
            for ii=1:totalFiles
                sq_AntDataRead128 =squeeze(AntDataRead128(vv,:,:));
                [br,bc] = size(sq_AntDataRead128);
                
                numCol = br/totalFiles;
        
                ant_data_lane = (sq_AntDataRead128((ii-1)*numCol+1 : ii*numCol,:)).';
        
                write2hex_fcn(sprintf('../vfy/vector/datain/ul_data_%d%d.txt',(aau_idx*2+aiu_idx),ii-1),ant_data_lane,16); 
            end
            vv = vv + 1;
        end
    end
end

% 转换码本矩阵
if WriteCodeMif
    write_mif('../prj/ip/rom_code_word_even',w0_data_read,1024,64);
    write_mif('../prj/ip/rom_code_word_odd',w1_data_read,1024,64);
end

fprintf('向量写入完毕！\n');


%% Matlab算法实现
%取出奇偶天线的第1个符号的数据

vv=1;
for aau_idx = 0:1
    for aiu_idx = 0:1
        ant_data_0 = squeeze(AntDataRead128(vv,:,   1:1584)); %前1584,奇天线
        ant_data_1 = squeeze(AntDataRead128(vv,:,1585:3168)); %后1584,偶天线
        


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
        
        
        BeamPower(vv,:,:)=rbG_sort_sum(:,1:16);
        BeamIndex(vv,:,:)=rbG_sort_addr(:,1:16);
        
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
        beams_sum_sft_fix(vv,:,:)=dynamic_truncation(beams16_sym1_sort,16,'round');
        
        vv = vv+1;
    end
end


beam_power_aau1 = [squeeze(BeamPower(1,:,:));squeeze(BeamPower(2,:,:))];
beam_power_aau2 = [squeeze(BeamPower(3,:,:));squeeze(BeamPower(4,:,:))];

beam_power_aau = [beam_power_aau1 beam_power_aau2];

[aau128_sort_pwr, aau128_sort_idx] = sort(beam_power_aau,2,'descend');

beam_dr_aau1 = [squeeze(beams_sum_sft_fix(1,:,:));squeeze(beams_sum_sft_fix(2,:,:))];
beam_dr_aau2 = [squeeze(beams_sum_sft_fix(3,:,:));squeeze(beams_sum_sft_fix(4,:,:))];

beam_dr_aau = [beam_dr_aau1 beam_dr_aau2];

aau128_sort_idx_re=[];
for ii=1:18
    if(ii==1)
        aau128_sort_idx_re = repmat(aau128_sort_idx(1,:),48,1);
    elseif(ii==18)
        aau128_sort_idx_re = [aau128_sort_idx_re; repmat(aau128_sort_idx(ii,:),48,1)];
    else
        aau128_sort_idx_re = [aau128_sort_idx_re; repmat(aau128_sort_idx(ii,:),192,1)];
    end
end

for ii=1:3168
    for jj=1:32
        beam_dr_aau_sorted(ii,jj) = beam_dr_aau(ii,aau128_sort_idx_re(ii,jj));
    end
end



beam_dr_aau_out = [beam_dr_aau1(:,1:9) beam_dr_aau2(:,1:7)];


% 向量与本Matlab计算结果比较
fprintf('---------------------------------------------\n');
fprintf('向量与本Matlab计算结果比较\n');
fprintf('---------------------------------------------\n');

err_sort_idx = BeamIndexRead128 - BeamIndex;
fprintf("rbG能量序号(8bit):\t err_sort_idx = %d\n",sum(err_sort_idx,[1,2,3]));


err_beam_sort = BeamPowerRead128 - BeamPower;
fprintf("rbG总能量排序(48bit):\t err_beam_sort = %d\n",sum(err_beam_sort,[1,2,3]));

err_dr_data = dr_data_read(1:2*numCarriers,:) - beam_dr_aau_out;
fprintf("压缩后降维数据(16bit):\t err_dr_data = %d\n",sum(err_dr_data,[1,2,3]));


%% 读取FPGA仿真数据
uiwait(msgbox('FPGA仿真运行完毕'));

MAC_DW=40;

for ii=1:4
    datafile1=sprintf('../vfy/pdsch_dr_128ants_tb_work/compress_data%d.txt',ii-1);
    datafile6=sprintf('../vfy/pdsch_dr_128ants_tb_work/des_beams_sort%d.txt',ii-1);
    datafile7=sprintf('../vfy/pdsch_dr_128ants_tb_work/des_beams_idx%d.txt',ii-1);
    
    
    sim_beams_sort(ii,:,:) = ReadData(datafile6,MAC_DW,0);
    sim_beams_idx(ii,:,:)  = ReadData(datafile7,8,0);
    sim_compress_data(ii,:,:) = ReadData(datafile1,16,0,'IQ');
end

% Matlab与FPGA计算结果比较
fprintf('\n---------------------------------------------\n');
fprintf('Matlab与FPGA计算结果比较\n');
fprintf('---------------------------------------------\n');


err_sort_idx = BeamIndex-sim_beams_idx;
fprintf("rbG能量序号(8bit):\t err_sort_idx = %d\n",sum(err_sort_idx,[1,2,3]));


err_beam_sort = BeamPower-sim_beams_sort(:,:,1:16);
fprintf("rbG总能量排序(48bit):\t err_beam_sort = %d\n",sum(err_beam_sort,[1,2,3]));

err_cprs = sim_compress_data(:,(1-1)*numCarriers+1 : (1)*numCarriers,:)-beams_sum_sft_fix;
err_cprs_sum=sum(err_cprs,[1,2,3]);
fprintf('压缩后降维数据(16bit):\t err_cprs_sum=\t%d\n',err_cprs_sum);



% 向量与FPGA计算结果比较
fprintf('\n---------------------------------------------\n');
fprintf('向量与FPGA计算结果比较\n');
fprintf('---------------------------------------------\n');

err_sort_idx2 = BeamIndexRead128-sim_beams_idx;
fprintf("rbG能量序号(8bit):\t err_sort_idx = %d\n",sum(err_sort_idx2,[1,2,3]));

err_beam_pwr2 = BeamPowerRead128-sim_beams_sort(:,:,1:16);
fprintf("rbG总能量降序(48bit):\t err_beam_pwr = %d\n",sum(err_beam_pwr2,[1,2,3]));
pct_err_pwr2 = err_beam_pwr2./BeamPowerRead128;
fprintf("rbG总能量降序(48bit):\t pct_err_pwr_max = %d\n",max(abs(pct_err_pwr2),[],[1,2,3]));



% err_cprs2 = sim_compress_data((1-1)*numCarriers+1 : (1)*numCarriers,:)-dr_data_read((1-1)*numCarriers+1 : (1)*numCarriers,:);
% err_cprs2_sum=sum(err_cprs2,[1,2]);
% fprintf('压缩后降维数据(16bit):\t err_cprs2_sum=\t%d\n',err_cprs2_sum);
% 
% err_cprs3 = beams_sum_sft_fix-dr_data_read((1-1)*numCarriers+1 : (1)*numCarriers,:);
% err_cprs3_sum=sum(err_cprs3,[1,2]);
% fprintf('压缩后降维数据(16bit):\t err_cprs3_sum=\t%d\n',err_cprs3_sum);











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


%% 分析开始
fprintf("#----------------------------------------------------------\n");
fprintf("# 第%d个符号分析如下：\n",symbol_id);
fprintf("#----------------------------------------------------------\n");


% 分离出发送端的奇偶天线数据（单Lane 8天线）
ant32_tx_eve = AntDataRead128(:, (2*symbol_id-2)*numCarriers+1 : (2*symbol_id-1)*numCarriers);
ant32_tx_odd = AntDataRead128(:, (2*symbol_id-1)*numCarriers+1 : (2*symbol_id-0)*numCarriers);


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

end

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
    
    signed_i = data_i - (data_i >= 2^(BITW-1))*(2^BITW);
    signed_q = data_q - (data_q >= 2^(BITW-1))*(2^BITW);
    
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
        sim_signed=sim_data-(sim_data >= 2^(BITW-1))*2^BITW;
    else
        sim_data=importdata(datafile,',',headLines);
        sim_signed=sim_data.data-(sim_data.data >= 2^(BITW-1))*2^BITW;
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

% 动态定标截断
function dataout_sft_fix=dynamic_truncation(datain,OW,varargin)

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
            dataout_sft_fix = round(dataout_sft);
        elseif(varargin{1}=="floor")  
            dataout_sft_fix = floor(dataout_sft);
        elseif(varargin{1}=="ceil")  
            dataout_sft_fix = ceil(dataout_sft);
        elseif(varargin{1}=="fix")  
            dataout_sft_fix = fix(dataout_sft);
        end
    else
        dataout_sft_fix = round(dataout_sft);
    end

%     dataout_sft_fix = quantize(quantizer('fixed','round','saturate',[16,0]),datain/2^factor_shift);
    
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
