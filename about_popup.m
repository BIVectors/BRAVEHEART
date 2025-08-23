%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% about_popup.m -- Generates information about BRAVEHEART license
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

function about_popup()

% Get version
version = AnnoResult().version{1};

% Get screen size and calculate center position
screenSize = get(0, 'ScreenSize');  % [left, bottom, width, height]
figWidth = 500;
figHeight = 600;

% Calculate centered position
figLeft = round((screenSize(3) - figWidth) / 2);
figBottom = round((screenSize(4) - figHeight) / 2);

% Create figure - centered on screen
fig = uifigure('Name', 'About/License', ...
               'Position', [figLeft, figBottom, figWidth, figHeight], ...
               'WindowStyle', 'modal', 'Resize', 'off');
    
% % Create figure
% fig = uifigure('Name', 'About/License', 'Position', [700, 500, 500, 600], ...
%            'WindowStyle', 'modal', 'Resize', 'off');

% Create panel
panel = uipanel(fig, 'Position', [10, 10, 480, 600], 'BorderType', 'none');

% Set where anchor text
anchor = 19;

% BRAVE in blue
brave_txt = uilabel(panel, ...
'Position', [anchor, 535, 120, 35], ...
'Text', 'BRAVE', ...
'FontSize', 32, ...
'FontWeight', 'bold', ...
'FontAngle', 'italic', ...
'FontColor', [0.09, 0.078, 0.377], ...
'HorizontalAlignment', 'left', ...
'VerticalAlignment', 'bottom');

% H part - red and large  
h_txt = uilabel(panel, ...
'Position', [anchor+112, 535, 40, 35], ...
'Text', 'H', ...
'FontSize', 32, ...
'FontWeight', 'bold', ...
'FontAngle', 'italic', ...
'FontColor', [0.89, 0.016, 0.016], ...
'HorizontalAlignment', 'left', ...
'VerticalAlignment', 'bottom');

% EART part - smaller, manually positioned higher to align baseline
eart_txt = uilabel(panel, ...
'Position', [anchor+134, 531, 80, 30], ...
'Text', 'EART', ...
'FontSize', 24, ...
'FontWeight', 'bold', ...
'FontAngle', 'italic', ...
'FontColor', [0.89, 0.016, 0.016], ...
'HorizontalAlignment', 'left');

% Subtitle
subtitle_txt = uilabel(panel, ...
'Position', [20, 505, 440, 25], ...
'Text', '(Beth Israel Analysis of Vectors of the Heart)', ...
'FontSize', 18, ...
'FontColor', [0, 0, 0], ...
'FontWeight','bold', ...
'HorizontalAlignment', 'left');

% Version 
version_txt = uilabel(panel, ...
'Position', [20, 480, 440, 25], ...
'Text', strcat('v',version), ...
'FontSize', 18, ...
'FontWeight','bold', ...
'HorizontalAlignment', 'left');

% Main text content
main_text = {
'Copyright 2016-2025  Hans F. Stabeneau and Jonathan W. Waks'
''
'Software updates available at http://github.com/BIVectors/BRAVEHEART'
''
'This program is free software: you can redistribute it and/or modify'
'it under the terms of the GNU General Public License as published by'
'the Free Software Foundation, either version 3 of the License, or'
'(at your option) any later version.'
''
'This program is distributed in the hope that it will be useful, but'
'WITHOUT ANY WARRANTY; without even the implied warranty of'
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'
'See the GNU General Public License for more details.'
''
'You should have received a copy of the GNU General Public License'
'along with this program.  If not, see <https://www.gnu.org/licenses/>'
''
'This software is for research purposes only and is not intended'
'to diagnose or treat any disease.'
};

% Main text line by line
y_pos = 440;
line_height = 20;

for i = 1:length(main_text)
if ~isempty(main_text{i})
    uilabel(panel, ...
        'Position', [20, y_pos - (i-1)*line_height, 460, 20], ...
        'Text', main_text{i}, ...
        'FontSize', 14, ...
        'HorizontalAlignment', 'left');
end
end

% OK button
ok_btn = uibutton(panel, ...
'Position', [210, 20, 80, 25], ...
'Text', 'OK', ...
'ButtonPushedFcn', @(src, event) close(fig));


% Make the dialog modal and wait for it to close
uiwait(fig);
end