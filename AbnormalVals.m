%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% AbnormalVals.m -- Class for assigning values as normal or abnormal.
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


classdef AbnormalVals
    
    % Value = 0 if within normal range
    % Value = 1 if ABOVE normal range
    % Value = -1 if BELOW normal range
	
	properties (SetAccess=immutable)
        
        % These properties are used to obtain the normal values
		age
        male
        bmi
        white
        hr
        
        % Properties here are pairs of values [LLN ULN] based on age, gender, bmi, race, and HR     
        svg_area_mag
		svg_area_az
		svg_area_el

		sai_vm
		sai_qrst
        
        svg_x
        svg_y
        svg_z
		
% 		q_area_mag
% 		q_area_az
% 		q_area_el
% 		t_area_mag
% 		t_area_az
% 		t_area_el
%         
		qrst_angle_area
		qrst_angle_peak
		
% 		vcg_length_qrst
% 		vcg_length_qrs
% 		vcg_length_t
% 		
		
	end
	
	methods
		
		function obj = AbnormalVals(varargin)
		if nargin == 0; return; end
        
        if nargin ~= 2; error('Expected 2 arguments to NormalVals constructor: VCG_Calc and NormalVals'); end
     
			geh = varargin{1};
            nml = varargin{2};
            
            obj.age = nml.age;
            obj.male = nml.male;
            obj.bmi = nml.bmi;
            obj.hr = nml.hr;
            obj.white = nml.white;
            
            fields = nml.labels();
        
            for i = 6:nml.length()

              tmp_val = nml.(fields{i});    % Gives low/high range for normal for each field in class

              obj.(fields{i}) = 0;          % Normal flag = 0 as default
              
              % Mark as -1 if value in geh is BELOW normal range
              if geh.(fields{i}) < tmp_val(1)
                 obj.(fields{i}) = -1;    % Abnormal flag = -1
              else
                    % Do nothing
              end
              
              % Mark as 1 if value in geh is ABOVE normal range
              if geh.(fields{i}) > tmp_val(2)
                 obj.(fields{i}) = 1;    % Abnormal flag = 1
              else
                    % Do nothing
              end

               
            end

        
        end
        
    end
    
    methods(Static)
        function l = length(); a = AbnormalVals(); l = length(properties(a)); end
        
        function labels = labels(); obj = AbnormalVals(); labels = properties(obj); end
        
            
    end
    
end