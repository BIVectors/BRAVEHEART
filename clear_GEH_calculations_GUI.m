%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% clear_GEH_calculations_GUI.m -- Part of BRAVEHEART GUI
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

function clear_GEH_calculations_GUI(hObject, eventdata, handles)

% Clears GUI value text elements and some other text elements in GUI

handles = guidata(hObject);

set(handles.success_txt,'Visible','Off')
set(handles.corr_x_txt, 'String'," ");
set(handles.corr_y_txt, 'String'," ");
set(handles.corr_z_txt, 'String'," ");

set(handles.svg_x_txt,'String',0);
set(handles.svg_y_txt,'String',0);
set(handles.svg_z_txt,'String',0);

set(handles.sai_x_txt,'String',0);
set(handles.sai_y_txt,'String',0);
set(handles.sai_z_txt,'String',0);
set(handles.sai_vm_txt,'String',0);
set(handles.sai_qrst_txt,'String',0);

set(handles.qrst_angle_area_txt,'String',0);
set(handles.qrst_angle_peak_txt,'String',0);
set(handles.qrst_angle_area_frontal_txt,'String',0);
set(handles.qrst_angle_peak_frontal_txt,'String',0);

set(handles.q_peak_el_txt,'String',0);
set(handles.q_peak_az_txt,'String',0);
set(handles.q_area_el_txt,'String',0);
set(handles.q_area_az_txt,'String',0);

set(handles.t_peak_el_txt,'String',0);
set(handles.t_peak_az_txt,'String',0);
set(handles.t_area_el_txt,'String',0);
set(handles.t_area_az_txt,'String',0);

set(handles.svg_qrs_angle_area_txt,'String',0);
set(handles.svg_qrs_angle_peak_txt,'String',0);
set(handles.svg_t_angle_area_txt,'String',0);
set(handles.svg_t_angle_peak_txt,'String',0);

set(handles.svg_area_el_txt,'String',0);
set(handles.svg_area_az_txt,'String',0);
set(handles.svg_peak_el_txt,'String',0);
set(handles.svg_peak_az_txt,'String',0);

set(handles.svg_area_mag_txt,'String',0);
set(handles.svg_peak_mag_txt,'String',0);

set(handles.q_peak_mag_txt,'String',0);
set(handles.t_peak_mag_txt,'String',0);

set(handles.q_area_mag_txt,'String',0);
set(handles.t_area_mag_txt,'String',0);

set(handles.peak_qrst_ratio_txt,'String',0);
set(handles.area_qrst_ratio_txt,'String',0);

set(handles.svg_svg_angle_txt,'String',0);

set(handles.svg_area_qrs_peak_angle_txt,'String',0);

set(handles.qrst_distance_peak_txt,'String',0);
set(handles.qrst_distance_area_txt,'String',0);

set(handles.vcg_length_qrst_txt,'String',0);
set(handles.vcg_length_qrs_txt,'String',0);
set(handles.vcg_length_t_txt,'String',0);


% Basic Intervals

%set(handles.hr_txt,'String',round(handles.hr,0));
set(handles.qrs_txt,'String',0);
set(handles.jt_txt,'String',0);
set(handles.qt_txt,'String',0);

set(handles.qrs_median_txt,'String',0);
set(handles.qrs_min_txt,'String',0);
set(handles.qrs_max_txt,'String',0);
set(handles.qrs_iqr_txt,'String',0);

set(handles.jt_median_txt,'String',0);
set(handles.jt_min_txt,'String',0);
set(handles.jt_max_txt,'String',0);
set(handles.jt_iqr_txt,'String',0);

set(handles.qt_median_txt,'String',0);
set(handles.qt_min_txt,'String',0);
set(handles.qt_max_txt,'String',0);
set(handles.qt_iqr_txt,'String',0);

set(handles.qtc_b_txt,'String',0);
set(handles.qtc_f_txt,'String',0);

set(handles.tpeak_txt,'String',0);
set(handles.tpeak_qt_txt,'String',0);



% Speed Intervals
set(handles.max_qrst_speed_txt,'String',0);
set(handles.med_qrst_speed_txt,'String',0);
set(handles.max_qrst_speed_time_txt,'String',sprintf("%.0f ms",0));

set(handles.max_qrs_speed_txt,'String',0);
set(handles.med_qrs_speed_txt,'String',0);
set(handles.max_qrs_speed_time_txt,'String',sprintf("%.0f ms",0));

set(handles.max_t_speed_txt,'String',0);
set(handles.med_t_speed_txt,'String',0);
set(handles.max_t_speed_time_txt,'String',sprintf("%.0f ms",0));


% VCG Morphology
set(handles.qrsloop_residual_txt,'String',0);
set(handles.qrsloop_rmse_txt,'String',0);
set(handles.qrsloop_roundness_txt,'String',0);
set(handles.qrsloop_area_txt,'String',0);
set(handles.qrsloop_perimeter_txt,'String',0);

set(handles.tloop_residual_txt,'String',0);
set(handles.tloop_rmse_txt,'String',0);
set(handles.tloop_roundness_txt,'String',0);
set(handles.tloop_area_txt,'String',0);
set(handles.tloop_perimeter_txt,'String',0);

set(handles.TCRT_txt,'String',0);
set(handles.TCRT_angle_txt,'String',0);

set(handles.qrst_dihedral_ang_txt,'String',0);


% Quality display
set(handles.quality_panel, 'BackgroundColor', '[0.3922 0.8314 0.0745]')
set(handles.quality_score_txt, 'BackgroundColor', '[0.3922 0.8314 0.0745]');
set(handles.quality_score_txt, 'String', 'NaN');

set(handles.quality_count_panel, 'BackgroundColor', '[0.3922 0.8314 0.0745]')
set(handles.quality_count_txt, 'BackgroundColor', '[0.3922 0.8314 0.0745]');
set(handles.quality_count_txt, 'String', 'NaN');

