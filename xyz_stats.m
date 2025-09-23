%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% xyz_stats.m -- Visualize statistics for each beat in the X, Y, Z leads
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

function  [svg_x, svg_y, svg_z, sai_x, sai_y, sai_z, sai_vm] = xyz_stats(n, hObject, eventdata, handles)

% n=1 -- X
% n=2 -- Y
% n=3 -- Z

r = 2;
c = 4;

aps = pull_guiparams(hObject, eventdata, handles); 

beatsig = handles.beatsig_vcg;
medianvcg = handles.median_vcg;
medianbeat = handles.medianbeat;
lead = [{'X'} {'Y'} {'Z'}];

beats = handles.beats;
vcg = handles.vcg;

% assign current listbox beats to prior fiducial points Q, QRS, S, Tend
Q = beats.Q;
R = beats.QRS;
S =  beats.S;
Tend = beats.Tend;

sample_time = 1000/vcg.hz;

N = length(R);

for i=1:N

    if isnan(Tend(i))   
        sai_x(i) = nan;
        sai_y(i) = nan;
        sai_z(i) = nan;
        sai_vm(i) = nan;
    else
        [sai_x(i), sai_y(i), sai_z(i), sai_vm(i)] = saiqrst(vcg.X(Q(i):Tend(i)), vcg.Y(Q(i):Tend(i)), vcg.Z(Q(i):Tend(i)), vcg.VM(Q(i):Tend(i)), sample_time, aps.baseline_flag);
    end
end


for i=1:N

    if isnan(Tend(i))   
        svg_x(i) = nan;
        svg_y(i) = nan;
        svg_z(i) = nan;
    else
        svg_x(i) = sample_time*(trapz(vcg.X(Q(i):Tend(i))));
        svg_y(i) = sample_time*(trapz(vcg.Y(Q(i):Tend(i))));
        svg_z(i) = sample_time*(trapz(vcg.Z(Q(i):Tend(i))));
    end
end



switch n
    case 1
        lead_str = 'X';
        svg = svg_x;
        sai = sai_x;
    case 2
        lead_str = 'Y'; 
        svg = svg_y;
        sai = sai_y;
    case 3
        lead_str = 'Z';
        svg = svg_z;
        sai = sai_z;
end

% GRAPH

    
figure('name',sprintf('Lead %s Data',lead_str),'numbertitle','off');
sgtitle(sprintf('Lead %s Data',lead_str),'fontsize',14,'fontweight','bold');

subplot(r,c,1) 
p1 = plot(svg, 'color','r','linewidth',2,'displayname',strcat('SVG',lower(lead_str)));
hold on
p2 = line([1 length(svg)],[median(svg) median(svg)], 'color', 'r','linewidth',2,'linestyle','--','displayname',strcat('Median SVG',lower(lead_str)));
p3 = line([1 length(svg)],[prctile(svg,25) prctile(svg,25)], 'color', 'r','linewidth',1,'linestyle',':','displayname','25th-75th %-ile');
p4 = line([1 length(svg)],[prctile(svg,75) prctile(svg,75)], 'color', 'r','linewidth',1,'linestyle',':');
legend([p1 p2 p3])
ylabel('SVG (mV*ms)','FontWeight','bold','FontSize',12)
title(strcat('SVG for Each Beat in Lead','{ }', lead_str))
legend('show','location','bestoutside')
xlim([1 length(svg)])
xticks(1:1:N)
hold off


subplot(r,c,2) 
p1 = plot(sai, 'color','b','linewidth',2,'displayname',strcat('SAI',lower(lead_str)));
hold on
p2 = line([1 length(sai)],[median(sai) median(sai)], 'color', 'b','linewidth',2,'linestyle','--','displayname',strcat('Median SAI',lower(lead_str)));
p3 = line([1 length(sai)],[prctile(sai,25) prctile(sai,25)], 'color', 'b','linewidth',1,'linestyle',':','displayname','25th-75th %-ile');
p4 = line([1 length(sai)],[prctile(sai,75) prctile(sai,75)], 'color', 'b','linewidth',1,'linestyle',':');
legend([p1 p2 p3])
ylabel('SAI (mV*ms)','FontWeight','bold','FontSize',12)
title(strcat('SAI for Each Beat in Lead','{ }', lead_str))
legend('show','location','bestoutside')
xlim([1 length(sai)])
xticks(1:1:N)
hold off

