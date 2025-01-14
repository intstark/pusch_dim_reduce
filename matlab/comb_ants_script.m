%% 本程序用于将多个16进制格式数据文本的每1行合并成1行，最终形成1个文件

clc;clear all;clear all;


load('data64ants/antData_fix.mat');
WriteFile = 0;
ReadFile  = 1;
MergeFile = 1;


ant_data_duplex= [antData_fix(1:2:end,:) antData_fix(2:2:end,:)];
ant_data_duplex=ant_data_duplex.';

if WriteFile
    [br,bc] = size(ant_data_duplex);
    for ii=1:bc
        write2hex_fcn(sprintf('ul_data2/ul_datain_%d.txt',ii-1),ant_data_duplex(:,ii),16);
    end
end


if ReadFile
    for ii=1:32
        data_in = sprintf('ul_data2/ul_datain_%d.txt',ii-1);
        ant_data_read(:,ii)=ReadHexData(data_in,16);

    end
end


if MergeFile
    totalFiles = 8;
    for ii=1:totalFiles
        [br,bc] = size(ant_data_read);
        
        numCol = bc/totalFiles;

        ant_data_lane = ant_data_read(:,(ii-1)*numCol+1 : ii*numCol);

        write2hex_fcn(sprintf('ul_data2/ul_data_%d.txt',ii-1),ant_data_lane,16);
    end
end

data_in = sprintf('ul_data2/ul_datain_%d.txt',64);
ant_data_read2=ReadHexData(data_in,16);

err1 = ant_data_read - ant_data_duplex;
err2 = ant_data_read2 - ant_data_duplex;

err1_sum = sum(err1,[1 2]);
err2_sum = sum(err2,[1 2]);


fprintf('err1:\t%d\n',err1_sum);
fprintf('err1:\t%d\n',err2_sum);


%% 相关函数

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
    
    HexB = BITW/4;

    for ii=1:r
        temp = data_cell{1,1}{ii,1};
        [temp_r,temp_c] = size(temp);
    

        HexB_GRP = HexB*2;
        DataWords = temp_c/HexB_GRP;
        
        

        for kk=1:DataWords
            hex_i = temp((kk-1)*HexB_GRP+1 : (kk-1)*HexB_GRP+HexB);
            hex_q = temp((kk-1)*HexB_GRP+1+HexB : (kk-1)*HexB_GRP+HexB*2);
            data_i(ii,DataWords+1-kk)=hex2dec(hex_i);
            data_q(ii,DataWords+1-kk)=hex2dec(hex_q);
        end
    end
    
    signed_i = data_i - (data_i > 2^(BITW-1)-1)*(2^BITW);
    signed_q = data_q - (data_q > 2^(BITW-1)-1)*(2^BITW);

    signed_data = signed_i + 1i*signed_q;

    fclose(fid);
end







