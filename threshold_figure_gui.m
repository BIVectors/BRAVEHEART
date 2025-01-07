%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% threshold_figure_gui.m -- Part of BRAVEHEART GUI - Figure for showing R peak detection
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


function threshold_figure_gui(vcg, aps)

% Pass in VCG object (vcg) and Annoparams object (aps)
vm = vcg.VM;
th = aps.pkthresh;
maxbpm = aps.maxBPM;
freq = vcg.hz;

% Detect peaks in VM signal without filtering
aps.pkfilter = 0;
QRS = vcg.peaks(aps);

if aps.spike_removal
    [vcg_noppm, ~] = vcg.remove_pacer_spikes(QRS, aps);
    locs = vcg_noppm.peaks(aps);
else
    locs = vcg.peaks(aps);
end  

% Detect peaks in VM signal with filtering
aps.pkfilter = 1;
QRS_filt = vcg.peaks(aps);

if aps.spike_removal
    [vcg_noppm_filt, ~] = vcg.remove_pacer_spikes(QRS_filt, aps);
    locs_filt = vcg_noppm_filt.peaks(aps);
else
    locs_filt = vcg.peaks(aps);
    vcg_noppm_filt = vcg;
end  

% Plot original VM signal data

up = vm;

q = quantile(abs(vm), 100);

up(up<q(th)) = NaN;

figure('name','Initial R Peak Detection','numbertitle','off');
set(gcf, 'Position', [100, 800, 1600, 300])  % set figure size
plot(vm,'linewidth',1','color','black');
hold on
p_green = plot(up,'linewidth',1.5','color','green');
p_line = line([0 length(vm)],[q(th) q(th)],'linestyle','--','color','blue');
xlim([0 length(vm)]);

color = [{'red'} {'blue'}];
color = repmat(color,1,100);

d = round(freq*60/maxbpm);

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

title(sprintf('Initial R Peak Detection (Threshold %d%%, %d bpm)',th, maxbpm),'fontweight','bold','fontsize',14);


p_green_txt = sprintf('VM Signal > %d %%ile', th);
p_line_txt = sprintf('%d %%ile', th);
legend([p_green p_line p_dot_red p_area_red p_dot_blue p_area_blue p_area_overlap], ...
    {p_green_txt, p_line_txt,'Odd R Peak','Window Around Odd R Peaks','Even R Peak','Window Around Even R Peaks', 'Window Overlap'}, ...
    'location','eastoutside','fontsize',12);

% Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end
hold off



% Figure using filtered QRST complex
%vm = vcg_noppm.VM;
[~, QRS_filt_raw, vm_filt] = findpeakswavelet(vcg_noppm_filt.VM, maxbpm, freq, th, 'sym4');

% Normalize to voltage of VM unfiltered signal
N = max(vm)/max(vm_filt);
vm_filt = vm_filt * N;

q_filt = quantile(abs(vm_filt), 100);

up_filt = vm_filt;
up_filt(up_filt<q_filt(th)) = NaN;

figure('name','Initial Filtered R Peak Detection','numbertitle','off');
set(gcf, 'Position', [100, 400, 1600, 300])  % set figure size
p_vm_filt = plot(vm_filt,'linewidth',1','color','black');
hold on
p_green_filt = plot(up_filt,'linewidth',1.5','color','green');
p_line_filt = line([0 length(vm_filt)],[q_filt(th) q_filt(th)],'linestyle','--','color','blue');
xlim([0 length(vm_filt)]);

% Plot original signal in grey
ecg_grey = plot(vm,'linewidth',0.5','color','[0.7 0.7 0.7]','linestyle','-');

title(sprintf('Initial Filtered R Peak Detection (Threshold %d%%, %d bpm)',th, maxbpm),'fontweight','bold','fontsize',14);


for i = 1:length(locs_filt)
    A = [locs_filt(i)-d locs_filt(i)+d];
    area(A,[YL(2) YL(2)],'facecolor',char(color(i)),'edgecolor','none','facealpha',0.15);
    scatter(locs_filt(i),vm(locs_filt(i)),'filled',char(color(i)));

end

for i = 1:length(QRS_filt_raw)
    scatter(QRS_filt_raw(i),vm_filt(QRS_filt_raw(i)),'black');

end

p_green_txt_filt = sprintf('Filtered VM Signal > %d %%ile', th);
p_dot_black = scatter(nan,nan,'black');

legend([ecg_grey p_vm_filt p_green_filt p_line_filt p_dot_black p_dot_red p_area_red p_dot_blue p_area_blue p_area_overlap], ...
    {'VM Signal', 'Filtered VM Signal', p_green_txt_filt, p_line_txt, 'Peaks of Filtered VM Signal', 'Odd R Peak','Window Around Odd R Peaks','Even R Peak','Window Around Even R Peaks', 'Window Overlap'}, ...
    'location','eastoutside','fontsize',12);


% Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end
hold off


end