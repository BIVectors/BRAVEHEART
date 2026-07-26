%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% nnet_median_annotatev2.m -- Annotate median beats with neural network v2
% Copyright 2016-2026 Hans F. Stabenau and Jonathan W. Waks
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


function [Q, S, T, Tend, flag, nan_count, sum_se] = nnet_median_annotateV2(signal_full, env, debug)

% Default flag values
% flag : if there is a confidence issue with predictions (viterbiDecode had
% to change something)
% nan_count : one or more fiducial points was not found
flag = 0;
nan_count = 0;

signal = signal_full.VM;
signal_orig = signal;

% Disable warning when loading function handle
    warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');

% Default is 500 hz signal
    freq = signal_full.hz;
  
% If freq not = 500 resample to 500
    if freq ~= 500
       signal = resample(signal,500,freq);  
    end

% Filter signal with 100 hz LPF
filterFreq = 100;
[filt_b, filt_a] = butter(4, filterFreq/(500/2), 'low');
signal_filt = filtfilt(filt_b, filt_a, signal);

% Get filtered signal mean and SD
mu = mean(signal_filt);
s  = std(signal_filt);
    if s < 0.01
        s = 1;
    end

% Normalize signal
signal_filt = (signal_filt - mu) ./ s;

%MedianAnnoNet_v2_run_003_k3-7-15-63_f100_u256_do30_20260419_182512;
NN = load("MedianAnnoNetV2.mat");

