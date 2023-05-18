%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% wander_remove.m -- high pass filtering
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


function [signal_nowander, approx_signal, lvl] = wander_remove(freq, hr, signal, wavelet_name_lf, wavelet_level_lf)

% set level to 0 if doing automatic level detection based on HR frequency

num_samples = length(signal);
max_lvl = ceil(log2(num_samples));  % max level of wavelet decomposition based on signal length


%1D wavelet decomposition using specified wavelet and max_lvl levels   
    [A,D]=wavedec(signal,max_lvl,wavelet_name_lf); 


if wavelet_level_lf >0  % user specified level
       n = wavelet_level_lf;
end


% auto determines the appropriate level for each lead based on the frequency of the HR
% removes frequencies lower than HR frequency
if wavelet_level_lf == 0  

    freq_c = hr/60;  % HR frequency cutoff
    
    n=ceil(log2((freq/2)/freq_c)); % choose level that removes all freq below HR freq

end


% wavelet reconstruction using wavelet and level specified by user.  
% levels 8-10 seem to work well and correspond to freq of respiration in most ppl    
% this gives the approximation at level n approximation as the estimate of the baseline wander (A_signal)

    approx_signal=wrcoef('a',A,D,wavelet_name_lf,n);
    
  
% subtract baseline wander from original signal
    signal_nowander = signal-approx_signal;
    lvl = n;