%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_musexml.m -- Load GE MUSE XML format ECGs
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


function [hz, I, II, V1, V2, V3, V4, V5, V6] = load_musexml(filename, rh_or_med_flag)
% BI MUSE XML format
% Need to construct III, avL, avR, avF using leads I and II (see ECG12.m)

if nargin < 2 || strcmpi(rh_or_med_flag,'rhythm')
	waveformstring='Rhythm';
elseif strcmpi(rh_or_med_flag,'median')
	waveformstring='Median';
else
	error('load_musexml: expected nothing, "rhythm", or "median" for rh_or_med_flag, got %s', rh_or_med_flag)
end

% Deal with parsing issues with xmlread
% Create Document Builder
builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;
% Disable dtd validation
builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

tree = xmlread(filename, builder);
wlist = tree.getElementsByTagName('Waveform');
waveform=[];
for k=0:wlist.getLength-1 % find the "rhythm" strip (not the median beat)
	wtype = elget(wlist.item(k), 'WaveformType');
	if strcmp(wtype, waveformstring); waveform=wlist.item(k); break; end
end
hz = elgetn(waveform, 'SampleBase');
exp = elgetn(waveform, 'SampleExponent');
assert(exp == 0, '%s: nonzero sample exponent %f', filename, exp);
leads = waveform.getElementsByTagName('LeadData');
for k=0:leads.getLength-1
	l = leads.item(k);
	gain = elgetn(l, 'LeadAmplitudeUnitsPerBit');
	unit = elget(l, 'LeadAmplitudeUnits');
	assert(strcmp(unit, 'MICROVOLTS'), '%s: expected MICROVOLTS but found %s', filename, unit);
	
	offset = elgetn(l, 'LeadOffsetFirstSample');
	assert(offset==0, '%s: lead %d with %d bytes of invalid data', filename, k, offset);
	baseline = elgetn(l, 'FirstSampleBaseline');
	bytespersamp = elgetn(l, 'LeadSampleSize');
	assert(bytespersamp == 2, '%s: expected 2 bytes per sample but found %f', filename, bytespersamp);
	
	w64 = char(elget(l, 'WaveFormData'));
	% data is little-endian per MUSE spec
        
	intsignal = double(typecast(matlab.net.base64decode(w64), 'int16'));
	intsignal = intsignal + baseline;
	signal = intsignal * gain / 1000;
	switch char(elget(l, 'LeadID'))
		case 'I'
			I = signal;
		case 'II'
			II = signal;
		case 'V1'
			V1 = signal;
		case 'V2'
			V2 = signal;
		case 'V3'
			V3 = signal;
		case 'V4'
			V4 = signal;
		case 'V5'
			V5 = signal;
		case 'V6'
			V6 = signal;
	end
end
end

% utility functions
function r = elget(l, name)
r = l.getElementsByTagName(name).item(0).getFirstChild.getNodeValue;
end
function r = elgetn(l, name)
r = str2double(elget(l, name));
end
