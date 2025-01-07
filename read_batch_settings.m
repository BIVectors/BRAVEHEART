%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% read_batch_settings.m -- Read batch settings when running via executable
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

function [format, output_ext, output_note, parallel_proc, progressbar, ...
    save_figures, save_data, save_annotations, ...
    vcg_calc_flag, lead_morph_flag, vcg_morph_flag] ...
    = read_batch_settings(file)

A = readcell(file); % read in data from .csv file

varnames = A(:,1);
vals = A(:,2);

  for i = 1:length(varnames)
	B.(varnames{i}) = vals{i};
  end
  
% batch parameters are now stored in structure B

format = B.format;
output_ext = B.output_ext;
output_note = B.output_note;
parallel_proc = B.parallel_proc;
progressbar = B.progressbar;
save_figures = B.save_figures;
save_data = B.save_data;
save_annotations = B.save_annotations;
vcg_calc_flag = B.vcg_calc_flag;
lead_morph_flag = B.lead_morph_flag;
vcg_morph_flag = B.vcg_morph_flag;

