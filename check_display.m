%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% check_display.m -- Generates warning popup if monitor resolution will not support BRAVEHEART GUI
% Copyright 2016-2026 Hans F. Stabenau and Jonathan W. Waks
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

function ok = check_display()

    % Min resolution is 1920x1080
    minW = 1920;
    minH = 1080;
    
    % Get monitor data from groot
    mp    = get(groot, 'MonitorPositions');
    dpi   = get(groot, 'ScreenPixelsPerInch');
    
    % Detect scaling (seems less useful overall)
    scale = max(dpi / 96, 1);   % never go below 1.0

    % The GUI always opens on the "main" monitor which starts with coordinates 1 1 in MonitorPositions
    pIdx = find(mp(:,1) == 1 & mp(:,2) == 1, 1);
    if isempty(pIdx), pIdx = 1; end   % fallback
    
    % Get resolution of main monitor
    monW = mp(pIdx,3);
    monH = mp(pIdx,4);

    % Effective area per monitor in "logical" pixels
    effW = monW / scale;
    effH = monH / scale;
    
    % Effective area must be > 1920x1080 accounting for scaling
    % There may be slight differences in PC and Mac in how this is reported
    ok = (effW >= minW && effH >= minH);

    if ~ok
        % Show popup 
        msg = sprintf(['Potential issue with display!  The effective resolution ' ...
            'of your primary monitor is %dx%d, but a minimum of 1920x1080 ' ...
            'is required.  This may be due to monitor resolution, OS ' ...
            'display scaling, or both — check your monitor settings.  See ' ...
            'BRAVEHEART user guide Chapter 31 for additional ' ...
            'information/help.'], round(effW), round(effH));

        uiwait(warndlg(msg, 'Monitor Resolution Too Low!', 'modal'));

    end

end         % End function