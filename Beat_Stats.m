%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% Beat_Stats.m -- Statistics on first pass annotation
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

classdef Beat_Stats
% This class computes statistics on various beat intervals
    
    properties  (SetAccess=private)
        qrs_median
        qrs_min
        qrs_max
        qrs_iqr
        
        jt_median
        jt_min
        jt_max
        jt_iqr
        
        qt_median
        qt_min
        qt_max
        qt_iqr
        
    end
    
    methods
        
        % Main constructor
        
        function obj = Beat_Stats(beats, sample_time)
            
            % Create a 'default' Annoparam class with default values
            if nargin == 0; return; end
            
            if nargin == 1
                error('Too few inputs: Beats_Stats class takes Beats class as only input');
            end
            
            if nargin >2
                error('Too many inputs: Beats_Stats class takes Beats class as only input');
            end
            
            if nargin == 2
                
                qrs = sample_time*(beats.S - beats.Q);
                jt = sample_time*(beats.Tend - beats.S);
                qt = sample_time*(beats.Tend - beats.Q);
                
                obj.qrs_median = median(qrs,'omitnan');
                obj.qrs_min = min(qrs);
                obj.qrs_max = max(qrs);
                obj.qrs_iqr = iqr(qrs);
                
                obj.jt_median = median(jt,'omitnan');
                obj.jt_min = min(jt);
                obj.jt_max = max(jt);
                obj.jt_iqr = iqr(jt);
                
                obj.qt_median = median(qt,'omitnan');
                obj.qt_min = min(qt);
                obj.qt_max = max(qt);
                obj.qt_iqr = iqr(qt);
                
                
            end   % End  nargin == 1
            
        end   % End Constructor
        
        
        
        function labels = labels(obj); labels = properties(obj)'; end   
        
        
        
%         function values = values(obj)    
%             txt_labels = properties(obj);
%             values = zeros(1, length(txt_labels));
%              for i = 1:length(txt_labels)  
%                  values(i) = obj.(txt_labels{i});
%              end
%         end
        
        function v = cells(obj)
            l = obj.labels();
            N = length(l);
            v = cell(1, N);
            vector_names = []; % these are nested cells
            
            for i = 1:N
                v{i} = obj.(l{i});
                
                if any(strcmp(l{i}, vector_names))
                    v{i} = num2str(obj.(l{i}));
                end
                
            end
        end
        
        
    end  % End Methods
    
end    % End class

