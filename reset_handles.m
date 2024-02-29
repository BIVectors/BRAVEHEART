%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% reset_handles.m -- Part of BRAVEHEART GUI
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

function reset_handles(hObject, eventdata, handles)
    
% Function does a deep clean for handles when reload/change ECGs to avoid anything being carried over
% Leaves the UI and some specific other elements alone (like NNet) and deletes any other values

% Get fieldnames from handles
fn = fieldnames(handles);

% Loop through all values
for i = 1:length(fn)

    % If not a part of the UI, file structure, or NNet, delete value
    if contains(class(handles.(fn{i})),'matlab') | ...
           strcmp(fn{i},'meanTrain') | strcmp(fn{i},'stdTrain') | ...
           strcmp(fn{i},'preset_names') | ...
           strcmp(fn{i},'preset_values') | ...
           strcmp(fn{i},'stdTrain') | ...
           strcmp(fn{i},'ecg_source_hash') | ...
           strcmp(class(handles.(fn{i})),'SeriesNetwork') | ...
           strcmp(class(handles.(fn{i})),'function_handle') | ...
           contains(fn{i},'filename') | contains(fn{i},'pathname') | contains(fn{i},'filename_short') | ... 
           contains(fn{i},'file_list') | contains(fn{i},'file_index')
    else
        % Remove the field from handles.
        handles = rmfield(handles,fn{i});
    end
    
end

guidata(hObject, handles);  % update handles