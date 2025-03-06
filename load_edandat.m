 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_edandat.m -- Loads .dat ECG files from Edan SE 601C ECG machines
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

function [hz, I, II, III, AVR, AVF, AVL, V1, V2, V3, V4, V5, V6] = load_edandat(filename)

% Set sampling freq and units per mV for Edan SE 601C
% Freq = 1000 hz
% 2.52 microvolt per LSB
hz = 1000;
unitspermv = 397;

% clear
% File path
%file = "H:\20240311-100241-0088.dat";  % Replace with your binary file path

% Load file and read header ingormation as int16 with an offset of 1
fileID = fopen(filename, 'rb');
fseek(fileID, 1, 'bof');
data = fread(fileID, Inf, '*int16');

% Emperically determined cutpoints for 1000 Hz signal with 8 leads of data
% and then medians
cuts = [1016 11016 21016 31016 41016 51016 61016 71016 81016];
lead_names = [{'L1'} {'L2'} {'V1'} {'V2'} {'V3'} {'V4'} {'V5'} {'V6'}];

% Debug
% figure
% plot(data)
% hold
% scatter(cuts, data(cuts))

% Cut out each lead and convert from int16 to double
for i = 1:length(cuts)-1
    lead.(lead_names{i}) = double(data(cuts(i):cuts(i+1)-1));
end

% Create indvidial lead variables
I = lead.L1 / unitspermv;
II = lead.L2 / unitspermv;

V1 = lead.V1 / unitspermv;
V2 = lead.V2 / unitspermv;
V3 = lead.V3 / unitspermv;
V4 = lead.V4 / unitspermv;
V5 = lead.V5 / unitspermv;
V6 = lead.V6 / unitspermv;

% These leads already had correct units per mv
III = -I + II;
AVF = II - 0.5*I;
AVR = -0.5*I - 0.5*II;
AVL = I - 0.5*II;
