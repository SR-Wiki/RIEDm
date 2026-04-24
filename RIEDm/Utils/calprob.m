function [output] = calprob(data,bin,maxv,minv)

output = zeros(bin,1);
for i = 1:length(data)
    idx = round((data(i)-minv)/(maxv-minv)*bin);
    if idx < 0
        idx = 0;
    end
    if idx >= bin
        idx = bin-1;
    end
    output(idx+1) = output(idx+1)+1;
end  
output = output./length(data);
end
