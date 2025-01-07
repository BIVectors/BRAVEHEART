%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% resamp_loc.m -- Map fiducial points between resampled signals
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

function idx = resamp_loc(fa, f0, sa)

% fa is the frequency of the signal that was annotated (usually at 500 Hz)
% f0 is the frequency of the original signal before resampling (to 500 Hz)
% sa is the index of the selected fiducial point in the annotated signal (500 Hz)

% For example, if use an ECG that is sampled at 1000 Hz, it will be
% downsampled to 500 Hz for NN annotation, fa = 500, and f0 = 1000.
% If used an ECG that is sampled at 250 Hz, it will be upsampled to 500 Hz
% for NN annotation, fa = 500, and f0 = 250.

% For the current implementation of BRAVEHEART, fa = 500

% Each sample has distance of 1/freq

if isnan(sa) || isempty(sa)
    idx = nan;
    return
end

% Distance to the selected point in the annotated signal (starting from sample 1)
Da = (sa-1)/fa;

% Want to find the index of the point in the new signal that is closest to Da
idx = round(f0*Da)+1;

% This will round DOWN when a point is equidistant from 2 points on the
% original signal.

end