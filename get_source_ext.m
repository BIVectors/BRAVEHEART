%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% get_source_ext.m -- Part of BRAVEHEART GUI
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

function e = get_source_ext(s)   
 switch s
    case 'bidmc_format'
       e = '.txt';
    case 'prucka_format'
       e = '.txt';
    case 'muse_xml'
       e = '.xml';
    case 'philips_xml'
       e = '.xml';
    case 'hl7_xml'
       e = '.xml';
    case 'ISHNE'
       e = '.ecg';
    case 'mrq_ascii'
       e = '.mrq';
    case 'DICOM'
       e = '.dcm';
    case 'generic_csv'
       e = '.csv';
    case 'unformatted'
       e = '.txt';
    case 'cardiosoft_xml'
       e = '.xml';
    otherwise
       e = '.*';
 end
end