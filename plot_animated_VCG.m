%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% plot_animated_VCG.m -- Part of BRAVEHEART GUI - Figure showing animated VCG loop
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

function plot_animated_VCG(x, y, z, axis_flag, step, save_flag, save_filename, title_filename, origin_flag)

title_txt = title_filename(1:end-4);
title_txt_full = strcat({'3D VCG - '}, {''}, {title_txt});
movie_filename = strcat(title_filename(1:end-4),'.avi');

t=linspace(1,length(x),length(x));

% Step spacing for animation
spacing = 1:step:length(x);

% Colors
frontal_color = [0.85 0.95 0];
transverse_color = [0 1 0];
sag_color = [1 0 0];

% Set up figure
anim_fig = figure('name','Animated VCG','numbertitle','off','visible','off');
set(gca, 'Units', 'normalized', 'Position', [.1 .1 .9 .9] );
set(gcf, 'Position', center_gui_figure(1500, 800));  % set figure size

%Shift X,Y,Z to origin at (0,0,0)
[~, ~, ~, x, y, z, ~, ~, ~, ~, ~, ~] = shift_xyz(x, y, z, origin_flag);

% setup dummy variables for YZ view
xx = z;
yy = y;

% 3d plot on ax3d axes
% Plot dots at each sample and then conect with lines
ax3d = subplot(3,5,[1,2,3,6,7,8,11,12,13]);
scatter3(ax3d, x,y,z,50,'filled');
hold(ax3d, 'on');
plot3(ax3d, x, y, z, 'Color', [0 0.45 0.74], 'LineStyle', '-', 'LineWidth', 3);   

% Lock the limits so the walls don't shift when add shadows
xl = xlim(ax3d); 
yl = ylim(ax3d); 
zl = zlim(ax3d);
xlim(ax3d, xl); 
ylim(ax3d, yl); 
zlim(ax3d, zl);

% Color the planes of projection using partially transparant coloring
wall_alpha = 0.3;

% Floor (frontal XY plane, at z = zl(2))
patch(ax3d, ...
    [xl(1) xl(2) xl(2) xl(1)], ...
    [yl(1) yl(1) yl(2) yl(2)], ...
    [zl(2) zl(2) zl(2) zl(2)], ...
    frontal_color, 'EdgeColor', 'none', 'FaceAlpha', wall_alpha);

% Back wall (transverse XZ plane, at y = yl(1))
patch(ax3d, ...
    [xl(1) xl(2) xl(2) xl(1)], ...
    [yl(1) yl(1) yl(1) yl(1)], ...
    [zl(1) zl(1) zl(2) zl(2)], ...
    transverse_color, 'EdgeColor', 'none', 'FaceAlpha', wall_alpha);

% Right wall (sagital YZ plane, at x = xl(2))
patch(ax3d, ...
    [xl(2) xl(2) xl(2) xl(2)], ...
    [yl(1) yl(2) yl(2) yl(1)], ...
    [zl(1) zl(1) zl(2) zl(2)], ...
    sag_color, 'EdgeColor', 'none', 'FaceAlpha', wall_alpha);

% Isometric view
view1 = -37.5;
view2 = 30;
view(ax3d, view1, view2)               
set(ax3d, 'ZDir', 'reverse')        % Z reversed
set(ax3d, 'YDir', 'reverse')        % Y reversed

% Box outline
box(ax3d, 'on')
set(ax3d, 'BoxStyle', 'full', 'LineWidth', 1)

% Static projection curves on the walls
shadow_color = [0.5 0.5 0.5];

plot3(ax3d, x, y, zl(2)*ones(size(y)), 'Color', shadow_color, 'LineStyle', '-', 'LineWidth', 2);   % XY shadow on floor
p3d_xy = scatter3(ax3d, x(1),y(1),zl(2),50,'r','filled');

plot3(ax3d, x, yl(1)*ones(size(y)), z, 'Color', shadow_color, 'LineStyle', '-', 'LineWidth', 2);   % XZ shadow on back wall
p3d_xz = scatter3(ax3d, x(1), yl(1), z(1), 50,'r','filled');

