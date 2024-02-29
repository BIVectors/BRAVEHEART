%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% display_medianbeats.m -- Part of BRAVEHEART GUI
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

function display_medianbeats(median_vcg, beatsig_vcg, medianbeat, max_tvm_value, hObject, eventdata, handles)

% Load in axes for plotting (VM, X, Y, Z in order)
A = [handles.VMmedianbeat_axis handles.Xmedianbeat_axis handles.Ymedianbeat_axis handles.Zmedianbeat_axis];

% Set up fidpts
    med_qoff = medianbeat.S;
    med_qon = medianbeat.Q;
    med_toff = medianbeat.Tend;

% To search for leads in VCG class
lead_names_vcg = [{'VM'} {'X'} {'Y'} {'Z'}];
vcg_fields = properties(median_vcg);

% Colors for plotting VM, X, Y, Z
colors = [{'[1 0 0]'}, {'[0 0.4470 0.7410]'}, {'[0 0.4470 0.7410]'}, {'[0 0.4470 0.7410]'}];

 % Find indices of lead_names in VCG class
for k = 1:length(lead_names_vcg)              
    lead_idx_vcg(k) = find(strcmp(vcg_fields,lead_names_vcg{k}));      
end


for j = 1:length(A)

    beatsig_signal = beatsig_vcg.(vcg_fields{lead_idx_vcg(j)});         % Individual beats
    med_signal = median_vcg.(vcg_fields{lead_idx_vcg(j)});              % Median beat

    cla(A(j));
    axes(A(j));
    scale = abs(max(max(beatsig_signal))-min(min(beatsig_signal)));     % Scale differently for each lead    
    hold on

    % Plot individual beats (beatsig) for X, Y, Z only (not VM)
    if ~strcmp(string(lead_names_vcg{j}),'VM')
        for i=1:size(beatsig_signal,1)
            plot(beatsig_signal(i,:),':k');
        end
    end

    % Plot median beat and lines
    line([med_qoff med_qoff], [min(min(beatsig_signal))-(0.1*scale) max(max(beatsig_signal))+(0.1*scale)],'color', 'k', 'linewidth',1.2,'LineStyle','--');
    line([med_qon med_qon], [min(min(beatsig_signal))-(0.1*scale) max(max(beatsig_signal))+(0.1*scale)],'color', 'k', 'linewidth',1.2,'LineStyle','--');
    line([med_toff med_toff], [min(min(beatsig_signal))-(0.1*scale) max(max(beatsig_signal))+(0.1*scale)],'color', 'k', 'linewidth',1.2,'LineStyle','--');
    
    line([0 length(med_signal)],[0 0], 'color', 'k','linewidth',0.5);
    plot(med_signal,'color', colors{j}, 'linewidth',1.5);
	if ~isnan(max_tvm_value)
		plot(max_tvm_value, med_signal(max_tvm_value),'*','color','b','MarkerSize', 8);
	end
    hold off

    xlim([0 length(med_signal)]);

    % Set ylim based on y values in each lead
    if strcmp(lead_names_vcg(j),'VM')
        ylim([0-(0.1*scale) max(max(beatsig_signal))+(0.1*scale) ]);
    else
        ylim([min(min(beatsig_signal))-(0.1*scale) max(max(beatsig_signal))+(0.1*scale)]);
    end

end