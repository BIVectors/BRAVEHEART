%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_ISHNE.m -- Load ISHNE format ECGs
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


function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] ... [hz, X, Y, Z]
	= load_ISHNE(filename)
% load ISHNE format files 
% adapted from read_ishne.m at http://thew-project.org/code_library.htm

[fid,errmsg]=fopen(filename,'r');
if ne(fid,-1)
    
    %Magic number
    magicNumber = fread(fid, 8, 'char'); %#ok<*NASGU>
   
    % get checksum
	checksum = fread(fid, 1, 'uint16');
	
	%read header
    Var_length_block_size = fread(fid, 1, 'long');
    Sample_Size_ECG = fread(fid, 1, 'long');	
    Offset_var_lenght_block = fread(fid, 1, 'long');
    Offset_ECG_block = fread(fid, 1, 'long');
    File_Version = fread(fid, 1, 'short');
    First_Name = fread(fid, 40, 'char');  									        								
    Last_Name = fread(fid, 40, 'char');  									        								
    ID = fread(fid, 20, 'char');  									        								
    Sex = fread(fid, 1, 'short');
    Race = fread(fid, 1, 'short');
    Birth_Date = fread(fid, 3, 'short');	
    Record_Date = fread(fid, 3, 'short');	
    File_Date = fread(fid, 3, 'short');	
    Start_Time = fread(fid, 3, 'short');	
    nbLeads = fread(fid, 1, 'short');
    Lead_Spec = fread(fid, 12, 'short');	
    Lead_Qual = fread(fid, 12, 'short');	
    Resolution = fread(fid, 12, 'short');	% in nv/unit
    Pacemaker = fread(fid, 1, 'short');	
    Recorder = fread(fid, 40, 'char');
    Sampling_Rate = fread(fid, 1, 'short');	
    Proprietary = fread(fid, 80, 'char');
    Copyright = fread(fid, 80, 'char');
    Reserved = fread(fid, 88, 'char');
    
    % read variable_length block
    varblock = fread(fid, Var_length_block_size, 'char');
    
    % get data at start
%     offset = startOffset*Sampling_Rate*nbLeads*2; % each data has 2 bytes
%     fseek(fid, Offset_ECG_block+offset, 'bof');
    
   
    % read ecgSig signal
%	numSample = 100000;
	numSample = Sample_Size_ECG;
    ecgSig = fread(fid, [nbLeads, numSample], 'int16')';
     
    fclose(fid);
 else
     error('Couldn''t open %s for reading: %s', filename, errmsg);
end

assert(nbLeads == 12);
%assert(nbLeads == 3);

hz = double(Sampling_Rate);

for i=1:nbLeads
	lead = ecgSig(:,i) .* Resolution(i) / 10.^6;
	switch Lead_Spec(i)
% 		case 2; X = lead;
% 		case 3; Y = lead;
% 		case 4; Z = lead;
		case 5; I = lead;
		case 6; II = lead;
		case 7; III = lead;
		case 8; avR = lead;
		case 9; avL = lead;
		case 10; avF = lead;
		case 11; V1 = lead;
		case 12; V2 = lead;
		case 13; V3 = lead;
		case 14; V4 = lead;
		case 15; V5 = lead;
		case 16; V6 = lead;
		otherwise; error('Unknown lead code %d', Lead_Spec(i));
	end
end