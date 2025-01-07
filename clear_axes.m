%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% clear_axes.m -- Part of BRAVEHEART GUI
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


function [] = clear_axes(hObject, eventdata, handles)

handles = guidata(hObject);

% clear all axes
    cla(handles.x_axis)
    cla(handles.y_axis)
    cla(handles.z_axis)
    cla(handles.vcg_axis)
    cla(handles.vm_axis)
    cla(handles.VMmedianbeat_axis)
    cla(handles.Xmedianbeat_axis)
    cla(handles.Ymedianbeat_axis)
    cla(handles.Zmedianbeat_axis)
    cla(handles.face_axis)
    cla(handles.selectedbeat_axis)
    cla(handles.vcg_morph_axis)
    cla(handles.speed_axis)
    cla(handles.speed_axis,'reset')