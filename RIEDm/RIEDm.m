function [RIEDresult] = RIEDm(imgstack, varargin)
%***************************************************************************
% RIED
%***************************************************************************
% function [RIEDresult] = RIEDm(imgstack,varargin)
%----------------------------------------------------
% Source code for RIED reconstruction
% imgstack   input data to be evaluated
% varargin   configurations
%----------------------------------------------------
%***************************Configurations**********************************
%-------basic parameters for image property----------
% pixel       |  Pixel size in nanometer {default: 160}
% wavelength  |  Emission wavelength in nanometer {default: 620}
% NA          |  Numerical aperture of objective {default: 1.45}
%--------Advanced parameters for RIED recon----------
% gauss       |  Gaussian pre-filter kernel size {default: 0.7}
% iter1       |  Pre-deconvolution iterations {default: 4}
% subfactor   |  Subtraction factor for cumulant {default: 0.5}
% wavelet     |  Weight of wavelet analysis for defocus-signal estimation {default: 0}
% finter2     |  Fourier interpolation factor after entropy-weighted correlation {default: 1}
% fidelity    |  Fidelity weight for sparse deconv.. {default: 50}
% sparsity    |  Sparsity weight for sparse deconv.. {default: 0.5}
% iter2       |  Sparse deconvolution iterations {default: 3}
% scale       |  PSF scale for post deconvolution {default: 1}
% gamma       |  Factor of intensity correction
%--Addtional parameters (Usually no need to adjust)--
% finter      |  Fourier interpolation factor before Pre-deconvolution {default: 2}
% bin         |  Bin for calculation of entropy map {default: 50}
%***************************************************************************
% Output:
%  Super-resolution image -> RIED result 
%***************************************************************************
% basic parameters
params.pixel = 160;       % Pixel size (nm)
params.wavelength = 620;  % Numerical aperture
params.NA = 1.45;         % Emission wavelength (nm)
% Advanced parameters
params.gauss = 0.7;       % Gaussian pre-filter kernel size
params.iter1 = 4;         % Pre-deconvolution iterations
params.subfactor = 0.5;   % Subtraction factor for cumulant
params.wavelet = 0;       % Weight of wavelet analysis for defocus-signal estimation 
params.finter2 = 1;       % Factor of fourier interpolation after entropy-weighted correlation
params.fidelity = 50;     % Fidelity weight for sparse deconvolution
params.sparsity = 0.5;    % Sparsity weight for sparse deconvolution
params.iter2 = 5;         % Sparse deconvolution iterations
params.scale = 1;         % PSF scale for post deconvolution
params.gamma = 1;         % Factor of intensity correction
% Additional parameters (Usually no need to adjust)
params.finter = 2;        % Fourier interpolation factor before Pre-deconvolution. 
params.bin = 50;          % Bin for calculation of entropy map

warning('off');
addpath('./Utils');
addpath('./RIED_core');

if nargin > 2
    params =  read_params(params, varargin);
end
%% percentage norm
data = single(imgstack);
data(data>5000) = data(data>5000)./50; % Remove hot spot noise
%% Gauss pre-filtering
disp(['Guassian pre-filter...'])
if params.gauss~=0
    gau = fspecial('gaussian',[ceil(params.gauss*7) ceil(params.gauss*7)],params.gauss); 
    data_gauss = zeros(size(data));
    for i=1:size(data,3)
        data_gauss(:,:,i)=imfilter(data(:,:,i),gau,'replicate');
    end
else
    data_gauss = data;
end
%% Fourier interpolation
disp(['Fourier Interpolation...'])
data_FI = abs(fourierInterpolation(data_gauss,[params.finter,params.finter,1],'lateral')); 
data_FI(data_FI < 0) = 0;
%% Pre-deconvolution
disp(['Pre-deconvolution...'])
pixel = params.pixel * 10^-9;
wavelength = params.wavelength * 10^-9;
Ipsf1 = kernel(pixel/params.finter, wavelength, params.NA, 0, min(size(data,1),size(data,2)));
data_deconv = zeros(size(data_FI));
for i=1:size(data_FI,3)
    data_deconv(:,:,i) = abs(RL3D(data_FI(:,:,i),Ipsf1,params.iter1,1));
end
%% Entropy weighted correlation
disp(['Entropy weighted correlation...'])
EC = entrocor(data_deconv, params.bin, params.subfactor, max(data_deconv(:)), 480);
%% defocus-signal removal
EC1 = EC.^1;
if params.wavelet~=0
    DS = background_estimation(EC./params.wavelet,1,10,'fk14',1); 
    DS(DS<0)=0;
    EC = EC-DS;
    EC(EC<0) = 0; 
    EC = EC./max(EC(:));
end
%% Post Sparse deconvolution
disp(['Sparse deconvolution...'])
EC_FI = abs(fourierInterpolation(EC,[params.finter2,params.finter2],'lateral')); 
EC_FI(EC_FI < 0) = 0;
EC_FI = EC_FI ./max(EC_FI(:));
Ipsf2 = kernel(pixel./(params.finter*params.finter2)/2, wavelength, params.NA, 0, min(size(data,1),size(data,2)));
RIEDresult = Spasedeconv(EC_FI, params.fidelity, 0, params.sparsity, 100, Ipsf2, params.iter2, params.scale);
RIEDresult = RIEDresult.^params.gamma;
disp('RIED reconstruction completed.');







