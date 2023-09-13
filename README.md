# BRAVEHEART: Open-Source Software for Automated Electrocardiographic and Vectorcardiographic Analysis  
[![badge](https://badgen.net/badge/MATLAB/R2022a/?color=green)](https://www.mathworks.com/products/matlab.html) ![badge](https://badgen.net/badge/License/GPL-3.0/?color=red) 
![badge](https://github.com/BIVectors/BRAVEHEART/actions/workflows/testing.yml/badge.svg)  
 [![badge](https://img.shields.io/github/v/release/BIVectors/BRAVEHEART?label=Latest%20Release)](https://github.com/BIVectors/BRAVEHEART/releases) ![badge](https://img.shields.io/github/repo-size/BIVectors/BRAVEHEART?label=Repo%20Size) ![badge](https://img.shields.io/github/directory-file-count/BIVectors/BRAVEHEART?label=File%20Count) ![badge](https://img.shields.io/github/languages/code-size/BIVectors/BRAVEHEART?label=Code%20Size)  [![badge](https://badgen.net/badge/icon/Windows%20.exe?icon=windows&label)](https://github.com/BIVectors/BRAVEHEART/releases) [![badge](https://badgen.net/badge/icon/Mac%20.app?icon=apple&label)](https://github.com/BIVectors/BRAVEHEART/releases)

**Hans Fredrich Stabenau, MD, PhD & Jonathan W. Waks, MD  
Harvard-Thorndike Electrophysiology Institute, Department of Cardiovascular Medicine,  
Beth Israel Deaconess Medical Center, Harvard Medical School, Boston, MA, USA  
braveheart.ecg@gmail.com**
<p align="center">
<img src="https://user-images.githubusercontent.com/31230011/233160703-f79d52f0-4600-40dc-86df-76f667adb6fe.PNG" width="777" height="726">
</p>

## What is BRAVEHEART?
BRAVEHEART (Beth Israel Analysis of Vectors of the Heart) is a modular, customizable, open-source software package for processing electrocardiograms (ECGs) and vectorcardiograms (VCGs) for research purposes.  
BRAVEHEART was built using MATLAB and **requires a version after R2022a** (http://www.mathworks.com) as well as the following toolboxes to run via source code:
* Wavelet toolbox
* Signal processing toolbox
* Deep learning toolbox
* Parallel computing toolbox (optional)

For users without access to MATLAB or all required toolboxes, we have also provided executables for Windows and Mac operating systems that can be run without needing MATLAB installed.

The most up to date version of the software can be found on GitHub at http://www.github.com/BIVectors/BRAVEHEART, where the software, source code, and executables for Windows and Mac are available under version 3 of the General Public License (GPL) (http://www.gnu.org/licenses/gpl-3.0.en.html).

## License
![badge](https://badgen.net/badge/License/GPL-3.0/?color=red)  
**Copyright 2016-2023 Jonathan W. Waks and Hans F. Stabenau**  
All rights reserved.  
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.  You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/ or the [LICENSE](https://github.com/BIVectors/BRAVEHEART/blob/main/LICENSE) file included in this repository.

## Installation & User Guide/Software Methods
A detailed user guide that covers installation and use of the software, including a quick start guide and examples of ECG/VCG processing, is available in the file [braveheart_userguide.pdf](https://github.com/BIVectors/BRAVEHEART/blob/main/braveheart_userguide.pdf).  

A manuscript describing the software methods in detail is available in the file [braveheart_methods.pdf](https://github.com/BIVectors/BRAVEHEART/blob/main/braveheart_methods.pdf) and as a [manuscript in Computer Methods and Programs in Biomedicine](https://doi.org/10.1016/j.cmpb.2023.107798). 

## How to Cite Use of BRAVEHEART
Please include the link to this GitHub repository and cite our [manuscript in Computer Methods and Programs in Biomedicine](https://doi.org/10.1016/j.cmpb.2023.107798).  The upper right section of this repository has a [citation file](https://github.com/BIVectors/BRAVEHEART/blob/main/CITATION.cff) that will provide the appropriate references:  

[Hans F. Stabenau and Jonathan W. Waks. BRAVEHEART: Open-source software for automated electrocardiographic and vectorcardiographic analysis. _Computer Methods and Programs in Biomedicine_. 2023, In Press. DOI: https://doi.org/10.1016/j.cmpb.2023.107798](https://doi.org/10.1016/j.cmpb.2023.107798)  

## Publications
The software has been used for ECG/VCG analysis in the following publications:  
1. [H. F. Stabenau, C. Shen, L. G. Tereshchenko, and J. W. Waks. Changes in global electrical heterogeneity associated with dofetilide, quinidine, ranolazine, and verapamil. Heart Rhythm, 2020 Mar;17(3):460-467.](https://www.heartrhythmjournal.com/article/S1547-5271(19)30850-1/fulltext)

2. [H. F. Stabenau, C. Shen, P. Zimetbaum, A. E. Buxton, L. G. Tereshchenko, and J. W. Waks. Global electrical heterogeneity associated with drug-induced torsades de pointes. Heart Rhythm, 2021 Jan;18(1):57-62.](https://www.heartrhythmjournal.com/article/S1547-5271(20)30754-2/fulltext)

3. [H. F. Stabenau, C. P. Bridge, and J. W. Waks. ECGAug: A novel method of generating augmented annotated electrocardiogram QRST complexes and rhythm strips. Comput Biol Med, 2021 Jul;134:104408.](https://www.sciencedirect.com/science/article/abs/pii/S001048252100202X)

4. [H. F. Stabenau, M. Marcus, J. D. Matos, I. McCormick, D. Litmanovich, W. J. Manning, B. J. Carroll, and J. W. Waks. The spatial ventricular gradient is associated with adverse outcomes in acute pulmonary embolism. Ann Noninvasive Electrocardiol, 2023, Jan 24;e13041.](https://onlinelibrary.wiley.com/doi/10.1111/anec.13041)

5. [A. N. Rosas Diaz, H. F. Stabenau, G. P. Hurtado, S. Warack, J. W. Waks, and A. Asnani. The spatial ventricular gradient is an independent predictor of anthracycline-associated cardiotoxicity. JACC: Advances, 2(2):100269, 2023.](https://www.jacc.org/doi/10.1016/j.jacadv.2023.100269)

6. [H. F. Stabenau, A. Sau, D. B. Kramer, N. S. Peters, F. S. Ng, and J. W. Waks. Limits of the Spatial Ventricular Gradient and QRST Angles in Patients with Normal Electrocardiograms and No Known Cardiovascular Disease Stratified by Age, Sex, and Race. J Cardiovasc Electrophysiol, 2023, In Press.](https://doi.org/10.1111/jce.16062)

If you have used BRAVEHEART for your research project we would be happy to include a reference to your manuscript!

## Contributing
Please contact the authors by email at braveheart.ecg@gmail.com if you are interested in contributing to the project.
