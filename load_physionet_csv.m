%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_physionet_csv.m -- Load Physionet .csv format ECGs
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_physionet_csv(filename)

% Note: although the overall structure of Physionet format .csv files is
% consistent for different databases, there are some variations in lead labeling
% and date/time formats that are present.  It it possible that this
% function will need modification for some databases.

% Read in .csv into Table
T = readtable(filename,'VariableNamingRule','preserve',"VariableUnitsLine",2);

% Have to get rid of extra single quotes in units
units = regexprep(T.Properties.VariableUnits,'[\'']*','');
T.Properties.VariableUnits = units;

% Have to get rid of extra spaces and single quotes in variable names
% Also convert variable/lead names to lowercase
new_col_names = regexprep(T.Properties.VariableNames,'[\'']*','');
new_col_names = regexprep(new_col_names,'\s*','');
new_col_names = lower(new_col_names);
T.Properties.VariableNames = new_col_names;

% Figure out Hz by looking at number of samples and the time duration 
% Use Regex to format the date/time strings (lots of variations)
time = string(T.(T.Properties.VariableNames{1}));
time = regexprep(time,'[\'']*','');
time = regexprep(time,'[*','');
time = regexprep(time,']*','');

% Date/time can be formatted differently
if length(char(time(1))) == 8       
    time = datetime(time, 'Format', "m:ss.SSSS");
elseif length(char(time(1))) == 23 
    time = datetime(time, 'Format', "HH:mm:ss.SSSS dd/MM/y");
end

% Calc Hz as number of samples per second
hz = round((length(T.i)-1) / double(second(time(end))));

% Generate table summary to pull out units from a structure
S = summary(T);

% Find gain based on units
gain_str = unique([{S.i.Units} {S.ii.Units} {S.v1.Units} {S.v2.Units} {S.v3.Units} {S.v4.Units} {S.v5.Units} {S.v6.Units}]);
assert(numel(gain_str) == 1)        % Assert only 1 unit for all leads

switch char(gain_str)
    case 'mV'
        gain = 1;
    case 'uV'
        gain = 1/1000;
    otherwise
        error('Unknown units for Physionet .csv ECG')
end

% Iterate through leads
I = T.i * gain;
II = T.ii * gain;
V1 = T.v1 * gain;
V2 = T.v2 * gain;
V3 = T.v3 * gain;
V4 = T.v4 * gain;
V5 = T.v5 * gain;
V6 = T.v6 * gain;

% Deal with the 4 other limb leads that may or may not have been provided
% in the file, and calculate if not provided
if isfield(T,'iii')
    III = T.iii * gain;
else
    III = -I + II;
end

if isfield(T,'avr')
    avR = T.avr * gain;
else
    avR = -0.5*I - 0.5*II;
end

if isfield(T,'avf')
    avF = T.avf * gain;
else
    avF = II - 0.5*I;
end

if isfield(T,'avl')
    avL = T.avl * gain;
else
    avL = I - 0.5*II;
end

