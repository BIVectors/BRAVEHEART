%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% changeGUIfont.m -- Adjust font in GUI on Mac computers
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

function changeGUIfont(handles)

        for field = fieldnames(handles)'
            field = field{1};
            try 
                set(handles.(field),'FontSize',get(handles.(field),'FontSize')*1.26); % Increase font size by 26% across GUI
            end   

            % Increase dropdown size
           
            switch field

                case  {'wavelet_type' , 'wavelet_type_lf'}
                   v = get(handles.(field),'Position');
                   x = [135 v(2) 70 v(4)];
                   set(handles.(field),'Position',x);

                case 'tend_method_dropdown'
                   v = get(handles.(field),'Position');
                   x = [5 v(2) 90 v(4)];
                   set(handles.(field),'Position',x);

                case {'wavelet_level_selection' , 'wavelet_level_selection_lf'}
                   v = get(handles.(field),'Position');
                   x = [245 v(2) 45 v(4)];
                   set(handles.(field),'Position',x);

                case 'ecg_source'
                   v = get(handles.(field),'Position');
                   x = [5 v(2) 115 v(4)];
                   set(handles.(field),'Position',x);

                case 'transform_mat_dropdown'
                   v = get(handles.(field),'Position');
                   x = [5 v(2) 90 v(4)];
                   set(handles.(field),'Position',x);

                case 'preset_fidpts'
                   v = get(handles.(field),'Position');
                   x = [4 v(2) 98 v(4)];
                   set(handles.(field),'Position',x);

                case 'align_dropdown'
                   v = get(handles.(field),'Position');
                   x = [7 0 85 30.6];
                   set(handles.(field),'Position',x);

                case {'text752' , 'text753' , 'text570'}
                   v = get(handles.(field),'Position');
                   x = [3 v(2) v(3) v(4)];
                   set(handles.(field),'Position',x);

                case {'corr_x_txt' , 'corr_y_txt' , 'corr_z_txt'}
                   v = get(handles.(field),'Position');
                   x = [4 v(2) v(3) v(4)];
                   set(handles.(field),'Position',x);

                case 'test52'
                   v = get(handles.(field),'Position');
                   x = [-16 v(2) v(3) v(4)];
                   set(handles.(field),'Position',x);

                case 'medianreanno_popup'
                   v = get(handles.(field),'Position');
                   x = [12 v(2) 110 v(4)];
                   set(handles.(field),'Position',x);

                case 'accel_box'
                   v = get(handles.(field),'Position');
                   x = [78 v(2) 110 v(4)];
                   set(handles.(field),'Position',x);

                case 'export_file_fmt_dropdown'
                   v = get(handles.(field),'Position');
                   x = [315 v(2) 55 v(4)];
                   set(handles.(field),'Position',x);

                case 'text51'
                   v = get(handles.(field),'Position');
                   x = [-1 v(2) v(3) v(4)];
                   set(handles.(field),'Position',x);

                case 'grid_popup'
                   v = get(handles.(field),'Position');
                   x = [162 v(2) 70 v(4)];
                   set(handles.(field),'Position',x);

                case 'text29'
                   v = get(handles.(field),'Position');
                   x = [0 v(2) v(3) v(4)];
                   set(handles.(field),'Position',x);

                case 'text30'
                   v = get(handles.(field),'Position');
                   x = [6 v(2) v(3) v(4)];
                   set(handles.(field),'Position',x);

                case 'text63'
                   v = get(handles.(field),'Position');
                   x = [v(1) v(2) v(3) v(4)+3];
                   set(handles.(field),'Position',x);

                case 'text576'
                   v = get(handles.(field),'Position');
                   x = [v(1) 53 v(3) v(4)+3];
                   set(handles.(field),'Position',x);

            end

        end

A = findobj;

for i = 1:length(A)

try
    if strcmp(A(i).Style,'pushbutton')
A(i).BackgroundColor = '[0.93 0.93 0.93]';

    end
end

end


            end

      