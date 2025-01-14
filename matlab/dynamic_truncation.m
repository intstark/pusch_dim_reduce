function dataout_sft_fix=dynamic_truncation(datain,OW)

    datain_i = real(datain);
    datain_q = imag(datain);
    
    abs_data_i = abs(datain_i);
    abs_data_q = abs(datain_q);
    
    i_max = max(abs_data_i,[],[1,2]);
    q_max = max(abs_data_q,[],[1,2]);
    
    iq_max = max([i_max q_max]);
    
    idx = floor(log2(iq_max)+1);
    
    
    fprintf('i_max\t=\t%d\nq_max\t=\t%d\niq_max\t=\t%d\n',i_max,q_max,iq_max);
    
    
    factor_shift = idx - (OW-1);
    
    
    dataout_sft = datain/2^factor_shift;
    dataout_sft_fix = round(dataout_sft);

end