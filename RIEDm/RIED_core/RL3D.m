function data_decon = RL3D(data,kernel,iteration,gpu)
kernel = kernel./sum(sum(sum(kernel)));
otf = psf2otf(kernel,size(data));
if gpu == 0
    yk = data;
    xk1 = zeros(size(data));
    vk1 = zeros(size(data));  
else
    otf = gpuArray(otf);
    data = gpuArray(data);
    yk = data;
    xk1 = gpuArray.zeros(size(data));
    vk1 = xk1;
end
%update
for iter = 1:iteration
        [yk1, xk1, vk1] = deblur_coreRL(yk, data, otf, xk1, vk1, iter);
        yk = yk1 ;
end
data_decon = real(yk);
end


function [yk, xk, vk] = deblur_coreRL(yk, data, otf, xk, vk, iter)
rliter = @(estimate, data, otf)fftn(data./ max(ifftn(otf .* fftn(estimate)), 1e-5));
xk_update=xk;
xk= max(yk.*real(ifftn(conj(otf).*rliter(yk,data,otf))),1e-5);
vk_update=vk;
vk=max(xk-yk,1e-5);
if iter==1
    alpha=0;
else
    alpha=sum(sum(sum(vk_update.*vk)))/(sum(sum(sum(vk_update.*vk_update)))+eps);
    alpha=max(min(alpha,1),0);
end
yk=real(max(xk+alpha*(xk-xk_update),1e-5));
end

