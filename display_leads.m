%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% display_leads.m -- Part of BRAVEHEART GUI
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

%%% Displays X, Y, Z, VM leads in GUI

function display_leads(X, Y, Z, VM, QRS, hObject, eventdata, handles)

% handles = guidata(hObject); %Load handles

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end


% clear axes
	clear_axes(hObject,eventdata,handles);

% Axes objects to pass in to make plotting much faster    
axX = handles.x_axis;
axY = handles.y_axis;
axZ = handles.z_axis;
axVM = handles.vm_axis;

% X
line(axX, [0 length(X)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axX,'on')
plot(axX, X,'color', colors.xyzecg)
ylim(axX, [min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))])
scatter(axX,QRS, X(QRS),'m','*')
hold(axX,'off')


% Y
line(axY, [0 length(Y)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axY, 'on')
plot(axY, Y,'color', colors.xyzecg)
ylim(axY, [min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))])
scatter(axY, QRS, Y(QRS),'m','*')
hold(axY, 'off')


% Z
line(axZ, [0 length(Z)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axZ, 'on')
plot(axZ, Z,'color', colors.xyzecg)
ylim(axZ, [min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))])
scatter(axZ, QRS, Z(QRS),'m','*')
hold(axZ, 'off')


% VM
line(axVM, [0 length(VM)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axVM, 'on')
plot(axVM, VM,'color', colors.vmecg)
ylim(axVM, [min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))])
scatter(axVM, QRS, VM(QRS),'m','*')
hold(axVM, 'off')
