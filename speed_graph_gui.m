%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% speed_grap_guih.m -- Part of BRAVEHEART GUI - Shows speed figure
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

function speed_graph_gui(hObject, eventdata, handles, filename, save_flag, auto_flag, blank_samples, accel_flag)

save_folder = get(handles.save_dir_txt,'String');

% speed defined as the speed going to point n (eg distance of pt n minues pt n-1
% Therefore point 1 will have no speed (because no point 0).  This
% prevents the last point from having speed undefined -- but it is a matter
% of convention.  Because speed_3d(n) is the speed between point n-1 going
% to point n, we define the "time" of this point as sample (n + (n-1))/2, or
% the time between these 2 points.  eg, speed_3d(2) is the speed between
% points 1 -> 2.  Because time starts at 0 the timing assigned to speed_3d(n) 
% is the average of TIME n-1 and n.

% Therefore, if freq is 500 Hz and each sample is 2 ms, then speed(2) is the
% speed between time 0 ms (sample 1) and time 2 ms (sample 2) = 1 ms.  If
% Freq is 1000 hz, then speed_3d(3) is the speed between sample 2 (time
% point 1 = 1 ms) and sample 3 (time point 2 = 2 ms) and is equal to 1.5 ms.

S = handles.medianbeat.S;
Q = handles.medianbeat.Q;
Tend = handles.medianbeat.Tend;

medianvm = handles.median_vcg.VM;
medianx = handles.median_vcg.X;
mediany = handles.median_vcg.Y;
medianz = handles.median_vcg.Z;
sample_time = 1000/handles.vcg.hz;

% Adjust blanking samples because Qon will no longer always be at sample 1
blank_samples = blank_samples + Q-1;

speed_3d = zeros(1,length(handles.median_vcg.VM));
    for i=1:length(speed_3d)-1
        speed_3d(i+1)= sqrt((medianx(i+1)-medianx(i))^2+(mediany(i+1)-mediany(i))^2+(medianz(i+1)-medianz(i))^2)/sample_time; 
    end
speed_3d(1)=nan;  % correct for no velocity at point 1 (otherwise always = 0)
 
max_vm =max(medianvm);
max_speed = max(speed_3d);

% Will graph speed vs time instead of sample number
tx = 0:sample_time:(length(medianvm)*(sample_time))-1;


% ACCELERATION 
accel_3d=zeros(1,length(medianvm));

for i=1:length(accel_3d)-1
accel_3d(i+1) = (speed_3d(i+1) - speed_3d(i)) / sample_time;
end


axes(handles.speed_axis)
%fig_vcgspeed = figure('name','VCG Speed','numbertitle','off');
%set(fig_vcgspeed,'defaultAxesColorOrder',[[0 0.4470 0.7410]; [1 0 0]]);

yyaxis left
s1 = plot(tx,medianvm,'LineWidth',2,'displayname','VCG VM');
hold on
xlabel('Time (ms)','FontWeight','bold','FontSize',12);
xlim([0 max(tx)]);


ylabel('VM Voltage (mV)','FontWeight','bold','FontSize',12);
if max_speed <= max_vm
sqoff = line([(S-1)*sample_time (S-1)*sample_time],[0 max_vm],'color', 'b','linewidth',1,'linestyle','--','displayname','QRS End');
sqon = line([(Q-1)*sample_time (Q-1)*sample_time],[0 max_vm],'color', 'k','linewidth',1,'linestyle','--','displayname','QRS Start');
stoff = line([(Tend-1)*sample_time (Tend-1)*sample_time],[0 max_vm],'color', 'r','linewidth',1,'linestyle','--','displayname','T End');
end

% assign ylim for left axis
left_ylim_min = min(ylim);
left_ylim_max = max(ylim);


% Add max speed in QRS complex to figure
max_qrs_speed_loc = find(speed_3d(blank_samples+1:S) == max(speed_3d(blank_samples+1:S))) + blank_samples;
s4 = scatter(tx(max_qrs_speed_loc), medianvm(max_qrs_speed_loc),70,'d','linewidth',1.3,'MarkerEdgeColor',[0 0 0],'displayname','Fastest QRS Segment');
s4_2 = scatter(tx(max_qrs_speed_loc-1), medianvm(max_qrs_speed_loc-1),70,'d','linewidth',1.3,'MarkerEdgeColor',[0 0 0],'displayname','Fastest QRS Segment2');

line([tx(max_qrs_speed_loc-1) tx(max_qrs_speed_loc)],[medianvm(max_qrs_speed_loc-1) medianvm(max_qrs_speed_loc)],'Color','k','linewidth',2);

s4_m = scatter(0.5*(tx(max_qrs_speed_loc-1)+tx(max_qrs_speed_loc)), 0.5*(medianvm(max_qrs_speed_loc-1)+medianvm(max_qrs_speed_loc)),90,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor','k','displayname','Fastest QRS Point (Mean)');


% Add max speed in T wave to figure
max_t_speed_loc = find(speed_3d(S:end) == max(speed_3d(S:end)));
s5 = scatter(tx(max_t_speed_loc+S-1), medianvm(max_t_speed_loc+S-1),70,'d','linewidth',1.3,'MarkerEdgeColor','[0 0.7 0]','displayname','Fastest T Segment');
s5_2 = scatter(tx(max_t_speed_loc+S-2), medianvm(max_t_speed_loc+S-2),70,'d','linewidth',1.3,'MarkerEdgeColor','[0 0.7 0]','displayname','Fastest T Segment2');

line([tx(max_t_speed_loc+S-2) tx(max_t_speed_loc+S-1)],[medianvm(max_t_speed_loc+S-2) medianvm(max_t_speed_loc+S-1)],'Color','[0 0.7 0]','linewidth',2);

s5_m = scatter(0.5*(tx(max_t_speed_loc+S-1)+tx(max_t_speed_loc+S-2)), 0.5*(medianvm(max_t_speed_loc+S-1)+medianvm(max_t_speed_loc+S-2)),90,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor','[0 0.7 0]','displayname','Fastest T Point (Mean)');



yyaxis right
s2 = plot(tx,speed_3d,'LineWidth',1,'color','r','displayname','VCG Speed');
ylabel('Speed (mV/ms)','FontWeight','bold','FontSize',12)
xlim([0 max(tx)]);
if max_speed > max_vm
sqoff = line([S S],[0 max(ylim)],'color', 'k','linewidth',1,'linestyle','--','displayname','QRS End');
sqon = line([Q Q],[0 max(ylim)],'color', 'k','linewidth',1,'linestyle','--','displayname','QRS Start');
stoff = line([Tend Tend],[0 max(ylim)],'color', 'k','linewidth',1,'linestyle','--','displayname','T End');
end


% assign ylim for right axis
right_ylim_min = min(ylim);
right_ylim_max = max(ylim);



if accel_flag == 1

        % Accel graph
        % Add acceleration tracing and min/max

        s_accel = plot(tx,accel_3d,'LineWidth',1,'color','[0 0.3 0]','linestyle','-','displayname','Acceleration');
        
        ylabel('Speed (mV/ms) {\color{black}&} {\color[rgb]{0,0.5,0}Acceleration (mV/ms^{2})}','FontWeight','bold','FontSize',12)
        
        % assign ylim for right axis
        right_ylim_min = min(ylim);
        right_ylim_max = max(ylim);

        %%% switch back to left axis to plot poitns of max acceleration on median beat
        yyaxis left
        max_accel_loc_pos = find(accel_3d(blank_samples+1:Tend) == max(accel_3d(blank_samples+1:Tend))) + blank_samples;
        max_accel_loc_neg = find(-accel_3d(blank_samples+1:Tend) == max(-accel_3d(blank_samples+1:Tend))) + blank_samples;
        
        s6 = scatter(tx(max_accel_loc_pos), medianvm(max_accel_loc_pos),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.9290, 0.6940, 0.1250]','displayname','Max Pos Acceleration Segment');
        scatter(tx(max_accel_loc_pos-1), medianvm(max_accel_loc_pos-1),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.9290, 0.6940, 0.1250]','displayname','Max Pos Acceleration2');
        s6_m = scatter(0.5*(tx(max_accel_loc_pos-1)+tx(max_accel_loc_pos)), 0.5*(medianvm(max_accel_loc_pos-1)+medianvm(max_accel_loc_pos)),90,'MarkerEdgeColor','k','MarkerFaceColor','[0.9290, 0.6940, 0.1250]','displayname','Max Pos Acceleration Point (Mean)');


        s7 = scatter(tx(max_accel_loc_neg), medianvm(max_accel_loc_neg),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.4940, 0.1840, 0.5560]','displayname','Max Neg Acceleration Segment');
        scatter(tx(max_accel_loc_neg-1), medianvm(max_accel_loc_neg-1),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.4940, 0.1840, 0.5560]','displayname','Max Neg Acceleration2');
        s7_m = scatter(0.5*(tx(max_accel_loc_neg-1)+tx(max_accel_loc_neg)), 0.5*(medianvm(max_accel_loc_neg-1)+medianvm(max_accel_loc_neg)),90,'MarkerEdgeColor','k','MarkerFaceColor','[0.4940, 0.1840, 0.5560]','displayname','Max Neg Acceleration Point (Mean)');

        

end

% blanking period line
yyaxis right
if blank_samples >0
s_fill = fill([0 blank_samples*sample_time blank_samples*sample_time 0], [right_ylim_min right_ylim_min right_ylim_max right_ylim_max ],[0.6 0.6 0.6],'EdgeColor','none','facealpha',0.3,'displayname','Blanking Period');
end




if blank_samples == 0 && accel_flag == 0
legend([s1 s2 sqon sqoff stoff s4 s4_m s5 s5_m])
%legend([s1 s2 s3 s4 s4_m])
legend('show','location','bestoutside')
end

if blank_samples >0 && accel_flag == 0
legend([s1 s2 sqon sqoff stoff s_fill s4 s4_m s5 s5_m])
%legend([s1 s2 s3 s4 s4_m])
legend('show','location','bestoutside')
end

if blank_samples == 0 && accel_flag == 1
legend([s1 s2 s_accel sqon sqoff stoff s4 s4_m s5 s5_m s6 s6_m s7 s7_m])
%legend([s1 s2 s3 s4 s4_m])
legend('show','location','bestoutside')
end


if blank_samples >0 && accel_flag == 1
legend([s1 s2 s_accel sqon sqoff stoff s_fill s4 s4_m s5 s5_m s6 s6_m s7 s7_m])
%legend([s1 s2 s3 s4 s4_m])
legend('show','location','bestoutside')
end

%set(gcf, 'Position', [200, 100, 1200, 800])  % set figure size
xlim([0 max(tx)]);
xticks(0:50:(sample_time*length(medianvm)));


%title(strcat({'Speed of VCG Complex - '},{' '},{handles.filename_short(1:end-4)}),'fontsize',14,'Interpreter', 'none');
hold off

% %%# save
% if save_flag == 1
%  print(gcf,'-dpng',[fullfile(save_folder,filename) '_speed.png'],'-r600');
% end

%%# Auto close figure for auto saving
if auto_flag == 1
%close(fig_vcgspeed)
end


