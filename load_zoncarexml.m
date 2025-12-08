%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_zoncarexml.m -- Load Zoncare XML format ECGs
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_zoncarexml(filename)

% Deal with parsing issues with xmlread
% Create Document Builder
builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;
% Disable dtd validation
builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

% Load XML
tree = xmlread(filename, builder);

% Check if ZQECG format
zqecg = tree.getElementsByTagName('zqecg');
assert(zqecg.getLength()>0, 'Does not appear to be properly formatted ZQECG XML file');

% Pull out information from limited header
num_leads = str2double(tree.getElementsByTagName('lead').item(0).getFirstChild.getNodeValue);
hz = str2double(tree.getElementsByTagName('sample').item(0).getFirstChild.getNodeValue);
duration = str2double(tree.getElementsByTagName('second').item(0).getFirstChild.getNodeValue);

% Assertions given limited XML metadata
assert(num_leads == 12, sprintf('Need 12 lead ECG but XML has a value of %i',num_leads));

% Fixed at ADC units being microvolts because don't see any other way to
% figure this out from the XML
unitspermv = 1000;

% Pull out waveform data (single tag in this format)
wlist = tree.getElementsByTagName('data');
w64 = char(wlist.item(0).getFirstChild.getNodeValue);

% Convert base64 to int16
intsignal = double(typecast(matlab.net.base64decode(w64), 'int16'));

% Signal is *13* channels multiplexed with the 13th signal empty
L = reshape(intsignal,num_leads+1,[]);

% Convert to mV
L = L ./ unitspermv; 

% Assumes no baseline offset because it is not available in any files

% Assume lead order is I, II, III, avR, avL, avF, V1-V6
% Will require 12 leads because of how the data is multiplexed and not sure
% how will behave if only have 8 leads.

I = L(1,:);
II = L(2,:);
III = L(3,:);
avR = L(4,:);
avL = L(5,:);
avF = L(6,:);

V1 = L(7,:);
V2 = L(8,:);
V3 = L(9,:);
V4 = L(10,:);
V5 = L(11,:);
V6 = L(12,:);