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

% Axes objects to pass in to make plotting much faster    
axX = handles.x_axis;
axY = handles.y_axis;
axZ = handles.z_axis;
axVM = handles.vm_axis;

% X Axis
cla(handles.x_axis);
line(axX, [0 length(X)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axX, 'on')
plot(axX, X,'color', colors.xyzecg)
ylim(axX, [min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))])
for i = 1:length(Q)
line(axX, [Q(i) Q(i)],[[min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line(axX, [S(i) S(i)],[[min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line(axX, [Tend(i) Tend(i)],[[min(X)-0.1*(abs(max(X)-min(X))) max(X)+0.1*(abs(max(X)-min(X)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(axX, R, X(R),'*','color','m','MarkerSize', 8)
hold(axX, 'off')

% Y Axis
cla(handles.y_axis);
line(axY, [0 length(Y)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axY, 'on')
plot(axY, Y,'color', colors.xyzecg)
ylim(axY, [min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))])
for i = 1:length(Q)
line(axY, [Q(i) Q(i)],[[min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line(axY, [S(i) S(i)],[[min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line(axY, [Tend(i) Tend(i)],[[min(Y)-0.1*(abs(max(Y)-min(Y))) max(Y)+0.1*(abs(max(Y)-min(Y)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(axY, R, Y(R),'*','color','m','MarkerSize', 8)
hold(axY, 'off')

% Z Axis
cla(handles.z_axis);
line(axZ, [0 length(Z)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axZ, 'on')
plot(axZ, Z,'color', colors.xyzecg)
ylim(axZ, [min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))])
for i = 1:length(Q)
line(axZ, [Q(i) Q(i)],[[min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line(axZ, [S(i) S(i)],[[min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line(axZ, [Tend(i) Tend(i)],[[min(Z)-0.1*(abs(max(Z)-min(Z))) max(Z)+0.1*(abs(max(Z)-min(Z)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(axZ, R, Z(R),'*','color','m','MarkerSize', 8)
hold(axZ, 'on')

% VM Axis
cla(handles.vm_axis);
line(axVM, [0 length(VM)],[0 0], 'color', colors.vertlines,'linewidth',0.5)
hold(axVM, 'on')
plot(axVM, VM,'color', colors.vmecg)
ylim(axVM, [min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))])
for i = 1:length(Q)
line(axVM, [Q(i) Q(i)],[[min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(S)
line(axVM, [S(i) S(i)],[[min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
for i = 1:length(Tend)
line(axVM, [Tend(i) Tend(i)],[[min(VM)-0.1*(abs(max(VM)-min(VM))) max(VM)+0.1*(abs(max(VM)-min(VM)))]],'color', colors.vertlines, 'linewidth',1.2,'LineStyle',':')
end
plot(axVM, R, VM(R),'*','color','m','MarkerSize', 8)
hold(axVM, 'off')

end