%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_schillerxml.m -- Load Schiller XML format ECGs
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


function [hz, I, II, III, AVR, AVF, AVL, V1, V2, V3, V4, V5, V6] = load_schillerxml(filename)
% Schiller XML format

% Declare variables
I = []; II = []; III = []; AVR = []; AVL = []; AVF = [];
V1 = []; V2 = []; V3 = []; V4 = []; V5 = []; V6 = [];

% Read XML into a structure
D = readstruct(filename);

% Determine if file contains rhythm strips and/or medians
num_types = length(D.eventdata.event.wavedata);

for i = 1:num_types
    type{i} = char(D.eventdata.event.wavedata(i).type);
end

type_idx = 0;
for i = 1:num_types
    if strcmpi(type{i}, 'ECG_RHYTHMS')
        type_idx = i;
    end
end

% type_idx is the index that contains rhythm strips

W = D.eventdata.event.wavedata(type_idx);

% Confirm index is correct
assert(strcmpi(W.type,'ECG_RHYTHMS'), 'Rhythm strip not located successfully');

% Extract sampling frequency
hz = W.resolution.samplerate.value;
assert(isnumeric(hz), 'Unexpected XML structure - sampling frequency not numeric')

% Assert sampling freq exponent = 1 because not sure how formatting changes if it is not = 1
assert(W.resolution.samplerate.exponent == 1,'Unexpected XML structure - sampling frequency exponent not 1')
    
% Extract signal sample resolution/units
scale = W.resolution.yres.unitperbit;           % mv or uv per unit
scale_units = W.resolution.yres.units;          % text of units
assert(isnumeric(scale), 'Unexpected XML structure - scale per unit not numeric')
assert(strcmpi(scale_units,'uv') || strcmp(scale_units,'mv'), 'ECG has incorrect units specified')

% To get signals from units to mv, multiple signal by scale, and then
% divide by 1000 if microvolts
if strcmpi(scale_units, "uv")
   scale = scale / 1000;  % convert microvolts to millivolts
elseif strcmpi(scale_units, "mv")
    % leave scale as is if in mV already
end


% Lead names/signals

% max number of signals in the rhythm strip signal format
num_leads = length(W.channel);

% Extract lead names and lead data
for i = 1:num_leads
    lead_name = upper(W.channel(i).name);
    signal = W.channel(i).data;
    datatype = W.channel(i).datastype;

    % Have to deal with commas
    if strcmpi(datatype,'COMMASEPARATE')    % Have to remove commas and create numeric vector
        signal = str2num(strrep(signal,',',' '));
    end

    % Adjust signal by scale to convert to mV
    switch lead_name   
        case "I"
            I = signal.*scale;
        case "II"
            II = signal.*scale;       
        case "III"
            III = signal.*scale;            
        case "AVR"
            AVR = signal.*scale;
        case "AVL"
            AVL = signal.*scale;        
        case "AVF"
            AVF = signal.*scale;       
        case "V1"
            V1 = signal.*scale;              
        case "V2"
            V2 = signal.*scale;                   
        case "V3"
            V3 = signal.*scale;                    
        case "V4"
            V4 = signal.*scale;                         
        case "V5"
            V5 = signal.*scale;                               
        case "V6"
            V6 = signal.*scale;       
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

   error('Missing one or more leads from Schiller XML file');
end