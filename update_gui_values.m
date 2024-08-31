%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% update_gui_values.m -- Part of BRAVEHEART GUI
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

function update_gui_values(geh, beat_stats, hObject, eventdata, handles)

% GEH
set(handles.svg_x_txt,'String',round(geh.svg_x,2));
set(handles.svg_y_txt,'String',round(geh.svg_y,2));
set(handles.svg_z_txt,'String',round(geh.svg_z,2));

set(handles.sai_x_txt,'String',round(geh.sai_x,2));
set(handles.sai_y_txt,'String',round(geh.sai_y,2));
set(handles.sai_z_txt,'String',round(geh.sai_z,2));
set(handles.sai_vm_txt,'String',round(geh.sai_vm,2));
set(handles.sai_qrst_txt,'String',round(geh.sai_qrst,2));

set(handles.qrst_angle_area_txt,'String',round(geh.qrst_angle_area,2));
set(handles.qrst_angle_peak_txt,'String',round(geh.qrst_angle_peak,2));
set(handles.qrst_angle_area_frontal_txt,'String',round(geh.qrst_angle_area_frontal,2));
set(handles.qrst_angle_peak_frontal_txt,'String',round(geh.qrst_angle_peak_frontal,2));

set(handles.q_peak_el_txt,'String',round(geh.q_peak_el,2));
set(handles.q_peak_az_txt,'String',round(geh.q_peak_az,2));
set(handles.q_area_el_txt,'String',round(geh.q_area_el,2));
set(handles.q_area_az_txt,'String',round(geh.q_area_az,2));

set(handles.t_peak_el_txt,'String',round(geh.t_peak_el,2));
set(handles.t_peak_az_txt,'String',round(geh.t_peak_az,2));
set(handles.t_area_el_txt,'String',round(geh.t_area_el,2));
set(handles.t_area_az_txt,'String',round(geh.t_area_az,2));

set(handles.svg_qrs_angle_area_txt,'String',round(geh.svg_qrs_angle_area,2));
set(handles.svg_qrs_angle_peak_txt,'String',round(geh.svg_qrs_angle_peak,2));
set(handles.svg_t_angle_area_txt,'String',round(geh.svg_t_angle_area,2));
set(handles.svg_t_angle_peak_txt,'String',round(geh.svg_t_angle_peak,2));

set(handles.svg_area_el_txt,'String',round(geh.svg_area_el,2));
set(handles.svg_area_az_txt,'String',round(geh.svg_area_az,2));
set(handles.svg_peak_el_txt,'String',round(geh.svg_peak_el,2));
set(handles.svg_peak_az_txt,'String',round(geh.svg_peak_az,2));

set(handles.svg_area_mag_txt,'String',round(geh.svg_area_mag,2));
set(handles.svg_peak_mag_txt,'String',round(geh.svg_peak_mag,2));

set(handles.q_peak_mag_txt,'String',round(geh.q_peak_mag,2));
set(handles.t_peak_mag_txt,'String',round(geh.t_peak_mag,2));

set(handles.q_area_mag_txt,'String',round(geh.q_area_mag,2));
set(handles.t_area_mag_txt,'String',round(geh.t_area_mag,2));

set(handles.svg_svg_angle_txt,'String',round(geh.svg_svg_angle,2));

set(handles.svg_area_qrs_peak_angle_txt,'String',round(geh.svg_area_qrs_peak_angle,2));

set(handles.qrst_distance_peak_txt,'String',round(geh.qrst_distance_peak,2));
set(handles.qrst_distance_area_txt,'String',round(geh.qrst_distance_area,2));

set(handles.vcg_length_qrst_txt,'String',round(geh.vcg_length_qrst,2));
set(handles.vcg_length_qrs_txt,'String',round(geh.vcg_length_qrs,2));
set(handles.vcg_length_t_txt,'String',round(geh.vcg_length_t,2));

set(handles.peak_qrst_ratio_txt,'String',round(geh.peak_qrst_ratio,2));
set(handles.area_qrst_ratio_txt,'String',round(geh.area_qrst_ratio,2));


% Speed Intervals
set(handles.max_qrst_speed_txt,'String',round(geh.speed_max,4));
%set(handles.min_qrst_speed_txt,'String',round(handles.speed_min,4));
set(handles.med_qrst_speed_txt,'String',round(geh.speed_med,4));
set(handles.max_qrst_speed_time_txt,'String',sprintf("%.0f ms",geh.time_speed_max));
%set(handles.min_qrst_speed_time_txt,'String',sprintf("%.0f ms",handles.time_speed_min));

set(handles.max_qrs_speed_txt,'String',round(geh.speed_qrs_max,4));
%set(handles.min_qrs_speed_txt,'String',round(handles.speed_qrs_min,3));
set(handles.med_qrs_speed_txt,'String',round(geh.speed_qrs_med,4));
set(handles.max_qrs_speed_time_txt,'String',sprintf("%.0f ms",geh.time_speed_qrs_max));
%set(handles.min_qrs_speed_time_txt,'String',sprintf("%.0f ms",handles.time_speed_qrs_min));

set(handles.max_t_speed_txt,'String',round(geh.speed_t_max,4));
%set(handles.min_t_speed_txt,'String',round(handles.speed_t_min,4));
set(handles.med_t_speed_txt,'String',round(geh.speed_t_med,4));
set(handles.max_t_speed_time_txt,'String',sprintf("%.0f ms",geh.time_speed_t_max));
%set(handles.min_t_speed_time_txt,'String',sprintf("%.0f ms",handles.time_speed_t_min));


