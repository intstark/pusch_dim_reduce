clc; clear all; close all;


load("data64ants/codeWord64_fix.mat");


% codeword_comb = round(real(codeWord_fix)*2^16) + imag(codeWord_fix);

codeword_comb_eve = codeWord_fix(:,1:2:end);
codeword_comb_odd = codeWord_fix(:,2:2:end);

width = 1024;
depth = 64;


write_mif("rom_code_word",codeWord_fix,width*2,depth);
write_mif("rom_code_word_even",codeword_comb_eve,width,depth);
write_mif("rom_code_word_odd",codeword_comb_odd,width,depth);

fprintf('>DONE\n');