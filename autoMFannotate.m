%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% annoMFannotate.m -- First pass heuristic annotations
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

function [Q, QRS, S, T, Tend] = autoMFannotate(signal, QRS, QRsamp, endspikes, RSsamp, STstartsamp, ...
    STendsamp, Tendstr, autoMF, filter_width, autoMF_thresh, freq, debug)
% QRS: indices of peaks in signal
% endspikes: vector, location of pacing spikes if present
% then either specify:
% QRsamp: vector, optional, specify the number of samples before each QRS to set the annotation window
% RSsamp: vector, optional, specify the number of samples after each QRS to set the annotation window
% STstartsamp, STendsamp: analogous to above
% or:
% autoMF: flag, try to estimate annotation windows automatically
% autoMF_thresh: median filtering threshold % to estimate QRS width
% filter_width: width of the median filter
% other parameters passed through to autoMF.

% if windows aren't specified, autoMFannotate tries to set sensible detection windows around each QRS.
% These detection windows are used as guardrails for the heuristic QRS annotator, annoMF
% this is done by using a median filter to estimate the width of each QRS


if isrow(QRS); QRS=QRS'; end
if isrow(QRsamp); QRsamp = QRsamp'; end
if isrow(RSsamp); RSsamp = RSsamp'; end

hz=freq;
NQRS = length(QRS);
STstart(1:NQRS) = STstartsamp;
% if NQRS == 1
%     %STend = NaN; % ignored for NQRS = 1
% else
     STend(1:NQRS) = STendsamp;
% end

% Debug figure for median beat
if debug
    if length(QRS) == 1
        figure(figure('name',' Median Beat Annotation Fiducial Point Debug','numbertitle','off'));
        hold off;
        %plotind = min([15*handles.vcg.hz, 100000, length(handles.vcg.VM)]);
        plot(signal, 'Color', '[ 0 0.8 0]');
        hold on;
    end
end


if autoMF % try to automatically set windows
    [widths, ~, ~, ~, ~, removed_beats] = qrs_width_est(signal, QRS, autoMF_thresh, filter_width, debug);
    QRS(removed_beats) = [];
    STend(removed_beats) = [];
    STstart(removed_beats) = [];
    
    %    medw = round(median(widths));
    widths(widths*1000/hz < 60) = round(60 * hz/1000); % minimum 60ms
    RSsamp = widths;
    QRsamp = widths;
end

% set start and end windows for QRS complex
qrs_start = QRS-QRsamp;
qrs_start(qrs_start < 1) = 1;
if ~isempty(endspikes)
    for i = 1:length(QRS) % adjust qrs_start if paced complexes present
        spike_ind = find(abs(qrs_start(i) - endspikes) < QRS(i) - qrs_start(i), 1);
        if ~isempty(spike_ind)
            qrs_start(i) = endspikes(spike_ind)-1;
        end
    end
end
qrs_end = QRS + RSsamp;

% full ECG annotation
%[Q, QRS, S, T, Tend] = annoCL(signal, QRS, RSsamp, QRsamp, CLsamp, STstartsamp, STend, Tendstr, hz, debug);
[Q, QRS, S, T, Tend] = annoMF(signal, QRS, qrs_start, qrs_end, STstart, STend, Tendstr, ...
    filter_width, autoMF_thresh, debug);

end
