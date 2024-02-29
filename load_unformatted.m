%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_unformatted.m -- Load 'Unformatted' format ECGs
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

% Loads UNFORMATTED ECG Format Files

function [L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6, freq] =...
    load_unformatted(filename)

[fid,errmsg] = fopen(filename);
if fid == -1
    error('load_unformatted: Couldn''t open %s: %s', filename, errmsg);
end

% Unformated txt files
M = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f');
L1 = double(M{1})'; L2 = double(M{2})'; L3 = double(M{3})';
avR = double(M{4})'; avF = double(M{5})'; avL= double(M{6})'; 
V1 = double(M{7})'; V2 = double(M{8})'; V3 = double(M{9})'; 
V4 = double(M{10})'; V5 = double(M{11})'; V6 = double(M{12})';    
 
fclose(fid);

% Pull 1st number out of each lead as this is the frequency and assert all are the same
f = [L1(1) L2(1) L3(1) avR(1) avL(1) avF(1) V1(1) V2(1) V3(1) V4(1) V5(1) V6(1)];
if min(f) ~= max(f)
    error('load_unformatted: frequency error');
else
    freq = f(1);
end

% Take sample 2:end for each lead (cut out the frequency)
L1 = L1(2:end);
L2 = L2(2:end);
L3 = L3(2:end);

avR = avR(2:end);
avL = avL(2:end);
avF = avF(2:end);

V1 = V1(2:end);
V2 = V2(2:end);
V3 = V3(2:end);
V4 = V4(2:end);
V5 = V5(2:end);
V6 = V6(2:end);
        
end
