[![Last Commit](https://img.shields.io/badge/last%20commit-July%202026-red)](https://github.com/SR-Wiki/RIEDm) [![Release](https://img.shields.io/badge/release-v0.1.0-orange)](https://github.com/SR-Wiki/RIEDm/releases/tag/v0.1) [![Paper](https://img.shields.io/badge/paper-Nature-blue)](https://doi.org/10.1038/s41586-026-10889-7)



<p>
<h1 align="center">RIED<font color="#FF6600">m</font></h1>
<h5 align="center">luminescent Reaction enabled super-resolution Imaging via Entropy-weighted correlation combined with Deconvolution.</h5>
<h6 align="right">v0.8.0</h6>
</p>



<img src="imgs/RIED Cover.png" width="270" align="left" hspace="50" alt="RIED cover">  

<br>
<br>
<div style="margin-left:180px">
    This repository is for <strong>RIED</strong> reconstruction, and it will be in continued   development. It is distributed as accompanying software for publication: <a href="https://doi.org/10.1038/s41586-026-10889-7"> <strong>Luminescent reaction enabled super-resolution imaging, <em>Nature</em> (2026)</strong> </a>. Please cite <strong>RIED</strong> in your publications if it helps your research. 
</div>

<br>
<br>
<br>
<br>
<a href="#introduction">📖 Introduction</a> |
<a href="#ried-reconstruction-workflow">🧠 RIED reconstruction workflow</a> |
<a href="#installation">🔧 Installation</a> |
<a href="#parameters">⚙️ Parameters</a> |
<a href="#example-demonstration">🧪 Example demonstration</a> |
<a href="#version">📚 Version</a> |
<a href="#resources">📖 Resources</a>

<br>
<br>
<br>


<br>
<br>
<br>

## 📖 Introduction

<img src="imgs\RIED concept.png"  style="zoom:80%;"  />

The **RIED** is a new conceptual and methodological framework for super-resolution luminescence imaging. It establishes that fluctuation information inherent in reaction-driven luminescence—including **electrochemiluminescence (ECL)**, **chemiluminescence (CL)**, and **bioluminescence (BL)**—can be harnessed to achieve super-resolution reconstruction, enabling zero-background, ultra-long-term super-resolution imaging with sub-100 nm resolution. Within this framework, we developed a specific computational reconstruction algorithm, which implements entropy-weighted correlation with dual-step deconvolution to extract super-resolved information from continuously collected short-exposure frames.



## 🧠 RIED reconstruction workflow 

<img src="imgs\RIED pipeline.png"  style="zoom:80%;"  />

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

% Basic reconstruction (GPU accelarated)
imgstack = imreadstack('bl.tif'); 
RIEDrecon = RIEDm(imgstack);

% Reconstruction based on pure CPU
imgstack = imreadstack('bl.tif','gpu',0); 
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
| `gpu`       | Enable GPU acceleration                                      | 1                 | 1       | Enable GPU acceleration to speed up processing. '**0**' for pure CPU computation. |



## 🧪 Example demonstration

- ### Reconstruction for ECL

 (microtubules, 50 frames)

```
% Involve RIED
addpath(genpath('./RIED_core'));
addpath(genpath('./Utils'));

% RIED recon
imgstack = imreadstack('RIEDm_data/ecl2.tif');
RIEDrecon = RIEDm(imgstack,'pixel',160,'NA',1.45,'wavelength',620,'iter1',3,'subfactor',0.6,'fidelity',50,'sparsity',9,'iter2',2);

% Visualization
visualize(imgstack, RIEDrecon, 480, 1, [1, 99.98], 'Green');
```

- ### Reconstruction for BL

(mitochondria, 200 frames)

```
% Involve RIED
addpath(genpath('./RIED_core'));
addpath(genpath('./Utils'));

% RIED recon
imgstack = imreadstack('RIEDm_data/bl.tif');
RIEDrecon = RIEDm(imgstack,'pixel',160,'NA',1.42,'wavelength',517,'iter1',5,'subfactor',0,'fidelity',150,'sparsity',20,'iter2',5);

% Visualization
visualize(imgstack, RIEDrecon, 480, 1, [1, 99.98], 'Yellowhot');
```



## 📚 Version 

| Version | Changes                                      |
| :------ | :------------------------------------------- |
| v0.8.0  | RIED reconstruction core for ECL, CL, and BL |
| v0.2.0  | RIED reconstruction core for ECL             |
| v0.1.0  | initial version                              |



## 📖 Resources

- **Preprint:** [Reaction-enabled, highly sensitive super-resolution imaging, *bioRxiv* (2026).](https://www.biorxiv.org/content/10.64898/2026.02.04.703714v1)

- **Publication:** [Luminescent reaction enabled super-resolution imaging, *Nature* (2026).](https://doi.org/10.1038/s41586-026-10889-7)



## Open source [RIED](https://github.com/SR-Wiki/RIEDm)
This software and corresponding methods can only be used for **non-commercial** use, and they are under Open Data Commons Open Database License v1.0.
