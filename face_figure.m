%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% display_medianbeats.m -- Part of BRAVEHEART GUI - Shows face in VCG Viewer
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

function face_figure(face_flag, hObject, eventdata, handles)

% face_flag is 1 if face is showing, and 0 if not showing

if face_flag == 1;  
    cla(handles.face_axis)
    handles.face_flag = 0;
    guidata(hObject, handles);
end

if face_flag == 0;
    set(handles.face_axis,'visible','on');
    handles.face_flag = 1;

    axes(handles.face_axis)

    % Draw face
    [x,y,z] = sphere;
    surf(x,y,z,'FaceColor', [0 0.4470 0.7410], 'FaceLighting', 'gouraud', 'linestyle','none', 'facealpha', 0.7);
    hold on;

    surf((x*.2)-.3,(y*.2)-.7,(z*.2)-.7,'FaceColor', [0 0 0]);
    surf((x*.2)+.3,(y*.2)-.7,(z*.2)-.7,'FaceColor', [0 0 0]);
    surf((x*.15),(y*.15)-.3,(z*.15)-1,'FaceColor', [0 0 1], 'linestyle','none');

    r=0.5;
    semicrc = [[r*cos(0:0.1:pi) r*cos(0)]; [r*sin(0:0.1:pi) r*sin(0)];zeros(1,33)-1];
    colorfill = zeros(1,33)+1;
    fill3(semicrc(1,:), semicrc(2,:), semicrc(3,:),colorfill);

    [x2,y2,z2] = cylinder;

    surf(x2*.3,(z2*.3)+.9,y2*.3,'FaceColor', [1 0 0],'linestyle','none');
    cilfill = [x2(1,:)*.3;  zeros(1,21)+1.15; y2(1,:)*.3];
    fill3(cilfill(1,:), cilfill(2,:), cilfill(3,:),'r');

    xlim([-1.2 1.2]);
    ylim([-1.2 1.2]);
    zlim([-1.2 1.2]);
    %set (gca,'Zdir','reverse');
    %%set (gca,'Ydir','reverse');

    hold off
    axis square
    axis off

    linkprop([handles.vcg_axis, handles.face_axis],'view');
    linkprop([handles.vcg_axis, handles.face_axis],'CameraUpVector');
    guidata(hObject, handles);

end