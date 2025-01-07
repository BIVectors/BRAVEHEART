%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% max_vector.m -- Find peak vector points
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

% Find peak vector points of median lead

function [XQ_max, YQ_max, ZQ_max, XT_max, YT_max, ZT_max] = max_vector(x, y, z, xorig, yorig, zorig, sample_time, qend)

dist =  sqrt((x-xorig).^2 + (y-yorig).^2 + (z-zorig).^2);

[~,maxQRS_index] = max(dist(1:qend));
XQ_max = x(maxQRS_index);
YQ_max = y(maxQRS_index);
ZQ_max = z(maxQRS_index);

[~,maxT_index] = max(dist(qend+1:end));
maxT_index = maxT_index + qend;
XT_max = x(maxT_index);
YT_max = y(maxT_index);
ZT_max = z(maxT_index);