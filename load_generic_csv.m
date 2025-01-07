%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_generic_csv.m -- Loads a .csv format ECGs with specified units/mv and frequency
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

% Loads .csv ECG Format Files which can have variable frequency or units per mV

function [L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6] =...
    load_generic_csv(filename, unitspermv, orientation, row_start, col_start, lead_order)

% Orientation sets if data is arranged in rows or columns

% Read starting at row/col specified to avoid issues with headers
M = readmatrix(filename,'range', [row_start,col_start]);

if strcmp(orientation,'cols')
    % do nothing
elseif strcmp(orientation,'rows')
    % Transpose
    M = M';
else
    error('generic CSV orientation is not set as rows or cols')
end

% Convert to mV
M = M / unitspermv;     

% Parse out lead order
lead_order = split(upper(lead_order));

% Could add some lead name verification here in the future...

L = struct();

% Pull lead data into structure so can deal with different lead order
for i = 1:length(lead_order)
    L.(lead_order{i}) = M(:,i);
end

L1 = L.I; 
L2 = L.II;
V1 = L.V1;
V2 = L.V2;
V3 = L.V3;
V4 = L.V4;
V5 = L.V5;
V6 = L.V6;
       
% Deal with possibility of only having 8 leads
if isfield(L,'III')
    L3 = L.III;
else
    L3 = -L1 + L2;
end

if isfield(L,'AVR')
    avR = L.AVR;
else
    avR = -0.5*L1 - 0.5*L2;
end

if isfield(L,'AVL')
    avL = L.AVL;
else
    avL = L1 - 0.5*L2;
end

if isfield(L,'AVF')
    avF = L.AVF;
else
    avF = L2 - 0.5*L1;
end


end     % End function
