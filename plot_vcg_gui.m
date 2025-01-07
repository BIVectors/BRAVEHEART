%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% plot_vcg_gui.m -- Part of BRAVEHEART GUI - Plots VCG
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


function plot_vcg_gui(geh, median_vcg, medianbeat, aps, hObject, eventdata, handles)

cla(handles.vcg_axis) % clear axes

try   % If throw an error just dont plot!

if isempty(median_vcg.X) || isempty(median_vcg.Y) || isempty(median_vcg.Z) || isempty(median_vcg.VM)
    return;
end
    
sample_time = median_vcg.sample_time();

% get flag for which type of graph to display
    speed_flag = get(handles.speed_checkbox,'Value');
    prop_flag = get(handles.propagation_checkbox,'Value');
    legend_flag = get(handles.legend_checkbox,'Value');
    vector_flag = get(handles.vector_checkbox,'Value');
    axes_flag = get(handles.axes_origin_checkbox,'Value');

% Get axis ratio information
    axesratio_flag = get(handles.sqaxes_box, 'Value');    
    
% Qon and Qoff for median beat
    Q = medianbeat.Q;
    S = medianbeat.S;
    Tend = medianbeat.Tend;

% Set vcg axis for plotting
axes(handles.vcg_axis)


%%% data cursor
dcm = datacursormode;
step = sample_time;

if get(handles.custom_dcm_checkbox, 'Value') == 1
    set(dcm, 'update', {@display_datacursor, step});

else
    set(dcm, 'update', @standard_dcm);    
end
%%% end data cursor


h = rotate3d;
%h.ActionPostCallback = {@vcg_axis_ButtonDownFcn, handles};
h.Enable = 'on';
h.RotateStyle = 'orbit';

% View angle
v1=23;   %az
v2=-45;  %el
      
origin_flag = aps.origin_flag;

x = median_vcg.X';
y = median_vcg.Y';
z = median_vcg.Z';

% Shift X,Y,Z to origin at (0,0,0)
    [X_mid, Y_mid, Z_mid, x, y, z, x_orig, y_orig, z_orig, x_shift, y_shift, z_shift] = shift_xyz(x, y, z, origin_flag);

% Plotting
if speed_flag == 0    % plot loops and fit curves
    XYZ_median_qrs= [x(Q:S);y(Q:S);z(Q:S)];   % define qrs curve for fitting
    XYZ_median_t= [x(S:end);y(S:end);z(S:end)];       % define t curve for fitting

    p1 = scatter3(x(Q:S),y(Q:S),z(Q:S),20,'MarkerEdgeColor','[0 0.4470 0.7410]','DisplayName','QRS Loop');
    hold on
    p2 = scatter3(x(S+1:end),y(S+1:end),z(S+1:end),20,'r','o','DisplayName','T Loop');
    p3 = scatter3(x(S),y(S),z(S),60,'MarkerFaceColor','y','MarkerEdgeColor','k','DisplayName','QRS End');
    p99 = scatter3(0,0,0,60,'k','filled','MarkerEdgeColor','y','DisplayName','Origin');

    % if you want extra smoothed lines and have curve fitting toolbox
    % removed because wasn't worth having to require curve fitting toolbox
    % for minimal visual improvement
    %fnplt(cscvn(XYZ_median_qrs),'b',2);   % fit QRS curve
    %fnplt(cscvn(XYZ_median_t),'r',2);     % fit T curve
    
    plot3(x(Q:S),y(Q:S),z(Q:S),'b','linewidth',2)
    plot3(x(S+1:end),y(S+1:end),z(S+1:end),'r','linewidth',2)

    xlabel('X','FontWeight','bold','FontSize',14);
    ylabel('Y','FontWeight','bold','FontSize',14);
    zlabel('Z','FontWeight','bold','FontSize',14);
    grid on 
    box off

% If want equal axis scaling
    if axesratio_flag == 1
        daspect([1 1 1])
    end

    if  axes_flag == 1
         ax.XRuler.FirstCrossoverValue  = 0; % X crossover with Y axis
         ax.YRuler.FirstCrossoverValue  = 0; % Y crossover with X axis
         ax.ZRuler.FirstCrossoverValue  = 0; % Z crossover with X axis
         ax.ZRuler.SecondCrossoverValue = 0; % Z crossover with Y axis
         ax.XRuler.SecondCrossoverValue = 0; % X crossover with Z axis
         ax.YRuler.SecondCrossoverValue = 0; % Y crossover with Z axis
    end

    view(v1,v2);
    % camroll(-70);

end  % End speed_flag == 0


