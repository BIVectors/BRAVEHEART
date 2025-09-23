%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% view_12lead_ecg.m -- Part of BRAVEHEART GUI - View 12L ECG
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

%%% displays 12-lead ECG for printing/saving

function view_12lead_ecg(ecg, filename, save_folder, save_flag, auto_flag, majorgrid, minorgrid, colors)

fn_ecg = fieldnames(ecg);

% Reorder avR, avL, avF to be more consistent with clinical ECGs displays
fn_ecg{6} = 'avR';
fn_ecg{7} = 'avL';
fn_ecg{8} = 'avF';

sample_time = ecg.sample_time();

% 1 mV square wave lasting 200 ms
% Number of samples in 200 ms = 200/sample_time
sq_wave_samples = 200/sample_time;

sqwave = [nan(1,100) zeros(1,round(sq_wave_samples/4)) zeros(1,round(sq_wave_samples))+1 zeros(1,round(sq_wave_samples/4)) nan(1,50)];

% need to link sqwave with sample 1 of each lead
ecg_sqwave = zeros(12,length(ecg.I)+length(sqwave));
max_vals = zeros(1,12);
min_vals = zeros(1,12);
diff_vals = zeros(1,12);

for i = 1:12
    if iscolumn(ecg.(fn_ecg{i+2}))
        ecg_sqwave(i,:) = [sqwave+ecg.(fn_ecg{i+2})(1) ecg.(fn_ecg{i+2})'];
    else
        ecg_sqwave(i,:) = [sqwave+ecg.(fn_ecg{i+2})(1) ecg.(fn_ecg{i+2})];
    end
    
    max_vals(i) = max(ecg.(fn_ecg{i+2}));
    min_vals(i) = min(ecg.(fn_ecg{i+2}));

end

    diff_vals = (ceil(max_vals - min_vals));
   
lead12_fig = figure('name','12-Lead ECG','numbertitle','off','SizeChangedFcn',{@move_button},'color',colors.bgcolor);

% Save button
save_filename = fullfile(save_folder,strcat(filename(1:end-4),'_12lead_ecg.png'));
savebutton = uicontrol('Parent',lead12_fig,'Style','pushbutton','String','Save .png','Units','pixels', ...
    'BackgroundColor',colors.buttoncolor, 'FontWeight','bold', 'fontsize',8, 'ForegroundColor',colors.txtcolor, ...
    'Position',[1100 900 80 30],'Visible','on','Callback',{@save_fig_from_button, save_filename});


set(gcf, 'Position', [0, 0, 1150, 1050])  % set figure size
set(lead12_fig,'PaperSize',[8.5 11]); %set the paper size to what you want  
hold on

xlim([0 ceil(length(ecg_sqwave(1,:)))]);

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
        total_x_large_grid = ceil(length(ecg_sqwave(1,:))/x_large_grid);
        total_x_small_grid = ceil(length(ecg_sqwave(1,:))/x_small_grid);
       
%%% Y grid
      
    % thick solid line every 0.5 mV
    % thin solid line every 0.1 mV

    y_large_grid = 0.5;
    y_small_grid = 0.1;
        
% y grid goes from 0 to 24
    yceil = 24;

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
        line([0 length(ecg_sqwave(1,:))], [(i-1)*y_small_grid (i-1)*y_small_grid], 'Color','[0.9373 0.6667 0.6667]','linewidth',0.8);
    end
    end
    
%%% show major Y markings every 0.5 mV (scaled)
    if majorgrid
    for i=1:(2*yceil)
        line([0 length(ecg_sqwave(1,:))], [(i-1)*y_large_grid (i-1)*y_large_grid], 'Color','[0.9020 0.3922 0.3922]','linewidth',0.8);
    end
    end
    

%%% Plot 12-lead figure

daspect([200/sample_time 0.5 1])
axis off

for i = 1:12
    sig = ecg_sqwave(13-i,:);
    plot(sig+(2*(i-1))- min(ecg_sqwave(12,:)-0.2),'linewidth',1.0,'color','k')
    text(-250,sig(101)+0.5+(2*(i-1))- min(ecg_sqwave(12,:)-0.2),fn_ecg{15-i}, 'Color', colors.txtcolor);
end

% Add white background overplot area
rectangle('Position',[0 0 (total_x_large_grid*x_large_grid) yceil], 'facecolor',[1 1 1], 'edgecolor','none');

% Put rectangle behind all the plots
% Rectangle will be child 1 because its the last thing added
C = gca().Children;
% Shift rectangle to end
C = circshift(C,-1,1);
set(gca, 'Children',C);

    
xlim([-400 length(ecg_sqwave(1,:)) ])
ylim([0 yceil])
title(filename(1:end-4),'FontWeight','bold','FontSize',14, 'Interpreter', 'none', 'color', colors.txtcolor)

hold off

h=gcf;
h.PaperPositionMode = 'manual';
orient(h,'landscape')
set(gcf, 'InvertHardCopy', 'off');

InSet = get(gca, 'TightInset');
InSet(4) = InSet(4)+0.028;
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

    if ismac && currentVersion < 2025
        fontsize(gca,scale=1.25)
        savebutton.FontSize = 10;
    end


% Save figure as .png if save checkbox selected
    if save_flag == 1
    filename_short = strcat(filename(1:end-4),'_12lead_ecg.png');
    full_filename = fullfile(save_folder,filename_short);
       
    print(gcf,'-dpng',[full_filename],'-r600');

    else
    end
     
% Auto close if auto save figure
if auto_flag == 1
    close(lead12_fig)
end