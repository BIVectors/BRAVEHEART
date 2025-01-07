%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% min_max_locs.m -- Find maximum and minimum speed values and locations
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

function [Max, Min, median_val] = min_max_locs(S, start, stop, B, hz)

% S = signal
% start = sample where start looking at signal
% stop = sample where stop looking at signal
% B = blanking period
% hz = sampling frequency
% 
% figure
% plot(S(start+B:stop))

[max_val, max_I_shift] = max(S(start+B:stop));
[min_val, min_I_shift] = min(S(start+B:stop));

max_loc_samp = max_I_shift + start - 1 + B;
min_loc_samp = min_I_shift + start - 1 + B;

% MATLAB starts indexing at 1, so to get time from start of 
% signal need to subtract 1
max_loc_time2 = (max_loc_samp - 1) * 1000 / hz;
min_loc_time2 = (min_loc_samp - 1) * 1000 / hz;

% Since each speed value is for a segment between samples S1 and S2, we
% will take the average of S2 and S1 (which is S2-1 sample)

max_loc_time1 = (max_loc_samp - 2) * 1000 / hz;
min_loc_time1 = (min_loc_samp - 2) * 1000 / hz;

max_loc_time = mean([max_loc_time2 max_loc_time1]);
min_loc_time = mean([min_loc_time2 min_loc_time1]);

% Median value
median_val = median(S(start+B:stop),'omitnan');


% Set up output in structures given multiple output variables
Max = struct;
Max.val = max_val;
Max.loc_samp = max_loc_samp;
Max.loc_samp_st = max_loc_samp - 1;
Max.loc_time = max_loc_time;
Max.loc_time1 = max_loc_time1;
Max.loc_time2 = max_loc_time2;

Min = struct;
Min.val = min_val;
Min.loc_samp = min_loc_samp;
Min.loc_samp_st = min_loc_samp - 1;
Min.loc_time = min_loc_time;
Min.loc_time1 = min_loc_time1;
Min.loc_time2 = min_loc_time2;
