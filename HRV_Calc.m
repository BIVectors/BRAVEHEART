%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% HRV_Calc.m -- Basic HRV parameters
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



classdef HRV_Calc
% Computes indices of HRV based on a Beats class object input
	
	properties (SetAccess=private)
		
		RR_n        % RR intervals for beats after PVC/outlier/manual beat removal (ms)
        RR          % RR intervals for all beats (ms)

        RR_sd_n     % Successive differences of RR intervals for beats after PVC/outlier/manual beat removal (ms)
        RR_sd       % Successive differences of all RR intervals (ms)

        RR_pct_n    % Percent change in RR_n (beats after PVC/outlier/manual beat removal (ms))
        RR_pct      % Percent change in RR (all beats (ms))

        SDNN        % Standard deviation of RR_n (beats after PVC/outlier/manual beat removal (ms))
        SDRR        % Standard deviation of RR (all beats (ms))

        RMSSD_n     % RMS of successive differences for beats after PVC/outlier/manual beat removal (ms)
        RMSSD_all   % RMS of successive differences for all beats (ms)        

	end
	
	methods
		
		function obj = HRV_Calc(varargin)
			if nargin == 0; return; end
			if nargin ~= 2 || ~isa(varargin{1}, 'Beats') || ~isnumeric(varargin{2}); error('HRV_Calc expected 2 arguments (Beats Class Object and number [sample time in ms]) to HRV_Calc constructor'); end
			
            % Input arguments
            B = varargin{1};
            sample_time = varargin{2};

            % 1st regenerate the list of QRS complexes (R peaks) without
            % removal of any outliers, PVCs, manual, or bad beats.  This may
            % not be what is ultimately needed, but removal of beats creates some issues
            % with how HRV is calculated.
    
            all_beats = vertcat(B.QRS, B.QRS_rem_outlier, B.QRS_rem_pvc, B.QRS_rem_manual, B.QRS_rem_bad);
            [all_beats, srt_idx] = sort(all_beats);

            % Need markers for what each beat is to determine if its
            % included in HRV.  Mark beats that were removed as = 1

            markers = vertcat(zeros(length(B.QRS),1) , ones((length(B.QRS_rem_outlier) + length(B.QRS_rem_pvc) + ...
                length(B.QRS_rem_manual) + length(B.QRS_rem_bad)),1));
            markers = markers(srt_idx);

            % Get RR intervals for all beats regardless of PVC, outliers, etc
            obj.RR = diff(all_beats) * sample_time;

            % Get RR intervals for all "Normal" (NSR) beats
            % BRAVEHEART can't determine that a beat is "sinus" vs paced,
            % or a PAC/PVC etc (PVC detection is a morphology detector), but 
            % will assume that the included beats are "NSR" after outliers
            % and PVCs are removed.  This may NOT always be the case...
            % BRAVHEART also does not determine if AF or SR etc...

            % This is a bit tricky because the R peaks may be fine but a
            % beat may be excluded due to noise that obscures other
            % fiducial point detection.  This is why report SDNN and SDRR etc


            % For SDNN only include a beat if the beat and the beat before
            % it were not removed from list of all beats.  Because looking
            % at beat i+1 compared to beat i, only matters if beat i or i+1
            % were marked for removal (do not care if beat i-1 was removed)

            RR_n = zeros(1,length(all_beats)-1);
            RR_pct_n = [];
            
            for i = 1:length(all_beats)-1
                if markers(i+1) == 0 && markers(i) == 0
                    RR_n(i) = all_beats(i+1) - all_beats(i);
                end
            end

            % Remvoe 0 values and make column vector to be consistent
            RR_n(RR_n==0) = [];
            if isrow(RR_n)
                RR_n = RR_n';
            end

            if ~isempty(RR_n)
                obj.RR_n = RR_n * sample_time;
            else
                obj.RR_n = [];
            end


            % Percent changes for subsequent RR intervals

            for i = 1:length(obj.RR)-1
                RR_pct(i+1) = 100 * ((obj.RR(i+1) - obj.RR(i)) / (obj.RR(i)));
            end
            obj.RR_pct = round(RR_pct,3)';

            for i = 1:length(obj.RR_n)-1
                RR_pct_n(i+1) = 100 * ((obj.RR_n(i+1) - obj.RR_n(i)) / (obj.RR_n(i)));
            end
            obj.RR_pct_n = round(RR_pct_n,3)';



            % Absolute changes for subsequent RR intervals
            if ~isempty(diff(obj.RR_n))
                obj.RR_sd_n = [0 ; diff(obj.RR_n)];
            else
                obj.RR_sd_n = [];
            end

            if ~isempty(diff(obj.RR))
                obj.RR_sd = [0 ; diff(obj.RR)];
            else
                obj.RR_sd = [];
            end


            % Calculations
            obj.SDRR = std(obj.RR);
            obj.SDNN = std(obj.RR_n);

            obj.RMSSD_all = rms(diff(obj.RR));
            obj.RMSSD_n = rms(diff(obj.RR_n));


        end % End main function



    end    % End Methods

end   % End Class