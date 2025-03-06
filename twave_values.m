%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% twave_values.m -- Measure parts of the T wave
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

function [twave_max, twave_max_loc] = twave_values(signal, freq, fidpts, vm)

% set debug = true if want to show figures for cases where decision about
% T wave max is more complex
debug = false;

% round VM T wave max location in case there is some issue with fractional
% samples
vm = round(vm);

% load in fiducual points and then find the magnitude of T peak
% zero reference for this calculation is the start of the QRS complex or
% fiducial point q(i).  If Qoff or Toff is missing return NaN for the T
% wave max
if isnan(fidpts(3)) || isnan(fidpts(4))
    twave_max = NaN;
    twave_max_loc = NaN;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if vm == 0 

% If don't supply a VM T peak location (set vm = 0 as convention), then will
% assume that are looking for a T wave peak in the VM lead which is always
% positive.  This is done separately from other leads because the VM T max
% location is used to help find the T peak of other leads when there are
% multiple candidate T peaks.  This helps narrow the T peak search window
% and in practice works better for non VM leads than just using a percent 
% of the JT window

% Window start at 30% of the JT interval - Percent window is only used for
% VM T peak detection
win_pct = 0.3;
jt = fidpts(4) - fidpts(3);

% window limits 30% to 100% of JT interval
win_st = fidpts(3) + round(win_pct*jt);
win_end = fidpts(4);

% Will do peak finding on absolute value of signal shifted by jpt voltage
% Using findpeaks is more robust than just finding the maximum value,
% because this adds some additional protection against finding just a high
% value due to ST segment deviation or noise.  In general, if there is large ST
% deviation in VM (all positive) which is large in amplitude compared to
% the T wave max amplitude, there will not be a "peak" as the ST segment
% declines.

% Remember that find peaks will find "Peaks", not troughs, so a negative T
% wave will NOT be found as a possible T wave peak using findpeaks.
% Therefore have to invert the signal to avoid missing negative T wave max
% peaks.  This is only an issue for non VM beats


else

% Not a VM beat -- need to look in window around the location of the VM T max 
% and need to look for positive and negative T waves.  Had tried using absolute 
% value of the signal but this is not useful because small negative peaks
% that can be true T wave peaks can get lost as they are folded up into
% positive peaks and may be less than ST deviation.
    
% open 100 ms window around T peak of VM.  This value seems to work well
% for most ECGs, could need to modify for edge cases.  As of now this is
% not able to be edited in Annoparams as should have minimal need to change
blank = round(100*freq/1000);

win_st = vm - blank;
win_end = vm + blank;

% Make sure window does not end after Toff or before Qoff
if win_end > fidpts(4)
   win_end = fidpts(4);
end

if win_st < fidpts(3)
   win_st = fidpts(3)+1;
end

end  % end vm/not vm branch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get J point voltage and shift so that J point voltage is "zero" reference
% to reduce issues with large ST deviations
shift_signal = signal - signal(fidpts(3));

% Different shift for negative signal (use same ref for both but invert J point for negative signal)
neg_signal = -signal;
neg_shift_signal = neg_signal - neg_signal(fidpts(3));

% findpeaks requires a minimum peak prominance of 0.01 mV (1/10 of a small box) 
% to avoid effects of random noise and to decrease number of false peak 
% detections.  A T wave max < 0.01 mV may therefore not be detected using this
% method, although such a T wave max value has questionable value as opposed 
% to just saying "can't find the max", as if the T wave max is so low
% amplitude it basically falls into the noise of the signal and detection
% is not likely ot be accurate anyway

% findpeaks is also set to only find the single maximum peak in the search window

% Find POSITIVE T wave peak
[~,pos_locs, w_pos, p_pos] = findpeaks(shift_signal(win_st:win_end),'MinPeakProminence',0.01,'MinPeakDistance',win_end-win_st-1,'SortStr','descend');

% Find NEGATIVE T wave peak
[~,neg_locs, w_neg, p_neg] = findpeaks(neg_shift_signal(win_st:win_end),'MinPeakProminence',0.01,'MinPeakDistance',win_end-win_st-1,'SortStr','descend');

% Shift back to frame of entire median beat
if ~isempty(pos_locs)
    twave_max_pos_loc = pos_locs(1);
    twave_max_pos_loc = twave_max_pos_loc + win_st -1; 
else
    twave_max_pos_loc = nan;
end

if ~isempty(neg_locs)
    twave_max_neg_loc = neg_locs(1);
    twave_max_neg_loc = twave_max_neg_loc + win_st -1; 
else
    twave_max_neg_loc = nan;
end


% Logic to check location of actual T max

% First check: is one of the pos/neg peaks empty/NaN, if so take the other as T peak
if isnan(twave_max_pos_loc) && ~isnan(twave_max_neg_loc)
   twave_max_loc = twave_max_neg_loc;
   twave_max = signal(twave_max_neg_loc);
   return;
end

if isnan(twave_max_neg_loc) && ~isnan(twave_max_pos_loc)
   twave_max_loc = twave_max_pos_loc;
   twave_max = signal(twave_max_pos_loc);
   return;
end

