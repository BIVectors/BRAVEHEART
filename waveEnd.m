%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% waveEnd.m -- Part of fiducial point location algorithm
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


function off = waveEnd(fsprime, pk, endw)
    % off = waveEnd(fsprime, pk, endw, type)
    % Find the end of an ECG wave which has its peak at pk
    % use % of max deriv
    % fsprime is derivative of the EKG signal
    % look btw pk and endw
    % Finds the wave end using a derivative threshold
    % the threshold depends on the max slope and the type of wave a la Laguna 1994
    % type can be 'P', 'T', 'S', 'R'

    %[d, x] = max(abs(fsprime(pk:endw)));
    off = []; dmax = []; xmax = [];
    % max derivative
    [dmax, xmax] = max(abs(fsprime(pk:endw)));
    x = xmax + pk-1;        
    
    k=50;
    while ~any(off) && k > 1.25
        off =find(abs(fsprime(x:endw))/dmax < 1/k, 1) + x-1;
        k=k/2;
    end
    
end
