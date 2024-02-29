%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% geh_sensitivity.m -- Performs sensitivity analysis on given ECG
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


function geh_sensitivity(filename, median_vcg, medianbeat, aps, step)

% Save original medianbeat
medianbeat_orig = medianbeat;
% Start looping through the fiducial points and calculating VCG_Calc

% Start with shifting Qbeg (Q)
index_q = 0; % Index for organizing into spreadsheet rows later
for i = -step:step 
    index_q = index_q + 1;
    medianbeat = medianbeat_orig.shift_q(i);
    note = strcat('shift Q', {' '}, num2str(i), {' :    '}, num2str(medianbeat.beatmatrix())); % label
    geh_q(index_q,:) = [note, num2cell(VCG_Calc(median_vcg, medianbeat, aps).values())];
    geh_q_num(index_q,:) = VCG_Calc(median_vcg, medianbeat, aps).values();   
    geh_q_class(index_q,:) = VCG_Calc(median_vcg, medianbeat, aps); 
    if i == 0
        geh_q_class_init = VCG_Calc(median_vcg, medianbeat, aps);
        geh_q_class_init_num = VCG_Calc(median_vcg, medianbeat, aps).values();
    end
end

% have to catch errors due to some values being text
for p = 1:size(geh_q_num,2)
    try
        geh_mean_q(p) = mean(geh_q_num(:,p));
        geh_std_q(p) = std(geh_q_num(:,p));
        geh_median_q(p) = median(geh_q_num(:,p));
        geh_iqr_q(p) = iqr(geh_q_num(:,p));
        
        temp = abs(geh_q_num(:,p) - geh_q_class_init_num(p));
        geh_maxchange_q(p) = max(temp);
        geh_maxchange_percent_q(p) = abs(100*(geh_maxchange_q(p)/geh_q_class_init_num(p)));
        
    catch
        geh_mean_q(p) = NaN;
        geh_std_q(p) = NaN;
        geh_median_q(p) = NaN;
        geh_iqr_q(p) = NaN;
        geh_maxchange_q(p) = NaN;
        geh_maxchange_percent_q(p) = NaN;

    end
end
    
% Q onset detector
% xq_lt_percent = 100* (max(abs([geh_q_class(1:step).sai_x] - geh_q_class_init.sai_x)))/geh_q_class_init.sai_x;
% yq_lt_percent = 100* (max(abs([geh_q_class(1:step).sai_y] - geh_q_class_init.sai_y)))/geh_q_class_init.sai_y;
% zq_lt_percent = 100* (max(abs([geh_q_class(1:step).sai_z] - geh_q_class_init.sai_z)))/geh_q_class_init.sai_z;
%vmq_lt_percent = 100* (max(abs([geh_q_class(1:step).sai_vm] - geh_q_class_init.sai_vm)))/geh_q_class_init.sai_vm;

% xq_rt_percent = 100* (max(abs([geh_q_class(step+2:end).sai_x] - geh_q_class_init.sai_x)))/geh_q_class_init.sai_x;
% yq_rt_percent = 100* (max(abs([geh_q_class(step+2:end).sai_y] - geh_q_class_init.sai_y)))/geh_q_class_init.sai_y;
% zq_rt_percent = 100* (max(abs([geh_q_class(step+2:end).sai_z] - geh_q_class_init.sai_z)))/geh_q_class_init.sai_z;
%vmq_rt_percent = 100* (max(abs([geh_q_class(step+2:end).sai_vm] - geh_q_class_init.sai_vm)))/geh_q_class_init.sai_vm;



% Qend (S) 
index_s = 0;
for m = -step:step 
    index_s = index_s + 1;
    medianbeat =  medianbeat_orig.shift_s(m);
    note = strcat('shift S', {' '}, num2str(m), {' :    '}, num2str(medianbeat.beatmatrix())); % label
    geh_s(index_s,:) = [note, num2cell(VCG_Calc(median_vcg, medianbeat, aps).values())];
    geh_s_num(index_s,:) = VCG_Calc(median_vcg, medianbeat, aps).values();
    geh_s_class(index_q,:) = VCG_Calc(median_vcg, medianbeat, aps); 
    if m == 0
        geh_s_class_init = VCG_Calc(median_vcg, medianbeat, aps);
        geh_s_class_init_num = VCG_Calc(median_vcg, medianbeat, aps).values();
    end
end