plot3(ax3d, xl(2)*ones(size(y)), y, z, 'Color', shadow_color, 'LineStyle', '-', 'LineWidth', 2);   % YZ shadow on left wall
p3d_yz = scatter3(ax3d, xl(2), y(1), z(1), 50,'r','filled');

% Origins on shadows
scatter3(ax3d,0,0,zl(2),50,'k','filled');
scatter3(ax3d,0,yl(1),0,50,'k','filled');
scatter3(ax3d,xl(2),0,0,50,'k','filled');

% Initial red dot on 3D plot
p3d = scatter3(x(1),y(1),z(1),100,'r','filled');

% Origin on 3d plot
origin_3d = scatter3(0,0,0,50,'k','filled');

% Keep red dot and then black dot in front of everything else
uistack(origin_3d, 'top');
uistack(p3d, 'top');

% Labels and title
xlabel('X','FontWeight','bold','FontSize',14);
ylabel('Y','FontWeight','bold','FontSize',14);
zlabel('Z','FontWeight','bold','FontSize',14);
title(title_txt_full,'Interpreter', 'none');

% Change aspect ratio if specified
if axis_flag == 1
    daspect(ax3d,[1 1 1])
end
axis(ax3d, 'vis3d')

% Drop lines from 3D point to each shadow
drop_style = {'Color', shadow_color, 'LineStyle', '--', 'LineWidth', 2};   % red, dotted, 40% alpha
drop_to_xy = plot3(ax3d, [x(1) x(1)], [y(1) y(1)], [z(1) zl(1)], drop_style{:});
drop_to_xz  = plot3(ax3d, [x(1) x(1)], [y(1) yl(1)], [z(1) z(1)], drop_style{:});
drop_to_yz = plot3(ax3d, [xl(2) x(1)], [y(1) y(1)], [z(1) z(1)], drop_style{:});

hold(ax3d,'off');


% Add face reference for orientation of axes
% Create a small overlay axes in the upper left corner
face_size = 0.25;
inset_ax = axes('Parent', anim_fig, 'Position', [0.02 0.7 face_size face_size], 'Color', 'none'); 

% Draw face
[xf,yf,zf] = sphere;
surf(inset_ax, xf,yf,zf,'FaceColor', [0 0.4470 0.7410], 'FaceLighting', 'gouraud', 'linestyle','none', 'facealpha', 0.7);
hold(inset_ax, 'on');

surf(inset_ax, (xf*.2)-.3,(yf*.2)-.7,(zf*.2)-.7,'FaceColor', [0 0 0]);
surf(inset_ax, (xf*.2)+.3,(yf*.2)-.7,(zf*.2)-.7,'FaceColor', [0 0 0]);
surf(inset_ax, (xf*.15),(yf*.15)-.3,(zf*.15)-1,'FaceColor', [0 0 1], 'linestyle','none');

r=0.5;
semicrc = [[r*cos(0:0.1:pi) r*cos(0)]; [r*sin(0:0.1:pi) r*sin(0)];zeros(1,33)-1];
colorfill = zeros(1,33)+1;
fill3(inset_ax, semicrc(1,:), semicrc(2,:), semicrc(3,:),colorfill);

[xf2,yf2,zf2] = cylinder;

surf(inset_ax, xf2*.3,(zf2*.3)+.9,yf2*.3,'FaceColor', [1 0 0],'linestyle','none');
cilfill = [xf2(1,:)*.3;  zeros(1,21)+1.15; yf2(1,:)*.3];
fill3(inset_ax, cilfill(1,:), cilfill(2,:), cilfill(3,:),'r');

xlim(inset_ax, [-1.2 1.2]);
ylim(inset_ax, [-1.2 1.2]);
zlim(inset_ax, [-1.2 1.2]);

axis(inset_ax, 'square');
hold(inset_ax, 'off');
axis(inset_ax, 'off')
view(inset_ax, view1, view2)   
set(inset_ax, 'ZDir', 'reverse', 'YDir', 'reverse');   % match orientation

% Subplots

% XY plot
ax_xy = subplot(3,5,4);
scatter3(ax_xy,x,y,z,15,'MarkerEdgeColor',[0 0.45 0.74],'MarkerFaceColor',[0 0.45 0.74]);
hold(ax_xy, 'on');
pxy = scatter3(ax_xy,x(1),y(1),z(1),50,'r','filled');

