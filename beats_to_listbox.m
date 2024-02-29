%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% beats_to_listbox.m -- Part of BRAVEHEART GUI
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


% Takes annotation output and formats for listbox in GUI

function listbox_beats = beats_to_listbox(qon, rpeak, qoff, toff)

% pull qon_out each beat into a new row in matrx "beat" for display in listbox

beat_dim = max([length(qon) length(rpeak) length(qoff) length(toff)]); %account for differences in number of fiducual points if some QRST cut off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add padding if number of all fiducial points not same (due to cut off)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

beats = zeros(beat_dim,4);

for i = 1:length(qon)
   beats(i,1) = qon(i);
    
end


for i = 1:length(rpeak)
   beats(i,2) = rpeak(i);
    
end


for i = 1:length(qoff)
   beats(i,3) = qoff(i);
    
end


for i = 1:length(toff)
   beats(i,4) = toff(i);
    
end



listbox_beats = num2str(beats);



