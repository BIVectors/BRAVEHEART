%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% outlier_figure.m -- Part of BRAVEHEART GUI - Figure assessing outliers
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


function outlier_figure(vcg, beats, cutpt, hObject, eventdata, handles)

beatmatrix = beats.beatmatrix();

% Get numbers for intervals to put on bars
Q = beats.Q;
QRS = beats.QRS;
S = beats.S;
Tend = beats.Tend;

% Define QR, RS, JT, and QT intervals
QR_int = QRS-Q;
RS_int = S-QRS;
JT_int = Tend-S;
RT_int = Tend-QRS;
QT_int = Tend-Q;
    
[outlier_matrix, ~] = find_outliers([Q QRS S Tend],vcg.VM, vcg.hz, cutpt);

num_beats = beats.length();  % number of beats in bar graph

y_text_loc = zeros(1,num_beats)+0.3;

figure('name','Outlier Beat Analysis','numbertitle','off')
sgtitle(sprintf('Beat & Intervals (in Samples) for VM Lead with Mod Z-Score Cutpoint = %2.1f', cutpt), 'fontweight','bold','fontsize',12)


subplot(6,1,1) 
bar(outlier_matrix(1,:),'r');
title("QR Interval Outliers (**)");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(1,i) == 0     
text(i,0.3,num2str(QR_int(i)),'vert','bottom','horiz','center'); 
else
text(i,0.3,num2str(QR_int(i)),'vert','bottom','horiz','center','FontWeight','bold'); 
end
end


subplot(6,1,2) 
bar(outlier_matrix(4,:),'r');
title("RT Interval Outliers (**)");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(4,i) == 0     
text(i,0.3,num2str(RT_int(i)),'vert','bottom','horiz','center'); 
else
text(i,0.3,num2str(RT_int(i)),'vert','bottom','horiz','center','FontWeight','bold'); 
end
end


subplot(6,1,3) 
bar(outlier_matrix(2,:),'k');
title("RS Interval Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(2,i) == 0     
text(i,0.3,num2str(RS_int(i)),'vert','bottom','horiz','center'); 
else
text(i,0.3,num2str(RS_int(i)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end


subplot(6,1,4) 
bar(outlier_matrix(3,:),'k');
title("JT Interval Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(3,i) == 0   
text(i,0.3,num2str(JT_int(i)),'vert','bottom','horiz','center'); 
else
text(i,0.3,num2str(JT_int(i)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end


subplot(6,1,5) 
bar(outlier_matrix(5,:),'k');
title("QT Interval Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(5,i) == 0   
text(i,0.3,num2str(QT_int(i)),'vert','bottom','horiz','center'); 
else
text(i,0.3,num2str(QT_int(i)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end


subplot(6,1,6) 
bar(outlier_matrix(6,:),'k');
title("Area Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

area = zeros(1,length(Q));
lead = vcg.VM;
for i=1:length(Q)
   if isnan(Tend(i)) || isnan(Q(i))
       area(i) = NaN;
       continue;
   end
   lead_segment = lead(Q(i):Tend(i));
   %lead_segment = lead_segment - lead_segment(end);
   area(i) = round(trapz(lead_segment)); 
end
area=area';

for i=1:num_beats
if outlier_matrix(6,i) == 0   
text(i,0.3,num2str(area(i)),'vert','bottom','horiz','center'); 
else
text(i,0.3,num2str(area(i)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end

xlabel('Beat #')

set(gcf, 'Position', [200, 100, 900, 600])  % set figure size

% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

if ismac && currentVersion < 2025
    fontsize(gcf,scale=1.25)
end
