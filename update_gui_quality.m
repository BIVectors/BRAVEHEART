%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% update_gui_quality.m -- Part of BRAVEHEART GUI
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


function update_gui_quality(Q, aps, hObject, eventdata, handles)

% Get cutoff for probability from Qualparams

    QP = Qualparams();
    cutlow = QP.prob(1);
    cuthigh = QP.prob(2);

    % Bad quality - red
    if Q.prob_value < cutlow || Q.prob_value > cuthigh || isnan(Q.prob_value)
        set(handles.quality_panel, 'BackgroundColor', '[1,0,0]');
        set(handles.quality_score_txt, 'BackgroundColor', '[1,0,0]');
        set(handles.quality_score_txt, 'String', sprintf('%3.1f',(100*Q.prob_value)));

    % Good Quality - green
    else                
        set(handles.quality_panel, 'BackgroundColor', '[0.3922 0.8314 0.0745]')
        set(handles.quality_score_txt, 'BackgroundColor', '[0.3922 0.8314 0.0745]');
        set(handles.quality_score_txt, 'String', sprintf('%3.1f',(100*Q.prob_value)));
    end
    

    
    % Bad quality - red
    if Q.counter() > 0 
        set(handles.quality_count_panel, 'BackgroundColor', '[1,0,0]');
        set(handles.quality_count_txt, 'BackgroundColor', '[1,0,0]');
        set(handles.quality_count_txt, 'String', num2str(Q.counter()));

    % Good Quality - green
        else                
        set(handles.quality_count_panel, 'BackgroundColor', '[0.3922 0.8314 0.0745]')
        set(handles.quality_count_txt, 'BackgroundColor', '[0.3922 0.8314 0.0745]');
        set(handles.quality_count_txt, 'String', num2str(Q.counter()));    
    end
    



