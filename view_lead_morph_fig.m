%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% view_lead_morph_fig.m -- Part of BRAVEHEART GUI - View Lead Morphology figure
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

function view_lead_morph_fig(median_12L, median_vcg, medianbeat, lead_morph, save, filename, save_folder, colors)

% List of lead names to help streamline code
lead = [{'L1'} {'L2'} {'L3'} {'avF'} {'avL'} {'avR'} {'V1'} {'V2'} {'V3'} {'V4'} {'V5'} {'V6'} {'X'} {'Y'} {'Z'} {'VM'}];

sig = median_12L;
fn_sig = fieldnames(sig);

vm = median_vcg;
fn_vm = fieldnames(vm);

m = lead_morph;
fn_m = fieldnames(m);


% Check if LeadMorphology class is all NaN which means something happened
% during calculations
nanlist = zeros(1,length(fn_m));

for k = 1:length(fn_m)
    nanlist(k) = isnan(lead_morph.(fn_m{k}));
end

if sum(nanlist) == length(nanlist)
    msgbox(sprintf('Error calculating Lead Morphology Class'),'Error','error');
    return;
end

% Location of end of pacing spike if detected
% This is important to avoid including large pacing spikes as the R and S
% wave amplitudes
endspike = median_vcg.endspikes;

% Median beat data
locs = medianbeat;

% Initialize vectors
tpk_vals = zeros(1,16);
tpk = zeros(1,16);
r_vals = zeros(1,16); 
s_vals = zeros(1,16);
rs_vals = zeros(1,16);


% Get the T wave locations (in samples) and T wave magnitudes
% Lead_Morphology stores T peak location as ms - need to convert back to samples for figure

% First 12 leads have different number of Lead_Morphology parameters than the 4 VCG leads

for i = 1:16
    % Find index of [lead]_t_max - this also finds [lead]_t_max_loc
    idx = find(contains(fn_m, lead{i}+"_t_max"));
    if ~isempty(idx)
        tmax_idx = idx(1);      % [lead]_t_max
        tmax_loc_idx = idx(2);  % [lead]_t_max_loc

        tpk_vals(i) = m.(fn_m{tmax_idx});
        tpk(i) = round((median_12L.hz/1000)*m.(fn_m{tmax_loc_idx}))+locs.Q; 
    else
        tpk_vals(i) = nan;
        tpk(i) = nan;
    end
end


% Get R wave and S wave values

for i = 1:16
    % Find index of [lead]_r_wave - this also finds [lead]_s_wave (index+1) and [lead]_rs_wave (index+2)
    idx = find(contains(fn_m, lead{i}+"_r_wave"));
        r_idx = idx(1);           % [lead]_r_wave
        s_idx = idx(1) + 1;       % [lead]_s_wave
        rs_idx = idx(1) + 2;      % [lead]_rs_wave

        r_vals(i) = m.(fn_m{r_idx});
        s_vals(i) = m.(fn_m{s_idx});
        rs_vals(i) = m.(fn_m{rs_idx});
end


% Now generate figure
LMFig = figure('name','Median Beat Morphology','numbertitle','off','Color',colors.bgcolor, 'SizeChangedFcn',{@move_button});

% Buttons on figure
save_filename = fullfile(save_folder,strcat(filename(1:end-4),'_lead_morph_ecg.png'));
savebutton = uicontrol('Parent',LMFig,'Style','pushbutton','String','Save .png','Units','pixels','BackgroundColor',colors.buttoncolor,...
   'FontWeight','bold', 'fontsize',8,'ForegroundColor',colors.txtcolor,'Position',[1500 960 80 30],'Visible','on','Callback',{@save_fig_from_button, save_filename});

scalebutton = uicontrol('Parent',LMFig,'Style','pushbutton','BackgroundColor',colors.buttoncolor,'ForegroundColor',colors.txtcolor,'String','Fixed Y Axes','Units','pixels','Position',[1500 920 80 30],'Visible','on', ...
    'Callback',{@LM_scale_y,median_12L, median_vcg, medianbeat, lead_morph}, ...
    'BackgroundColor',colors.buttoncolor, 'FontWeight','bold', 'fontsize',8, 'ForegroundColor',colors.txtcolor);

