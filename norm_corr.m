%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% norm_corr.m -- Calculate normalized cross correlation
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


function norm_corr_value = norm_corr(a,b)

if isempty(a) | isempty(b)
   norm_corr_value = nan;
   return
end

if isnan(a) | isnan(b)
   norm_corr_value = nan;
   return
end

% accounts for signals of different lengths.  
% Since the beats will be aligned by R peaks and we care more about the QRS
% morphology than the entire QRST morphology, its okay if the signals are
% of different lengths.  Rather than pad with 0s will just compare the
% signals for the window of the smaller signal

% removes end of a if a longer than b
if length(a) > length(b)
   for i = length(b)+1:length(a)
      a(end)=[]; 
   end
   
% removes end of b if b longer than a
elseif length(a) < length(b)
   for i = length(a)+1:length(b)
      b(end)=[]; 
   end
   
% if a and b are same length just compares a and b 
else


end


% cut out nans for comparison but keep signal lengths the same
% this should only be an issue for first and last beat

if isnan(a(1))
    num_nans = sum(isnan(a));
    % then cut begining of b
    b(1:num_nans) = [];
    a(1:num_nans) = [];
    
end

if isnan(a(end))
    num_nans = sum(isnan(a));
    % then cut end of b
    b(end-num_nans:end) = [];
    a(end-num_nans:end) = [];
    
end

if isnan(b(1))
    num_nans = sum(isnan(b));
    % then cut begining of a
    b(1:num_nans) = [];
    a(1:num_nans) = [];
    
end

if isnan(b(end))
    num_nans = sum(isnan(b));
    % then cut end of b
    b(end-num_nans:end) = [];
    a(end-num_nans:end) = [];
    
end


% normalized correlation between signal a and b
norm_corr_value = sum(a.*b)/(sqrt(sum(a.^2).*sum(b.^2)));