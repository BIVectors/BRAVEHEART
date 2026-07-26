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

% Updated to 4 states 

function [YPred_clean, wasModified] = viterbiDecode(probs)
    % probs is 3 x T softmax outputs.
    % Original classes: row 1 = other (0), row 2 = QRS (1), row 3 = Twave (2)
    %
    % Expanded (non-cyclic) state space (4 states):
    %   1 = pre   (baseline before QRS), emits class 0
    %   2 = QRS,                         emits class 1
    %   3 = T,                           emits class 2
    %   4 = post  (baseline after T),    emits class 0

    [~, T] = size(probs);
    numStates = 4;

    % Log-prob transition matrix (rows = from, cols = to; -Inf = forbidden)
    logTrans = [0    0    -Inf -Inf;   % pre  -> pre, QRS
                -Inf 0    0    -Inf;   % QRS  -> QRS, T
                -Inf -Inf 0    0;      % T    -> T, post
                -Inf -Inf -Inf 0];     % post -> post

    % Log emissions: pre and post both emit class 0
    eps0 = 1e-10;
    logEmit = zeros(numStates, T);
    logEmit(1,:) = log(probs(1,:) + eps0);  % pre  -> class 0
    logEmit(2,:) = log(probs(2,:) + eps0);  % QRS  -> class 1
    logEmit(3,:) = log(probs(3,:) + eps0);  % T    -> class 2
    logEmit(4,:) = log(probs(1,:) + eps0);  % post -> class 0

    % Force start in pre
    score = -Inf(numStates, T);
    score(1, 1) = logEmit(1, 1);
    backptr = zeros(numStates, T);

    % Forward pass
    for t = 2:T
        for s = 1:numStates
            [bestScore, bestPrev] = max(score(:, t-1) + logTrans(:, s));
            score(s, t) = bestScore + logEmit(s, t);
            backptr(s, t) = bestPrev;
        end
    end

    % Backward pass
    path = zeros(T, 1);
    [~, path(T)] = max(score(:, T));
    for t = T-1:-1:1
        path(t) = backptr(path(t+1), t+1);
    end

    % Map 4-state path back to original 3-class labels
    stateToClass = [0; 1; 2; 0];           % pre=0, QRS=1, T=2, post=0
    YPred_clean_num = stateToClass(path);
    YPred_clean = categorical(YPred_clean_num, [0 1 2], {'0','1','2'});

    % Modification flag
    [~, argmaxPath] = max(probs, [], 1);
    argmaxPath = argmaxPath(:) - 1;
    wasModified = any(argmaxPath ~= YPred_clean_num);
end