set(gcf, 'InvertHardCopy', 'off');

% 12L rows
for i = 1:12
subplot(4,4,i)

% Plot median beat and fiducial points
plot(sig.(fn_sig{i+2}),'linewidth',1.5,'color',colors.xyzecg)
hold on
scatter(locs.Q,sig.(fn_sig{i+2})(locs.Q),'MarkerEdgeColor',colors.txtcolor)
scatter(locs.S,sig.(fn_sig{i+2})(locs.S),'MarkerEdgeColor',colors.txtcolor)
scatter(locs.Tend,sig.(fn_sig{i+2})(locs.Tend),'MarkerEdgeColor',colors.txtcolor)

set(gca,'XColor', colors.txtcolor);
set(gca,'YColor', colors.txtcolor);

% Plot lines for R and S waves 
line([0 length(sig.(fn_sig{i+2}))],[r_vals(i) r_vals(i)],'linestyle','--','color',colors.vmecg)
line([0 length(sig.(fn_sig{i+2}))],[s_vals(i) s_vals(i)],'linestyle','--','color',colors.vmecg)
line([0 length(sig.(fn_sig{i+2}))],[0 0], 'linestyle',':', 'color',colors.txtcolor)
xlim([0 length(sig.(fn_sig{i+2})) + 125])
scale = abs(max((max([r_vals(i) tpk_vals(i)])))) + abs(min(min([s_vals(i) tpk_vals(i)])));

if sum(isnan(sig.(fn_sig{i+2}))) ~= length(sig.(fn_sig{i+2}))  % If signal NOT missing and therefore NOT all Nan
    ylim([min(min([s_vals(i) tpk_vals(i)]))-0.2*scale max(max([r_vals(i) tpk_vals(i)]))+0.2*scale]);
else
    ylim([-1 1]);   % If signal is all Nan, have to make some interval for ylim to avoid error
end

% Plot RS vertical line
line([length(sig.(fn_sig{i+2}))+5 length(sig.(fn_sig{i+2}))+5],[s_vals(i) r_vals(i)],'color',colors.txtcolor)

% Text
text(length(sig.(fn_sig{i+2}))+10, 0.5*(r_vals(i)+s_vals(i)), strcat("\Delta = ", num2str(round(rs_vals(i),2))),'fontsize',9,'color', colors.txtcolor)
text(length(sig.(fn_sig{i+2}))+10, r_vals(i), strcat("R = ", num2str(round(r_vals(i),2))),'fontsize',9,'color', colors.txtcolor)
text(length(sig.(fn_sig{i+2}))+10, s_vals(i), strcat("S = ", num2str(round(s_vals(i),2))),'fontsize',9,'color', colors.txtcolor)

% Labels
title(fn_sig{i+2}, 'Color',colors.txtcolor)
ylabel("mV", 'Color',colors.txtcolor)

% T Wave
scatter(tpk(i),tpk_vals(i),'MarkerEdgeColor',colors.vmecg)
line([tpk(i) tpk(i)],[0 tpk_vals(i)],'color', colors.txtcolor)

if tpk_vals(i) > 0 && ~isnan(tpk_vals(i))
    text(tpk(i)-30, tpk_vals(i) + 0.1*rs_vals(i), strcat("T = ", num2str(round(tpk_vals(i),2))),'color', colors.txtcolor)
elseif tpk_vals(i) < 0 && ~isnan(tpk_vals(i))
    text(tpk(i)-30, tpk_vals(i) -  0.1*abs(rs_vals(i)), strcat("T = ", num2str(round(tpk_vals(i),2))),'color', colors.txtcolor)
else
end

set(gca,'Color', colors.bgfigcolor);

end


