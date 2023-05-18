%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% svd_8lead.m -- SVD of 8 leads of an ECG
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


function [s1, s2, s3, E3, timeRs, timeRe] = svd_8lead(ecg, cutpt, fidpts, debug)

X = [ecg.I ecg.II ecg.V1 ecg.V2 ecg.V3 ecg.V4 ecg.V5 ecg.V6];

% DONT Subtract out the centroid to avoid offsets since already zerod data

% SVD - V is the new orthonormal basis
[~,~,V]=svd(X);
s=svd(X);

% Quick check singular values are ordered correctly
assert(s(1) == max(s))
assert(s(8) == min(s))

% Project the data into the new basis
newX = X*V;

% Take first 3 decompositions
s1 = newX(:,1);
s2 = newX(:,2);
s3 = newX(:,3);

% Energy signal is the "Vector Magnitude" in this new coordinate system
E3 = sqrt(s1.^2 + s2.^2 + s3.^2);

% Find max around R peak utilizing fidpts from median beat as guide
Emax = max(E3(fidpts(1):fidpts(3)));
Emax_loc = find(E3 == Emax);

% Find the ends of the peak at cutpt% of E3 max value
[~, ~, ~, timeRs, timeRe] = tcrt_width_est(E3, Emax_loc, fidpts, cutpt, 0);

% Debug figure
if debug
    figure
    hold on
    %plot(s1);
    %plot(s2);
    %plot(s3);
    plot(E3);
    scatter(Emax_loc,E3(Emax_loc))
    scatter(timeRs, E3(timeRs))
    scatter(timeRe, E3(timeRe))
    scatter(fidpts(1), E3(fidpts(1)))
    scatter(fidpts(3), E3(fidpts(3)))
    scatter(fidpts(4), E3(fidpts(4)))
    line([0 length(E3)],[cutpt*Emax cutpt*Emax],'color','r')
end