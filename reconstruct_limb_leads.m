%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% reconstruct_limb_leads.m -- Given 2 limb leads, generates the remaining limb leads if any are missing
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

function [I, II, III, aVR, aVL, aVF] = reconstruct_limb_leads(I, II, III, aVR, aVL, aVF)

% This function will generate any of the missing 6 limb leads given any 2 existing limb leads.

% Have the formulas for the 60 possible combinations of creating a missing
% lead from 2 existing leads

% Rules are given as:
% Lead to calculate,  {2 leads to use}, anonymous function to calculate Lead from the other 2 leads
% There are 10 possible ways to calculate each lead from 2 others -- 60 total equations

% Validate the input at least 2 non-empty leads
non_empty_count = sum(~cellfun(@isempty, {I, II, III, aVR, aVL, aVF}));
if non_empty_count < 2
    error('Need at least 2 non-empty limb leads to reconstruct the missing limb leads');
end

% Convert into structure to make it easier to deal with missing lead names
leads = struct('I', I, 'II', II, 'III', III, 'aVR', aVR, 'aVL', aVL, 'aVF', aVF);

rules = {
    % Rules for I
    'I',  {'II', 'III'},   @(L) L.II - L.III;
    'I',  {'II', 'aVR'},   @(L) -L.II - 2*L.aVR;
    'I',  {'II', 'aVL'},   @(L) (L.II/2) + L.aVL;
    'I',  {'II', 'aVF'},   @(L) 2*L.II - 2*L.aVF;
    'I',  {'III', 'aVR'},  @(L) -(L.III/2) - L.aVR;
    'I',  {'III', 'aVL'},  @(L) L.III + 2*L.aVL;
    'I',  {'III', 'aVF'},  @(L) 2*L.aVF - 2*L.III;
    'I',  {'aVR', 'aVL'},  @(L) ((2*L.aVL)/3) - ((2*L.aVR)/3);
    'I',  {'aVR', 'aVF'},  @(L) -((2*L.aVF)/3) - ((4*L.aVR)/3);
    'I',  {'aVL', 'aVF'},  @(L) ((2*L.aVF)/3) + ((4*L.aVL)/3);

    % Rules for II
    'II',  {'I', 'III'},   @(L) L.III + L.I;
    'II',  {'I', 'aVR'},   @(L) -L.I - 2*L.aVR;
    'II',  {'I', 'aVL'},   @(L) 2*L.I - 2*L.aVL;
    'II',  {'I', 'aVF'},   @(L) (L.I/2) + L.aVF;
    'II',  {'III', 'aVR'}, @(L) (L.III/2) - L.aVR;
    'II',  {'III', 'aVL'}, @(L) 2*L.III + 2*L.aVL;
    'II',  {'III', 'aVF'}, @(L) 2*L.aVF - L.III;
    'II',  {'aVR', 'aVL'}, @(L) -((2*L.aVL)/3) - ((4*L.aVR)/3);
    'II',  {'aVR', 'aVF'}, @(L) ((2*L.aVF)/3) - ((2*L.aVR)/3);
    'II',  {'aVL', 'aVF'}, @(L) ((4*L.aVF)/3) + ((2*L.aVL)/3);

    % Rules for III
    'III',  {'I', 'II'},   @(L) L.II - L.I;
    'III',  {'I', 'aVR'},  @(L) -2*L.I - 2*L.aVR;
    'III',  {'I', 'aVL'},  @(L) L.I - 2*L.aVL;
    'III',  {'I', 'aVF'},  @(L) L.aVF - (L.I/2);
    'III',  {'II', 'aVR'}, @(L) 2*L.II + 2*L.aVR;
    'III',  {'II', 'aVL'}, @(L) (L.II/2) - L.aVL;
    'III',  {'II', 'aVF'}, @(L) 2*L.aVF - L.II;
    'III',  {'aVR', 'aVL'},@(L) -((4*L.aVL)/3) - ((2*L.aVR)/3);
    'III',  {'aVR', 'aVF'},@(L) ((4*L.aVF)/3) + ((2*L.aVR)/3);
    'III',  {'aVL', 'aVF'},@(L) ((2*L.aVF)/3) - ((2*L.aVL)/3);

    % Rules for aVR
    'aVR',  {'I', 'II'},   @(L) -L.II/2 - L.I/2;
    'aVR',  {'I', 'III'},  @(L) -L.III/2 - L.I;
    'aVR',  {'I', 'aVL'},  @(L) L.aVL - (3*L.I)/2;
    'aVR',  {'I', 'aVF'},  @(L) -((3*L.I)/4) - (L.aVF/2);
    'aVR',  {'II', 'III'}, @(L) (L.III/2) - L.II;
    'aVR',  {'II', 'aVL'}, @(L) -((3*L.II)/4) - (L.aVL/2);
    'aVR',  {'II', 'aVF'}, @(L) L.aVF - ((3*L.II)/2);
    'aVR',  {'III', 'aVL'},@(L) -((3*L.III)/2) - 2*L.aVL;
    'aVR',  {'III', 'aVF'},@(L) ((3*L.III)/2) - 2*L.aVF;
    'aVR',  {'aVL', 'aVF'},@(L) -L.aVF - L.aVL;

    % Rules for aVL
    'aVL',  {'I', 'II'},   @(L) L.I - L.II/2;
    'aVL',  {'I', 'III'},  @(L) L.I/2 - L.III/2;
    'aVL',  {'I', 'aVR'},  @(L) (3*L.I)/2 + L.aVR;
    'aVL',  {'I', 'aVF'},  @(L) (3*L.I)/4 - L.aVF/2;
    'aVL',  {'II', 'III'}, @(L) L.II/2 - L.III;
    'aVL',  {'II', 'aVR'}, @(L) -(3*L.II)/2 - 2*L.aVR;
    'aVL',  {'II', 'aVF'}, @(L) (3*L.II)/2 - 2*L.aVF;
    'aVL',  {'III', 'aVR'},@(L) -(3*L.III)/4 - L.aVR/2;
    'aVL',  {'III', 'aVF'},@(L) L.aVF - (3*L.III)/2;
    'aVL',  {'aVR', 'aVF'},@(L) -L.aVF - L.aVR;

    % Rules for aVF
    'aVF',  {'I', 'II'},   @(L) L.II - L.I/2;
    'aVF',  {'I', 'III'},  @(L) L.III + L.I/2;
    'aVF',  {'I', 'aVR'},  @(L) -(3*L.I)/2 - 2*L.aVR;
    'aVF',  {'I', 'aVL'},  @(L) (3*L.I)/2 - 2*L.aVL;
    'aVF',  {'II', 'III'}, @(L) L.II/2 + L.III/2;
    'aVF',  {'II', 'aVR'}, @(L) (3*L.II)/2 + L.aVR;
    'aVF',  {'II', 'aVL'}, @(L) (3*L.II)/4 - L.aVL/2;
    'aVF',  {'III', 'aVR'},@(L) (3*L.III)/4 - L.aVR/2;
    'aVF',  {'III', 'aVL'},@(L) (3*L.III)/2 + L.aVL;
    'aVF',  {'aVR', 'aVL'},@(L) -L.aVL - L.aVR;
};
  
