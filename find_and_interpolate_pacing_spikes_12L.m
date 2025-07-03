%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% find_and_interpolate_pacing_spikes_12L.m -- Find +/- interpolate pacing spikes
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

function [spikeless_ecg, spikes_lead, lead_ispaced] = find_and_interpolate_pacing_spikes_12L(ecg, aps, debug)

spikeless_ecg = [];                 % Signal without pacing spikes
lead_ispaced = struct;              % Binary value 1/0 if lead is paced/not
spikes_lead = [];                   % Contains the spike signals only

% Preallocate structures s and e to store start/end of mod Z score spikes
s = struct;
e = struct;

S = [];
E = [];

% ECG frequency
hz = ecg.hz;

% Thresholds and windows
pacer_zcut = aps.pacer_zcut;                % Cutoff for mod Z score to identify pacing
pacer_zpk = aps.pacer_zpk;                  % Percent of mod Z peak to define peak on/off
pacer_maxscale = aps.pacer_maxscale;        % Scale cutoff for frequencies to include in pacer spike
win = round(50*hz/1000);                    % 50 ms window around spike peak

% Get lead fieldnames from ECG12 class and remove Hz and units
ecg_fn = fieldnames(ecg);
ecg_fn(1:2) = [];

% Loop through each lead
for jj = 1:length(ecg_fn)

    % Preallocate locations and widths of spikes in case nothing is found
    % Currently not using widths, but may use to refine algorithm in future
    sp_locs = [];
    %widths_lead = [];
    
    % s and e are start and end of Z score peaks
    % store in a structure for easier access later
    s.(ecg_fn{jj}) = [];
    e.(ecg_fn{jj}) = [];

    % s1 and e1 are the start and end for the specific lead
    % this is a temp variable
    s1 = [];
    e1 = [];
    
    % Load ECG lead
    signal = ecg.(ecg_fn{jj});
    
    % Mirror signal to minimze edge effects
    mirr_signal=mirror(signal);
    
    % Perform CWT
    [coefficients, freqs] = cwt(mirr_signal, hz);

    % Previously used actual frequency cutoff - switched to max scale to
    % avoid having to adjust for different sampling frequencies etc.  This
    % code remains in case it will be useful at some point in the future
    %     [coefficients, freqs] = cwt(mirr_signal, hz);
    %     % Can't have pacer_freq > max freq bin in CWT
    %     assert(pacer_freq < max(freqs),'Set pacer_freq must be < maximum freq in CWT.  Try again with lower value of pacer_freq');
    %     
    %     % Choose row to keep based on frequency
    %     % Keep frequencies > freq_cut
    %     maxrow = max(find(freqs > pacer_freq));

    % Take the first N scales (highest freq parts of signal) where N is
    % pacer_maxscale
    maxrow = aps.pacer_maxscale;
    small_scale_range = 1:maxrow; 
    cutfreq = freqs(maxrow);

    % Keep only the frequency coeffients in the selected scale range
    high_freq_coeffs = sum(abs(coefficients(small_scale_range, :)), 1);

    % Take mod Z score
    z = mod_z_score(middlethird(high_freq_coeffs));

    % store z in structure Z for use in debug figure
    Z.(ecg_fn{jj}) = z;
    
    % Find spikes of Z score
    [sp_locs, ~] = wavelet_find_spikes(z,aps);
    
    % If do not find any spikes, assign 0 to lead_ispaced and go to next lead
    if isempty(sp_locs)
        lead_ispaced.(ecg_fn{jj}) = 0;
        continue
    else
        % Assign lead as paced and continue
        lead_ispaced.(ecg_fn{jj}) = 1;
    end
    
    % If a Z peak was found 
    % Loop through each peak that was found
    for i = 1:length(sp_locs)

        % Value at cutoff
        % If specify percent of peak value:
        if isnumeric(pacer_zpk)          
            pkcut = (pacer_zpk/100)*z(sp_locs(i));
     
        % s1 is the start of the peak based on when it first crosses the pkpct threshold
        % e1 is the end of the peak based on when it last crosses the pkpct threshold
        
        % for s1 look in window interval before the spike location
        % Have to check to make sure window won't make a negative index
        if sp_locs(i)-win <= 0
            s1 = find(z(1:sp_locs(i)) > pkcut,1, 'first');
            s.(ecg_fn{jj})(i) = 1 + s1;
        else
            s1 =  find(z(sp_locs(i)-win:sp_locs(i)) > pkcut,1, 'first');
            s.(ecg_fn{jj})(i) = sp_locs(i)-(win-s1)-2;
        end

        % for e1 look in window inderval after the spike location
        % Have to check to make sure window won't make an index > signal length
        if sp_locs(i)+win > length(z)
            e1 = find(z(sp_locs(i):length(z)) > pkcut, 1, 'last');
            e.(ecg_fn{jj})(i) = sp_locs(i)+e1-1;
        else
            e1 = find(z(sp_locs(i):sp_locs(i)+win) > pkcut, 1, 'last');
            e.(ecg_fn{jj})(i) = sp_locs(i)+e1;
        end

        
        % Specify 'Auto' for pacer_zpeak which sets the start/end to when
        % the area under the Z peak changes by < cp%.  This is nominally 
        % set to 1%.  This may be best for very large spikes or very wide
        % spikes, but may over estimate pacing spike width for small spikes
        % or spikes at low sampling rates
        else
