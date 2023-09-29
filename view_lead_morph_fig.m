%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% view_lead_morph_fig.m -- Part of BRAVEHEART GUI - View Lead Morphology figure
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

function view_lead_morph_fig(median_12L, median_vcg, medianbeat, lead_morph, save, filename, save_folder)


sig = median_12L;
fn_sig = fieldnames(sig);

vm = median_vcg;
fn_vm = fieldnames(vm);

m = lead_morph;
fn_m = fieldnames(m);

locs = medianbeat;


for i = 1:16
    
    if ~isempty(m.(fn_m{(7*i)-1})) & ~isempty(m.(fn_m{(7*i)}))    
        tpk_vals(i) = m.(fn_m{(7*i)-1});
        tpk(i) = (0.5*m.(fn_m{(7*i)}))+locs.Q;
    else
       tpk_vals(i) = nan;
       tpk(i) = nan ;
    end
    
end


figure('name','Median Beat Morphology','numbertitle','off');


for i = 3:14
subplot(4,4,i-2)
plot(sig.(fn_sig{i}),'linewidth',1.5)
hold on
scatter(locs.Q,sig.(fn_sig{i})(locs.Q),'k')
scatter(locs.S,sig.(fn_sig{i})(locs.S),'k')
scatter(locs.Tend,sig.(fn_sig{i})(locs.Tend),'k')
line([0 length(sig.(fn_sig{i}))],[m.(fn_m{(7*(i-3))+1}) m.(fn_m{(7*(i-3))+1})],'linestyle','--','color','r')
line([0 length(sig.(fn_sig{i}))],[m.(fn_m{(7*(i-3))+2}) m.(fn_m{(7*(i-3))+2})],'linestyle','--','color','r')
line([0 length(sig.(fn_sig{i}))],[0 0], 'linestyle',':', 'color','k')
xlim([0 length(sig.(fn_sig{i})) + 125])
scale = abs(max(sig.(fn_sig{i}))) + abs(min(sig.(fn_sig{i})));

if sum(isnan(sig.(fn_sig{i}))) ~= length(sig.(fn_sig{i}))  % If signal NOT missing and therefore NOT all Nan
    ylim([min(sig.(fn_sig{i}))-0.2*scale max(sig.(fn_sig{i}))+0.2*scale]);
else
    ylim([-1 1]);   % If signal is all Nan, have to make some interval for ylim to avoid error
end

line([length(sig.(fn_sig{i}))+5 length(sig.(fn_sig{i}))+5],[m.(fn_m{(7*(i-3))+2}) m.(fn_m{(7*(i-3))+1})],'color','k')
text(length(sig.(fn_sig{i}))+10, 0.5*(m.(fn_m{(7*(i-3))+1}) + m.(fn_m{(7*(i-3))+2})), strcat("\Delta = ", num2str(round(m.(fn_m{(7*(i-3))+3}),2))),'fontsize',9)
text(length(sig.(fn_sig{i}))+10, m.(fn_m{(7*(i-3))+1}), strcat("R = ", num2str(round(m.(fn_m{(7*(i-3))+1}),2))),'fontsize',9)
text(length(sig.(fn_sig{i}))+10, m.(fn_m{(7*(i-3))+2}), strcat("S = ", num2str(round(m.(fn_m{(7*(i-3))+2}),2))),'fontsize',9)
title(fn_sig{i})
ylabel("mV")
scatter(tpk(i-2),tpk_vals(i-2),'r')
line([tpk(i-2) tpk(i-2)],[0 tpk_vals(i-2)],'color','k')

if tpk_vals(i-2) > 0 & ~isnan(tpk_vals(i-2))
    text(tpk(i-2)-30,tpk_vals(i-2)+ 0.1*m.(fn_m{(7*(i-3))+3}),strcat("T = ", num2str(round(tpk_vals(i-2),2))))
elseif tpk_vals(i-2) < 0 & ~isnan(tpk_vals(i-2))
    text(tpk(i-2)-30,tpk_vals(i-2)- 0.1*abs(m.(fn_m{(7*(i-3))+3})),strcat("T = ", num2str(round(tpk_vals(i-2),2))))
else
end


end

