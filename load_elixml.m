%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_elixml.m -- Load ELI XML format ECGs
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


function [hz, I, II, III, AVR, AVF, AVL, V1, V2, V3, V4, V5, V6] = load_elixml(filename)
% ELI XML format (multiple manufacturers over time)

% Declare variables
I = []; II = []; III = []; AVR = []; AVL = []; AVF = [];
V1 = []; V2 = []; V3 = []; V4 = []; V5 = []; V6 = [];

% Read XML into a structure
D = readstruct(filename);

% Rhythm strips are stored inside <CHANNEL> tags
C = D.CHANNEL;
num_leads = length(C);

% Initialize lead specific variables
fs = zeros(1,num_leads);
offset = zeros(1,num_leads);
bits = zeros(1,num_leads);
format = strings(1,num_leads);
unitspermv = zeros(1,num_leads);
duration = zeros(1,num_leads);
encoding = strings(1,num_leads);
lead_name = strings(1,num_leads);
data64 = strings(1,num_leads);

% Parse out data from XML
for i = 1:num_leads
    fs(i) = C(i).SAMPLE_FREQAttribute;
    offset(i) = C(i).OFFSETAttribute;
    bits(i) = C(i).BITSAttribute;
    format(i) = C(i).FORMATAttribute;
    unitspermv(i) = C(i).UNITS_PER_MVAttribute;
    duration(i) = C(i).DURATIONAttribute;
    encoding(i) = C(i).ENCODINGAttribute;
    lead_name(i) = C(i).NAMEAttribute;
    data64(i) = C(i).DATAAttribute;
end

% Ensure that leads are all encoded the same for now.  Unlikely this would
% be an issue with this format but just to check
assert(numel(unique(fs)) == 1, 'Multiple sampling frequencies not supported in this version of load_eli_xml.m');
assert(numel(unique(bits)) == 1, 'Multiple bits per sample not supported in this version of load_eli_xml.m');
assert(numel(unique(format)) == 1, 'Multiple bit sign not supported in this version of load_eli_xml.m');
assert(unique(bits) == 16 && strcmp(unique(format),"SIGNED"), 'Only 16 bit signed integer signals supported in this version of load_eli_xml.m');
assert(numel(unique(duration)) == 1, 'Multiple lead durations not supported in this version of load_eli_xml.m');
assert(numel(unique(encoding)) == 1 && strcmp(unique(encoding), "BASE64"), 'Only base64 encoding is supported in this version of load_eli_xml.m');

% Assign sampling frequency
hz = fs(1);

% Assign signal duration in samples
signal_length = duration(1);


% Process the lead data 

for i = 1:num_leads
    % Convert base64 into int16 and add the offset
    intsignal = double(typecast(matlab.net.base64decode(data64(i)), 'int16'));
	intsignal = intsignal + offset(i);

    % check lead length is correct
    assert(length(intsignal) == signal_length, "Lead %s signal is longer than expected in load_eli_xml.m", lead_name(i));

    % convert to mV
    signal_mv = intsignal / unitspermv(i);

    % Assign correct lead
    switch char(upper(lead_name(i)))
		case 'I'
			I = signal_mv;
		case 'II'
			II = signal_mv;
        case 'III'
			III = signal_mv;
        case 'AVR'
			AVR = signal_mv;
        case 'AVL'
			AVL = signal_mv;
        case 'AVF'
			AVF = signal_mv;
		case 'V1'
			V1 = signal_mv;
		case 'V2'
			V2 = signal_mv;
		case 'V3'
			V3 = signal_mv;
		case 'V4'
			V4 = signal_mv;
		case 'V5'
			V5 = signal_mv;
		case 'V6'
			V6 = signal_mv;
    end
end

% Now deal with possibly missing limb leads - reconstruct the missing limb leads
if isempty(I) || isempty(II) || isempty(III) || ...
   isempty(AVR) || isempty(AVL) || isempty(AVF)

   [I, II, III, AVR, AVL, AVF] = reconstruct_limb_leads(I, II, III, AVR, AVL, AVF);

end

% Check that are not missing any precordial leads
if isempty(V1) || isempty(V2) || isempty(V3) || ...
   isempty(V4) || isempty(V5) || isempty(V6) 

   error('Missing one or more leads from ELI XML file');
end

