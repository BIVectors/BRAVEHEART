%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% graph_outliers_pvcs.m -- Part of BRAVEHEART GUI - Visualize PVCs and outliers
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

function graph_outliers_pvcs(beats, vcg, aps, hObject,eventdata,handles)

outliers = beats.outlier;
pvcs = beats.pvc;
r_peaks = beats.QRS;

outlier_index = find(outliers);
outlier_r_locs = r_peaks(outlier_index);

pvc_index = find(pvcs);
pvc_r_locs = r_peaks(pvc_index);

X = vcg.X;
Y = vcg.Y;
Z = vcg.Z;
VM = vcg.VM;

% Outliers
str_matrix = get(handles.activebeats_list,'String');
        new_str_matrix='';
        for i=1:numel(outliers)
            if ~outliers(i) 
                string = strcat(str_matrix(i,:), '   ');
            else
                %string = ['<HTML><font color="red">' str_matrix(i,:) '</font></HTML>'];
                string = strcat(str_matrix(i,:), '  **');
            end
            if isempty(new_str_matrix)
                new_str_matrix = char(string);
            else
                new_str_matrix = char(new_str_matrix, string);
            end
        end
        
        % If import beats via csv file outliers/pvcs may be empty
        % and this will avoid erasing beat listbox
        if ~isempty(new_str_matrix)
            set(handles.activebeats_list, 'String', new_str_matrix);
        end
        
        set(handles.activebeats_list, 'Value', 1);
      
% PVC      
str_matrix = get(handles.activebeats_list,'String');
        new_str_matrix='';
        for i=1:numel(pvcs)
            if ~pvcs(i) 
                string = strcat(str_matrix(i,:), '   ');
            else
                %string = ['<HTML><font color="red">' str_matrix(i,:) '</font></HTML>'];
                string = strcat(str_matrix(i,:), '  #');
            end
            if isempty(new_str_matrix)
                new_str_matrix = char(string);
            else
                new_str_matrix = char(new_str_matrix, string);
            end
        end
        
        % If import beats via csv file outliers/pvcs may be empty
        % and this will avoid erasing beat listbox
        if ~isempty(new_str_matrix)
            set(handles.activebeats_list, 'String', new_str_matrix);
        end
        
        set(handles.activebeats_list, 'Value', 1);
      
          
% Graph Outliers      
      axes(handles.x_axis);
      hold on
      scatter(outlier_r_locs, X(outlier_r_locs),80,'o','MarkerEdgeColor','[0.25, 0.25, 0.25]','LineWidth',0.8)
      hold off
      
      axes(handles.y_axis);
      hold on
      scatter(outlier_r_locs, Y(outlier_r_locs),80,'o','MarkerEdgeColor','[0.25, 0.25, 0.25]','LineWidth',0.8)
      hold off
      
      axes(handles.z_axis);
      hold on
      scatter(outlier_r_locs, Z(outlier_r_locs),80,'o','MarkerEdgeColor','[0.25, 0.25, 0.25]','LineWidth',0.8)
      hold off
        
      axes(handles.vm_axis);
      hold on
      scatter(outlier_r_locs, VM(outlier_r_locs),80,'o','MarkerEdgeColor','[0.25, 0.25, 0.25]','LineWidth',0.8)
      hold off
      
      
% Graph PVCs      
      axes(handles.x_axis);
      hold on
      scatter(pvc_r_locs, X(pvc_r_locs),80,'^','MarkerEdgeColor','[0, 0.5, 0]','LineWidth',0.9)
      hold off
      
      axes(handles.y_axis);
      hold on
      scatter(pvc_r_locs, Y(pvc_r_locs),80,'^','MarkerEdgeColor','[0, 0.5, 0]','LineWidth',0.9)
      hold off
      
      axes(handles.z_axis);
      hold on
      scatter(pvc_r_locs, Z(pvc_r_locs),80,'^','MarkerEdgeColor','[0, 0.5, 0]','LineWidth',0.9)
        
      axes(handles.vm_axis);
      hold on
      scatter(pvc_r_locs, VM(pvc_r_locs),80,'^','MarkerEdgeColor','[0, 0.5, 0]','LineWidth',0.9)
      hold off
      
      