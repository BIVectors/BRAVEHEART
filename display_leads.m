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

% clear axes
	clear_axes(hObject,eventdata,handles);

% Loads ECG leads from handles
%     X = handles.vcg.X;
%     Y = handles.vcg.Y;
%     Z = handles.vcg.Z;
%     VM = handles.vcg.VM;
%     QRS = handles.beats.QRS;

% X
axes(handles.x_axis);
line([0 length(X)],[0 0], 'color', 'k','linewidth',0.5)
hold on
plot(X,'color', '[0 0.4470 0.7410]')
ylim([min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))])

for i = 1:length(QRS)
    scatter(QRS(i), X(QRS(i)),'m','*')
end

hold off


% Y
axes(handles.y_axis);
line([0 length(Y)],[0 0], 'color', 'k','linewidth',0.5)
hold on
plot(Y,'color', '[0 0.4470 0.7410]')
ylim([min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))])

for i = 1:length(QRS)
    scatter(QRS(i), Y(QRS(i)),'m','*')
end

hold off


% Z
axes(handles.z_axis);
line([0 length(Z)],[0 0], 'color', 'k','linewidth',0.5)
hold on
plot(Z,'color', '[0 0.4470 0.7410]')
ylim([min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))])

for i = 1:length(QRS)
    scatter(QRS(i), Z(QRS(i)),'m','*')
end

hold off


% VM
axes(handles.vm_axis);
line([0 length(VM)],[0 0], 'color', 'k','linewidth',0.5)
hold on
plot(VM,'color', 'r')
ylim([min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))])

for i = 1:length(QRS)
    scatter(QRS(i), VM(QRS(i)),'m','*')
end

hold off



