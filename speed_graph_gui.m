%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% speed_grap_guih.m -- Part of BRAVEHEART GUI - Shows speed figure
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

function speed_graph_gui(hObject, eventdata, handles, filename, save_flag, auto_flag, blank_samples, blank_samples_t, accel_flag, legend_flag, colors, popout)

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

if ~popout 
    cla(handles.speed_axis,'reset')
end

Q = handles.medianbeat.Q;
S = handles.medianbeat.S;
Tend = handles.medianbeat.Tend;

medianvm = handles.median_vcg.VM;
medianx = handles.median_vcg.X;
mediany = handles.median_vcg.Y;
medianz = handles.median_vcg.Z;
sample_time = 1000/handles.vcg.hz;

% Convert blanking windows in ms to samples
blank_q_ms = blank_samples;
blank_t_ms = blank_samples_t;
blank_samples = round(blank_samples/sample_time);
blank_samples_t = round(blank_samples_t/sample_time);

speed_3d = zeros(1,length(handles.median_vcg.VM));
    for i=1:length(speed_3d)-1
        speed_3d(i+1)= sqrt((medianx(i+1)-medianx(i))^2+(mediany(i+1)-mediany(i))^2+(medianz(i+1)-medianz(i))^2)/sample_time; 
    end
speed_3d(1)=nan;  % correct for no velocity at point 1 (otherwise always = 0)
 
max_vm =max(medianvm);
max_speed = max(speed_3d);


% ACCELERATION 
accel_3d=nan(1,length(medianvm));

for i=1:length(accel_3d)-1
    accel_3d(i+1) = (speed_3d(i+1) - speed_3d(i)) / sample_time;
end

% Make calculations
[speed_qrs_max, ~, ~] = min_max_locs(speed_3d, Q, S, blank_samples, 1000/sample_time);  
[speed_t_max, ~, ~] = min_max_locs(speed_3d, S, Tend, blank_samples_t, 1000/sample_time); 

[accel_pos_max, ~, ~] = min_max_locs(accel_3d, Q, length(accel_3d), blank_samples, 1000/sample_time);  
[accel_neg_max, ~, ~] = min_max_locs(-accel_3d, Q, length(accel_3d), blank_samples, 1000/sample_time);  

% Will graph speed vs time instead of sample number
% Starting at time = 0 ms
tx = 0:sample_time:(length(medianvm)*(sample_time))-1;


% If shift Qon to 0 ms
tx = tx - ((Q-1)*sample_time);
Qorig = Q;
Q = Q - Qorig;
S = (S - Qorig) * sample_time;
Tend = (Tend - Qorig) * sample_time;

% Now Q, S, and Tend are shifted so that Qon is at time 0
% Q, S, and Tend are now in MILLISECONDS, not samples


% Graph inside GUI or as a popout
if popout == 0
    axes(handles.speed_axis)
elseif popout == 1
    fig_vcgspeed = figure('name','VCG Speed','numbertitle','off');
    set(fig_vcgspeed,'defaultAxesColorOrder',[colors.xyzecg; [1 0 0]]);
    set(gcf, 'Position', [0, 0, 1200, 600])  % set figure size
end

yyaxis left
s1 = plot(tx,medianvm,'LineWidth',2,'displayname','VCG VM');
hold on
xlabel('Time (ms)','FontWeight','bold','FontSize',12, 'color', colors.txtcolor);
xlim([min(tx) max(tx)]);
ylabel('VM Voltage (mV)','FontWeight','bold','FontSize',12);
set(gca,'XColor',colors.txtcolor);

% Draw dashed lines at Qon, Qoff, Toff
sqoff = line([S S],[0 max([max_vm max_speed])],'color', 'b','linewidth',1,'linestyle','--','displayname','QRS End');
sqon = line([Q Q],[0 max([max_vm max_speed])],'color', 'k','linewidth',1,'linestyle','--','displayname','QRS Start');
stoff = line([Tend Tend],[0 max([max_vm max_speed])],'color', 'r','linewidth',1,'linestyle','--','displayname','T End');

% assign ylim for left axis
left_ylim_min = min(ylim);
left_ylim_max = max(ylim);

% Add max speed in QRS complex to figure
s4 = scatter(tx(speed_qrs_max.loc_samp), medianvm(speed_qrs_max.loc_samp),70,'d','linewidth',1.3,'MarkerEdgeColor',[0 0 0],'displayname','Fastest QRS Segment');
s4_2 = scatter(tx(speed_qrs_max.loc_samp_st), medianvm(speed_qrs_max.loc_samp_st),70,'d','linewidth',1.3,'MarkerEdgeColor',[0 0 0],'displayname','Fastest QRS Segment2');
s4_m = scatter(0.5*(tx(speed_qrs_max.loc_samp)+tx(speed_qrs_max.loc_samp_st)), 0.5*(medianvm(speed_qrs_max.loc_samp)+medianvm(speed_qrs_max.loc_samp_st)),90,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor','k','displayname','Fastest QRS Point (Mean)');
line([tx(speed_qrs_max.loc_samp) tx(speed_qrs_max.loc_samp_st)],[medianvm(speed_qrs_max.loc_samp) medianvm(speed_qrs_max.loc_samp_st)],'Color','k','linewidth',2);

% Add max speed in T wave to figure
s5 = scatter(tx(speed_t_max.loc_samp), medianvm(speed_t_max.loc_samp),70,'d','linewidth',1.3,'MarkerEdgeColor',[0 0.7 0],'displayname','Fastest QRS Segment');
s5_2 = scatter(tx(speed_t_max.loc_samp_st), medianvm(speed_t_max.loc_samp_st),70,'d','linewidth',1.3,'MarkerEdgeColor',[0 0.7 0],'displayname','Fastest QRS Segment2');
s5_m = scatter(0.5*(tx(speed_t_max.loc_samp)+tx(speed_t_max.loc_samp_st)), 0.5*(medianvm(speed_t_max.loc_samp)+medianvm(speed_t_max.loc_samp_st)),90,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0.7 0],'displayname','Fastest QRS Point (Mean)');
line([tx(speed_t_max.loc_samp) tx(speed_t_max.loc_samp_st)],[medianvm(speed_t_max.loc_samp) medianvm(speed_t_max.loc_samp_st)],'Color',[0 0.7 0],'linewidth',2);

