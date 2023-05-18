%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% remove_pvcs_GUI.m -- Part of BRAVEHEART GUI - Removes PVCs
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


function [removed] = remove_pvcs_GUI(hObject, eventdata, handles)

% Load signals/parameters
aps = pull_guiparams(hObject, eventdata, handles);
ecg = handles.ecg;
%baseline_shift_ecg = handles.baseline_shift_ecg;
vcg = handles.vcg;
beats = handles.beats;
QRS = beats.QRS;
removed = 0;


% Need to check if PVCs have already been detected so can add to the PVC
% list if run PVC removal more than once

if isfield(handles,'qrs_pvcs')
    existing_pvcs = handles.qrs_pvcs;        % Save indices of existing PVCs  
else
   existing_pvcs = [];
end


% PVC removal

% only do something if there are pvcs in the beats class

if ~isempty(beats.pvc) && sum(beats.pvc) > 0

delete_index  = find(beats.pvc == 1);
qrs_pvcs = QRS(delete_index);
qrs_pvcs = [qrs_pvcs; existing_pvcs];    % Add existing PVCs to old PVCs
handles.qrs_pvcs = qrs_pvcs;
beats = beats.delete(delete_index);  
handles.beats = beats;
guidata(hObject, handles);

if ~isempty(delete_index)

% Flag that clicked on PVC removal
handles.used_pvcremoval = 1;
guidata(hObject, handles);
    
set(handles.success_txt,'Visible','Off')
handles.active_beat_number = 1; % take care of issue when deleting PVCs and chosen beat in list box is > number of beats after PVC removed.
guidata(hObject, handles);

% save number of outliers removed
handles.num_pvcsrsemoved = length(delete_index);
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






end