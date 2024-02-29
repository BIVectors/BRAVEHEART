%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% tcrt_width_est.m -- QRS width estimate as used to calcualte TCRT
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


function [width, qrwidth, rswidth, start_qrs, end_qrs] = tcrt_width_est(signal, rpeak, fidpts, threshold, debug)

% Finds the first point before and after rpeak that are within the QRS
% complex and cross below threshold

% signal =  signal to process
% rpeaks = vector with Rpeak locations (in samples)
% threshold = find the width of the signal at threshold% of the Rpeak (0-1)
% debug = creates figure of relevant points if set to 1

start_qrs = zeros(1, 1); end_qrs = zeros(1, 1);
width = zeros(1, 1); qrwidth = zeros(1, 1); rswidth = zeros(1, 1);

maxpeak_loc = rpeak;
maxpeak_val = signal(maxpeak_loc);
thresh = threshold*maxpeak_val;

% find all points that are above threshold in the filtered signal
above_thresh_pts = signal >= thresh;
below_thresh_pts = signal < thresh;

% Indices of points in signal that are below threshold
idx_below = find(below_thresh_pts==1);

% Remove points outside QRS duration
idx_below(idx_below < fidpts(1) | idx_below > fidpts(3)) = [];

% Find temporal distance between rpeak and all idx_below
dist = rpeak - idx_below;
dist_pos = dist;
dist_pos(dist_pos < 0) = [];
dist_neg = dist;
dist_neg(dist_neg > 0) = [];

% Neg is to right, Pos is to left based on how did difference
qrwidth = min(dist_pos);
rswidth = abs(max(dist_neg));

% Output of function
start_qrs = rpeak - qrwidth;
end_qrs = rpeak + rswidth;
width = end_qrs - start_qrs;


    
% draw figure if debug = 1
if debug
    
%     figure
%     plot(signal,'r')
%     hold on
    
    scatter(start_qrs,signal(start_qrs),'filled','MarkerEdgeColor',[0.9290 0.6940 0.1250],'MarkerFaceColor',[0.9290 0.6940 0.1250])
    scatter(end_qrs,signal(end_qrs),'filled','MarkerEdgeColor',[0.9290 0.6940 0.1250],'MarkerFaceColor',[0.9290 0.6940 0.1250])
    %scatter(rpeaks,signal(rpeaks),'k')
    for i=1:length(rpeaks)
    line([start_qrs(i) end_qrs(i)], [signal(rpeaks(i))*threshold signal(rpeaks(i))*threshold])
        %text(rpeaks(i)+20, signal(rpeaks(i)), num2str(width(i)))
    end
    %hold off
    
end

end
