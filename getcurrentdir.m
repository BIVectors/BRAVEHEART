%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% getcurrentdir.m -- Get working directory if deployed
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

function currentDir = getcurrentdir()

if isdeployed && ispc % Compiled PC
    [status, result] = system('set path');
    currentDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));

elseif isdeployed && ismac % Compiled Mac
    % v1.2.1 onward
    % Allows .csv files to remain in executable directory rather than Mac
    % home directory

    % Find ctf directory substring
    % This has to be done in a round about way....
    
    % Find ctfroot directory - this is NOT the directory we need
    P = char(ctfroot);

    % Find the location in the string that references the Mac .app
    % compressed executable
    Ploc = strfind(ctfroot,'braveheart_gui.app');   

    % If running compiled batch not compiled GUI
    if isempty(Ploc)
        Ploc = strfind(ctfroot,'braveheart_batch.app');  
    end

    % Get the directory before the .app compressed executable
    % This is where the main directory is which contains the actual
    % executable and other provided files
    P = P(1:Ploc-2);

    currentDir = P;

	% v1.2.0 and prior
	%currentDir = char(string(java.lang.System.getProperty('user.home')) + "/braveheart");


%     NameOfDeployedApp = 'BRAVEHEART_GUI'; % do not include the '.app' extension
%     [~, result] = system(['top -n100 -l1 | grep ' NameOfDeployedApp ' | awk ''{print $1}''']);
%     result=strtrim(result);
%     [status, result] = system(['ps xuwww -p ' result ' | tail -n1 | awk ''{print $NF}''']);
%     if status==0
%         diridx=strfind(result,[NameOfDeployedApp '.app']);
%         currentDir=result(1:diridx-2);
%     else
%         msgbox({'realpwd not set:',result})
%     end

else % MATLAB mode.
    currentDir = pwd;

end