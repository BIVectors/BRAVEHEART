%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% Quality.m -- Class for Quality assessment
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


classdef Quality
% Tries to flag annotation results which are suspicious or unlikely to be correct
% This is not 100% specific or sensitive, but ECGs which are flagged by the detector are generally worth reviewing
% The properties below are checked to see if they are too high or too low; if so the ECG is flagged
% High/low limits are set in quality_presets.csv
% Separately there is a estimate of probability that the ECG is of good
% quality based on logistic regression
% Information on the sensitivity/specificity etc can be found in the documentation
  
properties (SetAccess = private)

    qt                  % QT interval (ms)
    qrs                 % QRS duration (ms)
    tpqt                % Ratio of location of VM Tpeak to VM Tend
    t_mag               % Magnitude of T wave peak in VM lead (mV)
    hr                  % Heart rate (bpm)
    num_beats           % Final number of beats included
    pct_beats_removed   % How many beats were removed from analysis (PVCs and outliers)
    corr                % MINIMUM mean cross correlation for X, Y, and Z beats (0-1)
    baseline            % Median value of Tend:Tend+D where D is up to 30 ms (mV)
    missing_lead        % Is there evidence of signal missing from a lead (yes/no result NOT set via quality_presets.csv)
    hf_noise            % SNR ratio of raw signal to LPF filtered signal
    lf_noise            % Variance in the baseline wander (HPF) at level 8
    prob                % Cutoff from probabilty to trigger outlier (0-1)
    prob_value          % Actual probability (range 0-1) for 'good' quality
    nnet_flag           % NNet probabilities found more than 1 possible fiducial point
    nnet_nan            % NNet couldnt find a fiducial point (usually Tend)

end
    
methods
        
function obj = Quality(med_vcg, ecg_raw, beats, medianbeat, hr, num_initial_beats, corr, noise, aps)
    
% med_vcg = median beat VCG.
% ecg_raw = original ECG12, no filtering
% beats = beats after all PVCs and outliers removed
% medianbeat = fiducial points of the median beat
% hr = initial heart rate calculation 
% num_initial_beats = number of beats that were intially detected prior to any removal
% corr = minimum cross correlation for median X, Y, Z beats
% noise = vector containing estimates of lowest SNR and highest wander
% aps = Annoparams

if nargin == 0; return; end    % Create empty Quality class if no input

% Missing any fiducial points on median beat --> flag as bad quality
if any(isnan(medianbeat.beatmatrix()))
    obj = Quality.zero();
    obj.nnet_flag = 1;
    obj.nnet_nan = 1;
    obj.prob = 1;
    obj.prob_value = nan;
    return;
end



% Calculate all the qualitities that are part of Quality variables
% Structure for storing values    
% Can't have empty values, or wksp will not work and will get an error
wksp = struct;   

wksp.hr = hr;

% Don't need to convert tpqt to ms because its already a ratio in 
% samples when calc from tpeak_loc function
[~, ~, wksp.tpqt, ~] = tpeak_loc(medianbeat, (1000/med_vcg.hz));

wksp.qrs = med_vcg.sample_time() * (medianbeat.S-medianbeat.Q);
wksp.qt =  med_vcg.sample_time() * (medianbeat.Tend-medianbeat.Q);
wksp.t_mag = max(med_vcg.VM(medianbeat.S+1:medianbeat.Tend)); 

% Number of beats and number of beats removed
wksp.num_beats = beats.length();
wksp.num_beats_removed = num_initial_beats - wksp.num_beats;
wksp.pct_beats_removed = 100*(wksp.num_beats_removed /num_initial_beats);
    
% Baseline after Tend
wksp.baseline = baseline_voltage(med_vcg, medianbeat);

% Flag for missing lead
[wksp.missing_lead, ~] = missing_leads(ecg_raw,aps.maxBPM,aps.pkthresh);

% NNet flags
wksp.nnet_flag = medianbeat.nnet_flag;
wksp.nnet_nan = medianbeat.nnet_nan;

if isempty(medianbeat.nnet_flag); wksp.nnet_flag = 0; end
if isempty(medianbeat.nnet_nan); wksp.nnet_nan = 0; end   
    
obj.nnet_flag = wksp.nnet_flag;
obj.nnet_nan = wksp.nnet_nan;

