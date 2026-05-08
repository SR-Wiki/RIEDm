% clear;clc;close all;
%% Involve RIED
addpath(genpath('./RIED_core'));
addpath(genpath('./Utils'));
%% RIED recon
imgstack = imreadstack('RIEDm_data/bl.tif');
RIEDrecon = RIEDm(imgstack,'pixel',160,'NA',1.42,'wavelength',517,'iter1',4,'subfactor',0,'fidelity',150,'sparsity',20,'iter2',5);
%% Visualization
visualize(imgstack, RIEDrecon, 560, 1, [1, 99.98], 'Yellowhot');
