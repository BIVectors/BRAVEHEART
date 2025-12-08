%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% lead_morph_uitable.m -- Generate table of LeadMorphology data
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

function [] = lead_morph_uitable(lead_morph, geh, filename)

% Adjust table figure size due to variations in display between MATLAB versions

currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

%Create figure and uitable
if currentVersion >= 2025
    fig = figure('Name', 'Lead Morphology Data Table', 'NumberTitle', 'off', 'Position', [100 100 1500 440]);
else
    fig = figure('Name', 'Lead Morphology Data Table', 'NumberTitle', 'off', 'Position', [100 100 1250 360]);
end

% Add the title text uicontrol
uicontrol(fig, 'Style', 'text', ...
            'String', strcat("Median Beat Morphology Data Table - ", filename(1:end-4)), ...
            'Units', 'normalized', ...
            'Position', [0.01 0.90 0.98 0.08], ... % Placed at the top
            'FontSize', 14, ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center');

% Define leads - note the lowercase 'av' for augmented leads
leads = {'L1', 'L2', 'L3', 'avR', 'avL', 'avF', 'V1', 'V2', 'V3', 'V4', 'V5', 'V6', 'X', 'Y', 'Z', 'VM'};

% Define parameter names (without lead prefix)
col_names = {'r_wave (mV)', 'r_wave_loc (ms)', 's_wave (mV)', 's_wave_loc (ms)', 'rs_wave (mV)', ...
               'rs_ratio', 'sr_ratio', 't_max (mV)', 't_max_loc (ms)', 'qrs_area (mV•ms)', ...
               't_area (mV•ms)', 'qrst_area (mV•ms)', 'jpt (mV)', 'jpt60 (mV)'};

params = {'r_wave', 'r_wave_loc', 's_wave', 's_wave_loc', 'rs_wave', ...
               'rs_ratio', 'sr_ratio', 't_max', 't_max_loc', 'qrs_area', ...
               't_area', 'qrst_area', 'jpt', 'jpt60'};

% Prepare column names
colNames = ['Lead', col_names];

% Initialize data cell array
data = cell(16, 15);  % 16 rows (16 leads), 15 columns (lead name + 14 params)

for i = 1:length(leads)
    lead = leads{i};
    data{i, 1} = lead;
    
    for j = 1:length(params)
        fieldName = [lead, '_', params{j}];
        
        % Try to access the property
        try
            data{i, j+1} = lead_morph.(fieldName);
        catch
            data{i, j+1} = NaN;
        end
    end
end

t = uitable(fig, 'Data', data, ...
                'ColumnName', colNames, ...
                'RowName', [], ...
                'ColumnEditable', false, ...
                'Units', 'normalized', ...
                'Position', [0.01 0.01 0.98 0.88]);

% Adjust decimals/formatting
% Time points need 1 decimal
cols_time = [3, 5, 10];
    
    for i = 1:size(data, 1)
        for col = cols_time
            if isnumeric(data{i, col}) && ~isnan(data{i, col})
                data{i, col} = sprintf('%.1f', data{i, col});
            end
        end
    end
    
% Most points get 3 decimals (microvolt level)
    for i = 1:size(data, 1)
        for col = 1:15
            if isnumeric(data{i, col}) && ~isnan(data{i, col})
                data{i, col} = sprintf('%.3f', data{i, col});
            end
        end
    end

% Missing data
for i = 1:size(data, 1)
    for col = 1:size(data, 2)
        if isnumeric(data{i, col}) && isnan(data{i, col})
            data{i, col} = 'N/A';
        end
    end
end    

t.ColumnWidth = 'auto';

% Add in data stored in GEH Class
data{13,11} = sprintf('%.3f',geh.XQ_area);
data{14,11} = sprintf('%.3f',geh.YQ_area);
data{15,11} = sprintf('%.3f',geh.ZQ_area);

data{13,12} = sprintf('%.3f',geh.XT_area);
data{14,12} = sprintf('%.3f',geh.YT_area);
data{15,12} = sprintf('%.3f',geh.ZT_area);

data{13,13} = sprintf('%.3f',geh.svg_x);
data{14,13} = sprintf('%.3f',geh.svg_y);
data{15,13} = sprintf('%.3f',geh.svg_z);

data{16,11} = sprintf('%.3f',geh.VMQ_area);
data{16,12} = sprintf('%.3f',geh.VMT_area);
data{16,13} = sprintf('%.3f',(geh.VMQ_area + geh.VMT_area));

% Update table data
t.Data = data;   