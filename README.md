

<p>
<h1 align="center">RIED<font color="#FF6600">m</font></h1>
<h5 align="center">luminescent Reaction enabled super-resolution Imaging via Entropy-weighted correlation combined with Deconvolution.</h5>
<h6 align="right">v0.8.0</h6>
</p>




## 📖 Introduction

<img width="982" height="500" alt="RIED concept" src="https://github.com/user-attachments/assets/446832f6-4e1a-445a-8988-fa155123452d" />


The **RIED** is a new conceptual and methodological framework for super-resolution luminescence imaging. It establishes that fluctuation information inherent in reaction-driven luminescence—including **electrochemiluminescence (ECL)**, **chemiluminescence (CL)**, and **bioluminescence (BL)**—can be harnessed to achieve super-resolution reconstruction, enabling zero-background, ultra-long-term super-resolution imaging with sub-100 nm resolution. Within this framework, we developed a specific computational reconstruction algorithm, which implements entropy-weighted correlation with dual-step deconvolution to extract super-resolved information from continuously collected short-exposure frames.



## 🧠 RIED reconstruction workflow

<img width="4391" height="1153" alt="RIED pipeline" src="https://github.com/user-attachments/assets/0f9d0d75-52f7-43c2-ba52-7b3a98b27c74" />

| Main step                        | Function                                                     |
| :------------------------------- | :----------------------------------------------------------- |
| **Pre-processing**               | Gaussian pre-filtering to suppress high-frequency sampling noise; <br />Fourier interpolation to provide a finer grid and ensures sufficient pixel support for subsequent resolution enhancement; <br />Pre-deconvolution to further suppress sampling noise and enhance fluctuation. |
| **Entropy-weighted correlation** | Identify emitters and extract super-resolved information     |
| **Post sparse deconvolution**    | Maximize resolution enhancement without introducing artefacts |



## 🔧 Installation

- ### Tested platforms


Matlab 2022b, with Wavelet Toolbox, Image Processing Toolbox, Parallel Computing Toolbox (Win 10, 128 GB RAM, NVIDIA RTX 4090 24 GB, CUDA 11.6)

- ### Quick start


```matlab
% Add RIEDm to your path
addpath(genpath('RIEDm'));

% Basic reconstruction
imgstack = imreadstack('bl.tif'); 
RIEDrecon = RIEDm(imgstack);
```



## ⚙️ Parameters

- ### Basic parameters


| Parameter    | Description              | Default | When to adjust                   |
| :----------- | :----------------------- | :------ | :------------------------------- |
| `pixel`      | Pixel size (nm)          | 160     | Match the microscope acquisition |
| `NA`         | Numerical aperture       | 1.45    | Match the objective lens         |
| `wavelength` | Emission wavelength (nm) | 620     | Match the luminescence peak      |

- ### Advanced parameters


| Parameter   | Description                                                  | Recommended Range | Default | When to adjust                                               |
| :---------- | :----------------------------------------------------------- | :---------------- | :------ | :----------------------------------------------------------- |
| `gauss`     | Gaussian pre-filter kernel size                              | 0.5-2             | 0.7     | **Higher** for low photon budget                             |
| `iter1`     | Pre-deconvolution iterations                                 | 2-10              | 4       | **Increase** to further enhance fluctuation and resolution, **reduce** if introduces artefacts |
| `subfactor` | Subtraction factor for cumulant                              | 0-1               | 0.5     | **Increase** if high fluctuation                             |
| `wavelet`   | Weight for wavelet defocus signal estimation                 | 0; 1-5            | 0       | Set to '**0**' for **ECL**, where defocus signal is negligible. For **CL** and **BL**, lower values remove defocus signal more aggressively |
| `fidelity`  | Fidelity weight for sparse deconvolution                     | 10-100            | 50      | **Lower** for high continuity constraint                     |
| `sparsity`  | Sparsity weight for sparse deconvolution                     | 0.1-5             | 0.5     | **Higher** for further resolution improvement, **Lower** if real structure signals are filtered out |
| `finter2`   | Factor of fourier interpolation  after entropy-weighted correlation | 1-2               | 1       | '**1**' is **enough for most cases**. Increase if higher resolution demand. |
| `iter2`     | Sparse deconvolution iterations                              | 2-15              | 5       | **Increase** to further enhance fluctuation, **reduce** if introduces artefacts |
| `gamma`     | Factor of intensity correction                               | 0.5-1             | 1       | **reduce** to further intensity correction                   |



## 🧪 Example demonstration

- ### Reconstruction for ECL

 (microtubules, 100 frames)

```
% Involve RIED
addpath(genpath('./RIED_core'));
addpath(genpath('./Utils'));

% RIED recon
imgstack = imreadstack('ecl1.tif');
RIEDrecon = RIEDm(imgstack,'pixel',160,'NA',1.45,'wavelength',620,'iter1',3,'subfactor',0.5,'fidelity',50,'sparsity',3,'iter2',7,'gamma',0.8);

% Visualization
baseline = 520;
Rawimg = imfilter(mean(imgstack,3),generate_rsf(1));
Rawimg = Rawimg-baseline; 
Rawimg(Rawimg<0) = 0;
Rawimg = percennorm(Rawimg,1,100);
RIEDrecon = imfilter(RIEDrecon,generate_rsf(3));
RIEDrecon = percennorm(RIEDrecon,1,99.98);
load('colormap_green.mat')
figure,
subplot(1,2,1),imshow(Rawimg,[0 1],'colormap',colormap_green),title('Raw summed data')
subplot(1,2,2),imshow(RIEDrecon,[0 1],'colormap',colormap_green), title('RIED')
```

- ### Reconstruction for ECL

 (microtubules, 50 frames)

```
% Involve RIED
addpath(genpath('./RIED_core'));
addpath(genpath('./Utils'));

% RIED recon
imgstack = imreadstack('ecl2.tif');
RIEDrecon = RIEDm(imgstack,'pixel',160,'NA',1.45,'wavelength',620,'iter1',3,'subfactor',1,'fidelity',20,'sparsity',1,'iter2',3);

% Visualization
baseline = 580;
Rawimg = imfilter(mean(imgstack,3),generate_rsf(1));
Rawimg = Rawimg-baseline; 
Rawimg(Rawimg<0) = 0;
Rawimg = percennorm(Rawimg,1,100);
RIEDrecon = imfilter(RIEDrecon,generate_rsf(1));
RIEDrecon = percennorm(RIEDrecon,1,99.5);
load('colormap_green.mat')
figure,
subplot(1,2,1),imshow(Rawimg,[0 1],'colormap',colormap_green),title('Raw summed data')
subplot(1,2,2),imshow(RIEDrecon,[0 1],'colormap',colormap_green), title('RIED')
```

- ### Reconstruction for BL

(mitochondria, 200 frames)

```
% Involve RIED
addpath(genpath('./RIED_core'));
addpath(genpath('./Utils'));

% RIED recon
imgstack = imreadstack('bl.tif');
RIEDrecon = RIEDm(imgstack,'pixel',160,'NA',1.42,'wavelength',517,'iter1',4,'subfactor',0,'fidelity',150,'sparsity',20,'iter2',5);

% Visualization
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
```



## 📚 Version 

| Version | Changes                                      |
| :------ | :------------------------------------------- |
| v0.8.0  | RIED reconstruction core for ECL, CL, and BL |
| v0.2.0  | RIED reconstruction core for ECL             |
| v0.1.0  | initial version                              |

