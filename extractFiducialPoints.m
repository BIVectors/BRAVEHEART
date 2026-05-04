%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% extractFiducialPoints.m -- Extract fiducial points from MedianAnnoNetV2 catagories
% Copyright 2016-2026 Hans F. Stabenau and Jonathan W. Waks
% This function authored by John Roberts (https://github.com/jlrjr)
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

function [Qon, Qoff, Tend, valid] = extractFiducialPoints(YPred_clean)

% Assumes sequence has already been processed by viterniDecode.m
% so transitions follow: Other(0) -> QRS(1) -> Twave(2) -> Other(0)
%
% INPUTS:
%   YPred_clean   categorical [1 x T] with classes '0', '1', '2'
%
% OUTPUTS:
%   Qon           sample index of QRS onset  (0->1 transition)
%   Qoff          sample index of QRS offset (1->2 transition)
%   Tend          sample index of T wave end (2->0 transition)
%   valid         struct with logical flags: valid.Qon, valid.Qoff, valid.Tend

% Initialise outputs
Qon  = NaN;
Qoff = NaN;
Tend = NaN;

valid.Qon  = false;
valid.Qoff = false;
valid.Tend = false;

% Convert to numeric for transition detection
Y = str2double(string(YPred_clean));   % [1 x T] numeric
d = diff(Y);                           % [1 x T-1] sample-to-sample differences

% Find transitions

% Qon: first 0->1 transition (diff = +1, coming from state 0)
qon_idx = find(d == 1 & Y(1:end-1) == 0);
if ~isempty(qon_idx)
    Qon       = qon_idx(1) + 1;   % +1 because diff is offset by 1 sample
    valid.Qon = true;
end

% Qoff: first 1->2 transition (diff = +1, coming from state 1)
qoff_idx = find(d == 1 & Y(1:end-1) == 1);
if ~isempty(qoff_idx)
    Qoff       = qoff_idx(1);
    valid.Qoff = true;
end

% Tend: first 2->0 transition (diff = -2)
tend_idx = find(d == -2);
if ~isempty(tend_idx)
    Tend       = tend_idx(1);
    valid.Tend = true;
end

% Sanity check - points must be physiologically ordered Qon < Qoff < Tend
if valid.Qon && valid.Qoff && valid.Tend
    if ~(Qon < Qoff && Qoff < Tend)
        warning('extractFiducialPoints: Disordered points Qon=%d Qoff=%d Tend=%d - returning NaN', ...
            Qon, Qoff, Tend);
        Qon  = NaN;  Qoff = NaN;  Tend = NaN;
        valid.Qon  = false;
        valid.Qoff = false;
        valid.Tend = false;
    end
end

end