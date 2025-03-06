<img src="https://www.dropbox.com/scl/fi/brlupwxyu5eb4w42el6yj/header.png?rlkey=4wjx7rd6m8hjbc4b8xyb9hlfo&raw=1">

# BRAVEHEART: Open-Source Software for Automated Electrocardiographic and Vectorcardiographic Analysis  
[![badge](https://badgen.net/badge/MATLAB/R2022a/?color=green)](https://www.mathworks.com/products/matlab.html) ![badge](https://badgen.net/badge/License/GPL-3.0/?color=red) 
![badge](https://github.com/BIVectors/BRAVEHEART/actions/workflows/testing.yml/badge.svg)  
 [![badge](https://img.shields.io/github/v/release/BIVectors/BRAVEHEART?label=Latest%20Release)](https://github.com/BIVectors/BRAVEHEART/releases) ![badge](https://img.shields.io/github/repo-size/BIVectors/BRAVEHEART?label=Repo%20Size) ![badge](https://img.shields.io/github/directory-file-count/BIVectors/BRAVEHEART?label=File%20Count) ![badge](https://img.shields.io/github/languages/code-size/BIVectors/BRAVEHEART?label=Code%20Size)  [![badge](https://badgen.net/badge/icon/Windows%20.exe?icon=windows&label)](https://github.com/BIVectors/BRAVEHEART/releases) [![badge](https://badgen.net/badge/icon/Mac%20.app?icon=apple&label)](https://github.com/BIVectors/BRAVEHEART/releases)   
 [![badge](https://img.shields.io/badge/User%20Guide-F7DF1E?logo=adobeacrobatreader&style=flat&labelColor=555)](https://github.com/BIVectors/BRAVEHEART/blob/main/braveheart_userguide.pdf) [![badge](https://img.shields.io/badge/Methods%20Manuscript-F7DF1E?logo=elsevier&style=flat&logoColor=white&labelColor=555)](https://doi.org/10.1016/j.cmpb.2023.107798)   

**Hans Fredrich Stabenau, MD, PhD & Jonathan W. Waks, MD  
Harvard-Thorndike Electrophysiology Institute, Department of Cardiovascular Medicine,  
Beth Israel Deaconess Medical Center, Harvard Medical School, Boston, MA, USA  
braveheart.ecg@gmail.com**
<p align="center">
<img src="https://www.dropbox.com/scl/fi/22skovb935d6v2gs74pxj/2pics.png?rlkey=79okilw9o0sify4tqocuy1siq&raw=1"></p>

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
**Copyright 2016-2025 Jonathan W. Waks and Hans F. Stabenau**  
All rights reserved.  
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.  You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/ or the [LICENSE](https://github.com/BIVectors/BRAVEHEART/blob/main/LICENSE) file included in this repository.

## Installation & User Guide/Software Methods
[![badge](https://img.shields.io/badge/User%20Guide-F7DF1E?logo=adobeacrobatreader&style=flat&labelColor=555)](https://github.com/BIVectors/BRAVEHEART/blob/main/braveheart_userguide.pdf)   
A detailed user guide that covers installation and use of the software, including a quick start guide and examples of ECG/VCG processing, is available in the file [braveheart_userguide.pdf](https://github.com/BIVectors/BRAVEHEART/blob/main/braveheart_userguide.pdf).  

[![badge](https://img.shields.io/badge/Methods%20Manuscript-F7DF1E?logo=elsevier&style=flat&logoColor=white&labelColor=555)](https://doi.org/10.1016/j.cmpb.2023.107798)    
A manuscript describing the software methods in detail is available in the file [braveheart_methods.pdf](https://github.com/BIVectors/BRAVEHEART/blob/main/braveheart_methods.pdf) and as a [manuscript in Computer Methods and Programs in Biomedicine (DOI: https://doi.org/10.1016/j.cmpb.2023.107798)](https://doi.org/10.1016/j.cmpb.2023.107798). 

## Frequently Encountered Issue - GUI Not Displaying Correctly
If the GUI is not displaying completely first check that your **monitor resolution is at least 1920 x 1080**.  If your monitor resolution is adequate but the GUI is still not fully displaying, 
your computer display settings likely have some form of scaling turned on; this setting increases the size of text to improve readability, but also effectively reduces the screen resolution.
Instructions for how to disable this setting can be found below or in the user guide section 29.1:

To disable screen scaling:   
+ **Windows 10:** Open the Ease of Access settings with Windows key + U. Under
Make everything bigger on the Display tab, change to 100%.   
+ **Windows 11:** Open Settings and then Display. Under Scale & layout, expand the Scale
menu and change to 100%.   
+ **Mac OS:** Open System Preferences and then Display. Choose Scaled Resolution and then
More Space

## Supported ECG Formats:
BRAVEHEART can read a wide variety of 12-lead ECG formats including:
1. GE MUSE XML
2. Philips XML
3. HL7 XML
4. DICOM
5. ISHNE
6. GE Marquette ASCII
7. Cardiosoft XML
8. Schiller XML
9. SCP-ECG
10. EDF
11. Physionet .dat
12. Physionet .csv
13. GE Prucka
14. Abbott Workmate Claris ASCII
15. Unformatted .txt and .csv
16. Norav 1200M .rdt
17. Megacare XML
18. Edan .dat

If you need BRAVEHEART to read another ECG format let us know and we will help add it.

## How to Cite Use of BRAVEHEART
Please include the link to this GitHub repository and cite our [manuscript in Computer Methods and Programs in Biomedicine](https://doi.org/10.1016/j.cmpb.2023.107798).  The upper right section of this repository has a [CITATION file](https://github.com/BIVectors/BRAVEHEART/blob/main/CITATION.cff) that will provide the appropriate references which are also reproduced here:  

Citation:   
[Hans F. Stabenau and Jonathan W. Waks. BRAVEHEART: Open-source software for automated electrocardiographic and vectorcardiographic analysis. _Computer Methods and Programs in Biomedicine_. Volume 242, Dec 2023, 107798. DOI: https://doi.org/10.1016/j.cmpb.2023.107798](https://doi.org/10.1016/j.cmpb.2023.107798)  
```
Stabenau, HF and Waks, JW. BRAVEHEART: Open-source software for automated electrocardiographic and vectorcardiographic analysis. Comput Methods Programs Biomed. Volume 242, Dec 2023, 107798. DOI: https://doi.org/10.1016/j.cmpb.2023.107798
```

Bibtex:
```
@Article{BRAVEHEART,
   Author="Stabenau, H. F.  and Waks, J. W. ",
   Title="{{B}{R}{A}{V}{E}{H}{E}{A}{R}{T}: {O}pen-source software for automated electrocardiographic and vectorcardiographic analysis}",
   Journal="Comput Methods Programs Biomed",
   Year="2023",
   Volume="242",
   Pages="107798",
   Month="Dec",
   doi = {https://doi.org/10.1016/j.cmpb.2023.107798}
}

```

## Publications
The software has been used for ECG/VCG analysis in the following publications:  
1. [HF Stabenau, C Shen, LG Tereshchenko, and JW. Waks. Changes in global electrical heterogeneity associated with dofetilide, quinidine, ranolazine, and verapamil. _Heart Rhythm_, 2020 Mar;17(3):460-467.](https://www.heartrhythmjournal.com/article/S1547-5271(19)30850-1/fulltext)

2. [HF Stabenau, C Shen, P Zimetbaum, AE Buxton, LG Tereshchenko, and JW Waks. Global electrical heterogeneity associated with drug-induced torsades de pointes. _Heart Rhythm_, 2021 Jan;18(1):57-62.](https://www.heartrhythmjournal.com/article/S1547-5271(20)30754-2/fulltext)

3. [HF Stabenau, CP Bridge, and JW Waks. ECGAug: A novel method of generating augmented annotated electrocardiogram QRST complexes and rhythm strips. _Comput Biol Med_, 2021 Jul;134:104408.](https://www.sciencedirect.com/science/article/abs/pii/S001048252100202X)

4. [HF Stabenau, M Marcus, JD Matos, I McCormick, D Litmanovich, WJ Manning, BJ Carroll, and JW Waks. The spatial ventricular gradient is associated with adverse outcomes in acute pulmonary embolism. _Ann Noninvasive Electrocardiol_, 2023, Jan 24;e13041.](https://onlinelibrary.wiley.com/doi/10.1111/anec.13041)

5. [AN Rosas Diaz, HF Stabenau, GP Hurtado, S Warack, JW Waks, and A Asnani. The spatial ventricular gradient is an independent predictor of anthracycline-associated cardiotoxicity. _JACC: Adv_, 2(2):100269, 2023.](https://www.jacc.org/doi/10.1016/j.jacadv.2023.100269)

6. [HF Stabenau, A Sau, DB Kramer, NS Peters, FS Ng, and JW Waks. Limits of the Spatial Ventricular Gradient and QRST Angles in Patients with Normal Electrocardiograms and No Known Cardiovascular Disease Stratified by Age, Sex, and Race. _J Cardiovasc Electrophysiol_, 2023 Nov;34(11):2305-2315.](https://doi.org/10.1111/jce.16062)

7. [N Isaza, HF Stabenau, DB Kramer, A Sau, P Tung, TR Maher, AH Locke, P Zimetbaum, A d’Avila, NS Peters, LG Tereshchenko, FS Ng, AE Buxton, and JW Waks. The Spatial Ventricular Gradient is Associated with Inducibility of Ventricular Arrhythmias During Electrophysiology Study. _Heart Rhythm_, 2024 Nov;21(11):2160-2167](https://doi.org/10.1016/j.hrthm.2024.05.005)

8. [L Pastika, A Sau, K Patlatzoglou, E Sieliwonczyk, AH Ribeiro, KA McGurk, S Khan, D Mandic, WR Scott, JS Ware, NS Peters, ALP Ribeiro, DB Kramer, JW Waks, and FS Ng. Deep Neural Network-derived Electrocardiographic Body Mass Index as a Predictor of Cardiometabolic Disease. _NPJ Digit. Med._ 2024 Jun 25;7(1):167.](https://doi.org/10.1038/s41746-024-01170-0)

9. [A Sau, L Pastika, E Sieliwonczyk, K Patlatzoglou, AH Ribeiro, KA McGurk, B Zeidaabadi, H Zhang, K Macierzanka, D Mandic, E Sabino, L Giatti, SM Barreto, L do Valle Camelo, I Tzoulaki, DP O’Regan, NS Peters, JS Ware, ALP Ribeiro, DB Kramer, JW Waks, and FS Ng.  Artificial intelligence-enabled electrocardiogram for mortality and cardiovascular risk estimation: a model development and validation study _Lancet Digit Health_. 2024 Nov;6(11):e791-e802](https://www.thelancet.com/journals/landig/article/PIIS2589-7500(24)00172-9/fulltext)

10. [M Raad, DB Kramer, HF Stabenau, E Anyanwu, DS Frankel, and JW Waks. The Spatial Ventricular Gradient Is Associated with Pacing-Induced Cardiomyopathy. _Heart Rhythm_. 2024. In Press](https://www.heartrhythmjournal.com/article/S1547-5271(24)03710-X/)

11. [A Sau, J Barker, L Pastika, E Sieliwonczyk, K Patlatzoglou, KA McGurk, NS Peters, DP O'Regan, JS Ware, DB Kramer, JW Waks, and FS Ng. Artificial Intelligence-Enhanced Electrocardiography for Prediction of Incident Hypertension. _JAMA Cardiol_.  2025, Jan 2.](https://jamanetwork.com/journals/jamacardiology/article-abstract/2828420)

12. [K Macierzanka, A Sau, K Patlatzoglou, L Pastika, E Sieliwonczyk, M Gurnani, NS Peters, JW Waks, DB Kramer, and FS Ng Siamese neural network-enhanced electrocardiography can re-identify anonymised healthcare data. _Eur Heart J Digit Health_. 2025, Feb 25.](https://academic.oup.com/ehjdh/advance-article/doi/10.1093/ehjdh/ztaf011/8042356)

13. [A Sau, E Sieliwonczyk, K Patlatzoglou, L Pastika, K McGurk, AH Ribeiro, ALP Ribeiro, JE Ho, NS Peters, JS Ware, U Tayal, DB Kramer, JW Waks, and FS Ng. Artificial intelligence- enhanced electrocardiography for the identification of a sex-related cardiovascular risk continuum: a retrospective cohort study. _Lancet Digit Health_, 2025 Mar;7(3):e184-e194.](https://www.sciencedirect.com/science/article/pii/S258975002400270X)


If you have used BRAVEHEART for your research project we would be happy to include a reference to your manuscript!

## Contributing
Please contact the authors by email at braveheart.ecg@gmail.com if you are interested in contributing to the project.
