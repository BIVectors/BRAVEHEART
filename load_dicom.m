%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_dicom.m -- Load DICOM ECG Format (requires image processing toolbox)
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = ...
    load_dicom(filename)

% Load DICOM file
D = dicominfo(filename);

% Pull out waveform part of DICOM and the field names in that part of DICOM
ws_fn = fieldnames(D.WaveformSequence);
ws = D.WaveformSequence.(ws_fn{1});
waveform = ws.WaveformData;

% Sample frequency
hz = ws.SamplingFrequency;
num_leads = int32(ws.NumberOfWaveformChannels);
num_samples = int32(ws.NumberOfWaveformSamples);

% Details on each of the 12 leads
ch_def = ws.ChannelDefinitionSequence;
ch_def_fn = fieldnames(ch_def);

mcv_perunit = zeros(1,num_leads);   % MICROVOLTS (convert to millivolts later)
baseline = zeros(1,num_leads);
correction = zeros(1,num_leads);

% obtain data on each lead
for i = 1:num_leads
    mcv_perunit(i) = ch_def.(ch_def_fn{i}).ChannelSensitivity;
    baseline(i) = ch_def.(ch_def_fn{i}).ChannelBaseline;
    correction(i) = ch_def.(ch_def_fn{i}).ChannelSensitivityCorrectionFactor;
    lead_str{i} = ch_def.(ch_def_fn{i}).ChannelSourceSequence.Item_1.CodeMeaning;
end

% Convert uint16 to int16
fullsignal = double(typecast(uint16(waveform), 'int16'));

% get each lead out of the singla waveform
L = zeros(num_leads, num_samples);

for s = 1:num_leads
    for i = 1:num_samples  
        L(s,i) = (((fullsignal(s + (12*(i-1)))) + baseline(s)) * (mcv_perunit(s)/1000 * correction(s))); 
    end
end

% Signal is now in MILLIVOLTS

% Parse out each lead
I = L(1,:);
II = L(2,:);
III = L(3,:);
avR = L(4,:);
avL = L(5,:);
avF = L(6,:);

V1 = L(7,:);
V2 = L(8,:);
V3 = L(9,:);
V4 = L(10,:);
V5 = L(11,:);
V6 = L(12,:);

