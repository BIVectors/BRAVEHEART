%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% mean_vector.m -- Find mean vector points
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

function [XQ_mean, XT_mean, YQ_mean, YT_mean, ZQ_mean, ZT_mean] = mean_vector(x, y, z, sample_time, qend, baseline_flag)

if strcmp(baseline_flag,'zero_baseline'); % zero baseline reference
end


if strcmp(baseline_flag,'Tend');  % Tend is zero reference
x = x-x(end);
y = y-y(end);
z = z-z(end);
end
   
    
if strcmp(baseline_flag,'Qon');  % QRS onset is zero reference
x = x-x(1);
y = y-y(1);
z = z-z(1);
end


if strcmp(baseline_flag,'Avg');  % Midpoint between QRS on and Tend is zero reference
x = x - ((x(1)+x(end))/2);
y = y - ((y(1)+y(end))/2);
z = z - ((z(1)+z(end))/2);
end

if ~isempty(x)
    XQ_mean = sample_time*trapz(x(1:qend));
    XT_mean = sample_time*trapz(x(qend:end));
else
    XQ_mean = [];
    XT_mean = [];
end

if ~isempty(y)
    YQ_mean = sample_time*trapz(y(1:qend));
    YT_mean = sample_time*trapz(y(qend:end));
else
    YQ_mean = [];
    YT_mean = [];
end

if ~isempty(z)
    ZQ_mean = sample_time*trapz(z(1:qend));
    ZT_mean = sample_time*trapz(z(qend:end));
else
    ZQ_mean = [];
    ZT_mean = [];
end