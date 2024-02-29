%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% missing_leads.m -- Determine if a lead is missing
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


function [missing_lead, which_leads] = missing_leads(ecg, maxbpm, pkthresh)

fn_ecg = fieldnames(ecg);
shift = 2;       % Location where ecg signals actually start in the class

for i = 1:12
    v(i) = var(ecg.(fn_ecg{i+shift}));
end

% Variance is basically 0 if lead missing. (order of 10^-24)

% This wont pick up if a lead is off for PART of the ECG, but this should
% be picked up with PVC/outlier detection and is something that will work
% on in the future.

which_leads = find(v < 0.00001);

if ~isempty(which_leads)
    missing_lead = 1;
else
    missing_lead = 0;
end


