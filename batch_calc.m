%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% batch_calc.m -- Annotates and computes all GEH and other statistics on an unfiltered ecg that the caller provides
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


function batchout = batch_calc(ecg_raw, ovrbeats, ovrmedianbeat, ovrmedianvcg, ovrmedian12L, ovrvcgbeatsig, ap, qp, save_figures, title_name, other)

% Filters, annotates, and creates median beats for an ECG that the caller provides
%
% INPUT:
% ecg_raw: 12-lead ECG12 object
% ovrbeats: manual annotation (or [] if automatic annotation) of the VCG
% ovrmedianbeat, ovrmedianvcg, ovrmedian12L: full control of the median beat; used by GUI
% ap: Annoparams object
% qp: Qualparams object
% save_figures: plot or not
% title_name: if generating figures, title for the figures
% other: other stuff for dealing with GUI features
% 
% OUTPUT (in structure batchout)
% beats_final: annotations for the filtered ECG/VCG
% quality: quality parameters
% correlation_test: X, Y, Z cross correlation values
% medianvcg1: median VCG object
% beatsig_vcg:individual beats used to make up median VCG
% median_12L: median 12 lead ECG12 object
% beatsig_12L: individual beats used to make the median 12L ECG
% medianbeat: annotations for the median beat
% beat_stats: beat statistics
% ecg_raw = 12-lead ECG12 object (same as input)
% vcg_raw = VCG of ecg_raw
% filtered_ecg: ECG12 with all processing (filtering, baseline correction, interpolation)
% filtered_vcg: VCG with all processing (filtering, baseline correction, interpolation)
% noise: noise measurements
% ecg_raw_postinterp: ECG12 object after interpolation (if performed)
% pacer_spikes: structure that contains the pacing spikes that were removed (if present) from each lead
% lead_ispaced: structure for if each of the 12 leads is paced or not

% Save raw ecg in output structure
batchout.ecg_raw = ecg_raw;

% Calc noise indices
[~, ~, ~, hf_noise_min, ~, ~, ~, lf_noise_max] = noise_test(ecg_raw, 0, 0, ap);
batchout.noise = [hf_noise_min lf_noise_max];

% If not supplying median beat information - eg denovo ECG/VCG processing
if isempty(ovrmedianbeat) && isempty(ovrmedianvcg) && isempty(ovrmedian12L)

% Unfiltered (raw) VCG from unfiltered (raw) ECG
batchout.vcg_raw = VCG(ecg_raw, ap);

% Find Rpeaks in VCG VM lead (legacy code, but leaving in for now)
QRS_for_shift = batchout.vcg_raw.peaks(ap);

% Will interpolate/spike remove on the RAW signals prior to filtering.
% Interpolation was fone prior to filtering to allow more robust and
% consistent performance.  If interpolation is done AFTER filtering, have
% to deal with the signal sampling frequency AND actual filtering affecting 
% Z score thresholds.  By doing interpolation on the raw signals, only 
% have to adjust for the signal sampling frequency.

% As of v1.5.0 we are replacing the function of spike removal which
% originally used median filtering and assessment of spike width to ignore
% pacing spikes.  This was controlled by pacer_spike_width, pacer_mf, and 
% pacer_thresh in Annoparams.  This method worked, but would require
% adjustment of the parameter values, especially for large or very wide
% pacing spikes and this limited the ability to automatically process large
% batches of paced ECGs.  Additionally, large pacing spikes would cause
% issues with annotation.  The new method allows more robust detection of
% pacing spikes and then the additional option to remove them with
% interpolation.  Details are available in the BRAVEHEART user guide.

