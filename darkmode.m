 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% darkmode.m -- Toggles GUI from light mode to dark mode
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

function darkmode(handles)

% If error in changing colors that specific element of GUI will just not
% change but errors are NOT produced

% Get all objects in the GUI
A = findobj;

% Get current color of GUI to see if in darkmode or lightmode
[is_dark, dark_colors, light_colors] = check_darkmode(handles);

if is_dark == 1
    new_colors = light_colors;
    old_colors = dark_colors;
else 
    new_colors = dark_colors;
    old_colors = light_colors;
end

% Set main GUI background color
BR = findobj('Tag','BRAVEHEART_GUI');
BR.Color = new_colors.bgcolor;

% Loop through all GUI objects
for i = 1:length(A)

% Buttons    
try
    % Change all button background colors
    if strcmp(A(i).Style,'pushbutton')
        A(i).BackgroundColor = new_colors.buttoncolor;
        
        % Button text color
        if (~strcmp(A(i).Tag,'toff_shift_button')) ...
            && (~strcmp(A(i).Tag,'rpk_shift_button')) ...
            && (~strcmp(A(i).Tag,'rpeak_minus_button')) ...
            && (~strcmp(A(i).Tag,'rpeak_plus_button')) ...
            && (~strcmp(A(i).Tag,'toff_minus_button')) ...
            && (~strcmp(A(i).Tag,'toff_plus_button')) ...
            && (~strcmp(A(i).Tag,'rpk_shift_button'))

            % Blue text buttons
            if (sum(A(i).ForegroundColor == light_colors.bluetxtcolor) == 3 || sum(A(i).ForegroundColor == dark_colors.bluetxtcolor) == 3)
                A(i).ForegroundColor = new_colors.bluetxtcolor;
            else
                A(i).ForegroundColor = new_colors.txtcolor;
            end
        end
    end
end

% Button Groups
try
    if strcmp(A(i).Type,'uibuttongroup')
        A(i).BackgroundColor = new_colors.bgcolor;
        A(i).ForegroundColor = new_colors.txtcolor;
    end
end

% Panels
try
    if strcmp(A(i).Type, 'uipanel') && (~strcmp(A(i).Tag,'quality_count_panel')) && (~strcmp(A(i).Tag,'quality_panel'))
        A(i).ForegroundColor = new_colors.txtcolor;
        A(i).BackgroundColor = new_colors.bgcolor;
    end
end

% Text
% Black text should change to white and vice versa - change background and text
try
    if strcmp(A(i).Style, 'text') && (sum(A(i).ForegroundColor == light_colors.txtcolor) == 3 || sum(A(i).ForegroundColor == dark_colors.txtcolor) == 3) ...
        && (~strcmp(A(i).Tag,'quality_score_txt')) && (~strcmp(A(i).Tag,'quality_count_txt'))
            A(i).ForegroundColor = new_colors.txtcolor;
            A(i).BackgroundColor = new_colors.bgcolor;
    end
end

% Colored text should only change background
% Ignore quality text which is always on colored background
try
    if strcmp(A(i).Style, 'text') && (sum(A(i).ForegroundColor == light_colors.txtcolor) < 3 || sum(A(i).ForegroundColor == dark_colors.txtcolor) < 3) ...
            && (~strcmp(A(i).Tag,'quality_score_txt')) && (~strcmp(A(i).Tag,'quality_count_txt'))
        A(i).BackgroundColor = new_colors.bgcolor;
    end
end

% Special change for blue text as contrast may be poor with darkmode
try
    if strcmp(A(i).Style, 'text') && (sum(A(i).ForegroundColor == light_colors.bluetxtcolor) == 3 || sum(A(i).ForegroundColor == dark_colors.bluetxtcolor) == 3)
        A(i).ForegroundColor = new_colors.bluetxtcolor;
    end
end

