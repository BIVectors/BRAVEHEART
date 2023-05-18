%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% VCG_Calc.m -- VCG_Calc Results Class
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


classdef VCG_Calc
% Given a VCG and a Beats annotation, this class computes measurements of global electrical heterogeneity,
% as well as other vector and related quantities.
	
	properties (SetAccess=private)
		
		% SVG
		svg_x
		svg_y
		svg_z
		
		% SAI
		sai_x
		sai_y
		sai_z
		sai_vm
		sai_qrst
		
		% Peak vectors
		q_peak_mag
		q_peak_az
		q_peak_el
		t_peak_mag
		t_peak_az
		t_peak_el
		svg_peak_mag
		svg_peak_az
		svg_peak_el    
		
		% Area vectors
		q_area_mag
		q_area_az
		q_area_el
		t_area_mag
		t_area_az
		t_area_el
		svg_area_mag
		svg_area_az
		svg_area_el
        
        % QRST ratios
        peak_qrst_ratio
        area_qrst_ratio
		
		% Other angles
		svg_qrs_angle_area  % angle between area QRS and area SVG vectors
		svg_qrs_angle_peak  % angle between peak QRS and peak SVG vectors
		svg_t_angle_area    % angle between area T and area SVG vectors
		svg_t_angle_peak    % angle between peak T and peak SVG vectors
		svg_svg_angle       % angle between peak SVG and area SVG vectors
		svg_area_qrs_peak_angle  % angle between area SVG and peak QRS vectors
		
		% QRST angles
		qrst_angle_peak_frontal
		qrst_angle_area_frontal
		qrst_angle_area
		qrst_angle_peak
		
		% Misc
		% midpoint for VCG plotting
		X_mid
		Y_mid
		Z_mid
		
		% Areas of QRS (Q) and T wave (T) for X,Y,Z
		XQ_area
		YQ_area
		ZQ_area
		XT_area
		YT_area
		ZT_area
		
		% X,Y,Z componants of the peak vectors [QRS (Q) and T wave (T)]
		XQ_peak
		YQ_peak
		ZQ_peak
		XT_peak
		YT_peak
		ZT_peak
		
		% Speeds/Times
		speed_max
		speed_min
		speed_med
		time_speed_max
		time_speed_min
		speed_qrs_max
		speed_qrs_min
		speed_qrs_med
		time_speed_qrs_max
		time_speed_qrs_min
		speed_t_max
		speed_t_min
		speed_t_med
		time_speed_t_max
		time_speed_t_min
		