%             cp = 1;             % cp is cut point for change in area of the Z spike
%             breakout = 0;       % variable to break out of loop
% 
%             % Take area from the Z peak and then walk backwards and
%             % forwards and calculate the change in area.  When the change
%             % is < cp% that is the location will use for interpolation.
% 
%             area_z = trapz(z(sp_locs(i)-1:sp_locs(i))); 
%             stpt = [];
%             w = 2;
% 
%             while breakout == 0
%                 area_z2 = trapz(z(sp_locs(i)-w:sp_locs(i)));
%                 
%                 if area_z2 < (1+(cp/100))*area_z
%                     stpt = w;
%                     breakout = 1;
%                 else
%                     area_z = area_z2;
%                     w = w+1;
%                 end
%             end
% 
%             area_z = trapz(z(sp_locs(i):sp_locs(i)+1)); 
%             endpt = [];
%             w=2;
%             breakout = 0;
% 
%             while breakout == 0
%                 area_z2 = trapz(z(sp_locs(i):sp_locs(i)+w));
%                 
%                 if area_z2 < (1+(cp/100))*area_z
%                     endpt = w;
%                     breakout = 1;
%                 else
%                     area_z = area_z2;
%                     w=w+1;
%                 end
%             
%             end
% 
%             % assign to s and e
%             s.(ecg_fn{jj})(i) = sp_locs(i) - stpt;
%             e.(ecg_fn{jj})(i) = sp_locs(i) + endpt;
       end
    end
end

% Now have all spike starts in 's' and spike ends in 'e'
% Want to make a list of all points to interpolate between s(i) and e(i)
% for ALL leads as may not see spikes in all leads

% If never found any pacing, break out here
if ~all(structfun(@isempty, s))

%     for k = 1:length(ecg_fn)
%         lead_ispaced.(ecg_fn{k}) = 0;
%         %cell2mat(struct2cell(lead_ispaced(:)))
%     end

% If pacing was found
% Initialize vector to store the points to interpolate
interp_ind = [];

% Loop through leads
for k = 1:length(ecg_fn)
    if ~isempty(s.(ecg_fn{k}))
        
        % Make sure have same number of starts and ends
        assert(length(s.(ecg_fn{k})) == length(e.(ecg_fn{k})))

        for j = 1:length(s.(ecg_fn{k}))
            interp_ind = [s.(ecg_fn{k})(j):e.(ecg_fn{k})(j) interp_ind];
        end
    end
end

% Will have manu duplicates, so sort and remove duplicates
interp_ind = unique(interp_ind);

% Need to now get back into format that interpolate can work with - need to
% interpolate in chunks

% Find breaks in order of samples to find start/end of contiguous samples
start_interp_ind = find(diff(interp_ind) > 1) + 1;
%start_interp_ind(end) = [];
start_interp_ind = [1 start_interp_ind];

end_interp_ind = find(diff(interp_ind) > 1);
end_interp_ind = [end_interp_ind numel(interp_ind)];


