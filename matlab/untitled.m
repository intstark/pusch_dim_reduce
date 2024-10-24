clc;clear all;

load('beams16_sorted.mat');
WriteFile = 0;


beams_sum_i = real(beams16_sorted);
beams_sum_q = imag(beams16_sorted);

abs_beams_i = abs(beams_sum_i);
abs_beams_q = abs(beams_sum_q);

i_max = max(abs_beams_i,[],[1,2]);
q_max = max(abs_beams_q,[],[1,2]);

iq_max = max([i_max q_max]);

idx = floor(log2(iq_max)+1);


fprintf('i_max\t=\t%d\nq_max\t=\t%d\niq_max\t=\t%d\n',i_max,q_max,iq_max);


factor_shift = idx - 15;


beams_sum_sft = beams16_sorted/2^factor_shift;
beams_sum_sft_fix = round(beams_sum_sft);


compressed_data_max_bit = log2(max(abs(beams_sum_sft),[],[1,2]));

if WriteFile
    [br,bc] = size(beams16_sorted);
    for ii=1:bc
        write2hex_fcn(sprintf('ul_datain_%d.txt',ii-1),beams16_sorted(:,ii));
    end
end






datafile1='../vfy/compress_40b16b_tb_work/compress_data.txt';
sim_compress_data = ReadData(datafile1,16,0,'IQ');


err_cprs = sim_compress_data(1:1584,:)-beams_sum_sft_fix;

err_cprs_sum=sum(err_cprs,[1,2]);

fprintf('对比误差err_cprs_sum\t=\t%d\n',err_cprs_sum);




%% 函数

% 写仿真激励文件HEX
function write2hex_fcn(desfile,WrData)
    fid=fopen(desfile,'w');
    
    [r,c] = size(WrData);
    for sr= 1:r
            WrDataHex = [dec2hex(real(WrData(sr,:)),10) dec2hex(imag(WrData(sr,:)),10)];
%             fprintf('%s',WrDataHex);
%             fprintf('\n');
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
