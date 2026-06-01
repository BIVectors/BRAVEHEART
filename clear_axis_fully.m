%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% clear_axis_fully.m -- Clears colorbars and legends from complex axes objects
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

function clear_axis_fully(ax)
    
    % cla() only deletes children with HandleVisibility='on', so lines 
    % created with HandleVisibility='off' (to keep them out of the legend)
    % survive a plain cla() and then show up in the next render. This
    % function also clears any colorbar or legend on the parent figure,
    % since neither lives in the axis's child list.
    
    % Use findall (not findobj): once a colorbar/legend has its position set
    % manually, its HandleVisibility goes to 'off' and findobj skips it,
    % which leaves the old annotation on screen alongside the new one.

    delete(allchild(ax));
 
    fig = ancestor(ax, 'figure');
    if ~isempty(fig)
        delete(findall(fig, 'Type', 'colorbar'));
        delete(findall(fig, 'Type', 'legend'));
    end
end
 