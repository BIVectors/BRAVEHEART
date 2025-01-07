%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% quality_figure.m -- Part of BRAVEHEART GUI - Figure for assessing quality
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

function quality_figure(quality, hObject, eventdata, handles)

% Make a single flag for either NNet issue
if quality.nnet_flag == 1 || quality.nnet_nan == 1
    nnet_flag = 1;
else
    nnet_flag = 0;
end
    
quality_matrix = [quality.qt quality.qrs quality.tpqt quality.t_mag quality.hr quality.num_beats ...
    quality.pct_beats_removed quality.corr quality.baseline quality.missing_lead quality.hf_noise quality.lf_noise ...
    quality.prob nnet_flag];

figure('name','Annotation Quality Assessment','numbertitle','off')
title('Annotation Quality Assessment','fontsize',12)
hold on

for i=1:length(quality_matrix)
    
    if quality_matrix(i) == 0     
        color(i) = 'g';
    else
        color(i) = 'r'; 
    end
    
    bar(i, 1, color(i))   
     
end
  
    text(1,0.4,'QT','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(2,0.4,'QRS','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(3,0.4,'Tpeak/QT','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(4,0.4,'Peak TMag','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(5,0.4,'HR','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(6,0.4,'# Beats','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(7,0.4,'# Removed','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(8,0.4,'Corr','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(9,0.4,'Baseline','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(10,0.35,{'Missing', 'Lead'},'vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(11,0.4,{'HF Noise'},'vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(12,0.4,{'LF Noise'},'vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    text(13,0.4,{'Prob'},'vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    
    if strcmp(handles.aps.median_reanno_method,'NNet')
        if nnet_flag == 1
            color(i) = 'r';
        else
            color(i) = 'g'; 
        end
    
        bar(14, 1, color(i));        
        text(14,0.4,'NNet Flag','vert','bottom','horiz','center','FontWeight','bold', 'Color','k', 'interpreter', 'none');
    end
    
hold off

ylim([0 1]);
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);

set(gcf, 'Position', [200, 100, 1600, 150])  % set figure size

InSet = get(gca, 'TightInset');
InSet(4) = InSet(4)+0.015;
InSet(3) = InSet(3)+0.015;
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

% Increase font size on mac due to pc/mac font differences
    if ismac
        fontsize(gcf,scale=1.25)
    end

