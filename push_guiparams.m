%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% push_guiparams.m -- Pushes parameters from the Annoparams class to GUI dropdowns/checkboxes
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

function push_guiparams(aps, hObject, eventdata, handles)

% Pushes parameters from the Annoparams class to GUI dropdowns/checkboxes

% Set pacing spike removal flag and parameters to Annoparams class
    set(handles.pacing_remove_box, 'Value', aps.spike_removal);
    set(handles.pacing_pkwidth_txt, 'String', aps.pacer_spike_width);
    set(handles.pacing_thresh_txt, 'String', aps.pacer_thresh);
   
% PVC removal etc
    set(handles.auto_pvc_removal_checkbox, 'Value', aps.pvc_removal); 
    set(handles.auto_remove_outliers_checkbox, 'Value', aps.outlier_removal);  
    
% Max bpm      
    set(handles.maxbpm, 'String', aps.maxBPM);    
    
% Peak Threshold for QRS detection
    set(handles.pkthresh, 'String', aps.pkthresh);
    
% Lowpass Wavelet filtering        
   set(handles.wavelet_filter_box, 'Value', aps.lowpass);
        if aps.lowpass
            set(handles.wavelet_type,'Enable','on');
            set(handles.wavelet_level_selection,'Enable','on');
        else
            set(handles.wavelet_type,'Enable','off');
            set(handles.wavelet_level_selection,'Enable','off');  
        end
  
% Highpass Wavelet filtering         
    set(handles.wavelet_filter_box_lf, 'Value', aps.highpass);
        if aps.highpass
            set(handles.wavelet_type_lf,'Enable','on');
            set(handles.wavelet_level_selection_lf,'Enable','on');
        else
            set(handles.wavelet_type_lf,'Enable','off');
            set(handles.wavelet_level_selection_lf,'Enable','off');  
        end
      
% Transformation matrix         
    if strcmp(aps.transform_matrix_str,'Kors')
        set(handles.transform_mat_dropdown, 'Value', 1);
    end
    if strcmp(aps.transform_matrix_str,'Dower')
        set(handles.transform_mat_dropdown, 'Value', 2);
    end
    
% Tend method
    switch aps.Tendstr
        case 'Energy'
            set(handles.tend_method_dropdown,'Value', 1);
        case 'Tangent'
            set(handles.tend_method_dropdown,'Value', 2);
        case 'Baseline'
            set(handles.tend_method_dropdown,'Value', 3);
    end
    
% Wavelet name Lowpass
    switch aps.wavelet_name_lowpass
        case 'Sym4'
            set(handles.wavelet_type,'Value', 1);
        case 'Sym5'
            set(handles.wavelet_type,'Value', 2);
        case 'Sym6'
            set(handles.wavelet_type,'Value', 3);
        case 'db4'
            set(handles.wavelet_type,'Value', 4);
        case 'db8'
            set(handles.wavelet_type,'Value', 5);
    end
    
% Wavelet name Highpass
        switch aps.wavelet_name_highpass
        case 'Sym4'
            set(handles.wavelet_type_lf,'Value', 1);
        case 'Sym5'
            set(handles.wavelet_type_lf,'Value', 2);
        case 'Sym6'
            set(handles.wavelet_type_lf,'Value', 3);
        case 'db4'
            set(handles.wavelet_type_lf,'Value', 4);
        case 'db8'
            set(handles.wavelet_type_lf,'Value', 5);
    end
     
% Baseline correction flag
     set(handles.baseline_correct_checkbox,'Value', aps.baseline_correct_flag);
       
% Set up wavelet levels from dropdown boxes
    set(handles.wavelet_level_selection,'Value', aps.wavelet_level_lowpass);  % dont need to reassign because in order from 1-5
    set(handles.wavelet_level_selection_lf,'Value', aps.wavelet_level_highpass - 5); % substract 5 since 1st entry (index 1) has value of 6
    
% Choose method of aligning beats (CoV or Rpeak)
    if strcmp(aps.align_flag,'CoV')
        set(handles.align_dropdown, 'Value', 1);
    end
    if strcmp(aps.align_flag,'Rpeak')
        set(handles.align_dropdown, 'Value', 2);
    end    
    
% Baseline for area calculations
    switch aps.baseline_flag
        case 'Tend'
            set(handles.zero_ref_list, 'Value', 1);
        case 'Qon'
            set(handles.zero_ref_list, 'Value', 2);
        case 'Avg'
            set(handles.zero_ref_list, 'Value', 3);
        case 'zero_baseline'
            set(handles.zero_ref_list, 'Value', 4);
    end
       
% Origin_flag to determine the VCG origin
    switch aps.origin_flag
        case 'Avg'
            set(handles.vcg_origin_list, 'Value', 1);
        case 'Tend'
            set(handles.vcg_origin_list, 'Value', 2);
        case 'zero_origin'
            set(handles.vcg_origin_list, 'Value', 3);
    end

% Debug flag
    set(handles.debug_anno, 'Value', aps.debug);

% PVC thresholds (X-Corr and RMSE)
    set(handles.pvc_thresh_txt, 'String', aps.pvcthresh*100);
    set(handles.rmse_thresh_txt, 'String', aps.rmse_pvcthresh);
    
% Blanking samples for speed graph
    set(handles.speed_blank_txt, 'String', aps.blanking_samples);
    
% Annotation parameters    
    set(handles.autocl_checkbox, 'Value', aps.autoMF);
    set(handles.autocl_value_txtbox,'String', aps.autoMF_thresh);
    set(handles.ststart, 'String', aps.STstart);
    set(handles.stend, 'String', aps.STend);
    set(handles.rswidth, 'String', aps.RSwidth);
    set(handles.qrwidth, 'String', aps.QRwidth);
    
% Outlier modified Z-score cutoff for declaring a beat an outlier
    set(handles.zscore_thresh_txt,'String', aps.modz_cutoff);

% Median beat reannotation method    
if strcmp(aps.median_reanno_method,'NNet')
        set(handles.medianreanno_popup, 'Value', 1);
    end
if strcmp(aps.median_reanno_method,'Std')
        set(handles.medianreanno_popup, 'Value', 2);
end
    
% Septal activation search window
%set(handles.septal_txt, 'String', aps.septumwindow);
    
% Keep PVC vs native
if aps.keep_pvc == 0
    set(handles.keepnative_button, 'Value', 1);
    set(handles.keeppvc_button, 'Value', 0);
else
    set(handles.keepnative_button, 'Value', 0);
    set(handles.keeppvc_button, 'Value', 1);
end

    
    
end