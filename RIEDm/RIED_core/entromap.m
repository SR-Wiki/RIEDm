function [output] = entromap(data, bin, maxv, minv)
[x,y,~] = size(data);
output = zeros(x*2, y*2);
for i = 1:x-1
    for j = 1:y-1
        for m = 0:1
            for n = 0:1
                if m+n==0
                    p1 = squeeze(data(i,j,:)); 
                    output(2*i-1, 2*j-1) = xEtr(p1,p1,bin,maxv,minv);
                end
                if m+n==1
                    p1 = squeeze(data(i,j,:));
                    p2 = squeeze(data(i+m,j+n,:));
                    output(2*i-1+m, 2*j-1+n) = xEtr(p1,p2,bin,maxv,minv);
                end
                if m+n==2
                    p1 = squeeze(data(i,j,:));
                    p2 = squeeze(data(i+m,j,:));
                    p3 = squeeze(data(i,j+n,:));
                    p4 = squeeze(data(i+m,j+n,:));
                    output(2*i+m-1, 2*j+n-1) = ((xEtr(p1,p4,bin,maxv,minv)+xEtr(p2,p3,bin,maxv,minv))/2);
                end
            end
        end
    end
end


end


