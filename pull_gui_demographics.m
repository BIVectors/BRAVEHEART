%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% pull_gui_demographics.m -- Pulls demographic data from the GUI for normal ranges calcs
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

function [age, male, white, bmi] = pull_gui_demographics(hObject, eventdata, handles)

% Import age
age = str2num(get(handles.age_txt,'String'));

% Import sex
if get(handles.gender_dropdown, 'Value') == 2           % Male
    male = 1;
elseif get(handles.gender_dropdown, 'Value') == 1       % Female
    male = 0;
else                                                    % Missing or not M/F
    male = [];
end

% Import race
if get(handles.race_dropdown, 'Value') == 1
    white = 1;
elseif get(handles.race_dropdown, 'Value') == 2
    white = 0;
else
    white = [];
end

% Import BMI
bmi = str2num(get(handles.bmi_txt,'String'));
