function visualize(imgstack, RIEDrecon, baseline, rsf, pcn, cmap_fun)
%-------parameters for visualization----------
% imgstack  | Raw stack of reaction-based luminescence data
% RIEDrecon | RIED super-resolution reconstruction
% baseline  | Baseline background
% rsf       | Resolution scaling function
% pcn       | Lower and upper limits of percentage normalization for RIED
% cmap_fun  | Name of colormap

Rawimg = imfilter(mean(imgstack,3),generate_rsf(rsf));
Rawimg = Rawimg-baseline; 
Rawimg(Rawimg<0) = 0;
Rawimg = percennorm(Rawimg,1,100);
RIEDrecon = imfilter(RIEDrecon,generate_rsf(rsf));
RIEDrecon = percennorm(RIEDrecon,pcn(1),pcn(2));
switch cmap_fun
    case 'Green'
        cmap = getColorGreen();
    case 'Yellowhot'
        cmap = getColorYellowhot();
    otherwise
        error('Unsupported colormap. Use ''Green'' or ''Yellowhot''.');
end
figure,
subplot(1,2,1),imshow(Rawimg,[0 1],'colormap',cmap),title('Raw summed data')
subplot(1,2,2),imshow(RIEDrecon,[0 1],'colormap',cmap), title('RIED')
end

function cmap = getColorGreen()
    v = linspace(0, 1, 256);
    key_x = [0, 0.12, 0.33, 0.60, 0.83, 1.00];
    key_r = [0, 0.03, 0.07, 0.14, 0.20, 0.85];
    key_g = [0, 0.18, 0.37, 0.64, 0.89, 1.00];
    key_b = [0, 0.02, 0.02, 0.05, 0.08, 0.08];
    cmap = [interp1(key_x, key_r, v, 'linear')', ...
            interp1(key_x, key_g, v, 'linear')', ...
            interp1(key_x, key_b, v, 'linear')'];
end

function cmap = getColorYellowhot()
    v = linspace(0, 1, 256);
    key_x = [0, 0.31, 0.50, 0.70, 0.87, 1.00];
    key_r = [0, 0.73, 0.90, 1.00, 1.00, 1.00];
    key_g = [0, 0.55, 0.80, 1.00, 1.00, 1.00];
    key_b = [0, 0.00, 0.00, 0.09, 0.60, 1.00];
    cmap = [interp1(key_x, key_r, v, 'linear')', ...
            interp1(key_x, key_g, v, 'linear')', ...
            interp1(key_x, key_b, v, 'linear')'];
end