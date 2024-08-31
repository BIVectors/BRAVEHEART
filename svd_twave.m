%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% svd_twave.m -- Calculates TMD and TWR
% Copyright 2016-2024 Hans F. Stabenau and Jonathan W. Waks
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

function [TMD, TWR_abs, TWR_rel] = svd_twave(ecg, fidpts)

% Cut out T wave
X = [ecg.I(fidpts(3):fidpts(4)) ecg.II(fidpts(3):fidpts(4)) ...
    ecg.V1(fidpts(3):fidpts(4)) ecg.V2(fidpts(3):fidpts(4)) ...
    ecg.V3(fidpts(3):fidpts(4)) ecg.V4(fidpts(3):fidpts(4)) ...
    ecg.V5(fidpts(3):fidpts(4)) ecg.V6(fidpts(3):fidpts(4))]';

% DONT Subtract out the centroid to avoid offsets since already zerod data

% SVD - Only care about left singular vectors U and singular values, but
% easier to extract singular values using second line of code than to get
% the entire matrix S with all the zeros etc.
[U,~,~]=svd(X);
s=svd(X);


%%% TMD

% See Concept of T-Wave Morphology Dispersion
% https://ieeexplore.ieee.org/document/825905

% Take first 2 singular vectors
Ut = U(:,[1 2]);

% Make 2x2 matrix of singular values on diagonals
S = [s(1) 0 ; 0 s(2)];

% Create W
W = (Ut * S)';

% Drop V1 (3rd col of W)
W(:,3) = [];

% Calculate angles between pairs of columns of W

% Preallocate A to store permutations of angles.  Since have 7 leads after
% excluding V1 it will be 7x7
A = zeros(7,7);

% Calculate angle permutations (set z = 0 to use cross function)
for i = 1:7
    for j = 1:7
        wi = [W(:,i) ; 0];
        wj = [W(:,j) ; 0];
        A(i,j) = atan2d(norm(cross(wi,wj)),dot(wi,wj));
    end
end

% Want to exclude if i = j
% Take values above diagnoal; there are 21 values
A2 = triu(A,1);

% Average the 21 values in A2 to get TMD
TMD = sum(A2,"all")/21;


%%% TWR

% See Analysis of T wave morphology parameters with signal averaging during 
% ischemia induced by percutaneous transluminal coronary angioplasty
% https://ieeexplore.ieee.org/document/5445289
%
% See Role of Dipolar and Nondipolar Components of the T Wave in Determining 
% the T Wave Residuum in an Isolated Rabbit Heart Model
% https://onlinelibrary.wiley.com/doi/10.1046/j.1540-8167.2004.03466.x
%
% TWR is sum of 4th through 8th eigenvalues 
% (although some other reports say that they use the squares of the eigenvalues?)
% The singular values are the sqrts of the eigenvalues
% Therefore the eigenvalues are the singular values squared
%
% The sum of the 4th to 8th eigenvalues expressed in mV2 defines the 
% TWR and quantifies the nondipolar components of the T wave.

% Generate eigenvalues as 'eigmat' by squaring singular values
eigmat = s.^2;

% TWR is sum of 4th through nth (8th in this case) eigenalues
TWR_abs = sum(eigmat(4:8));

% Relative TWR is the percentage of the whole
TWR_rel = 100 * TWR_abs / sum(eigmat);
