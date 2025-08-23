%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% r2025_GUI.m -- Adjust GUI for graphics overhaul in R2025a
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

function r2025_GUI(handles)

gray = '[0.94 0.94 0.94]';
newfont = 'Helvetica';
buttoncolor = '[0.85 0.85 0.85]';
outlines = 'line';
outlinewidth = 1.5;

% Set the background for the main GUI to the light mode color to avoid
% issues with weird plotting colors
A = findobj;
set(A(1).Children,'Color', '[0.94 0.94 0.94]');

% Replace all fonts and make all text, buttons, and uipanels correct background color
for field = fieldnames(handles)'
    field = field{1};
    try 
        set(handles.(field),'FontName',newfont);
    end

    try
        if strcmp(get(handles.(field),'Style'), 'text') 

            if (~strcmp(get(handles.(field),'Tag'),'quality_score_txt')) && (~strcmp(get(handles.(field),'Tag'),'quality_count_txt'))
                set(handles.(field),'BackgroundColor',gray)
            end
            set(handles.(field),'FontName',newfont)
        end
    end

    try
        if strcmp(get(handles.(field),'Style'), 'pushbutton') 
            set(handles.(field),'BackgroundColor',buttoncolor) 
        end
    end
end

% Left sided panels
set(handles.uipanel1,'BorderType',outlines)
set(handles.uipanel1,'BorderColor','[0.7 0.7 0.7]')
set(handles.uipanel1,'BorderWidth',outlinewidth)
set(handles.uipanel4,'BorderType',outlines)
set(handles.uipanel4,'BorderColor','[0.7 0.7 0.7]')
set(handles.uipanel4,'BorderWidth',outlinewidth)
set(handles.uipanel6,'BorderType',outlines)
set(handles.uipanel6,'BorderColor','[0.7 0.7 0.7]')
set(handles.uipanel6,'BorderWidth',outlinewidth)

% Fix major panels
field_list = [{'uipanel2'} {'uipanel56'} {'uipanel13'} {'uipanel7'} {'tab1'} {'uipanel9'} {'tab5'} {'tab3'} {'tab2'} {'tab4'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}), 'BorderColor','[0.7 0.7 0.7]')   
    set(handles.(field_list{i}), 'BorderType',outlines)   
    set(handles.(field_list{i}), 'BackgroundColor',gray) 
    set(handles.(field_list{i}),'BorderWidth',outlinewidth)
end


% Fix 'Select data for display buttons
% Looks best if decrease height by 4px and use 9.5 pt font
field_list = [{'tab1_button'} {'tab2_button'} {'lead_morph_button'} {'tab5_button'} {'tab3_button'} {'tab4_button'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}),'FontSize',9.5)  
    set(handles.(field_list{i}),'FontName',newfont)
    set(handles.(field_list{i}),'BackgroundColor',buttoncolor)  
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2) v(3) v(4)-4];
    set(handles.(field_list{i}),'Position',x);
end

set(handles.uipanel56, 'BorderType','none') 


% Fix left side buttons
field_list = [{'pushbutton77'} {'about_help_button'} {'export_xyz_waveform_button'} {'export_medianbeat_waveform_button'} ...
    {'x_stats_button'} {'y_stats_button'} {'z_stats_button'} {'quality_button'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}),'FontSize',9.5)  
    set(handles.(field_list{i}),'FontName',newfont)
    set(handles.(field_list{i}),'BackgroundColor',buttoncolor)  
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2) v(3) v(4)-5];
    set(handles.(field_list{i}),'Position',x);
end


% Fix figure buttons
field_list = [{'view_12lead_button'} {'view_vcgloops_button'} {'normal_range_button'} {'view_xyz_ecg'} ...
    {'view_median_ecg_button'} {'polar_fig_button'} {'summary_ecg_button'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}),'FontSize',9.5)  
    set(handles.(field_list{i}),'FontName',newfont)
    set(handles.(field_list{i}),'BackgroundColor',buttoncolor)  
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-2 v(3) v(4)-2];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'grid_popup'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-1 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


