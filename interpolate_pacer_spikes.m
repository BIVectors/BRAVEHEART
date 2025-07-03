%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% interpolate_pacer_spikes.m -- interpolate pacing spikes
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
 
function spikeless = interpolate_pacer_spikes(signal, x1, x2, MF_length)
spikeless = signal;
N = length(signal);

% tau changes shape of curve, should be < 1
tau=0.1;

y1 = signal(x1);
y2 = signal(x2);

% Now shift x1 and x2 to relative values to avoid overflow in cosh
xx1 = 1;
xx2 = x2 - x1 + 1;

% cosh interpolation from Harvey and Noheria
alpha = (y2-y1)/(cosh(tau*xx2)-cosh(tau*xx1));
beta = y1-alpha*cosh(tau*xx1);
gamma = xx1:xx2;
delta = alpha*cosh(tau*gamma) + beta;

% overwrite pacing spike(s)
spikeless(x1:x2) = delta;

% median filter to smooth out this area
if (x1-MF_length < 1); return; end
if (x2+MF_length > N); return; end

%spikeless(x1-MF_length:x2+MF_length) = medfilt1(spikeless(x1-MF_length:x2+MF_length), MF_length);
%spikeless(x1:x2) = medfilt1(spikeless(x1:x2), MF_length);

end

    
