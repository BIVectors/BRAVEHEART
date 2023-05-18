%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% tcrt.m -- Calcualtes Total Cosine R-to-T
% Copyright 2016-2023 Hans F. Stabenau and Jonathan W. Waks
% 
% Source code/executables: https://github.com/BIVectors/BRAVEHEART
% Contact: braveheart.ecg@gmail.com
% 
% BRAVEHEART is free software: you can redistribute it and/or modify it under the terms of the GNU 
% General Public License as published by the Free Software Foundation, either version 3 of the License, 
% or (at your option) any later version.
%
% BRAVEHEART is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <https://www.gnu.org/licenses/>.
%
% This software is for research purposes only and is not intended to diagnose or treat any disease.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [tcrt, angle] = tcrt(ecg, vcg, fidpts, cutpt, debug)

% ecg : median beat ECG object
% vcg : median beat VCG object
% fidpts : median beat fiducial points as 1x4 vector [Qon Rpk Qoff Toff]
% cutpt: fraction of E3 max used for calculating the TCRT (nominal 0.7)
% debug : set = 1 to show some figures if needed, set = 0 otherwise

% Method described in https://pubmed.ncbi.nlm.nih.gov/10723894/
% Acar et al Med Biol Eng Comput 1999 Sep;37(5):574-84.

% calculate E3 and the samples of cutpt% from max E3
[S1, S2, S3, E3, timeRs, timeRe] = svd_8lead(ecg, cutpt, fidpts, debug);

% Now have moved into the SVD basis:
% S1 = 'X'
% S2 = 'Y'
% S3 = 'Z'
Sqrs = [S1(fidpts(1):fidpts(3)) S2(fidpts(1):fidpts(3)) S3(fidpts(1):fidpts(3))];
St = [S1(fidpts(3):fidpts(4)) S2(fidpts(3):fidpts(4)) S3(fidpts(3):fidpts(4))];

% Correct timeRs and timeRe to account for the location relative to Qon
% because E3 is the entire median beat, but QRS loop starts at Qon
timeRs = timeRs - fidpts(1);
timeRe = timeRe - fidpts(1);

% PCA if want to do it that way
%[coeff,newdata,latend,tsd,variance,mu] = pca(txyz);

% Find point of Tmax in E3 (which is like VM lead in XYZ coord system)
%start 80 ms after QRS end to avoid any issues with annotation
TE3 = E3(fidpts(3)+(round(80/(1000/ecg.hz))):fidpts(4));
Tm = find(TE3 == max(TE3)) + (fidpts(3)+round((80/(1000/ecg.hz)))) - 1;

if length(Tm) > 1  
    Tm = Tm(1);
end

% T vector (eT1)
VTm = [S1(Tm) S2(Tm) S3(Tm)];

% Calculate the TCRT 
% Looks at angles between T wave (eT1) and points on the
% loop defined by S1, S2, and S3 (Sqrs) -- NOT the original QRS(X,Y,Z)
% Look at Sqrs values between timeRs and timeRe
for i = timeRs:timeRe
    v1 = VTm;
    v2 = Sqrs(i,:);

    tcrt(i-timeRs+1) = dot(v1,v2) / (norm(v1) * norm(v2));
end

 % tcrt = mean of these values
 tcrt = mean(tcrt);
 angle = acosd(tcrt);
 
if debug
    figure
    hold on

    scatter3(Sqrs(:,1), Sqrs(:,2), Sqrs(:,3),'filled','b')
    scatter3(St(:,1), St(:,2), St(:,3),'filled','r')

    line(Sqrs(:,1), Sqrs(:,2), Sqrs(:,3))
    line(St(:,1), St(:,2), St(:,3),'color','r')

    line([0 VTm(1)], [0 VTm(2)], [0 VTm(3)], 'linewidth',3)
    %line([0 V(1,2)], [0 V(2,2)], [0 V(3,2)], 'linewidth',2)
    %line([0 V(1,3)], [0 V(2,3)], [0 V(3,3)], 'linewidth',1)
    
    for i = timeRs:timeRe
    line([0 Sqrs(i,1)], [0 Sqrs(i,2)], [0 Sqrs(i,3)],'color','black','linewidth',0.5);
    end
    
    grid on
    daspect([1 1 1])
end