% 		% initial forces
% 		septum_speed_max
% 		septum_speed_X_max
% 		septum_speed_Y_max
% 		septum_speed_Z_max
% 		septum_t_speed_max
% 		septum_t_end
% 		septum_X_end
% 		septum_Y_end
% 		septum_Z_end
% 		septum_speed_avg
% 		septum_speed_X_avg
% 		septum_speed_Y_avg
% 		septum_speed_Z_avg
		
		% Distances
		qrst_distance_area
		qrst_distance_peak
		
		% Loop length
		vcg_length_qrst
		vcg_length_qrs
		vcg_length_t
		
		% VM T morphology
		vm_tpeak_time
		vm_tpeak_tend_abs_diff
		vm_tpeak_tend_ratio
		vm_tpeak_tend_jt_ratio
		
		% QRS/QT intervals (in ms)
		qrs_int
		qt_int
        baseline
	end
	
	methods
		
		function obj = VCG_Calc(varargin)
			if nargin == 0; return; end
			if nargin ~= 3; error('Expected 3 arguments to VCG Calc constructor'); end
			
			if isa(varargin{2}, 'Beats') && isa(varargin{1}, 'VCG') && isa(varargin{3}, 'Annoparams')
				
				v_uncropped = varargin{1}; medianbeat = varargin{2}; aps = varargin{3};
				if any(isnan(medianbeat.beatmatrix()))
					obj = VCG_Calc();
					p = properties(obj);
					for i=1:length(p); obj.(p{i}) = NaN; end
					return;
				end
				
				v_cropped = v_uncropped.crop(medianbeat.Q, medianbeat.Tend);
				qend = medianbeat.S-(medianbeat.Q-1);
				
				
			else
				
				%v = varargin{1}; qend = varargin{2}; aps = varargin{3};
				error('expected VCG, Beats, AP in VCG Calc constructor');
				
            end
            
            % ADD NEW MEASUREMENTS IN THIS SECTION
            
			[obj.svg_x, obj.svg_y, obj.svg_z, obj.svg_area_mag, obj.sai_x, obj.sai_y, obj.sai_z, obj.sai_qrst, obj.svg_qrs_angle_area, ...
				obj.svg_qrs_angle_peak, obj.svg_t_angle_area, obj.svg_t_angle_peak, obj.svg_area_el, obj.svg_area_az, ...
				obj.svg_peak_el, obj.svg_peak_az, obj.q_peak_el, obj.t_peak_el, obj.q_peak_az, obj.t_peak_az, ...
				obj.q_area_el, obj.t_area_el, obj.q_area_az, obj.t_area_az, obj.qrst_angle_peak_frontal, obj.qrst_angle_area_frontal, ...
				obj.qrst_angle_area, obj.qrst_angle_peak, obj.sai_vm, obj.q_peak_mag, obj.t_peak_mag, obj.q_area_mag, obj.t_area_mag, obj.svg_peak_mag, ...
				obj.X_mid, obj.Y_mid, obj.Z_mid, obj.XQ_area, obj.YQ_area, obj.ZQ_area, obj.XT_area, obj.YT_area, obj.ZT_area, ...
				obj.XQ_peak, obj.YQ_peak, obj.ZQ_peak, obj.XT_peak, obj.YT_peak, obj.ZT_peak, obj.svg_svg_angle, ...
				obj.speed_max, obj.speed_min, obj.speed_med, obj.time_speed_max, obj.time_speed_min, ...
				obj.speed_qrs_max, obj.speed_qrs_min, obj.speed_qrs_med, obj.time_speed_qrs_max, obj.time_speed_qrs_min, ...
				obj.speed_t_max, obj.speed_t_min, obj.speed_t_med, obj.time_speed_t_max, obj.time_speed_t_min, obj.svg_area_qrs_peak_angle, ...
				obj.qrst_distance_area, obj.qrst_distance_peak...
				] =  GEH_calculations(v_cropped.X, v_cropped.Y, v_cropped.Z, v_cropped.VM, v_cropped.sample_time(), qend, aps.baseline_flag, aps.blanking_samples, aps.origin_flag);
			
			obj.vcg_length_qrs = curve_length(v_cropped.X, v_cropped.Y, v_cropped.Z, 1, qend);
			obj.vcg_length_t = curve_length(v_cropped.X, v_cropped.Y, v_cropped.Z, qend, length(v_cropped.X));
			obj.vcg_length_qrst = curve_length(v_cropped.X, v_cropped.Y, v_cropped.Z, 1, length(v_cropped.X));
            
            obj.peak_qrst_ratio = obj.q_peak_mag/obj.t_peak_mag;
            obj.area_qrst_ratio = obj.q_area_mag/obj.t_area_mag;
			
            obj.baseline = baseline_voltage(v_uncropped, medianbeat);
			
			[vm_tpeak_time, vm_tpeak_tend_abs_diff, obj.vm_tpeak_tend_ratio, obj.vm_tpeak_tend_jt_ratio ] = tpeak_loc(medianbeat, (1000/v_uncropped.hz));
			
            % Convert samples to ms (don't need to do for ratio)
            obj.vm_tpeak_time = vm_tpeak_time*(1000/v_uncropped.hz);  
            obj.vm_tpeak_tend_abs_diff = vm_tpeak_tend_abs_diff*(1000/v_uncropped.hz);
            
			obj.qrs_int = (qend-1) * 1000/v_cropped.hz;
			obj.qt_int = (medianbeat.Tend - medianbeat.Q) * 1000/v_cropped.hz;
			
% 			% initial forces
% 			qrspct = aps.septumwindow;
% 			window = round(medianbeat.QRSdur() * qrspct/100);
% 			septumvcg = v_uncropped.crop(medianbeat.Q, medianbeat.Q+window);
% 						
% 			[obj.septum_t_speed_max, obj.septum_speed_max, obj.septum_speed_X_max, obj.septum_speed_Y_max, obj.septum_speed_Z_max, ...
% 				obj.septum_speed_avg, obj.septum_speed_X_avg, obj.septum_speed_Y_avg, obj.septum_speed_Z_avg, obj.septum_t_end] ...
% 				= septumspeed(septumvcg.X, septumvcg.Y, septumvcg.Z);
% 			if isempty(obj.septum_t_end) || isnan(obj.septum_t_end)
%                 obj.septum_t_end = NaN;
% 				obj.septum_X_end = NaN;
% 				obj.septum_Y_end = NaN;
% 				obj.septum_Z_end = NaN;
% 			else
% 				obj.septum_X_end = septumvcg.X(obj.septum_t_end);
% 				obj.septum_Y_end = septumvcg.Y(obj.septum_t_end);
% 				obj.septum_Z_end = septumvcg.Z(obj.septum_t_end);
% 			end
% 
% 			% these are reported relative to the QRS onset (medianbeat.Q)
% 			obj.septum_t_speed_max = obj.septum_t_speed_max * 1000/v_cropped.hz;
% 			obj.septum_t_end = obj.septum_t_end  * 1000/v_cropped.hz;
			
			
        end
		
        % Need .values() for sensitivity analysis to avoid issues with
        % nested cells.  Use .cells() for everything else
		function values = values(obj)
			txt_labels = properties(obj);
			values = zeros(1, length(txt_labels));
			for i = 1:length(txt_labels)
				if ~isempty(obj.(txt_labels{i}))
					values(i) = obj.(txt_labels{i});
				else
					values(i) = NaN;
				end
			end
        end
		
        
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

	end
	
	methods(Static)
		function l = length(); g = VCG_Calc(); l = length(properties(g)); end
		function labels = labels(); obj = VCG_Calc(); labels = properties(obj)'; end
        function a = allnan()
            a = VCG_Calc();
            p = properties(a);
            for i = 1:length(p)
                a.(p{i}) = nan;
            end
        end
	end
	
end