for i = 3:6
subplot(4,4,i+10)
plot(vm.(fn_vm{i}),'linewidth',1.5)
hold on
scatter(locs.Q,vm.(fn_vm{i})(locs.Q),'k')
scatter(locs.S,vm.(fn_vm{i})(locs.S),'k')
scatter(locs.Tend,vm.(fn_vm{i})(locs.Tend),'k')
line([0 length(vm.(fn_vm{i}))],[m.(fn_m{(7*(i+12-3))+1}) m.(fn_m{(7*(i+12-3))+1})],'linestyle','--','color','r')
line([0 length(vm.(fn_vm{i}))],[m.(fn_m{(7*(i+12-3))+2}) m.(fn_m{(7*(i+12-3))+2})],'linestyle','--','color','r')
line([0 length(vm.(fn_vm{i}))],[0 0], 'linestyle',':', 'color','k')
xlim([0 length(vm.(fn_vm{i})) + 100])
scale = abs(max(vm.(fn_vm{i}))) + abs(min(vm.(fn_vm{i})));
ylim([min(vm.(fn_vm{i}))-0.2*scale max(vm.(fn_vm{i}))+0.2*scale])
line([length(vm.(fn_vm{i}))+5 length(vm.(fn_vm{i}))+5],[m.(fn_m{(7*(i+12-3))+2}) m.(fn_m{(7*(i+12-3))+1})],'color','k')
text(length(vm.(fn_vm{i}))+10, 0.5*(m.(fn_m{(7*(i+12-3))+1}) + m.(fn_m{(7*(i+12-3))+2})), strcat("\Delta = ", num2str(round(m.(fn_m{(7*(i+12-3))+3}),2))),'fontsize',9)
text(length(vm.(fn_vm{i}))+10, m.(fn_m{(7*(i+12-3))+1}), strcat("R = ", num2str(round(m.(fn_m{(7*(i+12-3))+1}),2))),'fontsize',9)
text(length(vm.(fn_vm{i}))+10, m.(fn_m{(7*(i+12-3))+2}), strcat("S = ", num2str(round(m.(fn_m{(7*(i+12-3))+2}),2))),'fontsize',9)
title(fn_vm{i})
ylabel("mV")
scatter(tpk(i+12-2),tpk_vals(i+12-2),'r')
line([tpk(i+12-2) tpk(i+12-2)],[0 tpk_vals(i+12-2)],'color','k')

if tpk_vals(i+12-2) >= 0 & ~isnan(tpk_vals(i-2))
    text(tpk(i+12-2)-30,tpk_vals(i+12-2)+ 0.1*m.(fn_m{(7*(i+12-3))+3}),strcat("T = ", num2str(round(tpk_vals(i+12-2),2))))
elseif tpk_vals(i+12-2) < 0 & ~isnan(tpk_vals(i-2))
    text(tpk(i+12-2)-30,tpk_vals(i+12-2)- 0.1*abs(m.(fn_m{(7*(i+12-3))+3})),strcat("T = ", num2str(round(tpk_vals(i+12-2),2))))
else
end


sgtitle(strcat("Median Beat Morphology - ", filename(1:end-4)),'interpreter','none','fontweight', 'bold')
set(gcf, 'Position', [0,0, 1600, 1000])  % set figure size
end


% Increase font size on mac due to pc/mac font differences
if ismac
    fontsize(gcf,scale=1.25)
end


if save == 1
    filename_short = strcat(filename(1:end-4),'_lead_morph_ecg.png');
    full_filename = fullfile(save_folder,filename_short);
    print(gcf,'-dpng',[full_filename],'-r600');
end



% All leads at once

max_val = max(max([sig.I sig.II sig.III sig.avR sig.avL sig.avF sig.V1 sig.V2 sig.V3 sig.V4 sig.V5 sig.V6 vm.X vm.Y vm.Z vm.VM]));
min_val = min(min([sig.I sig.II sig.III sig.avR sig.avL sig.avF sig.V1 sig.V2 sig.V3 sig.V4 sig.V5 sig.V6 vm.X vm.Y vm.Z vm.VM]));

figure('name','Superimposed Leads','numbertitle','off');
for i=3:5
   hold on
   plot(vm.(fn_vm{i}),'color','k','linewidth',1.2);
end
for i=3:14
    p1 = plot(sig.(fn_sig{i}),'color','k','linewidth',1.2); 
end

p2 = plot(vm.(fn_vm{6}),'color','r','linewidth',1.5);

p3 = line([locs.Q locs.Q],[min_val max_val],'color','b','linestyle','--', 'linewidth',1.2);
line([locs.S locs.S],[min_val max_val],'color','b','linestyle','--', 'linewidth',1.2);
line([locs.Tend locs.Tend],[min_val max_val],'color','b','linestyle','--', 'linewidth',1.2);
p4 = line([0 length(vm.(fn_vm{6}))],[0 0],'color','[0 0.6 0]','linestyle','--', 'linewidth',1.2);
legend([p1 p2 p3 p4],{'Medians', 'Median VM', 'Fiducial Pts', 'Zero Line'})
ylim([min_val max_val]);
xlim([0 length(vm.(fn_vm{6}))]);
title(strcat("Superimposed Leads - ", filename(1:end-4)),'interpreter','none')
set(gcf, 'Position', [100,100, 700, 500])  % set figure size

% Increase font size on mac due to pc/mac font differences
if ismac
    fontsize(gcf,scale=1.25)
end


if save == 1
    filename_short = strcat(filename(1:end-4),'_leads_superimposed.png');
    full_filename = fullfile(save_folder,filename_short);
    print(gcf,'-dpng',[full_filename],'-r600');
end

