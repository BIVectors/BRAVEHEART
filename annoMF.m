%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% annoMF.m -- First pass heuristic annotations
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

function [Q, newQRS, S, T, Tend] = annoMF(signal, QRS, qrs_start, qrs_end, ...
    STstart, STend, Tendstr, width_filter, width_threshold, debug)
% [Q, newQRS, S, T, Tend] = annoMF(signal, QRS, qrs_end, qrs_start, STstart, STend, Tendstr, debug)
% Heuristic annotation for vector magnitude signals derived from the ECG
% signal: filtered signal.
% QRS: locations of QRS-complex peaks (R-waves).
% qrs_start and qrs_end are the guardrails for the wave-onset/offset algorithms.
% These are absolute locations in the signal.
% STstart: blanking interval in samples after R-wave before T-wave search window
% STend is in ms, and is the end of the T-end search window from the R wave
% Tendstr: which algorithm to use for Tend. Supported are 'baseline', 'tangent', or 'energy'
% width_filter: median filter length in samples for peak width estimation
% width_threshold: what % of peak height do you use to start looking for peak start/end
%%%
% No denoising is done in anno. Untested on signals that are not strictly-positive.
% uses median filter
% Small q or s waves are searched for in the region QR/5 and RS/5 from the
% MF-determined wave boundaries, respectively
% If Q or S wave boundary is not found, that wave boundary is set to R-QRwidth or
% R+RSwidth respectively

% row/column vector nonsense
if ~iscolumn(signal); signal = signal'; end
if ~iscolumn(QRS); QRS = QRS'; end

% check that we got vectors
if length(QRS) ~= length(qrs_end) || length(QRS) ~= length(qrs_start) ... 
    || length(QRS) ~= length(STstart) || length(QRS) ~= length(STend)
    error('input vectors must have length = QRS vector');
end

N = numel(signal);
fs = signal; 
% 5-point stencil derivatives
fsprime = deriv5(fs, 't');
fspp = deriv2nd5(fs, 't');

% median filter estimation of QRS width
% bpm beats / 1 min * 1 min / 60s * 1 s / hz samples => [beats/sample] =>
% (bpm / 60 / hz)^-1 [samples/beat]
[~, ~, ~, startmed, endmed, removed] = qrs_width_est(fs, QRS, width_threshold, width_filter, debug);
QRS(removed) = [];
qrs_end(removed) = [];
qrs_start(removed) = [];
NQRS = numel(QRS);

RRint = N/NQRS;
Q = zeros(NQRS,1); S= zeros(NQRS,1); T= zeros(NQRS,1); Tend= zeros(NQRS,1);
j=1;
k=1;
baseline_est = zeros(N,1);
for i=1:NQRS
    R = QRS(i);
    Rmag = fs(R);
%     if i==1; thisRR = RRint; else; thisRR = R - Rprev; end
%     Rprev = R;
%     RRint = (thisRR + 4*RRint)/5;
     if debug
         text(R, Rmag*1.1, 'QRS', 'interpreter', 'none');
         text(R, Rmag, 'R', 'interpreter', 'none');
     end

    % define search windows for QRS-complex waves:
    startw = qrs_start(i);
    endw  = qrs_end(i);

    if endw > N; break; end
    if startw < 1
        k=k+1;
        continue;
    end
    
    if debug
        text(startw, fs(startw), '|', 'FontSize', 16, 'Color', 'blue', 'interpreter', 'none');
        text(endw, fs(endw), '|', 'FontSize', 16, 'Color', 'blue', 'interpreter', 'none');
    end

    qrswin = (startw:endw)';
    if isempty(fs(qrswin)); continue; end
    
    ss = startmed(i);
    ee = endmed(i);
    
    if ss < startw; ss = startw+1; end
    if ee > endw; ee = endw-1; end
    
    
    % is there another + QR peak within window / 8?
    QRw = R-startw;
    qstart = max([ss-round(QRw/4) startw]);
    if ss-qstart >= 3
        [~, qp] = findpeaks(fs(qstart:ss));
        qp = qp + qstart - 1;
    else
        qp = [];
    end
    if any(qp) % pick the last one
        qpk = qp(end);
        ss = qpk;
    end
    % don't look for S-wave wiggle
