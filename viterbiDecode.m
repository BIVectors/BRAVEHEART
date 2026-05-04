%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% viterbiDecode.m -- Viterbi decoder for MedianAnnoNetV2 probabilities
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

function [YPred_clean, wasModified] = viterbiDecode(probs)
    % probs is numStates x T matrix of softmax outputs (3 x T)
    % States: row 1 = other (0), row 2 = QRS (1), row 3 = Twave (2)
    
    [numStates, T] = size(probs);
    
    % Log-probability transition matrix (-Inf = forbidden)
    % Rows = from state, cols = to state
    logTrans = [0    0    -Inf;   % from 0: allow 0->0, 0->1
                -Inf 0    0;      % from 1: allow 1->1, 1->2
                0    -Inf 0];     % from 2: allow 2->0, 2->2
    
    % Log emissions (add small epsilon to avoid log(0))
    logEmit = log(probs + 1e-10);  % still 3 x T
    
    % Initialize: force start in state 0
    score = -Inf(numStates, T);
    score(1, 1) = logEmit(1, 1);  % must start in state 0
    backptr = zeros(numStates, T);
    
    % Forward pass
    for t = 2:T
        for s = 1:numStates
            % score(:, t-1) is 3x1, logTrans(:, s) is 3x1 - both column vectors
            [bestScore, bestPrev] = max(score(:, t-1) + logTrans(:, s));
            score(s, t) = bestScore + logEmit(s, t);
            backptr(s, t) = bestPrev;
        end
    end
    
    % Backward pass: recover optimal path
    path = zeros(T, 1);
    [~, path(T)] = max(score(:, T));
    for t = T-1:-1:1
        path(t) = backptr(path(t+1), t+1);
    end
    
    % Convert to 0-indexed and to categorical
    YPred_clean_num = path - 1;
    YPred_clean = categorical(YPred_clean_num, [0 1 2], {'0','1','2'});
    
    % Compare to argmax to determine if modified
    [~, argmaxPath] = max(probs, [], 1);  % argmax across rows (states)
    argmaxPath = argmaxPath(:) - 1;  % make column, 0-indexed
    wasModified = any(argmaxPath ~= YPred_clean_num);
end