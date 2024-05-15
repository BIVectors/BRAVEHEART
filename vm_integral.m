%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% vm_integral.m -- Calculate area under vector magnitude lead
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


% Integrate under VM median beat

function [VM_area, VMQ_area, VMT_area] = vm_integral(vm, qend, sample_time, baseline_flag)

if strcmp(baseline_flag,'zero_baseline')  % zero baseline reference - do nothing to deal with baseline
end


if strcmp(baseline_flag,'Tend')  % Tend is zero reference
    vm = vm-vm(end);
end
   
    
if strcmp(baseline_flag,'Qon')  % QRS onset is zero reference
    vm = vm-vm(1);
end


if strcmp(baseline_flag,'Avg')  % Midpoint between QRS on and Tend is zero reference
    vm = vm - ((vm(1)+vm(end))/2);
end
  
% Segment out QRS and T wave
vm_qrs = vm(1:qend);
vm_t = vm(qend:end);

VM_area = trapz(vm)*sample_time;
VMQ_area = trapz(vm_qrs)*sample_time;
VMT_area = trapz(vm_t)*sample_time;




