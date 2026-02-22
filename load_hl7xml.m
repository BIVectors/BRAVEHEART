%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_hl7xml.m -- Load HL7 XML ECGs
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


function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_hl7xml(filename)
% Mortara HL7 XML format - outputs in millivolts

% Declare variables
I = [];
II = [];
III = [];
avR = [];
avL = [];
avF = [];
V1 = [];
V2 = [];
V3 = [];
V4 = [];
V5 = [];
V6 = [];

% Read XML into a structure
D = readstruct(filename);

% Make sure HL7 Annotated ECG XML format
assert(isfield(D, 'xmlnsAttribute') && contains(D.xmlnsAttribute, 'hl7-org'), 'File is not HL7 Annotated ECG XML format');

% Extract seconds per sample and convert to Hz
% Must use component(1) for the current file structure
time_string = D.component.series.component.sequenceSet.component(1).sequence.code.codeAttribute;
hz = 1/D.component.series.component.sequenceSet.component(1).sequence.value.increment.valueAttribute;

% Confirm that this is the correct tag to get the frequency
if ~strcmp(time_string, "TIME_ABSOLUTE")
    error('Unexpected XML structure - unable to find signal frequency');
end

if ~isnumeric(hz)
    error('Unexpected XML structure - frequency not numeric');
end

% Lead names/signals

% max number of signals in the rhythm strip signal format
max_component = size(D.component.series.component.sequenceSet.component,2);

% Leads start at index 2
for i = 2:max_component

lead_name = D.component.series.component.sequenceSet.component(i).sequence.code.codeAttribute;
signal = D.component.series.component.sequenceSet.component(i).sequence.value.digits;

% Remove end of line characters that can be an issue on some systems
signal = regexprep(signal, '\r\n|\n|\r', '');

% Extract signal scale
scale = D.component.series.component.sequenceSet.component(i).sequence.value.scale.valueAttribute;        % mv or uv per unit
scale_units = D.component.series.component.sequenceSet.component(i).sequence.value.scale.unitAttribute;   % text of units

% Extract signal origin (usually 0)
origin = D.component.series.component.sequenceSet.component(i).sequence.value.origin.valueAttribute;      % Origin of signal value
origin_units = D.component.series.component.sequenceSet.component(i).sequence.value.origin.unitAttribute; % text of units

if ~isnumeric(scale)
    error('Unexpected XML structure - scale per unit not numeric');
end

if ~isnumeric(origin)
    error('Unexpected XML structure - origin not numeric');
end

% Will assert that origin_units must be the same as scale_units
assert(strcmp(scale_units, origin_units));

% To get signals from units to mv, multiple signal by scale, and then
% divide by 1000 if microvolts
if strcmp(scale_units, "uV")
   scale = scale / 1000;        % convert microvolts to millivolts
   origin = origin / 1000;      % convert microvolts to millivolts
elseif strcmp(scale_units, "mV")
    % leave scale as is if in mV already
end

switch lead_name    
    case "MDC_ECG_LEAD_I"
        I = (str2num(signal).*scale) + origin;
    case "MDC_ECG_LEAD_II"
        II = (str2num(signal).*scale) + origin;       
    case "MDC_ECG_LEAD_III"
        III = (str2num(signal).*scale) + origin;            
    case "MDC_ECG_LEAD_AVR"
        avR = (str2num(signal).*scale) + origin;
    case "MDC_ECG_LEAD_AVL"
        avL = (str2num(signal).*scale) + origin;        
    case "MDC_ECG_LEAD_AVF"
        avF = (str2num(signal).*scale) + origin;       
    case "MDC_ECG_LEAD_V1"
        V1 = (str2num(signal).*scale) + origin;              
    case "MDC_ECG_LEAD_V2"
        V2 = (str2num(signal).*scale) + origin;                   
    case "MDC_ECG_LEAD_V3"
        V3 = (str2num(signal).*scale) + origin;                    
    case "MDC_ECG_LEAD_V4"
        V4 = (str2num(signal).*scale) + origin;                         
    case "MDC_ECG_LEAD_V5"
        V5 = (str2num(signal).*scale) + origin;                               
    case "MDC_ECG_LEAD_V6"
        V6 = (str2num(signal).*scale) + origin;       
    otherwise   
end

end

% Check that are not missing any leads
if isempty(I) || isempty(II) || isempty(III) || ...
   isempty(avR) || isempty(avL) || isempty(avF) || ...
   isempty(V1) || isempty(V2) || isempty(V3) || ...
   isempty(V4) || isempty(V5) || isempty(V6) 

   error('Missing one or more leads from xml file');
end