yyaxis right
s2 = plot(tx,speed_3d,'LineWidth',2,'color','r','displayname','VCG Speed');
ylabel('Speed (mV/ms)','FontWeight','bold','FontSize',12,'color','r')
xlim([min(tx) max(tx)]);
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

        s_accel = plot(tx,accel_3d,'LineWidth',2,'color','[0 0.3 0]','linestyle','-','displayname','Acceleration');
        
        ylabel('Speed (mV/ms) {\color{black}&} {\color[rgb]{0,0.5,0}Acceleration (mV/ms^{2})}','FontWeight','bold','FontSize',12)
        
        % assign ylim for right axis
        right_ylim_min = min(ylim);
        right_ylim_max = max(ylim);

        % switch back to left axis to plot poitns of max acceleration on median beat
        yyaxis left

        s6 = scatter(tx(accel_pos_max.loc_samp), medianvm(accel_pos_max.loc_samp),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.9290, 0.6940, 0.1250]','displayname','Max Pos Acceleration Segment');
        scatter(tx(accel_pos_max.loc_samp_st), medianvm(accel_pos_max.loc_samp_st),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.9290, 0.6940, 0.1250]','displayname','Max Pos Acceleration2');
        s6_m = scatter(0.5*(tx(accel_pos_max.loc_samp)+tx(accel_pos_max.loc_samp_st)), 0.5*(medianvm(accel_pos_max.loc_samp)+medianvm(accel_pos_max.loc_samp_st)),90,'MarkerEdgeColor','k','MarkerFaceColor','[0.9290, 0.6940, 0.1250]','displayname','Max Pos Acceleration Point (Mean)');
        line([tx(accel_pos_max.loc_samp) tx(accel_pos_max.loc_samp_st)],[medianvm(accel_pos_max.loc_samp) medianvm(accel_pos_max.loc_samp_st)],'Color','[0.9290, 0.6940, 0.1250]','linewidth',2);

        s7 = scatter(tx(accel_neg_max.loc_samp), medianvm(accel_neg_max.loc_samp),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.4940, 0.1840, 0.5560]','displayname','Max Neg Acceleration Segment');
        scatter(tx(accel_neg_max.loc_samp_st), medianvm(accel_neg_max.loc_samp_st),70,'d','linewidth',1.3,'MarkerEdgeColor','[0.4940, 0.1840, 0.5560]','displayname','Max Neg Acceleration2');
        s7_m = scatter(0.5*(tx(accel_neg_max.loc_samp)+tx(accel_neg_max.loc_samp_st)), 0.5*(medianvm(accel_neg_max.loc_samp)+medianvm(accel_neg_max.loc_samp_st)),90,'MarkerEdgeColor','k','MarkerFaceColor','[0.4940, 0.1840, 0.5560]','displayname','Max Neg Acceleration Point (Mean)');
        line([tx(accel_neg_max.loc_samp) tx(accel_neg_max.loc_samp_st)],[medianvm(accel_neg_max.loc_samp) medianvm(accel_neg_max.loc_samp_st)],'Color','[0.4940, 0.1840, 0.5560]','linewidth',2);
end

% QRS onset blanking period line and fills
yyaxis right
if blank_samples >= 0       % Always will be some blanking prior to QRS onset
    s_fill = fill([min(tx) (Q+blank_q_ms) (Q+blank_q_ms) min(tx)], [right_ylim_min right_ylim_min right_ylim_max right_ylim_max ],[0.6 0.6 0.6],'EdgeColor','none','facealpha',0.3,'displayname','Blanking Period');
end


% T wave onset blanking period line and fills
yyaxis right
if blank_samples_t > 0      % Only show blaking if blank_samples_t > 0
    s_fill_t = fill([S (S+blank_t_ms) (S+blank_t_ms) S], [right_ylim_min right_ylim_min right_ylim_max right_ylim_max ],[0.6 0.6 0.6],'EdgeColor','none','facealpha',0.3,'displayname','Blanking Period');
end

if legend_flag == 1

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
else
    legend('off');
end


%set(gcf, 'Position', [200, 100, 1200, 800])  % set figure size
xlim([min(tx) max(tx)]);

% Need to find lower limit of Xtick label with 50 ms delta and starting at
% zero going backwards to negative numbers in tx
d = 50;

% Take ceiling because negative
tx_div = ceil(tx/d);
d_start = tx_div(1) * d;
xticks(d_start:d:(sample_time*length(medianvm)));

%title(strcat({'Speed of VCG Complex - '},{' '},{handles.filename_short(1:end-4)}),'fontsize',14,'Interpreter', 'none');
hold off

% Save
if save_flag == 1 && popout == 1
    print(gcf,'-dpng',filename,'-r600');
end

%%# Auto close figure for auto saving
if auto_flag == 1
%close(fig_vcgspeed)
end


