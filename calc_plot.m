%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% calc_plot.m -- Part of BRAVEHEART GUI
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

function calc_plot(vcg, beats, aps, hObject, eventdata, handles)
  
% Add beats to listbox in GUI
    set(handles.activebeats_list,'String',[]);
    listbox_beats = beats_to_listbox(beats.Q, beats.QRS, beats.S, beats.Tend);
    set(handles.activebeats_list,'String',listbox_beats);
    
% Add number of beats to the best listbox header
    set(handles.uipanel9,'Title',strcat('Annotated Beats (',num2str(length(beats.Q)),')'))

% Show the fiducial points (Qon, Qoff, Toff) on the X, Y, Z, VM full leads 
    show_fiducialpts_gui(vcg, beats, hObject,eventdata,handles);
      
% Display median beats/individual beats aligned in GUI
    display_medianbeats(handles.median_vcg, handles.beatsig_vcg, handles.medianbeat, handles.medianbeat.T, hObject, eventdata, handles);
    
% Update GUI values with geh, lead_morphology, beat stats, and basic intervals
    update_gui_values(handles.geh, handles.beat_stats, hObject, eventdata, handles);
    
% Mark outliers and PVCs in listbox and mark in rhythm leads    
    graph_outliers_pvcs(beats, vcg, aps, hObject,eventdata,handles);
    
% Plot VCG
    plot_vcg_gui(handles.geh, handles.median_vcg, handles.medianbeat, handles.aps, hObject, eventdata, handles);
    
% Update GUI quality items
    update_gui_quality(handles.quality, aps, hObject, eventdata, handles);
     
end