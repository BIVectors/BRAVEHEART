%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% pacer_spike_removal.m -- Deal with pacemaker spikes
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


function [endspike_locs, spikes_removed_signal] = ...
    pacer_spike_removal(signal, QRS_peak, mfthresh, spike_width, MF_length)

% short median filter to look for pacing spikes
% pass in Rpeaks detected by findpeaksecg
% function uses a very narrow MF to measure the width of the peak
% that was detected
[widths, ~, ~, start_qrs, end_qrs, ~] = qrs_width_est(signal, QRS_peak, mfthresh, MF_length, 0);

% setup paced variable (0 if beat does not have significant pacing
% artifact and 1 if beat does have significant pacing artifact.
% This does NOT detect veyr small pacing spikes, but is designed to
% prevent anno from crashing due to seeing very large pacing spikes
% that it thinks are the QRS complexes
paced = widths < spike_width;  % if peak width < 30 ms = pacing artifact

% delete spikes for paced complexes
spikes_removed_signal = signal;

endspike_locs = zeros(sum(paced), 1);
for t = 1:length(widths)
    if paced(t)
        % location of the end of the pacing spikes
        %endspike_locs(t) = waveEndPk(signal, QRS_peak(t), QRS_peak(t) + max_spike_width);
        
        if QRS_peak(t)+spike_width <= length(signal)
            [~, endspike_locs(t)] = min(signal(QRS_peak(t) : QRS_peak(t)+spike_width));
        else 
            [~, endspike_locs(t)] = min(signal(QRS_peak(t) : end));
        end
        
        endspike_locs(t) = endspike_locs(t) + QRS_peak(t)-1;
        
        spikes_removed_signal(start_qrs(t):end_qrs(t))=NaN;

    end
end

endspike_locs(endspike_locs==0) = [];
if ~iscolumn(endspike_locs); endspike_locs = endspike_locs'; end

end

