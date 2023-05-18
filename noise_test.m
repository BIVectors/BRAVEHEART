%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% noise_test.m -- Estimate noise in ECG signal
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


function [sig_noise_ratio, hf_noise_flag, hf_noise_matrix, hf_noise_min, lf_noise_var, lf_noise_flag, lf_noise_matrix, lf_noise_max] = ...
            noise_test(ecg_raw, hf_thresh, lf_thresh, aps)

highpass_value = aps.highpass; % Save highpass value in aps for use later
aps.highpass = 0; % Temporarily turn off highpass to avoid triggering detection of HF noise due to LF wander in noise signal
ecg_filtered = ecg_raw.filter(NaN, aps);

maxRR_hr = 30;  % Placeholder -- doesnt do anything.

% generate measure of noise defined as raw ECG - lvl 5 LPF filtered ECG
L1 = ecg_raw.I;
L2 = ecg_raw.II;
L3 = ecg_raw.III;
avR = ecg_raw.avR;
avF = ecg_raw.avF;
avL = ecg_raw.avL;
V1 = ecg_raw.V1;
V2 = ecg_raw.V2;
V3 = ecg_raw.V3;
V4 = ecg_raw.V4;
V5 = ecg_raw.V5;
V6 = ecg_raw.V6;

L1_noise = L1-ecg_filtered.I;
L2_noise = L2-ecg_filtered.II;
L3_noise = L3-ecg_filtered.III;
avR_noise = avR-ecg_filtered.avR;
avF_noise = avF-ecg_filtered.avF;
avL_noise = avL-ecg_filtered.avL;
V1_noise = V1-ecg_filtered.V1;
V2_noise = V2-ecg_filtered.V2;
V3_noise = V3-ecg_filtered.V3;
V4_noise = V4-ecg_filtered.V4;
V5_noise = V5-ecg_filtered.V5;
V6_noise = V6-ecg_filtered.V6;

sig_noise_ratio = [snr(L1,L1_noise) snr(L2,L2_noise) snr(L3,L3_noise) snr(avR,avR_noise) snr(avL,avL_noise) snr(avF,avF_noise)...
    snr(V1,V1_noise) snr(V2,V2_noise) snr(V3,V3_noise) snr(V4,V4_noise) snr(V5,V5_noise) snr(V6,V6_noise)];

hf_noise_flag = sig_noise_ratio;

% If snr_thresh <1 the change from values to 1s and 0s will break -
% but no reason that would set the snr_thrshold <1 so wont change this ...

% For snr_thresh, *higher* values are *less* sensitive to noise
hf_noise_flag(hf_noise_flag < hf_thresh) = 1;
hf_noise_flag(hf_noise_flag >= hf_thresh) = 0;
hf_noise_matrix = hf_noise_flag;
hf_noise_flag = sum(hf_noise_flag);
hf_noise_min = min(sig_noise_ratio);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assess low frequency noise

% Will filter at around 1-2 Hz and look at the basline signal below this
% freq.  If use higher levels may miss HF noise, and can't just use the
% typical filtering params because this usually fileters <0.5 Hz, and if
% has higher freq baseline wander will miss it.

% Calculate the level needed to get close to 2 Hz:
% cutoff freq = (f/2) / (2^lvl)
% so lvl = ceil(log2(f/(2*cutoff freq))
% for f = 500 Hz, cutoff = 2 Hz; lvl = 7
% for f = 1000 Hz, cutoff = 2 Hz; lvl = 8

freq = ecg_raw.hz;
cutoff = 2;          % Hz
lvl = ceil(freq/ (2*cutoff));

aps.highpass = lvl; % Revert highpass filter on/off to original settings

% lvl 0 filtering is auto level selection based on maxRR_hr
[~, aL1o, ~] = wander_remove(freq, maxRR_hr, L1, aps.wavelet_name_highpass, 0);
[~, aL2o, ~] = wander_remove(freq, maxRR_hr, L2, aps.wavelet_name_highpass, 0);
[~, aL3o, ~] = wander_remove(freq, maxRR_hr, L3, aps.wavelet_name_highpass, 0);

[~, aavRo, ~] = wander_remove(freq, maxRR_hr, avR, aps.wavelet_name_highpass, 0);
[~, aavLo, ~] = wander_remove(freq, maxRR_hr, avL, aps.wavelet_name_highpass, 0);
[~, aavFo, ~] = wander_remove(freq, maxRR_hr, avF, aps.wavelet_name_highpass, 0);

[~, aV1o, ~] = wander_remove(freq, maxRR_hr, V1, aps.wavelet_name_highpass, 0);
[~, aV2o, ~] = wander_remove(freq, maxRR_hr, V2, aps.wavelet_name_highpass, 0);
[~, aV3o, ~] = wander_remove(freq, maxRR_hr, V3, aps.wavelet_name_highpass, 0);

[~, aV4o, ~] = wander_remove(freq, maxRR_hr, V4, aps.wavelet_name_highpass, 0);
[~, aV5o, ~] = wander_remove(freq, maxRR_hr, V5, aps.wavelet_name_highpass, 0);
[~, aV6o, ~] = wander_remove(freq, maxRR_hr, V6, aps.wavelet_name_highpass, 0);

%lf_noise_mad = 100* [ mad(aL1o) mad(aL2o) mad(aL3o) mad(aavRo) mad(aavFo) mad(aavLo) mad(aV1o) mad(aV2o) mad(aV3o) mad(aV4o) mad(aV5o) mad(aV6o)];
% don't include III, avL, avF, avR
%lf_noise_mad = [ mad(aL1o) mad(aL2o) mad(aL3o) mad(aavRo) mad(aavLo) mad(aavFo) mad(aV1o) mad(aV2o) mad(aV3o) mad(aV4o) mad(aV5o) mad(aV6o)];
lf_noise_var = [ var(aL1o) var(aL2o) var(aL3o) var(aavRo) var(aavLo) var(aavFo) var(aV1o) var(aV2o) var(aV3o) var(aV4o) var(aV5o) var(aV6o)];

% for lf_threshold, higher values are less sensitive to wander
lf_noise_flag = lf_noise_var;
lf_noise_flag(lf_noise_flag < lf_thresh) = 0;  % zero always stays below lf_threshold
lf_noise_flag(lf_noise_flag >= lf_thresh) = 1;
lf_noise_matrix = lf_noise_flag;
lf_noise_flag = sum(lf_noise_flag);
lf_noise_max= max(lf_noise_var);

aps.highpass = highpass_value; % Revert highpass filter on/off to original settings


end