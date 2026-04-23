% clear;clc;close all;
%% Involve RIED
addpath(genpath('./RIED_core'));
addpath(genpath('./Utils'));
%% RIED recon
imgstack = imreadstack('bl.tif');
RIEDrecon = RIEDm(imgstack,'pixel',160,'NA',1.42,'wavelength',517,'iter1',4,'subfactor',0,'fidelity',150,'sparsity',20,'iter2',5);
%% Visualization
baseline = 560;
Rawimg = imfilter(mean(imgstack,3),generate_rsf(2));
Rawimg = Rawimg-baseline; 
Rawimg(Rawimg<0) = 0;
Rawimg = percennorm(Rawimg,1,100);
RIEDrecon = imfilter(RIEDrecon,generate_rsf(2));
RIEDrecon = percennorm(RIEDrecon,1,99.98);
load('colormap_yellowhot.mat')
figure,
subplot(1,2,1),imshow(Rawimg,[0 1],'colormap',colormap_yellowhot),title('Raw summed data')
subplot(1,2,2),imshow(RIEDrecon,[0 1],'colormap',colormap_yellowhot), title('RIED')