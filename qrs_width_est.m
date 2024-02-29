%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% qrs_width_est.m -- Estimate QRS with as part of first pass annotation
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


function [width, qrwidth, rswidth, start_qrs, end_qrs, removed_beats] = ...
    qrs_width_est(signal, rpeaks, threshold, mf_length, debug)

% signal =  signal to process
% rpeaks = vector with Rpeak locations (in samples)
% threshold = find the width of the signal at threshold% of the Rpeak (0-100)
% debug = creates figure of relevant points if set to 1
% filter_length = length of median filter (in samples)

Np = length(rpeaks);
start_qrs = zeros(Np, 1); end_qrs = zeros(Np, 1);
width = zeros(Np, 1); qrwidth = zeros(Np, 1); rswidth = zeros(Np, 1);
% median filter to avoid rapid fluctuations below threshold inside the QRS
filt_signal = medfilt1(signal,mf_length);
threshold = threshold/100;

for i = 1:length(rpeaks)
    
    maxpeak_loc = rpeaks(i);
    maxpeak_val = filt_signal(maxpeak_loc);
    thresh = threshold*maxpeak_val;
    
    % find all points that are above threshold in the filtered signal
    above_thresh_pts = filt_signal > thresh;
    
    % find where indicator goes from 0 to 1 and 1 to 0
    % these points are the crossing points
    indicator = diff(above_thresh_pts);
    pos_indicator = find(indicator == 1);
    neg_indicator = find(indicator == -1);
    
    
    % need to avoid the T wave crossting threshold...
    % start of QRS is the first point where indicator goes from 0 to 1
    
    % want to restrict the start points it can choose from to those that are
    % before rpeak(i)
    
    % find the positive crossings before QRS
    p = max(pos_indicator(pos_indicator < maxpeak_loc));
    if isempty(p)
        start_qrs(i) = nan;
    else
        % the start is the last pos_indicator before QRS
        start_qrs(i) = p;
    end
    
    % find first index in neg_indicator where the index is > maxpeak_loc
    q = min(neg_indicator(neg_indicator > maxpeak_loc));
    if isempty(q)
        end_qrs(i) = nan;
    else
        end_qrs(i) = q;
    end
    
    width(i) = end_qrs(i) - start_qrs(i);
    qrwidth(i)= maxpeak_loc - start_qrs(i);
    rswidth(i) = end_qrs(i) - maxpeak_loc;
    
end


% remove indices with a NaN in them (beats without a start and end detected
% due to being close to the start/end of the signal

start_nan_index = isnan(start_qrs);
end_nan_index = isnan(end_qrs);
removed_beats = start_nan_index | end_nan_index;

width( removed_beats) = [];
start_qrs( removed_beats) = [];
end_qrs( removed_beats) = [];
qrwidth( removed_beats) = [];
rswidth( removed_beats) = [];
rpeaks( removed_beats) = [];


% draw figure if debug = 1
if debug
    
%     figure
%     plot(signal,'r')
%     hold on
    
    scatter(start_qrs,signal(start_qrs),'filled','MarkerEdgeColor',[0.9290 0.6940 0.1250],'MarkerFaceColor',[0.9290 0.6940 0.1250])
    scatter(end_qrs,signal(end_qrs),'filled','MarkerEdgeColor',[0.9290 0.6940 0.1250],'MarkerFaceColor',[0.9290 0.6940 0.1250])
    %scatter(rpeaks,signal(rpeaks),'k')
    for i=1:length(rpeaks)
    line([start_qrs(i) end_qrs(i)], [signal(rpeaks(i))*threshold signal(rpeaks(i))*threshold],'Color',[0.9290 0.6940 0.1250],'linewidth',1.5)
        %text(rpeaks(i)+20, signal(rpeaks(i)), num2str(width(i)))
    end
    %hold off
    
    
    
end

end
