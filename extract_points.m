%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% extract_points.m -- Logic to deal with possibility of median annotation
% via neural network finding more than 1 fiducial point
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

function [qonPred, qoffPred, toffPred, flag, nan_count] = extract_points(YPredTest)
    
%%


% Flag for multiple possible fiducial points
flag = zeros(size(YPredTest,1),1);
nan_count = 0;   % Count number of times no point is found
    
% Logic for detecting fiducial points in YPredTest is more complex because
% can have multiple Qon/Qoff/Toff detected.  Will Flag the ECG if there are
% multiple possible points.  

for j = 1:size(YPredTest,1)
 
   tmp = [];
    
for k = 1:size(YPredTest{j},2)-1
    if find(YPredTest{j}(k) == '0' & YPredTest{j}(k+1) == '1') == 1
        tmp(k+1) = 1;
    else
        tmp(k+1) = 0;
    end
end   
tmpq{j} = find(tmp == 1);

if length(tmpq{j}) > 1
   flag(j) = 1; 
end

    
for k = 1:size(YPredTest{j},2)-1
    if find(YPredTest{j}(k) == '1' & YPredTest{j}(k+1) == '2') == 1
        tmp(k) = 1;
    else
        tmp(k) = 0;
    end
end   
tmps{j} = find(tmp == 1);

if length(tmps{j}) > 1
   flag(j) = 1; 
end


for k = 1:size(YPredTest{j},2)-1
    if find(YPredTest{j}(k) == '2' & YPredTest{j}(k+1) == '0') == 1
        tmp(k) = 1;
    else
        tmp(k) = 0;
    end
end   
tmpt{j} = find(tmp == 1);

if length(tmpt{j}) > 1
   flag(j) = 1; 
end


end

%%% POINT FILTERING 1
% Algorithm to deal with multiple found fidpts and removes pts that are
% clearly out of order

for j = 1:size(YPredTest,1)


    if ~isempty(tmpq{j})
        
        % If multiple qon but only 1 qoff and 1 toff, choose 1st qon that
        % is before qoff and toff
        if ~isempty(tmps{j}) && ~isempty(tmpt{j}) && length(tmpq{j}) > 1 && length(tmps{j}) == 1 && length(tmpt{j}) == 1 
         
            for p = 1:length(tmpq{j})
                
                if tmpq{j}(p) > tmps{j}
                   tmpq{j}(p) = [];
                   break;
                end
                
                if tmpq{j}(p) > tmpt{j}
                   tmpq{j}(p) = []; 
                   break;
                end
                
            end
 
            qonPred(j) = tmpq{j}(1);  
        
        else 
           % if multiple points everywhere just choose 1st qon
            qonPred(j) = tmpq{j}(1);     
                
        end
         
    else
        qonPred(j) = nan; 
        flag(j) = 1;
        nan_count = nan_count +1;
    end
    
    
    
    if ~isempty(tmps{j})

    % If multiple qoff but only 1 qon and 1 toff, choose the 1st qon that
    % is after qon and before toff
    if ~isempty(tmpq{j}) && ~isempty(tmpt{j}) && length(tmps{j}) > 1 && length(tmpq{j}) == 1 && length(tmpt{j}) == 1
         
            for p = 1:length(tmps)
                
                if tmps{j}(p) < tmpq{j}
                   tmps{j}(p) = [];
                   break;   % Have to break out of loop of second if/end will throw an error since tmps{j}(p) is deleted if this loop activates
                end
                
                if tmps{j}(p) > tmpt{j}
                   tmps{j}(p) = []; 
                   break;
                end
                
            end
 
            qoffPred(j) = tmps{j}(1);  
        
        else 
           % if multiple points everywhere just choose 1st qon
            qoffPred(j) = tmps{j}(1);     
                
        end
               
        
    else
        qoffPred(j) = nan;   
        flag(j) = 1;
        nan_count = nan_count +1;
    end



    if ~isempty(tmpt{j})

           % If multiple toff but only 1 qon and 1 qoff, choose first toff
           % that is after qoff and qon
           if ~isempty(tmps{j}) && ~isempty(tmpq{j}) && length(tmpt{j}) > 1 && length(tmps{j}) == 1 && length(tmpq{j}) == 1
         
            for p = 1:length(tmpt{j})
                
                if tmpt{j}(p) < tmpq{j}
                   tmpt{j}(p) = []; 
                   break;
                end
                
                if tmpt{j}(p) < tmps{j}
                   tmpt{j}(p) = []; 
                   break;
                end
                
            end
 
            toffPred(j) = tmpt{j}(1);  
        
        else 
           % if multiple points everywhere just choose 1st qon
            toffPred(j) = tmpt{j}(1);     
                
        end
        
               
    else
        toffPred(j) = nan;   
        flag(j) = 1;
        nan_count = nan_count +1;
    end

end