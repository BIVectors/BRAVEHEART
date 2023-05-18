%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% module_output.m -- Ouptuts selected results classes
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


function [geh, lead_morph, vcg_morph] = module_output(median_12L, median_vcg, medianbeat, ap, flags)

assert(isa(median_12L, 'ECG12'), 'First argument is not an ECG class');
assert(isa(median_vcg, 'VCG'), 'Second argument is not a VCG class');
assert(isa(medianbeat, 'Beats'), 'Third argument is not a Beats class');
assert(isa(ap, 'Annoparams'), 'Fourth argument is not an Annoparams class');

% Flags is a structure with multiple values to simplify input:
% flags.vcg_calc_flag
% flags.lead_morph_flag
% flags.vcg_morph_flag 

% Outputs the class with values or class filled with NaNs if there is an error

if flags.vcg_calc_flag == 1
    try
        geh = VCG_Calc(median_vcg, medianbeat, ap);
    catch
        geh = VCG_Calc.allnan();
    end
else
    geh = VCG_Calc.allnan();
end
    

if flags.lead_morph_flag == 1
    try
      lead_morph = Lead_Morphology(median_12L, median_vcg, medianbeat, ap);
    catch
      lead_morph = Lead_Morphology.allnan();
    end
else
    lead_morph = Lead_Morphology.allnan();
end


if flags.vcg_morph_flag == 1
    try
      vcg_morph = VCG_Morphology(median_12L, median_vcg, medianbeat);
    catch ME
      vcg_morph = VCG_Morphology.allnan();
    end
else
    vcg_morph = VCG_Morphology.allnan();
end


