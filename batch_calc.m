%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% batch_calc.m -- Annotates and computes all GEH and other statistics on an unfiltered ecg that the caller provides
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


function [hr_orig, NQRS_orig, beats5, quality, correlation_test, medianvcg1, beatsig_vcg, median_12L, beatsig_12L, ...
	  medianbeat, beat_stats, ecg_raw, vcg_raw, filtered_ecg, filtered_vcg, noise, sumfig] = ...
      batch_calc(ecg_raw, ovrbeats, ovrmedianbeat, ovrmedianvcg, ovrmedian12L, ovrvcgbeatsig, ap, qp, save_figures, title_name, other)

  
% Annotates and computes all GEH and other statistics on an unfiltered ecg that the caller provides
%
% input:
% ecg: raw 12-lead ECG12
% ovrbeats: manual annotation (or [] if automatic annotation) of the VCG
% ovrmedianbeat, ovrmedianvcg, ovrmedian12L, other: full control of the median beat, used by GUI
% ap: Annoparams
% qp: Qualparams
% save_figures: plot or not
% title_name: if generating figures, title for the figures
% other: stuff for dealing with GUI features
% 
% output:
% geh: VCG measurements
% morph: individual beat measurements
% beats5: beat annotations / ecg segmentation
% quality: quality flags
% median_12L: median beat in 12 lead ecg format
% medianbeat: median beat in VCG format
% ecg_raw: raw 12L ecg data
% vcg_raw: raw vcg data
% correlation_test
% filtered
% sumfig: summary figure to be saved in batch.m (not used in GUI)
% beats3 =  beats with PVCs marked (need for GUI figures)
% beats4 =  beats with outliers marked (need for GUI figures)
% beats5 =  final beats after removal of PVCs and outliers


% for dubugging GUI
% ap.outlier_removal = 0
% ap.pvc_removal = 0

% Calc noise indices
[~, ~, ~, hf_noise_min, ~, ~, ~, lf_noise_max] = noise_test(ecg_raw, 0, 0, ap);
noise = [hf_noise_min lf_noise_max];

% If not supplying median beat information - eg denovo ECG/VCG processing
if isempty(ovrmedianbeat) && isempty(ovrmedianvcg) && isempty(ovrmedian12L)

% Unfiltered (raw) VCG from unfiltered (raw) ECG
vcg_raw = VCG(ecg_raw, ap);

% Find Rpeaks in VCG VM lead
QRS_for_shift = vcg_raw.peaks(ap);

% Filter, transform post-filtering
filtered_ecg = ecg_raw.filter(NaN, ap);
filtered_vcg = VCG(filtered_ecg, ap);

% Baseline correction for X, Y, Z if option checked
if ap.baseline_correct_flag
    % Baseline correct VCG
    vcg2 = filtered_vcg.baseline_shift(ap);
    
    % Baseline correct the 12L ECG (needed for GUI)
    [sL1, sL2, sL3, savR, savF, savL, sV1, sV2, sV3, sV4, sV5, sV6, ~, ~, ~, ~, ~,...
    ~, ~, ~, ~, ~, ~, ~] = ...
    baseline_shift_hfs(filtered_ecg.I, filtered_ecg.II, filtered_ecg.III, filtered_ecg.avR, filtered_ecg.avF, filtered_ecg.avL, ...
    filtered_ecg.V1, filtered_ecg.V2, filtered_ecg.V3, filtered_ecg.V4, filtered_ecg.V5, filtered_ecg.V6, filtered_ecg.hz, QRS_for_shift);

    filtered_ecg = ECG12(filtered_ecg.hz,'',sL1, sL2, sL3, savR, savF, savL, sV1, sV2, sV3, sV4, sV5, sV6);
        
else    % Don't baseline shift
    vcg2 = filtered_vcg;
end

QRS2 = vcg2.peaks(ap);
NQRS_orig = length(QRS2);

hr_orig = 60000 / mean((diff(QRS2)*(1000/ecg_raw.hz))) ;  % HR from initial peak detection
%maxRR_hr_orig = (60000/vcg2.sample_time())*0.5/max(diff(QRS2)); % the 0.5 is for filtering stuff - no longer used

% If supply a beats class use these instead of annotating from scratch
if isa(ovrbeats, 'Beats')
    beats5 = ovrbeats; beats3 = ovrbeats; beats4 = ovrbeats;
else
    % Pacer spike detection - generate new VCG with NaN masking of pacer spikes
    if ap.spike_removal
        [vcg3, vcg2] = vcg2.remove_pacer_spikes(QRS2, ap);
        QRS3 = vcg3.peaks(ap);
    else
        vcg3 = vcg2; %#ok<NASGU>
        QRS3 = QRS2;
    end
    
    % Annotate and fix intervals
    beats3_1 = Beats(vcg2, QRS3, ap);
    % sanity checking - beats should not overlap and T-end should not be NaN
    beats3 = beats3_1.fixTend(ap);

    
    % PVC removal - generate new VCG with NaN masking of PVCs
    % beats3 is everything pre-pvc removal
    if ap.pvc_removal
        beats3 = beats3.find_pvcs(vcg2, ap);
        beats4 = beats3.delete(beats3.pvc,"pvc");
    else
        beats4 = beats3;
    end
    
    
    % Outlier removal
    % beats4 is everything pre-outlier removal
    if ap.outlier_removal
        beats4 = beats4.find_outliers(vcg2,ap);
        beats5 = beats4.delete(beats4.outlier,"outlier");
    else
        beats5 = beats4;
    end
