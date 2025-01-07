%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% pvc_stats.m -- Determine which beats are PVCs
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


function [delete_index, norm_corr_matrix_values, rmse_matrix_values, pvc_marker, max_index] = ...
    pvc_stats(corr_threshold, rmse_threshold, keep_pvc, beatmatrix, ecg_lead)

%%% INPUT
% corr_threshold = normalized cross correlation trehsold for comparison of PVC
% and normal (nominal 0.95)
% rmes_threshold = normalized cross correlation trehsold for comparison of PVC
% and normal (nominal 0.1)
% keep_pvc = keep (1) or remove (0) PVCs
% str_matrix_num =  beatmatrix (Q R S Tend) in numeric format (not
% strings/char) for all beats
% ecg_matrix = matrix of all 15 ecg leads
% median_beats = matrix of all beats making up the median VM beat
%%% OUTPUT
% delete_index = indices of beats to delete based on if want to keep/remove
% PVCs
% norm_corr_matrix_values =  matrix of normalized cross correlation values for
% all beats
% pvc_marker = beats that are declared as PVC (1) or normal (0)
% VM_no_PVC = signal with PVC beatsreplaced by nan


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEW METHOD
% Looks at X, Y, Z leads individually
% calculates the cross correlation and RMSE for all combinations of beats (NxN)
% values of corr and RMSE are thresholded into 1 and 0, and then added together
% If either RMSE or Xcorr meet criteria, it is considered a NORMAL beat
% The beat that agrees best with all other beats is chosen as the reference
% This beat is used to calculate the correlation with all other beats and
% the XCorr and RMSE is calculated.
% If there are more than N/2 + 1 normal beats, the PVCs are the rest
% If there are < N/2 + 1 normal beats (eg bigeminy), the normal beat is the
% narrower template
% Beats.m class then calculates the X, Y, Z PVCs.  Beats that have >= 2
% leads showing PVC are noted to be a PVC


% Assign current listbox beats to prior fiducial points Q, QRS, S, Tend
Q = beatmatrix(:,1);
R = beatmatrix(:,2);
S =  beatmatrix(:,3);
Tend = beatmatrix(:,4);

QRS = beatmatrix(:,3) - beatmatrix(:,1);
QT = beatmatrix(:,4) - beatmatrix(:,1);

N = numel(Q);  % number of beats

% There cannot be a PVC if there is only 1 beat
% If run with 1 beat will crash - so if N = 1 will just break out

if N <= 1   
    delete_index = [];
    norm_corr_matrix_values = [];
    rmse_matrix_values = [];
    pvc_marker = false(N,1)';
    max_index = [];
    
    return;
end

% Calc beatsig - individual beats so PVC detector can operate on the properly aligned beats
% Specifically NOT using the parsed out individual beats that made up the
% median beat because need to look at a segment around QRS peak that is
% relatively shorter than the entire QRST complex, or noise etc makes the
% cross correlations poor overall

[startb, endb] = minQRSTwindow(Q, R, S, Tend);

for i=1:N
   % figure(i)
   % hold on
    beatsig(i,:) = ecg_lead(startb(i):endb(i));
   % plot(beatsig(i,:))
   % plot(beatsig(1,:))
   % c = norm_corr(beatsig(1,:),beatsig(i,:))
    
   % nRMSE = (sqrt(mean((beatsig(1,:)-beatsig(i,:)).^2)))/(max(beatsig(1,:)) - min(beatsig(1,:)));
   % text(80,0,num2str(nRMSE));
   % text(20,0,num2str(c))
   % hold off
end


% Area of all beats (not really used anymore unless issue with differentiating same number of normal beats from PVCs)
% Not being used anymore
% for i=1:N
%     area(i) = trapz(abs(beatsig(i,:)));
% end


% Empty NxN matrices for storing normalized correlations and RMSE between beats
norm_corr_matrix = zeros(N); 
rmse_matrix = zeros(N); 

% Need to clip the parts of the QRS complex that will be used to see how
% correlated 2 beats are.  This is because if the windows arent equal cant
% computer correlation, and truncating to the shorter signal can cause
% errors due to not knowing if should truncate the start or end of the
% signal (? is signal A too long at start or end compared to signal B).
% Will take each QRS interval, and truncate around the R wave to the
% shortest RS and QR intervals

