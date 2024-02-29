%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% twave_values.m -- Measure parts of the T wave
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

function [twave_max, twave_max_loc] = twave_values(signal, freq, fidpts, vm)

vm = round(vm);

% load in fiducual points and then find the magnitude of T peak
% zero reference for this calculation is the start of the QRS complex or
% fiducial point q(i)

if isnan(fidpts(3)) || isnan(fidpts(4))
    twave_max = NaN;
    twave_max_loc = NaN;
    return;
end

if isempty(vm) || vm == 0 

    % blank for 50 ms after QRS offset
    blank = round(50*freq/1000);

    [twave_pos, twave_pos_index] = max(signal(fidpts(3)+blank:fidpts(4)));  % reads in t wave from QRS end to T end - finds max postive value
    % adjust index for slicing out of full signal
    twave_pos_index = twave_pos_index + fidpts(3)+blank-1;
    
    [twave_neg, twave_neg_index] = max(-signal(fidpts(3)+blank:fidpts(4)));  % reads in t wave from QRS end to T end - finds max negative value
    % adjust index for slicing out of full signal
    twave_neg_index = twave_neg_index + fidpts(3)+blank-1;
    
    % find if absolute value of positive or negative T wave maximum is larger - this is value to be reported

    % Choose if use the pos or neg value of T wave as the max value/location
    
    % will use the location of QRS off as reference as this works better
    % than using absolute value for biphaisc leads
    
    v = signal(fidpts(3));
    
    diff_pos = abs(twave_pos - v);
    diff_neg = abs(-twave_neg - v);
%     
%     
    if diff_pos >= diff_neg
        twave_max = twave_pos;  
        twave_max_loc = twave_pos_index;
    else
        twave_max = -twave_neg;  % need extra negative sign here
        twave_max_loc = twave_neg_index;
    end
    
%     locs = 1;
    
else
    
    
     % open window around T peak of VM
    blank = round(80*freq/1000);
    
    win_st = vm - blank;
    win_end = vm + blank;

    if win_end > length(signal)
        win_end = length(signal);
    end
    
    % peak finding on absolute value of signal
    [~,locs] = findpeaks(abs(signal(win_st:win_end)),'MinPeakDistance',blank,'MinPeakProminence',0.01);
    locs = locs + win_st -1; 
    
    [~, twave_pos_index] = max(signal(win_st:win_end));  % reads in t wave from QRS end to T end - finds max postive value
    % adjust index for slicing out of full signal
    twave_pos_index = twave_pos_index + win_st -1;
    
    [~, twave_neg_index] = max(-signal(win_st:win_end));  % reads in t wave from QRS end to T end - finds max negative value
    % adjust index for slicing out of full signal
    twave_neg_index = twave_neg_index + win_st -1;
    
    % find if absolute value of positive or negative T wave maximum is larger - this is value to be reported

    % Choose if use the pos or neg value of T wave as the max value/location
    
    % v is reference as this works better
    % than using absolute value for biphaisc leads
    
    % v = signal(fidpts(3));
%     v = 0;
%     
%     diff_pos = abs(twave_pos - v);
%     diff_neg = abs(-twave_neg - v);
    
    % Find intersection of locations with findpeaks and locations that are
    % maxima or minima.  T wave peak should be overlap between these.  This
    % helps deal with biphasic T waves and avoid choosing the limits of the
    % window around the T peak of VM as the T peak of other leads with
    % biphasic T waves
    
%     locs
%     twave_pos_index
%     twave_neg_index
%     
    twave_max_loc = intersect(locs, [twave_pos_index twave_neg_index]);
    
    % now deal with if get 2 values from tmax2 due to a truly biphasic T
    % wave that has both peaks within the window around VM T max location.
    % Will choose the value closer to VM tmax loc (vm)
    
        if length(twave_max_loc) > 1
            for i = 1:length(twave_max_loc)
                diff_vm(i) = abs(twave_max_loc(i)-vm);
            end
            
           
           q = find(diff_vm == min(diff_vm));
           
           if length(q) == 1
           
                twave_max_loc = twave_max_loc(q);
             
           else
               % take location with max abs value of signal
               abs_signal = abs(signal);
               mag_vm = abs_signal(twave_max_loc(q));
               q = find(mag_vm == max(mag_vm));
               twave_max_loc = twave_max_loc(q);
               
           end
               
            
        end
    
    
        % if cant find a T peak due to low voltage etc, use the location
        % from the VM lead as an approximation
    
        if ~isnan(twave_max_loc)
            
           twave_max = signal(twave_max_loc);
            
        else
            twave_max_loc = vm;
            twave_max = signal(twave_max_loc);
        
        end
    
    
%         figure
%     hold on
%     plot(signal)
% %     scatter(fidpts(1), signal(fidpts(1)))
% %     scatter(fidpts(3), signal(fidpts(3)))
%     scatter(fidpts(4), signal(fidpts(4)))
%     scatter(win_st,signal(win_st),'b','filled')
%     scatter(win_end,signal(win_end),'b','filled')
%     scatter(twave_pos_index,signal(twave_pos_index),'k','*')
%     scatter(twave_neg_index,signal(twave_neg_index),'k','*')
%     scatter(locs, signal(locs),'m')
%     scatter(twave_max_loc,signal(twave_max_loc),70,'r','d')

    
    
end

    
    
end
