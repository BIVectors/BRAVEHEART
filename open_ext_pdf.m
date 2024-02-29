%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% open_ext_pdf.m -- Open an external PDF file so can load within packaged executable
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

function open_ext_pdf(file, type)

% Special way to deal with user guide which is in the same directory as the
% application executable

if strcmp(type, 'userguide')

    if ismac && isdeployed
        % Find ctf directory substring
        % This has to be done in a round about way....
        
        % Find ctfroot directory - this is NOT the directory we need
        P = char(ctfroot);
    
        % Find the location in the string that references the Mac .app
        % compressed executable
        Ploc = strfind(ctfroot,'braveheart_gui.app');   
    
        % Get the directory before the .app compressed executable
        % This is where the main directory is which contains the actual
        % executable and other provided files
        P = P(1:Ploc-2);
    
        % Add escape character \ for spaces
        P = strrep(P, ' ', '\ ');
    
        open_ext_file(fullfile(P,file));
    
    % Either PC or Mac not deployed - just get current directory    
    else        
        path = fullfile(getcurrentdir(),file);

        if ismac
            path = strrep(path, ' ', '\ ');
        end

        open_ext_file(fullfile(getcurrentdir(),file));
    
    end


% Other PDF files that are included inside the executable

else

    if ismac && isdeployed
        % Find this directory inside ctfroot and escape character any spaces
        path = fullfile(ctfroot,'braveheart_g',file);
        path = strrep(path, ' ', '\ ');
        open_ext_file(path);
    
        
    elseif ispc && isdeployed
        open_ext_file(file);


    else        % Not deployed
        %open_ext_file(file);
        path = fullfile(getcurrentdir(),file);

        if ismac
            path = strrep(path, ' ', '\ ');
        end


        fullfile(getcurrentdir(),file)

        open_ext_file(fullfile(getcurrentdir(),file));
    end

end