end


% Median beat signals
% use VCG2 here, because you want to use the original VCG to generate the median beat.
[startb, endb] = beats5.medianloc(vcg2, ap);

% is the median window too big?
medRR = median(diff(beats5.QRS));
% RRfrac = round(ap.window_rrfrac * medRR);
% ind = ((endb - startb) > RRfrac);
% endb(ind) = startb(ind) + RRfrac;
% rrfrac_flag = any(ind);

[medianvcg1, beatsig_vcg] = vcg2.medianbeat(startb, endb);

% Find R peak of median VM signal
[~, medianQRS1] = max(medianvcg1.VM);

% adjust for possible pacer spike
if ap.spike_removal
    [medianvcg2, medianvcg1] = medianvcg1.remove_pacer_spikes(medianQRS1, ap);
else
    medianvcg2 = medianvcg1;
end
[~, medianQRS2] = max(medianvcg2.VM, [], 'omitnan'); % finds QRS peak of median VM beat


% NB STend is ignored when NQRS = 1
% annotate original median beat
% for NBeats = 1, STend is interpreted as an interval in samples rather than a %age
% a little clunky but the best way to do it maybe? idk
ap.STend = round(ap.STend * medRR/100);
medianbeat = Beats(medianvcg1, medianQRS2, ap);

% Correlation Test
correlation_test = median_fit(beatsig_vcg, medianbeat);

% Medians for 12L ECG
[median_12L, beatsig_12L] = filtered_ecg.medianbeat(startb, endb);


% Beat stats
beat_stats = Beat_Stats(beats5, 1000/ecg_raw.hz);

filtered_vcg = vcg2;  

end         % End of If statement for if no ovrmedianbeats



% If specified a ovrmedianbeat, swap it for the variable medianbeat here
if ~isempty(ovrmedianbeat) && ~isempty(ovrmedianvcg) && ~isempty(ovrmedian12L) && ~isempty(ovrvcgbeatsig)
   medianvcg1 = ovrmedianvcg;
   median_12L = ovrmedian12L;
   beatsig = ovrvcgbeatsig;
   beats5 = ovrbeats;
   
   % Have to recalculate STend here
   medRR = median(diff(beats5.QRS));
   ap.STend = round(ap.STend * medRR/100);
   
   % Annotate the median beat
   medianbeat = Beats(ovrmedianvcg, ovrmedianbeat.QRS, ap);
   
   % Recalc correlation
   correlation_test  = median_fit(beatsig, medianbeat);
   
   % Pull these HR metrics through since they dont change and therefore dont have to run the entire loop again   
   hr_orig = other.hr;
   NQRS_orig = other.NQRS_orig;
   
   % No output for these since they dont change   
   beatsig_vcg = [];
   beatsig_12L = [];
   beat_stats = [];
   %ecg_raw = [];
   vcg_raw = [];
   filtered_ecg = [];
   filtered_vcg = [];
end


% quality testing
quality = Quality(medianvcg1, ecg_raw, beats5, medianbeat, ...
    hr_orig, NQRS_orig, correlation_test, noise, ap, qp);


