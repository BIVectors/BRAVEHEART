%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% baseline_shift_hfs.m -- Physiological baseline correction
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

function [L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6, baseline_L1, baseline_L2, baseline_L3, baseline_avR, baseline_avF,...
    baseline_avL, baseline_V1, baseline_V2, baseline_V3, baseline_V4, baseline_V5, baseline_V6] = ...
    baseline_shift_hfs(L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6, freq, QRS)

if iscolumn(L1); L1=L1'; end
if iscolumn(L2); L2=L2'; end
if iscolumn(L3); L3=L3'; end
if iscolumn(avR); avR=avR'; end
if iscolumn(avL); avL=avL'; end
if iscolumn(avF); avF=avF'; end
if iscolumn(V1); V1=V1'; end
if iscolumn(V2); V2=V2'; end
if iscolumn(V3); V3=V3'; end
if iscolumn(V4); V4=V4'; end
if iscolumn(V5); V5=V5'; end
if iscolumn(V6); V6=V6'; end


sample_time = 1000/freq;

ECG = [ L1; L2; L3; avR; avF; avL; V1; V2; V3; V4; V5; V6];
ECG_orig = [ L1; L2; L3; avR; avF; avL; V1; V2; V3; V4; V5; V6];

% % transform to a VM lead to allow easy estimation of R peaks for use later
% [~,~,~,VM] = ecgtransform(L1, L2, V1, V2, V3, V4, V5, V6, transform_matrix); 
% 
% 
% % find peaks
N = max(size(ECG));
% QRS = findpeaksecg(VM, maxBPM, freq, pkthresh)';
NQRS = length(QRS);


% framelength must be odd for savitzky-golay
framelen=round(0.1*N/NQRS); if mod(framelen, 2)==0; framelen=framelen+1; end
order=4;
[~,g] = sgolay(order, framelen);

median_shift = zeros(12,1);
for k = 1:12  % for all 12 leads
    signal = ECG(k,QRS(1):QRS(end));
    
% 
%                     % Exclude 100 ms window after Rpeak
%                     for i = 1:NQRS-1
%                     signal(QRS(i):QRS(i)+100/sample_time) = nan;  
%                     end
% 
%                     % Exclude 40 ms window before Rpeak (excluding first beat)
%                     for i = 2:NQRS
%                     signal(QRS(i)-40/sample_time:QRS(i)) = nan;  
%                     end 
%     
    
    
    dx = abs(conv(signal, -g(:,2), 'same'));
    %    startb = QRS(1:end-1);
    %    endb = QRS(2:end);
    %    for i = 1:NQRS-1
    %    seg = signal(startb(i):endb(i));
    %    dseg = dx(startb(i):endb(i));
    seg = signal;
    dseg = dx;
    % dx2 = conv(medianseg, 2 * g(:,3), 'same');
    
    % find indices where slope and slope2 are both minimal  (less than 10th% ile)
    %small = prctile(dx,10));
    small = max(dseg)/50;
    ind = dseg < small;
        
    %     % this is the start index of each consecutive run in ind
    % consec = diff(ind)==1;
    %     start_regions = ind(diff(consec)==1);
    %     end_regions = ind(diff(consec)==-1);
    %     [len, longest] = max(diff(end_regions-start_regions));
    %     longest_region = medianseg(
    
    % shift is median of region where deriv is small
    median_shift(k) = median(seg(ind)); 
end

L1 = ECG(1,:)-median_shift(1);
% figure
% hold on;
% plot(L1, 'color', 'blue'); plot(L1+median_shift(1), 'color', 'green');

L2 = ECG(2,:)-median_shift(2);
L3 = ECG(3,:)-median_shift(3);

avR = ECG(4,:)-median_shift(4);
avF = ECG(5,:)-median_shift(5);
avL = ECG(6,:)-median_shift(6);

V1 = ECG(7,:)-median_shift(7);
V2 = ECG(8,:)-median_shift(8);
V3 = ECG(9,:)-median_shift(9);
V4 = ECG(10,:)-median_shift(10);
V5 = ECG(11,:)-median_shift(11);
V6 = ECG(12,:)-median_shift(12);



baseline_L1 = median_shift(1);
baseline_L2 = median_shift(2);
baseline_L3 = median_shift(3);

baseline_avR = median_shift(4);
baseline_avF = median_shift(5);
baseline_avL = median_shift(6);

baseline_V1 = median_shift(7);
baseline_V2 = median_shift(8);
baseline_V3 = median_shift(9);
baseline_V4 = median_shift(10);
baseline_V5 = median_shift(11);
baseline_V6 = median_shift(12);
end
