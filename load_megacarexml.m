%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_megacarexml.m -- Load Megacare XML format ECGs
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


function [hz, I, II, III, AVR, AVF, AVL, V1, V2, V3, V4, V5, V6] = load_megacarexml(filename)
% Megacare XML format

% Declare variables
I = []; II = []; III = []; AVR = []; AVL = []; AVF = [];
V1 = []; V2 = []; V3 = []; V4 = []; V5 = []; V6 = [];

% Read XML into a structure
D = readstruct(filename);

% Each lead (n) is stored as 
% D.component.series.component.sequenceSet.component(n).sequence.value.digits
% although lead data may not start at n = 1

% Number of possible leads/headers
num_sections = length(D.component.series.component.sequenceSet.component);

% make sure code ECG_RHYTHM_WAVEFORMS
assert(strcmp(D.component.series.code.codeAttribute, "ECG_RHYTHM_WAVEFORMS"), 'Did not find Rhythm waveforms in load_megacarexml.m');
assert(strcmp(D.component.series.code.codeSystemAttribute, "MDC"));

% Extract sampling freqnency
% Make sure delta is in seconds and extract delta between samples
assert(strcmpi(D.component.series.component.sequenceSet.component(1).sequence.value.increment.unitAttribute,"s"));
hz = 1 / D.component.series.component.sequenceSet.component(1).sequence.value.increment.valueAttribute;


% Loop through all leads and extract data
for i = 2:num_sections
    lead_name{i-1} = D.component.series.component.sequenceSet.component(i).sequence.code.codeAttribute;
    signal{i-1} = str2num(D.component.series.component.sequenceSet.component(i).sequence.value.digits);
    origin(i-1) = D.component.series.component.sequenceSet.component(i).sequence.value.origin.valueAttribute;
    units{i-1} = D.component.series.component.sequenceSet.component(i).sequence.value.origin.unitAttribute;
    scale(i-1) = D.component.series.component.sequenceSet.component(i).sequence.value.scale.valueAttribute;
    scale_units{i-1} = D.component.series.component.sequenceSet.component(i).sequence.value.scale.unitAttribute;
end

% Check units are the same for each lead.  Easier to loop than deal with comparing cell matrices
for i = 1:num_sections - 1
    assert(strcmpi(units{i},scale_units{i}), 'Units do not match in load_megacarexml.m');

    if strcmpi(units{i},"uV")
        mvperunit = scale / 1000; 
    else
        error('Expected uV as units in load_megacarexml.m');
    end
end

% Check that origin is 0 for all leads
assert(unique(origin) == 0 & length(unique(origin)) == 1), 'Origin not set to 0 in load_megacarexml.m';

% Extract lead names and lead data
for i = 1:length(lead_name)

    % Adjust signal by scale to convert to mV
    switch lead_name{i}   
        case "NOM_ECG_LEAD_I"
            I = signal{i}.*mvperunit(i);
        case "NOM_ECG_LEAD_II"
            II = signal{i}.*mvperunit(i);       
        case "NOM_ECG_LEAD_III"
            III = signal{i}.*mvperunit(i);            
        case "NOM_ECG_LEAD_AVR"
            AVR = signal{i}.*mvperunit(i);
        case "NOM_ECG_LEAD_AVL"
            AVL = signal{i}.*mvperunit(i);        
        case "NOM_ECG_LEAD_AVF"
            AVF = signal{i}.*mvperunit(i);       
        case "NOM_ECG_LEAD_V1"
            V1 = signal{i}.*mvperunit(i);              
        case "NOM_ECG_LEAD_V2"
            V2 = signal{i}.*mvperunit(i);                   
        case "NOM_ECG_LEAD_V3"
            V3 = signal{i}.*mvperunit(i);                    
        case "NOM_ECG_LEAD_V4"
            V4 = signal{i}.*mvperunit(i);                         
        case "NOM_ECG_LEAD_V5"
            V5 = signal{i}.*mvperunit(i);                               
        case "NOM_ECG_LEAD_V6"
            V6 = signal{i}.*mvperunit(i);       
        otherwise   
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

   error('Missing one or more leads from Megacare XML file');
end