% Fix minor panels color and font
field_list = [{'uipanel10'} {'uipanel30'} {'uipanel32'} {'uipanel39'} {'uipanel8'} {'uipanel10'} {'uipanel26'} ...
    {'uipanel136'} {'uipanel44'} {'uibuttongroup4'} {'uibuttongroup13'} {'uipanel38'} {'uibuttongroup10'} {'uipanel94'} ...
    {'uipanel15'} {'uipanel23'} {'uipanel24'} {'uipanel25'} {'uipanel36'} {'uipanel18'} {'uipanel19'} {'uipanel21'} ...
    {'uipanel123'} {'uipanel89'} {'uipanel87'} {'uipanel12'} {'panel_v'} {'uipanel145'} {'uipanel126'} {'uipanel128'} ...
    {'uipanel129'} {'uipanel74'} {'uipanel75'} {'uipanel76'} {'uipanel127'} {'uipanel135'} {'uipanel120'} {'uipanel130'} ...
    {'uipanel88'} {'uipanel122'} {'uipanel140'} {'uipanel141'} {'uipanel66'} {'uipanel71'} {'uipanel72'} {'uipanel73'} ...
    {'uipanel14'} {'uipanel28'} {'uipanel90'} {'uipanel73'} {'uipanel147'} {'uipanel7'} {'uipanel9'} {'uipanel29'} ...
    {'uipanel45'} {'uipanel41'} {'uipanel95'} {'uipanel37'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}), 'BorderColor','[0.7 0.7 0.7]')   
    set(handles.(field_list{i}), 'BorderType',outlines)   
    set(handles.(field_list{i}), 'BackgroundColor',gray) 
    set(handles.(field_list{i}),'BorderWidth',1)
end


% Minor buttons
field_list = [{'crosscorr_button'} {'pvc_button'} {'remove_selectbeat_button'} {'add_newbeat_button'} {'update_selectbeat_button'} ...
    {'prev_beat_button'} {'next_beat_button'} {'remove_outliers_button'} {'outlier_button'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}),'FontSize',9.5)  
    set(handles.(field_list{i}),'FontName',newfont)
    set(handles.(field_list{i}),'BackgroundColor',buttoncolor)  
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2) v(3) v(4)-1];
    set(handles.(field_list{i}),'Position',x);
end

% Fix text in buttons that no longer accept HTML
set(handles.remove_outliers_button,'String',{'Remove';'Outliers'})
set(handles.outlier_button,'String',{'Outlier';'Data'})


% Load Section
set(handles.uibuttongroup14,'BorderType','none');
set(handles.uibuttongroup3,'BorderType','none');

set(handles.uibuttongroup14,'BorderColor',gray);
set(handles.uibuttongroup3,'BorderColor',gray);

v = get(handles.batch_load_button,'Position');
x = [v(1)-3 v(2) v(3) v(4)];
set(handles.batch_load_button,'Position',x);


field_list = [{'uipanel28'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)+6 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'Tendmethod'} {'uipanel92'} {'uipanel93'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}),'BorderType','none');
    set(handles.(field_list{i}),'BorderColor',gray);
    set(handles.(field_list{i}), 'BackgroundColor',gray)
end

