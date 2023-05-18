%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% plot_animated_VCG.m -- Part of BRAVEHEART GUI - Figure showing animated VCG loop
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

%%% PLOT ANIMATED VCG

function plot_animated_VCG(x, y, z, axis_flag, step, save_flag, save_filename, title_filename, origin_flag)

title_txt = title_filename(1:end-4);
title_txt_full = strcat({'3D VCG - '}, {''}, {title_txt});
movie_filename = strcat(title_filename(1:end-4),'.avi');

t=linspace(1,length(x),length(x));

spacing = 1:step:length(x);


anim_fig = figure('name','Animated VCG','numbertitle','off');
set( gca, 'Units', 'normalized', 'Position', [.1 .1 .9 .9] );
set(gcf, 'Position', [50, 150, 1500, 800]);  % set figure size


%Shift X,Y,Z to origin at (0,0,0)
[X_mid, Y_mid, Z_mid, x, y, z, x_orig, y_orig, z_orig, x_shift, y_shift, z_shift] = shift_xyz(x, y, z, origin_flag);

% setup dummy variables for YZ view
%"X"
xx = z;
yy = y;


% 3d plot
ax3d = subplot(3,5,[1,2,3,6,7,8,11,12,13]);
scatter3(x,y,z,25);
hold on;
p3d = scatter3(x(1),y(1),z(1),50,'r','filled');
hold off;
xlabel('X','FontWeight','bold','FontSize',14);
ylabel('Y','FontWeight','bold','FontSize',14);
zlabel('Z','FontWeight','bold','FontSize',14);
title(title_txt_full,'Interpreter', 'none');
if axis_flag == 1
daspect([1 1 1])
end


% XY plot
ax_xy = subplot(3,5,4);
scatter3(x,y,z,10);
hold on;
pxy = scatter3(x(1),y(1),z(1),50,'r','filled');
hold off;
view(0,-90); % XY
xlabel('X (mV)','FontWeight','bold','FontSize',9);
ylabel('Y (mV)','FontWeight','bold','FontSize',9);
title('Frontal')
if axis_flag == 1
daspect([1 1 1])
end


% XZ plot
ax_xz = subplot(3,5,9);
scatter3(x,y,z,10);
hold on;
pxz = scatter3(x(1),y(1),z(1),50,'r','filled');
hold off;
view(360, 180); % XZ
xlabel('X (mV)','FontWeight','bold','FontSize',9);
zlabel('Z (mV)','FontWeight','bold','FontSize',9);
title('Transverse')
if axis_flag == 1
daspect([1 1 1])
end


% YZ plot
ax_yz = subplot(3,5,14);
plot(xx,yy,'o','MarkerSize',3);
hold on;
pyz = scatter(xx(1),yy(1),'r','filled');
hold off;
ylabel('Y (mV)','FontWeight','bold','FontSize',9);
xlabel('Z (mV)','FontWeight','bold','FontSize',9);
title('Left Sagital');
set (gca,'Ydir','reverse');
grid on
if axis_flag == 1
daspect([1 1 1])
end


% X axis
ax_x = subplot(3,5,5);
plot(t,x);
hold on;
px = plot(t(1),x(1),'o','MarkerFaceColor','red');
hold off;
title('X');
xlabel('Samples','FontWeight','bold','FontSize',9);
ylabel('mV','FontWeight','bold','FontSize',9);
xlim([0 length(x)])

% Y axis
ax_y = subplot(3,5,10);
plot(t,y);
hold on;
py = plot(t(1),y(1),'o','MarkerFaceColor','red');
hold off;
title('Y');
xlabel('Samples','FontWeight','bold','FontSize',9);
ylabel('mV','FontWeight','bold','FontSize',9);
xlim([0 length(y)])

% Z axis
ax_z = subplot(3,5,15);
plot(t,z);
hold on;
pz = plot(t(1),z(1),'o','MarkerFaceColor','red');
hold off;
title('Z');
xlabel('Samples','FontWeight','bold','FontSize',9);
ylabel('mV','FontWeight','bold','FontSize',9);
xlim([0 length(z)])

pause(1)  % pause few seconds to allow loading of graphics

% Animate 

Mov(1) = getframe(anim_fig);  % save first frame for movie

for k = 2:length(spacing)
        
    p3d.XData = x(spacing(k));
    p3d.YData = y(spacing(k));
    p3d.ZData = z(spacing(k));
    
    pxy.XData = x(spacing(k));
    pxy.YData = y(spacing(k));
    pxy.ZData = z(spacing(k));

    pxz.XData = x(spacing(k));
    pxz.YData = y(spacing(k));
    pxz.ZData = z(spacing(k));
    
    pyz.XData = xx(spacing(k));
    pyz.YData = yy(spacing(k));
    
    px.YData = x(spacing(k));
    px.XData = t(spacing(k));
    
    py.YData = y(spacing(k));
    py.XData = t(spacing(k));
    
    pz.YData = z(spacing(k));
    pz.XData = t(spacing(k));
    
    drawnow; 
    
    Mov(k) = getframe(anim_fig);  % save kth frame for movie

end



%Movie Export
export_movie = VideoWriter(movie_filename,'Motion JPEG AVI');
export_movie.Quality = 100;
open(export_movie)
writeVideo(export_movie,Mov)
close(export_movie)


% Animate_button=uicontrol('Parent',anim_fig,'Style','pushbutton','String','Play','Units','normalized','Position',[0.0 0.0 0.1 0.1],'Visible','on');