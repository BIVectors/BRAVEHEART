%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_eptracer.m -- Load EP Tracer (Schwarzer Cardiotek) recording system exported ECGs
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_eptracer(filename)
% EP Tracer recording system (Schwarzer Cardiotek) export format - outputs in millivolts
% Searches for case insensitive lead names: leads MUST have names I, II,
% III, AVR, AVL, AVF, V1, V2, V3, V4, V5, V6, in any order and with any case.
% Data other than the 12 ECG leads can be included in the file

% Load the ; delimited file exported from EP Tracer system
% Lead data names are in the format I[mV] etc
opts = detectImportOptions(filename, 'Delimiter', ';', 'VariableNamingRule', 'preserve');
data = readtable(filename, opts);

% Pull the lead data out based on column header names
I =   getLeadDatafromTable(data,'I[mV]'); 
II =  getLeadDatafromTable(data,'II[mV]'); 
III = getLeadDatafromTable(data,'III[mV]'); 

avR = getLeadDatafromTable(data,'AVR[mV]'); 
avL = getLeadDatafromTable(data,'AVL[mV]'); 
avF = getLeadDatafromTable(data,'AVF[mV]'); 

V1 =  getLeadDatafromTable(data,'V1[mV]'); 
V2 =  getLeadDatafromTable(data,'V2[mV]'); 
V3 =  getLeadDatafromTable(data,'V3[mV]'); 
V4 =  getLeadDatafromTable(data,'V4[mV]'); 
V5 =  getLeadDatafromTable(data,'V5[mV]'); 
V6 =  getLeadDatafromTable(data,'V6[mV]'); 

% Get sampling frequency from the delta time of samples to extract Hz
time = data.TimeOfDay;
time_per_sample = seconds(time(2))-seconds(time(1));
hz = round(1/time_per_sample);

% Now deal with possibly missing limb leads - reconstruct the missing limb leads
if isempty(I) || isempty(II) || isempty(III) || ...
   isempty(avR) || isempty(avL) || isempty(avF)

   [I, II, III, avR, avL, avF] = reconstruct_limb_leads(I, II, III, avR, avL, avF);

end

% Check that are not missing any precordial leads
if isempty(V1) || isempty(V2) || isempty(V3) || ...
   isempty(V4) || isempty(V5) || isempty(V6) 

   error('Missing one or more leads from EP Tracer file');
end