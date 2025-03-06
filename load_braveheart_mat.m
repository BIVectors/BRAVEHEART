function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_braveheart_mat(filename)

load(filename);

hz = data.ecg_raw.hz;

I = data.ecg_raw.I;
II = data.ecg_raw.II;
III = data.ecg_raw.III;

avR = data.ecg_raw.avR;
avL = data.ecg_raw.avL;
avF = data.ecg_raw.avF;

V1 = data.ecg_raw.V1;
V2 = data.ecg_raw.V2;
V3 = data.ecg_raw.V3;
V4 = data.ecg_raw.V4;
V5 = data.ecg_raw.V5;
V6 = data.ecg_raw.V6;
