function [output] = binning(inputdata,binsize)
if nargin < 2 || isempty(binsize)
    binsize = 2;
end
[rows, cols] = size(inputdata);
output = zeros(rows/binsize, cols/binsize);
for i=1:binsize:rows
    for j=1:binsize:cols
        block = inputdata(i:i+binsize-1,j:j+binsize-1);
        output((i+binsize-1)/binsize,(j+binsize-1)/binsize)=mean(block(:));
    end
end
end