for ii = 1:length(start_interp_ind)
    S(ii) = interp_ind(start_interp_ind(ii));
    E(ii) = interp_ind(end_interp_ind(ii));
end

% Loop through each lead
for jj = 1:length(ecg_fn)
    sig_tmp = ecg.(ecg_fn{jj});

% Interpolate each start/end pair in each lead
for kk = 1:length(S)
    sig_tmp = interpolate_pacer_spikes(sig_tmp, S(kk), E(kk), aps.pacer_mf_samp(500));
end

% assign signal without spike to signal_nospike structure
signal_nospike.(ecg_fn{jj}) = sig_tmp;

end

% Create new ECG12 object with ECG with spike removed in all leads
spikeless_ecg = ECG12(hz, ecg.units, signal_nospike.I, signal_nospike.II, signal_nospike.III, ...
    signal_nospike.avR, signal_nospike.avF, signal_nospike.avL, ...
    signal_nospike.V1, signal_nospike.V2, signal_nospike.V3, ...
    signal_nospike.V4, signal_nospike.V5, signal_nospike.V6);

% Create ECG12 object with just the spikes in them
% Find where the original and spikeless signals the same (diff = 0), and assign
% those values as NaN.  What remains is what was removed with interpolation

% Loop through each lead
for jj = 1:length(ecg_fn)

    % make spikes all nan to start
    spikes = nan(1,length(ecg.(ecg_fn{jj})));

    % take difference between ecg and spikeless ecg
    sig = ecg.(ecg_fn{jj});
    sig_nospike = spikeless_ecg.(ecg_fn{jj});
    delta = sig - sig_nospike;

    % find set of points where delta is not = 0
    % note: the function 'find' finds non-zero elements by default
    spikepts_locs = find(delta);

    % assign values of ECG with spike to indices found in nanpts_locs and
    % assign to an ECG12 object
    spikes(spikepts_locs) = sig(spikepts_locs);
    spikes_lead.(ecg_fn{jj}) = spikes;

end

end


if debug == 1
figure
set(gcf, 'Position', [200, 200, 1500, 1000])  % set figure size
tiledlayout(6,2,'TileSpacing','tight','Padding','compact')

if isnumeric(pacer_zpk)
    sgtitle(sprintf('Pacemaker Spike Detection - Z Cutoff/%%Peak = %i/%i%%, Max Scale = %i (%0.1f Hz)',pacer_zcut, pacer_zpk, pacer_maxscale, cutfreq),'fontweight','bold','fontsize',12)
else
    sgtitle(sprintf('Pacemaker Spike Detection - Z Cutoff = %i, Max Scale = %i (%0.1f Hz)',pacer_zcut, pacer_maxscale, cutfreq),'fontweight','bold','fontsize',12)
end

for jj = 1:length(ecg_fn)
nexttile
hold on
title(sprintf('%s',string(ecg_fn{jj})));

yyaxis left
hold on
p1 = plot(Z.(ecg_fn{jj}),'linewidth',1,'Color','red');
p3 = line([0 length(ecg.(ecg_fn{jj}))],[pacer_zcut pacer_zcut],'color','r','linestyle','--','linewidth',1.5);
YL = get(gca,'ylim');
ylim([0 1.1*max(YL)]);
ylabel('Mod Z-Score')

yyaxis right
hold on
p2 = plot(ecg.(ecg_fn{jj}),'linewidth',0.8,'Color','black');

if ~isempty(S)
    s1 = scatter(s.(ecg_fn{jj}),ecg.(ecg_fn{jj})(s.(ecg_fn{jj})),20,'filled','b');
    s2 = scatter(e.(ecg_fn{jj}),ecg.(ecg_fn{jj})(e.(ecg_fn{jj})),20,'filled','b');
end
ylabel('mV')

    if jj == 2
        legend([p2 p1 p3 s1],{'ECG Signal','|Mod Z Score|','|Mod Z Score| Cutoff', 'On/Off Interpolation'},'Location','eastoutside','FontSize',10)
    end

ax = gca;
ax.YAxis(1).Color = 'r';
ax.YAxis(2).Color = 'k';

end
end  % End debug

