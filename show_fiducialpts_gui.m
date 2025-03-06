%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% show_fiducialpts_gui.m -- Part of BRAVEHEART GUI
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

function show_fiducialpts_gui(vcg, beats, hObject,eventdata,handles)  % adds lines for fiducial points on all 6 graphs

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end


X = vcg.X;
Y = vcg.Y;
Z = vcg.Z;
VM = vcg.VM;
beatmatrix = beats.beatmatrix();

Q = beatmatrix(:,1);
R = beatmatrix(:,2);
S = beatmatrix(:,3);
Tend = beatmatrix(:,4);

cla(handles.x_axis);
axes(handles.x_axis);
line([0 length(X)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold on
plot(X,'color', colors.xyzecg)
ylim([min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))])
for i = 1:length(Q)
line([Q(i) Q(i)],[[min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line([S(i) S(i)],[[min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line([Tend(i) Tend(i)],[[min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(R, X(R),'*','color','m','MarkerSize', 8)
hold off


cla(handles.y_axis);
axes(handles.y_axis);
line([0 length(Y)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold on
plot(Y,'color', colors.xyzecg)
ylim([min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))])
for i = 1:length(Q)
line([Q(i) Q(i)],[[min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line([S(i) S(i)],[[min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line([Tend(i) Tend(i)],[[min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(R, Y(R),'*','color','m','MarkerSize', 8)
hold off


cla(handles.z_axis);
axes(handles.z_axis);
line([0 length(Z)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold on
plot(Z,'color', colors.xyzecg)
ylim([min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))])
for i = 1:length(Q)
line([Q(i) Q(i)],[[min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line([S(i) S(i)],[[min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line([Tend(i) Tend(i)],[[min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(R, Z(R),'*','color','m','MarkerSize', 8)
hold off


cla(handles.vm_axis);
axes(handles.vm_axis);
line([0 length(VM)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold on
plot(VM,'color', colors.vmecg)
ylim([min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))])
for i = 1:length(Q)
line([Q(i) Q(i)],[[min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line([S(i) S(i)],[[min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line([Tend(i) Tend(i)],[[min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(R, VM(R),'*','color','m','MarkerSize', 8)
hold off

end