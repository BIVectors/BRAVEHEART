%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% check_darkmode.m -- Determine which color mode is active and sets appropriate colors
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

function [is_dark, dark_colors, light_colors] = check_darkmode(handles)

% Set colors here as MATLAB RGB triplets range 0-1 for 0-255 (NOT hex codes)

% Initialize color structures
% Easier to adjust colors for other aspects of the GUI this way
dark_colors = struct;
light_colors = struct;

% Colors to use after change of color mode to LIGHT MODE
light_colors.bgcolor = [0.94 0.94 0.94];                % Background of GUI
light_colors.buttoncolor = [0.94 0.94 0.94];            % Button color
light_colors.txtcolor = [0 0 0];                        % Main Text color
light_colors.bgfigcolor= [1 1 1];                       % Figure/graph background
light_colors.xyzecg = [0 0.45 0.74];                    % Color of XYZ ECG signals
light_colors.vmecg = [1 0 0];                           % Color of VM ECG signals
light_colors.vertlines = [0 0 0];                       % Color of vertical graph lines
light_colors.bluetxtcolor = [0 0 1];                    % Color of blue text (if change)
light_colors.pvcmarker = [0, 0.5, 0];                   % Color of PVC marker 
light_colors.outliermarker = [0.25 0.25 0.25];          % Color of outlier marker

% Colors to use after change of color mode to DARK MODE
dark_colors.bgcolor= [0.15 0.15 0.15];
dark_colors.buttoncolor = [0.15 0.15 0.15];
dark_colors.txtcolor = [0.85 0.85 0.85];
dark_colors.bgfigcolor = [0.2 0.2 0.2];
dark_colors.xyzecg = [1 0.89 0]; 
dark_colors.vmecg = [1 0 0]; [1 0.03 0];
dark_colors.vertlines = [1 1 1];
dark_colors.bluetxtcolor = [0.18 0.56 1];
dark_colors.pvcmarker = [0.9 0.9 0.9];
dark_colors.outliermarker = [0 0.91 1];   

% Checks if GUI background is normal gray color
% If not, assumes in dark mode
% This is important for figure saving

% Get all objects in the GUI
A = findobj;

    % Get current color of GUI to see if in darkmode or lightmode
    if isequal(A(1).Children(1).Color, light_colors.bgcolor)
        is_dark = 0;
    else
        is_dark = 1;
    end
        
end


