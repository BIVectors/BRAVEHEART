%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% NormalVals.m -- Class for storing normal values for select parameters
% Copyright 2016-2023 Hans F. Stabenau and Jonathan W. Waks
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


classdef NormalVals
	
	properties (SetAccess=immutable)
        % These properties are used to obtain the normal values
		age
        gender
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
		
		function obj = NormalVals(varargin)
			
        if nargin ~= 5 && nargin ~= 0; error('Expected 5 arguments to NormalVals constructor: Age (number),  Gender (string -- MALE or FEMALE), White race (1 or 0),  BMI (number), and HR (number).  If no input arguments will default to 50 yo white male with BMI 25 and HR 60'); end
			
            if nargin == 0   
                return;
            else
                obj.age = varargin{1};
                obj.gender = varargin{2};
                obj.white = varargin{3};
                obj.bmi = varargin{4};
                obj.hr = varargin{5};
                
                % Deal with missing values and assign defaults
                if isempty(obj.age)
                    obj.age = 50;
                end
                
                if isempty(obj.gender)
                    obj.gender = 'MALE';
                end
                
                if isempty(obj.bmi)
                    obj.bmi = 25;
                end
                
                if isempty(obj.hr)
                    obj.hr = 60;
                end
                
                if isempty(obj.white)
                    obj.white = 1;
                end
                
                
            end
                       
            % Get the age/gender/GMI/race/HR normal ranges and store in 'nvals'
            nvals = normal_ranges(obj.age, obj.gender, obj.bmi, obj.hr, obj.white);
            
            fn = fieldnames(NormalVals());
            
            for i = 6:length(fn)    % Skip the first 5 properties which are NOT normal value ranges
               obj.(fn{i}) = [nvals.low.(fn{i}) nvals.high.(fn{i})];       
            end
            
            
            
        end
            
    end
    
        methods(Static)
            
        function l = length(); a = NormalVals(); l = length(properties(a)); end
        
        function labels = labels(); obj = NormalVals(); labels = properties(obj); end
        
            
    end
    
    
end