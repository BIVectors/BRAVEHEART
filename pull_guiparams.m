%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% pull_guiparams.m -- Pulls all the parameters from the GUI and adds them to an Annoparams class
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

function aps = pull_guiparams(hObject, eventdata, handles)

% Pulls all the parameters from the GUI and adds them to an Annoparams class

aps = Annoparams;       % Declare as Annoparams class (will pull in default values)



% Set pacing spike removal flag and parameters to Annoparams class
    aps.spike_removal = logical(get(handles.pacing_remove_box, 'Value'));
    aps.pacer_spike_width = str2double(get(handles.pacing_pkwidth_txt, 'String'));
    aps.pacer_thresh = str2double(get(handles.pacing_thresh_txt, 'String'));
   
    
% PVC removal etc
    aps.pvc_removal = logical(get(handles.auto_pvc_removal_checkbox, 'Value')); 
    aps.outlier_removal = logical(get(handles.auto_remove_outliers_checkbox, 'Value'));  
    
% Max bpm      
    aps.maxBPM = str2double(get(handles.maxbpm, 'String'));    
    
% Peak Threshold for QRS detection
    aps.pkthresh = str2double(get(handles.pkthresh, 'String'));
    
% Lowpass Wavelet filtering        
    if get(handles.wavelet_filter_box, 'Value') == 1
        aps.lowpass = 1;
    else
        aps.lowpass = 0;
	end
        
% Highpass Wavelet filtering         
    if get(handles.wavelet_filter_box_lf, 'Value') == 1
        aps.highpass = 1;
    else
        aps.highpass = 0;
    end        
        
% Transformation matrix         
    if get(handles.transform_mat_dropdown, 'Value') == 1
         aps.transform_matrix_str = 'Kors';
    end
    if get(handles.transform_mat_dropdown, 'Value') == 2
         aps.transform_matrix_str = 'Dower';
    end
    
% Tend method
    Tend_strings = get(handles.tend_method_dropdown,'String');
    Tend_selectedIndex = get(handles.tend_method_dropdown,'Value');
    aps.Tendstr = Tend_strings{Tend_selectedIndex};
               
% Wavelet name Lowpass
    wavelet_name_index = get(handles.wavelet_type,'Value');
    wavelet_name_all = get(handles.wavelet_type,'String');
    aps.wavelet_name_lowpass = char(wavelet_name_all(wavelet_name_index));
             
% Wavelet name Highpass
    wavelet_name_index_lf = get(handles.wavelet_type_lf,'Value');
    wavelet_name_all_lf = get(handles.wavelet_type_lf,'String');
    aps.wavelet_name_highpass = char(wavelet_name_all_lf(wavelet_name_index_lf));
 
% Baseline correction flag
    aps.baseline_correct_flag = get(handles.baseline_correct_checkbox,'Value');
    
% Set up wavelet levels from dropdown boxes
    aps.wavelet_level_lowpass = get(handles.wavelet_level_selection,'Value');  % dont need to reassign because in order from 1-5
    handles.wavelet_level_lowpass = aps.wavelet_level_lowpass;
        
    aps.wavelet_level_highpass = get(handles.wavelet_level_selection_lf,'Value')+5;  % add 5 since 1st entry (index 1) has value of 6
    handles.wavelet_level_highpass = aps.wavelet_level_highpass;
   
% Choose method of aligning beats (Rpeak or CoV)
    align_strings = get(handles.align_dropdown,'String');
    align_index = get(handles.align_dropdown,'Value');
    aps.align_flag = align_strings{align_index};

% Baseline for area calculations
    if get(handles.zero_ref_list, 'Value') == 1
        aps.baseline_flag = 'Tend';
    end
    if get(handles.zero_ref_list, 'Value') == 2
        aps.baseline_flag = 'Qon';
    end
    if get(handles.zero_ref_list, 'Value') == 3
        aps.baseline_flag = 'Avg';
    end
    if get(handles.zero_ref_list, 'Value') == 4
        aps.baseline_flag = 'zero_baseline';
    end
        
% Origin_flag to determine the VCG origin
    if get(handles.vcg_origin_list, 'Value') == 1
        aps.origin_flag = 'Avg';
   end

   if get(handles.vcg_origin_list, 'Value') == 2
        aps.origin_flag = 'Tend';
   end

   if get(handles.vcg_origin_list, 'Value') == 3
        aps.origin_flag = 'zero_origin';
   end   

% Debug flag
    aps.debug = logical(get(handles.debug_anno, 'Value'));
   
% PVC thresholds (X-Corr and RMSE)
    aps.pvcthresh =  str2num(get(handles.pvc_thresh_txt, 'String'))/100;
    aps.rmse_pvcthresh = str2num(get(handles.rmse_thresh_txt, 'String'));
    
% Keep or remove PVCs
    aps.keep_pvc =  get(handles.keeppvc_button,'Value');
    
% Blanking samples for speed graph
    aps.blanking_samples = str2num(get(handles.speed_blank_txt, 'String'));
    
% Annotation parameters    
    aps.autoMF = logical(get(handles.autocl_checkbox, 'Value'));
    aps.autoMF_thresh = str2num(get(handles.autocl_value_txtbox,'String'));
    aps.STstart = str2double(get(handles.ststart, 'String'));
    aps.STend = str2double(get(handles.stend, 'String'));
    aps.RSwidth = str2double(get(handles.rswidth, 'String'));
    aps.QRwidth = str2double(get(handles.qrwidth, 'String'));
    
% Outlier modified Z-score cutoff for declaring a beat an outlier
    aps.modz_cutoff = str2num(get(handles.zscore_thresh_txt,'String'));
   
% Median beat reannotation method    
    if get(handles.medianreanno_popup, 'Value') == 1
         aps.median_reanno_method = 'NNet';
    end
    if get(handles.medianreanno_popup, 'Value') == 2
         aps.median_reanno_method = 'Std';
	end    
   
	% Septum search window
	%aps.septumwindow = str2double(get(handles.septal_txt, 'String'));
end