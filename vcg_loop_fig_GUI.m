%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% vcg_loop_fig_GUI.m -- Part of BRAVEHEART GUI - Figure showing VCG loop morphology
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

function vcg_loop_fig_GUI(x, y, z, x2, y2, z2, label, hObject, eventdata, handles)

if strcmp(label,'qrs')
    main_loop = 'QRS Loop';
    sec_loop = 'T Loop';
else
    main_loop = 'T Loop';
    sec_loop = 'QRS Loop';
end

msize = 15;

cla(handles.vcg_morph_axis);
axes(handles.vcg_morph_axis);

vcg = handles.median_vcg;
fidpts = handles.medianbeat.beatmatrix();

cent=[mean(x),mean(y),mean(z)];

[N, A, B, C, ~, ~, ~, ~, ~, ~, ~, ~, V, ~, newPX, newPY, PS, ~, ~] = ...
    plane_svd(x,y,z, 0);


n = V(:,3)';
for i = 1:length(x)
    q = [x(i) y(i) z(i)];
    q_proj(i,:) = q - dot(q - cent, n) * n;
end

a = N(1);
b = N(2);
c = N(3);

hold on
grid on
xlabel('X','fontweight','bold');
ylabel('Y','fontweight','bold');
zlabel('Z','fontweight','bold');


% Generate plane and plot in green
[X,Y]=meshgrid(linspace(min(x),max(x),msize), linspace(min(y), max(y) ,20));
Z=(A*X)+(B*Y)+C;
m = surf(X,Y,Z,'FaceColor','g', 'DisplayName','Best-fit Plane'); alpha(0.1);

% Plot original data in black
s1 = scatter3(x,y,z,msize,'filled','MarkerEdgeColor','k','MarkerFaceColor','k','DisplayName',main_loop);
line(x,y,z,'color','k','linewidth',1);

% Plot secondary loop
s_alt = scatter3(x2,y2,z2,msize/2,'filled','MarkerEdgeColor','[0.6 0.6 0.6]','MarkerFaceColor','[0.6 0.6 0.6]','DisplayName',sec_loop');
line(x2,y2,z2,'color','[0.6 0.6 0.6]','linewidth',0.4);

% Plot data projected into the plane in red
s2 = scatter3(q_proj(:,1),q_proj(:,2),q_proj(:,3),msize,'filled','MarkerEdgeColor','r','MarkerFaceColor','r','DisplayName','Projected to Best-fit Plane'); 
line(q_proj(:,1),q_proj(:,2),q_proj(:,3),'color','r','linewidth',1);

% % Plot projected data now rotated/translated into the XY plane in blue
% s3 = scatter(newPX, newPY,msize,'filled','MarkerEdgeColor','b','MarkerFaceColor','b','DisplayName','Loop Rotated to XY Plane');
% line(newPX, newPY,'color','b','linewidth',1)
% plot(PS,'FaceColor','b','FaceAlpha',0.2);

% Basis vectors for plane
if get(handles.vcg_morph_fig_hidebasis_checkbox,'Value') == 1
    ax1 = line([cent(1) V(1,1)+cent(1)], [cent(2) V(2,1)+cent(2)], [cent(3) V(3,1)+cent(3)], 'linewidth',2,'color','r','DisplayName','V1');
    ax2 = line([cent(1) V(1,2)+cent(1)], [cent(2) V(2,2)+cent(2)], [cent(3) V(3,2)+cent(3)], 'linewidth',2,'color','g','DisplayName','V2');
    ax3 = line([cent(1) V(1,3)+cent(1)], [cent(2) V(2,3)+cent(2)], [cent(3) V(3,3)+cent(3)], 'linewidth',2,'color','b','DisplayName','V3 (Normal)');
end

if get(handles.vcg_morph_fig_axis_checkbox,'Value') == 1
    daspect([1 1 1])
else
    daspect auto;
end

if get(handles.vcg_morph_fig_legend_checkbox,'Value') == 1
    if get(handles.vcg_morph_fig_hidebasis_checkbox,'Value') == 1
        legend([s1 s_alt s2 ax1 ax2 ax3 m],'location', 'southoutside','NumColumns',3);
    else
        legend([s1 s_alt s2 m],'location', 'southoutside','NumColumns',2);
    end
else
    legend('off');
end

ax = gca;
ax.XRuler.FirstCrossoverValue  = 0; % X crossover with Y axis
ax.YRuler.FirstCrossoverValue  = 0; % Y crossover with X axis
ax.ZRuler.FirstCrossoverValue  = 0; % Z crossover with X axis
ax.ZRuler.SecondCrossoverValue = 0; % Z crossover with Y axis
ax.XRuler.SecondCrossoverValue = 0; % X crossover with Z axis
ax.YRuler.SecondCrossoverValue = 0; % Y crossover with Z axis

