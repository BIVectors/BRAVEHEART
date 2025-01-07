%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% baseline_voltage.m -- Calculate baseline voltage at the end of the T wave for quality metrics 
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

function baseline = baseline_voltage(med_vcg, medianbeat)

% Calculates the baseline voltage at the end of the T wave primarily for
% quality metrics.

% Look at 30 ms after the end of the T wave
d = 30;
extra = round(d * med_vcg.hz/1000);     % Round to deal with random freq like 997 Hz

% How many samples are left after T end
leftover = length(med_vcg.VM) - medianbeat.Tend;

if leftover >= extra
    baseline = median(med_vcg.VM(medianbeat.Tend+1:medianbeat.Tend+extra)); 
else
% if less than 30 ms at the end of the signal, take to end
    baseline = median(med_vcg.VM(medianbeat.Tend+1:end)); 
end


