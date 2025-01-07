%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% deriv2nd5.m -- Compute 5-point stencil 2nd derivative of f
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

function der = deriv5(f, what)
% deriv5(f, what): compute 5-point stencil derivative of f
% Approximate derivative using the form
% f' ~ ay[k - 2] + by[k - 1] + cy[k]+ dy[k + 1] + gy[k + 2]
%    ~ ay[k-2] + by[k-1] - by[k+1] - ay[k+2]
% what=t or p sets coeffs
% see Discrete derivative estimation in LISA Pathfinder data reduction
% Class. Quantum Grav. 26 (2009) 094013 for a derivation
    if strcmpi(what(1), 't')
        a=1/12;
    elseif strcmpi(what(1), 'p')
        a=-1/5;
    else
        error('Deriv5: expecting "t" or "p" for taylor or parabolic fit, got "%s"\n', what)
    end
    
    b=-1/2-a;
    N = numel(f);
    % 3:N-2
    d = a*(f(1:N-4) - f(5:N)) + b*(f(2:N-3) - f(4:N-1));
    der = zeros(N,1);
    der(1:2) = NaN;
    der(3:end-2) = d;
    der(end-1:end) = NaN;
end

            