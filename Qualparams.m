%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% Qualparams.m -- Qualparams class for controlling BRAVEHEART quality assessment
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


classdef Qualparams
% stores parameters which control the behavior of ECG quality assessment 

	properties
		
		% Class to store quality parameters.  When using MATLAB set values
        % in this file.  When using a compiled executable the Qualparams
        % class object will pull values from the external Qualparams.csv
        % file.  It is also possible to generate a Qualparams class object
        % from an external file with the location/name specified in the
        % constructor.

        % See BRAVEHEART user guide (available on GitHub) for details about
        % each of the parameters below.

        % For each parameter, values are entered as a pair of [min, max]
        % values, and values are flagged if they are OUTSIDE of the [min,
        % max] range entered.  Values EQUAL to the min and max values are
        % NOT flagged.

        % Use of Inf or -Inf will allow setting just values > or < a specific 
        % number: e.g. [1, Inf] will allow all values >= 1, so only values
        % < 1 will be flagged.  Similarly, [-Inf, 4] will allow all values
        % <= 4, so only values > 4 will be flagged.

        % To DISABLE a specific quality flag, set to [-Inf,Inf]

		
        qrs = [60 200];                  % Min/max range of QRS duration
        qt = [250 700];                  % Min/max range of QT interval
        tpqt = [0.5 Inf];                % Min/max range of T peak/QT ratio (nominal is min only)
        t_mag = [0.05 Inf];              % Min/max range for T wave magnitude (nominal is min only)
        hr = [30 150];                   % Min/max range for HR
        num_beats = [4 Inf];             % # of beats left after PVC and outlier beats are removed
        pct_beats_removed = [-Inf 60];   % of total number of beats removed to trigger
        corr = [0.8 1];                  % Min/max range for average normalized cross correlation (nomimal min only)
        baseline = [-Inf 0.1];           % Min/max range for baseline at the end of the T wave (nominal max only)
        hf_noise = [10 Inf];             % SNR for HF noise cutoff
        lf_noise = [-Inf 0.02];          % mV for cutoff in variance in LF noise
        prob = [0.8 1];                  % Logistic regression probability (range 0-1)

	end
	
	methods
		
		% Constructor
		function obj = Qualparams(varargin)
			
			if nargin >1
				error('Too many input arguments: Qualparams constructor takes 0 or 1 input (.csv file)');
			end
			
			% Create a 'default' Qualparams class with default values
			if nargin <= 1

                % Defauly to Quaparams.csv file if deployed.  Otherwise can
                % manually specify a file (although this isnt currently used)
                    if nargin == 0 && isdeployed
                        csv_filename = 'Qualparams.csv';
                    elseif nargin == 1
                        csv_filename = varargin{1};
                    end
                
                % If running as executable, load Qualparams from Qualparams.csv from the executable directory, 
                % otherwise pull values from the defaults above
                if nargin ==0 && ~isdeployed    
                    obj.check();
                    return;                
                else
                    prop = properties(obj);    
                    currentdir = getcurrentdir();
                    A = readcell(fullfile(currentdir,csv_filename)); % read in data from .csv file
                    
                    % Take first 3 columns and discard the rest
                    A = A(:,[1 2 3]); 

                    % Replace missing with Nan which will become Inf later
                    miss = cellfun(@(x) any(isa(x,'missing')), A);
                    A(miss) = {NaN};
                    
                    % Preset names
                    preset_names = A(:,1);

                    % Low values
                    preset_values_low = cell2mat(A(:,2));
                    preset_values_low(isnan(preset_values_low)) = -Inf;
                    
                    % High values
                    preset_values_high = cell2mat(A(:,3));
                    preset_values_high(isnan(preset_values_high)) = Inf;


                    % Now read in Qualparams
                    for i = 1:length(prop)

                        % Find index of prop(i) in csv file (account for
                        % rearranging order of properties in future)
                        idx = find(strcmp(preset_names, prop(i)));

                        % Perhaps the property wasn't set? - helps with backwards compatibility
                        if isempty(idx)
                            warning('Couldn''t find property %s in Qualparams.csv external file - check for formatting errors', prop{i});
                            continue;
                        end

                        % Assign property(i) to value of row with same name in csv file
                        obj.(prop{i}) = [preset_values_low(idx) preset_values_high(idx)];
                    end        
                end     % End isdeployed           
            end         % End if nargin == 0
			
        
        end  % End generation function
		
    % List labels
	function labels = labels(obj); labels = properties(obj)'; end


    % Check that each parameter is a [min,max] pair that is numeric
    function check(obj)
         prop = properties(obj);
         for i = 1:length(prop)
            assert(length(obj.(prop{i})) == 2, 'Qualparams property %s has %i parameter(s) when it should have 2 parameters',prop{i},length(obj.(prop{i})));
            assert(isnumeric(obj.(prop{i})),'Qualparams property %s is not numeric',prop{i});

         end
    end

	
	% Output values
	function values = values(obj)
		txt_labels = properties(obj);
		values = cell(1, length(txt_labels));
		for i = 1:length(txt_labels)
			values(i) = {obj.(txt_labels{i})};
		end
	end
	
	
	function v = cells(obj)
		l = obj.labels();
		N = length(l);
		v = cell(1, N);
		for i = 1:N
			v{i} = obj.(l{i});
		end
	end
		
		
	end    % End methods
	
end   % End class

function l = isCellNumeric(c)
l = cellfun(@(x) isnumeric(x), c);
end
