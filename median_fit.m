%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% median_fit.m -- Calculate cross correlation for beats
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

function  correlation_test  = median_fit(median_matrix, fidpts)

%%% INPUT
% median_matrix = matrix of all individual beats for use in creating

N = min(size(median_matrix.X));  % number of beats

%median_matrix(isnan(median_matrix))=0; % replace NaN with 0 to avoid errors

correlation_test =  struct;

lead_names = [{'X'} {'Y'} {'Z'}];

for a = 1:3
matrix = median_matrix.(lead_names{a});

% if N = 1 check to make sure is a row matrix
if N == 1
   if ~isrow(matrix)
       matrix = matrix';
   end
end
    

norm_corr_matrix = zeros(N);  % empty NxN matrix for storing normalized correlations between beats

% Break and assign cross corr = NaN if cant find fiducial points
if isnan(fidpts.Tend) | isnan(fidpts.Q) | isnan(fidpts.S)
    correlation_test.X = nan;
    correlation_test.Y = nan;
    correlation_test.Z = nan;
    return;
end


for i=1:N
    for j = i:N      
        beat1 = matrix(i,:);
        beat2 = matrix(j,:);  
       
        beat1 = beat1(fidpts.Q:fidpts.Tend);
        beat2 = beat2(fidpts.Q:fidpts.Tend);        
      
        norm_corr_matrix(i,j) = norm_corr(beat1,beat2);  % perform normalized cross correlation   
       
    end    
end

tot = 0;
for c = 1:N-1
   tot = tot + c;
end

if N > 1
correlation_test.(lead_names{a}) = round(((sum(norm_corr_matrix(:)) - N) / tot),3);
else
correlation_test.(lead_names{a}) = nan;    
end

end

