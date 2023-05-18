%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% ecg_source_string.m -- Part of BRAVEHEART GUI - links source format to string
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

function [source_str, source_ext, source_freq] = ecg_source_string(format, ecg_hash)

% This function can be used to source_str and source_ext
% based on the ECG format text from GUI dropdown

% If format is source_str already, it will give u the format

% It does this by looking in which column the result is found:

% Col 1 contains GUI strings from dropdown - in this case will get
% source_str and source_ext by looking up cols 2 and 3 of the same row

% Col 2 contains the source_str, so if you match on a source_str will 
% assume you want the source_ext for batch 

[r,c] = find(strcmp(format, ecg_hash));

switch c
    case 1  % input GUI dropdown string
        source_str = char(ecg_hash(r,2));
        source_ext = char(ecg_hash(r,3));  
        source_freq = cell2mat(ecg_hash(r,4));
    case 2
        source_str = [];
        source_ext = char(ecg_hash(r,3));
        source_freq = cell2mat(ecg_hash(r,4));
    otherwise
        % Do nothing   
end

end