% If both are NaN then return NaN
if isnan(twave_max_neg_loc) && isnan(twave_max_pos_loc)
   twave_max_loc = nan;
   twave_max = nan;
   return;
end

% If have both positive and negative locations, look at the peak width and
% peak magnitude relative to J point.  True T wave should have a wider peak compared to a
% spike due to noise/artifact.  

if w_pos >= w_neg && abs(signal(twave_max_pos_loc)-signal(fidpts(3))) >= abs(signal(twave_max_neg_loc)-signal(fidpts(3))) 
    % Positive T wave is wider and more larger - choose positive
    twave_max_loc = twave_max_pos_loc;
    twave_max = signal(twave_max_loc);

elseif w_pos < w_neg && abs(signal(twave_max_pos_loc)-signal(fidpts(3))) < abs(signal(twave_max_neg_loc)-signal(fidpts(3)))
    % Negative T wave is wider and more larger - choose negative
    twave_max_loc = twave_max_neg_loc;
    twave_max = signal(twave_max_loc);

elseif (w_pos >= w_neg && abs(signal(twave_max_pos_loc)-signal(fidpts(3))) < abs(signal(twave_max_neg_loc)-signal(fidpts(3)))) ||...
        (w_pos < w_neg && abs(signal(twave_max_pos_loc)-signal(fidpts(3))) >= abs(signal(twave_max_neg_loc)-signal(fidpts(3))))
    % Discordant wideness and prominance - look at peak prominance
    if p_pos  >= p_neg
        twave_max_loc = twave_max_pos_loc;
        twave_max = signal(twave_max_loc);
    else
        twave_max_loc = twave_max_neg_loc;
        twave_max = signal(twave_max_loc); 
    end
 
else 
    % Some other combination - catch error
    twave_max_loc = nan;
    twave_max = nan; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if debug

figure

subplot(1,3,1)
hold on
if vm > 0
scatter(vm,shift_signal(vm),100,'g','filled')
end
tmp_pos = [nan(1,win_st-1) shift_signal(win_st:win_end)' nan(1,length(shift_signal)-win_end)]';
findpeaks(tmp_pos,'MinPeakProminence',0.01,'MinPeakDistance',win_end-win_st-1,'SortStr','descend','Annotate','extents')
plot(shift_signal,'color', 'k','LineWidth',0.75)
plot(tmp_pos, 'r','LineWidth',2)
scatter(fidpts(3),shift_signal(fidpts(3)),'m','filled')
scatter(fidpts(4),shift_signal(fidpts(4)),'m','filled')
line([0 length(tmp_pos)],[shift_signal(fidpts(3)) shift_signal(fidpts(3))],'Color','k')
ylim auto
hold off

subplot(1,3,2)
hold on
if vm > 0
scatter(vm,neg_shift_signal(vm),100,'g','filled')
end
tmp_neg = [nan(1,win_st-1) neg_shift_signal(win_st:win_end)' nan(1,length(shift_signal)-win_end)]';
findpeaks(tmp_neg,'MinPeakProminence',0.01,'MinPeakDistance',win_end-win_st-1,'SortStr','descend','Annotate','extents')
plot(neg_shift_signal,'color', 'k','LineWidth',0.75)
plot(tmp_neg, 'b','LineWidth',2)
scatter(fidpts(3),neg_shift_signal(fidpts(3)),'m','filled')
scatter(fidpts(4),neg_shift_signal(fidpts(4)),'m','filled')
line([0 length(tmp_neg)],[neg_shift_signal(fidpts(3)) neg_shift_signal(fidpts(3))],'Color','k')
ylim auto
hold off


subplot(1,3,3)
hold on
if vm > 0
scatter(vm,signal(vm),100,'g','filled')
end
plot(signal,'color', 'k','LineWidth',0.75)
scatter(fidpts(3),signal(fidpts(3)),'m','filled')
scatter(fidpts(4),signal(fidpts(4)),'m','filled')
line([0 length(signal)],[signal(fidpts(3)) signal(fidpts(3))],'color','k')
line([0 length(signal)],[0 0],'color','c')
if ~isnan(twave_max_pos_loc)
scatter(twave_max_pos_loc, signal(twave_max_pos_loc),'r','filled')
text(twave_max_pos_loc,signal(twave_max_pos_loc),sprintf('width = %0.2f, prom = %0.3f, amp = %0.3f, ampJ =%0.3f',w_pos, p_pos, abs(signal(twave_max_pos_loc)),abs(signal(twave_max_pos_loc)-signal(fidpts(3)))))
end
if ~isnan(twave_max_neg_loc)
scatter(twave_max_neg_loc, signal(twave_max_neg_loc),'b','filled')
text(twave_max_neg_loc,signal(twave_max_neg_loc),sprintf('width = %0.2f, prom = %0.3f, amp = %0.3f, ampJ = %0.3f',w_neg, p_neg, abs(signal(twave_max_neg_loc)),abs(signal(twave_max_neg_loc)-signal(fidpts(3)))))
end
if ~isnan(twave_max_loc)
scatter(twave_max_loc,signal(twave_max_loc),100,'r','d')
end

end % end figure block

    
end  % end function