view(ax_xy,0,-90); % XY
xlabel(ax_xy,'X (mV)','FontWeight','bold','FontSize',9);
ylabel(ax_xy,'Y (mV)','FontWeight','bold','FontSize',9);
title(ax_xy,'Frontal (XY)')

patch_color = frontal_color; 
a = 0.3;       
ax_xy.Color = patch_color * a + [1 1 1] * (1 - a);

% Origin
oriXY = scatter3(ax_xy,0,0,0,50,'k','filled');
uistack(oriXY, 'top');

hold(ax_xy,'off');

if axis_flag == 1
    daspect(ax_xy,[1 1 1]);
end


% XZ plot
ax_xz = subplot(3,5,9);
scatter3(ax_xz,x,y,z,15,'MarkerEdgeColor',[0 0.45 0.74],'MarkerFaceColor',[0 0.45 0.74]);
hold(ax_xz,'on');
pxz = scatter3(ax_xz,x(1),y(1),z(1),50,'r','filled');

view(ax_xz,360, 180); % XZ
xlabel(ax_xz,'X (mV)','FontWeight','bold','FontSize',9);
zlabel(ax_xz,'Z (mV)','FontWeight','bold','FontSize',9);
title(ax_xz,'Transverse (XZ)')

patch_color = transverse_color; 
a = 0.3;       
ax_xz.Color = patch_color * a + [1 1 1] * (1 - a);

% Origin
oriXZ = scatter3(ax_xz,0,0,0,50,'k','filled');
uistack(oriXZ, 'top');

hold(ax_xz,'off');

if axis_flag == 1
    daspect(ax_xz,[1 1 1]);
end


% YZ plot
ax_yz = subplot(3,5,14);
scatter(ax_yz,xx,yy,15,'MarkerEdgeColor',[0 0.45 0.74],'MarkerFaceColor',[0 0.45 0.74]);
hold(ax_yz,'on');
pyz = scatter(ax_yz,xx(1),yy(1),'r','filled');

ylabel(ax_yz,'Y (mV)','FontWeight','bold','FontSize',9);
xlabel(ax_yz,'Z (mV)','FontWeight','bold','FontSize',9);
title(ax_yz,'Left Sagital (YZ)');
set (ax_yz,'Ydir','reverse');
grid(ax_yz,'on');

% Origin
oriYZ = scatter3(ax_yz,0,0,0,50,'k','filled');
uistack(oriYZ, 'top');

hold(ax_yz,'off');

patch_color = sag_color; 
a = 0.3;       
ax_yz.Color = patch_color * a + [1 1 1] * (1 - a);


if axis_flag == 1
    daspect(ax_yz,[1 1 1]);
end



% X axis
ax_x = subplot(3,5,5);
plot(ax_x,t,x,'LineWidth',2);
hold on;
px = plot(ax_x,t(1),x(1),'o','MarkerFaceColor','red');
hold(ax_x,'off');
title(ax_x,'X');
xlabel(ax_x,'Samples','FontWeight','bold','FontSize',9);
ylabel(ax_x,'mV','FontWeight','bold','FontSize',9);
xlim(ax_x,[0 length(x)])
grid(ax_x,'on');

% Y axis
ax_y = subplot(3,5,10);
plot(ax_y,t,y,'LineWidth',2);
hold(ax_y,'on');
py = plot(ax_y,t(1),y(1),'o','MarkerFaceColor','red');
hold(ax_y,'off');
title(ax_y,'Y');
xlabel(ax_y,'Samples','FontWeight','bold','FontSize',9);
ylabel(ax_y,'mV','FontWeight','bold','FontSize',9);
xlim(ax_y,[0 length(y)])
grid(ax_y,'on');

% Z axis
ax_z = subplot(3,5,15);
plot(ax_z,t,z,'LineWidth',2);
hold(ax_z,'on');
pz = plot(ax_z,t(1),z(1),'o','MarkerFaceColor','red');
hold(ax_z,'off');
title(ax_z,'Z');
xlabel(ax_z,'Samples','FontWeight','bold','FontSize',9);
ylabel(ax_z,'mV','FontWeight','bold','FontSize',9);
xlim(ax_z,[0 length(z)])
grid(ax_z,'on');