% VCG row
for i = 1:4
subplot(4,4,i+12)

% Plot median beat and fiducial points
plot(vm.(fn_vm{i+2}),'linewidth',1.5,'color',colors.xyzecg)
hold on
scatter(locs.Q,vm.(fn_vm{i+2})(locs.Q),'MarkerEdgeColor',colors.txtcolor)
scatter(locs.S,vm.(fn_vm{i+2})(locs.S),'MarkerEdgeColor',colors.txtcolor)
scatter(locs.Tend,vm.(fn_vm{i+2})(locs.Tend),'MarkerEdgeColor',colors.txtcolor)

set(gca,'XColor', colors.txtcolor);
set(gca,'YColor', colors.txtcolor);

% Plot lines for R and S waves 
line([0 length(vm.(fn_vm{i+2}))],[r_vals(i+12) r_vals(i+12)],'linestyle','--','color',colors.vmecg)
line([0 length(vm.(fn_vm{i+2}))],[s_vals(i+12) s_vals(i+12)],'linestyle','--','color',colors.vmecg)
line([0 length(vm.(fn_vm{i+2}))],[0 0], 'linestyle',':', 'color',colors.txtcolor)
xlim([0 length(vm.(fn_vm{i+2})) + 125])
scale = abs(max((max([r_vals(i+12) tpk_vals(i+12)])))) + abs(min(min([s_vals(i+12) tpk_vals(i+12)])));


if sum(isnan(vm.(fn_vm{i+2}))) ~= length(vm.(fn_vm{i+2}))  % If vmnal NOT missing and therefore NOT all Nan
     ylim([min(min([s_vals(i+12) tpk_vals(i+12)]))-0.2*scale max(max([r_vals(i+12) tpk_vals(i+12)]))+0.2*scale]);
else
    ylim([-1 1]);   % If vmnal is all Nan, have to make some interval for ylim to avoid error
end

% Plot RS vertical line
line([length(vm.(fn_vm{i+2}))+5 length(vm.(fn_vm{i+2}))+5],[s_vals(i+12) r_vals(i+12)],'color',colors.txtcolor)

% Text
text(length(vm.(fn_vm{i+2}))+10, 0.5*(r_vals(i+12)+s_vals(i+12)), strcat("\Delta = ", num2str(round(rs_vals(i+12),2))),'fontsize',9,'color', colors.txtcolor)
text(length(vm.(fn_vm{i+2}))+10, r_vals(i+12), strcat("R = ", num2str(round(r_vals(i+12),2))),'fontsize',9,'color', colors.txtcolor)
text(length(vm.(fn_vm{i+2}))+10, s_vals(i+12), strcat("S = ", num2str(round(s_vals(i+12),2))),'fontsize',9,'color', colors.txtcolor)

% Labels
title(fn_vm{i+2},'Color',colors.txtcolor);
ylabel("mV",'Color',colors.txtcolor);

% T Wave
scatter(tpk(i+12),tpk_vals(i+12),'MarkerEdgeColor',colors.vmecg)
line([tpk(i+12) tpk(i+12)],[0 tpk_vals(i+12)],'color',colors.txtcolor)

if tpk_vals(i+12) > 0 && ~isnan(tpk_vals(i+12))
    text(tpk(i+12)-30, tpk_vals(i+12) + 0.1*rs_vals(i+12), strcat("T = ", num2str(round(tpk_vals(i+12),2))),'color', colors.txtcolor)
elseif tpk_vals(i+12) < 0 && ~isnan(tpk_vals(i+12))
    text(tpk(i+12)-30, tpk_vals(i+12) -  0.1*abs(rs_vals(i+12)), strcat("T = ", num2str(round(tpk_vals(i+12),2))),'color', colors.txtcolor)
else
end

set(gca,'Color', colors.bgfigcolor);

end


sgtitle(strcat("Median Beat Morphology - ", filename(1:end-4)),'interpreter','none','fontweight', 'bold','Color',colors.txtcolor)
set(gcf, 'Position', [0,0, 1600, 1000])  % set figure size


% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

if ismac && currentVersion < 2025
    fontsize(gcf,scale=1.25)
end

if save == 1
    filename_short = strcat(filename(1:end-4),'_lead_morph_ecg.png');
    full_filename = fullfile(save_folder,filename_short);
    print(gcf,'-dpng',[full_filename],'-r600');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All leads at once
max_val = max(max([sig.I sig.II sig.III sig.avR sig.avL sig.avF sig.V1 sig.V2 sig.V3 sig.V4 sig.V5 sig.V6 vm.X vm.Y vm.Z vm.VM]));
min_val = min(min([sig.I sig.II sig.III sig.avR sig.avL sig.avF sig.V1 sig.V2 sig.V3 sig.V4 sig.V5 sig.V6 vm.X vm.Y vm.Z vm.VM]));

figure('name','Superimposed Leads','numbertitle','off', 'color', colors.bgcolor);
for i=3:5
   hold on
   plot(vm.(fn_vm{i}),'color',colors.txtcolor,'linewidth',1.2);
end
for i=3:14
    p1 = plot(sig.(fn_sig{i}),'color',colors.txtcolor,'linewidth',1.2); 
end

p2 = plot(vm.(fn_vm{6}),'color',colors.vmecg,'linewidth',1.5);

p3 = line([locs.Q locs.Q],[min_val max_val],'color',colors.bluetxtcolor,'linestyle','--', 'linewidth',1.2);
line([locs.S locs.S],[min_val max_val],'color',colors.bluetxtcolor,'linestyle','--', 'linewidth',1.2);
line([locs.Tend locs.Tend],[min_val max_val],'color',colors.bluetxtcolor,'linestyle','--', 'linewidth',1.2);
p4 = line([0 length(vm.(fn_vm{6}))],[0 0],'color','[0 0.6 0]','linestyle','--', 'linewidth',1.2);
legend([p1 p2 p3 p4],{'Medians', 'Median VM', 'Fiducial Pts', 'Zero Line'})
ylim([min_val max_val]);
xlim([0 length(vm.(fn_vm{6}))]);
title(strcat("Superimposed Leads - ", filename(1:end-4)),'interpreter','none', 'color', colors.txtcolor)
set(gca, 'Xcolor', colors.txtcolor);
set(gca, 'Ycolor', colors.txtcolor);
set(gcf, 'Position', [100,100, 700, 500])  % set figure size
xlabel('Samples', 'color', colors.txtcolor)
ylabel('mV', 'color', colors.txtcolor)

set(gca,'Color', colors.bgfigcolor);

% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

if ismac && currentVersion < 2025
    fontsize(gcf,scale=1.25)
    savebutton.FontSize = 10;
    scalebutton.FontSize = 10;
end

if save == 1
    filename_short = strcat(filename(1:end-4),'_leads_superimposed.png');
    full_filename = fullfile(save_folder,filename_short);
    print(gcf,'-dpng',[full_filename],'-r600');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ECG Axis figure
figure('name','Frontal Plane Axis','numbertitle','off', 'color', colors.bgcolor)
polarplot([0 m.qrs_frontal_axis*pi/180],[0 1],'Color','r','LineWidth',4);
hold on
rticks([])
rlim([0 1])

% Yellow shading for normal axis area
for i = -30:0.5:90    
    polarplot([0 deg2rad(i)],[0 1],'linewidth',1.5,'color','[1 1 .82]'); 
end    

polarplot([0 0],[0 1],'Color','k','LineWidth',1,'LineStyle','--');
polarplot([0 90*pi/180 ],[0 1],'Color','k','LineWidth',1,'LineStyle','--');
polarplot([0 -90*pi/180 ],[0 1],'Color','k','LineWidth',1,'LineStyle','--');
polarplot([0 180*pi/180 ],[0 1],'Color','k','LineWidth',1,'LineStyle','--');

