%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% pvc_data_visualization.m -- Part of BRAVEHEART GUI - Figure showing PVC data
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


function pvc_data_visualization(beats, aps, vcg, hObject, eventdata, handles)

% Load VCG class so can interate through labels
% (v{index}) allows to programatically iterate through X, Y, and Z
v = properties(VCG());
v_fn = fieldnames(VCG());

figure('name','QRS Normalized Cross Correlations and Normalized RMSE','numbertitle','off')
sgtitle(sprintf('Normalized X-Correlation (Threshold = %3.1f%%) & Normalized RMSE (Threshold = %0.2f)',round(100*aps.pvcthresh),round(aps.rmse_pvcthresh,2)),'fontweight', 'bold')

for k = 3:5     % X, Y, and Z in VCG properties
    
R = com_or_rpeak(beats.QRS, vcg.VM, vcg.hz, aps);
    
[~, norm_corr_matrix_values, rmse_matrix_values, pvc_list, ind] = pvc_stats(aps.pvcthresh, aps.rmse_pvcthresh, aps.keep_pvc, [beats.Q R beats.S beats.Tend], vcg.(v{k}));

pvcs(k,:) = pvc_list;

N = size(norm_corr_matrix_values,1);
  
% Generate xtick labels based on number of beats (N)
for p=1:N
   xtick_label(p) = strcat({'Beat '}', num2str(p));
end
  
max_rows = 13;

%%%
subplot(max_rows,1,4*k-11) 
title(sprintf('Normalized Cross Correlation (Beat %i Reference)', ind))
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)
xticklabels([])
ylabel(v_fn(k), 'fontsize',12,'fontweight','bold');
ylh = get(gca,'ylabel');
gyl = get(ylh);
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
  
for j=1:N
    if norm_corr_matrix_values(ind,j)>aps.pvcthresh
        text(j,0.3,num2str(round(100*norm_corr_matrix_values(ind,j),1)),'vert','bottom','horiz','center','FontWeight','bold', 'Color','r'); 
    else
        text(j,0.3,num2str(round(100*norm_corr_matrix_values(ind,j),1)),'vert','bottom','horiz','center'); 
    end
end
      
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)


%%%   
subplot(max_rows,1,4*k-10) 
title(sprintf('Normalized RMSE (Beat %i Reference)', ind))
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)
xticklabels([])
ylabel(v_fn(k), 'fontsize',12,'fontweight','bold');
ylh = get(gca,'ylabel');
gyl = get(ylh);
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
   
   
for j=1:N
    if rmse_matrix_values(ind,j) <= aps.rmse_pvcthresh
        text(j,0.3,num2str(round(rmse_matrix_values(ind,j),2)),'vert','bottom','horiz','center','FontWeight','bold', 'Color','r'); 
    else
        text(j,0.3,num2str(round(rmse_matrix_values(ind,j),2)),'vert','bottom','horiz','center'); 
    end
end


ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)


%%%   
subplot(max_rows,1,4*k-9) 

bar(pvc_list,'r') 

title(sprintf('PVC Markers (Beat %i Reference)', ind))
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)
xticklabels(xtick_label)
ylabel(v_fn(k), 'fontsize',12,'fontweight','bold');
ylh = get(gca,'ylabel');
gyl = get(ylh);
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
   
   
% for j=1:N
%     if pvc_list(j) == 1
%         text(j,0.3,num2str(pvc_list(j)),'vert','bottom','horiz','center','FontWeight','bold', 'Color','r'); 
%     else
%         text(j,0.3,num2str(pvc_list(j)),'vert','bottom','horiz','center'); 
%     end
% end



ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)

end

%%%   
subplot(max_rows,1,max_rows) 

final_pvc_list = sum(pvcs);
final_pvc_list(final_pvc_list<2) = 0;
final_pvc_list(final_pvc_list>=2) = 1;

bar(final_pvc_list,'r')   


title(sprintf('Final PVC Markers', ind))
ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)
xticklabels(xtick_label)
ylabel('PVCs', 'fontsize',12,'fontweight','bold');
ylh = get(gca,'ylabel');
gyl = get(ylh);
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
   



% for j=1:N
%     if final_pvc_list(j) == 1
%         text(j,0.3,num2str(final_pvc_list(j)),'vert','bottom','horiz','center','FontWeight','bold', 'Color','r'); 
%     else
%         text(j,0.3,num2str(final_pvc_list(j)),'vert','bottom','horiz','center'); 
%     end
% end


ylim([0 1]);
set(gca,'YTickLabel',[]);
yticks([0 1])
xlim([0 N+1])
xticks(1:1:N)

set(gcf, 'Position', [200, 100, 900, 1000])  % set figure size

% Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end

