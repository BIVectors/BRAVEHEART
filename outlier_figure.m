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

% Store all intervals in a matrix
intervals = [QR_int'; RS_int'; JT_int'; RT_int'; QT_int'; area];

% Get outlier_matrix and modz_matrix    
[outlier_matrix, modz_matrix, ~] = find_outliers([Q QRS S Tend],vcg.VM, vcg.hz, cutpt);

num_beats = beats.length();  % number of beats in bar graph

y_text_loc = zeros(1,num_beats)+0.3;

% To switch easily between intervals and mod Z scores we will combine
% intervals and mod Z scores into a single matrix and use the 3d dimension
% to switch between numberic values
dataMat(:,:,1) = intervals;
dataMat(:,:,2) = modz_matrix;

% Start with intervals
currentData = 1;


fig = figure('name','Outlier Beat Analysis','numbertitle','off','visible','off','SizeChangedFcn',{@move_button});
sgtitle(sprintf('Beat & Intervals (in Samples) for VM Lead with Mod Z-Score Cutpoint = %2.1f', cutpt), 'fontweight','bold','fontsize',12)

% Pass between figures as toggle intervals vs mod Z scores
setappdata(fig,'currentData',currentData);

% outlier_matrix defines positive or negative for both visualizations
% The only thing that changes is the text labels
ax1 = subplot(6,1,1);
bar(outlier_matrix(1,:),'r');
title("QR Interval Outliers (**)");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(1,i) == 0     
textLabel(1,i) = text(i,0.3,num2str(dataMat(1,i,currentData)),'vert','bottom','horiz','center'); 
else
textLabel(1,i) = text(i,0.3,num2str(dataMat(1,i,currentData)),'vert','bottom','horiz','center','FontWeight','bold'); 
end
end


ax4 = subplot(6,1,2);
bar(outlier_matrix(4,:),'r');
title("RT Interval Outliers (**)");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(4,i) == 0     
textLabel(4,i) = text(i,0.3,num2str(dataMat(4,i,currentData)),'vert','bottom','horiz','center'); 
else
textLabel(4,i) = text(i,0.3,num2str(dataMat(4,i,currentData)),'vert','bottom','horiz','center','FontWeight','bold'); 
end
end


ax2 = subplot(6,1,3);
bar(outlier_matrix(2,:),'k');
title("RS Interval Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(2,i) == 0     
textLabel(2,i) = text(i,0.3,num2str(dataMat(2,i,currentData)),'vert','bottom','horiz','center'); 
else
textLabel(2,i) = text(i,0.3,num2str(dataMat(2,i,currentData)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end


ax3 = subplot(6,1,4);
bar(outlier_matrix(3,:),'k');
title("JT Interval Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(3,i) == 0   
textLabel(3,i) = text(i,0.3,num2str(dataMat(3,i,currentData)),'vert','bottom','horiz','center'); 
else
textLabel(3,i) = text(i,0.3,num2str(dataMat(3,i,currentData)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end


ax5 = subplot(6,1,5);
bar(outlier_matrix(5,:),'k');
title("QT Interval Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(5,i) == 0   
textLabel(5,i) = text(i,0.3,num2str(dataMat(5,i,currentData)),'vert','bottom','horiz','center'); 
else
textLabel(5,i) = text(i,0.3,num2str(dataMat(5,i,currentData)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end


ax6 = subplot(6,1,6); 
bar(outlier_matrix(6,:),'k');
title("Area Outliers");
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 size(outlier_matrix,2)+1])
xticks(1:1:size(outlier_matrix,2))

for i=1:num_beats
if outlier_matrix(6,i) == 0   
textLabel(6,i) = text(i,0.3,num2str(dataMat(6,i,currentData)),'vert','bottom','horiz','center'); 
else
textLabel(6,i) = text(i,0.3,num2str(dataMat(6,i,currentData)),'vert','bottom','horiz','center','FontWeight','bold','Color','w'); 
end
end

xlabel('Beat #')

set(gcf, 'Position', center_gui_figure(900, 600))  % set figure size


% Button to toggle between intervals and mod Z scores
b = uicontrol('Parent',fig,'Style','pushbutton','String','Mod Z Scores','Units','pixels', ...
     'FontWeight','bold','Position',[50 50 90 30],'Visible','on','Callback', @(src,evt) ...
      toggleOutlierData(src, dataMat, textLabel, cutpt));

set(fig, 'Visible', 'on');


% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

if ismac && currentVersion < 2025
    fontsize(gcf,scale=1.25)
end

end  % End main function


% Helper Functions

function currentData = toggleOutlierData(src, dataMat, textLabel, cutpt)

    % Pull data
    fig = ancestor(src,'figure');
    currentData = getappdata(fig,'currentData');

    % Toggles 1 <-> 2
    currentData = 3 - currentData;    
    setappdata(fig,'currentData',currentData);

    % Change text
    % fmtstr is decimal places - ends up being 0 for intervals and 1 for
    % mod Z so can easily swap based on current Data
    fmtstr = sprintf('%%2.%df', currentData - 1);

    for s = 1:size(textLabel,1)
        for i = 1:size(textLabel,2)
            textLabel(s,i).String = sprintf(fmtstr,dataMat(s,i,currentData));
        end
    end


    % Change button text
    if currentData == 1
        src.String = 'Mod Z Scores';
    else
        src.String = 'Intervals';
    end


    % Change title
    if currentData == 1
        sgtitle(sprintf('Beat & Intervals (in Samples) for VM Lead with Mod Z-Score Cutpoint = %2.1f', cutpt), 'fontweight','bold','fontsize',12);
    else
            sgtitle(sprintf('Beat & Modified Z-Scores for VM Lead with Mod Z-Score Cutpoint = %2.1f', cutpt), 'fontweight','bold','fontsize',12);
    end


end