polarplot([0 -30*pi/180],[0 1],'Color','[0.9216 0.9216 0.9216]','LineWidth',1,'LineStyle','-');
polarplot([0 0],[0 1],'Color','[0.9216 0.9216 0.9216]','LineWidth',1,'LineStyle','-');
polarplot([0 30*pi/180 ],[0 1],'Color','[0.9216 0.9216 0.9216]','LineWidth',1,'LineStyle','-');
polarplot([0 60*pi/180 ],[0 1],'Color','[0.9216 0.9216 0.9216]','LineWidth',1,'LineStyle','-');

polarplot([0 90*pi/180 ],[0 1],'Color','[0 0.4470 0.7410]','LineWidth',2,'LineStyle','-');
polarplot([0 -30*pi/180 ],[0 1],'Color','[0 0.4470 0.7410]','LineWidth',2,'LineStyle','-');

polarplot([0 m.qrs_frontal_axis*pi/180],[0 1],'Color','r','LineWidth',4);

ax = gca;
ax.ThetaZeroLocation = 'right';
ax.ThetaDir = 'clockwise';
ax.ThetaLim = [-180 180];
ax.ThetaTick = [-180 -150 -120 -90 -60 -30 0 30 60 90 120 150];
ax.ThetaColor = colors.txtcolor;

ax_str = "Normal Axis";
if m.qrs_frontal_axis < -30 && m.qrs_frontal_axis > -90
    ax_str = "Left Axis Deviation";
elseif m.qrs_frontal_axis <= -90
    ax_str = "Extreme Axis Deviation";
elseif m.qrs_frontal_axis > 90 
    ax_str = "Right Axis Deviation";
end

set(gca,'Color', colors.bgfigcolor);

title(sprintf("QRS Axis = %3.0f° -- %s",m.qrs_frontal_axis, ax_str), 'color', colors.txtcolor)

end



% Helper function to rescale the Y axes so leads are all set to same scale
function LM_scale_y(src, event, median_12L, median_vcg, medianbeat, lead_morph)

    % List of lead names to help streamline code
    lead = [{'L1'} {'L2'} {'L3'} {'avF'} {'avL'} {'avR'} {'V1'} {'V2'} {'V3'} {'V4'} {'V5'} {'V6'} {'X'} {'Y'} {'Z'} {'VM'}];
    lead_alt = [{'I'} {'II'} {'III'} {'avF'} {'avL'} {'avR'} {'V1'} {'V2'} {'V3'} {'V4'} {'V5'} {'V6'} {'X'} {'Y'} {'Z'} {'VM'}];
    
    F = gcf;
    FAxes = findobj(allchild(F), 'flat', 'Type', 'axes');
    FYlims = get(FAxes, 'Ylim');

    % Find buttons
    B = findobj(allchild(F), 'flat', 'Type', 'uicontrol');

    % If Dynamic Ylim
    if strcmp(get(B(1),'String'),'Fixed Y Axes')
        
        for i = 1:16
            Ymin(i) = FYlims{i}(1);
            Ymax(i) = FYlims{i}(2);
        end
        
        axMin = min(Ymin);
        axMax = max(Ymax);
        
        for i = 1:16
            set(FAxes(i), 'Ylim', [axMin axMax]);
            
            % Get max/min to pan to center of Ylim
            % Want to equalize the distance from top op axis to max value (top) 
            % to distance from bottop of axis to min value (bot)
            % then goal, equal distance D = (top + bot) /2
            % amount to shift (dy) = top - dy which is equal to bot - dy
            % except for sign

            % index is in REVERSE order (VM is first etc)

            if i <= 4
                top = axMax - max(median_vcg.(lead_alt{16-i+1}));
                bot = min(median_vcg.(lead_alt{16-i+1})) - axMin;
                D = (top + bot) / 2;
                dy = top - D;

            else
                top = axMax - max(median_12L.(lead_alt{16-i+1}));
                bot = min(median_12L.(lead_alt{16-i+1})) - axMin;
                D = (top + bot) / 2;
                dy = top - D;

            end

            % If bot > top want to shift DOWN, so dy is POSITIVE
            % If top > bot want to shit UP so dy is NEGATIVE
            set(FAxes(i), 'YLim', get(FAxes(i), 'YLim') - dy);

        end

        % Change button text
        set(B(1),'String','Auto Y Axes')
    
    % Go back to Dynamic Ylim
    else
    