% Pacing spike identification, removal, and interpolation (v1.5.0)
if ap.cwt_spike_removal == 1
    
    % Generate new ECG12 with spikes removed/interpolated if they are found
    [batchout.ecg_raw_postinterp, batchout.pacer_spikes, batchout.lead_ispaced] = find_and_interpolate_pacing_spikes_12L(batchout.ecg_raw, ap, 0);
    
    % ECG without pacing spikes and with the spikes interpolated is stored
    % in ecg_raw_postinterp

    % If found some spikes and therefore interpolated the signal, will
    % also require that pacing spikes detected in # of leads specified in
    % Annoparams pacer_spike_num.  Can set this > 1 to minimze false positives
    % as would expect significant pacing spikes to be seen in > 1 lead in
    % general.  Adjusting the value of pacer_spike_num makes the pacemaker
    % spike detection more or less sensitive/specific.

    if ~isempty(batchout.ecg_raw_postinterp) && sum(cell2mat(struct2cell(batchout.lead_ispaced(:)))) >= ap.pacer_spike_num

        % Recreate VCG with new ecg without spikes
        batchout.vcg_raw_postinterp = VCG(batchout.ecg_raw_postinterp, ap);

        % Filter and transform to VCG after spikes removed and interpolated
        batchout.filtered_ecg = batchout.ecg_raw_postinterp.filter(NaN, ap);
        batchout.filtered_vcg = VCG(batchout.filtered_ecg, ap);

        % Here need to redetect R peaks on the interpolated signal.
        % This *replaces* the old way of looking just at peak widths as it
        % will be in general more robust to large pacing spikes. If
        % interpolation is disabled (ap.interpolate = 0) then will use
        % these peaks, but reset the signals to their non-interpolated
        % versions

        % Detect QRS peaks on filtered/spike removed/interpolated VCG
        QRS2 = batchout.filtered_vcg.peaks(ap);

        % if DO NOT want to remove and interpolate the pacing spikes
        if ap.interpolate == 0
            
            % if dont want to interpolate, now that have found the correct
            % QRS peaks on the interpolated signal (signal with spikes
            % removed), can restore the original ECG/VCG

            batchout.ecg_raw_postinterp = batchout.ecg_raw;
            batchout.vcg_raw_postinterp = batchout.vcg_raw;

            % Filter, transform post-filtering
            batchout.filtered_ecg = batchout.ecg_raw_postinterp.filter(NaN, ap);
            batchout.filtered_vcg = VCG(batchout.filtered_ecg, ap);

            % Dont redetect spikes here or will pick up the pacing spikes
            % which is not what you want!
        end


    % If NO pacing detected/interpolated - do nothing   
    else
            batchout.ecg_raw_postinterp = batchout.ecg_raw;
            batchout.vcg_raw_postinterp = batchout.vcg_raw;

            % Filter, transform post-filtering
            batchout.filtered_ecg = batchout.ecg_raw_postinterp.filter(NaN, ap);
            batchout.filtered_vcg = VCG(batchout.filtered_ecg, ap);

            % Detect QRS peaks on filtered VCG
            QRS2 = batchout.filtered_vcg.peaks(ap);        
    end   


else  % Spike detection is disabled - do nothing
    batchout.ecg_raw_postinterp = batchout.ecg_raw;
    batchout.pacer_spikes = [];
    batchout.lead_ispaced = [];

    % Filter, transform post-filtering
    batchout.filtered_ecg = batchout.ecg_raw_postinterp.filter(NaN, ap);
    batchout.filtered_vcg = VCG(batchout.filtered_ecg, ap);

    % Detect QRS peaks on filtered VCG
    QRS2 = batchout.filtered_vcg.peaks(ap);

end     % End pacing spike interpolation section


% Baseline correction for X, Y, Z if option checked
if ap.baseline_correct_flag

    % Baseline correct VCG
    vcg2 = batchout.filtered_vcg.baseline_shift(ap);
    
    % Baseline correct the 12L ECG (needed for GUI)
    [sL1, sL2, sL3, savR, savF, savL, sV1, sV2, sV3, sV4, sV5, sV6, ~, ~, ~, ~, ~,...
    ~, ~, ~, ~, ~, ~, ~] = ...
    baseline_shift_hfs(batchout.filtered_ecg.I, batchout.filtered_ecg.II, batchout.filtered_ecg.III, batchout.filtered_ecg.avR, batchout.filtered_ecg.avF, batchout.filtered_ecg.avL, ...
    batchout.filtered_ecg.V1, batchout.filtered_ecg.V2, batchout.filtered_ecg.V3, batchout.filtered_ecg.V4, batchout.filtered_ecg.V5, batchout.filtered_ecg.V6, batchout.filtered_ecg.hz, QRS_for_shift);

    batchout.filtered_ecg = ECG12(batchout.filtered_ecg.hz,'',sL1, sL2, sL3, savR, savF, savL, sV1, sV2, sV3, sV4, sV5, sV6);
        
else    % Don't baseline shift
    vcg2 = batchout.filtered_vcg;
end

batchout.NQRS_orig = length(QRS2);

