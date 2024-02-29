%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% noise_reduction_figure.m -- Part of BRAVEHEART GUI - Figure assessing noise/filtering
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


function noise_reduction_figure(ecg, ecg_raw, aps, filename, hObject, eventdata, handles)

% Initialize figure
figure(figure('name','Noise Reduction','numbertitle','off'))
set(gcf, 'Position', [0, 0, 1500, 1000])  % set figure size
hold on

% Y-scale adjustment if needed
scale = 10;

% Original raw ecg signals
L1o = ecg_raw.I*scale;
L2o = ecg_raw.II*scale;
L3o = ecg_raw.II*scale;
avRo = ecg_raw.avR*scale;
avFo = ecg_raw.avF*scale;
avLo = ecg_raw.avL*scale;
V1o = ecg_raw.V1*scale;
V2o = ecg_raw.V2*scale;
V3o = ecg_raw.V3*scale;
V4o = ecg_raw.V4*scale;
V5o = ecg_raw.V5*scale;
V6o = ecg_raw.V6*scale;

% Filtered/baseline corrected signals
L1 = ecg.I*scale;
L2 = ecg.II*scale;
L3 = ecg.II*scale;
avR = ecg.avR*scale;
avF = ecg.avF*scale;
avL = ecg.avL*scale;
V1 = ecg.V1*scale;
V2 = ecg.V2*scale;
V3 = ecg.V3*scale;
V4 = ecg.V4*scale;
V5 = ecg.V5*scale;
V6 = ecg.V6*scale;

% Determine Y bounds for each lead
max_L1 = max(L1)+abs(min(L1));
max_L2 = max(L2)+abs(min(L2));
max_L3 = max(L3)+abs(min(L3));
max_avR = max(avR)+abs(min(avR));
max_avL = max(avL)+abs(min(avL));
max_avF = max(avF)+abs(min(avF));
max_V1 = max(V1)+abs(min(V1));
max_V2 = max(V2)+abs(min(V2));
max_V3 = max(V3)+abs(min(V3));
max_V4 = max(V4)+abs(min(V4));
max_V5 = max(V5)+abs(min(V5));
max_V6 = max(V6)+abs(min(V6));
    
% k = variable to help position various leads on figure correctly   
k = round(max([max_L1 max_L2 max_L3 max_avR max_avL max_avF max_V1 max_V2 max_V3 max_V4 max_V5 max_V6]));
axis off

% Plot original signals
pb = plot(V6o+k,'k','linewidth',1.0,'DisplayName','Original');
plot(V5o+2*k,'k','linewidth',1.0);
plot(V4o+3*k,'k','linewidth',1.0);
plot(V3o+4*k,'k','linewidth',1.0);
plot(V2o+5*k,'k','linewidth',1.0);
plot(V1o+6*k,'k','linewidth',1.0);
plot(avFo+7*k,'k','linewidth',1.0);
plot(avLo+8*k,'k','linewidth',1.0);
plot(avRo+9*k,'k','linewidth',1.0);
plot(L3o+10*k,'k','linewidth',1.0);
plot(L2o+11*k,'k','linewidth',1.0);
plot(L1o+12*k,'k','linewidth',1.0);

% Plot filtered signals
pr = plot(V6+k,'r','linewidth',1.0,'DisplayName','Filtered');
plot(V5+2*k,'r','linewidth',1.0);
plot(V4+3*k,'r','linewidth',1.0);
plot(V3+4*k,'r','linewidth',1.0);
plot(V2+5*k,'r','linewidth',1.0);
plot(V1+6*k,'r','linewidth',1.0);
plot(avF+7*k,'r','linewidth',1.0);
plot(avL+8*k,'r','linewidth',1.0);
plot(avR+9*k,'r','linewidth',1.0);
plot(L3+10*k,'r','linewidth',1.0);
plot(L2+11*k,'r','linewidth',1.0);
plot(L1+12*k,'r','linewidth',1.0);
    
    
%Add trend line in if wavelet low freq filtering
maxRR_hr = handles.maxRR_hr; 

