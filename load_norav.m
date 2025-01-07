%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_novav.m -- Load Norav 1200M raw data type (.rdt) ECG files
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

function [I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_norav(filename, unitspermv)

% Further information can be found at 
% https://www.noravmedical.com/wp-content/uploads/2023/03/UM_PC-ECG-v5.9.7.pdf
% The Norav 1200M uses 2.44 microvolts/unit

fid = fopen(filename,'rb');

if fid == -1
  error('Cant Open Norav .rdt file %s', filename);
end

ECG = fread(fid,[12,Inf],'int16','l');

I = ECG(1,:) / unitspermv;
II = ECG(2,:) / unitspermv;
III = ECG(3,:) / unitspermv;

avR = ECG(4,:) / unitspermv;
avL = ECG(5,:) / unitspermv;
avF = ECG(6,:) / unitspermv;

V1 = ECG(7,:) / unitspermv;
V2 = ECG(8,:) / unitspermv;
V3 = ECG(9,:) / unitspermv;
V4 = ECG(10,:) / unitspermv;
V5 = ECG(11,:) / unitspermv;
V6 = ECG(12,:) / unitspermv;

fclose(fid);
