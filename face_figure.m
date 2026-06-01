%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% face_figure.m -- Part of BRAVEHEART GUI - Shows face in VCG Viewer
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

function face_figure(hObject, eventdata, handles)

ax = handles.face_axis;

% Draw face
[x,y,z] = sphere;
surf(ax, x,y,z,'FaceColor', [0 0.4470 0.7410], 'FaceLighting', 'gouraud', 'linestyle','none', 'facealpha', 0.7);
hold(ax, 'on');

surf(ax, (x*.2)-.3,(y*.2)-.7,(z*.2)-.7,'FaceColor', [0 0 0]);
surf(ax, (x*.2)+.3,(y*.2)-.7,(z*.2)-.7,'FaceColor', [0 0 0]);
surf(ax, (x*.15),(y*.15)-.3,(z*.15)-1,'FaceColor', [0 0 1], 'linestyle','none');

r=0.5;
semicrc = [[r*cos(0:0.1:pi) r*cos(0)]; [r*sin(0:0.1:pi) r*sin(0)];zeros(1,33)-1];
colorfill = zeros(1,33)+1;
fill3(ax, semicrc(1,:), semicrc(2,:), semicrc(3,:),colorfill);

[x2,y2,z2] = cylinder;

surf(ax, x2*.3,(z2*.3)+.9,y2*.3,'FaceColor', [1 0 0],'linestyle','none');
cilfill = [x2(1,:)*.3;  zeros(1,21)+1.15; y2(1,:)*.3];
fill3(ax, cilfill(1,:), cilfill(2,:), cilfill(3,:),'r');

face_lim = 1;

xlim(ax, [-face_lim face_lim]);
ylim(ax, [-face_lim face_lim]);
zlim(ax, [-face_lim face_lim]);
%set (gca,'Zdir','reverse');
%set (gca,'Ydir','reverse');

hold(ax, 'off');
axis(ax, 'square');
axis(ax,'off');

guidata(hObject, handles);