if aps.highpass == 1
    freq = ecg.hz;    
    wavelet_name_highpass = aps.wavelet_name_highpass;
    wavelet_level_highpass = aps.wavelet_level_highpass;

    % L1x is a dummy variable that is not used - only care about the approximation signal here

    [~, aL1o, ~] = wander_remove(freq, maxRR_hr, mirror(L1o), wavelet_name_highpass, wavelet_level_highpass);
    [~, aL2o, ~] = wander_remove(freq, maxRR_hr, mirror(L2o), wavelet_name_highpass, wavelet_level_highpass);
    [~, aL3o, ~] = wander_remove(freq, maxRR_hr, mirror(L3o), wavelet_name_highpass, wavelet_level_highpass);

    [~, aavRo, ~] = wander_remove(freq, maxRR_hr, mirror(avRo), wavelet_name_highpass, wavelet_level_highpass);
    [~, aavLo, ~] = wander_remove(freq, maxRR_hr, mirror(avLo), wavelet_name_highpass, wavelet_level_highpass);
    [~, aavFo, ~] = wander_remove(freq, maxRR_hr, mirror(avFo), wavelet_name_highpass, wavelet_level_highpass);

    [~, aV1o, ~] = wander_remove(freq, maxRR_hr, mirror(V1o), wavelet_name_highpass, wavelet_level_highpass);
    [~, aV2o, ~] = wander_remove(freq, maxRR_hr, mirror(V2o), wavelet_name_highpass, wavelet_level_highpass);
    [~, aV3o, ~] = wander_remove(freq, maxRR_hr, mirror(V3o), wavelet_name_highpass, wavelet_level_highpass);

    [~, aV4o, ~] = wander_remove(freq, maxRR_hr, mirror(V4o), wavelet_name_highpass, wavelet_level_highpass);
    [~, aV5o, ~] = wander_remove(freq, maxRR_hr, mirror(V5o), wavelet_name_highpass, wavelet_level_highpass);
    [~, aV6o, ~] = wander_remove(freq, maxRR_hr, mirror(V6o), wavelet_name_highpass, wavelet_level_highpass);

    % Deal with edge effects
    aL1o = middlethird(aL1o);
    aL2o = middlethird(aL2o);
    aL3o = middlethird(aL3o);
    aavRo = middlethird(aavRo);
    aavLo = middlethird(aavLo);
    aavFo = middlethird(aavFo);
    aV1o = middlethird(aV1o);
    aV2o = middlethird(aV2o);
    aV3o = middlethird(aV3o);
    aV4o = middlethird(aV4o);
    aV5o = middlethird(aV5o);
    aV6o = middlethird(aV6o); 

    % Plot baseline wander signals
    pc = plot(aV6o+k,'b--','linewidth',1.0,'DisplayName','Baseline Wander');
    plot(aV5o+2*k,'b--','linewidth',1.0);
    plot(aV4o+3*k,'b--','linewidth',1.0);
    plot(aV3o+4*k,'b--','linewidth',1.0);
    plot(aV2o+5*k,'b--','linewidth',1.0);
    plot(aV1o+6*k,'b--','linewidth',1.0);
    plot(aavFo+7*k,'b--','linewidth',1.0);
    plot(aavLo+8*k,'b--','linewidth',1.0);
    plot(aavRo+9*k,'b--','linewidth',1.0);
    plot(aL3o+10*k,'b--','linewidth',1.0);
    plot(aL2o+11*k,'b--','linewidth',1.0);
    plot(aL1o+12*k,'b--','linewidth',1.0);

end         % End highpass if statement
    

% Labels
text(-250,k,'V6');
text(-250,2*k,'V5');
text(-250,3*k,'V4');
text(-250,4*k,'V3');
text(-250,5*k,'V2');
text(-250,6*k,'V1');
text(-250,7*k,'avF');
text(-250,8*k,'avL');
text(-250,9*k,'avR');
text(-250,10*k,'III');
text(-250,11*k,'II');
text(-250,12*k,'I');

