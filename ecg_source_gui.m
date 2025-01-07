%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% ecg_source_gui.m -- Part of BRAVEHEART GUI - Choose default wavelet levels
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

function [freq, wavelet_level_selection, wavelet_level_selection_lf] = ecg_source_gui(freq)

% wavelet_level_selection_lf is really the value here + 5; eg 5 -> lvl 10, 6 -> lvl 11
% Now sets the HPF denoising to highest level that is < 0.25 Hz

% To get wavelet_level_selection_lf from findHighpassLvl(cut,fs) function
% take output and substract 5

 switch freq
     case 500
         wavelet_level_selection = 1;
         % wavelet_level_selection_lf = 5;
         wavelet_level_selection_lf = findHighpassLvl(0.25,freq) - 5;
         
     case 997
         wavelet_level_selection = 2;
         % wavelet_level_selection_lf = 6;
         wavelet_level_selection_lf = findHighpassLvl(0.25,freq) - 5;
     case 1000
         wavelet_level_selection = 2;
         % wavelet_level_selection_lf = 6;
         wavelet_level_selection_lf = findHighpassLvl(0.25,freq) - 5;
     otherwise
         wavelet_level_selection = 1;
         % wavelet_level_selection_lf = 5;
         wavelet_level_selection_lf = findHighpassLvl(0.25,freq) - 5;
 end
 
end
 
