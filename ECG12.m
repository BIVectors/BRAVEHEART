%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% ECG12.m -- ECG Object Class
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


classdef ECG12
% The ECG12 constructor reads a digitized 12-lead ECG from a file
% If sample values and no metadata are supplied, then the frequency and units must be inferred or otherwise provided
% An instance can return a filtered version of itself and construct a median beat

    properties (SetAccess=private)
        hz
        units
        I
        II
        III
        avF
        avL
        avR
        V1
        V2
        V3
        V4
        V5
        V6
        
    end
    methods
        function obj = ECG12(varargin)
            if nargin == 0; return; end
            if nargin == 14
                [obj.hz, obj.units, ...
                    obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                    obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = varargin{:};
            elseif nargin == 10
                [obj.hz, obj.units, ...
                    obj.I, obj.II, ...
                    obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = varargin{:};
                obj.III = -obj.I + obj.II;
                obj.avF = obj.II - 0.5*obj.I;
                obj.avR = -0.5*obj.I - 0.5*obj.II;
                obj.avL = obj.I - 0.5*obj.II;
            elseif nargin == 2
                [filename, format] = varargin{:};
                obj.units='mV';
                
                % ADD NEW ECG FORMATS TO THIS SWITCH STATEMENT
                switch format
                    
                    case 'bidmc_format'
                        obj.hz=500;
                        unitspermv=200;
                        [obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = load_ecg(filename, unitspermv, format);
                        
                    case 'muse_xml'
						[obj.hz, obj.I, obj.II, obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = ...
							load_musexml(filename);
                        obj.III = -obj.I + obj.II;
                        obj.avF = obj.II - 0.5*obj.I;
                        obj.avR = -0.5*obj.I - 0.5*obj.II;
                        obj.avL = obj.I - 0.5*obj.II;
                    
                    case 'prucka_format'
                        obj.hz=997;
                        unitspermv=1;
                        [obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = load_ecg(filename, unitspermv, format);
                        
                    case 'unformatted'
                        unitspermv=1;
                        [obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6, obj.hz] = load_unformatted(filename);    
                    
                    case 'philips_xml'
                        [obj.hz, obj.I, obj.II, obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = ...
							load_philipsxml(filename);
                        obj.III = -obj.I + obj.II;
                        obj.avF = obj.II - 0.5*obj.I;
                        obj.avR = -0.5*obj.I - 0.5*obj.II;
                        obj.avL = obj.I - 0.5*obj.II;
					
                    case 'ISHNE'
                        [obj.hz, obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = load_ISHNE(filename);
                    
                    case 'mrq_ascii'
                        [obj.hz, obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = load_mrq(filename);   
                    
                    case 'DICOM'
                        [obj.hz, obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = load_dicom(filename);                    
                    
                    case 'hl7_xml'
                        [obj.hz, obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = load_hl7xml(filename); 

                    case 'generic_csv'
                        unitspermv=200;
                        obj.hz=500;
                        [obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, ...
                            obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6] = load_generic_csv(filename, unitspermv);

					
                    otherwise
                        error('unknown format %s', format);
                end
            else
                error('ECG12: invalid number of arguments %d', nargin);
            end
            
            % Error handeling if file doesn't parse correctly
            fn = fieldnames(ECG12());
            for i = 3:length(fn)
                if isempty(obj.(fn{i}))
                    error(sprintf('%s seems to be incorrect - could not find ECG data in file',format));
                end
            end
            
            if isrow(obj.I); obj.I = obj.I'; end
            if isrow(obj.II); obj.II = obj.II'; end
            if isrow(obj.III); obj.III = obj.III'; end
            if isrow(obj.avL); obj.avL = obj.avL'; end
            if isrow(obj.avF); obj.avF = obj.avF'; end
            if isrow(obj.avR); obj.avR = obj.avR'; end
            if isrow(obj.V1); obj.V1 = obj.V1'; end
            if isrow(obj.V2); obj.V2 = obj.V2'; end
            if isrow(obj.V3); obj.V3 = obj.V3'; end
            if isrow(obj.V4); obj.V4 = obj.V4'; end
            if isrow(obj.V5); obj.V5 = obj.V5'; end
            if isrow(obj.V6); obj.V6 = obj.V6'; end
        end
        
        function [obj, highpass_lvl_min] = filter(obj, maxRR_hr, aps)
            
            % maxRR_hr is needed for auto HPF level calculation
            % highpass_lvl_min is level chosen by auto (if used)
            [obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6, highpass_lvl_min] = ...
                ecgfilter(obj.I, obj.II, obj.III, obj.avR, obj.avF, obj.avL, obj.V1, obj.V2, obj.V3, obj.V4, obj.V5, obj.V6, ...
                obj.hz, maxRR_hr, ...
                aps.lowpass, aps.wavelet_level_lowpass, aps.wavelet_name_lowpass, ...
                aps.highpass, aps.wavelet_level_highpass, aps.wavelet_name_highpass);
            if isrow(obj.I); obj.I = obj.I'; end
            if isrow(obj.II); obj.II = obj.II'; end
            if isrow(obj.III); obj.III = obj.III'; end
            if isrow(obj.avL); obj.avL = obj.avL'; end
            if isrow(obj.avF); obj.avF = obj.avF'; end
            if isrow(obj.avR); obj.avR = obj.avR'; end
            if isrow(obj.V1); obj.V1 = obj.V1'; end
            if isrow(obj.V2); obj.V2 = obj.V2'; end
            if isrow(obj.V3); obj.V3 = obj.V3'; end
            if isrow(obj.V4); obj.V4 = obj.V4'; end
            if isrow(obj.V5); obj.V5 = obj.V5'; end
            if isrow(obj.V6); obj.V6 = obj.V6'; end

        end
        
        function c = write(obj, file, format, freq)
            [fid, err] = fopen(file, 'w');
            if fid == -1; error('opening %s for writing: %s', file, err); end
            switch format   % Note: doesn't account for differences in gain between input and output formats
                case 'bidmc_format' %%% BIDMC txt file
                    u = 200.0;
                    c = fprintf(fid, '%d %d %d %d %d %d %d %d %d %d %d %d %d\n', round([ (1:length(obj.I))'   ...
                        u*obj.I  u*obj.II  u*obj.III  u*obj.avR  u*obj.avF  u*obj.avL  ...
                        u*obj.V1  u*obj.V2  u*obj.V3  u*obj.V4  u*obj.V5  u*obj.V6 ])');
                case 'prucka_format'
                    u = 1;
                    c = fprintf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f\n', ...
                        [u*obj.I u*obj.II u*obj.III u*obj.avR u*obj.avF u*obj.avL ...
                        u*obj.V1 u*obj.V2 u*obj.V3 u*obj.V4 u*obj.V5 u*obj.V6]'); 
                case 'unformatted'
                    u = 1;
                    c = fprintf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f\n', ...
                        [[freq; u*obj.I] [freq; u*obj.II]  [freq; u*obj.III] ...
                        [freq; u*obj.avR] [freq; u*obj.avF] [freq; u*obj.avL] ...
                        [freq; u*obj.V1]  [freq; u*obj.V2]  [freq; u*obj.V3] ...
                        [freq; u*obj.V4]  [freq; u*obj.V5]  [freq; u*obj.V6]]'); 
%                 case 'muse_xml'   % Not ready yet
%                     u = 205;   % 4.88 uV resolution
%                     xml = write_muse_xml_file(obj);
%                     fprintf(fid, xml);
                    
                otherwise
                    error('ECG12.write(): unknown format %s', format);
            end
            fclose(fid);
        end
                
        
        function [medbeat_12L, beatsig_ecg_12L] = medianbeat(obj, startb, endb) % not sure how to return or store beatsig atm
            [medbeat_I, beatsig_I] = medianbeat(obj.I, startb, endb);
            [medbeat_II, beatsig_II] = medianbeat(obj.II, startb, endb);
            [medbeat_III, beatsig_III] = medianbeat(obj.III, startb, endb);
            [medbeat_avR, beatsig_avR] = medianbeat(obj.avR, startb, endb);
            [medbeat_avF, beatsig_avF] = medianbeat(obj.avF, startb, endb);
            [medbeat_avL, beatsig_avL] = medianbeat(obj.avL, startb, endb);
            
            [medbeat_V1, beatsig_V1] = medianbeat(obj.V1, startb, endb);
            [medbeat_V2, beatsig_V2] = medianbeat(obj.V2, startb, endb);
            [medbeat_V3, beatsig_V3] = medianbeat(obj.V3, startb, endb);
            [medbeat_V4, beatsig_V4] = medianbeat(obj.V4, startb, endb);
            [medbeat_V5, beatsig_V5] = medianbeat(obj.V5, startb, endb);
            [medbeat_V6, beatsig_V6] = medianbeat(obj.V6, startb, endb);
            
            medbeat_12L = ECG12(obj.hz, obj.units, medbeat_I, medbeat_II, medbeat_III, ...
                    medbeat_avR, medbeat_avF, medbeat_avL, ...
                    medbeat_V1, medbeat_V2, medbeat_V3, medbeat_V4, medbeat_V5, medbeat_V6);
            beatsig_ecg_12L = ECG12(obj.hz, obj.units, beatsig_I, beatsig_II, beatsig_III, ...
                    beatsig_avR, beatsig_avF, beatsig_avL, ...
                    beatsig_V1, beatsig_V2, beatsig_V3, beatsig_V4, beatsig_V5, beatsig_V6);
		end
        
		function [ecg1, ecg2] = split(obj, idx)
			ecg1 = ECG12();
			ecg2 = ECG12();
			ecg1.I   = obj.I(1:idx);   ecg2.I   = obj.I(idx+1:end);
			ecg1.II  = obj.II(1:idx);  ecg2.II  = obj.II(idx+1:end);
			ecg1.III = obj.III(1:idx); ecg2.III = obj.III(idx+1:end);
			ecg1.avF = obj.avF(1:idx); ecg2.avF = obj.avF(idx+1:end);
			ecg1.avL = obj.avL(1:idx); ecg2.avL = obj.avL(idx+1:end);
			ecg1.avR = obj.avR(1:idx); ecg2.avR = obj.avR(idx+1:end);
			ecg1.V1  = obj.V1(1:idx);  ecg2.V1  = obj.V1(idx+1:end);
			ecg1.V2  = obj.V2(1:idx);  ecg2.V2  = obj.V2(idx+1:end);
			ecg1.V3  = obj.V3(1:idx);  ecg2.V3  = obj.V3(idx+1:end);
			ecg1.V4  = obj.V4(1:idx);  ecg2.V4  = obj.V4(idx+1:end);
			ecg1.V5  = obj.V5(1:idx);  ecg2.V5  = obj.V5(idx+1:end);
			ecg1.V6  = obj.V6(1:idx);  ecg2.V6  = obj.V6(idx+1:end);
			ecg1.hz = obj.hz; ecg2.hz = obj.hz;
			ecg1.units = obj.units; ecg2.units = obj.units;
		end


        function t = sample_time(obj); t = 1000/obj.hz; end
		function l = length(obj); l = length(obj.I); end
        % default copy, destructor, assignment
    end
    
    
end
