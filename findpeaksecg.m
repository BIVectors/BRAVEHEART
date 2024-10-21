%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% findpeaksecg.m -- Find R peaks
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

function QRS = findpeaksecg(VM, maxbpm, freq, pkthresh, filter)

if filter == 1
    [QRS, ~, ~] = findpeakswavelet(VM, maxbpm, freq, pkthresh, 'sym4');
else
    q = quantile(abs(VM), 100);
    [~, QRS] = findpeaks(abs(VM), ...
        'MinPeakHeight', q(pkthresh), 'MinPeakDistance', round(freq*60/maxbpm));
end

% QRS = QRS';
% 
% QRS
%QRS2

% figure
% hold on
% plot(VM)
% scatter(QRS,VM(QRS))
% scatter(QRS2,VM(QRS2))


end