field_list = [{'uipanel1'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [9 v(2) 636 v(4)];
    set(handles.(field_list{i}),'Position',x);
    set(handles.(field_list{i}),'BorderType','none');
end


field_list = [{'wavelet_level_selection'} {'wavelet_level_selection_lf'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2) v(3)+1 v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'wavelet_filter_box'} {'wavelet_filter_box_lf'} {'baseline_correct_checkbox'} {'wavelet_type'} {'wavelet_type_lf'} ...
    {'text795'} {'text40'} {'maxbpm'} {'text532'} {'text796'} {'pkthresh'} {'text797'} {'text798'} ...
    {'pkfilter_checkbox'} {'text531'} {'hf_freq_txt'} {'text517'} {'lf_fmin_txt'} {'text129'} {'wavelet_level_selection'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-2 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'freq_txt'} {'text8'} {'text7'} {'num_samples_txt'} {'text9'} {'duration_txt'} {'text5'} {'sample_time_txt'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-3 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end
 
field_list = [{'load_prev_ecg_button'} {'load_next_ecg_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2) v(3) v(4)-3];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'text129'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-1 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

set(handles.load_prev_ecg_button,'FontSize',10);
set(handles.load_next_ecg_button,'FontSize',10);

field_list = [{'pacer_interpolation_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-2 v(3) v(4)-2];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'gui_pacing_indicator'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-4 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
    set(handles.(field_list{i}),'FontSize',24) 
end

field_list = [{'num_paced_leads_detected_txtbox'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-2 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


% Fiducial Points
% Move buttons down

field_list = [{'import_fidpts_button'} {'calculate'} {'reset'} {'debug_anno'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-6 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'Tendmethod'} {'uipanel92'} {'uipanel93'}];

for i = 1:length(field_list)
    set(handles.(field_list{i}),'BorderType','none');
    set(handles.(field_list{i}),'BorderColor',gray);
    set(handles.(field_list{i}), 'BackgroundColor',gray)
end


field_list = [{'align_dropdown'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-2 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'uipanel14'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-1 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'uipanel92'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-3 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'Tendmethod'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-6 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'tend_method_dropdown'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)+2 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'uipanel8'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-5 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'uipanel26'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-6 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'text550'} {'text142'} {'text143'} {'text144'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-4 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
    set(handles.(field_list{i}),'FontSize',8) 
end

field_list = [{'uibuttongroup4'} {'uibuttongroup13'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-6 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'uipanel44'} {'uipanel136'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-6 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


% VCG Window
field_list = [{'uipanel29'} {'uipanel45'} {'uipanel37'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-3 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

% VCG Window
field_list = [{'uipanel41'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-4 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

% VCG Window
field_list = [{'uipanel95'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-5 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end



field_list = [{'pop_out_vcg_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-2 v(3) v(4)-1];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'full_vcg_button'} {'animate_vcg_button'} {'camera_button'} {'frontal_view_button'} ...
    {'trans_view_button'} {'sag_view_button'} {'view_ori_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-3 v(3) v(4)-1];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'animate_vcg_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)+3 v(3) v(4)-1];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'camera_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)+2 v(3) v(4)-1];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'rot_r_button'} {'rot_l_button'} {'rot_r2_button'} {'rot_l2_button'} {'rot_u_button'} {'rot_d_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2) v(3) v(4)-3];
    set(handles.(field_list{i}),'Position',x);
    set(handles.(field_list{i}),'FontSize',8.5)
end

field_list = [{'refresh_vcg_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-3 v(3) v(4)-3];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'save3dfig_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-2 v(3) v(4)-2];
    set(handles.(field_list{i}),'Position',x);
end


% Beat selection/shifting

field_list = [{'shift_box'} {'text179'} {'text576'} {'shift_median_checkbox'} {'qon_shift_button'} ...
    {'rpk_shift_button'} {'qoff_shift_button'} {'toff_shift_button'} {'qon_minus_button'} {'qon_plus_button'} ...
    {'rpeak_minus_button'} {'rpeak_plus_button'} {'qoff_minus_button'} {'qoff_plus_button'} {'toff_minus_button'} ...
    {'toff_plus_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-4 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


field_list = [{'qon_shift_button'} {'rpk_shift_button'} {'qoff_shift_button'} {'toff_shift_button'} {'qon_minus_button'} ...
    {'qon_plus_button'} {'rpeak_minus_button'} {'rpeak_plus_button'} {'qoff_minus_button'} {'qoff_plus_button'} ...
    {'toff_minus_button'} {'toff_plus_button'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2) v(3) v(4)-3];
    set(handles.(field_list{i}),'Position',x);
end


% Other buttons/text

field_list = [{'quality_score_txt'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1)-3 v(2) v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


field_list = [{'text711'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-5 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


field_list = [{'text761'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-5 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


field_list = [{'uipanel129'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1) v(2)-3 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end

field_list = [{'auto_remove_outliers_checkbox'}];

for i = 1:length(field_list)
    v = get(handles.(field_list{i}),'Position');
    x = [v(1)+2 v(2)-2 v(3) v(4)];
    set(handles.(field_list{i}),'Position',x);
end


% Speed - FUTURE EDITS

