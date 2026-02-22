%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_claris.m -- Load Abbott WorkMate Claris ASCII format ECGs
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

function [hz, I, II, III, AVR, AVF, AVL, V1, V2, V3, V4, V5, V6] = load_claris(filename)

% Parse filename to get structure needed to find all of the corresponding
% text files since the data is stored in 1 lead per file

% It does not matter which lead is chosen - this function will parse all
% leads with a smilar structure:

% e.g. II.Session 18 - Page 1.2.TXT
% Will load all 12 <L>.Session 18 - Page 1.<N>.TXT where <L> is the lead and
% <N> is the order in which the signals appear in the Claris page which has
% no bearing on loading the signals.

% This load module will ONLY work if the file names are in the above format.

[d,f,~] = fileparts(filename);

common_file = strsplit(f,'.');
common_file = common_file{2};

% common_file now contains the structure of the data:
%<L>.common_file.<N>.txt

L =struct();

% Initialize empty values in case leads are missing
L.I = []; L.II = []; L.III = [];
L.AVR = []; L.AVF = []; L.AVL = [];
L.V1 = []; L.V2 = []; L.V3 = []; 
L.V4 = []; L.V5 = []; L.V6 = [];

% Field names of all 12 leads
leads = upper(fieldnames(ECG12));

for i = 3:14        % ECG12 fieldnames
    for N = 1:40    % Max number of leads from Claris page (may need to change)

        F = strcat(leads{i},'.',common_file,'.',num2str(N),'.txt');

        if isfile(fullfile(d,F))
            L.(leads{i}) = parse_claris_txt(fullfile(d,F));
            break;
        end

    end
end

% Need to have at least 8 leads
assert(numel(fieldnames(L)) >= 8, "Not enough files to make a 12-lead ECG");

% See if an information file exists
info_file_name = strsplit(common_file,' - ');
info_file_name = info_file_name{1};
info_file_name = strcat(info_file_name,' Information.TXT');

if isfile(fullfile(d,info_file_name))
    
    info_file = textread(fullfile(d,info_file_name),'%s','delimiter','\n');
    
    freq_idx = find(contains(info_file,'Sample Rate='));
    freq_cell = strsplit(info_file{freq_idx},'=');
    hz = str2double(extract(string(freq_cell{2}), digitsPattern));

    gain_idx = find(contains(info_file,'Channel Resolution='));
    gain_cell = strsplit(info_file{gain_idx},'=');
    gain_val = str2double(extract(string(gain_cell{2}), digitsPattern));

    gain_units = strsplit(gain_cell{2},' ');
    gain_units = gain_units{2};

    switch gain_units
        case 'nV/LSB'
            gain = gain_val / 1000000;
        otherwise
            error('gain units not in nV')
    end

else
    gain = 78/1000000;
    hz = 2000;
end


% Now deal with possibly missing limb leads - reconstruct the missing limb leads
if isempty(L.I) || isempty(L.II) || isempty(L.III) || ...
   isempty(L.AVR) || isempty(L.AVL) || isempty(L.AVF)

   [L.I, L.II, L.III, L.AVR, L.AVL, L.AVF] = reconstruct_limb_leads(L.I, L.II, L.III, L.AVR, L.AVL, L.AVF);

end

% Check that are not missing any precordial leads
if isempty(L.V1) || isempty(L.V2) || isempty(L.V3) || ...
   isempty(L.V4) || isempty(L.V5) || isempty(L.V6) 

   error('Missing one or more leads from Claris file');
end

% Form row vectors gained properly
I = L.I' * gain;
II = L.II' * gain;
III = L.III' * gain;
AVR = L.AVR' * gain;
AVF = L.AVF' * gain;
AVL = L.AVL' * gain;

V1 = L.V1' * gain;
V2 = L.V2' * gain;
V3 = L.V3' * gain;
V4 = L.V4' * gain;
V5 = L.V5' * gain;
V6 = L.V6' * gain;
