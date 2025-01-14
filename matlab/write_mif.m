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

end
