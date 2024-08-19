clc; clear all; close all;


numBeam = 16;
numAnts = 32;
numPrb = 132;
numCarriers = numPrb*12;
numSymbols = 14;


ReGenerateData = 0;
WriteFile = 0;
ReloadData = 1;


if ReGenerateData
    codeWord = exp(1i*randn([numBeam,numAnts]));
    antData  = exp(1i*randn([numAnts,numCarriers]));
    
    
    save("data/codeWord.mat","codeWord");
    save("data/antData.mat","antData");
    
    % Quarlize
    codeWord_fix = quantize(quantizer('fix',[16,15]),codeWord)*2^15;
    antData_fix = quantize(quantizer('fix',[16,15]),antData)*2^15;
    
    save("data/codeWord_fix.mat","codeWord_fix");
    save("data/antData_fix.mat","antData_fix");
else
    load("data/codeWord_fix.mat");
    load("data/antData_fix.mat");
end


for bi = 1:numBeam
    re_cmpy(bi,:)=codeWord_fix(bi,:) .* antData_fix(:,1).';
end
cmpy_sum = sum(re_cmpy,2);

sum_data = codeWord_fix * antData_fix;



if WriteFile
    fid=fopen('../sim/mac_ants_tb_work/ant_data.txt','w');
    
    antData_fix = antData_fix.';
    for sr= 1:numCarriers
            fprintf('%d,',real(antData_fix(sr,:)),imag(antData_fix(sr,:)));
            fprintf('\n');
            puts = sprintf('%d,',real(antData_fix(sr,:)),imag(antData_fix(sr,:)));
            fwrite(fid,puts);
            fwrite(fid,newline);
    end
    
    fclose(fid);
    
    
    fid=fopen('../sim/mac_ants_tb_work/code_word.txt','w');
    
    for sr= 1:numBeam
            fprintf('%d,',real(codeWord_fix(sr,:)),imag(codeWord_fix(sr,:)));
            fprintf('\n');
            puts = sprintf('%d,',real(codeWord_fix(sr,:)),imag(codeWord_fix(sr,:)));
            fwrite(fid,puts);
            fwrite(fid,newline);
    end
    
    fclose(fid);

end



if ReloadData
    des_path='../sim/mac_ants_tb_work/beam_data.txt';
    
    BITW=36;
    
    sim_data=importdata(des_path,',',10);
    sim_signed=sim_data.data-(sim_data.data>=2^(BITW-1))*2^BITW;
    
    sim_beam_re=sim_signed(:,1:2:end);
    sim_beam_im=sim_signed(:,2:2:end);
    
    sim_beam=sim_beam_re+1i*sim_beam_im;
    save("data/sim_beam.mat","sim_beam");
else
    load("data/sim_beam.mat");
end



SIM_LEN = length(sim_beam);
err = sum_data(1,1:SIM_LEN).' - sim_beam;
fprintf('err sum = %.2f\n',sum(err));











