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


function plot_vcg_gui(geh, median_vcg, medianbeat, aps, hObject, eventdata, handles) %#ok<INUSL>

% Clear vcg_axis 
cla(handles.vcg_axis)
clear_axis_fully(handles.vcg_axis)

% Restore VCG axes location to avoid issues with colorbar shrinking figure
orig_pos = getappdata(handles.BRAVEHEART_GUI, 'vcg_axis_orig_pos');
handles.vcg_axis.Position = orig_pos;

% Get colors based on if in light/dark mode
[dm, dark_colors, light_colors] = check_darkmode(handles);

if dm == 1
    colors = dark_colors;
else
    colors = light_colors;
end

% If missing VCG leads just stop there
if isempty(median_vcg.X) || isempty(median_vcg.Y) || isempty(median_vcg.Z) || isempty(median_vcg.VM)
    return;
end


try   % If throw an error just dont plot!

    % Read all flags into structure
        flags = read_flags(handles);
 
    % Median beat fiducial points
        sample_time = median_vcg.sample_time();
        Q = medianbeat.Q;
        S = medianbeat.S;
        Tend = medianbeat.Tend;

    % Shift X,Y,Z to origin at (0,0,0)
        origin_flag = aps.origin_flag;
        [~, ~, ~, x, y, z, ~, ~, ~, ~, ~, ~] = shift_xyz(median_vcg.X', median_vcg.Y', median_vcg.Z', origin_flag);

    % Draw on axis, accumulating legend handles as needed
        ax = handles.vcg_axis;
        hold(ax, 'on');

        % Fix issue with losing ability to rotate when clearing figure
        ax.HitTest = 'on';
        ax.PickableParts = 'visible'; 
        
        h = struct();   % registry: fieldname -> graphics handle for legend
 
        if flags.speed
            plot_speed_colored(ax, x, y, z, Q, Tend, sample_time, flags);
        else
            h = plot_loops(ax, x, y, z, Q, S, h);
        end

        % Markers shown regardless of plotting flags
            h.QRSEnd = scatter3(ax, x(S), y(S), z(S), 60, 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'DisplayName', 'QRS End');
            h.Origin = scatter3(ax, 0, 0, 0, 60, 'k', 'filled', 'MarkerEdgeColor', 'y', 'DisplayName', 'Origin');
 
        if flags.prop
            h = plot_propagation(ax, x, y, z, Q, S, h);
        end
 
        if flags.vector
            h = plot_vectors(ax, geh, h);
        end

    % Cosmetic changes to axes
        apply_axes_cosmetics(ax, colors, flags);

    % Legend
        if flags.legend
            build_legend(ax, h, colors);
        else
            legend(ax, 'off');
        end
 
        hold(ax, 'off');

catch ME
    % Don't crash the GUI on a plot failure
    warning('plot_vcg_gui:render', 'VCG plot failed: %s', ME.message);
    
end  % end try

end  % End function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Helper functions

% Read flags into a structure 'flags'
function flags = read_flags(handles)
    flags = struct( ...
        'speed', get(handles.speed_checkbox, 'Value'), ...
        'prop', get(handles.propagation_checkbox, 'Value'), ...
        'legend', get(handles.legend_checkbox, 'Value'), ...
        'vector', get(handles.vector_checkbox, 'Value'), ...
        'axes_orig', get(handles.axes_origin_checkbox, 'Value'), ...
        'sq_axes', get(handles.sqaxes_box, 'Value'), ...
        'custom_dc', get(handles.custom_dcm_checkbox, 'Value'));
end


% Plot standard QRS and T wave loops (points and connected lines)
function h = plot_loops(ax, x, y, z, Q, S, h)
    h.QRSLoop = scatter3(ax, x(Q:S), y(Q:S), z(Q:S), 20, 'MarkerEdgeColor', 'b', 'DisplayName', 'QRS Loop');
    h.TLoop = scatter3(ax, x(S+1:end), y(S+1:end), z(S+1:end), 20, 'r', 'o', 'DisplayName', 'T Loop');
   
    % Connecting lines, hidden from the legend so dont assign to 'h'
    plot3(ax, x(Q:S), y(Q:S), z(Q:S), 'b', 'LineWidth', 2);
    plot3(ax, x(S+1:end), y(S+1:end), z(S+1:end), 'r', 'LineWidth', 2);
end


% Plot color coded speed
function plot_speed_colored(ax, x, y, z, Q, Tend, sample_time, flags)
    n = numel(x);
    speed_3d = zeros(n-1, 1);
    
    % Calcualte the speed between sequential points
    for i = Q:n-1
        speed_3d(i+1) = sqrt((x(i+1)-x(i))^2 + (y(i+1)-y(i))^2 + (z(i+1)-z(i))^2) / sample_time;
    end

    smax = max(speed_3d);

    SpeedColorMap = jet(256);
    idx  = round(speed_3d * (256 / smax));
    
    for i = Q:Tend
        line(ax, [x(i) x(i+1)], [y(i) y(i+1)], [z(i) z(i+1)], 'Color', SpeedColorMap(idx(i+1), :), ...
            'LineWidth', 3);   % don't add to the legend
    end
    colormap(ax, SpeedColorMap);
    cb = colorbar(ax, 'Location', 'eastoutside');

    % Shift the colorbar only if no legend is shown
    if flags.legend == 0
        drawnow;
        ax_pos_pin = ax.Position;
        cb.Position(1) = cb.Position(1) - 0.05;
        ax.Position = ax_pos_pin;
    end

    % Set color limits from 0 to the maximum speed
    set(ax, 'CLim', [0, smax]);
    
    % Generate 8 ticks: 0, smax, and 6 evenly spaced values in between
    cb.Ticks = linspace(0, smax, 8);
    
    % Clean up the labels to 2 decimal place so they don't overlap
    cb.TickLabels = string(round(cb.Ticks, 2));
    ylabel(cb, 'Speed (mV/ms)');

    % Fixing legend bug w/ speed display
    legend off
end


function apply_axes_cosmetics(ax, colors, flags)
    set(ax, 'Color',  colors.bgfigcolor, ...
            'XColor', colors.txtcolor, ...
            'YColor', colors.txtcolor, ...
            'ZColor', colors.txtcolor);
    xlabel(ax, 'X', 'FontWeight', 'bold', 'FontSize', 14);
    ylabel(ax, 'Y', 'FontWeight', 'bold', 'FontSize', 14);
    zlabel(ax, 'Z', 'FontWeight', 'bold', 'FontSize', 14);
    grid(ax, 'on');
    box(ax, 'off');
 
    if flags.sq_axes
        daspect(ax, [1 1 1]);
    else
        daspect(ax, 'auto');
    end
 
    if flags.axes_orig
        ax.XRuler.FirstCrossoverValue  = 0;  % X crossover with Y
        ax.YRuler.FirstCrossoverValue  = 0;  % Y crossover with X
        ax.ZRuler.FirstCrossoverValue  = 0;  % Z crossover with X
        ax.ZRuler.SecondCrossoverValue = 0;  % Z crossover with Y
        ax.XRuler.SecondCrossoverValue = 0;  % X crossover with Z
        ax.YRuler.SecondCrossoverValue = 0;  % Y crossover with Z
    else
        % Reset to defaults if user unchecked the box
        ax.XRuler.FirstCrossoverValue  = -inf;
        ax.YRuler.FirstCrossoverValue  = -inf;
        ax.ZRuler.FirstCrossoverValue  = -inf;
        ax.ZRuler.SecondCrossoverValue = -inf;
        ax.XRuler.SecondCrossoverValue = -inf;
        ax.YRuler.SecondCrossoverValue = -inf;
    end
 
    view(ax, 23, -45);
end
 

% Create legend with appropriate number of items
function build_legend(ax, h, colors)
    names = fieldnames(h);
    if isempty(names)
        legend(ax, 'off');
        return;
    end
    c = struct2cell(h);
    handles_list = [c{:}];
    leg = legend(ax, handles_list, 'Location', 'northeastoutside', 'Color', colors.bgfigcolor, 'TextColor', colors.txtcolor);
end

% Plot initial propagation of QRS and T wave
function h = plot_propagation(ax, x, y, z, Q, S, h)
    h.StartQRS = scatter3(ax, x(Q:Q+20), y(Q:Q+20), z(Q:Q+20), 'g', 'filled', 'MarkerEdgeColor', 'b', 'DisplayName', 'Start QRS Loop');
    h.StartT = scatter3(ax, x(S+1:S+20), y(S+1:S+20), z(S+1:S+20), 'y', 'filled', 'MarkerEdgeColor', 'r', 'DisplayName', 'Start T Loop');
end


% Plot peak and area vectors
function h = plot_vectors(ax, geh, h)
    O = [0 0 0];
 
    % Peak Vectors
    qrs_peak = [geh.XQ_peak geh.YQ_peak geh.ZQ_peak];
    t_peak   = [geh.XT_peak geh.YT_peak geh.ZT_peak];
    svg_peak = qrs_peak + t_peak;
 
    h.PeakQRS = vec_line(ax, qrs_peak, O, 'b', '-', 'Peak QRS');
    h.PeakT   = vec_line(ax, t_peak,   O, 'r', '-', 'Peak T');
    h.PeakSVG = vec_line(ax, svg_peak, O, [0 0.7 0], '-', 'Peak SVG');
 
    % Area Vectors (scaled so can view them on same figure)
    qrs_area = [geh.XQ_area geh.YQ_area geh.ZQ_area];
    t_area   = [geh.XT_area geh.YT_area geh.ZT_area];
    svg_area = [geh.svg_x geh.svg_y geh.svg_z];
 
    ratio = min([norm(qrs_peak) / max(norm(qrs_area), eps), ...
                 norm(t_peak) / max(norm(t_area), eps), ...
                 norm(svg_peak) / max(geh.svg_area_mag, eps)]);
 
    h.AreaQRS = vec_line(ax, scale_to(qrs_area, norm(qrs_area) * ratio), O, 'b', ':', 'Area QRS');
    h.AreaT   = vec_line(ax, scale_to(t_area,   norm(t_area)   * ratio), O, 'r', ':', 'Area T');
    h.AreaSVG = vec_line(ax, scale_to(svg_area, geh.svg_area_mag * ratio), O, [0 0.7 0], ':', 'Area SVG');
end


% Rescale area vectors so they fit
function v = scale_to(vec, target_len)
    n = norm(vec);
    if n == 0
        v = vec;
    else
        v = vec / n * target_len;
    end
end
 
% Draw vectors as lines
function lh = vec_line(ax, p1, p2, color, style, name)
    lh = line(ax, [p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], ...
        'Color', color, 'LineWidth', 3, 'LineStyle', style, ...
        'DisplayName', name);
end