% Figure out the max/min Ylimits for the individual leads so can be plotted
% at the same scale
ecgylim_X = ylim(ax_x);
ecgylim_Y = ylim(ax_y);
ecgylim_Z = ylim(ax_z);

ecg_y_upperlim = max([ecgylim_X(2) ecgylim_Y(2) ecgylim_Z(2)]);
ecg_y_lowerlim = min([ecgylim_X(1) ecgylim_Y(1) ecgylim_Z(1)]);

ecg_y_newlim = [(ecg_y_lowerlim - 0.1) (ecg_y_upperlim + 0.1)];

ylim(ax_x, ecg_y_newlim);
ylim(ax_y, ecg_y_newlim);
ylim(ax_z, ecg_y_newlim);


% Draw Figure
drawnow
movegui(anim_fig, 'center');
set(anim_fig, 'Visible', 'on');

% Run animation
Mov = run_animation(true);

% Now that Mov is complete, create the save button and play button
btn_w = 80; btn_h = 30; margin = 10;
figpos = get(anim_fig, 'Position');

uicontrol('Parent', anim_fig, 'Style', 'pushbutton', 'String', 'Save .avi', ...
    'Units','pixels', 'FontWeight','bold', 'fontsize',8, ...
    'Position', [figpos(3)-btn_w-margin, figpos(4)-btn_h-margin, btn_w, btn_h], ...
    'Callback', @(s,e) save_movie_callback(Mov, movie_filename));

play_btn = uicontrol('Parent', anim_fig, 'Style','pushbutton', 'String','Play', ...
    'Units','pixels', 'Position', [figpos(3)-btn_w-margin, figpos(4)-(2*btn_h)-margin, btn_w, btn_h], ...
    'Callback', @(s,e) play_callback());

drawnow   % force the button to render now


% Animate nested function
function M = run_animation(capture)
    if capture
        M(length(spacing)) = struct('cdata',[],'colormap',[]);
        M(1) = getframe(anim_fig);
    else
        M = [];
    end

    % Update positions on figure
    for k = 2:length(spacing)
            
        p3d.XData = x(spacing(k));
        p3d.YData = y(spacing(k));
        p3d.ZData = z(spacing(k));
    
        p3d_xy.XData = x(spacing(k));
        p3d_xy.YData = y(spacing(k));
    
        drop_to_xy.XData = [x(spacing(k)) x(spacing(k))];
        drop_to_xy.YData = [y(spacing(k)) y(spacing(k))];
        drop_to_xy.ZData = [z(spacing(k)) zl(2)];
    
        p3d_xz.XData = x(spacing(k));
        p3d_xz.ZData = z(spacing(k));
    
        drop_to_xz.XData = [x(spacing(k)) x(spacing(k))];
        drop_to_xz.YData = [y(spacing(k)) yl(1)];
        drop_to_xz.ZData = [z(spacing(k)) z(spacing(k))];
    
        p3d_yz.YData = y(spacing(k));
        p3d_yz.ZData = z(spacing(k));
        
        drop_to_yz.XData = [x(spacing(k)) xl(2)];
        drop_to_yz.YData = [y(spacing(k)) y(spacing(k))];
        drop_to_yz.ZData = [z(spacing(k)) z(spacing(k))];
        
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
            
        % If saving movie
        if capture
            M(k) = getframe(anim_fig);
        end
    end
end     % end animation nested function


function play_callback()
    play_btn.Enable = 'off';
    % Reset markers to position 1
    p3d.XData = x(1);  p3d.YData = y(1);  p3d.ZData = z(1);
    drawnow
    pause(0.2)   % brief pause at start so the reset is visible
    run_animation(false);
    play_btn.Enable = 'on';
end     % end play_callback nested function

end % end main function


% Movie Export helper function
function save_movie_callback(Mov, default_name)
    [f, p] = uiputfile('*.avi', 'Save animation as', default_name);
    if isequal(f, 0); return; end
    vw = VideoWriter(fullfile(p, f), 'Motion JPEG AVI');
    vw.Quality = 50;
    open(vw); writeVideo(vw, Mov); close(vw);
end