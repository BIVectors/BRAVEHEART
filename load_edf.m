%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_edf.m -- Load European Data Format (EDF) format ECGs
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_edf(filename)

data = edfread(filename);
info = edfinfo(filename);

labels = lower(info.SignalLabels);
%labels_old = labels;

true_labels = {'iii', 'ii', 'i', 'avr', 'avl', 'avf', 'v1', 'v2', 'v3', 'v4', 'v5', 'v6'};

% Need to clean up some variations in ECG lead labeling
% Some ECGs just use the lead names, but other ECGs have more descriptive
% labels that mess up using structures to parse the data

% Check if labels are more than 3 characters (so not just lead names)
for i = 1:length(labels)
    if length(labels{i}) > 3
        for j = 1:length(true_labels)
             if ~isempty(strfind(string(labels{i}),true_labels{j}))
                labels{i} = true_labels{j};
                break;
             end
        end

    end

end


num_leads = info.NumSignals;

gain_str = [];

if num_leads < 8
    error("Not Enough Leads in the .edf file")
end

num_segs = info.NumDataRecords;
seg_time = milliseconds(info.DataRecordDuration);

hz = info.NumSamples/seconds(info.DataRecordDuration);

% Make sure frequencies of all leads are the same
assert(length(unique(hz)) == 1,"All leads do not have the same sampling frequency")

hz = hz(1);

for j = 1:num_leads
    L.(labels{j})= [];
    gain_str = [gain_str info.PhysicalDimensions(j)];
    for i = 1:num_segs
        L.(labels{j}) = [L.(labels{j}) data.(j){i}'];        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deal with Physionet .EDF exports that have extra missing data appended on
% to the end of the signal.  This data is usually the value in
% info.PhysicalMin for each lead, but it can also be some fraction of
% info.DigitalMin, so to be robust for different databases need to just
% look at the final sample value and use that.  The artifact is a single
% value, so regardless of what the value is can look for long flat segments

% Look at the last value in each lead
% We only have to do this for any one lead, because if the artifact is in 1 
% lead it has to be in the other leads too to keep them the same length

Eind = zeros(1,num_leads);

for j = 1:num_leads
    
    flag = 0;

    % Get end value
    E = L.(labels{j})(end);
    Eind(j) = length(L.(labels{j}));

    % Scan backwards until this end value is not the value of the last 
    % sample of the signal
    for i = 1:length(L.(labels{j}))-1
       
        if flag == 1
            break;
        end

        if L.(labels{j})(end-i) == E
            % Do nothing and just cycle through to next sample
        else
            % Make note of the last sample with the end value and break out
            % of the loop
            Eind(j) = Eind(j) - i + 1;
            flag = 1;
        end

    end

end

% There is a possibility that the end of a single lead could be artifact
% because it fell off at the very end, but all other leads are artifact
% free.  For now, for simplicity, will remove the ending segment of ALL
% leads if >= 1 has a constant artifact longer than set value  BUT shorter 
% than the duration of 1 DataRecordDuration

% Since checked on all leads, choose the minimum value just in case
Eind = min(Eind);

% Trim if needed (>= 50 ms) and <= DataRecordDuration
artifact_length = length(L.(labels{j})) - Eind;
limit_in_ms = 50;

if artifact_length * 1000 / hz >= limit_in_ms  && artifact_length * 1000 / hz <= seg_time
    for j = 1:num_leads
        L.(labels{j})(end-artifact_length:end) = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deal with units
assert(numel(unique(gain_str)) == 1)        % Assert only 1 unit for all leads

switch char(gain_str(1))
    case 'mV'
        gain = 1;
    case 'uV'
        gain = 1/1000;
    otherwise
        error('Unknown units for .edf ECG')
end


I = L.i * gain;
II = L.ii * gain;
V1 = L.v1 * gain;
V2 = L.v2 * gain;
V3 = L.v3 * gain;
V4 = L.v4 * gain;
V5 = L.v5 * gain;
V6 = L.v6 * gain;


if isfield(L,'iii')
    III = L.iii * gain;
else
    III = -I + II;
end

if isfield(L,'avr')
    avR = L.avr * gain;
else
    avR = -0.5*I - 0.5*II;
end

if isfield(L,'avf')
    avF = L.avf * gain;
else
    avF = II - 0.5*I;
end

if isfield(L,'avl')
    avL = L.avl * gain;
else
    avL = I - 0.5*II;
end
