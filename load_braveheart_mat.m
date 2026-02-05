%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_braveheart_mat.m -- Load ECG data from BRAVEHEART formatted .mat files
% Copyright 2016-2025 Hans F. Stabenau and Jonathan W. Waks
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_braveheart_mat(filename)

E = load(filename);

hz = E.data.ecg_raw.hz;

I = E.data.ecg_raw.I;
II = E.data.ecg_raw.II;
III = E.data.ecg_raw.III;

avR = E.data.ecg_raw.avR;
avL = E.data.ecg_raw.avL;
avF = E.data.ecg_raw.avF;

V1 = E.data.ecg_raw.V1;
V2 = E.data.ecg_raw.V2;
V3 = E.data.ecg_raw.V3;
V4 = E.data.ecg_raw.V4;
V5 = E.data.ecg_raw.V5;
V6 = E.data.ecg_raw.V6;
