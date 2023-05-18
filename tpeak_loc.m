%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% tpeak_loc.m -- Find parts of the T wave
% Copyright 2016-2023 Hans F. Stabenau and Jonathan W. Waks
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

function [tpeak_time, tpeak_tend_abs_diff, tpeak_tend_ratio, tpeak_tend_jt_ratio ] = tpeak_loc(fidpts, sample_time)

% set sample time to 1 to deal with other issues that come up
sample_time = 1;

% Outputs in SAMPLES

qrs_off = fidpts.S;
t_off = fidpts.Tend;

qt_interval = (fidpts.Tend - fidpts.Q) * sample_time;

tpeak_time = (fidpts.T - fidpts.Q) * sample_time;       % Have to subtract Qon to avoid getting tpqt > 1 since QT interval is relative but T peak is absolute

tpeak_tend_abs_diff = qt_interval - tpeak_time;

tpeak_tend_ratio = tpeak_time / qt_interval;

jt_interval = qt_interval - ((qrs_off-1) * sample_time);

tpeak_tend_jt_ratio = (tpeak_time - ((qrs_off-1) * sample_time)) / jt_interval;


