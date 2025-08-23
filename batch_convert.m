 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% batch_convert.m -- Converts a directory of ECGs into another format 
% Copyright 2016-2025 Hans F. Stabenau and Jonathan W. Waks
%
% Code adapted from: https://cardiocurves.sourceforge.net/
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

% Currently can only convert into `unformatted text' format

% Inputs:
% file_folder - directory of files to convert.  If set to '' will prompt the user to choose a directory
% format - the string used to describe the ecg format (eg 'muse_xml')
% file_ext - the file format extension (eg '.xml')
% progbar - 0/1 if want to disable/enable a progress bar to monitor the status of file conversion

% Outputs:
% num_files - total number of files successfully converted
% err - total number of files not converted due to an error

function [num_files, err] = batch_convert(file_folder, format, file_ext, progbar)

% If pass in '' as file filder it will ask you to choose a directory
if strcmp(file_folder,'')
    % Choose folder via filesystem GUI
    file_folder = uigetdir(pwd, 'Select a folder');
    if file_folder==0; return; end % Pressed cancel
else
    % use input file_folder
end

% Folder file stucture
file_list_struct = dir(fullfile(file_folder, strcat('*',file_ext)));
name_list_struct = {file_list_struct.name}';
name_list_struct(ismember(name_list_struct, {'.', '..'})) = [];

% Create directory names
orig_directory = file_list_struct.folder;

% Load ECGs from directory
num_files = length(name_list_struct);

% Initialize error counter
err = 0;

if progbar
    W = waitbar(0,'Processing','Name','Processing...');
end

% loop through files, load ECG12 object, and convert
for i = 1:num_files
    try
        fname = char(fullfile(orig_directory,name_list_struct(i)));
        e = ECG12(fname,format);
        e.write(strcat(fname(1:end-4),'.txt'), 'unformatted');

        if progbar
            waitbar(i/num_files, W, sprintf('Processed %i out of %i Total ECGs (%i%%)',i,num_files,round(100*(i/num_files))),'Name','Processing...');
        end
    
    catch ME
        err = err + 1;
    end
end

if progbar
    delete(W);
end

end