qrs_dur = handles.sample_time * (S - Q);

subplot(r,c,5) 
p1 = plot(qrs_dur, 'color','k','linewidth',2,'displayname','QRS Duration' );
hold on
p2 = line([1 length(qrs_dur)],[median(qrs_dur) median(qrs_dur)], 'color', 'k','linewidth',2,'linestyle','--','displayname','Median QRS Dur');
p3 = line([1 length(qrs_dur)],[prctile(qrs_dur,25) prctile(qrs_dur,25)], 'color', 'k','linewidth',1,'linestyle',':','displayname','25th-75th %-ile');
p4 = line([1 length(qrs_dur)],[prctile(qrs_dur,75) prctile(qrs_dur,75)], 'color', 'k','linewidth',1,'linestyle',':');
legend([p1 p2 p3])
ylabel('QRS Duration (ms)','FontWeight','bold','FontSize',12)
title('QRS Duration for Each Beat')
legend('show','location','bestoutside')
xlim([1 length(qrs_dur)])
xticks(1:1:N)
hold off

qt_dur = handles.sample_time * (Tend - Q);

subplot(r,c,6) 
p1 = plot(qt_dur, 'color','m','linewidth',2,'displayname','QT Interval' );
hold on
p2 = line([1 length(qt_dur)],[median(qt_dur) median(qt_dur)], 'color', 'm','linewidth',2,'linestyle','--','displayname','Median QT Interval');
p3 = line([1 length(qt_dur)],[prctile(qt_dur,25) prctile(qt_dur,25)], 'color', 'm','linewidth',1,'linestyle',':','displayname','25th-75th %-ile');
p4 = line([1 length(qt_dur)],[prctile(qt_dur,75) prctile(qt_dur,75)], 'color', 'm','linewidth',1,'linestyle',':');
legend([p1 p2 p3])
xlabel('Beat #','FontWeight','bold','FontSize',12)
ylabel('QT Interval (ms)','FontWeight','bold','FontSize',12)
title('QT Interval for Each Beat')
legend('show','location','bestoutside')
xlim([1 length(qt_dur)])
xticks(1:1:N)
hold off


subplot(r,c,[3 4 7 8]) 
hold on
p1 = plot(medianvcg.(lead{n}),'linewidth',3,'color','[0 0.8 0]','displayname',sprintf('Median Beat Lead %s',string(lead{n})));

p2 = plot(beatsig.(lead{n})(1,:),'linestyle',':','color','k','displayname','Individual Beats');
for j = 2:size(beatsig.(lead{n}),1)
    plot(beatsig.(lead{n})(j,:),'linestyle',':','color','k');
end

pz = line([0 length(medianvcg.(lead{n}))],[0 0],'linestyle','-','color','k','displayname','Zero Voltge');

yL = ylim;
pq = line([medianbeat.Q medianbeat.Q],[yL(1) yL(2)],'linestyle','--','color','k','displayname','QRS on','linewidth',2);
ps = line([medianbeat.S medianbeat.S],[yL(1) yL(2)],'linestyle','--','color','b','displayname','QRS off','linewidth',2);
pt = line([medianbeat.Tend medianbeat.Tend],[yL(1) yL(2)],'linestyle','--','color','r','displayname','Toff','linewidth',2);

text(medianbeat.S+5, min(medianvcg.(lead{n})),sprintf('Cross Correlation = %0.3f',round(handles.correlation_test.(lead{n}),3)),'FontWeight','bold','FontSize',12);

xlim([0 length(medianvcg.(lead{n}))])
legend([p1 p2 pz pq ps pt],'location','northeast')

xlabel('Samples','FontWeight','bold','FontSize',12);
ylabel('mV','FontWeight','bold','FontSize',12)
title(sprintf('Median Beat Lead %s',string(lead{n})));

set(gcf, 'Position', [0, 0, 1600, 700])  % set figure size


% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

if ismac && currentVersion < 2025
    fontsize(gcf,scale=1.25)
end

    
end


