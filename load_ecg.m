%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_ecg.m -- Load BIDMC and Prucka format ECGs
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



%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LOAD ECG FUNCTION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

function [L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6, X, Y, Z, VM] =...
    load_ecg(filename, unitspermv, source)


% shouldn't pass hObject around to subroutines
% handles = guidata(hObject);

[fid,errmsg] = fopen(filename);
if fid == -1
    error('load_ecg: Couldn''t open %s: %s', filename, errmsg);
end

X = []; Y = []; Z = []; VM=[];
switch source
    case 'bidmc_format'
        %%% BIDMC txt files
        M = textscan(fid, '%*d %d %d %d %d %d %d %d %d %d %d %d %d %d');
        L1 = double(M{1})'; L2 = double(M{2})'; L3 = double(M{3})';
        avR = double(M{4})'; avF = double(M{5})'; avL = double(M{6})'; 
        V1 = double(M{7})'; V2 = double(M{8})'; V3 = double(M{9})'; 
        V4 = double(M{10})'; V5 = double(M{11})'; V6 = double(M{12})';

    case 'prucka_format'
        %Prucka txt files
        M = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f');
        L1 = double(M{1})'; L2 = double(M{2})'; L3 = double(M{3})';
        avR = double(M{4})'; avL = double(M{5})'; avF= double(M{6})'; 
        V1 = double(M{7})'; V2 = double(M{8})'; V3 = double(M{9})'; 
        V4 = double(M{10})'; V5 = double(M{11})'; V6 = double(M{12})';

    case 'rdsamp_format'
        % (output from rdann) text files
        M = textscan(fid, '%*f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
        L1 = double(M{1})'; L2 = double(M{2})'; L3= double(M{3})';
        avR= double(M{4})';avL= double(M{5})'; avF= double(M{6})'; 
        V1= double(M{7})'; V2= double(M{8})'; V3= double(M{9})'; 
        V4= double(M{10})'; V5= double(M{11})'; V6= double(M{12})';
        VM= double(M{13})'; 
        X= double(M{14})'; Y= double(M{15})'; Z= double(M{16})';
        
    otherwise
        error('Unknown source format: %s', source);
end
fclose(fid);


 % divide each lead by x units per 1 mV (1 mv = 200 units for standard BIDMC txt files; 1 mv = 1 unit for Prucka)

    L1 = L1/unitspermv;
    L2 = L2/unitspermv;
    L3 = L3/unitspermv;
    avR = avR/unitspermv;
    avF = avF/unitspermv;
    avL = avL/unitspermv;
    V1 = V1/unitspermv;
    V2 = V2/unitspermv;
    V3 = V3/unitspermv;
    V4 = V4/unitspermv;
    V5 = V5/unitspermv;
    V6 = V6/unitspermv;
    
    X = X/unitspermv;
    Y = Y/unitspermv;
    Z = Z/unitspermv;
        
end
