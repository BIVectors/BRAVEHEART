%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% plane_svd.m -- Calculates SVD on a VCG loop
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


function [N, A, B, C, residual, rmse, var_s1_total, var_s2_total, var_s3_total, S1, S2, S3, V, roundness, newPX, newPY, PS, ps_area, ps_length] = plane_svd(x, y, z, fig)

% Disable warning for polyshape
warning('off','MATLAB:polyshape:repairedBySimplify')

% Calculate the centroid/mean of each coordinate
cent=[mean(x),mean(y),mean(z)];

% Subtract out the centroid
XYZ = [x-cent(1),y-cent(2),z-cent(3)];

% SVD
[U,S,V]=svd(XYZ);
s = svd(XYZ);   % simplifies storage of singular values

% Normal vector to the best fit plane is given by V(:3)
% Have N = [a b c] = V(:,3)
% Want to get A B C such that Ax + By + z = C, or alternatively
% z = Ax + By + C

% Since we are rearranging the general plane form Ax + By + z = C to
% z = Ax + By + C, the compontants of the normal vector N are NOT the
% coefficients and we have to arrange things a bit... 
% http://citadel.sjfc.edu/faculty/kgreen/vector/Block1/plane/node6.html
% A = -a/c
% B = -b/c
% C = (N dot cent)/c

% Normal vector and componants N = [a,b,c]
N = V(:,3);
a = N(1);
b = N(2);
c = N(3);

% Transform to the cartesian coordinates since we rearranged the equation
A = -a/c;
B = -b/c;
C = cent*N/c;

% residual of the Z componant gives an idea of how good the fit is to the
% plane; 0 is perfect fit on plane.
% Decided to square it to make more like variance
residual = S(3,3)^2;

% Singular values:
S1 = s(1);
S2 = s(2);
S3 = s(3);

% Variance is equal to the singular values squared
% Present it as a % of total variance like with PCA
va = s.^2;
variance = 100 * va / sum(va);

var_s1_total = variance(1);
var_s2_total = variance(2);
var_s3_total = variance(3);

roundness = max(s)/median(s);   % 2 largest componants, assuming Z will be relatively small
if s(3) > min(s)
   display "Loop orientation highly non-planar";
   roundness = nan;
end


if fig
    figure
    hold on
    %scatter3(x,y,z,80,'filled')
    [X,Y]=meshgrid(linspace(-max([abs(max(x)) abs(min(x))]), max([abs(max(x)) abs(min(x))]),20), linspace(-max([abs(max(y)) abs(min(y))]), max([abs(max(y)) abs(min(y))]),20));
    Z=(A*X)+(B*Y)+C;
    plot3(x,y,z,'r.','markersize',20); hold on; grid on;
    xlabel('x')
    ylabel('y')
    zlabel('z')
    surf(X,Y,Z,'FaceColor','g'); alpha(0.1);
    scatter3(a,b,c, 20, 'r','filled')
    scatter3(a,b,c, 20, 'b','filled')
    line([0 a],[0 b],[0 c], 'linewidth',3)
    
    line([0 V(1,1)], [0 V(2,1)], [0 V(3,1)], 'linewidth',2,'color','r')
    line([0 V(1,2)], [0 V(2,2)], [0 V(3,2)], 'linewidth',2,'color','g')
    line([0 V(1,3)], [0 V(2,3)], [0 V(3,3)], 'linewidth',2,'color','b')
    
    set(gca,'DataAspectRatio',[1 1 1])
end



% Project points onto the best fit plane
n = V(:,3)';
for i = 1:length(x)
    q = [x(i) y(i) z(i)];
    q_proj(i,:) = q - dot(q - cent, n) * n;
end


% RMSE
dist = sqrt((x-q_proj(:,1)).^2 + (y-q_proj(:,2)).^2 + (z-q_proj(:,3)).^2);
rmse = sqrt(mean(dist.^2));

% Project the area of the projected points onto the basis vectors generated
% by SVD; the vectors which are parallel to the plane and orthogonal to
% eachother = V(:,1) and V(:,2)
for i = 1:length(x)
    P = [q_proj(i,1), q_proj(i,2), q_proj(i,3)];
    newPX(i,:) = dot(P, V(:,1));     
    newPY(i,:) = dot(P, V(:,2));
end

% Create polyshape of the area projected onto the new basis
PS = polyshape(newPX, newPY);

ps_area = area(PS);
ps_length = perimeter(PS);

if fig
    plot(newPX, newPY);
    plot(PS);
    scatter3(q_proj(:,1),q_proj(:,2),q_proj(:,3),'filled','MarkerEdgeColor','k','MarkerFaceColor','k') 
    scatter3(newPX, newPY, zeros(length(newPX),1))
end