% Scatter markers for PVCs and outliers
try
    if strcmp(A(i).Type, 'scatter')
        % PVC markers
        if strcmp(A(i).Marker, '^')
            A(i).MarkerEdgeColor = new_colors.pvcmarker;
        end

        % Outlier markers
        if (strcmp(A(i).Parent.Tag, 'vm_axis') || strcmp(A(i).Parent.Tag, 'x_axis') ||  strcmp(A(i).Parent.Tag, 'y_axis') || strcmp(A(i).Parent.Tag, 'z_axis')) ...
            && strcmp(A(i).Marker, 'o')
            A(i).MarkerEdgeColor = new_colors.outliermarker;
        end
    end
end

% Checkboxes
try
    if strcmp(A(i).Style, 'checkbox')
        A(i).ForegroundColor = new_colors.txtcolor;
        A(i).BackgroundColor = new_colors.bgcolor;
    end
end

% Dropdowns
try
    if strcmp(A(i).Style, 'popupmenu')
        A(i).ForegroundColor = new_colors.txtcolor;
        A(i).BackgroundColor = new_colors.bgfigcolor;
    end
end

% Editable Text Fields
try
    if strcmp(A(i).Style, 'edit')
        A(i).ForegroundColor = new_colors.txtcolor;
        A(i).BackgroundColor = new_colors.bgfigcolor;
    end
end

% Radio Buttons
try
    if strcmp(A(i).Style, 'radiobutton')
        A(i).ForegroundColor = new_colors.txtcolor;
        A(i).BackgroundColor = new_colors.bgcolor;
    end
end

% Listbox
try
    if strcmp(A(i).Style, 'listbox')
        A(i).ForegroundColor = new_colors.txtcolor;
        A(i).BackgroundColor = new_colors.bgfigcolor;
    end
end

% Axes
try
    if strcmp(A(i).Type,'axes') 
        A(i).XColor = new_colors.txtcolor;
        A(i).YColor = new_colors.txtcolor;
        A(i).ZColor = new_colors.txtcolor;
        A(i).Color = new_colors.bgfigcolor;
    end

end

% Legends
try
    if strcmp(A(i).Type,'legend') 
        A(i).Color = new_colors.bgfigcolor;
        A(i).TextColor = new_colors.txtcolor;
    end

end

% % Opened Figures - Not doing this for now -- too hard to get colors right
% for each specific figure.  Reopen figure to change color scheme
% try
%     if strcmp(A(i).Type,'figure') 
%         if ~strcmp(A(i).Tag,'BRAVEHEART_GUI') 
%             A(i).Color = new_colors.bgcolor;
%         end
%     end
% 
% end

end  % End loop


% Fixed changes that are needed due to complex interactions with GUI
% elements which are required due to thinks like making lines draggable or
% linking face and VCG plot

% vcg_axis sometimes does not cooperate - make sure changes
        set(handles.vcg_axis, 'XColor', new_colors.txtcolor);
        set(handles.vcg_axis, 'YColor', new_colors.txtcolor);
        set(handles.vcg_axis, 'ZColor', new_colors.txtcolor);
        set(handles.vcg_axis, 'Color', new_colors.bgfigcolor);

% Load BRAVEHEART logo
axes(handles.logo_axis)

if is_dark == 0
    logo = imread ('logo_t_dark.bmp'); 
    set(handles.uipanel1, 'BorderWidth', 0);
else
    logo = imread ('logo_t.bmp'); 
    set(handles.uipanel1, 'BorderWidth', 1);
end
imshow(logo);


% Existing lines in GUI figures (ECG plots)

L = handles.x_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.y_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.z_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.vm_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.Xmedianbeat_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.Ymedianbeat_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.Zmedianbeat_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.VMmedianbeat_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end

L = handles.selectedbeat_axis.Children;

for i = 1:length(L)
    if strcmp(L(i).Type,'line')
        if isequal(L(i).Color, old_colors.xyzecg)
            L(i).Color = new_colors.xyzecg;
        end
    
        if isequal(L(i).Color, old_colors.vmecg)
            L(i).Color = new_colors.vmecg;
        end
    
        if isequal(L(i).Color, old_colors.vertlines)
            L(i).Color = new_colors.vertlines;
        end
    
        if isequal(L(i).Color, old_colors.bluetxtcolor)
            L(i).Color = new_colors.bluetxtcolor;
        end
    end
end
