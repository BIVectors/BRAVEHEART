%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_labsystempro.m -- Load LABSYSTEM Pro (Boston Scientific, previously Bard) recording system exported ECGs
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_labsystempro(filename)
% LABSYSTEM Pro recording system (Boston Scientific, formerly Bard) export format - outputs in millivolts
% Searches for case insensitive lead names: leads MUST have names I, II,
% III, AVR, AVL, AVF, V1, V2, V3, V4, V5, V6, in any order and with any case.
% Data other than the 12 ECG leads can be included in the file
% Signal data is in ADC units

% Read entire file
fid = fopen(filename, 'r');
file_text = fread(fid, '*char')';
fclose(fid);

% Split into lines
lines = strsplit(file_text, '\n');

% Line number initialization
header_line = 0;
data_line = 0;

% Find where the header and data start/end
for i = 1:length(lines)
    if strcmp(strtrim(lines{i}),'[Header]')
        header_line = i;   % Should be 1
    end
        
    if strcmp(strtrim(lines{i}),'[Data]')
        data_line = i;
        break;
    end
end

% Extract data/signal
data_table = readtable(filename, 'Delimiter', ',', 'NumHeaderLines', data_line);

% Initialize header structure H
H = struct;

% Extract header information
header = lines(header_line+1:data_line-1);

for i = 1:length(header)
    line = header{i};

    if contains(line, 'Channels exported:')
        tmp = strsplit(line,':');
        H.num_channels = str2double(tmp{2});
    end

    if contains(line, 'Samples per channel:')
        tmp = strsplit(line,':');
        H.num_samples = str2double(tmp{2});
    end

    if contains(line, 'Sample Rate:')
        tmp = strsplit(line,':');
        tmp = strrep(tmp{2}, 'Hz', '');  % Remove 'Hz'
        H.hz = str2double(tmp);
    end

end

% Now work on extracting channel names/labels
current_channel = 0;
channel_labels = {};  % Cell array to store labels in order

% Initialize range which is needed to convert ADC to mV
range = [];

for i = 1:length(header)
    line = header{i};
    
    % Find the channel number
    if contains(line, 'Channel #:')
        tmp = strsplit(line, ':');
        current_channel = str2double(tmp{2});
        
        % Need to make sure that the next line is the label
        assert(contains(header{i+1},'Label:'));
        tmp = strsplit(header{i+1}, ':');
        label = strtrim(tmp{2});

        % store the label
        channel_labels{current_channel} = label;  % Store at correct index    
    end

    if contains(line, 'Range:')
        tmp = strsplit(line,':');
        tmp = strrep(tmp{2}, 'mv', '');  % Remove 'mv' 
        range = [range str2double(tmp)];
    end
end

% Now calculate the ADC to mV conversion scale which is 
% mV =  (ADC_Value / 32768) × range 
% Note 32768 = 2^15 (16 bit)
scales = range/32768;

% Convert data_table ADC units to mV using each signals scale
data_table_mV = data_table{:,:} .* scales;
data_table_mV = array2table(data_table_mV, 'VariableNames', data_table.Properties.VariableNames);

% Now use channel_labels as the headers for data_table
data_table.Properties.VariableNames = channel_labels;
data_table_mV.Properties.VariableNames = channel_labels;

% Assert that the data_table dimensions are as expected from the header
assert(height(data_table) == H.num_samples, 'Number of samples mismatch');
assert(width(data_table) == H.num_channels, 'Number of channels mismatch');

% Pull the lead data out based on column header names
I =   getLeadDatafromTable(data_table_mV,'I'); 
II =  getLeadDatafromTable(data_table_mV,'II'); 
III = getLeadDatafromTable(data_table_mV,'III'); 

avR = getLeadDatafromTable(data_table_mV,'AVR'); 
avL = getLeadDatafromTable(data_table_mV,'AVL'); 
avF = getLeadDatafromTable(data_table_mV,'AVF'); 

V1 =  getLeadDatafromTable(data_table_mV,'V1'); 
V2 =  getLeadDatafromTable(data_table_mV,'V2'); 
V3 =  getLeadDatafromTable(data_table_mV,'V3'); 
V4 =  getLeadDatafromTable(data_table_mV,'V4'); 
V5 =  getLeadDatafromTable(data_table_mV,'V5'); 
V6 =  getLeadDatafromTable(data_table_mV,'V6'); 

% Sampling frequency
hz = H.hz;


% Now deal with possibly missing limb leads - reconstruct the missing limb leads
if isempty(I) || isempty(II) || isempty(III) || ...
   isempty(avR) || isempty(avL) || isempty(avF)

   [I, II, III, avR, avL, avF] = reconstruct_limb_leads(I, II, III, avR, avL, avF);

end

% Check that are not missing any precordial leads
if isempty(V1) || isempty(V2) || isempty(V3) || ...
   isempty(V4) || isempty(V5) || isempty(V6) 

   error('Missing one or more leads from Labsystem Pro file');
end