% have to catch errors due to some values being text
for p = 1:size(geh_s_num,2)
    try
        geh_mean_s(p) = mean(geh_s_num(:,p));
        geh_std_s(p) = std(geh_s_num(:,p));
        geh_median_s(p) = median(geh_s_num(:,p));
        geh_iqr_s(p) = iqr(geh_s_num(:,p));
               
        temp = abs(geh_s_num(:,p) - geh_s_class_init_num(p));
        geh_maxchange_s(p) = max(temp);
        geh_maxchange_percent_s(p) = abs(100*(geh_maxchange_s(p)/geh_s_class_init_num(p)));

    catch
        geh_mean_s(p) = NaN;
        geh_std_s(p) = NaN;
        geh_median_s(p) = NaN;
        geh_iqr_s(p) = NaN;
        geh_maxchange_s(p) = NaN;
        geh_maxchange_percent_s(p) = NaN;

    end
end


% Tend
jt = 40/(1000/median_vcg.hz);
medianbeat_shift = medianbeat_orig.shift_tend(jt);
geh_t_class_shifted = VCG_Calc(median_vcg, medianbeat_shift, aps);

index_t = 0;
for k = -step:step 
    index_t = index_t + 1;
    medianbeat =  medianbeat_orig.shift_tend(k);
    note = strcat('shift T', {' '}, num2str(k), {' :    '}, num2str(medianbeat.beatmatrix())); % label
    geh_t(index_t,:) = [note, num2cell(VCG_Calc(median_vcg, medianbeat, aps).values())];
    geh_t_num(index_t,:) = VCG_Calc(median_vcg, medianbeat, aps).values();
    geh_t_class(index_t,:) = VCG_Calc(median_vcg, medianbeat, aps); 
    if k == 0
        geh_t_class_init = VCG_Calc(median_vcg, medianbeat, aps);
        geh_t_class_init_num = VCG_Calc(median_vcg, medianbeat, aps).values();
    end
end


% have to catch errors due to some values being text
for p = 1:size(geh_t_num,2)
    try
        geh_mean_t(p) = mean(geh_t_num(:,p));
        geh_std_t(p) = std(geh_t_num(:,p));
        geh_median_t(p) = median(geh_t_num(:,p));
        geh_iqr_t(p) = iqr(geh_t_num(:,p));
                
        temp = abs(geh_t_num(:,p) - geh_t_class_init_num(p));
        geh_maxchange_t(p) = max(temp);
        geh_maxchange_percent_t(p) = abs(100*(geh_maxchange_t(p)/geh_t_class_init_num(p)));

    catch
        geh_mean_t(p) = NaN;
        geh_std_t(p) = NaN;
        geh_median_t(p) = NaN;
        geh_iqr_t(p) = NaN;
        geh_maxchange_t(p) = NaN;
        geh_maxchange_percent_t(p) = NaN;

    end
end


% a1 = sqrt(geh_t_class_init.XT_area^2 + geh_t_class_init.YT_area^2 + geh_t_class_init.ZT_area^2);
% a2 = sqrt(geh_t_class_shifted.XT_area^2 + geh_t_class_shifted.YT_area^2 + geh_t_class_shifted.ZT_area^2);
% a1 = [geh_t_class_init.XT_area geh_t_class_init.YT_area geh_t_class_init.ZT_area];
% a2 = [geh_t_class_shifted.XT_area geh_t_class_shifted.YT_area geh_t_class_shifted.ZT_area];
% percent_t = max(abs(100*(a2-a1)./a1));

% Looking at individual X, Y, Z areas for T wave does not work because
% falls apart if the T waves are flat - get large percent changes.  Will
% now look at change in VM T wave area with goal of testing if annotation
% of T end is ok.

% shift_left = medianbeat_orig.shift_tend(round(-20/(1000/median_vcg.hz)));
% shift_right = medianbeat_orig.shift_tend(round(20/(1000/median_vcg.hz)));
% 
% t1 = trapz(median_vcg.VM(medianbeat_orig.S:medianbeat_orig.Tend));
% t2 = trapz(median_vcg.VM(shift_right.S:shift_right.Tend));
% t3 = trapz(median_vcg.VM(shift_left.S:shift_left.Tend));
% percent_t_right = max(abs(100*(t2-t1)./t1));
% percent_t_left = max(abs(100*(t3-t1)./t1));
% t_index = (percent_t_left - percent_t_right)/ percent_t_right;


% shift_left = medianbeat_orig.shift_q(round(-20/(1000/median_vcg.hz)));
% shift_right = medianbeat_orig.shift_q(round(20/(1000/median_vcg.hz)));
% 
% q1 = trapz(median_vcg.VM(medianbeat_orig.Q:medianbeat_orig.S));
% q2 = trapz(median_vcg.VM(shift_right.Q:shift_right.S));
% q3 = trapz(median_vcg.VM(shift_left.Q:shift_left.S));
% percent_q_right = max(abs(100*(q2-q1)./q1));
% percent_q_left = max(abs(100*(q3-q1)./q1));
% q_index = (percent_q_right - percent_q_left)/ percent_q_left;

