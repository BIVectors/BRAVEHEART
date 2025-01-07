%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% remove_outliers_GUI.m -- Part of BRAVEHEART GUI - Removes outliers
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

function [removed] = remove_outliers_GUI(hObject, eventdata, handles)

% Load signals/parameters
aps = pull_guiparams(hObject, eventdata, handles);
ecg = handles.ecg;
%baseline_shift_ecg = handles.baseline_shift_ecg;
vcg = handles.vcg;
beats = handles.beats;
QRS = beats.QRS;
removed = 0;


% Need to check if outliers have already been detected so can add to the
% outlier list if run outlier removal more than once

if isfield(handles,'qrs_outliers')
    existing_outliers = handles.qrs_outliers;        % Save indices of existing PVCs  
else
   existing_outliers = [];
end


% Outlier removal

% only do something if there are outliers in the beats class

if ~isempty(beats.outlier) && sum(beats.outlier) > 0

% if isempty(beats.outlier)
%     beats = beats.find_outliers(vcg);    
% end

delete_index  = find(beats.outlier == 1);
qrs_outliers = QRS(delete_index);
qrs_outliers = [qrs_outliers ; existing_outliers];    % Add existing outliers to old outliers
handles.qrs_outliers = qrs_outliers;
beats = beats.delete(delete_index,"outlier");  
handles.beats = beats;
guidata(hObject, handles);

if ~isempty(delete_index)

% Flag that clicked on outlier removal
handles.used_outlieremoval = 1;
guidata(hObject, handles);
    
set(handles.success_txt,'Visible','Off')
handles.active_beat_number = 1; % take care of issue when deleting PVCs and chosen beat in list box is > number of beats after PVC removed.
guidata(hObject, handles);

% save number of outliers removed
handles.num_outliersemoved = length(delete_index);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Finds outliers 
    beats = beats.find_outliers(vcg,aps);
    handles.beats = beats;
    guidata(hObject, handles);  % update handles
    
% Finds PVCs
    beats = beats.find_pvcs(vcg,aps);
    handles.beats = beats;
    guidata(hObject, handles);  % update handles
    

% flag to know if anything happened
removed = 1;
    
  
end   % end isempty block
end  