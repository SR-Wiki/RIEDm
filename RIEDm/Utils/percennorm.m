function output = percennorm(data, miper, maper)
if nargin < 3, maper = 100; end
if nargin < 2, miper = 0; end
data = single(data);
max(data(:));
datamin = prctile(data(:), miper);
datamax = prctile(data(:), maper);
output = (data - datamin) / (datamax - datamin);
output(output > 1) = 1;
output(output < 0) = 0;
end