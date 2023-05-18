%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% ecgfilter.m -- ECG Filtering
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


function [L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6, final_lf_wavelet_lvl_min] = ...
    ecgfilter(L1, L2, L3, avR, avF, avL, V1, V2, V3, V4, V5, V6, freq, maxRR_hr, ...
    wavelet_filt, wavelet_level, wavelet_name, wavelet_filt_lf, wavelet_level_lf, wavelet_name_lf)



final_lf_wavelet_lvl_min = 'N/A';  % if dont use LF wavelet filter to remove noise

% LOW FREQ FILTERING WITH WAVELET TRANSFORM 
if wavelet_filt_lf == 1

    [L1, aL1, lvl_L1] = wander_remove(freq, maxRR_hr, mirror(L1), wavelet_name_lf, wavelet_level_lf);
    [L2, aL2, lvl_L2] = wander_remove(freq, maxRR_hr, mirror(L2), wavelet_name_lf, wavelet_level_lf);
    [L3, aL3, lvl_L3] = wander_remove(freq, maxRR_hr, mirror(L3), wavelet_name_lf, wavelet_level_lf);
    L1 = middlethird(L1);
    L2 = middlethird(L2);
    L3 = middlethird(L3);
    aL1 = middlethird(aL1);
    aL2 = middlethird(aL2);
    aL3 = middlethird(aL3);

    [avR, aavR, lvl_avR] = wander_remove(freq, maxRR_hr, mirror(avR), wavelet_name_lf, wavelet_level_lf);
    [avL, aavL, lvl_avL] = wander_remove(freq, maxRR_hr, mirror(avL), wavelet_name_lf, wavelet_level_lf);
    [avF, aavF, lvl_avF] = wander_remove(freq, maxRR_hr, mirror(avF), wavelet_name_lf, wavelet_level_lf);
    avR = middlethird(avR);
    avL = middlethird(avL);
    avF = middlethird(avF);
    aavR = middlethird(aavR);
    aavL = middlethird(aavL);
    aavF = middlethird(aavF);

    [V1, aV1, lvl_V1] = wander_remove(freq, maxRR_hr, mirror(V1), wavelet_name_lf, wavelet_level_lf);
    [V2, aV2, lvl_V2] = wander_remove(freq, maxRR_hr, mirror(V2), wavelet_name_lf, wavelet_level_lf);
    [V3, aV3, lvl_V3] = wander_remove(freq, maxRR_hr, mirror(V3), wavelet_name_lf, wavelet_level_lf);
    [V4, aV4, lvl_V4] = wander_remove(freq, maxRR_hr, mirror(V4), wavelet_name_lf, wavelet_level_lf);
    [V5, aV5, lvl_V5] = wander_remove(freq, maxRR_hr, mirror(V5), wavelet_name_lf, wavelet_level_lf);
    [V6, aV6, lvl_V6] = wander_remove(freq, maxRR_hr, mirror(V6), wavelet_name_lf, wavelet_level_lf);
    V1 = middlethird(V1);
    V2 = middlethird(V2);
    V3 = middlethird(V3);
    V4 = middlethird(V4);
    V5 = middlethird(V5);
    V6 = middlethird(V6);
    aV1 = middlethird(aV1);
    aV2 = middlethird(aV2);
    aV3 = middlethird(aV3);
    aV4 = middlethird(aV4);
    aV5 = middlethird(aV5);
    aV6 = middlethird(aV6);   

final_lf_wavelet_lvl_min = lvl_L1;

end


% HIGH FREQ FILTERING WITH WAVELET TRANSFORM
if wavelet_filt == 1
    
    L1 = wden(L1,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    L2 = wden(L2,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    L3 = wden(L3,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    avR = wden(avR,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    avL = wden(avL,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    avF = wden(avF,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    V1 = wden(V1,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    V2 = wden(V2,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    V3 = wden(V3,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    V4 = wden(V4,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    V5 = wden(V5,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    V6 = wden(V6,'modwtsqtwolog','s','mln',wavelet_level,wavelet_name);
    
end



end            
 
 


