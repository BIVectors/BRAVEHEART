%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% summary_figure.m -- Part of BRAVEHEART GUI - Shows Summary figure
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


function summary_figure(vcg, beats, beats_pvc, beats_outlier, median_vcg, medianbeat, correlation_test, filename)

%%% NEED TO HAVE GUI STORE beats3 and beats4 when activate PVC and/or outlier removal

%summaryecg_fig = figure('name',handles.filename_short,'numbertitle','off');
summaryecg_fig = figure('name',filename,'numbertitle','off');

    subplot(7,1,[1 2 3])
    
    max_line = max(max([median_vcg.X median_vcg.Y median_vcg.Z median_vcg.VM]));
    min_line = min(min([median_vcg.X median_vcg.Y median_vcg.Z median_vcg.VM]));
    hold off;
    
    ppvm = plot(median_vcg.VM, 'linewidth', 2, 'color', [0 0.4470 0.7410],'Displayname','VM');
    hold on;
    
    ppx = plot(median_vcg.X', 'color', [0 0 0],'Displayname','X', 'linewidth', 1.2);
    ppy = plot(median_vcg.Y', 'color', [0.8500 0.3250 0.0980],'Displayname','Y', 'linewidth', 1.2);
    ppz = plot(median_vcg.Z', 'color', [0.9290 0.6940 0.1250],'Displayname','Z', 'linewidth', 1.2);
    
    line([0 length(median_vcg.X')],[0 0], 'Color','black','LineStyle','--');
    
    ppdot = line([0 length(median_vcg.X')],[0.05 0.05], 'Color','black','LineStyle',':', 'Displayname','0.05 mV');
    ppqon = line([medianbeat.Q medianbeat.Q],[min_line max_line],'Color','k','LineStyle','--', 'Displayname','QRS Start','linewidth', 1.15);
    ppqoff = line([medianbeat.S medianbeat.S],[min_line max_line],'Color','b','LineStyle','--', 'Displayname','QRS End','linewidth', 1.15);
    pptoff = line([medianbeat.Tend medianbeat.Tend],[min_line max_line],'Color','r','LineStyle','--', 'Displayname','Tend','linewidth', 1.15);
    
    line([0 length(median_vcg.X')],[-0.05 -0.05], 'Color','black','LineStyle',':');
    
    text_string = sprintf('X / Y / Z Cross Correlation = %0.3f / %0.3f / %0.3f \nQRS = %3.0f ms \nQT = %3.0f ms', correlation_test.X,  correlation_test.Y,  correlation_test.Z, ...
        (medianbeat.S-medianbeat.Q)*(1000/vcg.hz), (medianbeat.Tend-medianbeat.Q)*(1000/vcg.hz)); 
    text(find(median_vcg.VM == max(median_vcg.VM)) + round(100*(vcg.hz/1000)), 0.8*median_vcg.VM(find(median_vcg.VM == max(median_vcg.VM))),text_string,'fontsize',12);
    
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',10)
    ylabel('mV', 'FontWeight','bold')
    
    title_txt = sprintf('%s', filename);
    title(title_txt,'Interpreter','none','fontsize',13)
    
    xlim([0 length(median_vcg.X)])
    legend([ppvm ppx ppy ppz ppqon ppqoff pptoff ppdot]) % Add partial legend to figure
    hold off
    
    X = vcg.X; Y = vcg.Y; Z = vcg.Z; VM = vcg.VM;
    
    
    subplot(7,1,4)
    hold on
    
    plot(X, 'color', [0 0 0], 'linewidth', 1)
    scatter(beats.QRS,X(beats.QRS))    
    line([0 length(X)],[0 0], 'Color','red','LineStyle','--','linewidth', 0.5);
   
    set(gca,'YTickLabel',[]);
    xticks(0:1000:length(VM));
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',10);
    ylabel('X (mV)');
    scalex = abs(max(X)-min(X));
    ylim([min(min(X))-(0.1*scalex) max(max(X))+(0.1*scalex)]);
    
    pvc_QRS = [];
    if any(beats_pvc)
        pvc_QRS = beats_pvc;
        t1 = text(pvc_QRS,X(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 10;
        end
        
    end
    
    outlier_QRS = [];
    if any(beats_outlier)
        outlier_QRS = beats_outlier;
        t2 = text(outlier_QRS,X(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 10;
        end
    end
    hold off
    
    subplot(7,1,5)
    hold on
    plot(Y, 'color', [0.8500 0.3250 0.0980], 'linewidth', 1)
    scatter(beats.QRS,Y(beats.QRS))
    line([0 length(Y)],[0 0], 'Color','black','LineStyle','--','linewidth', 0.5);
    
    set(gca,'YTickLabel',[]);
    xticks(0:1000:length(VM));
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',10);
    ylabel('Y (mV)');
    scaley = abs(max(Y)-min(Y));
    ylim([min(min(Y))-(0.1*scaley) max(max(Y))+(0.1*scaley)]);
    
    if ~isempty(pvc_QRS)
        t1 = text(pvc_QRS,Y(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 10;
        end
        
    end
    
    if ~isempty(outlier_QRS)
        t2 = text(outlier_QRS,Y(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 10;
        end
    end
    hold off
    
    
    subplot(7,1,6)
    hold on
    plot(Z, 'color', [0.9290 0.6940 0.1250], 'linewidth', 1)
    scatter(beats.QRS,Z(beats.QRS))
    line([0 length(Z)],[0 0], 'Color','black','LineStyle','--','linewidth', 0.5);
    
    set(gca,'YTickLabel',[]);
    xticks(0:1000:length(VM));
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',10);
    ylabel('Z (mV)');
    scalez = abs(max(Z)-min(Z));
    ylim([min(min(Z))-(0.1*scalez) max(max(Z))+(0.1*scalez)]);
   
    if ~isempty(pvc_QRS)
        t1 = text(pvc_QRS,Z(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 10;
        end
        
    end
    
    if ~isempty(outlier_QRS)
        t2 = text(outlier_QRS,Z(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 10;
        end
    end
    hold off
    
    
    subplot(7,1,7)
    hold on
    
    plot(VM, 'color', [0 0.4470 0.7410], 'linewidth', 1)
    scatter(beats.QRS,VM(beats.QRS));
    set(gca,'YTickLabel',[]);
    xticks(0:1000:length(VM));
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',10);
    
    if ~isempty(pvc_QRS)
        t1 = text(pvc_QRS,VM(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 10;
        end
        
    end
    
    if ~isempty(outlier_QRS)
        t2 = text(outlier_QRS,VM(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 10;
        end
    end
    
    ylabel('VM (mV)');
    xlabel('Samples');
    hold off
    
    % Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end

    set(gcf, 'Position', [200, 100, 1200, 900])  % set figure size

