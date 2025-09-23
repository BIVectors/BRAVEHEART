%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% view_median12lead_ecg.m -- Part of BRAVEHEART GUI - View Median beats
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

%%% displays Median beats for printing/saving

function view_median12lead_ecg(ecg, vcg, filename, save_folder, save_flag, auto_flag, majorgrid, minorgrid, colors)

fn_ecg = fieldnames(ecg);
fn_vcg = fieldnames(vcg);

fn = [{fn_ecg{3:14}} {fn_vcg{3:6}}];

sample_time = ecg.sample_time();

% 1 mV square wave lasting 200 ms
% Number of samples in 200 ms = 200/sample_time
sq_wave_samples = 200/sample_time;

sqwave = [nan(1,100) zeros(1,round(sq_wave_samples/4)) zeros(1,round(sq_wave_samples))+1 zeros(1,round(sq_wave_samples/4)) nan(1,50)];

new_ecg(1,:) = [sqwave nan(1,50) vcg.X' nan(1,300) vcg.Y' nan(1,300) vcg.Z' nan(1,300) vcg.VM' nan(1,300)];
new_ecg(2,:) = [sqwave nan(1,50) ecg.V3' nan(1,300) ecg.V4' nan(1,300) ecg.V5' nan(1,300) ecg.V6' nan(1,300)];
new_ecg(3,:) = [sqwave nan(1,50) ecg.avL' nan(1,300) ecg.avR' nan(1,300) ecg.V1' nan(1,300) ecg.V2' nan(1,300)];
new_ecg(4,:) = [sqwave nan(1,50) ecg.I' nan(1,300) ecg.II' nan(1,300) ecg.III' nan(1,300) ecg.avF' nan(1,300)];

max_vals = zeros(1,4);
min_vals = zeros(1,4);

for i = 1:4 
    max_vals(i) = max(new_ecg(i,:));
    min_vals(i) = min(new_ecg(i,:));
    spacer(i) = abs(max(new_ecg(i,:)) - min(new_ecg(i,:)));
end

   
median12L_fig = figure('name','Median Beats','numbertitle','off','SizeChangedFcn',{@move_button},'color',colors.bgcolor);

% Save button
save_filename = fullfile(save_folder,strcat(filename(1:end-4),'_median_beats.png'));
savebutton = uicontrol('Parent',median12L_fig,'Style','pushbutton','String','Save .png','Units','pixels', ...
    'BackgroundColor',colors.buttoncolor, 'FontWeight','bold', 'fontsize',8, 'ForegroundColor',colors.txtcolor, ...
    'Position',[1100 400 80 30],'Visible','on','Callback',{@save_fig_from_button, save_filename});

set(gcf, 'Position', [30, 50, 1000, 500])  % set figure size
set(median12L_fig,'PaperSize',[8.5 11]); %set the paper size to what you want  
hold on

xlim([0 ceil(length(new_ecg(1,:)))]);

%%% X grid

    % thick solid line every 200 ms
    % distance for large boxes in X axis is 200/(1/freq) = 200/sample_time
    x_large_grid = 200/sample_time;

    % dotted line every 40 ms
    % distance for small boxes in X axis is 40/(1/freq) = 40/sample_time
    x_small_grid = 40/sample_time;

    % find number of large/small boxes that occupy the ECG based on length
    % length = 10 sec for standard ECGs but variable for other Prucka
    % tracings:
    total_x_large_grid = ceil(length(new_ecg(1,:))/x_large_grid);
    total_x_small_grid = ceil(length(new_ecg(1,:))/x_small_grid);
       
%%% Y grid
      
    % thick solid line every 0.5 mV
    % thin solid line every 0.1 mV

    y_large_grid = 0.5;
    y_small_grid = 0.1;
        
% y grid goes from 0 to 24
    yceil = sum(spacer)+ 0.6;

%%% Show minor X markings evetn 200 ms
    if minorgrid
    for i=1:total_x_small_grid+1
        line( [(i-1)*x_small_grid (i-1)*x_small_grid], [0 yceil], 'Color','[0.9373 0.6667 0.6667]','linewidth',0.8);
    end
    end
               
%%% Show major X markings evetn 200 ms
    if majorgrid
    for i=1:total_x_large_grid+1
        line( [(i-1)*x_large_grid (i-1)*x_large_grid], [0 yceil], 'Color','[0.9020 0.3922 0.3922]','linewidth',0.8);
    end
    end

%%% show minor Y markings every 0.1 mV (scaled)    
    if minorgrid
    for i=1:(10*yceil)
        line([0 length(new_ecg(1,:))], [(i-1)*y_small_grid (i-1)*y_small_grid], 'Color','[0.9373 0.6667 0.6667]','linewidth',0.8);
    end
    end
    
%%% show major Y markings every 0.5 mV (scaled)
    if majorgrid
    for i=1:(2*yceil)
        line([0 length(new_ecg(1,:))], [(i-1)*y_large_grid (i-1)*y_large_grid], 'Color','[0.9020 0.3922 0.3922]','linewidth',0.8);
    end
    end
    

