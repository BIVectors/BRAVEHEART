%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% rs_values.m -- Calculate wave measrements on ECG lead
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

function [r_wave, r_wave_loc, s_wave, s_wave_loc, rs_wave, rs_ratio, sr_ratio, jpt, jpt60] = rs_values(signal,fidpts,hz,endspike)

% If have a NaN value report values as NaN to prevent throwing error

if ~isnan(fidpts(1)) && ~isnan(fidpts(3))

    % Need to deal with possibility that the signal between qpt and spt
    % will contain a large pacing spike.

    % Check if endspike exists
    % if so, Nan out the signal from 1:endspikes
    if ~isempty(endspike)
        signal(1:endspike) = NaN;
    end

    
    qpt = fidpts(1);
    rpt = fidpts(2);
    spt = fidpts(3);

    pos_signal = signal;
    neg_signal = signal;

    pos_signal(pos_signal<0) = NaN;
    neg_signal(neg_signal>=0) = NaN;


    [r_wave r_wave_loc] = max(pos_signal(qpt:spt));

    % convert to ms
    % subtract 1 sample since sample 1 = 0 ms at qpt because searched on
    % interval qpt:spt
    r_wave_loc = (r_wave_loc-1) * round(1000/hz);

    if length(r_wave) > 1
        r_wave = r_wave(1);
        r_wave_loc = r_wave_loc(1);
    end

    if isnan(r_wave)
       r_wave = 0;
       r_wave_loc = NaN;
    end

    [s_wave s_wave_loc] = min(neg_signal(qpt:spt));

    % convert to ms
    % subtract 1 sample since sample 1 = 0 ms at qpt because searched on
    % interval qpt:spt
    s_wave_loc = (s_wave_loc-1) * round(1000/hz);

    if length(s_wave) > 1
       s_wave = s_wave(1); 
       s_wave_loc = s_wave_loc(1);
    end

    if isnan(s_wave)
       s_wave = 0; 
       s_wave_loc = NaN;
    end

    % rs_wave (always positive):
    if r_wave ~= 0 && s_wave ~= 0
        rs_wave = r_wave - s_wave;
    elseif s_wave == 0
        rs_wave = r_wave;
    else
        rs_wave = abs(s_wave);
    end


    rs_ratio = r_wave/rs_wave;   % r:r+s ratio
    sr_ratio = abs(s_wave)/rs_wave;   % s:r+s ratio  


    % J point voltage
    jpt = signal(spt);
    
    % J pt + 60 voltage
    % Determine how many samples is 60 ms
    ms60 = round(60 * hz / 1000); 
    jpt60 = signal(spt+ms60);
    
else % If have NaNs it messes everything up
    
    r_wave = NaN;
    r_wave_loc = NaN;
    s_wave = NaN;
    s_wave_loc = NaN;
    rs_wave = NaN;
    rs_ratio = NaN;
    sr_ratio = NaN;
    jpt = NaN;
    jpt60 = NaN;
end

