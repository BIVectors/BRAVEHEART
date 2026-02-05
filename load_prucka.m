%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_prucka.m -- Load Prucka (GE) recording system exported ECGs
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_prucka(filename)
% GE Prucka recording system export format - outputs in millivolts
% Searches for case insensitive lead names: leads MUST have names I, II,
% III, AVR, AVL, AVF, V1, V2, V3, V4, V5, V6, in any order and with any case.
% Data other than the 12 ECG leads can be included in the file. 

% If an .inf file with the same path/name is found it will pull data such
% as lead order and sampling rate from the .inf file.

% If an .inf file is not found, defaults to s977 Hz and lead order I, II,
% III, AVR, AVL, AVF, V1, V2, V3, V4, V5, V6

% Read the space delimited .txt file and store in a table
data_table = readtable(filename, 'Delimiter', ' ');

% Set up path/filename for .inf file if it exists
[path, name, ~] = fileparts(filename);
inf_ext = '.inf';
inf_filename = fullfile(path,[name inf_ext]);

% Initialize H structure for header data
H = struct;

% Look for .inf header file if it exists
if isfile(inf_filename)
    
    % Read .inf file
    fid = fopen(inf_filename, 'r');
    inf_file_text = fread(fid, '*char')';
    fclose(fid);

    % Split into lines
    lines = strsplit(inf_file_text, '\n');

    for i = 1:length(lines)
        L = lines{i};

        if contains(L, 'Points for Each Channel =')
            tmp = strsplit(L,'=');
            H.num_samples = str2double(tmp{2});
        end

        if contains(L, 'Number of Channel = ')
            tmp = strsplit(L,'=');
            H.num_channels = str2double(tmp{2});
        end
    
        if contains(L, 'Data Sampling Rate =')
            tmp = strsplit(L,'=');
            tmp = strrep(tmp{2}, 'points/second', '');  % Remove 'points/second'
            H.hz = str2double(tmp);
        end

        if contains(L, 'Units:')
            % Make sure units are in mV as should always be the case
            assert(strcmp(strtrim(L),'Units: mmHg for pressure and mV for all others'))
            H.units = 'mV';
        end
    end

    % Assert that the data_table dimensions are as expected from the header
    assert(height(data_table) == H.num_samples, 'Number of samples mismatch');
    assert(width(data_table) == H.num_channels, 'Number of channels mismatch');

    % Find the line where starts listing channel number and label
    header_idx = 0;
    for i = 1:length(lines)
        if contains(lines{i}, 'Channel Number') && contains(lines{i}, 'Channel Label')
            header_idx = i;
            break;
        end
    end
    
    % Parse channel labels after header_idx
    channel_labels = cell(1, H.num_channels);
    
    for i = 1:H.num_channels
        line = strtrim(lines{header_idx + i});
        
        % Remove leading digits and whitespace
        label = regexprep(line, '^\d+\s+', '');
        channel_labels{i} = strtrim(label);
    end

else
    % If no .inf file use these values and assume all 12 leads are present in this order 
    H.hz = 977;
    H.units = 'mV';
    channel_labels = [{'I'} {'II'} {'III'} {'aVR'} {'aVL'} {'aVF'} {'V1'} {'V2'} {'V3'} {'V4'} {'V5'} {'V6'}];

    % Now need to account for any additional labels that might be included
    % for other EGMs, as need same number of labels as columns in the table
    num_extra_labels = width(data_table) - length(channel_labels);

    % Add the extra labels    
    if num_extra_labels > 0
        newLabels = compose('Var%d', 1:num_extra_labels);
        channel_labels = [channel_labels newLabels];
    end

end

% Now use channel_labels as the headers for data_table
data_table.Properties.VariableNames = channel_labels;

% Pull the lead data out based on column header names
I =   getLeadDatafromTable(data_table,'I'); 
II =  getLeadDatafromTable(data_table,'II'); 
III = getLeadDatafromTable(data_table,'III'); 

avR = getLeadDatafromTable(data_table,'AVR'); 
avL = getLeadDatafromTable(data_table,'AVL'); 
avF = getLeadDatafromTable(data_table,'AVF'); 

V1 =  getLeadDatafromTable(data_table,'V1'); 
V2 =  getLeadDatafromTable(data_table,'V2'); 
V3 =  getLeadDatafromTable(data_table,'V3'); 
V4 =  getLeadDatafromTable(data_table,'V4'); 
V5 =  getLeadDatafromTable(data_table,'V5'); 
V6 =  getLeadDatafromTable(data_table,'V6'); 

% Sampling frequency
hz = H.hz;

% Check that are not mising any leads
if isempty(I) || isempty(II) || isempty(III) || ...
   isempty(avR) || isempty(avL) || isempty(avF) || ...
   isempty(V1) || isempty(V2) || isempty(V3) || ...
   isempty(V4) || isempty(V5) || isempty(V6) 

   error('Missing one or more leads from Prucka file');
end