if speed_flag == 1  % plot color coded speed
        SpeedColorMap = jet(256);    
        speed_3d=zeros(1,length(x));

        for i=Q:length(speed_3d)-1
            speed_3d(i+1)= sqrt((x(i+1)-x(i))^2+(y(i+1)-y(i))^2+(z(i+1)-z(i))^2)/sample_time; 

        end
            speed_3d=speed_3d'; 

% Divide 256/maxC to get conversion factor to map to colormap
        ColorConv = 256/max(speed_3d);
        speed_3d_rounded=round(speed_3d*ColorConv);
        speed_3d_rounded(speed_3d_rounded == 0)=1;

        LineColor=zeros(1,length(speed_3d));    


        for i=Q:length(speed_3d_rounded)-1

            line([x(i) x(i+1)], [y(i) y(i+1)], [z(i) z(i+1)],'Color', [SpeedColorMap(speed_3d_rounded(i+1),:)],'linewidth',3);
            hold on
        end    

        colormap jet(256);
        cbar_graph = colorbar;
        set(gca, 'CLim', [min(speed_3d), max(speed_3d)]);
        ylabel(cbar_graph, 'Speed (mV/ms)')
        
        p3 = scatter3(x(S),y(S),z(S),60,'MarkerFaceColor','y','MarkerEdgeColor','k','DisplayName','QRS End');
        p99 = scatter3(0,0,0,60,'k','filled','MarkerEdgeColor','y','DisplayName','Origin');
       
        xlabel('X','FontWeight','bold','FontSize',14);
        ylabel('Y','FontWeight','bold','FontSize',14);
        zlabel('Z','FontWeight','bold','FontSize',14);
        %%set (gca,'Ydir','reverse');
        %set (gca,'Zdir','reverse');
        ax = gca;
        grid on
        legend off %fixing legend bug w/ speed display

% If want equal axis scaling
    if axesratio_flag == 1
        daspect([1 1 1])
    end

    if  axes_flag == 1   
        ax.XRuler.FirstCrossoverValue  = 0; % X crossover with Y axis
        ax.YRuler.FirstCrossoverValue  = 0; % Y crossover with X axis
        ax.ZRuler.FirstCrossoverValue  = 0; % Z crossover with X axis
        ax.ZRuler.SecondCrossoverValue = 0; % Z crossover with Y axis
        ax.XRuler.SecondCrossoverValue = 0; % X crossover with Z axis
        ax.YRuler.SecondCrossoverValue = 0; % Y crossover with Z axis
    end

    view(v1,v2);

end     % End speed flag == 1



if prop_flag == 1  % highlightes the first 20 samples of the QRS in green and the first 20 samples of the T wave in yellow
        hold on
        p4 = scatter3(x(Q:Q+20), y(Q:Q+20), z(Q:Q+20),'g','filled','MarkerEdgeColor','b','DisplayName','Start QRS Loop');   
        p5 = scatter3(x(S+1:S+20),y(S+1:S+20),z(S+1:S+20),'y','filled','MarkerEdgeColor','r','DisplayName','Start T Loop');      
end



%%% VECTORS
if vector_flag == 1
       
X_mid = 0;
Y_mid = 0;
Z_mid = 0;

p3 = scatter3(x(S),y(S),z(S),60,'MarkerFaceColor','y','MarkerEdgeColor','k','DisplayName','QRS End');
p99 = scatter3(0,0,0,60,'k','filled','MarkerEdgeColor','y','DisplayName','Origin');
p6 = line([geh.XQ_peak X_mid], [geh.YQ_peak Y_mid], [geh.ZQ_peak Z_mid], 'Color','b','linewidth',3,'DisplayName','Peak QRS');
p7 = line([geh.XT_peak X_mid], [geh.YT_peak Y_mid], [geh.ZT_peak Z_mid], 'Color','r','linewidth',3,'DisplayName','Peak T');
p8 = line([geh.XT_peak+geh.XQ_peak X_mid],[geh.YT_peak+geh.YQ_peak Y_mid],[geh.ZT_peak+geh.ZQ_peak Z_mid],'Color','[0 0.7 0]','linewidth',3,'DisplayName','Peak SVG');


% Generate scaling for area vectors
QRS_area_length = sqrt((geh.XQ_area)^2 + (geh.YQ_area)^2 + (geh.ZQ_area)^2);
QRS_peak_length = sqrt((geh.XQ_peak)^2 + (geh.YQ_peak)^2 + (geh.ZQ_peak)^2);

T_area_length = sqrt((geh.XT_area)^2+(geh.YT_area)^2+(geh.ZT_area)^2);
T_peak_length = sqrt((geh.XT_peak)^2 + (geh.YT_peak)^2 + (geh.ZT_peak)^2);

