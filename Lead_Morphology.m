%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% Lead_Morphology.m -- Lead_Morphology Results Class
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


classdef Lead_Morphology
% Various measurements on the 12-lead ECG, given an ECG and a Beats annotation
    
    properties (SetAccess=private)
        
                % 12 lead ECG properties        
        L1_r_wave      % R wave height
        L1_r_wave_loc  % Location of R peak (ms after QRS onset)
        L1_s_wave      % S wave height
        L1_s_wave_loc  % Location of S peak (ms after QRS onset)
        L1_rs_wave     % R+S wave (height of entire QRS complex)
        L1_rs_ratio    % R/(R+S) ratio
        L1_sr_ratio    % S/(R+S) ratio
        L1_t_max       % Max amplitude (pos or neg) of T wave
        L1_t_max_loc   % Location of T max (ms after QRS onset)
        L1_qrs_area    % Area of QRS complex
        L1_t_area      % Area of T wave
        L1_qrst_area   % Area of QRST complex
        L1_jpt         % Amplitude of signal at J point (QRS off)
        L1_jpt60       % Amplitude of signal at J point + 60 ms
        
        L2_r_wave
        L2_r_wave_loc
        L2_s_wave
        L2_s_wave_loc
        L2_rs_wave
        L2_rs_ratio
        L2_sr_ratio
        L2_t_max
        L2_t_max_loc
        L2_qrs_area
        L2_t_area
        L2_qrst_area
        L2_jpt
        L2_jpt60
        
        L3_r_wave
        L3_r_wave_loc
        L3_s_wave
        L3_s_wave_loc
        L3_rs_wave
        L3_rs_ratio
        L3_sr_ratio
        L3_t_max
        L3_t_max_loc
        L3_qrs_area
        L3_t_area
        L3_qrst_area
        L3_jpt
        L3_jpt60
        
        avF_r_wave
        avF_r_wave_loc
        avF_s_wave
        avF_s_wave_loc
        avF_rs_wave
        avF_rs_ratio
        avF_sr_ratio
        avF_t_max
        avF_t_max_loc
        avF_qrs_area
        avF_t_area
        avF_qrst_area
        avF_jpt
        avF_jpt60
        
        avL_r_wave
        avL_r_wave_loc
        avL_s_wave
        avL_s_wave_loc
        avL_rs_wave
        avL_rs_ratio
        avL_sr_ratio
        avL_t_max
        avL_t_max_loc
        avL_qrs_area
        avL_t_area
        avL_qrst_area
        avL_jpt
        avL_jpt60
        
        avR_r_wave
        avR_r_wave_loc
        avR_s_wave
        avR_s_wave_loc
        avR_rs_wave
        avR_rs_ratio
        avR_sr_ratio
        avR_t_max
        avR_t_max_loc
        avR_qrs_area
        avR_t_area
        avR_qrst_area
        avR_jpt
        avR_jpt60
        
        V1_r_wave
        V1_r_wave_loc
        V1_s_wave
        V1_s_wave_loc
        V1_rs_wave
        V1_rs_ratio
        V1_sr_ratio
        V1_t_max
        V1_t_max_loc
        V1_qrs_area
        V1_t_area
        V1_qrst_area
        V1_jpt
        V1_jpt60
        
        V2_r_wave
        V2_r_wave_loc
        V2_s_wave
        V2_s_wave_loc
        V2_rs_wave
        V2_rs_ratio
        V2_sr_ratio
        V2_t_max
        V2_t_max_loc
        V2_qrs_area
        V2_t_area
        V2_qrst_area
        V2_jpt
        V2_jpt60
        
        V3_r_wave
        V3_r_wave_loc
        V3_s_wave
        V3_s_wave_loc
        V3_rs_wave
        V3_rs_ratio
        V3_sr_ratio
        V3_t_max
        V3_t_max_loc
        V3_qrs_area
        V3_t_area
        V3_qrst_area
        V3_jpt
        V3_jpt60
        
        V4_r_wave
        V4_r_wave_loc
        V4_s_wave
        V4_s_wave_loc
        V4_rs_wave
        V4_rs_ratio
        V4_sr_ratio
        V4_t_max
        V4_t_max_loc
        V4_qrs_area
        V4_t_area
        V4_qrst_area
        V4_jpt
        V4_jpt60
        
        V5_r_wave
        V5_r_wave_loc
        V5_s_wave
        V5_s_wave_loc
        V5_rs_wave
        V5_rs_ratio
        V5_sr_ratio
        V5_t_max
        V5_t_max_loc
        V5_qrs_area
        V5_t_area
        V5_qrst_area
        V5_jpt
        V5_jpt60
        
        V6_r_wave
        V6_r_wave_loc
        V6_s_wave
        V6_s_wave_loc
        V6_rs_wave
        V6_rs_ratio
        V6_sr_ratio
        V6_t_max
        V6_t_max_loc
        V6_qrs_area
        V6_t_area
        V6_qrst_area
        V6_jpt
        V6_jpt60
        
        
        % X, Y, Z, VM Properties        
        X_r_wave
        X_r_wave_loc
        X_s_wave
        X_s_wave_loc
        X_rs_wave
        X_rs_ratio
        X_sr_ratio
        X_t_max
        X_t_max_loc
        X_jpt
        X_jpt60
        
        Y_r_wave
        Y_r_wave_loc
        Y_s_wave
        Y_s_wave_loc
        Y_rs_wave
        Y_rs_ratio
        Y_sr_ratio
        Y_t_max
        Y_t_max_loc
        Y_jpt
        Y_jpt60
        
        Z_r_wave
        Z_r_wave_loc
        Z_s_wave
        Z_s_wave_loc
        Z_rs_wave
        Z_rs_ratio
        Z_sr_ratio
        Z_t_max
        Z_t_max_loc
        Z_jpt
        Z_jpt60
        
        VM_r_wave
        VM_r_wave_loc
        VM_s_wave
        VM_s_wave_loc
        VM_rs_wave
        VM_rs_ratio
        VM_sr_ratio
        VM_t_max
        VM_t_max_loc
        VM_jpt
        VM_jpt60
        %VM_max_rpk_loc     % Location of maximum R peak (ms after QRS onset) - replaced with VM_r_wave_loc
     
         
