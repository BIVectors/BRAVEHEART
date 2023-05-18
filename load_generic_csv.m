%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_generic_csv.m -- Loads a .csv format ECGs with specified units/mv and frequency
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

% Loads .csv ECG Format Files which can have variable frequency or units per mV

function [L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6] =...
    load_generic_csv(filename, unitspermv)

M = readmatrix(filename);

M = M / unitspermv;     % Convert to mV

L1 = double(M(:,1)); 
L2 = double(M(:,2));
L3 = double(M(:,3));

avR = double(M(:,4));
avL = double(M(:,5));
avF = double(M(:,6));

V1 = double(M(:,7));
V2 = double(M(:,8));
V3 = double(M(:,9));
V4 = double(M(:,10));
V5 = double(M(:,11));
V6 = double(M(:,12));


end