% Depending on which leads you start with may have to do this entire loop
% more than once to get all 4 missing leads

% Iteratively apply rules until no new leads can be derived
max_iterations = 5;  % Prevent infinite loops
    
for iteration = 1:max_iterations

leads_added = 0;
        
    for i = 1:size(rules, 1)
        % Select appropriate rule row
        target_lead = rules{i, 1};
        dependencies = rules{i, 2};
        compute_func = rules{i, 3};
        
        % Skip if we already have this lead
        if isfield(leads, target_lead) && ~isempty(leads.(target_lead))
            continue;   % Break out of loop and increase i by 1
        end
        
        % Check if all dependencies are available
        all_deps_available = true;
        for j = 1:length(dependencies)
            if ~isfield(leads, dependencies{j}) || isempty(leads.(dependencies{j}))
                all_deps_available = false;  
                break; % If this becomes false it breaks out of loop and increments i by 1
            end
        end
        
        % If all dependencies available, compute the lead
        if all_deps_available
            try
                % Use the anonymous function to calculate the lead from the
                % other 2 leads which are available
                leads.(target_lead) = compute_func(leads);

                % Increment counter
                leads_added = leads_added + 1;
            catch
                % Skip if computation fails
                continue;
            end
        end
    end
        
        % If no new leads were added, we're done
        if leads_added == 0
            break;
        end
end

% Check if we successfully reconstructed all 6 leads
expected_leads = {'I', 'II', 'III', 'aVR', 'aVL', 'aVF'};

empty_leads = {};
for k = 1:length(expected_leads)
    if isempty(leads.(expected_leads{k}))
        empty_leads{end+1} = expected_leads{k};
    end
end

if ~isempty(empty_leads)
    error('Could not reconstruct all leads. Still empty: %s', strjoin(empty_leads, ', '));
end


% Unpack the structure into individual leads
[I, II, III, aVR, aVL, aVF] = deal(leads.I, leads.II, leads.III, leads.aVR, leads.aVL, leads.aVF);

end