% Cross correlation for X, Y, Z (just reports the min value for all 3)
wksp.corr = min([corr.X corr.Y corr.Z]);  % Look at minimum correlation for X, Y, Z leads

% Noise
wksp.hf_noise = noise(1);
wksp.lf_noise = noise(2);

% Logit probability
% If NNet is not confident, flag regardless of probability
if wksp.nnet_flag == 1 || wksp.nnet_nan == 1 || wksp.missing_lead == 1 || ...
   isnan(wksp.corr) || isnan(wksp.baseline) || isnan(wksp.t_mag) || isnan(wksp.tpqt)    
    wksp.prob_value = nan;
    obj.prob_value = wksp.prob_value;
    
else
    P = -22.56276 + ...
        (18.21152 * wksp.corr) + ...
        (-87.59086 * wksp.baseline) + ...
        (9.061254  * wksp.t_mag) + ...
        (11.1939 * wksp.tpqt);

    wksp.prob_value = exp(P)/(1+exp(P));
    obj.prob_value = wksp.prob_value;
end

% Fieldnames
f = fieldnames(Quality());

% Dummy value for prob
wksp.prob = wksp.prob_value;

% Pull all of the workspace variables into a structure by save/load 
% save('tmp.mat');
% V = load('tmp.mat');
% 
% for i = 1:length(f)
%     if ~strcmp('prob_value',f{i})     % prob_value is special case and ignore it in struct
%         wksp.(f{i}) = V.(f{i}); 
%     end
% end
      

% Generate structure to store the names of Quality variables
% Qvar_names will have same order as 'wksp' EXCEPT it also includes 'prob_cut'
Qvar_names = fieldnames(Quality());

% Tests for if results are out of normal range based on values in quality_presets.csv:

% Load preset values into Qvals structure based on names in qiality_presets.csv file
% Get working directory if running off compiled version
currentdir = getcurrentdir();
A = readcell(fullfile(currentdir,'quality_presets.csv')); % read in data from .csv file
miss = cellfun(@(x) any(isa(x,'missing')), A);
A(miss) = {NaN};

preset_names = A(:,1);
preset_values_low = cell2mat(A(:,2));
preset_values_low(isnan(preset_values_low)) = -Inf;

preset_values_high = cell2mat(A(:,3));
preset_values_high(isnan(preset_values_high)) = Inf;

%preset_values = [preset_values_low preset_values_high];

% Make sure lengths of file and throw error if not same length (csv has errors) 
assert(length(preset_names) == length(Qvar_names)-3, 'Check quality_presets.csv for errors');

% Set up variables for low and high cutoffs
for i = 1:length(preset_names)
    Qnames{i} = matlab.lang.makeValidName(preset_names{i});
    Qvals.(Qnames{i}) = [preset_values_low(i) preset_values_high(i)];
end

% Now have all of the cutpoints stored in structure Qvals

% Loop through presets and check if satisfies conditions
for i = 1:length(preset_names)
  switch (Qnames{i})
      case 'missing_lead'
            obj.missing_lead = wksp.missing_lead;            
      otherwise
          if isempty(wksp.(Qnames{i})) || isnan(wksp.(Qnames{i}))
                obj.(Qnames{i}) = 1;
          else
                obj.(Qnames{i}) =  wksp.(Qnames{i}) < Qvals.(Qnames{i})(1) || wksp.(Qnames{i}) > Qvals.(Qnames{i})(2);
          end
      end   % end switch
    end     % end for loop
    end   % End constructor


    
% Helper functions:    
function c = counter(obj)
    c = sum(vector(obj));
end
        
      
function v = vector(obj)

if isempty(obj.nnet_flag)
    obj.nnet_flag = 0;
end

if isempty(obj.nnet_nan)
    obj.nnet_nan = 0;  
end
    
v = [obj.qt obj.qrs obj.tpqt obj.t_mag obj.hr obj.num_beats obj.pct_beats_removed...
        obj.corr obj.baseline obj.missing_lead obj.hf_noise obj.lf_noise obj.prob obj.nnet_flag obj.nnet_nan];
end
                
    
end   % End methods


methods(Static)   
    function obj = zero()
        obj = Quality();
        p = properties(obj);
        for i=1:length(p)
            obj.(p{i}) = 0;
        end
    end  
end
    
end         % End classdef