% 
% xt_lt_percent = 100* (max(abs([geh_t_class(1:step).sai_x] - geh_t_class_init.sai_x)))/geh_t_class_init.sai_x;
% yt_lt_percent = 100* (max(abs([geh_t_class(1:step).sai_y] - geh_t_class_init.sai_y)))/geh_t_class_init.sai_y;
% zt_lt_percent = 100* (max(abs([geh_t_class(1:step).sai_z] - geh_t_class_init.sai_z)))/geh_t_class_init.sai_z;
% vmt_lt_percent = 100* (max(abs([geh_t_class(1:step).sai_vm] - geh_t_class_init.sai_vm)))/geh_t_class_init.sai_vm;
% 
% vmt_left_percent = max([xt_lt_percent yt_lt_percent zt_lt_percent vmt_lt_percent])
% 
% xt_rt_percent = 100* (max(abs([geh_t_class(step+2:end).sai_x] - geh_t_class_init.sai_x)))/geh_t_class_init.sai_x;
% yt_rt_percent = 100* (max(abs([geh_t_class(step+2:end).sai_y] - geh_t_class_init.sai_y)))/geh_t_class_init.sai_y;
% zt_rt_percent = 100* (max(abs([geh_t_class(step+2:end).sai_z] - geh_t_class_init.sai_z)))/geh_t_class_init.sai_z;
% vmt_rt_percent = 100* (max(abs([geh_t_class(step+2:end).sai_vm] - geh_t_class_init.sai_vm)))/geh_t_class_init.sai_vm;
% vmt_right_percent = max([xt_rt_percent yt_rt_percent zt_rt_percent vmt_rt_percent])

% max_t_right = max([xq_rt_percent yq_rt_percent zq_rt_percent])
% max_t_left = max([xq_lt_percent yq_lt_percent zq_lt_percent])


% Write all data to Excel

% Write header w/ variable names
g = VCG_Calc();
excel_header = [{'note'} properties(g)'];

% Matrix of std deviations
geh_stats_q = nan(5,size(geh_q_num,2));
geh_stats_s = nan(5,size(geh_s_num,2));
geh_stats_s = nan(5,size(geh_t_num,2));
   
% Blank line
blank_cell = {'.'};
blank = repmat(blank_cell,1,length(excel_header));

% Create stat matrices
geh_stats_q = [geh_mean_q; geh_std_q; nan(1,length(geh_mean_q)); geh_median_q; geh_iqr_q; nan(1,length(geh_mean_q)); geh_maxchange_q; geh_maxchange_percent_q];  
geh_stats_s = [geh_mean_s; geh_std_s; nan(1,length(geh_mean_s)); geh_median_s; geh_iqr_s; nan(1,length(geh_mean_s)); geh_maxchange_s; geh_maxchange_percent_s]; 
geh_stats_t = [geh_mean_t; geh_std_t; nan(1,length(geh_mean_t)); geh_median_t; geh_iqr_t; nan(1,length(geh_mean_t)); geh_maxchange_t; geh_maxchange_percent_t]; 

% Get rid of NaNs for excel export
geh_stats_cell_q = num2cell(geh_stats_q);
geh_stats_cell_q(isnan(geh_stats_q)) ={'.'};

geh_stats_cell_s = num2cell(geh_stats_s);
geh_stats_cell_s(isnan(geh_stats_s)) ={'.'};

geh_stats_cell_t = num2cell(geh_stats_t);
geh_stats_cell_t(isnan(geh_stats_t)) ={'.'};

% Add mean and std col "headers" to the first column of geh_stats
col = [{'Mean'};{'Std Deviation'};{' '};{'Median'};{'IQR'};{' '};{'Max Change'};{'% Max Change'}];
geh_stats_cell_q = [col geh_stats_cell_q];
geh_stats_cell_s = [col geh_stats_cell_s];
geh_stats_cell_t = [col geh_stats_cell_t];


% Create matrix of all geh calculations - Q then S then Tend then blank then stats
full_data = [excel_header; geh_q; blank; geh_stats_cell_q; blank; blank;...
    geh_s; blank; geh_stats_cell_s; blank; blank;...
    geh_t; blank; geh_stats_cell_t];

% Write to excel as single write operation 
if ~isempty(filename)
    writecell(full_data, char(filename));  
end



% Q onset detecetor broken at the moment
% q_bad_thresh = 4.5;
% if (q_index < q_bad_thresh)
%   q_bad = 0;
% else
%   q_bad = 0;
% end

%  q_bad = 0;
%  
%  
% t_bad_thresh = 0.15;
% 
% % Looking to see what happens to 
% if (t_index < t_bad_thresh)
%   t_bad = 1;
% else
%   t_bad = 0;
% end

%display('Complete');  % completed write operation


end