batchout.hr_orig = 60000 / mean((diff(QRS2)*(1000/ecg_raw.hz))) ;  % HR from initial peak detection
%maxRR_hr_orig = (60000/vcg2.sample_time())*0.5/max(diff(QRS2)); % the 0.5 is for filtering stuff - no longer used

% If supply a beats class use these instead of annotating from scratch
if isa(ovrbeats, 'Beats')
    batchout.beats_final = ovrbeats; beats3 = ovrbeats; beats4 = ovrbeats;
else

  % Old Pacer spike detection based on width - generate new VCG with NaN masking of pacer spikes
    if ap.spike_removal
        QRS2_old = QRS2;
        [vcg3, ~] = vcg2.remove_pacer_spikes(QRS2, ap);
        QRS2 = vcg3.peaks(ap);
        
        % If the R peaks change with the spike width filter, then some
        % pacing spikes were detected.  To allow user to get this
        % information in the output, will assign batchout.lead_ispaced to
        % be a 1x12 vector of -1s.  This will be interpreted by AnnoResult
        % as pacing detected by the spike width filter rather than the CWT
        % spike filter
        if ~isequal(QRS2, QRS2_old) 
            lead_ispaced.I = -1;
            lead_ispaced.II = -1;
            lead_ispaced.III = -1;
            lead_ispaced.avR = -1;
            lead_ispaced.avL = -1;
            lead_ispaced.avF = -1;

            lead_ispaced.V1 = -1;
            lead_ispaced.V2 = -1;
            lead_ispaced.V3 = -1;
            lead_ispaced.V4 = -1;
            lead_ispaced.V5 = -1;
            lead_ispaced.V6 = -1;

            batchout.lead_ispaced = lead_ispaced;
        end     
    end

    
    % Annotate and fix intervals
    beats3_1 = Beats(vcg2, QRS2, ap);
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
        batchout.beats_final = beats4.delete(beats4.outlier,"outlier");
    else
        batchout.beats_final = beats4;
    end
end


% Median beat signals
% use VCG2 here, because you want to use the original VCG to generate the median beat.

[startb, endb] = batchout.beats_final.medianloc(vcg2, ap);

% is the median window too big?
medRR = median(diff(batchout.beats_final.QRS));
% RRfrac = round(ap.window_rrfrac * medRR);
% ind = ((endb - startb) > RRfrac);
% endb(ind) = startb(ind) + RRfrac;
% rrfrac_flag = any(ind);

[batchout.medianvcg1, batchout.beatsig_vcg] = vcg2.medianbeat(startb, endb);

% Find R peak of median VM signal
[~, medianQRS1] = max(batchout.medianvcg1.VM);

% adjust for possible pacer spike
if ap.spike_removal
    [medianvcg2, batchout.medianvcg1] = batchout.medianvcg1.remove_pacer_spikes(medianQRS1, ap);
else
    medianvcg2 = batchout.medianvcg1;
end
[~, medianQRS2] = max(medianvcg2.VM, [], 'omitnan'); % finds QRS peak of median VM beat

% NB STend is ignored when NQRS = 1
% annotate original median beat
% for NBeats = 1, STend is interpreted as an interval in samples rather than a %age
% a little clunky but the best way to do it maybe? idk
ap.STend = round(ap.STend * medRR/100);
batchout.medianbeat = Beats(batchout.medianvcg1, medianQRS2, ap);

% Correlation Test
batchout.correlation_test = median_fit(batchout.beatsig_vcg, batchout.medianbeat);

% Medians for 12L ECG
[batchout.median_12L, batchout.beatsig_12L] = batchout.filtered_ecg.medianbeat(startb, endb);

% Beat stats
batchout.beat_stats = Beat_Stats(batchout.beats_final, 1000/ecg_raw.hz);

batchout.filtered_vcg = vcg2;  

end         % End of If statement for if no ovrmedianbeats