%     send = ee+round(RSwidth/5);
%     [~, sp] = findpeaks(fs(ee:send));
%     sp = sp + ee - 1;
%     if any(sp)
%         spk = sp(1);
%         ee = spk;
%     end    

    s1 = waveStart2(fsprime, R, startw, ss);
    s2 = waveStartPk(fs, fspp, startw, ss);
    s = max([s1 s2]);

    % are we already past the minimum of the S-wave?
    [~, minS] = min(fs(R:endw));
    minS = minS + R-1;
    if minS <= ee % dont go too crazy looking for S wiggles
        e = ee;
    else
        e1 = waveEnd2(fsprime, R, ee, endw);
        e2 = waveEndPk(fs, ee, endw);
        e = min([e1 e2]);
    end
    
    if ~any(s); s=startw; end
    if ~any(e); e=endw; end
     
    if debug
        text(s, fs(s), '[', 'FontSize', 16, 'Color', 'm', 'interpreter', 'none');
        text(e, fs(e), ']', 'FontSize', 16, 'Color', 'm', 'interpreter', 'none');
    end  
    
    % using the wavestart/end3 strategy
%     s1 = waveStart2(fsprime, R, R-QRwidth, ss);
%     s2 = waveStartPk3(fs, fspp, R, R-QRwidth, ss);
%     e1 = waveEnd2(fsprime, R, ee, R+RSwidth);
%     e2 = waveEndPk3(fs, fspp, R, ee, R+RSwidth);
%     s = max([s1 s2]); e = min([e1 e2]);
% 
%     if debug
%         text(s, fs(s), '[', 'FontSize', 16, 'Color', 'black', 'interpreter', 'none');
%         text(e, fs(e), ']', 'FontSize', 16, 'Color', 'black', 'interpreter', 'none');
%     end
%     
    
    Tstartw = e + STstart(i);
    Tendw = e + STend(i);
	if Tendw > N && NQRS==1; Tendw = N; end
    %if NQRS==1; Tendw=N-1; end % helps with median beat annotation
	if Tendw > N; break; end
    
    % if (Tendw-Tstartw < Twidth); continue; end
    if debug
        text(Tstartw, fs(Tstartw), '(', 'FontSize', 16, 'Color', 'blue', 'interpreter', 'none');
        text(Tendw, fs(Tendw), ')', 'FontSize', 16, 'Color', 'blue', 'interpreter', 'none');
    end
    
    % Don't update our estimate of the noise locally
    % it seems like the estimate from the whole EKG is more robust
    % noise = 1.4826*mad(residual(Tstartw:Tendw), 1);
%    [T, Toff] = findT2ndB(fs, fsprime, fspp, Tstartw, Tendw, baseline_est, noise);
    
    
    if strcmpi(Tendstr, 'baseline') || strcmpi(Tendstr, 'tangent')
        [TT, TToff] = findTGauss(fs, fsprime, fspp, baseline_est, Tstartw, Tendw, Tendstr, debug);
    elseif strcmpi(Tendstr, 'energy')
        
         %TT = findTenergy(fs, fsprime, Tstartw, Tendw, hz, debug);
         [~, TT] = max(fs(Tstartw:Tendw)); TT = TT + Tstartw-1;
		 if isempty(TT)
			 TT = NaN;
			 TToff = NaN;
		 else
			 if debug; text(TT, fs(TT), 'T', 'FontSize', 16, 'Color', 'red', 'interpreter', 'none'); 
             ylabel('VM Signal (mV)')
             xlabel('Samples')
             end
			 TToff = energyoff(fs, fsprime, TT, Tendw, R, RRint, debug);
		 end
    else
        error('Expected "Energy", "Tangent", or "Baseline" for Tendstr, got %s\n.', Tendstr);
    end
    if isempty(TToff); TToff=NaN; end
    if debug && ~isnan(TToff); text(TToff, fs(TToff), '}', 'FontSize', 16, 'Color', 'red', 'interpreter', 'none'); end
    
    Q(j)=s; 
    QRS(j)=R; 
    S(j)=e; 
    T(j)=TT; 
    Tend(j)=TToff;
    
    j=j+1;
    
end

Q = Q(k:j-1);
newQRS = QRS(k:j-1);
S = S(k:j-1);
T = T(k:j-1);
Tend = Tend(k:j-1);

% Check to make sure arent too close to the start or end of the signal
% after annotation complete -- eg if Qon = 1 or Tend = legnth of signal 
% its likely that there is an issue with that beat

if Q(1) == 1 
    Q(1) = [];
    S(1) = [];
    T(1) = [];
    Tend(1) = [];
    newQRS(1) = [];    
end

if Tend(end) == N 
    Q(end) = [];
    S(end) = [];
    T(end) = [];
    Tend(end) = [];
    newQRS(end) = [];    
end


end


% 
% function clip = madclip(signal, m)
% 
% med = median(signal);
% thresh = m*1.4826*mad(signal, 1);
% clip = signal;
% ind = abs(signal-med) > thresh;
% clip(ind) = med + sign(signal(ind)) * thresh;
% 
% end

