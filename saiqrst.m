%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% saiqrst.m -- Calculate area under absolute value of signal
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


% SAI QRST
% Integrate under absolute value of median X, Y, Z beats and then add
% together to get SAI QRST

% SAIVM is the areas under the absolute value of the VM lead


function [sai_x, sai_y, sai_z, sai_vm] = saiqrst(x, y, z, vm, sample_time, baseline_flag)

if strcmp(baseline_flag,'zero_baseline');  % zero baseline reference - do nothing to deal with baseline
end


if strcmp(baseline_flag,'Tend');  % Tend is zero reference
    x = x-x(end);
    y = y-y(end);
    z = z-z(end);
    vm = vm-vm(end);
end
   
    
if strcmp(baseline_flag,'Qon');  % QRS onset is zero reference
    x = x-x(1);
    y = y-y(1);
    z = z-z(1);
    vm = vm-vm(1);
end


if strcmp(baseline_flag,'Avg');  % Midpoint between QRS on and Tend is zero reference
    x = x - ((x(1)+x(end))/2);
    y = y - ((y(1)+y(end))/2);
    z = z - ((z(1)+z(end))/2);
    vm = vm - ((vm(1)+vm(end))/2);
end
  

sai_x = sample_time*(trapz(abs(x)));
sai_y = sample_time*(trapz(abs(y)));
sai_z = sample_time*(trapz(abs(z)));
sai_vm = sample_time*(trapz(abs(vm)));