% If specified a ovrmedianbeat, swap it for the variable medianbeat here
if ~isempty(ovrmedianbeat) && ~isempty(ovrmedianvcg) && ~isempty(ovrmedian12L) && ~isempty(ovrvcgbeatsig)
   batchout.medianvcg1 = ovrmedianvcg;
   batchout.median_12L = ovrmedian12L;
   beatsig = ovrvcgbeatsig;
   batchout.beats_final = ovrbeats;
   
   % Have to recalculate STend here
   medRR = median(diff(batchout.beats_final.QRS));
   ap.STend = round(ap.STend * medRR/100);
   
   % Annotate the median beat
   batchout.medianbeat = Beats(ovrmedianvcg, ovrmedianbeat.QRS, ap);
   
   % Recalc correlation
   batchout.correlation_test  = median_fit(beatsig, batchout.medianbeat);
   
   % Pull these HR metrics through since they dont change and therefore dont have to run the entire loop again   
   batchout.hr_orig = other.hr;
   batchout.NQRS_orig = other.NQRS_orig;
   
   % No output for these since they dont change   
   batchout.beatsig_vcg = [];
   batchout.beatsig_12L = [];
   batchout.beat_stats = [];
   %ecg_raw = [];
   batchout.vcg_raw = [];
   batchout.filtered_ecg = [];
   batchout.filtered_vcg = [];
end


% quality testing
batchout.quality = Quality(batchout.medianvcg1, ecg_raw, batchout.beats_final, batchout.medianbeat, ...
    batchout.hr_orig, batchout.NQRS_orig, batchout.correlation_test, batchout.noise, ap, qp);


if save_figures
    batchout.sumfig = figure('visible','off');

    subplot(7,1,[1 2 3])
    max_line = max(max([batchout.medianvcg1.X batchout.medianvcg1.Y batchout.medianvcg1.Z batchout.medianvcg1.VM]));
    min_line = min(min([batchout.medianvcg1.X batchout.medianvcg1.Y batchout.medianvcg1.Z batchout.medianvcg1.VM]));
   
    hold off;
    ppvm = plot(batchout.medianvcg1.VM, 'linewidth', 1.75, 'color', [0 0.4470 0.7410],'Displayname','VM');
    hold on;
    ppx = plot(batchout.medianvcg1.X', 'color', [ 0 0 0],'Displayname','X', 'linewidth', 1.25);
    ppy = plot(batchout.medianvcg1.Y', 'color', [0.8500 0.3250 0.0980],'Displayname','Y', 'linewidth', 1.25);
    ppz = plot(batchout.medianvcg1.Z', 'color', [0.9290 0.6940 0.1250],'Displayname','Z', 'linewidth', 1.25);
        
    line([0 length(batchout.medianvcg1.X')],[0 0], 'Color','black','LineStyle','--');
    ppdot = line([0 length(batchout.medianvcg1.X')],[0.05 0.05], 'Color','black','LineStyle',':', 'Displayname','0.05 mV'); 
    ppqon = line([batchout.medianbeat.Q batchout.medianbeat.Q],[min_line max_line],'Color','k','LineStyle','--', 'Displayname','QRS Start','linewidth', 1.15);
    ppqoff = line([batchout.medianbeat.S batchout.medianbeat.S],[min_line max_line],'Color','b','LineStyle','--', 'Displayname','QRS End','linewidth', 1.15);
    pptoff = line([batchout.medianbeat.Tend batchout.medianbeat.Tend],[min_line max_line],'Color','r','LineStyle','--', 'Displayname','Tend','linewidth', 1.15);
    line([0 length(batchout.medianvcg1.X')],[-0.05 -0.05], 'Color','black','LineStyle',':');
    text_string = sprintf('X / Y / Z Cross Correlation = %0.3f / %0.3f / %0.3f \nGood Quality Probability = %3.1f%% \nQRS = %i ms \nQT = %i ms', batchout.correlation_test.X,  batchout.correlation_test.Y,  batchout.correlation_test.Z, ...
       100*batchout.quality.prob_value, (batchout.medianbeat.S-batchout.medianbeat.Q)*(1000/batchout.medianvcg1.hz), (batchout.medianbeat.Tend-batchout.medianbeat.Q)*(1000/batchout.medianvcg1.hz)); 
    text(find(batchout.medianvcg1.VM == max(batchout.medianvcg1.VM)) + round(100*(batchout.medianvcg1.hz/1000)), 0.8*batchout.medianvcg1.VM(find(batchout.medianvcg1.VM == max(batchout.medianvcg1.VM))),text_string,'fontsize',8);
 
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
    scatter(batchout.beats_final.QRS,X(batchout.beats_final.QRS),12)
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
    scatter(batchout.beats_final.QRS,Y(batchout.beats_final.QRS),12)
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
    scatter(batchout.beats_final.QRS,Z(batchout.beats_final.QRS),12)
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
    scatter(batchout.beats_final.QRS,VM(batchout.beats_final.QRS),12);
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
    batchout.sumfig = [];
end


end