SVG_area_length = geh.svg_area_mag;
SVG_peak_length = sqrt((geh.XT_peak+geh.XQ_peak)^2+(geh.YT_peak+geh.YQ_peak)^2+(geh.ZT_peak+geh.ZQ_peak)^2);

mean_max_ratio = min([QRS_peak_length/QRS_area_length, T_peak_length/T_area_length, SVG_peak_length/SVG_area_length]);

% Area QRS scaling vectors
QRSarea_end = [geh.XQ_area geh.YQ_area geh.ZQ_area];
QRSarea_scale = QRSarea_end/norm(QRSarea_end);
QRS_area_scaled = [(mean_max_ratio*QRS_area_length*QRSarea_scale(1)), (mean_max_ratio*QRS_area_length*QRSarea_scale(2)), (mean_max_ratio*QRS_area_length*QRSarea_scale(3))];

% Area T scaling vectors
Tarea_end = [geh.XT_area geh.YT_area geh.ZT_area];
Tarea_scale = Tarea_end/norm(Tarea_end);
T_area_scaled = [(mean_max_ratio*T_area_length*Tarea_scale(1)), (mean_max_ratio*T_area_length*Tarea_scale(2)), (mean_max_ratio*T_area_length*Tarea_scale(3))];

% Area SVG scaling vectors
SVGarea_end = [geh.svg_x, geh.svg_y, geh.svg_z];
SVGarea_scale = SVGarea_end/norm(SVGarea_end);
SVG_area_scaled = [(mean_max_ratio*SVG_area_length*SVGarea_scale(1)), (mean_max_ratio*SVG_area_length*SVGarea_scale(2)), (mean_max_ratio*SVG_area_length*SVGarea_scale(3))];

p9 = line([QRS_area_scaled(1) X_mid], [QRS_area_scaled(2) Y_mid], [QRS_area_scaled(3) Z_mid], 'Color','b','linewidth',3,'linestyle',':','DisplayName','Area QRS');
p10 = line([T_area_scaled(1) X_mid], [T_area_scaled(2) Y_mid], [T_area_scaled(3) Z_mid], 'Color','r','linewidth',3,'linestyle',':','DisplayName','Area T');

% Add mean vectors and SVG
p11 = line([SVG_area_scaled(1) X_mid], [SVG_area_scaled(2) Y_mid], [SVG_area_scaled(3) Z_mid], 'Color','[0 0.7 0]','linewidth',3,'linestyle',':','DisplayName','Area SVG');
ax = gca;


% If want equal axis scaling
if axesratio_flag == 1
    daspect([1 1 1])   
end


if  axes_flag == 1
    ax.XRuler.FirstCrossoverValue  = 0; % X crossover with Y axis
    ax.YRuler.FirstCrossoverValue  = 0; % Y crossover with X axis
    ax.ZRuler.FirstCrossoverValue  = 0; % Z crossover with X axis
    ax.ZRuler.SecondCrossoverValue = 0; % Z crossover with Y axis
    ax.XRuler.SecondCrossoverValue = 0; % X crossover with Z axis
    ax.YRuler.SecondCrossoverValue = 0; % Y crossover with Z axis
end

view(v1,v2);
grid on
box off

end  % End vector flag


%%% Legends
if legend_flag == 1
    
  if prop_flag == 0 && speed_flag == 0 && vector_flag == 0
        legend([p1 p2 p3 p99]);    
  end
    
  if prop_flag == 1 && speed_flag == 0 && vector_flag == 0
        legend([p1 p2 p4 p3 p5 p99]);       
  end
    
  if prop_flag == 0 && speed_flag == 1 && vector_flag == 0 
        legend([p3 p99]);       
  end
   
  if prop_flag == 0 && speed_flag == 0 && vector_flag == 1 
        legend([p1 p2 p99 p6 p7 p8 p9 p10 p11]);      
  end
  
  if prop_flag == 0 && speed_flag == 1 && vector_flag == 1   
        legend([p3 p99 p6 p7 p8 p9 p10 p11]);   
  end
  
  if prop_flag == 1 && speed_flag == 1 && vector_flag == 1
        legend([p3 p4 p3 p99 p5 p6 p7 p8 p9 p10 p11]);   
  end  
  
  if prop_flag == 1 && speed_flag == 0 && vector_flag == 1
        legend([p1 p2 p4 p3 p99 p5 p6 p7 p8 p9 p10 p11]);   
  end
  
  if prop_flag == 1 && speed_flag == 1 && vector_flag == 0
        legend([p4 p3 p5 p99]);   
  end
  
  
  grid on
  box off
  
end

view(v1,v2);
hold off

catch % If graphing throws an error

end