%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% loop_rotation_dir.m -- Calculates signed area to determine if loop is CW or CCW
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


function [direction, signed_area] = loop_rotation_dir(x, y, z, normal, horizontal, vertical, threshold)

% Calculates the signed area for a set of points x , y, and z by
% projecting them into the plane defined by normal vector (normal).  The
% orientation of the coordinate system is defined by horizontal and
% vertical unit vectors that are passed into the function.

% The normal direction is the direction that the plane perpendiculat to the
% normal is being viewed FROM.

% Coordinate system uses +X [1 0 0] towards the left, +Y [0 -1 0] towards
% the feet, and +Z [0 0 1] posteriorly.  The handedness of the coordinate
% system affects the direction of rotation.

% normal = [-1 0 0];       % Direction viewing from.  e.g. if viewing from the feet use [0 -1 0].  If viewing from front use [0 0 -1]
% horizontal = [0 0 -1];   % Horizontal axis.  set orientation.  e.g. to set X towards left use [1 0 0], to set X towards right use [-1 0 0]
% vertical = [0 -1 0];     % Vertical axis.  set orientation.  e.g. to set Y down use [0 -1 0]

for i = 1:length(x)
    q = [x(i) y(i) z(i)];
    p2(i,:) = q - dot(q, normal) * normal;
end

% Preallocate
newX = zeros(1,length(x));
newY = zeros(1,length(x));

for i = 1:length(x)
    P = [p2(i,1), p2(i,2), p2(i,3)];
    newX(i) = dot(P, horizontal);     
    newY(i) = dot(P, vertical);
end

N = length(newX);

% Calculate signed area using Shoelace formula
    area = 0;
    
    for i = 1:N-1
        area = area + (newX(i)*newY(i+1) - newX(i+1)*newY(i));
    end
    
    % Close the loop
    area = area + (newX(N)*newY(1) - newX(1)*newY(N));
    
    signed_area = area / 2;

% Assign CW or CCW
% Positive angles are CCW
% Negative angles are CW

% Set threshold below which CW/CCW is indeterminant.  If signed area is
% very small then its hard to say which way it actually is rotating
% Nominal threshold = 0.1

if signed_area > 0 && abs(signed_area) > threshold
    direction = 'CCW';
elseif signed_area < 0  && abs(signed_area) > threshold
    direction = 'CW';
else
    direction = 'Indeterminate';
end