% Graph limits
xlim([-300 length(L1)]);
ylim([0 13*k]);

% Graph title based on filename
title(filename(max(strfind(filename,'\'))+1:end-4),'FontWeight','bold','FontSize',14,'Interpreter', 'none');

% Legend
if get(handles.wavelet_filter_box_lf, 'Value') == 1
    legend ([pb pr pc]);
else
    legend ([pb pr]);
end

% Graph positioning to fill out figure and have minimal margins
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

hold off

% Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end


% End of filtering graph

% On to display of noise levels for each lead

wavelet_name_lowpass = aps.wavelet_name_lowpass;
wavelet_level_lowpass = aps.wavelet_level_lowpass;

% Thresholds for calling too much noise 
% Read quality.csv
A = readcell(fullfile(getcurrentdir(),'Qualparams.csv')); % read in data from .csv file
miss = cellfun(@(x) any(isa(x,'missing')), A);
A(miss) = {NaN};

preset_names = A(:,1);
preset_values_low = cell2mat(A(:,2));
preset_values_low(isnan(preset_values_low)) = -Inf;

preset_values_high = cell2mat(A(:,3));
preset_values_high(isnan(preset_values_high)) = Inf;

preset_values = [preset_values_low preset_values_high];

[~, ind] = ismember(preset_names, 'hf_noise');
hf_thresh_ind = find(ind == 1);
hf_thresh = preset_values(hf_thresh_ind,1);

[~, ind] = ismember(preset_names, 'lf_noise');
lf_thresh_ind = find(ind == 1);
lf_thresh = preset_values(lf_thresh_ind,2);

% Call noise_test function
[sig_noise_ratio, ~, hf_noise_matrix, ~, lf_noise_var, ~, lf_noise_matrix, ~] = ...
    noise_test(ecg_raw, hf_thresh, lf_thresh, aps);

% Change lf_noise_var to microvolts so values arent so small
lf_noise_var = 1000 * lf_noise_var;

% Set up figure
figure('name','ECG Noise/Wander Estimates','numbertitle','off')

subplot(2,1,1)
title(sprintf('ECG Signal to Noise Ratio Estimates (Cutoff = %d)',hf_thresh))
hold on

for i=1:length(hf_noise_matrix)
    if hf_noise_matrix(i) == 0     
        color(i) = 'g';
    else
        color(i) = 'r'; 
    end
    
    bar(i, 1, color(i))   
     
end


L = [{'L1'} {'L2'} {'L3'} {'avR'} {'avL'} {'avF'} {'V1'} {'V2'} {'V3'} {'V4'} {'V5'} {'V6'}];

for k = 1:length(L)
    hold on    
    text(k,0.4,L{k},'vert','bottom','horiz','center','FontWeight','bold', 'Color','k');
    text(k,0.7,num2str(round(sig_noise_ratio(k))),'vert','bottom','horiz','center', 'Color','k');
end

hold off

% Set figure limits
ylim([0 1]);
xlim([0 length(hf_noise_matrix)+1]);
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);

subplot(2,1,2)
title(sprintf('ECG Baseline Wander Noise Estimates (Cutoff = %1.2f \\muV)',lf_thresh*1000))
hold on

for i=1:length(lf_noise_matrix)
    
    if lf_noise_matrix(i) == 0   
        color(i) = 'g';
    else
        color(i) = 'r'; 
    end
    
    bar(i, 1, color(i))   
     
end
    
for k = 1:length(L)
    hold on
    text(k,0.4,L{k},'vert','bottom','horiz','center','FontWeight','bold', 'Color','k');
    text(k,0.7,sprintf('%s',num2str(round(lf_noise_var(k),2))),'vert','bottom','horiz','center', 'Color','k');
end

hold off

ylim([0 1]);
xlim([0 length(hf_noise_matrix)+1]);
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);

set(gcf, 'Position', [200, 100, 800, 300])  % set figure size

% Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end
