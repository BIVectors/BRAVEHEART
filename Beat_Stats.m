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

        % HRV metrics -- may move these out to be stored a separate results class in
        % future if start adding more complex measures, but for now will
        % keep here to avoid having to do too much change to ECG
        % processing/reporting pipeline

        RR_n                % RR intervals for beats after PVC/outlier/manual beat removal (ms)
        RR_pct_n            % Percent change in RR_n (beats after PVC/outlier/manual beat removal (ms))
        RR_sd_n             % Successive differences of RR intervals for beats after PVC/outlier/manual beat removal (ms)
        
        RR                  % RR intervals for all beats (ms)
        RR_pct              % Percent change in RR (all beats (ms))
        RR_sd               % Successive differences of all RR intervals (ms)

        SDNN                % Standard deviation of RR_n (beats after PVC/outlier/manual beat removal (ms))
        SDRR                % Standard deviation of RR (all beats (ms))

        RMSSD_n             % RMS of successive differences for beats after PVC/outlier/manual beat removal (ms)
        RMSSD_all           % RMS of successive differences for all beats (ms)        
        
    end
    
    methods
        
        % Main constructor
        
        function obj = Beat_Stats(beats, sample_time)
            
            % Create a 'default' Annoparam class with default values
            if nargin == 0; return; end
            
            if nargin == 1
                error('Too few inputs: Beats_Stats class takes Beats class and sample_time as 2 inputs');
            end
            
            if nargin >2
                error('Too many inputs: Beats_Stats class takes Beats class and sample_time as 2 inputs');
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


                % HRV Parameters Holding Space -- May move this out in the future

                HRV = HRV_Calc(beats, sample_time);

                obj.RR_n = HRV.RR_n;                
                obj.RR_pct_n = HRV.RR_pct_n;            
                obj.RR_sd_n = HRV.RR_sd_n;             

                obj.RR = HRV.RR;                 
                obj.RR_pct = HRV.RR_pct;             
                obj.RR_sd = HRV.RR_sd;               

                obj.SDNN = HRV.SDNN;               
                obj.SDRR = HRV.SDRR;                

                obj.RMSSD_n = HRV.RMSSD_n;             
                obj.RMSSD_all = HRV.RMSSD_all;          
                
                
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
        
%         function v = cells(obj)
%             l = obj.labels();
%             N = length(l);
%             v = cell(1, N);
%             vector_names = []; % these are nested cells
%             
%             for i = 1:N
%                 v{i} = obj.(l{i});
%                 
%                 if any(strcmp(l{i}, vector_names))
%                     v{i} = num2str(obj.(l{i}));
%                 end
%                 
%             end
%         end



        function v = cells(obj)
            
            lab = obj.labels();
            v = cell(1, length(lab));
            for i = 1:length(lab)
                
                v{i} = mat2str(obj.(lab{i})');
                T = v{i};
                T(T=='[') = [];
                T(T==']') = [];
                v{i} = T;
                
            end
            
        end
        
        
    end  % End Methods
    
end    % End class

