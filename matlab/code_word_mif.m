%--------------------------------------------------------------------------
% Author：NEWHUI
% Date  ：2024/12/19
% 本程序是用于产生码本矩阵的MIF文件
% 输入向量：
%           1. 码本矩阵向量
% 输出向量：
%           1. 偶天线4个ROM的MIF文件
%           2. 奇天线4个ROM的MIF文件
%--------------------------------------------------------------------------

clc;clear all;close all;

%% 参数设置

ReadFile    = 1;
WriteCodeMif= 0;

vector_dir  = '../../../../AlgoVec/ulrxDimRedu-1213';
fpga_dir    = '../vfy/pusch_dr_top_vec_work';
mif_dir     = './data/mif';


%% 文件读取转换
if ReadFile
    % 读取W0
    data_in = sprintf('%s/ReduMatrix/W_0.txt',vector_dir);
    fprintf('读取文件:\t%s\n',data_in);
    temp=ReadHexData(data_in,16);
    w0_data_read = (reshape(temp,32,64)).';
    
    
    % 读取W1
    data_in = sprintf('%s/ReduMatrix/W_1.txt',vector_dir);
    fprintf('读取文件:\t%s\n',data_in);
    temp=ReadHexData(data_in,16);
    w1_data_read = (reshape(temp,32,64)).';

    save('data/w0_data_read','w0_data_read');
    save('data/w1_data_read','w1_data_read');
else
    load('data/w0_data_read.mat');
    load('data/w1_data_read.mat');
end

% 共轭矩阵
w0_data_read=conj(w0_data_read);
w1_data_read=conj(w1_data_read);

%% 写MIF文件
if WriteCodeMif
    write_mif(sprintf('%s/rom_code_word_even_0',mif_dir),w0_data_read(:, 1: 8),8*32,64);
    write_mif(sprintf('%s/rom_code_word_even_1',mif_dir),w0_data_read(:, 9:16),8*32,64);
    write_mif(sprintf('%s/rom_code_word_even_2',mif_dir),w0_data_read(:,17:24),8*32,64);
    write_mif(sprintf('%s/rom_code_word_even_3',mif_dir),w0_data_read(:,25:32),8*32,64);

    write_mif(sprintf('%s/rom_code_word_odd_0',mif_dir),w1_data_read(:, 1: 8),8*32,64);
    write_mif(sprintf('%s/rom_code_word_odd_1',mif_dir),w1_data_read(:, 9:16),8*32,64);
    write_mif(sprintf('%s/rom_code_word_odd_2',mif_dir),w1_data_read(:,17:24),8*32,64);
    write_mif(sprintf('%s/rom_code_word_odd_3',mif_dir),w1_data_read(:,25:32),8*32,64);

    write_mif(sprintf('%s/rom_code_word_even',mif_dir),w0_data_read,1024,64);
    write_mif(sprintf('%s/rom_code_word_odd',mif_dir),w1_data_read,1024,64);
end
fprintf('运行完毕！\n');

%% 用到的函数
% 函数：读16进制文件
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

% 函数：写mif文件
function write_mif(coe_name,hfix,width,depth)
    fid_mif = fopen(sprintf('%s.mif',coe_name),'wb');

    puts = sprintf('WIDTH = %d;\nDEPTH = %d;\n\nADDRESS_RADIX = UNS;\nDATA_RADIX =HEX;\n\n',...
        width, depth);

    fwrite(fid_mif,puts);

    puts = sprintf('CONTENT BEGIN\n');
    fwrite(fid_mif,puts);

    [m,n]=size(hfix);

    for r = 1:m
        data_hex = [];
        for c= n:-1:1

            data_hex = [data_hex dec2hex(real(hfix(r,c)),4) dec2hex(imag(hfix(r,c)),4)];
        end

        puts = sprintf('\t%d\t:\t%s;\n', r-1, data_hex);
        fwrite(fid_mif,puts);
    end

    puts = sprintf('END;\n');
    fwrite(fid_mif,puts);

    fclose(fid_mif);
    fprintf('写入文件:\t%s\n', sprintf('%s.mif',coe_name));
end