sig = median_12L;
fn_sig = fieldnames(sig);

vm = median_vcg;
fn_vm = fieldnames(vm);

m = lead_morph;
fn_m = fieldnames(m);

endspike = median_vcg.endspikes;

locs = medianbeat;

% Initialize vectors
tpk_vals = zeros(1,16);
tpk = zeros(1,16);
r_vals = zeros(1,16); 
s_vals = zeros(1,16);
rs_vals = zeros(1,16);


% Get the T wave locations (in samples) and T wave magnitudes
% Lead_Morphology stores T peak location as ms - need to convert back to samples for figure

% First 12 leads have different number of Lead_Morphology parameters than the 4 VCG leads

for i = 1:16
    % Find index of [lead]_t_max - this also finds [lead]_t_max_loc
    idx = find(contains(fn_m, lead{i}+"_t_max"));
    if ~isempty(idx)
        tmax_idx = idx(1);      % [lead]_t_max
        tmax_loc_idx = idx(2);  % [lead]_t_max_loc

        tpk_vals(i) = m.(fn_m{tmax_idx});
        tpk(i) = round((median_12L.hz/1000)*m.(fn_m{tmax_loc_idx}))+locs.Q; 
    else
        tpk_vals(i) = nan;
        tpk(i) = nan;
    end
end


% Get R wave and S wave values

for i = 1:16
    % Find index of [lead]_r_wave - this also finds [lead]_s_wave (index+1) and [lead]_rs_wave (index+2)
    idx = find(contains(fn_m, lead{i}+"_r_wave"));
        r_idx = idx(1);           % [lead]_r_wave
        s_idx = idx(1) + 1;       % [lead]_s_wave
        rs_idx = idx(1) + 2;      % [lead]_rs_wave

        r_vals(i) = m.(fn_m{r_idx});
        s_vals(i) = m.(fn_m{s_idx});
        rs_vals(i) = m.(fn_m{rs_idx});
end

        for i = 1:12

scale = abs(max((max([r_vals(i) tpk_vals(i)])))) + abs(min(min([s_vals(i) tpk_vals(i)])));

if sum(isnan(sig.(fn_sig{i+2}))) ~= length(sig.(fn_sig{i+2}))  % If signal NOT missing and therefore NOT all Nan
   % Axes are stored in OPPOSITE order
    set(FAxes(16-i+1), 'Ylim', [min(min([s_vals(i) tpk_vals(i)]))-0.2*scale max(max([r_vals(i) tpk_vals(i)]))+0.2*scale]);
else
    set(FAxes(16-i+1), 'Ylim', [-1 1]);   % If signal is all Nan, have to make some interval for ylim to avoid error
end

        end

        for i = 1:4
scale = abs(max((max([r_vals(i+12) tpk_vals(i+12)])))) + abs(min(min([s_vals(i+12) tpk_vals(i+12)])));

if sum(isnan(vm.(fn_vm{i+2}))) ~= length(vm.(fn_vm{i+2}))  % If vmnal NOT missing and therefore NOT all Nan
     % Axes are stored in OPPOSITE order
    set(FAxes(4-i+1), 'Ylim', [min(min([s_vals(i+12) tpk_vals(i+12)]))-0.2*scale max(max([r_vals(i+12) tpk_vals(i+12)]))+0.2*scale]);
    
else
     set(FAxes(4-i+1), 'Ylim', [-1 1]); % If vmnal is all Nan, have to make some interval for ylim to avoid error   
end

        end


        % Change button text
        set(B(1),'String','Fixed Y Axes')
    
    end

end


