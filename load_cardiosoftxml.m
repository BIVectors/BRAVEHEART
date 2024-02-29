%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_cardiosoftxml.m -- Load Cardiosoft XML format ECGs
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


function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_cardiosoftxml(filename, rh_or_med_flag)
% Cardiosoft XML format

if nargin < 2 || strcmpi(rh_or_med_flag,'rhythm')
	waveformstring='Rhythm';
elseif strcmpi(rh_or_med_flag,'median')
	waveformstring='Median';
else
	error('load_cardiosoftxml: expected nothing, "rhythm", or "median" for rh_or_med_flag, got %s', rh_or_med_flag)
end

% Deal with parsing issues with xmlread
% Create Document Builder
builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;
% Disable dtd validation
builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

tree = xmlread(filename, builder);
L = tree.getElementsByTagName('StripData').item(0);

% Sampling frequency
hz = elgetn(L, 'SampleRate');

% Units
gain = elgetn(L, 'Resolution');
ulist = L.getElementsByTagName('Resolution');
units = char(ulist.item(0).getAttributes.item(0));
unit_div = 1000;
assert(strcmp(units, 'units="uVperLsb"'), '%s: expected uVperLsb but found %s', filename, units);

wlist = L.getElementsByTagName('WaveformData');

for k=0:wlist.getLength-1 
    % Note indexing of item 0 corresponds to waveform{1} etc
    W = string((wlist.item(k).getFirstChild.getNodeValue));
    W = regexprep(W, '\t', '');
    label = char(wlist.item(k).getAttributes.item(0));
    D = sscanf(W, '%g,', [1, inf]) * gain / unit_div;

	switch lower(label)     % User lowercase because some different versions use different capital letters
		case 'lead="i"'
			I = D;
		case 'lead="ii"'
			II = D;
		case 'lead="iii"'
			III = D;
        case 'lead="avr"'
			avR = D;
        case 'lead="avl"'
			avL = D;
        case 'lead="avf"'
			avF = D;
		case 'lead="v1"'
			V1 = D;
		case 'lead="v2"'
			V2 = D;
		case 'lead="v3"'
			V3 = D;
		case 'lead="v4"'
			V4 = D;
		case 'lead="v5"'
			V5 = D;
		case 'lead="v6"'
			V6 = D;
    end

end         % End for loop
end         % end function


% utility functions
function r = elget(l, name)
r = l.getElementsByTagName(name).item(0).getFirstChild.getNodeValue;
end
function r = elgetn(l, name)
r = str2double(elget(l, name));
end
