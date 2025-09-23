%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% median_offset_measure_GUI.m -- Part of BRAVEHEART GUI
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


function median_offset_measure_GUI(hObject, eventdata, handles, aps)

% Find/plot baseline offsets for all leads
    baseline_shift = handles.baseline_shift;

% Load raw 12 lead ECG
    ecg_noshift = handles.ecg_raw;
    ecg = handles.ecg;
    vcg_noshift = VCG(handles.ecg_raw, aps);
    vcg = handles.vcg;
    
% Account for possibility that user has not clicked baseline correction flag -
% then baselines will not have been calculated.

shift_prop = fieldnames(baseline_shift);
ecg_prop = properties(ecg_noshift);
vcg_prop = properties(vcg_noshift);

label = {'L1', 'L2', 'L3', 'avR', 'avF', 'avL', 'V1', 'V2', 'V3', 'V4', 'V5', 'V6', 'X', 'Y', 'Z', 'VM'};

figure('name','Lead Baseline Offset Correction','numbertitle','off');
sgtitle('Results of Filtering and Baseline Correction');
set(gcf, 'Position', [0, 0, 1800, 1000])  % set figure size

for i = 1:12
    
subplot(8,2,i)
plot(ecg_noshift.(shift_prop{i}),'k');
hold on
plot(ecg.(shift_prop{i}),'r');
line([0 length(ecg_noshift.(shift_prop{i}))],[0 0],'Color','b');
    % Prevent figure not genearating if a lead is missing due to ylim error
    if min( [min(ecg_noshift.(shift_prop{i})) min(ecg.(shift_prop{i}))]) ~= max( [max(ecg_noshift.(shift_prop{i})) max(ecg.(shift_prop{i}))])
        ylim( [ min( [min(ecg_noshift.(shift_prop{i})) min(ecg.(shift_prop{i}))]) max( [max(ecg_noshift.(shift_prop{i})) max(ecg.(shift_prop{i}))])]);
    else
        ylim( [ min( [min(ecg_noshift.(shift_prop{i})) min(ecg.(shift_prop{i}))])-0.01 max( [max(ecg_noshift.(shift_prop{i})) max(ecg.(shift_prop{i}))])+0.01 ]);
    end
ylabel(label(i))
hold off

    if i == 1
    legend('Original','Corrected','Zero Line','Location','northeast')
    end

end

for i = 13:15
    
subplot(8,2,i)
plot(vcg_noshift.(shift_prop{i}),'k');
hold on
plot(vcg.(shift_prop{i}),'r');
line([0 length(vcg_noshift.(shift_prop{i}))],[0 0],'Color','b');
ylim( [ min( [min(vcg_noshift.(shift_prop{i})) min(vcg.(shift_prop{i}))]) max( [max(vcg_noshift.(shift_prop{i})) max(vcg.(shift_prop{i}))])]);
ylabel(label(i))
hold off

end


subplot(8,2,16)
plot(vcg_noshift.VM,'k')
hold on
plot(vcg.VM,'r')
line([0 length(vcg.VM)],[0 0],'Color','b')
ylabel('VM')
ylim( [ min( [min(vcg.VM) min(vcg_noshift.VM)]) max( [max(vcg.VM) max(vcg_noshift.VM)])])
hold off
legend('Uncorrected VM','Corrected VM','Location','northeast')

% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

    if ismac && currentVersion < 2025
        fontsize(gcf,scale=1.25)
    end



figure('name','Results of Baseline Offset Correction on VM Lead','numbertitle','off');
title('Results of Filtering and Baseline Correction on VM Lead');
set(gcf, 'Position', [0, 0, 1800, 400])  % set figure size
plot(vcg_noshift.VM,'k', 'displayname','Uncorrected VM')
hold on
plot(vcg.VM,'r')
line([0 length(vcg.VM)],[0.05 0.05], 'Color','b','LineStyle','--')
line([0 length(vcg.VM)],[0 0],'Color','b')
ylabel('VM (mV)')
xlabel('Samples')
ylim( [ min( [min(vcg.VM) min(vcg_noshift.VM)]) max( [max(vcg.VM) max(vcg_noshift.VM)])])
hold off
legend('Uncorrected VM','Corrected VM', '0.05 mV','Location','northeast')


if ~get(handles.baseline_correct_checkbox,'Value')  
    msgbox('Baseline Correction Off', 'Baseline Offsets','help'); 
end

% Increase font size on mac due to pc/mac font differences if version prior to R2025a
currentVersion = char(matlabRelease.Release);
currentVersion = str2double(currentVersion(2:5));

    if ismac && currentVersion < 2025
        fontsize(gcf,scale=1.25)
    end



end