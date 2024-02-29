%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% waveStart2.m -- Part of fiducial point location algorithm
% Copyright 2016-2024 Hans F. Stabenau and Jonathan W. Waks
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

function on = waveStart2(fsprime, pk, startw, endw)
    % on = waveStart2(fsprime, pk, startw, endw)
    % Find the start of an ECG wave which has its peak at pk
    % fsprime is derivative of the EKG signal
    % look btw startw and endw
    % Finds the wave end using a derivative threshold
    on = []; dmax = [];
    % max derivative
    dmax = max(abs(fsprime(startw:pk)));
    
    % start looking at the local dmax
    [~, x] = max(abs(fsprime(startw:endw)));
    x = x + startw - 1;
    
    k=50;
    while ~any(on) && k > 1.25
        on = find(abs(fsprime(startw:x))/dmax < 1/k, 1, 'last') + startw-1;
        k=k/2;
    end

end
