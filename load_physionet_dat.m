%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_physionet_dat.m -- Load Physionet .dat files using information from .hea files
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = ...
    load_physionet_dat(filename)

% Need to have the .dat and .hea files with same basename in the same
% directory of the load will not work.  There are no default values if the
% .hea file is missing

[fdir,fname,~] = fileparts(filename);

if ~isfile(strcat(fullfile(fdir,fname),'.hea'))
    error("Physionet format header (.hea) file not found in same directory as .dat file")
end

% Read header file
H = readmatrix(strcat(fullfile(fdir,fname),'.hea'),'FileType','text','OutputType','string','Range', 1, "Delimiter"," ");

% Extract number of leads and assert is a 12L ECG (or 8 leads)
num_leads = str2double(H{1,2});
assert(num_leads == 12 | num_leads == 8, "Not a 12-lead or 8-lead Physionet ECG based on .hea file");

% Extract sampling frequency
hz = str2double(H{1,3});

% Extract signal length
sig_length = str2double(H{1,4});

% Remove any comments
while size(H,1) > num_leads + 1
    H(num_leads + 2,:) = [];
end

% find where text is in the header for lead names
[ru,cu] = find(ismember(H,'I'));
[rl,cl] = find(ismember(H,'i'));

% Deal with upper/lower case labeling
if isempty(rl)
    row = ru;
    col = cu(1);
else
    row = rl;
    col = cl(1);
end

Hcol = size(H,2);

if Hcol > col
    H(:,[col+1:Hcol]) = [];
end

leads = H(2:num_leads + 1,col);
leads = upper(leads);

% Pre-allocation
format_array = zeros(1,num_leads);
units_str = cell(1,num_leads);
units = cell(1,num_leads);
zero = zeros(1,num_leads);
unitspermv = zeros(1,num_leads);

% Encoding format
for i = 2:1 + num_leads
    format_array(i-1) = str2double(H{i,2});
end
format = format_array(1);
assert(length(unique(format_array)) == 1, "Encoding format not consistent throughout file")


% Signal units per mV
for i = 2:1 + num_leads
   units_str{i-1} = H{i,3};
end

units_str = string(units_str);

% Deal with variable gain and variable baseline for each lead
for i = 1:num_leads
    tmp = char(units_str(i));

    units{i} = tmp(isstrprop(tmp,'alpha'));
    
    % Zero value
    z = regexp(units_str(i), '(?<=\()[^)]*(?=\))', 'match', 'once');
    if ~ismissing(z)
        zero(i) = str2double(z);
    else
        zero(i) = 0;
    end

    % Units per mv    
    parens_loc = strfind(tmp,'(');
    if ~isempty(parens_loc)
        unitspermv(i) = str2double(tmp(1:parens_loc-1));
    else
        unitspermv(i) = str2double(tmp(isstrprop(tmp,'digit')));
    end

end

% Make sure all leads have same units -- have not seen this be an issue yet
assert(length(unique(units)) == 1, "Units not consistent throughout file")



% Open binary .dat file
fid=fopen(strcat(fullfile(fdir,fname),'.dat'),'r');

% Switch encoding based on format code
% All 12-lead ECGs so far seem to be format 16
% but including other options for completeness.
% HAVE NOT FORMALLY TESTED ANYTHING OHTER THAN FORMAT 16!
switch format
    case 16
        f=fread(fid,'int16','l');
    case 24
        f=fread(fid,'int24','l');
    case 32 
        f=fread(fid,'int32','l');
    case 61
        f=fread(fid,'int16','b');
    otherwise
        error("Physionet format code not understood")
end

for j = 1:num_leads
    for i = 1:length(f)/num_leads
        E_raw.(leads(j))(i) = f(j+(12*(i-1)));
    end

    % Correct for zero voltage
    E.(leads(j)) = E_raw.(leads(j)) - zero(j);
    
    % Convert to physiological units (mv)
    E.(leads(j)) = E.(leads(j)) ./ unitspermv(j);
end



% Account for possiblity that only get 8 independent leads
if isempty(E.III)
    E.III = -E.I + E.II;
end

if isempty(E.AVR)
    E.AVR = -0.5*E.I - 0.5*E.II;
end

if isempty(E.AVF)
    E.AVF = E.II - 0.5*E.I;
end

if isempty(E.AVL)
    E.AVL = E.I - 0.5*E.II;
end


% Check that are not mising any leads

if isempty(E.I) || isempty(E.II) || isempty(E.III) || ...
   isempty(E.AVR) || isempty(E.AVL) || isempty(E.AVF) || ...
   isempty(E.V1) || isempty(E.V2) || isempty(E.V3) || ...
   isempty(E.V4) || isempty(E.V5) || isempty(E.V6) 

   error('Missing one or more leads from .dat file');

end

% Check signal length is correct
assert(sig_length == length(E.I), "Signal legnth does not match header file");

% Lead output
I = E.I;
II = E.II;
III = E.III;
avR = E.AVR;
avF = E.AVF;
avL = E.AVL;
V1 = E.V1;
V2 = E.V2;
V3 = E.V3;
V4 = E.V4;
V5 = E.V5;
V6 = E.V6;