% Beat Stats
set(handles.qrs_median_txt,'String',round(beat_stats.qrs_median,0));
set(handles.qrs_min_txt,'String',round(beat_stats.qrs_min,0));
set(handles.qrs_max_txt,'String',round(beat_stats.qrs_max,0));
set(handles.qrs_iqr_txt,'String',round(beat_stats.qrs_iqr,0));

set(handles.jt_median_txt,'String',round(beat_stats.jt_median,0));
set(handles.jt_min_txt,'String',round(beat_stats.jt_min,0));
set(handles.jt_max_txt,'String',round(beat_stats.jt_max,0));
set(handles.jt_iqr_txt,'String',round(beat_stats.jt_iqr,0));

set(handles.qt_median_txt,'String',round(beat_stats.qt_median,0));
set(handles.qt_min_txt,'String',round(beat_stats.qt_min,0));
set(handles.qt_max_txt,'String',round(beat_stats.qt_max,0));
set(handles.qt_iqr_txt,'String',round(beat_stats.qt_iqr,0));


% Basic intervals
set(handles.qrs_txt,'String',round(geh.qrs_int,0));
set(handles.qt_txt,'String',round(geh.qt_int,0));

% Calculate JT interval
jt_int = geh.qt_int - geh.qrs_int;
set(handles.jt_txt,'String',round(jt_int,0));

% Calculate corrected QT intervals (Bazett and Frederica)
qtc_b = geh.qt_int/sqrt(60/handles.hr);
qtc_f = geh.qt_int/nthroot((60/handles.hr),3);

set(handles.qtc_b_txt,'String',round(qtc_b,0));
set(handles.qtc_f_txt,'String',round(qtc_f,0));


set(handles.tpeak_txt,'String',round(geh.vm_tpeak_time,0));
set(handles.tpeak_qt_txt,'String',round(geh.vm_tpeak_tend_ratio,3));


% Cross correlation - now deals with possibility of Nans
if ~isnan(handles.correlation_test.X)
    set(handles.corr_x_txt,'String',round(handles.correlation_test.X,4));
else
    set(handles.corr_x_txt,'String',handles.correlation_test.X)
end

if ~isnan(handles.correlation_test.Y)
    set(handles.corr_y_txt,'String',round(handles.correlation_test.Y,4));
else
    set(handles.corr_y_txt,'String',handles.correlation_test.Y)
end

if ~isnan(handles.correlation_test.Z)
    set(handles.corr_z_txt,'String',round(handles.correlation_test.Z,4));
else
    set(handles.corr_z_txt,'String',handles.correlation_test.Z)
end

% Add VCG morphology data if if has been calculated
set(handles.qrsloop_residual_txt,'String',round(handles.vcg_morph.qrsloop_residual,3));
set(handles.qrsloop_rmse_txt,'String',round(handles.vcg_morph.qrsloop_rmse,3));
set(handles.qrsloop_roundness_txt,'String',round(handles.vcg_morph.qrsloop_roundness,3));
set(handles.qrsloop_area_txt,'String',round(handles.vcg_morph.qrsloop_area,3));
set(handles.qrsloop_perimeter_txt,'String',round(handles.vcg_morph.qrsloop_perimeter,3));

set(handles.tloop_residual_txt,'String',round(handles.vcg_morph.tloop_residual,3));
set(handles.tloop_rmse_txt,'String',round(handles.vcg_morph.tloop_rmse,3));
set(handles.tloop_roundness_txt,'String',round(handles.vcg_morph.tloop_roundness,3));
set(handles.tloop_area_txt,'String',round(handles.vcg_morph.tloop_area,3));
set(handles.tloop_perimeter_txt,'String',round(handles.vcg_morph.tloop_perimeter,3));

set(handles.TCRT_txt,'String',round(handles.vcg_morph.TCRT,2));
set(handles.TCRT_angle_txt,'String',round(handles.vcg_morph.TCRT_angle,2));

set(handles.qrst_dihedral_ang_txt,'String',round(handles.vcg_morph.qrst_dihedral_ang,2));

set(handles.TMD_txt,'String',round(handles.vcg_morph.TMD,2));
set(handles.TWR_abs_txt,'String',round(handles.vcg_morph.TWR_abs,3));
set(handles.TWR_rel_txt,'String',round(handles.vcg_morph.TWR_rel,3));



% Star abnormal values in GUI

% Only do if checkbox in Utilities is checked off

[age, male, white, bmi] = pull_gui_demographics(hObject, eventdata, handles);

nml = NormalVals(age, male, white, bmi, handles.hr);
abnml = AbnormalVals(geh,nml);
fields = nml.labels();

% Mark values in GUI that are abnormal with an up or down arrow based on if
% they are above or below normal ranges
for i=6:nml.length()
    
    % char(8593) is up arrow
    % char(8595) is down arrow
    
   if abnml.(fields{i}) == 1
      tmp = get(handles.(strcat(fields{i},"_txt")),'String'); 
      % remove any existing up arrows
      tmp = erase(tmp,char(8593));
      set(handles.(strcat(fields{i},"_txt")),'String',strcat(tmp,char(8593)));     
   end
   
      if abnml.(fields{i}) == -1
      tmp = get(handles.(strcat(fields{i},"_txt")),'String'); 
      % remove any existing down arrows
      tmp = erase(tmp,char(8595));
      set(handles.(strcat(fields{i},"_txt")),'String',strcat(tmp,char(8595)));     
   end
   
end

end  % End if normal checkbox checked