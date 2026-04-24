function [output] = entrocor(data, bin, offset, maxv, minv)
entrom = entromap(data, bin, maxv, minv);
ecum = XCcumulant(data, 1, offset);
output = entrom.*ecum;
output = output./max(output(:));
end