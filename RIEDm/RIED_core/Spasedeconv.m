function [output] = Spasedeconv(input, mu, sigma_t, l10, iter_Bregman, psf, iter, scale)

    lamda = 1;
    siranu=mu;
    zbei=sigma_t;
    input=single(input);
    [sx,sy,~] = size(input);
    ind_sam = 1;
    ind_down_y1 = ind_sam:ind_sam:sy*ind_sam;
    ind_down_x1 = ind_sam:ind_sam:sx*ind_sam;
    y(ind_down_x1,ind_down_y1,:) =input;
    
    [sx,sy,sz] = size(y);
    sizex=[sx,sy,sz] ;
    y_flag=size(y,3);
    l1=l10;
    x = zeros(sizex);                  
    ztiduzz(:,:,1)=1;
    ztiduzz(:,:,2)=-2;
    ztiduzz(:,:,3)=1;
    ztiduxz(:,:,1)=[1,-1];
    ztiduxz(:,:,2)=[-1,1];
    ztiduyz(:,:,1)=[1;-1];
    ztiduyz(:,:,2)=[-1;1];

    tmp_fft=fftn([1 -2 1],sizex).*conj(fftn([1 -2 1],sizex));
    Frefft = tmp_fft;
    tmp_fft=fftn([1 ;-2 ;1],sizex).*conj(fftn([1; -2 ;1],sizex));
    Frefft=Frefft + tmp_fft;
    tmp_fft=fftn(ztiduzz,sizex).*conj(fftn(ztiduzz,sizex));
    Frefft=Frefft +(zbei^2)*tmp_fft;
    tmp_fft=fftn([1 -1;-1 1],sizex).*conj(fftn([1 -1;-1 1],sizex));
    Frefft=Frefft + 2 * tmp_fft;
    tmp_fft=fftn(ztiduxz,sizex).*conj(fftn(ztiduxz,sizex));
    Frefft=Frefft + 2 * (zbei)*tmp_fft;
    tmp_fft= fftn(ztiduyz,sizex).*conj(fftn(ztiduyz,sizex));
    Frefft=Frefft + 2 * (zbei)*tmp_fft;
    clear  tmp_fft
    divide = single((siranu/lamda)+Frefft);
    clear  Frefft

    b1 = zeros(sizex,'single');
    b2 = zeros(sizex,'single');
    b3 = zeros(sizex,'single');
    b4 = zeros(sizex,'single');
    b5 = zeros(sizex,'single');
    b6 = zeros(sizex,'single');
    b7 = zeros(sizex,'single');
    b8 = zeros(sizex,'single');
    x = zeros(sizex,'int32');
    frac = (siranu/lamda)*(y);
    frac(frac<0)=0;
    frac=gpuArray(frac);
    for ii = 1:iter_Bregman
        tic
        frac = fftn(frac);
        if ii>1
            x = real(ifftn(frac./divide));
        else
            x = real(ifftn(frac./(siranu/lamda)));
        end
        frac = (siranu/lamda)*(y);
        %         frac(frac<0)=0;
        u = back_diff(forward_diff(x,1,1),1,1);
        signd = abs(u+b1)-1/lamda;
        signd(signd<0)=0;
        signd=signd.*sign(u+b1);
        d=signd;
        b1 = b1+(u-d);
        frac = frac+back_diff(forward_diff(d-b1,1,1),1,1);
        
        u = back_diff(forward_diff(x,1,2),1,2);
        signd = abs(u+b2)-1/lamda;
        signd(signd<0)=0;
        signd=signd.*sign(u+b2);
        d=signd;
        b2 = b2+(u-d);
        frac = frac+back_diff(forward_diff(d-b2,1,2),1,2);
        
        u = back_diff(forward_diff(x,1,3),1,3);
        signd = abs(u+b3)-1/lamda;
        signd(signd<0)=0;
        signd=signd.*sign(u+b3);
        d=signd;
        b3 = b3+(u-d);
        frac = frac+(zbei^2)*back_diff(forward_diff(d-b3,1,3),1,3);
        
        u = forward_diff(forward_diff(x,1,1),1,2);
        signd = abs(u+b4)-1/lamda;
        signd(signd<0)=0;
        signd=signd.*sign(u+b4);
        d=signd;
        b4 = b4+(u-d);
        frac = frac+ 2 * back_diff(back_diff(d-b4,1,2),1,1);
        
        u = forward_diff(forward_diff(x,1,1),1,3);
        signd = abs(u+b5)-1/lamda;
        signd(signd<0)=0;
        signd=signd.*sign(u+b5);
        d=signd;
        b5 = b5+(u-d);
        frac = frac+ 2 * (zbei)*back_diff(back_diff(d-b5,1,3),1,1);
        
        u = forward_diff(forward_diff(x,1,2),1,3);
        signd = abs(u+b6)-1/lamda;
        signd(signd<0)=0;
        signd=signd.*sign(u+b6);
        d=signd;
        b6 = b6+(u-d);
        frac = frac+ 2 * (zbei)*back_diff(back_diff(d-b6,1,3),1,2);
        
        u=x;
        signd=abs(u+b7)-1/lamda;
        signd(signd<0)=0;
        signd=signd.*sign(u+b7);
        d=signd;
        b7 = b7+(u-d);
        frac = frac+l1.*(d-b7);
        x(x<0)=0;

    end
    x(x<0)=0;
    x=x(:,:,1:y_flag);
    cr = single(gather(x));
    cr = cr./max(cr(:));
    output = abs(gather(RLdeconv(cr,psf.^scale,iter,1)));
    output = output./max(output(:));

end