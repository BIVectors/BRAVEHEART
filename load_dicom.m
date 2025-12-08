%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_dicom.m -- Load DICOM ECG Format (requires image processing toolbox)
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = ...
    load_dicom(filename)

% Load DICOM file
D = dicominfo(filename);

% Check that is a DICOM with ECG waveforms and not an image DICOM or some other DICOM format
validECGClasses = {
'1.2.840.10008.5.1.4.1.1.9.1.1',  % 12-Lead ECG Waveform Storage
'1.2.840.10008.5.1.4.1.1.9.1.2',  % General ECG Waveform Storage
'1.2.840.10008.5.1.4.1.1.9.1.3'   % Ambulatory ECG Waveform Storage
};

% Check if it's a valid ECG waveform class
    if ~any(strcmp(D.SOPClassUID, validECGClasses))
        error('load_dicom:InvalidSOPClass', ...
              ['load_dicom: Unsupported SOP Class UID: %s\n' ...
               'This does not appear to be an ECG Waveform Storage format DICOM file.'], ...
              D.SOPClassUID);
    end

% Pull out waveform part of DICOM and the field names in that part of DICOM
ws_fn = fieldnames(D.WaveformSequence);

% Check if there is more than 1 'Item' if there are rhythm strips and medians
% Format requires that there are between 1 and 4 'Items'
% see https://www.dicomstandard.org/News-dir/ftsup/docs/sups/sup30.pdf
len_ws_fn = length(ws_fn);
itemN = 0;

% Only take the RHYTHM data, although could modify to get other types of waveforms if needed
for i = 1:len_ws_fn

    if strcmp(string(D.WaveformSequence.(ws_fn{i}).MultiplexGroupLabel),"RHYTHM")
        itemN = i;
        break;
    end
end

% Check that found a RHYTHM waveform
if itemN == 0
    error('load_dicom.m: Did not find a RHYTHM WaveformSequence')
end

% Choose the RHYTHM Waveforms
ws = D.WaveformSequence.(ws_fn{itemN});
waveform = ws.WaveformData;

% Sample frequency
hz = ws.SamplingFrequency;
num_leads = double(ws.NumberOfWaveformChannels);
num_samples = double(ws.NumberOfWaveformSamples);

% Details on each of the 12 leads
ch_def = ws.ChannelDefinitionSequence;
ch_def_fn = fieldnames(ch_def);

sensitivity = zeros(1,num_leads);   % MICROVOLTS (convert to millivolts later)
baseline = zeros(1,num_leads);
correction = zeros(1,num_leads);
lead_str = strings(1,num_leads);
unit_str = strings(1,num_leads);
unitspermv = zeros(1,num_leads);

% obtain data on each lead
for i = 1:num_leads
    sensitivity(i) = ch_def.(ch_def_fn{i}).ChannelSensitivity;
    baseline(i) = ch_def.(ch_def_fn{i}).ChannelBaseline;
    correction(i) = ch_def.(ch_def_fn{i}).ChannelSensitivityCorrectionFactor;
    lead_str(i) = ch_def.(ch_def_fn{i}).ChannelSourceSequence.Item_1.CodeMeaning;
    unit_str(i) = ch_def.(ch_def_fn{i}).ChannelSensitivityUnitsSequence.Item_1.CodeValue;

end

% Pull out units needed to convert to mV at end
for i = 1:num_leads
switch unit_str(i)
    case "uV"
        unitspermv(i) = 1000;
    case "mV"
        unitspermv(i) = 1;
    otherwise
        error('load_dicom.m: Did not find signal units')
end
end

% Convert into int16 based on whatever encoding DICOM using
% Get encoding
E = string(class(ws.WaveformData));

if strcmp(E, 'uint16')
    % Convert uint16 to int16
    fullsignal = double(typecast(uint16(waveform), 'int16'));
elseif strcmp(E, 'uint8')
    % Convert uint8 to int16
    fullsignal = double(typecast(uint8(waveform), 'int16'));
elseif strcmp(E, 'int16')
    fullsignal = double(waveform);
else
    error('Check WaveformSequence.Item_N.WaveformData encoding - may need to add current encoding to load_dicom.m')
end

% get each lead out of the signal waveform
L = zeros(num_leads, num_samples);
L = reshape(fullsignal,num_leads,[]);

% L is now the raw waveform data in ADC units

% Calculate the scaling factor to get ADC units into mV
% Note that in most cases ADC units are microvolts
scaling_factor = (sensitivity./correction) ./ unitspermv;

% To get data in mV substract the baseline and then multiply by scaling factor.
L_mv = (L - baseline') .* scaling_factor'; 

% Signal is now in MILLIVOLTS

for s = 1:num_leads
    % Read lead_str to determine which lead it is
    % Now will not break if the lead labels are not exactly "Lead x"
    % But to avoid missing lead II and III had to change order of cases
    switch true
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])iii([^A-Za-z0-9]|$)', 'match'))
              III = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])ii([^A-Za-z0-9]|$)', 'match'))
              II = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])i([^A-Za-z0-9]|$)', 'match'))
              I = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])aVR([^A-Za-z0-9]|$)', 'match'))
              avR = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])aVL([^A-Za-z0-9]|$)', 'match'))
              avL = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])aVF([^A-Za-z0-9]|$)', 'match'))
              avF = L_mv(s,:);

        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])V1([^A-Za-z0-9]|$)', 'match'))
              V1 = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])V2([^A-Za-z0-9]|$)', 'match'))
              V2 = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])V3([^A-Za-z0-9]|$)', 'match'))
              V3 = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])V4([^A-Za-z0-9]|$)', 'match'))
              V4 = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])V5([^A-Za-z0-9]|$)', 'match'))
              V5 = L_mv(s,:);
        case ~isempty(regexpi(char(lead_str(s)), '(^|[^A-Za-z0-9])V6([^A-Za-z0-9]|$)', 'match'))
              V6 = L_mv(s,:);
    end
end