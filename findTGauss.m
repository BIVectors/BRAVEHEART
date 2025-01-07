%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% findTGauss.m -- Find T wave end using tangent or baseline methods
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

function [T, off] = findTGauss(fs, fsprime, fspp, baseline_est, startw, endw, Tendstr,debug)
    % [T, Toff] = findTGauss(fs, fsprime, baseline_est, Tstartw, Tendw, Tendstr)
    % find onset, peak, offset of P or T wave
    % Fit a generalized gaussian and then check specified method
    
    off = [];
    baseline = baseline_est;

    % Find T-wave peak and initial guess for T-end
    [T, off1] = findT(fs, fsprime, fspp, baseline_est, startw, endw, debug);
    if ~any(T); return; end
    if debug; text(off1, fs(off1), '*', 'Color', 'magenta', 'FontSize', 16); end

%    halfmax = find(abs(fs(T:endw)) < 0.5*abs(fs(T)), 1, 'first') - 1;

    % Set fitting parameters
%     fo = fitoptions('Method', 'NonlinearLeastSquares', ...
%     'Lower', [1.0 -Inf], 'StartPoint', [2.0 halfmax], ...
%     'TolFun', 0.0001, 'TolX', 0.0001);
% 
%     ft = fittype('exp(-(x/c)^b)', ...
%     'independent', 'x', 'coefficients', {'b', 'c'}, 'options', fo);

    x = (off1:endw)';
    try m1 = polyfit(x, fs(x), 1); catch return; end
    x = (T:endw)';
    base1 = m1(1)*x + m1(2);
    if debug; plot(x, base1, 'Color', 'red'); end
    baseline(x) = base1;
   
    try f1 = waveFitGauss(fs, baseline, T, endw); catch return; end
    %f1 = waveFitGauss(fs, baseline, T, endw);
    try off2 = baselineTangentIntersect(T, endw, f1, m1, baseline, false, debug); catch return; end

    %c = coeffvalues(f1);
    %b = c(1); s = c(2);
    %var1 = a^2*2^(1-1/b)*s*gamma(1+1/b);
    %SNR = var1/noise^2;
    %if SNR < 5
    %    T = [];
    %    return;
    %end
    
%     x = (T:offguess)';
%     [dmax, loc] = findpeaks(conc*fsprime(x), 'SortStr', 'descend');
%     mt = conc*dmax(1);
%     xt = loc(1) + T-1;
%     yt = fs(xt);
%         
%     x = (T:endw)';
%     plot(x, mt*(x-xt) + yt, 'Color', 'red');
%     
    x = (off2:endw)';
    yhat1 = f1(1) * exp( -( (x-T)/f1(3)^2 ).^f1(2) );
    try m2 = polyfit(x, fs(x) - yhat1, 1); catch return; end
    x = (T:endw)';
    base2 = m2(1)*x + m2(2);
    if debug; plot(x, base2, 'Color', 'red', 'LineWidth', 2); end
    baseline(x) = base2;
    
    %off = round( (yt/mt - m(1)/mt - xt)/(m(2)/mt - 1) );

    f2 = waveFitGauss(fs, baseline, T, endw);
    %yhat = f2(x-T)+baseline(x);
    yhat2 = f2(1) * exp( -( (x-T)/f2(3)^2 ).^f2(2) );
    if debug; plot(x, yhat2 + base2, 'Color', 'magenta'); end
    try off1 = baselineTangentIntersect(T, endw, f2, m2, baseline, true, debug); catch return; end
    switch lower(Tendstr)
        case 'tangent'
            off=off1;
        case 'baseline'
            off = baselineSignalIntersect(fs, baseline, off1, endw);
        otherwise
            error('Expected "Tangent" or "Baseline" for Tendmethod, got %s\n.', Tendstr);
    end
end

function off = baselineSignalIntersect(fs, baseline, off1, endw)
    s = sign(fs(off1) - baseline(off1));
    off = find(sign(fs(off1:endw)-baseline(off1:endw)) ~= s, 1) +off1-1;

end


% function off = baselineTangentTouch(a, T, endw, f, m, baseline)
%     c = coeffvalues(f);
%     b = c(1); sigma = c(2);
% 
%     x = (T:endw)';
%     xt = T + sigma * ( (b-1)/b )^(1/b);
%     mt = -a/sigma * (b-1)^(1-1/b) * b^(1/b) * exp(1/b - 1);
%     yt = a*exp(1/b-1) + baseline(round(xt));
%     plot(x, mt*(x-xt) + yt, 'Color', 'red');
%     
%     off1 = round( (yt/mt - m(1)/mt - xt)/(m(2)/mt - 1) );
%     
%     off = find(abs(a*f(off1-T:endw-T)) < 0.1, 1) + off1;
% end

function off = baselineTangentIntersect(T, endw, f, m, baseline, p, debug)
    % c = coeffvalues(f);
    a = f(1); b = f(2); sigma = f(3)^2;

    x = (T:endw)';
    xt = T + sigma * ( (b-1)/b )^(1/b);
    mt = -a/sigma * (b-1)^(1-1/b) * b^(1/b) * exp(1/b - 1);
    yt = a*exp(1/b-1) + baseline(round(xt));
    if p && debug; plot(x, mt*(x-xt) + yt, 'Color', 'red'); end

    off = round( (yt/mt - m(2)/mt - xt)/(m(1)/mt - 1) );
end

function f = waveFitGauss(fs, baseline, peak, endw)
% [s, basenew] = waveEndGauss(signal, fs, baseline, peak, endw)
% fit a modified gaussian to a given peak location
% fit a new baseline to the residual
% return where the max deriv tangent hits the new baseline
% return new baseline estimate on peak:endw

x = (peak:endw)';
y = fs(x) - baseline(x);
xx = x-peak;
y0 = fs(peak) - baseline(peak);
s0 = sqrt((peak-length(x))/2);

fun = @(a) sqrt( sum((y - a(1)*exp(-(xx/a(3)^2).^a(2))) .^2) );
start = [y0, 2, s0];
f = fminsearch(fun, start);
end