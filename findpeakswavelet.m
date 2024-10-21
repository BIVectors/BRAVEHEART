%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% findpeakswavelet.m -- Find R peaks using wavelet filtered signals 
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

function [QRS, QRS_wavelet, R] = findpeakswavelet(VM, maxbpm, freq, pkthresh, wavelet)

% Max level of wavelet decomposition based on signal length
max_lvl = floor(log2(length(VM)));

% Get freq bands for decomposition at each level (col 1 lower bound,
% col2 upper bound)
fc = zeros(max_lvl,2);

for i = 1:max_lvl
    fc(i,2) = freq / (2^i);
    fc(i,1) = freq / (2^(i+1));
end

fc(max_lvl,1) = 0;

% Want to keep frequencies 10-40 Hz which should capture most of QRS energy
% without T wave (<10 Hz)
Fa = 40;
Fb = 10;

% Find closest value to 40 in upper bound of freq cutoffs
U = fc(:,2) - Fa;

% Take smallest positive value so dont undercut the freq band
U(U<0) = nan;
[~,idxU] = min(U);

% Find closest value to 10 in lower bound of freq cutoffs
L = fc(:,1) - Fb;

% Take smallest postive value so dont undercut the freq band
L(L<0) = nan;
[~,idxL] = min(L);

% Decompose signal to max level using MODWT
% Signal is mirrored to reduce edge effects
M = modwt(mirror(VM), max_lvl, wavelet);

% Reconstruct using only the coefficients in levels between idxL and idxU
% and then square the resultant signal (R)
Mrecon = zeros(size(M));
Mrecon(idxU:idxL,:) = M(idxU:idxL,:);
R = imodwt(Mrecon,wavelet);
R = abs(R).^2;
R = middlethird(R);

% Find peaks in the reconstructed signal which will be estimates of the
% actual R peaks.

q = quantile(R, 100);

[~, QRS_wavelet] = findpeaks(R, ...
    'MinPeakHeight', q(pkthresh), 'MinPeakDistance', round(freq*60/maxbpm));

% Now have to use the peaks in the wavelet signal as an estimate of where
% to search for true peaks in VM since the max in the wavelet
% reconstruction is not always going to correlate exactly with the max in
% each QRS complex in VM

% Open a window of 100 ms on each side of each peak detected in the wavelet
% reconstruction signal
win_len = 100;
w = round(win_len * freq / 1000);
QRS = zeros(1,length(QRS_wavelet));

for i = 1:length(QRS_wavelet)
    ll = QRS_wavelet - w;
    ul = QRS_wavelet + w;

    % Prevent indices from being out of bounds for QRS complexes near
    % start/end of signal

    ll(ll<0) = 1;
    ul(ul>length(VM)) = length(VM);

    % Just take maximum as should only be 1 peak
    [~,QRS(i)] = max(VM(ll(i):ul(i)));
    
    % Correct indexing
    QRS(i) = QRS(i) + ll(i) - 1;

end

debug = 0;
if debug
    q1 = quantile(abs(VM), 100);
    q2 = quantile(abs(R), 100);
    
    s = max(VM)/max(R);
    R=R*s;
    
    figure
    plot(R)
    hold on
    plot(VM)
    scatter(QRS_wavelet,R(QRS_wavelet))
    scatter(QRS, VM(QRS))
    
    line([0 length(VM)],[q(pkthresh)*s q(pkthresh)*s])
    %line([0 5000],[q2(95) q2(95)])
    
end


end