%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_wfdb_dat.m -- Load Physionet/WFDB .dat files using information from .hea files
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
    load_wfdb_dat(filename)

% Declare variables in structure E
E = struct;
E.I = []; E.II = []; E.III = []; E.AVR = []; E.AVL = []; E.AVF = [];
E.V1 = [];E.V2 = []; E.V3 = []; E.V4 = []; E.V5 = []; E.V6 = [];

% Need to have the .dat and .hea files with same basename in the same
% directory of the load will not work.  There are no default values if the
% .hea file is missing
[fdir,fname,~] = fileparts(filename);

if ~isfile(strcat(fullfile(fdir,fname),'.hea'))
    error("Physionet format header (.hea) file not found in same directory as .dat file")
end

% Read header file
H = readmatrix(strcat(fullfile(fdir,fname),'.hea'),'FileType','text','OutputType','string','Range', 1, "Delimiter"," ");

% See https://physionet.org/physiotools/wag/header-5.htm
% First line of header (Record line) contains up to 6 cols:
% 1) record_name, 2) number of signals, 3) fs, 4) signal length, 5) base time, 6) base date in sequential columns
% Only record_name and number of signals are REQUIRED to be present
% each optional field can only be present if the one to its left is also present
% if fs is not present it defaults to 250 Hz
% Cols 3 - 6 (fs, signal length, base time, base date) are OPTIONAL
% This file ignores multi segment files or counter frequency/base counter
% value as these are very unlikely to show up in ECG files
% This file only extracts number of signals, fs, and signal length

% Extract number of leads (col 2) and assert there are at least 8 leads
num_leads = str2double(H{1,2});
assert(num_leads >= 8 , "Does not contain at least an 8-lead Physionet/WFDB ECG based on .hea file");

% Baseline fs (col 3) = 250 Hz if not specified per WFDB specifications
hz = 250;

% Signal legnth (col 4) is optional
sig_length = NaN;

% Extract fs (col 3) if present
if size(H,2) >= 3 && ~ismissing(H(1,3))
    hz = str2double(H{1,3});
end

% Extract signal length if present
if size(H,2) >= 4 && ~ismissing(H(1,4))
    sig_length = str2double(H{1,4});
end

% Remove any comments
while size(H,1) > num_leads + 1
    H(num_leads + 2,:) = [];
end

% For signal specific lines the order is:
% 1) filename, 2) format, 3) gain information, 4) ADC resolution, 5) byte offset, 6) initial ADC value, 7) checksum, 8) block size, 9) signal name
% Gain information includes a string in the format of gain(zero)/units
% We do not need block size (col 7) or ADC resolution (col 4)
% In practice, all 12-lead ECG files will need to have the leads labeled, so should all have 9 columns

% Pre-allocation
format_array = zeros(1,num_leads);      % Storage format of signal
units_str = cell(1,num_leads);          % ADC gain(ADC zero)/units string to parse out
units = cell(1,num_leads);              % Units 
zero = zeros(1,num_leads);              % ADC zero value
unitspermv = zeros(1,num_leads);        % ADC gain = ADC units per mV
byte_offset = zeros(1,num_leads);       % Byte offset (for reading .dat files)
init_value = zeros(1, num_leads);       % First ADC value of each lead
checksum = zeros(1, num_leads);         % Checksum for each lead
leads = strings(1, num_leads);          % Lead names
dat_files = strings(1,num_leads);        % Name of linked .dat file (for multiple .dat files per .hea file)

% Parse the signal specific lines
for i = 2:1 + num_leads
    dat_files(i-1) = H{i,1};                    % .dat file that contains the signal
    format_array(i-1) = str2double(H{i,2});     % Storage format
    units_str{i-1} = H{i,3};                    % Gain information (to be further parsed)
    byte_offset(i-1) = str2double(H{i,5});      % Byte offset
    init_value(i-1) = str2double(H{i,6});       % Initial ADC value
    checksum(i-1) = str2double(H{i,7});         % Checksum
    leads(i-1) = upper(H{i,9});                 % Lead name
end

% Make sure single format for all leads
format = format_array(1);
assert(length(unique(format_array)) == 1, "Encoding format not consistent throughout file")

% Make sure byte offset is 0.  Other values are not currently supported.
assert(length(unique(byte_offset)) == 1, "Variable byte offsets not supported in this version of load_physionet_dat.m");
assert(byte_offset(1) == 0, "Nonzero byte offset not supported in this version of load_physionet_dat.m");

% Make sure only a single .dat file contains the data
assert(length(unique(dat_files)) == 1, "Multiple .dat files not supported in this version of load_physionet_dat.m");

% Parse out the gain information
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open binary .dat file
fid=fopen(strcat(fullfile(fdir,fname),'.dat'),'r');

% Switch encoding based on format code
% All 12-lead ECGs so far seem to be format 16
% but including other options for completeness.
% HAVE NOT FORMALLY TESTED ANYTHING OHTER THAN FORMAT 16!
switch format
    case 16
        f=fread(fid,'int16','l');
    case 32 
        f=fread(fid,'int32','l');
    case 61
        f=fread(fid,'int16','b');
    otherwise
        error("Physionet format code %d not supported in this version of load_physionet_dat.m.  Only formats 16, 32, and 61 are implemented.", format)
end

% Close file
fclose(fid);

% Now parse the raw data
for j = 1:num_leads
    for i = 1:length(f)/num_leads
        E_raw.(leads(j))(i) = f(j+(num_leads*(i-1)));
    end

    % Confirm first sample in each lead is correct
    assert(E_raw.(leads(j))(1) == init_value(j), "Initial value mismatch for lead %s", leads(j));

    % Checksum
    % Need to deal with how matlab doesnt wrap around values when converting between int types
    total = mod(sum(int64(E_raw.(leads(j)))), 2^16);
    if total >= 2^15
        total = total - 2^16;
    end
    computed_checksum = int16(total);

    if checksum(j) > 32767
        checksum(j) = checksum(j) - 65536;
    end

    assert(computed_checksum == int16(checksum(j)), "Checksum mismatch for lead %s", leads(j));

    % Correct for zero voltage
    E.(leads(j)) = E_raw.(leads(j)) - zero(j);
  
    % Convert to physiological units (mv)
    E.(leads(j)) = E.(leads(j)) ./ unitspermv(j);
  
end

% Now all lead data has been extracted.  Check if missing limb leads and
% reconstruct the missing leads if needed.  If a lead was not found in the
% .dat/.hea files, then it is empty

if isempty(E.I) || isempty(E.II) || isempty(E.III) || ...
        isempty(E.AVR) || isempty(E.AVL) || isempty(E.AVF)

   [E.I, E.II, E.III, E.AVR, E.AVL, E.AVF] = reconstruct_limb_leads(E.I, E.II, E.III, E.AVR, E.AVL, E.AVF);

end

% Check that are not missing any precordial leads
if isempty(E.V1) || isempty(E.V2) || isempty(E.V3) || ...
   isempty(E.V4) || isempty(E.V5) || isempty(E.V6) 

   error('Missing one or more leads from physionet/WFDB .dat file');
end

% Check signal length is correct
if ~isnan(sig_length)
    assert(sig_length == length(E.I), "Signal length does not match header file");
end

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

