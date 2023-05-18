%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% findT.m -- Find T Wave peak
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

function [T, off] = findT(fs, fsprime, fspp, baseline, startw, endw, debug)
    % findT(fs, fsprime, fspp, baseline, startw, endw)
    % find peak, offset of T wave    
    
    % Assumes that we are using the VM, i.e., that the T-wave will be the
    % point with the highest *positive* deflection.
    
        
    T=[]; off=[];
        
    x = (startw:endw)';
    fsc = fs(x) - baseline(x);
    
    [~, peaks] = findpeaks(fsc, 'sortStr', 'descend'); %, 'MinPeakDistance', Twidth/2);
        
    Tpeak1 = peaks(1) + startw-1;
    conc1 = sign(fspp(Tpeak1));

    if debug; text(Tpeak1, fs(Tpeak1), 'T'); end
    
    T = Tpeak1;
    
    if ~isempty(fsprime)
        off = waveEnd(fsprime, T, endw);
    end
        
        

end