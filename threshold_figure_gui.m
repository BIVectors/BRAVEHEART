%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% threshold_figure_gui.m -- Part of BRAVEHEART GUI - Figure for showing R peak detection
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


function threshold_figure_gui(vm, th, maxbpm, freq)

up = vm;
down = vm;

q = quantile(abs(vm), 100);

up(up<q(th)) = NaN;

figure('name','Initial R Peak Detection','numbertitle','off');
set(gcf, 'Position', [100, 800, 1600, 300])  % set figure size
plot(vm,'linewidth',1','color','black');
hold on
p_green = plot(up,'linewidth',2','color','green');
p_line = line([0 length(vm)],[q(th) q(th)],'linestyle','--','color','blue');
xlim([0 length(vm)]);

color = [{'red'} {'blue'}];
color = repmat(color,1,40);

d = round(freq*60/maxbpm);

[pks, locs] = findpeaks((vm),'MinPeakHeight', q(th), 'MinPeakDistance', d);
% 
% P =zeros(1,100);
% vm_trim = vm(501:4500); 
% for i = 1:100
%    [~, QRS] = findpeaks((vm_trim),'MinPeakHeight', q(i), 'MinPeakDistance', d);
%    P(i) =  length(QRS);
% end
% 
% pcut = 50;
% P(1:pcut) = [];

YL = ylim;

for i = 1:length(locs)
    A = [locs(i)-d locs(i)+d];
    area(A,[YL(2) YL(2)],'facecolor',char(color(i)),'edgecolor','none','facealpha',0.15);
    scatter(locs(i),vm(locs(i)),'filled',char(color(i)));

end

% Empty plots for legend
p_dot_blue = scatter(nan,nan,'filled','blue');
p_area_blue = area(A,[nan nan],'facecolor','blue','edgecolor','none','facealpha',0.15);
p_dot_red = scatter(nan,nan,'filled','red');
p_area_red = area(A,[nan nan],'facecolor','red','edgecolor','none','facealpha',0.15);
p_area_overlap = area(A,[nan nan],'facecolor','[0.8510, 0.7255, 0.8745]','edgecolor','none','facealpha',1);

%est_thresh = max(find(P==max(P(P==mode(P)))));
%title(sprintf('Initial R Peak Detection (Threshold %d%%, %d bpm) - Estimated Optimal Threshold = %d%%',th, maxbpm,est_thresh+pcut),'fontweight','bold','fontsize',14);
title(sprintf('Initial R Peak Detection (Threshold %d%%, %d bpm)',th, maxbpm),'fontweight','bold','fontsize',14);


p_green_txt = sprintf('VM Signal > %d %%ile', th);
p_line_txt = sprintf('%d %%ile', th);
legend([p_green p_line p_dot_red p_area_red p_dot_blue p_area_blue, p_area_overlap], ...
    {p_green_txt, p_line_txt,'Odd R Peak','Window Around Odd R Peaks','Even R Peak','Window Around Even R Peaks', 'Window Overlap'}, ...
    'location','eastoutside','fontsize',12);


% Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end


end