%%% Plot median beat figure

daspect([200/sample_time 0.5 1])
axis off


for i = 1:4
switch i
    case 1
        sig = new_ecg(i,:);
        plot(sig + (abs(min(new_ecg(i,:)))) + 0.1, 'linewidth',1.0,'color','k')
        text(275, (abs(min(new_ecg(i,:)))) + 1.1, fn{17-(4*i)});
        text(350 + length(ecg.I) + 225, (abs(min(new_ecg(i,:)))) + 1.1, fn{18-(4*i)});
        text(350 + 2*(length(ecg.I) + 225)+75, (abs(min(new_ecg(i,:)))) + 1.1, fn{19-(4*i)});
        text(350 + 3*(length(ecg.I) + 225)+150, (abs(min(new_ecg(i,:)))) + 1.1, fn{20-(4*i)});

    case 2
        sig = new_ecg(i,:);
        plot(sig + spacer(1) + (abs(min(new_ecg(i,:)))) + 0.1, 'linewidth',1.0,'color','k')
        text(275, spacer(1) + (abs(min(new_ecg(i,:)))) + 1.1, fn{17-(4*i)});
        text(350 + length(ecg.I) + 225, spacer(1) + (abs(min(new_ecg(i,:)))) + 1.1, fn{18-(4*i)});
        text(350 + 2*(length(ecg.I) + 225)+75, spacer(1) + (abs(min(new_ecg(i,:)))) + 1.1, fn{19-(4*i)});
        text(350 + 3*(length(ecg.I) + 225)+150, spacer(1) + (abs(min(new_ecg(i,:)))) + 1.1, fn{20-(4*i)});

    case 3
        sig = new_ecg(i,:);
        plot(sig + spacer(1) + spacer(2) + (abs(min(new_ecg(i,:)))) + 0.1, 'linewidth',1.0,'color','k')
        text(275, spacer(1) + spacer(2) + (abs(min(new_ecg(i,:)))) + 1.1, fn{17-(4*i)});
        text(350 + length(ecg.I) + 225, spacer(1) + spacer(2) + (abs(min(new_ecg(i,:)))) + 1.1, fn{18-(4*i)});
        text(350 + 2*(length(ecg.I) + 225)+75, spacer(1) + spacer(2) + (abs(min(new_ecg(i,:)))) + 1.1, fn{19-(4*i)});
        text(350 + 3*(length(ecg.I) + 225)+150, spacer(1) + spacer(2) + (abs(min(new_ecg(i,:)))) + 1.1, fn{20-(4*i)});

    case 4
        sig = new_ecg(i,:);
        plot(sig + spacer(1) + spacer(2) + spacer(3)+ (abs(min(new_ecg(i,:)))) + 0.1, 'linewidth',1.0,'color','k')
        text(275, spacer(1) + spacer(2) + spacer(3)+ (abs(min(new_ecg(i,:)))) + 1.1, fn{17-(4*i)});
        text(350 + length(ecg.I) + 225, spacer(1) + spacer(2) + spacer(3)+ (abs(min(new_ecg(i,:)))) + 1.1, fn{18-(4*i)});
        text(350 + 2*(length(ecg.I) + 225)+75, spacer(1) + spacer(2) + spacer(3)+ (abs(min(new_ecg(i,:)))) + 1.1, fn{19-(4*i)});
        text(350 + 3*(length(ecg.I) + 225)+150, spacer(1) + spacer(2) + spacer(3)+ (abs(min(new_ecg(i,:)))) + 1.1, fn{20-(4*i)});
    end
end

% Add white background overplot area
rectangle('Position',[0 0 (total_x_large_grid*x_large_grid) yceil], 'facecolor',[1 1 1], 'edgecolor','none');

% Put rectangle behind all the plots
% Rectangle will be child 1 because its the last thing added
C = gca().Children;
% Shift rectangle to end
C = circshift(C,-1,1);
set(gca, 'Children',C);

    
xlim([-400 length(new_ecg(1,:)) ])
ylim([0 yceil])
title(strcat(filename(1:end-4)," - Median Beats"),'FontWeight','bold','FontSize',14, 'Interpreter', 'none', 'color', colors.txtcolor)

hold off

h=gcf;
h.PaperPositionMode = 'manual';
orient(h,'landscape')

InSet = get(gca, 'TightInset');
InSet(4) = InSet(4)+0.015;
InSet(3) = InSet(3)+0.015;
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);
set(gcf, 'InvertHardCopy', 'off');

% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

if ismac && currentVersion < 2025
    fontsize(gcf,scale=1.25)
    savebutton.FontSize = 10;
end

% Save 12-lead as .png if save checkbox selected
    if save_flag == 1
        filename_short = strcat(filename(1:end-4),'_median_beats.png');
        full_filename = fullfile(save_folder,filename_short);

        print(gcf,'-dpng',[full_filename],'-r600');

    else
    end
    
    
 % Auto close if auto save figure
if auto_flag == 1
    close(median12L_fig)
end