%         % Individual beat SAI and SVG (X Y Z VM leads)
%         % Not using now...leaving in for future purposes
%         svg_x_individual             % Individual SVG values for each beat
%         svg_x_individual_median      % Median SVG value based on SVG for each beat (not median beat)
%         svg_x_individual_iqr         % SVG IQR value based on SVG for each beat (not median beat)
%         
%         svg_y_individual
%         svg_y_individual_median
%         svg_y_individual_iqr
%         
%         svg_z_individual
%         svg_z_individual_median
%         svg_z_individual_iqr
%         
%         sai_x_individual
%         sai_x_individual_median
%         sai_x_individual_iqr
%         
%         sai_y_individual
%         sai_y_individual_median
%         sai_y_individual_iqr
%         
%         sai_z_individual
%         sai_z_individual_median
%         sai_z_individual_iqr
%         
%         sai_vm_individual
%         sai_vm_individual_median
%         sai_vm_individual_iqr
        
       
        % LVH properties
        
        cornell_lvh_mv               % S in V3 + R in avL.  Units are mV not mm!  0.1 mV = 1 mm
        sokolow_lvh_mv               % S in V1 + R in V5 or V6.  Units are mV not mm!  0.1 mV = 1 mm


        % Frontal plane electrical axis
        qrs_frontal_axis               % QRS electrical axis from Einthoven triangle in frontal plane
        

    end
    
    
    methods
        
        function obj = Lead_Morphology(varargin)        % varagin: ECG12, VCG, Beats, Annoparams
            if nargin == 0; return; end
            if nargin ~= 4
                error('Lead_Morphology: expected 4 args in constructor, got %d', nargin);
            end
            
            assert(isa(varargin{1}, 'ECG12'), 'First argument is not a ECG12 class');
            assert(isa(varargin{2}, 'VCG'), 'Second argument is not a VCG class');
            assert(isa(varargin{3}, 'Beats'), 'Third argument is not a Beats class');
            assert(isa(varargin{4}, 'Annoparams'), 'Fourth argument is not an Annoparam class');
            
            ecg = varargin{1}; vcg = varargin{2}; fidpts = varargin{3}.beatmatrix(); aps = varargin{4};
            
            
            ecg_fields = fieldnames(ecg);            % List of all properties in the ECG12 class
            vcg_fields = fieldnames(vcg);            % List of all properties in the VCG class
            endspike = vcg.endspikes;                 % If there was a spike detected this is end of spike
            
            % Find the indices of all 16 leads by searching within the properties of the ECG12/VCG classes
            % (to avoid issues later on if change the order of the properties of the ECG12/VCG classes
            lead_names_ecg = [{'I'} {'II'} {'III'} {'avF'} {'avL'} {'avR'} {'V1'} {'V2'} {'V3'} {'V4'} {'V5'} {'V6'}];
            lead_names_vcg = [{'X'} {'Y'} {'Z'} {'VM'}];
            
            
            for k = 1:length(lead_names_ecg)              % Find indices of lead_names in ECG12/VCG class
                lead_idx_ecg(k) = find(strcmp(ecg_fields,lead_names_ecg{k}));
            end
            
            for k = 1:length(lead_names_vcg)               % Find indices of lead_names in ECG12 class
                lead_idx_vcg(k) = find(strcmp(vcg_fields,lead_names_vcg{k}));
            end
            
            
            lead_morph_fields = properties(obj);           % List of all properties in the Lead_Morphology class
            
            
            % run VM lead through first so can open window for other leads
            [~, twave_max_loc_vm] = twave_values(vcg.(vcg_fields{lead_idx_vcg(4)}),ecg.hz,fidpts, 0);


            % Parameters to allow easier addition of more parameters in future
            num_12L_params = 14;     % Number of parameters for each of the 12L medians
            num_vcg_params = 11;      % Number of parameters for each of the VCG/VM medians

            % Loop through ECG12 class
            for j=1:length(lead_names_ecg)
                
                step = 0;
                signal = ecg.(ecg_fields{lead_idx_ecg(j)});      % Assign each ECG12 lead to 'signal' variable for processing
                freq = ecg.hz;
                % Load in fiducual points and then find the R and S waves
                % R wave is the max positive value of the QRS complex
                % S wave is the max negative values of the QRS complex
                % If there is no positive values in the QRS then R = NaN
                % If there is no negative values in the QRS then S = NaN
                % Zero reference for this calculation is the start of the QRS complex at fiducial point q(i)
                
                try
                    [r_wave, r_wave_loc, s_wave, s_wave_loc, rs_wave, rs_ratio, sr_ratio, jpt, jpt60] = rs_values(signal,fidpts,ecg.hz,endspike);
                catch
                    r_wave = nan;
                    r_wave_loc = nan;
                    s_wave = nan;
                    s_wave_loc = nan;
                    rs_wave = nan;
                    rs_ratio = nan;
                    sr_ratio = nan;
                    jpt = nan;
                    jpt60 = nan;
                end

                try
                    [twave_max, twave_max_loc] = twave_values(signal,freq,fidpts,twave_max_loc_vm);
                catch
                    twave_max = nan;
                    twave_max_loc = nan;
                end
               
                % Correct for extra signal at start of each median beat
                % before Qon and convert to ms from samples
                twave_max_loc = round((1000/freq)*(twave_max_loc - fidpts(1)));

                % Rpeak location after QRS onset (just VM lead for now)
                % Renamed to VM_r_wave_loc for consistency
                %obj.VM_max_rpk_loc = round((1000/freq)*(fidpts(2) - fidpts(1)));

                % Calculate areas for 12L medians
                try
                    [qrs_area, t_area] = mean_vector_leadmorph(signal, (1000/freq), fidpts, aps.baseline_flag);
                catch
                    qrs_area = nan;
                    t_area =  nan;
                end

                obj.(lead_morph_fields{step+1+(num_12L_params*(j-1))}) = r_wave;                % R wave
                obj.(lead_morph_fields{step+2+(num_12L_params*(j-1))}) = r_wave_loc;            % R wave location (ms after QRS onset)
                obj.(lead_morph_fields{step+3+(num_12L_params*(j-1))}) = s_wave;                % S wave
                obj.(lead_morph_fields{step+4+(num_12L_params*(j-1))}) = s_wave_loc;            % S wave location (ms after QRS onset)
                obj.(lead_morph_fields{step+5+(num_12L_params*(j-1))}) = rs_wave;               % R+S wave (height of entire QRS complex)
                obj.(lead_morph_fields{step+6+(num_12L_params*(j-1))}) = rs_ratio;              % R/(R+S) ratio
                obj.(lead_morph_fields{step+7+(num_12L_params*(j-1))}) = sr_ratio;              % S/(R+S) ratio
                obj.(lead_morph_fields{step+8+(num_12L_params*(j-1))}) = twave_max;             % T max amplitude
                obj.(lead_morph_fields{step+9+(num_12L_params*(j-1))}) = twave_max_loc;         % T max location (ms after QRS onset)
                obj.(lead_morph_fields{step+10+(num_12L_params*(j-1))}) = qrs_area;             % QRS area
                obj.(lead_morph_fields{step+11+(num_12L_params*(j-1))}) = t_area;               % T area
                obj.(lead_morph_fields{step+12+(num_12L_params*(j-1))}) = qrs_area + t_area;    % QRST area
                obj.(lead_morph_fields{step+13+(num_12L_params*(j-1))}) = jpt;                  % J point voltage
                obj.(lead_morph_fields{step+14+(num_12L_params*(j-1))}) = jpt60;                % J point + 60 ms voltage
                
            end   % end for loop
            
            
            for j=1:length(lead_names_vcg)
                
                step = num_12L_params*12;   % Total number of parameters from 12L medians
                signal = vcg.(vcg_fields{lead_idx_vcg(j)});      % Assign each VCG lead to 'signal' variable for processing
                freq = vcg.hz;
                
                try
                    [r_wave, r_wave_loc, s_wave, s_wave_loc, rs_wave, rs_ratio, sr_ratio, jpt, jpt60] = rs_values(signal,fidpts,ecg.hz,endspike);
                catch
                    r_wave = nan;
                    r_wave_loc = nan;
                    s_wave = nan;
                    s_wave_loc = nan;
                    rs_wave = nan;
                    rs_ratio = nan;
                    sr_ratio = nan;
                    jpt = nan;
                    jpt60 = nan;
                end

                try
                [twave_max, twave_max_loc] = twave_values(signal,freq,fidpts,twave_max_loc_vm);
                twave_max_loc = round(1000/freq)*(twave_max_loc - fidpts(1));
                catch
                    twave_max = nan;
                    twave_max_loc = nan;
                end
                
                obj.(lead_morph_fields{step+1+(num_vcg_params*(j-1))}) = r_wave;            % R wave
                obj.(lead_morph_fields{step+2+(num_vcg_params*(j-1))}) = r_wave_loc;        % R wave location (ms after QRS onset)
                obj.(lead_morph_fields{step+3+(num_vcg_params*(j-1))}) = s_wave;            % S wave
                obj.(lead_morph_fields{step+4+(num_vcg_params*(j-1))}) = s_wave_loc;        % S wave location (ms after QRS onset)
                obj.(lead_morph_fields{step+5+(num_vcg_params*(j-1))}) = rs_wave;           % R+S wave (height of entire QRS complex)
                obj.(lead_morph_fields{step+6+(num_vcg_params*(j-1))}) = rs_ratio;          % R/(R+S) ratio
                obj.(lead_morph_fields{step+7+(num_vcg_params*(j-1))}) = sr_ratio;          % S/(R+S) ratio
                obj.(lead_morph_fields{step+8+(num_vcg_params*(j-1))}) = twave_max;         % T max amplitude
                obj.(lead_morph_fields{step+9+(num_vcg_params*(j-1))}) = twave_max_loc;     % T max location (ms after QRS onset)
                obj.(lead_morph_fields{step+10+(num_vcg_params*(j-1))}) = jpt;              % J point voltage
                obj.(lead_morph_fields{step+11+(num_vcg_params*(j-1))}) = jpt60;            % J point + 60 ms voltage
                
            end
            
            % LVH voltages
            
            obj.cornell_lvh_mv = abs(obj.V3_s_wave) + obj.avL_r_wave;
            obj.sokolow_lvh_mv = abs(obj.V1_s_wave) + max(obj.V5_r_wave, obj.V6_r_wave);


            % Frontal plane electrical axis
            [obj.qrs_frontal_axis] = ecg_axis(obj.L1_r_wave, obj.L1_s_wave, obj.avF_r_wave, obj.avF_s_wave);

            
            % Calculate individual SAI and SVG for X Y Z VM leads
            
            Qon = fidpts(:,1);
            Tend = fidpts(:,4);
            
            for i=1:size(fidpts,1)
                
                if isnan(Tend(i))
                    sai_x(i) = nan;
                    sai_y(i) = nan;
                    sai_z(i) = nan;
                    sai_vm(i) = nan;
                else
                    [sai_x(i), sai_y(i), sai_z(i), sai_vm(i)] = saiqrst(vcg.X(Qon(i):Tend(i)), vcg.Y(Qon(i):Tend(i)), vcg.Z(Qon(i):Tend(i)), vcg.VM(Qon(i):Tend(i)), (1000/vcg.hz), aps.baseline_flag);
                end
                
                
                if isnan(Tend(i))
                    svg_x(i) = nan;
                    svg_y(i) = nan;
                    svg_z(i) = nan;
                else
                    svg_x(i) = (1000/vcg.hz)*(trapz(vcg.X(Qon(i):Tend(i))));
                    svg_y(i) = (1000/vcg.hz)*(trapz(vcg.Y(Qon(i):Tend(i))));
                    svg_z(i) = (1000/vcg.hz)*(trapz(vcg.Z(Qon(i):Tend(i))));
                end
                
            end
         
        end     % End main Lead_Morphology method        
        
        
        % Export RS Values in column format
        function v = cells(obj)
            l = obj.labels();
            N = length(l);
            v = cell(1, N);
             all_beat_names = [{'svg_x_individual'} {'svg_y_individual'} {'svg_z_individual'}...
                 {'sai_x_individual'}, {'sai_y_individual'}, {'sai_z_individual'}, {'sai_vm_individual'}];
            
            for i = 1:N
                v{i} = obj.(l{i});
                
                 if any(strcmp(l{i}, all_beat_names))                
                     v{i} = num2str(obj.(l{i}));
                 end
                
            end
            %             lead_morph_fields = properties(obj);           % List of all properties in the Lead_Morphology class
            %             delete_names = [{'VM_s_wave'} {'VM_rs_wave'} {'VM_rs_ratio'} {'VM_sr_ratio'}];
            %
            %             j=1;
            %             v = cell(length(lead_morph_fields)-length(delete_names), 1);
            %             for i=1:length(lead_morph_fields)
            %                 if ~any(strcmp(lead_morph_fields{i}, delete_names))
            %                     v{j} = obj.(lead_morph_fields{i});
            %                     j=j+1;
            %                 end
            %             end
        end
         
    end     % End methods


    methods(Static)
        % Display lead header for export purposes
        function labels = labels()
            obj = Lead_Morphology();
            lead_morph_fields = properties(obj)';
            % Delete VM NaN labels/values
            
            delete_names = [{'VM_s_wave'} {'VM_rs_wave'} {'VM_rs_ratio'} {'VM_sr_ratio'} {'VM_s_wave_loc'}];
            
            for k = 1:length(delete_names)
                lead_idx_ecg(k) = find(strcmp(lead_morph_fields,delete_names{k}));
            end
            lead_morph_fields(lead_idx_ecg)=[];
            labels = lead_morph_fields;
        end
        
        function l = length(); g = Lead_Morphology(); l = length(properties(g)); end

        function a = allnan()
            a = Lead_Morphology();
            p = properties(a);
            for i = 1:length(p)
                a.(p{i}) = nan;
            end
        end
    end
    
end     % End class


