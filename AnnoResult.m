%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% AnnoResult.m -- Utility class which stores the results of an annotation calculation and export it as a table
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


classdef AnnoResult
% Utility class which stores the results of an annotation calculation and export it as a table

	properties
		filename
        version
		note
		date
		time
		source
		freq
		num_samples
		num_beats
        initial_num_beats
		hr
        cross_corr 
        noise_hf
        noise_lf
        qual_prob
        missing_lead
		geh
		ap
		beat_stats
		beats
		lead_morph
        vcg_morph
	end
	
	methods
		function obj = AnnoResult(varargin)
			switch nargin
				case 0
					return;
				case 1
					ars = varargin{1};
					N = length(ars);
					p = properties(AnnoResult());
					for i=1:length(p)
						temp = cell(N, 1);
						for j=1:N
							if ~isempty(ars{j})
								temp{j} = ars{j}.(p{i});
							end
						end
						obj.(p{i}) = temp;
					end
					
					
				case 16
					[filename, note, source_str, ap, ecg, hr, num_initial_beats, beats, beat_stats, cross_corr, noise, qual_prob, missing_lead, geh, lead_morph, vcg_morph] = varargin{:};
					obj.filename = {filename};
					obj.note = {note};
					
					obj.geh = geh.cells();
					obj.lead_morph = lead_morph.cells();
                    obj.vcg_morph = vcg_morph.cells();
					obj.beat_stats = beat_stats.cells();
					obj.beats = beats.cells();
					obj.ap = ap.cells();
					obj.source = {source_str};
					obj.freq = {ecg.hz};
					obj.num_samples = {ecg.length()};
					obj.num_beats = {beats.length()};
					obj.date = {datestr(now,'mm/dd/yyyy')};
					obj.time = {datestr(now,'HH:MM')};
					
                    obj.initial_num_beats = num2cell(num_initial_beats);
                    obj.hr = num2cell(hr);  
                    
                    obj.cross_corr = num2cell(min([cross_corr.X cross_corr.Y cross_corr.Z]));
					obj.noise_hf = num2cell(noise(1));
                    obj.noise_lf = num2cell(noise(2));
                    
                    obj.qual_prob = num2cell(qual_prob);
                    obj.missing_lead = num2cell(missing_lead);

                    % VERSION MANUALLY UPDATED HERE
                    obj.version = {'1.1.0'};
                   
			end
		end
			
			function [excel_header, data] = export_data(obj)
				
				vcg_blank = VCG_Calc();
				lead_morph_blank = Lead_Morphology();
                vcg_morph_blank = VCG_Morphology();
				beats_blank = Beats();
				beat_stats_blank = Beat_Stats();
				aps_blank = Annoparams();
				
				
				info_labels = [{'filename'} {'version'} {'note'} {'proc_date'} {'proc_time'} {'source'} {'freq'} {'num_samples'} {'num_beats'} {'initial_num_beats'} {'hr'} {'cross_corr'} {'noise_hf'} {'noise_lf'} {'quality_prob'} {'missing_lead'}];
				% you have to do it this way in order to deal properly with the nested cells and with empty cells								
				excel_header = [info_labels vcg_blank.labels() aps_blank.labels() beat_stats_blank.labels() beats_blank.labels() lead_morph_blank.labels() vcg_morph_blank.labels()];				
				p = properties(obj);
				data = []; 
				for i = 1:length(p)
					temp = obj.(p{i});
					data = [data vertcat(temp{:})]; %#ok<AGROW>
				end
			end
			
		end
	end
