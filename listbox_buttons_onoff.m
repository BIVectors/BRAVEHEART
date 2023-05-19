%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% listbox_buttons_onoff.m -- Part of BRAVEHEART GUI
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


function listbox_buttons_onoff(onoff, hObject, eventdata, handles)

set(handles.update_selectbeat_button, 'Enable', onoff);
set(handles.qon_minus_button, 'Enable', onoff);
set(handles.qon_plus_button, 'Enable', onoff);
set(handles.rpeak_minus_button, 'Enable', onoff);
set(handles.rpeak_plus_button, 'Enable', onoff);
set(handles.qoff_minus_button, 'Enable', onoff);
set(handles.qoff_plus_button, 'Enable', onoff);
set(handles.toff_minus_button, 'Enable', onoff);
set(handles.toff_plus_button, 'Enable', onoff);

set(handles.remove_selectbeat_button, 'Enable', onoff);
