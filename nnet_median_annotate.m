%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% nnet_median_annotate.m -- Annotate median beats with neural network
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


function [Q, S, T, Tend, flag, nan_count] = nnet_median_annotate(signal_full, debug)

signal = signal_full.VM;
signal_orig = signal;

% Disable warning when loading function handle
    warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');

% Default is 500 hz signal and 128 kaiser window
    freq = signal_full.hz;
    k=kaiser(128);
  
% If freq not = 500 resample to 500
    if freq ~= 500
       signal = resample(signal,500,freq);  
    end

% Flags for error checking
    flag = 0; 
    nan_count = 0;
    
% Load neural network for median beat annotation
    load('MedianAnnoNet')

% Process VM signal into freq-time domain
    vcg_fsst = cell(1,1);
    [s,f,~] = fsst(signal, 500, k);
    f_indices =  (f > 0.5) & (f < 40);
    vcg_fsst{1} = [real(s(f_indices,:)); imag(s(f_indices,:))]; 
    vcg_fsst = cellfun(standardizeFun,vcg_fsst,'UniformOutput',false);

% Process VM median beat through NNet and calculate
    [vcg_nnet, scores] = classify(MedianAnnoNet,vcg_fsst,'MiniBatchSize',24, 'SequenceLength','longest');

% Pull out the fiducial points from the scores/NNet output
[qonPred, qoffPred, toffPred, flag, nan_count] = extract_points(vcg_nnet);

% Assign final fiducial points
Q = qonPred;
S = qoffPred;
Tend = toffPred;

if ~isnan(Tend)
	try
        tpk_candidates = find(signal == max(signal(qoffPred+1:toffPred)));
        T = tpk_candidates(1);
    catch
        T = NaN;
    end
else
	T = NaN;
end
      
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


% Draw figure if set to debug
if debug == 1 
	%close(gcf);
	try % dont choke here
		plot_scores(signal, signal_orig, freq, scores, Q, S, T, Tend, Q_down, S_down, T_down, Tend_down);
	catch
    end 
end


% Re-enable warning
    warning('on', 'MATLAB:dispatcher:UnresolvedFunctionHandle');
	
end


function plot_scores(signal, signal_orig, freq, scores, Q, S, T, Tend, Q_down, S_down, T_down, Tend_down)
if freq ~= 500
	
	figure('name','Median Reannotation Fiducial Point Debug','numbertitle','off')
	subplot(1,2,1)
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
	
	line([Q_down Q_down],[0 1],'color','m', 'LineStyle', '-')
	line([S_down S_down],[0 1],'color','m', 'LineStyle', '-')
	line([Tend_down Tend_down],[0 1],'color','m', 'LineStyle', '-')
	
	yyaxis left
	text(Q_down, signal(Q_down), '[', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(S_down, signal(S_down), ']', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(T_down, signal(T_down), 'T', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(Tend_down, signal(Tend_down), '}', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	
	plot(signal,'Color', '[ 0 0.8 0]')
	
	hold off
	
	legend([s0 s1 s2])
	
	subplot(1,2,2)
	
	plot(signal_orig,'Color', '[ 0 0.8 0]')
	title(sprintf('Original Signal - %i Hz', freq))
	ylabel('VM Signal (mV)')
	xlabel('Samples')
	hold on
	
	text(Q, signal_orig(Q), '[', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(S, signal_orig(S), ']', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(T, signal_orig(T), 'T', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(Tend, signal_orig(Tend), '}', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	hold off
	
	set(gcf, 'Position', [10, 10, 1100, 400])  % set figure size
	
else
	
    figure('name','Median Reannotation Fiducial Point Debug','numbertitle','off')
    hold on
    plot(signal, 'Color', '[ 0 0.8 0]');
	yyaxis left
	
	ylabel('VM Signal (mV)')
	xlabel('Samples')

	yyaxis right
	ylabel('Fiducial Point Probabilities [0-1]')
	ylim([0 1.1])
	s0 = plot(scores{1}(1,1:end),'k','LineStyle', '--', 'Displayname',' Other');
	s1 = plot(scores{1}(2,1:end),'r','LineStyle', '--', 'Displayname',' QRS');
	s2 = plot(scores{1}(3,1:end),'b','LineStyle', '--', 'Displayname',' T');
	
	line([Q Q],[0 1],'color','m', 'LineStyle', '-')
	line([S S],[0 1],'color','m', 'LineStyle', '-')
	line([Tend Tend],[0 1],'color','m', 'LineStyle', '-')
	
	yyaxis left
	text(Q, signal(Q), '[', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(S, signal(S), ']', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(T, signal(T), 'T', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	text(Tend, signal(Tend), '}', 'FontSize', 16, 'Color', 'magenta', 'interpreter', 'none');
	hold off
	
	legend([s0 s1 s2])
end


end

	