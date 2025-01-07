%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% shift_xyz.m -- Shifts midpoint of VCG loop
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

% Shifts midpoint of VCG loop to Origin (0,0,0)

function [X_mid, Y_mid, Z_mid, x, y, z, x_orig, y_orig, z_orig, x_shift, y_shift, z_shift] = shift_xyz(x, y, z, origin_flag)

% Midpoints

if strcmp(origin_flag,'Avg');  % uses the midpoint between QRS onset and Tend as the origin
    X_mid = (x(1)+x(end))/2;
    Y_mid = (y(1)+y(end))/2;
    Z_mid = (z(1)+z(end))/2;
end

if strcmp(origin_flag,'Tend');  % uses Tend as the origin (useful if pacing spike or other issues with QRS onset
    X_mid = x(end);
    Y_mid = y(end);
    Z_mid = z(end);
end

if strcmp(origin_flag,'zero_origin'); % uses 0,0,0 as origin
    X_mid = 0;
    Y_mid = 0;
    Z_mid = 0;
end


% Midpoints will be shifted to origin (0,0,0) - could modify for any other
% point if needed for some other reason
new_orig_x = 0;
new_orig_y = 0;
new_orig_z = 0;


% Translate VCG to midpoint which will be the "origin" at (0,0,0)
x_shift = X_mid - new_orig_x;
y_shift = Y_mid - new_orig_y;
z_shift = Z_mid - new_orig_z;


% save original x, y, x
x_orig = x;
y_orig = y;
z_orig = z;


x=x-x_shift;
y=y-y_shift;
z=z-z_shift;
