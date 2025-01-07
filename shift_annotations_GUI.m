%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% shift_annotations_GUI.m -- Part of BRAVEHEART GUI - Shifts locations of annotations
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

function shift_annotations_GUI(pt, hObject, eventdata, handles)

set(handles.success_txt,'Visible','Off')

beats = handles.beats;
medianbeat = handles.medianbeat;
vcg = handles.vcg;
ecg = handles.ecg;
aps = pull_guiparams(hObject, eventdata, handles);

shift = str2num(get(handles.shift_box,'String'));

% If median shift box checked
if get(handles.shift_median_checkbox, 'Value')
    median_vcg = handles.median_vcg;
    beatsig_vcg = handles.beatsig_vcg;

    % Choose which point to shift (var 'pt')
    switch pt
        case 'Q'
            medianbeat = medianbeat.shift_q(shift); 
        case 'R'
            medianbeat = medianbeat.shift_r(shift);
        case 'S'
            medianbeat = medianbeat.shift_s(shift);
        case 'Tend'
            medianbeat = medianbeat.shift_tend(shift);
    end

    handles.medianbeat = medianbeat;  % update beats in handles
    guidata(hObject, handles);    


else   % Shifting individual beats

    switch pt
    case 'Q'
        beats = beats.shift_q(shift); 
    case 'R'
        beats = beats.shift_r(shift);
    case 'S'
        beats = beats.shift_s(shift);
    case 'Tend'
        beats = beats.shift_tend(shift);
    end

    handles.beats = beats;  % update beats in handles
    guidata(hObject, handles);

    % Finds outliers 
        beats = beats.find_outliers(vcg,aps);
        handles.beats = beats;
        guidata(hObject, handles);  % update handles
    
    % Finds PVCs
        beats = beats.find_pvcs(vcg,aps);
        handles.beats = beats;
    	guidata(hObject, handles);  % update handles

     
    % Mark outliers and PVCs in listbox and mark in rhythm leads    
        graph_outliers_pvcs(beats, vcg, aps, hObject,eventdata,handles)

end   