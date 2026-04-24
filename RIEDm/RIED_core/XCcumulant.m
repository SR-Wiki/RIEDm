function [output] = XCcumulant(data, order, offset)
output = zeros(size(data,1)*2,size(data,2)*2);
cdata = abs(data - offset * mean(data,3)).^order;
output(2:2:end-1,1:2:end) = mean(cdata(1:end-1,:,:).*cdata(2:end,:,:),3);
output(1:2:end,2:2:end-1) = mean(cdata(:,1:end-1,:).*cdata(:,2:end,:),3);
output(2:2:end-1,2:2:end-1) = (mean(cdata(1:end-1,1:end-1,:).*cdata(2:end,2:end,:),3) + mean(cdata(1:end-1,2:end,:).*cdata(2:end,1:end-1,:),3))/2;
output(1:2:end,1:2:end) = mean(cdata(:,:,1:end-1).*cdata(:,:,2:end),3);
end