% Predict raw scores and classification catagories
[~, scores] = classify(NN.MedianAnnoNetV2_net, {signal_filt'}, 'ExecutionEnvironment', env);
%scores = predict(medianannov2, {signal_filt'}, 'ExecutionEnvironment', env);

% Pass probabilities through Viterbi algorithm to deal with multiple
% possible fiducial points.  At the end there should be 1 Qon, 1 Qoff, and
% 1 Toff assuming there is only 1 QRST complex and the signal is not cut off
[YClean, vmod] = viterbiDecode(scores{1});
YClean = YClean';

% vmod = 1 indicates that the Viterbi algorithm had to intervene
if vmod == 1
    flag = 1;
end

% Extract the fiducial points
[Q, S, Tend, validpts] = extractFiducialPoints(YClean);

% Increment NaN counter if points not found
if ~validpts.Qon 
    nan_count = nan_count + 1;
end
    
if ~validpts.Qoff 
    nan_count = nan_count + 1;    
end

if ~validpts.Tend
    nan_count = nan_count + 1;    
end


% Find T peak
if ~isnan(Tend)
	try
        tpk_candidates = find(signal == max(signal(S+1:Tend)));
        T = tpk_candidates(1);
    catch
        T = NaN;
        nan_count = nan_count + 1;
    end
else
	T = NaN;
    nan_count = nan_count + 1;
end

% Now deal with signals that are not at 500 hz
Q_down = Q;
S_down = S;
T_down = T;
Tend_down = Tend;

% Need to assign points differently if the 500 Hz median beat was due to
% downsampling or upsampling, because if UPsampled to get to 500 Hz median
% and an interpolated point is chosen as a fiducial point, this point does
% not directly map onto the orignal signal.  If the sampling frequency of
% the original signal is > 500 Hz and the signal was DOWNsampled to create
% a 500 Hz median beat to pass into the NN, then the point chosen on the
% median should exist on the original signal (with slight exception for
% sampling frequencies that are not multiples of 500 Hz like 997 Hz, but in
% these cases the error should be small since you actually downsampled the
% original signal to get the median).  This issue was fixed in v1.0.2

if freq ~= 500
	Q = resamp_loc(500, freq, Q);
	S = resamp_loc(500, freq, S);
	T = resamp_loc(500, freq, T);
	Tend = resamp_loc(500, freq, Tend);
end

% Shannon Entropy -- add eps to avoid log 0
pOther = scores{1}(1,:);
pQRS = scores{1}(2,:);
pT = scores{1}(3,:);

se = -(pOther .* log(pOther + eps) + ...
       pQRS .* log(pQRS + eps) + ...
       pT .* log(pT + eps));

sum_se = sum(se);


 % Draw figure if set to debug
if debug == 1 
	%close(gcf);
	try % dont choke here
		plot_scores(signal, signal_orig, freq, scores, YClean, Q, S, T, Tend, Q_down, S_down, T_down, Tend_down);
    catch ME
    end 
end


% Re-enable warning
    warning('on', 'MATLAB:dispatcher:UnresolvedFunctionHandle');
	
end % end main function


function plot_scores(signal, signal_orig, freq, scores, YClean, Q, S, T, Tend, Q_down, S_down, T_down, Tend_down)

pOther = scores{1}(1,:);
pQRS = scores{1}(2,:);
pT = scores{1}(3,:);

% Shannon Entropy -- add eps to avoid log 0
se = -(pOther .* log(pOther + eps) + ...
       pQRS .* log(pQRS + eps) + ...
       pT .* log(pT + eps));

sum_se = sum(se);


if freq ~= 500
	
	F = figure('name','Median Reannotation Fiducial Point Debug','numbertitle','off','SizeChangedFcn',{@move_button});
    set(gcf, 'Position', center_gui_figure(1200, 700));  % set figure size
	ax1 = subplot(7,2,[1 3 5 7 9]);
	title('Resampled Signal - 500 Hz')
	yyaxis left
	
	ylabel('VM Signal (mV)')
	xlabel('Samples')
	hold on
	yyaxis right
	ylabel('Fiducial Point Probabilities [0-1]')
	ylim([0 1.1])
	s0 = plot(scores{1}(1,1:end),'k','LineStyle', '--', 'Displayname',' Other');
	s1 = plot(scores{1}(2,1:end),'r','LineStyle', '--', 'Displayname',' QRS');
	s2 = plot(scores{1}(3,1:end),'b','LineStyle', '--', 'Displayname',' T');

    % Final classes before and after Viterbi decoder
    [~, collapsed_scores] = max(scores{1}, [], 1);
    score_orig = plot(collapsed_scores-1,'k','Linestyle','-','linewidth',4,'Marker','none','Visible','off','Displayname', sprintf('Raw\nClasses'));
    score_fixed = plot(double(YClean)-1,'r','Linestyle','-','linewidth',2.5,'Marker','none','Visible','off','Displayname',sprintf('Viterbi\nCorrected'));

    yyaxis left
    if ~isnan(Q_down)
	    line([Q_down Q_down],[0 1],'color','m', 'LineStyle', '-')
        t1 = text(Q_down, signal(Q_down), '[', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end

    if ~isnan(S_down)
	    line([S_down S_down],[0 1],'color','m', 'LineStyle', '-')
        t2 = text(S_down, signal(S_down), ']', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end

    if ~isnan(T_down)
        t3 = text(T_down, signal(T_down), 'T', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end

    if ~isnan(Tend_down)
	    line([Tend_down Tend_down],[0 1],'color','m', 'LineStyle', '-')
        t4 = text(Tend_down, signal(Tend_down), '}', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end

	plot(signal,'Color', '[ 0 0.8 0]')
	
	hold off
	
    % Viterbi vs Scores toggle button
    vbutton = uicontrol('Parent',F,'Style','pushbutton','String','Classification','Units','pixels', ...
     'FontWeight','bold','Position',[1100 660 90 30],'Visible','on','Callback', @(src,evt) ...
      toggleViterbi(score_orig, score_fixed, s0, s1, s2, ax1));

	legend([s0 s1 s2])
	
	ax2 = subplot(7,2,[2 4 6 8 10]);
	
	plot(signal_orig,'Color', '[ 0 0.8 0]')
	title(sprintf('Original Signal - %i Hz', freq))
	ylabel('VM Signal (mV)')
	xlabel('Samples')
	hold on
	
	t1 = text(Q, signal_orig(Q), '[', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	t2 = text(S, signal_orig(S), ']', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	t3 = text(T, signal_orig(T), 'T', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	t4 = text(Tend, signal_orig(Tend), '}', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	hold off

    ax3 = subplot(7,2,13);
    title(sprintf('Shannon Entropy (SE) - Sum = %.1f nats', sum_se),'FontSize',11)
    yyaxis left
    plot(cumsum(se))
    ylim([0 1.1*sum(se)])
    ylabel('\SigmaSE','color',[0 0.45 0.74])
	xlabel('Samples')

    yyaxis right
    plot(se)
    ylabel('SE','color',[0.85, 0.325, 0.098])
    ylim([0 log(2)])
    yticks([0 log(2)])
    yticklabels({'0','0.69'})
	
    sgtitle('Median Reannotation Fiducial Point Debug','fontweight','bold')
    
	
else
	
    F = figure('name','Median Reannotation Fiducial Point Debug','numbertitle','off','SizeChangedFcn',{@move_button});
    set(gcf, 'Position', center_gui_figure(650, 700));  % set figure size
    ax1 = subplot(7,1,1:5);
    hold on
    plot(signal, 'Color', '[ 0 0.8 0]');
    title('Median Reannotation Fiducial Point Debug')
	yyaxis left
	
	ylabel('VM Signal (mV)')
	xlabel('Samples')

	yyaxis right
	ylabel('Fiducial Point Probabilities [0-1]')
	ylim([0 1.1])
	s0 = plot(scores{1}(1,1:end),'k','LineStyle', '--', 'Displayname',' Other');
	s1 = plot(scores{1}(2,1:end),'r','LineStyle', '--', 'Displayname',' QRS');
	s2 = plot(scores{1}(3,1:end),'b','LineStyle', '--', 'Displayname',' T');

    % Final classes before and after Viterbi decoder
    [~, collapsed_scores] = max(scores{1}, [], 1);
    score_orig = plot(collapsed_scores-1,'k','Linestyle','-','linewidth',4,'Marker','none','Visible','off','Displayname', sprintf('Raw\nClasses'));
    score_fixed = plot(double(YClean)-1,'r','Linestyle','-','linewidth',2.5,'Marker','none','Visible','off','Displayname',sprintf('Viterbi\nCorrected'));
	
    yyaxis left
    if ~isnan(Q)
	    line([Q Q],[0 1],'color','m', 'LineStyle', '-')
        t1 = text(Q, signal(Q), '[', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end

    if ~isnan(S)
	    line([S S],[0 1],'color','m', 'LineStyle', '-')
        t2 = text(S, signal(S), ']', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end

    if ~isnan(T)
        t3 = text(T, signal(T), 'T', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end

    if ~isnan(Tend)
	    line([Tend Tend],[0 1],'color','m', 'LineStyle', '-')
        t4 = text(Tend, signal(Tend), '}', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
    end


    % Viterbi vs Scores toggle button
    vbutton = uicontrol('Parent',F,'Style','pushbutton','String','Classification','Units','pixels', ...
     'FontWeight','bold','Position',[550 660 90 30],'Visible','on','Callback', @(src,evt) ...
      toggleViterbi(score_orig, score_fixed, s0, s1, s2, ax1));
    

	hold off
	legend(ax1, [s0 s1 s2])

    
    ax2 = subplot(7,1,7);
    title(sprintf('Shannon Entropy (SE) - Sum = %.1f nats', sum_se),'FontSize',11)
    yyaxis left
    plot(cumsum(se))
    ylim([0 1.1*sum(se)])
    ylabel('\SigmaSE','color',[0 0.45 0.74])
	xlabel('Samples')

    yyaxis right
    plot(se)
    ylabel('SE','color',[0.85, 0.325, 0.098])
    ylim([0 log(2)])
    yticks([0 log(2)])
    yticklabels({'0','0.69'})

end


end  % end plotscores


% Toggle Viterbi vs score display function
function toggleViterbi(score_orig, score_fixed, s0, s1, s2, ax)
 
    vis = ~strcmp(score_orig.Visible,'on');

    % Toggle categories and move text labels
    set([score_orig score_fixed], 'Visible', vis);
    if vis
        yyaxis(ax, 'right');
        ax.YLim = [0 2.2];   
        legend(ax,[s0 s1 s2 score_orig score_fixed])
    else
        yyaxis(ax, 'right');
        ax.YLim = [0 1.1];   % original
        legend(ax,[s0 s1 s2])
    end
end


