function out = median_intervals(median_vcg, medianbeat, hr)

qon = medianbeat.Q;
qoff = medianbeat.S;
toff = medianbeat.Tend;

qt = (toff - qon) * median_vcg.sample_time();
qtc_b = qt/sqrt(60/hr);
qtc_f = qt/nthroot((60/hr),3);

jt = (toff - qoff) * median_vcg.sample_time();

qrs = (qoff-qon) * median_vcg.sample_time();

% Save output to structure
out = struct;

out.qt = qt;
out.qtc_b = qtc_b;
out.qtc_f = qtc_f;
out.jt = jt;
out.qrs = qrs;


