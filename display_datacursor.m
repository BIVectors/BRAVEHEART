%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% display_datacursor.m -- Part of BRAVEHEART GUI
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

function output_txt = display_datacursor(obj,event_obj, step)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).



pos = get(event_obj,'Position');
I = get(event_obj, 'DataIndex');
T = (I - 1) * step;
output_txt = {['Sample: ',num2str(pos(1),4)],...
    ['Time (ms): ',num2str((pos(1)-1)*step)],...
    ['Amplitude (mV): ',num2str(pos(2),4)]};
% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt = {['X (mV): ',num2str(pos(1),4)],...
    ['Y (mV): ',num2str(pos(2),4)],...
    ['Z (mV): ',num2str(pos(3),4)],...
    ['Sample: ',num2str(I)],...
    ['Time (ms): ',num2str(T)]};
    
    
    
end