% Start with beat 1, and compare its normalized correlation and RMSE to all other
% beats in the beatlist using the adjusted QR and RS intervals 

for i=1:N 
    for j = 1:N                
        beat1_vm = beatsig(i,:);
        beat2_vm = beatsig(j,:);
        
        % Perform normalized cross correlation
        norm_corr_matrix(i,j) = norm_corr(beat1_vm,beat2_vm);   
        rmse_matrix(i,j) = (sqrt(mean((beat1_vm - beat2_vm).^2)))/(max([beat1_vm beat2_vm]) - min([beat1_vm beat2_vm]));
    end 
end


% Save cross correlation values for use later in norm_corr_matrix_values.
% will use norm_cross_matrix as binary values for good/bad correlation
% going forward from here
norm_corr_matrix_values = norm_corr_matrix;
rmse_matrix_values = rmse_matrix;

% Beats with good correlation are assigned 1, while beats with poor
% corrlation are assigned 0.  Threshold is adjustable, but 95-96% probably
% is reasonable
norm_corr_matrix(norm_corr_matrix > corr_threshold) = 1;
norm_corr_matrix(norm_corr_matrix <= corr_threshold) = 0;


rmse_matrix(rmse_matrix >= rmse_threshold) = 1;
rmse_matrix(rmse_matrix < rmse_threshold) = 0;
rmse_matrix = abs(rmse_matrix - 1);     % Have to invert it here due to subtraction order issues

sum_rmse = sum(rmse_matrix,2) - 1;
sum_corr = sum(norm_corr_matrix,2) - 1;

sum_combined = sum_rmse + sum_corr;
max_index = find(sum_combined == max(sum_combined));
max_index = max_index(1);

combined_matrix = rmse_matrix + norm_corr_matrix;

norm_beats = combined_matrix(max_index,:);
norm_beats(norm_beats > 0) = 1;       %  BOTH below corr threshold and above rmse threshold = PVC


% if no PVCs, stop here
if all(norm_beats)
    pvc_marker = ~norm_beats;
    if ~keep_pvc
        delete_index = [];
    else
        delete_index = norm_beats;
    end
    return;
end

% Should be more normal beats than PVCs in the ECG, so check that
% pvc_marker has more 1s than 0s

if sum(norm_beats) > N/2 + 1 
% If first beat is normal and normal beats are most of beats, then invert norm_beats to get PVCs
pvc_marker = ~norm_beats;
else
    
% Look at areas of number of normal and pvc beats are close

% Best template for the dominant/normal beats is going to be max_index by definition
% but to make more robust will take median of all beats that share sum of
% max_index
norm_list = find(norm_beats == 1);
sum_normal = sum_combined(norm_list);
best_normal = find(sum_normal == max(sum_normal));
best_normal = norm_list(best_normal);

% Now need to find the best template for the PVC/non-diminant beat
% Find the indices of PVCs
pvc_list = find(norm_beats == 0);

% Find the "best" PVC beat to use as a comparitor to the best normal beat

% look at sum_combined to find the best PVC beat
sum_pvc = sum_combined(pvc_list);

% Take the first occurance of the max of sum_pvc as the tempate for PVCs.
best_pvc = find(sum_pvc == max(sum_pvc));
best_pvc = pvc_list(best_pvc); 
%best_pvc = pvc_list(best_pvc(1)); 

% Does the "PVC" template have a narrower QRS than the "normal" template?
% If so, then will assume that the PVCs and normal beats are reversed.
% To deal with small variations in annotation, will also require the
% difference is > 10%

% If fails the QRS comparison, the check the same for QT. 

    if median(QRS(best_pvc)) < median(QRS(best_normal)) & (abs(median(QRS(best_pvc)) - median(QRS(best_normal)))/ median(QRS(best_pvc))) > 0.1
        pvc_marker = norm_beats;
    elseif median(QT(best_pvc)) < median(QT(best_normal)) & (abs(median(QT(best_pvc)) - median(QT(best_normal)))/ median(QT(best_pvc))) > 0.1
        pvc_marker = norm_beats;
    else    % PVC template QRS and QT are not sufficiently shorter than the normal template - assume template are assigned correctly
        pvc_marker = ~norm_beats;
    end

end


if keep_pvc == 0
    delete_index = find(pvc_marker == 1);
end

if keep_pvc == 1
    delete_index = find(pvc_marker == 0);
end

