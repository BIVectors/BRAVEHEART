%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% mean_vector_leadmorph.m -- Find mean vectors for lead morphology
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


% calcualte mean vector/area under median ECG lead

function [QRS_area, T_area] = mean_vector_leadmorph(x, sample_time, fidpts, baseline_flag)

q = fidpts(1);
s = fidpts(3);
t = fidpts(4);

if strcmp(baseline_flag,'zero_baseline') % zero baseline reference
end


if strcmp(baseline_flag,'Tend')  % Tend is zero reference
x = x-x(end);
end
   
    
if strcmp(baseline_flag,'Qon')  % QRS onset is zero reference
x = x-x(1);
end


if strcmp(baseline_flag,'Avg')  % Midpoint between QRS on and Tend is zero reference
x = x - ((x(1)+x(end))/2);
end

if ~isempty(x)
    QRS_area = sample_time*trapz(x(q:s));
    T_area = sample_time*trapz(x(s:t));
else
    QRS_area = [];
    T_area = [];
end
