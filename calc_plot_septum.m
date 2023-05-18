function [geh, med_intervals, septumbeat, septumvcg]...
    = calc_plot_septum(median_vcg, beatsig_vcg, aps, hObject, eventdata, handles)

[~, medianQRS] = max(median_vcg.VM);

% annotate original median beat
medRR = median(diff(handles.beats.QRS));
aps.STend = round(aps.STend * medRR/100);
medianbeat = Beats(median_vcg, medianQRS, aps);

% Calculate VCG_Calc - note VCG_Calc does its own cropping
geh = VCG_Calc(median_vcg, medianbeat, aps);

% plot septum annotations
qrspct = aps.septumwindow;
window = round(medianbeat.QRSdur() * qrspct/100);
septumvcg = median_vcg.crop(1, medianbeat.Q+window);

% check for a z-peak to display
zpeak = geh.septum_t_end * median_vcg.hz/1000 + medianbeat.Q-1;
tspeedmax = geh.septum_t_speed_max * median_vcg.hz/1000 + medianbeat.Q-1;
if isempty(zpeak) || isnan(zpeak) 
	septumbeat = Beats(NaN, NaN, NaN, NaN, NaN);
else
	septumbeat = Beats(medianbeat.Q, NaN, NaN, NaN, zpeak);
	beatsig_septum = beatsig_vcg.crop2d(1, medianbeat.Q+window);
	display_medianbeats(septumvcg, beatsig_septum, septumbeat, tspeedmax, hObject, eventdata, handles);
end

% Calculate median beat intervals
    med_intervals = median_intervals(median_vcg, medianbeat, handles.hr);

end