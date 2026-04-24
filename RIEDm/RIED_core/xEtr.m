function [output] = xEtr(data1, data2, bin, maxv, minv)

P1 = calprob(data1,bin,maxv,minv);
P2 = calprob(data2,bin,maxv,minv);
h_sum = 0;
for i = 1:length(P1)
    if P1(i)>0
        h_sum = h_sum + P2(i)*log(P1(i));
    end
    if P2(i)>0
        h_sum = h_sum + P1(i)*log(P2(i));
    end
end
output = -h_sum/2;
end