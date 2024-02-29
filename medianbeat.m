%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% medianbeat.m -- Create median beat
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


function [medbeat, beatsig] = medianbeat(signal, startb, endb)
% given a signal and the locations of the start and end of each beat
% compute a median beat
% there is some subtlety to how beats near the beginning and end of the ECG are handled

len = numel(signal);
M = max(endb-startb) + 1;
N=numel(startb);
beatsig = zeros(N,M);

for i=1:N
    if endb(i) > len
        siglen = len-startb(i) + 1;
        beatsig(i,1:siglen) = signal(startb(i):len);
        beatsig(i,siglen+1:M) = NaN;
    elseif startb(i) < 1
        siglen = 1-startb(i);
        beatsig(i,1:siglen) = NaN;
        beatsig(i,siglen+1:M) = signal(1:endb(i));
    else
        beatsig(i,:) = signal(startb(i):endb(i));
    end
end

if N>1
medbeat = median(beatsig, 'omitnan');
end

if N==1
medbeat = beatsig;
end

end
