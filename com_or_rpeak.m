%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% com_or_rpeak.m -- Find center of QRST complex for beat alignment
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

function R = com_or_rpeak(QRS, signal, hz, ap)
N = length(QRS);
switch ap.align_flag
    case 'CoV'
        R = zeros(N, 1);
        [~, ~, ~, start_qrs, end_qrs, ~] = ...
            qrs_width_est(signal, QRS, ap.cov_thresh, ap.cov_mf_samp(hz), false);
        for i = 1:N
            R(i) = center_of_mass(signal(start_qrs(i):end_qrs(i))) + start_qrs(i)-1;
        end
    case 'Rpeak'
        R = QRS;
    otherwise
        error('Unknown align_flag in Beats: %s', ap.alight_flag);
end
end

