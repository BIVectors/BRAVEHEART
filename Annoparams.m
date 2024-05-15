%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% Annoparams.m -- Annoparams class for controlling BRAVEHEART function
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


classdef Annoparams
% stores parameters which control the behavior of the annotation algorithm 

% These can be customized per-ecg; the constructor and to-file methods provide
% deserialization and serialization to help with this

% Because we have so far stored the annotation parameters and fiducial points together,
% the constructor can also optinally return a Beats object
  
	properties
		
		% For ease of transfering parameters, use 0 and 1 instead of False and True

        % See BRAVEHEART user guide (available on GitHub) for details about
        % each of the parameters below
		
		% Load in ECG/peak detection
		maxBPM = 150;                    % Sets window for detecting R peaks
		pkthresh = 95;                   % Percentile of ECG signal above which a peak can be found
		lowpass = 1;                     % Low pass wavelet filter on/off
		highpass = 1;                    % High pass wavelet filter on/off
		wavelet_level_lowpass = 1;       % LPF freq is > samp freq/2^(wavelet_level_lowpass + 1)
		wavelet_level_highpass = 10;     % HPF freq is < samp freq/2^(wavelet_level_highpass + 1)
		wavelet_name_lowpass = 'sym4';   % Low-pass wavelet (sym4, sym5, sym6, db4, db8, db10, etc)
		wavelet_name_highpass = 'db4';   % High-pass wavelet (sym4, sym5, sym6, db4, db8, db10, etc)
		baseline_correct_flag = 1;       % Corrects baseline offset
		
		% Transformation matrix
		transform_matrix_str = 'Kors';   % Kors or Dower transformation matrix
		
		% Baseline/origin flag
		baseline_flag = 'zero_baseline'; % Zero reference for area calculations
		origin_flag = 'zero_origin';     % Origin for VCG plotting
		
        % Parameters for auto QRS width estimation
		autoMF = 1;                      % Auto estimate QRS width
		autoMF_thresh = 20;              % Percent Rpeak threshold if autoMF = true
		MF_width = 40;                   % Length of median filter (in ms) used when autoMF = true
        
		% Fiducial point parameters (see documentation for more details)
		QRwidth = 100;                   % Width of QR search window in ms
		RSwidth = 100;                   % Width of RS search window in ms
		STstart = 100;                   % Distance between Qoff and start of Tend search window in ms
		STend = 45;                      % Length of Tend search window as a percent of RR interval

		% Pacer spike removal
		spike_removal = 1;               % Remove pacemaker spikes
		pacer_spike_width = 20;          % Max width of pacing spike (in ms)
		pacer_mf = 4;                    % Pacer spike detection median filter (in ms)
		pacer_thresh = 20;               % Percent peak of pacer spike used for spike removal
		
		% Beat alignment
		align_flag = 'CoV';              % Beat alignment method ('CoV' or 'Rpeak')
		cov_mf = 40;                     % width of CoV median filter (in ms)
		cov_thresh = 30;                 % CoV median filter threshold %
		shiftq = -40;                    % Q window expand when calculating median beat (in ms)
		shiftt = 60;                     % T window expand when calculating median beat (in ms)
		%window_rrfrac = 1.0;            % limit median beat window to this fraction of the median RR interval
		
		% Tend detection method
		Tendstr = 'Energy';              % Tend detection method ('Energy', 'Tangent', or 'Baseline')
		
		% Median reannotation method
		median_reanno_method = 'NNet';   % 'NNet' for neural network and 'Std' for standard annotations
		
		% Outlier, pacing spike, PVC removal
		outlier_removal = 1;             % Remove outliers
        modz_cutoff = 4;                 % Cutoff for mod Z-score to flag an outlier (higher less sensitive)
		pvc_removal = 1;                 % Remove PVCs
		pvcthresh = 0.95;                % Cross correlation threshold for PVC removal
        rmse_pvcthresh = 0.1;            % Normalized RMSE threshold for PVC removal
		keep_pvc = 0;                    % Set = 1 if PVC removal removes native QRS instead of PVCs
		
		% Speed calculations
		blanking_window_q = 0;           % Blanking window after QRS onset (in ms) to ignore in speed calcs
        blanking_window_t = 20;          % Blanking window after TW onset (in ms) to ignore in TW speed calcs
        
		% Misc
		debug = 0;                       % Debug mode (generates debug annotation figures)
		
	end
	
	methods
		
		% Constructor
		function [obj, fidpts] = Annoparams(varargin)
			
			if nargin >1
				error('Too many input arguments: Annoparams constructor takes 0 or 1 input (.anno file)');
			end
			
			
			% Create a 'default' Annoparam class with default values
			if nargin == 0;
                
                % If running as executable, load annoparams from
                % Annoparams.csv from the executable directory, otherwise
                % pull values from the defaults above
                
                if ~isdeployed     
                    return;                
                else
                    prop = properties(obj);
                    length_prop = length(prop);    
                    
                    currentdir = getcurrentdir();      

                    raw = readcell(fullfile(currentdir,'Annoparams.csv')); % read in data from .csv file

                    % Now read in Annoparams
                    for i = 1:length(prop)

                        % Find index of prop(i) in csv file (account for
                        % rearranging order of properties in future)
                        idx = find(strcmp(raw(:,1), prop(i)));
                        % perhaps the property wasn't set? - helps with backwards compatibility
                        if isempty(idx)
                            warning('Couldn''t find property %s in Annoparams.csv external file - check for formatting errors', prop{i});
                            continue;
                        end

                        % Assign property(i) to value of row with same name in csv file
                        obj.(prop{i}) = cell2mat(raw(idx,2));
                    end        
                end     % End isdeployed           
            end         % End if nargin == 0
			
			
			
			% If pass in a filename will create Annoparam class based on file
			if nargin == 1
				csv_filename = varargin{1};
				ap = Annoparams();  % Generate default Annoparam to get property list
				
				% read data from csv or xls
				% If this throws an error, check to see if your csv's are actually xls - this happened in the old version
				% if so, you can fix by renaming
				raw = readcell(csv_filename, 'FileType','Text');
				
				% Load properties list from Annoparams
				prop = properties(ap);
				length_prop = length(prop);
				
				% calculate length of the csv (number of rows)
				firstcol = raw(:, 1);
				length_csv = length(firstcol);
				length_fidpts = find(~isCellNumeric(firstcol), 1)-1;
				
				% Fidpts are the n rows prior to the list of properties that make up Annoparams
				% Check if fidpts are present or if this is just a Annoparam import
				if length_fidpts ~= length_csv-length_prop
					warning('Actual number of properties %d does not match expected %d in file %s', ...
						length_fidpts, length_csv-length_prop, csv_filename);
				end
				
				% Separate fidpts from rest of Annoparams
				
				if length_fidpts > 0     % If true there is atleast 1 beat in fidpts
					fidpts = cell2mat(raw(1:length_fidpts,1:4));     % Convert to numeric matrix
					fidpts = Beats(fidpts(:,1), fidpts(:,2), fidpts(:,3), fidpts(:,4));    % Convert to Beat Class
					
				else    % File only has Annoparams, so import blank fidpts
					fidpts = [];
					
				end
				
				% Now read in Annoparams
				for i = 1:length(prop)
					
					% Find index of prop(i) in csv file (account for
					% rearranging order of properties in future)
					idx = find(strcmp(raw(:,1), prop(i)));
					% perhaps the property wasn't set? - helps with backwards compatibility
					if isempty(idx)
						warning('Couldn''t find property %s in file %s', prop{i}, csv_filename);
						continue;
					end
					
					% Assign property(i) to value of row with same name in csv file
					obj.(prop{i}) = cell2mat(raw(idx,2));
					
				end
			end  % End nargin == 1
		end  % End generation function
		
		
		
		% Save parameters to file
		function to_file(varargin)
			
			% Error if incorrect number of inputs
			if nargin < 2 || nargin > 3
				error('Incorrect number of input arguments: Annoparams.to_file takes 1 (.anno file) or 2 (Beats class, .anno file) inputs');
			end
			
			if nargin == 3  % Pass in beatmatrix and filename
				assert(isa(varargin{2}, 'Beats'));
				assert(ischar(varargin{3}));
				obj = varargin{1};
				beatmatrix = varargin{2};
				beatmatrix = beatmatrix.beatmatrix();
				csv_filename = varargin{3};
			end
			
			if nargin == 2  && ischar(varargin{2}) % Pass in only filename
				assert(ischar(varargin{2}));
				obj = varargin{1};
				csv_filename = varargin{2};
				beatmatrix = [];
			end
			
			% Generate Annoparam property list
			prop = properties(obj);
			
			% Process beatmatrix/Beat class if present
			if ~isempty(beatmatrix)
				
				% convert beatmatrix (fiducial points) to cell format
				beatmatrix_data = num2cell(beatmatrix);
				
			else
				
				beatmatrix_data= [];
				
			end
			
			% Save Annoparams
			for i = 1:length(prop)
				anno_data(i,1) = {prop{i}};
				anno_data(i,2) = {obj.(prop{i})};
				anno_data(i,[3 4]) = {' '};
				
			end
			
			% Combine beatmatrix_data and anno_data
			export_data = [beatmatrix_data ; anno_data];
			
			% Save
			writecell(export_data,csv_filename,'FileType','Text');
			
		end  % End save to file function
		
		
		% Generates fiducial point parameters in samples
		function s = QRsamp(obj, hz); s = round(obj.QRwidth*hz/1000); end
		function s = RSsamp(obj, hz); s = round(obj.RSwidth*hz/1000); end
		function s = STstartsamp(obj, hz); s = round(obj.STstart*hz/1000); end
		function s = STendsamp(obj, RR); s = round(0.01*obj.STend*RR); end
		function s = MF_width_samp(obj, hz); s = round(obj.MF_width*hz/1000); end
		function s = pacer_spike_width_samp(obj, hz); s = round(obj.pacer_spike_width*hz/1000); end
		function s = pacer_mf_samp(obj, hz); s=round(obj.pacer_mf*hz/1000); end
		function s = cov_mf_samp(obj, hz); s=round(obj.cov_mf*hz/1000); end
		function s = shiftq_samp(obj, hz); s=round(obj.shiftq*hz/1000); end
		function s = shiftt_samp(obj, hz); s=round(obj.shiftt*hz/1000); end
		
		
		function labels = labels(obj); labels = properties(obj)'; end
		
		
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
