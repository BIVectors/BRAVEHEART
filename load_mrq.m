%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_mrq.m -- Load Marquee ASCII format ECGs
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


function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = ...
    load_mrq(filename)


opts = delimitedTextImportOptions("NumVariables", 12);

% Specify range and delimiter
opts.DataLines = [7, Inf];
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["L1", "L2", "L3", "avR", "avF", "avL", "V1", "V2", "V3", "V4", "V5", "V6"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Import the data
tbl = readtable(filename, opts);

% Convert to output type
I = tbl.L1';
II = tbl.L2';
III = tbl.L3';
avR = tbl.avR';
avF = tbl.avF';
avL = tbl.avL';
V1 = tbl.V1';
V2 = tbl.V2';
V3 = tbl.V3';
V4 = tbl.V4';
V5 = tbl.V5';
V6 = tbl.V6';

hz = 500;

% divide each lead by x units per 1 mV 
unitspermv = 1000;

I = I/unitspermv;
II = II/unitspermv;
III = III/unitspermv;
avR = avR/unitspermv;
avF = avF/unitspermv;
avL = avL/unitspermv;
V1 = V1/unitspermv;
V2 = V2/unitspermv;
V3 = V3/unitspermv;
V4 = V4/unitspermv;
V5 = V5/unitspermv;
V6 = V6/unitspermv;


% Clear temporary variables
clear opts tbl