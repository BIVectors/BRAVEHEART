%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% waveStartPk.m -- Part of fiducial point location algorithm
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

function on = waveStartPk(fs, fspp, startw, pk)
    % on = waveStartPk(fs, fspp, startw, pk)
    % Find the start of an ECG wave which has its peak at pk
    % fspp is 2nd derivative of the EKG signal
    % look btw startw and pk
    % Finds the wave end by searching for a peak with opposite sense
    
    on = [];
    x = (startw:pk)';
    if isempty(x); return; end
    
    conc = sign(fspp(pk));
    try
        [~, pc] = findpeaks(conc*fs(x));
    catch
        return;
    end
    if any(pc)
        on = pc(end) + startw-1;
    end
    
end
