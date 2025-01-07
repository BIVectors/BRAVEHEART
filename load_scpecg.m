%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_scpecg.m -- Load SCP-ECG Format (Utilizes code from the BioSig Project [see below])
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_scpecg(filename)

% Note that loading SCP-ECG files tend to be slower than other formats due
% to the significant processing that is required to read and parse the data.

% This function utilizes the following files from The BioSig Project v3.8.4
% https://biosig.sourceforge.net -- Under GNU GPL License v3
%   sopen.m
%   scpopen.m
%   leadidcodexyz.m
%   getfiletype.m
%   physicalunits.m
%   biosig_str2double.m
%   elecpos.txt -> as elecpos.m
%   leadidtable_scpecg.txt -> as leadidtable_scpecg.m

% Use BioSig to load and parse the SCP file
HDR = sopen(filename);

% Frequency
hz = round(HDR.SampleRate);     % Saw some sample files with non-integer frequency

% Lead labels
labels = upper(HDR.Label);

% Make sure has enough leads to make a 12-lead ECG
if length(labels) < 8
    error('Does not seem to be a 12-lead ECG')
end

% Lead units
units = HDR.PhysDim;

% Make sure all units are the same - format does not allow this to vary
assert(length(unique(units))==1);

% For now only works for mV units.  Need to see more files to determine
% what else need to account for in future
assert(strcmp(units{1},'mV'))

% Scaling of signal to convert from units to mV
scaling = unique(max(full(HDR.Calib)));

% Make sure that all scaling is the same - format does not allow this to vary
assert(length(unique(max(full(HDR.Calib))))==1);

% Multiply raw data (units) * scaling to get data in unit specified by 'units'
leads = HDR.data.*scaling;


% some .scp files can have NaN for some samples at the end, which causes problems with all the
% subsequent calculations, so need to truncate at the earliest occurance of NaN so all leads 
% are same length
nanloc = zeros(1,length(labels));
for i = 1:length(labels)
    idx = find(isnan(leads(:,i))==1);
    if ~isempty(idx)
        nanloc(i) = idx(1);
    else
        nanloc(i) = 0;
    end
end

zeroloc = find(nanloc == 0);
nanloc(zeroloc) = [];
if ~isempty(nanloc)
    firstnan = min(nanloc);
else
    firstnan = [];
end


% Segment each lead out
for i = 1:length(labels)
    L.(labels{i}) = leads(:,i);

    % Cut each lead to same legnth if NaNs are present at end
    if ~isempty(firstnan)
        L.(labels{i}) =  L.(labels{i})(1:firstnan-1);
    end
end

I = L.I;
II = L.II;
V1 = L.V1;
V2 = L.V2;
V3 = L.V3;
V4 = L.V4;
V5 = L.V5;
V6 = L.V6;


% Deal with if need to calculate non-independent leads
if isfield(L,'III')
    III = L.III;
else
    III = -I + II;
end

if isfield(L,'AVR')
    avR = L.AVR;
else
    avR = -0.5*I - 0.5*II;
end

if isfield(L,'AVF')
    avF = L.AVF;
else
    avF = II - 0.5*I;
end

if isfield(L,'AVL')
    avL = L.AVL;
else
    avL = I - 0.5*II;
end

