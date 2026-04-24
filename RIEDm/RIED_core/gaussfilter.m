function data_gauss = gaussfilter(data,sigma)
N = ceil(sigma*7);
gauf = fspecial('gaussian',[N N],sigma); 
data_gauss = zeros(size(data));
for i=1:size(data,3)
    data_gauss(:,:,i)=imfilter(data(:,:,i),gauf,'replicate');
end