if save_figures
    sumfig = figure('visible','off');

    subplot(7,1,[1 2 3])
    max_line = max(max([medianvcg1.X medianvcg1.Y medianvcg1.Z medianvcg1.VM]));
    min_line = min(min([medianvcg1.X medianvcg1.Y medianvcg1.Z medianvcg1.VM]));
   
    hold off;
    ppvm = plot(medianvcg1.VM, 'linewidth', 1.75, 'color', [0 0.4470 0.7410],'Displayname','VM');
    hold on;
    ppx = plot(medianvcg1.X', 'color', [ 0 0 0],'Displayname','X', 'linewidth', 1.25);
    ppy = plot(medianvcg1.Y', 'color', [0.8500 0.3250 0.0980],'Displayname','Y', 'linewidth', 1.25);
    ppz = plot(medianvcg1.Z', 'color', [0.9290 0.6940 0.1250],'Displayname','Z', 'linewidth', 1.25);
        
    line([0 length(medianvcg1.X')],[0 0], 'Color','black','LineStyle','--');
    ppdot = line([0 length(medianvcg1.X')],[0.05 0.05], 'Color','black','LineStyle',':', 'Displayname','0.05 mV'); 
    ppqon = line([medianbeat.Q medianbeat.Q],[min_line max_line],'Color','k','LineStyle','--', 'Displayname','QRS Start','linewidth', 1.15);
    ppqoff = line([medianbeat.S medianbeat.S],[min_line max_line],'Color','b','LineStyle','--', 'Displayname','QRS End','linewidth', 1.15);
    pptoff = line([medianbeat.Tend medianbeat.Tend],[min_line max_line],'Color','r','LineStyle','--', 'Displayname','Tend','linewidth', 1.15);
    line([0 length(medianvcg1.X')],[-0.05 -0.05], 'Color','black','LineStyle',':');
    text_string = sprintf('X / Y / Z Cross Correlation = %0.3f / %0.3f / %0.3f \nGood Quality Probability = %3.1f%% \nQRS = %i ms \nQT = %i ms', correlation_test.X,  correlation_test.Y,  correlation_test.Z, ...
       100*quality.prob_value, (medianbeat.S-medianbeat.Q)*(1000/medianvcg1.hz), (medianbeat.Tend-medianbeat.Q)*(1000/medianvcg1.hz)); 
    text(find(medianvcg1.VM == max(medianvcg1.VM)) + round(100*(medianvcg1.hz/1000)), 0.8*medianvcg1.VM(find(medianvcg1.VM == max(medianvcg1.VM))),text_string,'fontsize',8);
 
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',6)
    ylabel('mV')
    title_txt = sprintf('%s', char(title_name));
    title(title_txt,'Interpreter','none','fontsize',13)
    
    legend([ppvm ppx ppy ppz ppqon ppqoff pptoff ppdot]) % Add partial legend to figure
    hold off
    
    X = vcg2.X; Y = vcg2.Y; Z = vcg2.Z; VM = vcg2.VM;
    subplot(7,1,4)
    hold on
    plot(X, 'color', [ 0 0 0], 'linewidth', 1)
    scatter(beats5.QRS,X(beats5.QRS),12)
    line([0 length(X)],[0 0], 'Color','red','LineStyle','--','linewidth', 0.5);
    set(gca,'YTickLabel',[]);
    xticks(0:1000:5000);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',6);
    ylabel('X (mV)');
    scalex = abs(max(X)-min(X));
    ylim([min(min(X))-(0.1*scalex) max(max(X))+(0.1*scalex)]);
    
    pvc_QRS = [];
    if any(beats3.pvc)
        pvc_QRS = beats3.QRS(beats3.pvc);
        t1 = text(pvc_QRS,X(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 5;
        end
        
    end
    
    outlier_QRS = [];
    if any(beats4.outlier)
        outlier_QRS = beats4.QRS(beats4.outlier);
        t2 = text(outlier_QRS,X(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 5;
        end
    end
    hold off
    
    subplot(7,1,5)
    hold on
    plot(Y, 'color', [0.8500 0.3250 0.0980], 'linewidth', 1)
    scatter(beats5.QRS,Y(beats5.QRS),12)
    line([0 length(Y)],[0 0], 'Color','black','LineStyle','--','linewidth', 0.5);
    set(gca,'YTickLabel',[]);
    xticks(0:1000:5000);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',6);
    ylabel('Y (mV)');
    scaley = abs(max(Y)-min(Y));
    ylim([min(min(Y))-(0.1*scaley) max(max(Y))+(0.1*scaley)]);
    if ~isempty(pvc_QRS)
        t1 = text(pvc_QRS,Y(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 5;
        end
        
    end
    
    if ~isempty(outlier_QRS)
        t2 = text(outlier_QRS,Y(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 5;
        end
    end
    hold off
    
    subplot(7,1,6)
    hold on
    plot(Z, 'color', [0.9290 0.6940 0.1250], 'linewidth', 1)
    scatter(beats5.QRS,Z(beats5.QRS),12)
    line([0 length(Z)],[0 0], 'Color','black','LineStyle','--','linewidth', 0.5);
    set(gca,'YTickLabel',[]);
    xticks(0:1000:5000);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',6);
    ylabel('Z (mV)');
    scalez = abs(max(Z)-min(Z));
    ylim([min(min(Z))-(0.1*scalez) max(max(Z))+(0.1*scalez)]);
    if ~isempty(pvc_QRS)
        t1 = text(pvc_QRS,Z(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 5;
        end
        
    end
    
    if ~isempty(outlier_QRS)
        t2 = text(outlier_QRS,Z(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 5;
        end
    end
    hold off
    
    subplot(7,1,7)
    hold on
    plot(VM, 'color', [0 0.4470 0.7410], 'linewidth', 1)
    scatter(beats5.QRS,VM(beats5.QRS),12);
    set(gca,'YTickLabel',[]);
    xticks(0:1000:5000);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',6);
    
    if ~isempty(pvc_QRS)
        t1 = text(pvc_QRS,VM(pvc_QRS),' PVC');
        
        for j = 1:length(t1)
            t1(j).FontSize = 5;
        end
        
    end
    
    if ~isempty(outlier_QRS)
        t2 = text(outlier_QRS,VM(outlier_QRS),' Out');
        
        for j = 1:length(t2)
            t2(j).FontSize = 5;
        end
    end
    
    ylabel('VM (mV)');
    xlabel('Samples');
    hold off
    
    set(gcf, 'Position', [200, 100, 900, 600])  % set figure size
else
    sumfig = [];
end


end




