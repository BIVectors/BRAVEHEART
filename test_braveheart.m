%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% test_braveheart.m -- Testing framework for BRAVHEART
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

% This *very long* file is used to test if the output from BRAVEHEART is
% expected, so that any accidential changes to the core functions can be
% caught before the program breaks.

% There are a series of tests that go through the different steps of
% ECG/VCG processing.

% To cut down on extra files in the BRAVEHEART Repo, the actual results are
% hardcoded in this file.

% A Failure at any point in the test requires investigation - the name of
% the failed function/line of failure should point you in the right direction

% Most functions test multiple things.  Many functions test ALL
% outputs given that it is possible that some sub-sub functions could be
% changed to affect only SOME results.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main function
function tests = test_braveheart
    tests = functiontests(localfunctions);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reused code for Annoparam values
function ap = aparam()
    % Make sure Annoparams used in tests doesn't change if Annoparams.m is edited.
    ap = Annoparams();                  % Blank Annoparams class
    ap.maxBPM = 150;                    % Sets window for detecting R peaks
    ap.pkthresh = 95;                   % Percentile of ECG signal above which a peak can be found
    ap.lowpass = 1;                     % Low pass wavelet filter on/off
    ap.highpass = 1;                    % High pass wavelet filter on/off
    ap.wavelet_level_lowpass = 2;       % Lvl 2 at 500 Hz and Lvl 3 at 997 Hz is 62.5 Hz low-pass filter
    ap.wavelet_level_highpass = 10;     % Lvl 10 is 0.24 Hz at 500 Hz
    ap.wavelet_name_lowpass = 'Sym4';   % Low-pass wavelet (Sym4, Sym5, Sym6, db4, db8)
    ap.wavelet_name_highpass = 'db4';   % High-pass wavelet (Sym4, Sym5, Sym6, db4, db8)
    ap.baseline_correct_flag = 1;       % Corrects baseline offset
    ap.transform_matrix_str = 'Kors';   % Kors or Dower transformation matrix
    ap.baseline_flag = 'zero_baseline'; % Zero reference for area calculations
    ap.origin_flag = 'zero_origin';     % Origin for VCG plotting
    ap.autoMF = 1;                      % Auto estimate QRS width
    ap.autoMF_thresh = 20;              % Percent Rpeak threshold if autoMF = true
    ap.MF_width = 40;                   % Length of median filter (in ms) used when autoMF = true
    ap.QRwidth = 100;                   % Width of QR search window in ms
    ap.RSwidth = 100;                   % Width of RS search window in ms
    ap.STstart = 100;                   % Distance between Qoff and start of Tend search window in ms
    ap.STend = 45;                      % Length of Tend search window as a percent of RR interval
    ap.spike_removal = 1;               % Remove pacemaker spikes
    ap.pacer_spike_width = 20;          % Max width of pacing spike (in ms)
    ap.pacer_mf = 4;                    % Pacer spike detection median filter (in ms)
    ap.pacer_thresh = 20;               % Percent peak of pacer spike used for spike removal
    ap.align_flag = 'CoV';              % Beat alignment method ('CoV' or 'Rpeak')
    ap.cov_mf = 40;                     % width of CoV median filter (in ms)
    ap.cov_thresh = 30;                 % CoV median filter threshold %
    ap.shiftq = -40;                    % Q window expand when calculating median beat (in ms)
    ap.shiftt = 60;                     % T window expand when calculating median beat (in ms)
    ap.Tendstr = 'Energy';              % Tend detection method ('Energy', 'Tangent', or 'Baseline')
    ap.median_reanno_method = 'NNet';   % 'NNet' for neural network and 'Std' for standard annotations
    ap.outlier_removal = 1;             % Remove outliers
    ap.modz_cutoff = 4;                 % Cutoff for mod Z-score to flag an outlier (higher less sensitive)
    ap.pvc_removal = 1;                 % Remove PVCs
    ap.pvcthresh = 0.95;                % Cross correlation threshold for PVC removal
    ap.rmse_pvcthresh = 0.1;            % Normalized RMSE threshold for PVC removal
    ap.keep_pvc = 0;                    % Set = 1 if PVC removal removes native QRS instead of PVCs
    ap.blanking_samples = 0;            % Blanking window (in samples) to ignore in speed calculations
    ap.debug = 0;                       % Debug mode (generates debug annotation figures)
end

% Reused code for Qualparams values
function qp = qparam()
        qp = Qualparams();                  % Blank Qualparams class
        qp.qrs = [70, 200];                 % Min/max range of QRS duration
        qp.qt = [250, 700];                 % Min/max range of QT interval
        qp.tpqt = [0.5, Inf];               % Min/max range of T peak/QT ratio (nominal is min only)
        qp.t_mag = [0.05, Inf];             % Min/max range for T wave magnitude (nominal is min only)
        qp.hr = [30, 150];                  % Min/max range for HR
        qp.num_beats = [4, Inf];            % # of beats left after PVC and outlier beats are removed
        qp.pct_beats_removed = [-Inf, 60];  % of total number of beats removed to trigger
        qp.corr = [0.8,1];                  % Min/max range for average normalized cross correlation (nomimal min only)
        qp.baseline = [-Inf, 0.1];          % Min/max range for baseline at the end of the T wave (nominal max only)
        qp.hf_noise = [10, Inf];            % SNR for HF noise cutoff
        qp.prob = [0.8, 1];                 % Logistic regression probability (range 0-1)
        qp.lf_noise = [-Inf, 0.02];         % mV for cutoff in variance in LF noise
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Individual tests are from this point down:

%% Check that braveheart_batch executes without errors

% Checking with serial processing and all extra file generation
% This also tests output file formatting which can be problematic if you
% add new results that are not part of the output classes
function test_braveheart_batch(testCase)
    braveheart_batch('Example ECGs', 'muse_xml', '.csv', 'test', 0, 0, 1, 1, 1, 1, 1, 1)
end


%% Check raw VCG signals using batch_calc

% Load example1.xml and check that a segment of the raw VCG (samples 200:250)
% is correct when using the Kors matrix using batch_calc
function test_raw_vcg_transformation_using_braveheart(testCase)

% Load ECG (example1.xml)
ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Make sure use Kors matrix even if defaults are changed in Annoparams.m
ap = aparam(); 
ap.transform_matrix_str = 'Kors';

% Standard Qualparams
qp = qparam();

% Pass through batch_calc to get vcg_raw
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, vcg_raw, ~, ~, ~, ~] = batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Manually obtained 51 sample segments of X, Y, Z
V = ...
[-0.0810568	-0.0826672	0.028792	0.119302347
-0.0825208	-0.0751032	0.0243512	0.114206629
-0.0825208	-0.0751032	0.0243512	0.114206629
-0.0843752	-0.0747616	0.0238144	0.115219776
-0.0843752	-0.0747616	0.0238144	0.115219776
-0.0831064	-0.074664	0.020496	0.11358465
-0.083448	-0.0701256	0.0193736	0.1107091
-0.0813496	-0.0715408	0.0186904	0.109932591
-0.0811544	-0.0718824	0.0177144	0.109849515
-0.0852536	-0.068564	0.0150304	0.110431478
-0.0842288	-0.06344	0.011956	0.106122902
-0.0776408	-0.0635864	0.0142496	0.101362593
-0.0787632	-0.0635864	0.0083936	0.101574231
-0.081252	-0.0589016	-0.0029768	0.100399937
-0.075396	-0.0525576	-0.0061	    0.092109001
-0.075396	-0.047092	-0.0093208	0.089381713
-0.0757864	-0.0468968	-0.011712	0.08988915
-0.0752008	-0.036844	-0.0135176	0.084825504
-0.072468	-0.032696	-0.0156648	0.081031015
-0.0704184	-0.0333792	-0.016104	0.079575504
-0.0691984	-0.033428	-0.0176656	0.078853809
-0.0721752	-0.0325008	-0.0183976	0.081265203
-0.0721752	-0.0325008	-0.0183976	0.081265203
-0.0715408	-0.0284992	-0.0210328	0.079828999
-0.0660264	-0.0258152	-0.0210816	0.073961773
-0.05856	-0.0169336	-0.0189344	0.06383206
-0.06222	-0.0199592	-0.0183488	0.067870292
-0.060512	-0.01952	-0.0155672	0.065460448
-0.0589504	-0.0150792	-0.0154696	0.062784078
-0.0476776	-0.0177632	-0.0107848	0.052009583
-0.0469456	-0.0224968	-0.0072712	0.052562969
-0.049044	-0.0220576	-0.0075152	0.054298526
-0.0511424	-0.0257176	-0.0083448	0.057849596
-0.0603656	-0.0329888	-0.0011712	0.068801441
-0.056852	-0.0341112	0.0059536	0.066567028
-0.0558272	-0.0345992	0.0104432	0.066504446
-0.0606584	-0.03416	0.016348	0.071509469
-0.0604632	-0.0386496	0.0282064	0.077105066
-0.0555344	-0.049044	0.0403576	0.084368948
-0.0559736	-0.0508008	0.0448472	0.087892187
-0.0552904	-0.0508496	0.0476288	0.088944998
-0.0611952	-0.051972	0.046848	0.092955239
-0.0610976	-0.0564128	0.0482632	0.09614914
-0.0636352	-0.060512	0.0490928	0.100604393
-0.0613904	-0.065148	0.0514352	0.103240607
-0.0686128	-0.0732976	0.0609024	0.117428092
-0.0664168	-0.0781776	0.0625616	0.120153578
-0.0676856	-0.082472	0.0628544	0.123829103
-0.0737368	-0.0858392	0.0569008	0.126661695
-0.0803736	-0.1022848	0.0474336	0.138463144
-0.0834968	-0.105896	0.043432	0.141675746];

% Test values
testCase.verifyEqual(vcg_raw.X(200:250), V(:,1), "AbsTol", 1e-7)
testCase.verifyEqual(vcg_raw.Y(200:250), V(:,2), "AbsTol", 1e-7)
testCase.verifyEqual(vcg_raw.Z(200:250), V(:,3), "AbsTol", 1e-7)
testCase.verifyEqual(vcg_raw.VM(200:250), V(:,4), "AbsTol", 1e-9)

end


%% Check raw VCG signals using VCG constructor

% Load example1.xml and check that a segment of the raw VCG (200:250) is
% correct when using the Kors matrix using manual VCG construction
function test_raw_vcg_transformation_using_vcg_constructor(testCase)

% Load ECG (example1.xml)
ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Make sure use Kors matrix even if defaults are changed in Annoparams.m
ap = aparam(); 
ap.transform_matrix_str = 'Kors';

% Standard Qualparams
qp = qparam();

% Pass through batch_calc to get vcg_raw
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, vcg_raw, ~, ~, ~, ~] = batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Check vcg when just use VCG constructor with ecg
vcg_raw2 = VCG(ecg,ap);

% Test equivalency of vcg_raw and vcg_raw2
testCase.verifyEqual(vcg_raw, vcg_raw2)

end


%% Check calculation VCG_Calc of example1.xml with default Annoparams
function test_braveheart_ex1_vcg_calc_standard_annoparams(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam(); 

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, ~, ~, medianvcg1, ~, median_12L, ~, medianbeat, ...
    ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, 'example1.xml', []);

% Calculate results
[geh, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Verified results will be put into a structure because cant add to a
% VCG_Calc class (read only)

G = struct;
    G.svg_x = 100.15159835004;
    G.svg_y = 68.1359908648155;
    G.svg_z = -24.569946013672;
    G.sai_x = 103.858428403219;
    G.sai_y = 76.7530778333831;
    G.sai_z = 55.8943609706713;
    G.sai_vm = 148.486982743176;
    G.sai_qrst = 236.505867207274;
    G.q_peak_mag = 1.76133340662024;
    G.q_peak_az = 2.68906230135808;
    G.q_peak_el = 56.9359506869666;
    G.t_peak_mag = 0.759258867225018;
    G.t_peak_az = -21.3533367090749;
    G.t_peak_el = 55.1785714993309;
    G.svg_peak_mag = 2.48847067392229;
    G.svg_peak_az = -4.38836339118898;
    G.svg_peak_el = 55.9177822217226;
    G.q_area_mag = 37.7936858177582;
    G.q_area_az = 18.2497306608626;
    G.q_area_el = 65.5689608981901;
    G.t_area_mag = 92.5128141942523;
    G.t_area_az = -27.6478225890489;
    G.t_area_el = 55.4212256755028;
    G.svg_area_mag = 123.598293476539;
    G.svg_area_az = -13.7840037350141;
    G.svg_area_el = 56.5458384646829;
    G.peak_qrst_ratio = 2.31980617237657;
    G.area_qrst_ratio = 0.408523793670372;
    G.svg_qrs_angle_area = 29.3125430119111;
    G.svg_qrs_angle_peak = 5.98272124125288;
    G.svg_t_angle_area = 11.5370971854526;
    G.svg_t_angle_peak = 13.9922122453529;
    G.svg_svg_angle = 7.83295153341574;
    G.svg_area_qrs_peak_angle = 13.7658812469071;
    G.qrst_angle_peak_frontal = 3.66098649737606;
    G.qrst_angle_area_frontal = 12.3252865459133;
    G.qrst_angle_area = 40.8496401973636;
    G.qrst_angle_peak = 19.9749334866058;
    G.X_mid = 0;
    G.Y_mid = 0;
    G.Z_mid = 0;
    G.XQ_area = 32.6788453883312;
    G.YQ_area = 15.6313822075685;
    G.ZQ_area = 10.7756968247011;
    G.XT_area = 67.4727529617086;
    G.YT_area = 52.504608657247;
    G.ZT_area = -35.3456428383732;
    G.XQ_peak = 1.47447978760477;
    G.YQ_peak = 0.960941622774216;
    G.ZQ_peak = 0.0692526016947143;
    G.XT_peak = 0.58051464895218;
    G.YT_peak = 0.433552481126276;
    G.ZT_peak = -0.226955977936237;
    G.speed_max = 0.157531192520504;
    G.speed_min = 0.000412424575214347;
    G.speed_med = 0.00526220351860439;
    G.time_speed_max = 55;
    G.time_speed_min = 135;
    G.speed_qrs_max = 0.157531192520504;
    G.speed_qrs_min = 0.0057158477950232;
    G.speed_qrs_med = 0.040318179364392;
    G.time_speed_qrs_max = 55;
    G.time_speed_qrs_min = 91;
    G.speed_t_max = 0.0131299192612991;
    G.speed_t_min = 0.000412424575214347;
    G.speed_t_med = 0.00322298541145137;
    G.time_speed_t_max = 381;
    G.time_speed_t_min = 135;
    G.qrst_distance_area = 68.5377910743458;
    G.qrst_distance_peak = 1.07937597643328;
    G.vcg_length_qrst = 6.32505421447227;
    G.vcg_length_qrs = 4.73042642472082;
    G.vcg_length_t = 1.59462778975145;
    G.vm_tpeak_time = 344;
    G.vm_tpeak_tend_abs_diff = 102;
    G.vm_tpeak_tend_ratio = 0.771300448430493;
    G.vm_tpeak_tend_jt_ratio = 0.670967741935484;
    G.qrs_int = 94;
    G.qt_int = 446;
    G.baseline = 0.0237368929288424;
fnG = fieldnames(G);

% Loop through Structure G and compare to same field name in geh
% This way if add additional parameters in future it wont break the test
for i = 1:length(fnG)
    testCase.verifyEqual(geh.(fnG{i}),G.(fnG{i}),"AbsTol",1e-7)
end
end



%% Check calculation Lead_Morphology of example1.xml with default Annoparams
function test_braveheart_ex1_lead_morph_standard_annoparams(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam(); 

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, ~, ~, medianvcg1, ~, median_12L, ~, medianbeat, ...
    ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Calculate results
[~, lead_morph, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Verified results will be put into a structure because cant add to a
% VCG_Calc class (read only)

L = struct;
    L.L1_r_wave = 1.22737041327228;
    L.L1_s_wave = -0.100468779284365;
    L.L1_rs_wave = 1.32783919255665;
    L.L1_rs_ratio = 0.924336636659353;
    L.L1_sr_ratio = 0.0756633633406472;
    L.L1_t_max = 0.472434765451803;
    L.L1_t_max_loc = 348;
    L.L2_r_wave = 1.23300098034776;
    L.L2_s_wave = -0.229740896317191;
    L.L2_rs_wave = 1.46274187666495;
    L.L2_rs_ratio = 0.842938183433293;
    L.L2_sr_ratio = 0.157061816566707;
    L.L2_t_max = 0.55145552699255;
    L.L2_t_max_loc = 346;
    L.L3_r_wave = 0.0342122665008569;
    L.L3_s_wave = -0.340812498542213;
    L.L3_rs_wave = 0.37502476504307;
    L.L3_rs_ratio = 0.0912266860481274;
    L.L3_sr_ratio = 0.908773313951873;
    L.L3_t_max = 0.0796696060901795;
    L.L3_t_max_loc = 334;
    L.avF_r_wave = 0.624568180200316;
    L.avF_s_wave = -0.269834917578584;
    L.avF_rs_wave = 0.8944030977789;
    L.avF_rs_ratio = 0.698307264086323;
    L.avF_sr_ratio = 0.301692735913677;
    L.avF_t_max = 0.317046479649642;
    L.avF_t_max_loc = 340;
    L.avL_r_wave = 0.605019570589893;
    L.avL_s_wave = -0.0672395868040764;
    L.avL_rs_wave = 0.672259157393969;
    L.avL_rs_ratio = 0.899979663996349;
    L.avL_sr_ratio = 0.100020336003651;
    L.avL_t_max = 0.199336647255782;
    L.avL_t_max_loc = 340;
    L.avR_r_wave = 0.0917366621867849;
    L.avR_s_wave = -1.23819796648662;
    L.avR_rs_wave = 1.32993462867341;
    L.avR_rs_ratio = 0.0689783243544016;
    L.avR_sr_ratio = 0.931021675645598;
    L.avR_t_max = -0.513337018318627;
    L.avR_t_max_loc = 348;
    L.V1_r_wave = 0.18970168583508;
    L.V1_s_wave = -1.05005242164909;
    L.V1_rs_wave = 1.23975410748417;
    L.V1_rs_ratio = 0.153015573564052;
    L.V1_sr_ratio = 0.846984426435948;
    L.V1_t_max = -0.0143502406261112;
    L.V1_t_max_loc = 348;
    L.V2_r_wave = 0.53093924467163;
    L.V2_s_wave = -1.50653156805583;
    L.V2_rs_wave = 2.03747081272746;
    L.V2_rs_ratio = 0.260587411291987;
    L.V2_sr_ratio = 0.739412588708013;
    L.V2_t_max = 0.929308727791144;
    L.V2_t_max_loc = 336;
    L.V3_r_wave = 1.28299952152054;
    L.V3_s_wave = -0.517822426921702;
    L.V3_rs_wave = 1.80082194844225;
    L.V3_rs_ratio = 0.71245217920093;
    L.V3_sr_ratio = 0.28754782079907;
    L.V3_t_max = 0.563044419656922;
    L.V3_t_max_loc = 346;
    L.V4_r_wave = 1.54779598834339;
    L.V4_s_wave = -0.312404284006067;
    L.V4_rs_wave = 1.86020027234945;
    L.V4_rs_ratio = 0.832058790308908;
    L.V4_sr_ratio = 0.167941209691092;
    L.V4_t_max = 0.605759835795054;
    L.V4_t_max_loc = 348;
    L.V5_r_wave = 1.4953982498337;
    L.V5_s_wave = -0.149187892590126;
    L.V5_rs_wave = 1.64458614242383;
    L.V5_rs_ratio = 0.909285449547659;
    L.V5_sr_ratio = 0.0907145504523406;
    L.V5_t_max = 0.595372445866418;
    L.V5_t_max_loc = 348;
    L.V6_r_wave = 1.30020254500729;
    L.V6_s_wave = -0.107223826504265;
    L.V6_rs_wave = 1.40742637151155;
    L.V6_rs_ratio = 0.92381567613437;
    L.V6_sr_ratio = 0.0761843238656301;
    L.V6_t_max = 0.534033730677809;
    L.V6_t_max_loc = 348;
    L.X_r_wave = 1.47447978760477;
    L.X_s_wave = -0.117503456117004;
    L.X_rs_wave = 1.59198324372178;
    L.X_rs_ratio = 0.926190519541964;
    L.X_sr_ratio = 0.0738094804580363;
    L.X_t_max = 0.580939362852274;
    L.X_t_max_loc = 346;
    L.Y_r_wave = 0.960941622774216;
    L.Y_s_wave = -0.216294457738434;
    L.Y_rs_wave = 1.17723608051265;
    L.Y_rs_ratio = 0.816269258716362;
    L.Y_sr_ratio = 0.183730741283638;
    L.Y_t_max = 0.434990437019319;
    L.Y_t_max_loc = 340;
    L.Z_r_wave = 0.635312553903394;
    L.Z_s_wave = -0.16736614920931;
    L.Z_rs_wave = 0.802678703112704;
    L.Z_rs_ratio = 0.79149048235579;
    L.Z_sr_ratio = 0.20850951764421;
    L.Z_t_max = -0.227798568414126;
    L.Z_t_max_loc = 342;
    L.VM_r_wave = 1.76133340662024;
    L.VM_s_wave = 0;
    L.VM_rs_wave = 1.76133340662024;
    L.VM_rs_ratio = 1;
    L.VM_sr_ratio = 0;
    L.VM_t_max = 0.759258867225018;
    L.VM_t_max_loc = 344;
    L.cornell_lvh_mv = 1.1228419975116;
    L.sokolow_lvh_mv = 2.54545067148279;
    L.qrs_frontal_axis = 19.9753948024832;

    % Areas for 12L ECG medians
    L.L1_qrs_area = 28.6613287077627;
    L.L1_t_area = 57.0790620651604;
    L.L2_qrs_area = 21.3751610740212;
    L.L2_t_area = 66.724447488035;
    L.L3_qrs_area = -7.58191010032679;
    L.L3_t_area = 8.23761995666568;
    L.avR_qrs_area = -25.1515632067626;
    L.avR_t_area = -62.16738902966; 
    L.avL_qrs_area = 17.9178387916212;
    L.avL_t_area = 23.7038850835341;
    L.avF_qrs_area = 6.90676265965125;
    L.avF_t_area = 38.3635445107586;
    L.V1_qrs_area = -32.4312705447119;
    L.V1_t_area = 10.666514354212;
    L.V2_qrs_area = -26.8238652049473;
    L.V2_t_area = 139.350351498924;
    L.V3_qrs_area = 18.4648374962034;
    L.V3_t_area = 70.9762710348518;
    L.V4_qrs_area = 27.3170506561867;
    L.V4_t_area = 69.8575483724744;
    L.V5_qrs_area = 30.2317654289367;
    L.V5_t_area = 68.3053244533152;
    L.V6_qrs_area = 27.2268701124476;
    L.V6_t_area = 60.6552006179627;

fnL = fieldnames(L);

% Loop through Structure L and compare to same field name in lead_morph
% This way if add additional parameters in future it wont break the test

for i = 1:length(fnL)
    testCase.verifyEqual(lead_morph.(fnL{i}),L.(fnL{i}),"AbsTol",1e-7)
end
end


%% Check calculation VCG_Morph of example1.xml with default Annoparams
function test_braveheart_ex1_vcg_morph_standard_annoparams(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam(); 

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, ~, ~, medianvcg1, ~, median_12L, ~, medianbeat, ...
    ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Calculate results
[~, ~, vcg_morph] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Verified results will be put into a structure because cant add to a
% VCG_Calc class (read only)

V = struct;
    V.TCRT = 0.712987934764033;
    V.TCRT_angle = 44.5214551334312;
    V.tloop_residual = 0.00252206405297346;
    V.tloop_rmse = 0.00377477806656597;
    V.tloop_roundness = 13.7612841686039;
    V.tloop_area = 0.0169284093692822;
    V.tloop_perimeter = 1.65781805187524;
    V.qrsloop_residual = 0.0657525558510096;
    V.qrsloop_rmse = 0.0370114159897011;
    V.qrsloop_roundness = 2.40444385642316;
    V.qrsloop_area = 1.06146626883235;
    V.qrsloop_perimeter = 4.75134317217718;
    V.qrs_S1 = 4.33226693363748;
    V.qrs_S2 = 1.80177504334917;
    V.qrs_S3 = 0.256422611816918;
    V.t_S1 = 3.39331401448759;
    V.t_S2 = 0.24658411038625;
    V.t_S3 = 0.0502201558437792;
    V.qrs_var_s1_total = 84.9998031508298;
    V.qrs_var_s2_total = 14.7024136832135;
    V.qrs_var_s3_total = 0.297783165956673;
    V.t_var_s1_total = 99.453046270155;
    V.t_var_s2_total = 0.525170308049601;
    V.t_var_s3_total = 0.0217834217953821;
    V.qrs_loop_normal = [0.54733905702934; -0.814062339851085; -0.194222716195632];
    V.t_loop_normal = [0.510374524685172; -0.816423376477932; -0.270130921763424];
    V.qrst_dihedral_ang = 4.84081595239727;
fnV = fieldnames(V);


% Loop through Structure V and compare to same field name in vcg_morph
% This way if add additional parameters in future it wont break the test

for i = 1:length(fnV)
    testCase.verifyEqual(vcg_morph.(fnV{i}),V.(fnV{i}),"AbsTol",1e-7)
end
end


%% Check calculation of individual beats of example1.xml with default Annoparams
function test_braveheart_ex1_beats_standard_annoparams(testCase)

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam(); 

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, beats, ~, ~, ~, ~, ~, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Verified beat fiducial point results
% Individual
Q = [275 925 1533 2160 2768 3370 3991 4626];
R = [299 949 1558 2184 2792 3393 4015 4650];
S = [326 974 1585 2212 2814 3419 4042 4675];
Tend = [502 1153 1757 2396 2991 3610 4223 4858];

% Median
mQ = 22;
mR = 46;
mS = 69;
mT = 194;
mTend = 245;

% Test (no tolerance given integer values)
testCase.verifyEqual(beats.Q',Q);
testCase.verifyEqual(beats.QRS',R);
testCase.verifyEqual(beats.S',S);
testCase.verifyEqual(beats.Tend',Tend);

testCase.verifyEqual(medianbeat.Q,mQ);
testCase.verifyEqual(medianbeat.QRS,mR);
testCase.verifyEqual(medianbeat.S,mS);
testCase.verifyEqual(medianbeat.T,mT);
testCase.verifyEqual(medianbeat.Tend,mTend);

end



%% Check cross correlation of example1.xml with default Annoparams
function test_braveheart_crosscorr_standard_annoparams(testCase)

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam(); 

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, ~, corr, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

%Test
testCase.verifyEqual(corr.X,0.995);
testCase.verifyEqual(corr.Y,0.993);
testCase.verifyEqual(corr.Z,0.99);

end



%% Check output of VCG_Calc in example1.xml with no filtering/baseline correction
% NOTE that this results in outliers being removed

function test_braveheart_ex1_vcg_calc_nofiltering(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Annoparams - disable filtering and baseline correction
ap = aparam(); 
ap.lowpass = 0;
ap.highpass = 0;
ap.baseline_correct_flag = 0;

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, ~, ~, medianvcg1, ~, median_12L, ~, medianbeat, ...
    ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, 'example1.xml', []);

% Calculate results
[geh, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Verified results will be put into a structure because cant add to a
% VCG_Calc class (read only)

G = struct;
    G.svg_x = 59.9455296;
    G.svg_y = 45.0585528;
    G.svg_z = -13.2377076;
    G.sai_x = 90.1332096;
    G.sai_y = 67.6134248;
    G.sai_z = 48.8535092;
    G.sai_vm = 130.78120473369;
    G.sai_qrst = 206.6001436;
    G.q_peak_mag = 1.6672895285488;
    G.q_peak_az = 2.57796018096536;
    G.q_peak_el = 56.3678761530256;
    G.t_peak_mag = 0.664034878922124;
    G.t_peak_az = -23.4165407116574;
    G.t_peak_el = 53.6513143623329;
    G.svg_peak_mag = 2.29833988740673;
    G.svg_peak_az = -4.57096184970558;
    G.svg_peak_el = 55.0383122524802;
    G.q_area_mag = 30.1930486645215;
    G.q_area_az = 28.7587372646622;
    G.q_area_el = 67.8380901445348;
    G.t_area_mag = 55.690673560995;
    G.t_area_az = -36.9907259699626;
    G.t_area_el = 52.8020117397089;
    G.svg_area_mag = 76.1510118249125;
    G.svg_area_az = -12.452712633845;
    G.svg_area_el = 53.7222624500537;
    G.peak_qrst_ratio = 2.51084631466224;
    G.area_qrst_ratio = 0.542156284596786;
    G.svg_qrs_angle_area = 38.2923393618827;
    G.svg_qrs_angle_peak = 6.05224060643326;
    G.svg_t_angle_area = 19.6309382210858;
    G.svg_t_angle_peak = 15.3510033812562;
    G.svg_svg_angle = 6.5388132042219;
    G.svg_area_qrs_peak_angle = 12.5860326566239;
    G.qrst_angle_peak_frontal = 5.06825445870144;
    G.qrst_angle_area_frontal = 18.6174819716;
    G.qrst_angle_area = 57.9232775829685;
    G.qrst_angle_peak = 21.4032439876894;
    G.X_mid = 0;
    G.Y_mid = 0;
    G.Z_mid = 0;
    G.XQ_area = 24.5133624;
    G.YQ_area = 11.3895784;
    G.ZQ_area = 13.4533548;
    G.XT_area = 35.4321672;
    G.YT_area = 33.6689744;
    G.ZT_area = -26.6910624;
    G.XQ_peak = 1.3867984;
    G.YQ_peak = 0.9234424;
    G.ZQ_peak = 0.0624396;
    G.XT_peak = 0.4907816;
    G.YT_peak = 0.393572;
    G.ZT_peak = -0.2125484;
    G.speed_max = 0.156104104465193;
    G.speed_min = 0.000655175213206359;
    G.speed_med = 0.00600014307162755;
    G.time_speed_max = 57;
    G.time_speed_min = 143;
    G.speed_qrs_max = 0.156104104465193;
    G.speed_qrs_min = 0.0049989044079678;
    G.speed_qrs_med = 0.0400213780532355;
    G.time_speed_qrs_max = 57;
    G.time_speed_qrs_min = 15;
    G.speed_t_max = 0.016741720880483;
    G.speed_t_min = 0.000655175213206359;
    G.speed_t_med = 0.00360156315507586;
    G.time_speed_t_max = 395;
    G.time_speed_t_min = 143;
    G.qrst_distance_area = 47.1928598064683;
    G.qrst_distance_peak = 1.07667411356566;
    G.vcg_length_qrst = 6.44192595136287;
    G.vcg_length_qrs = 4.7819931601409;
    G.vcg_length_t = 1.65993279122197;
    G.vm_tpeak_time = 346;
    G.vm_tpeak_tend_abs_diff = 68;
    G.vm_tpeak_tend_ratio = 0.835748792270531;
    G.vm_tpeak_tend_jt_ratio = 0.746268656716418;
    G.qrs_int = 94;
    G.qt_int = 414;
    G.baseline = 0.0581244926618719;
fnG = fieldnames(G);

% Loop through Structure G and compare to same field name in geh
% This way if add additional parameters in future it wont break the test
for i = 1:length(fnG)
    testCase.verifyEqual(geh.(fnG{i}),G.(fnG{i}),"AbsTol",1e-7)
end


end


%% Check output of Lead_Morphology in example1.xml with no filtering/baseline correction
% NOTE that this results in outliers being removed
function test_braveheart_ex1_lead_morph_nofiltering(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Annoparams
ap = aparam();
ap.lowpass = 0;
ap.highpass = 0;
ap.baseline_correct_flag = 0;

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, ~, ~, medianvcg1, ~, median_12L, ~, medianbeat, ...
    ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, 'example1.xml', []);

% Calculate results
[~, lead_morph, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Verified results will be put into a structure because cant add to a
% VCG_Calc class (read only)

L = struct;
    L.L1_r_wave = 1.15656;
    L.L1_s_wave = -0.19032;
    L.L1_rs_wave = 1.34688;
    L.L1_rs_ratio = 0.858695652173913;
    L.L1_sr_ratio = 0.141304347826087;
    L.L1_t_max = 0.39772;
    L.L1_t_max_loc = 346;
    L.L2_r_wave = 1.17608;
    L.L2_s_wave = -0.30256;
    L.L2_rs_wave = 1.47864;
    L.L2_rs_ratio = 0.795379537953795;
    L.L2_sr_ratio = 0.204620462046205;
    L.L2_t_max = 0.488;
    L.L2_t_max_loc = 344;
    L.L3_r_wave = 0.05856;
    L.L3_s_wave = -0.3294;
    L.L3_rs_wave = 0.38796;
    L.L3_rs_ratio = 0.150943396226415;
    L.L3_sr_ratio = 0.849056603773585;
    L.L3_t_max = 0.10736;
    L.L3_t_max_loc = 360;
    L.avF_r_wave = 0.60268;
    L.avF_s_wave = -0.29524;
    L.avF_rs_wave = 0.89792;
    L.avF_rs_ratio = 0.671195652173913;
    L.avF_sr_ratio = 0.328804347826087;
    L.avF_t_max = 0.2928;
    L.avF_t_max_loc = 350;
    L.avL_r_wave = 0.5856;
    L.avL_s_wave = -0.12444;
    L.avL_rs_wave = 0.71004;
    L.avL_rs_ratio = 0.824742268041237;
    L.avL_sr_ratio = 0.175257731958763;
    L.avL_t_max = 0.15616;
    L.avL_t_max_loc = 338;
    L.avR_r_wave = 0.16592;
    L.avR_s_wave = -1.1712;
    L.avR_rs_wave = 1.33712;
    L.avR_rs_ratio = 0.124087591240876;
    L.avR_sr_ratio = 0.875912408759124;
    L.avR_t_max = -0.44164;
    L.avR_t_max_loc = 344;
    L.V1_r_wave = 0.20496;
    L.V1_s_wave = -1.0736;
    L.V1_rs_wave = 1.27856;
    L.V1_rs_ratio = 0.16030534351145;
    L.V1_sr_ratio = 0.83969465648855;
    L.V1_t_max = 0.00976;
    L.V1_t_max_loc = 346;
    L.V2_r_wave = 0.40992;
    L.V2_s_wave = -1.64944;
    L.V2_rs_wave = 2.05936;
    L.V2_rs_ratio = 0.199052132701422;
    L.V2_sr_ratio = 0.800947867298578;
    L.V2_t_max = 0.8296;
    L.V2_t_max_loc = 330;
    L.V3_r_wave = 1.2322;
    L.V3_s_wave = -0.61;
    L.V3_rs_wave = 1.8422;
    L.V3_rs_ratio = 0.66887417218543;
    L.V3_sr_ratio = 0.33112582781457;
    L.V3_t_max = 0.488;
    L.V3_t_max_loc = 344;
    L.V4_r_wave = 1.4884;
    L.V4_s_wave = -0.38552;
    L.V4_rs_wave = 1.87392;
    L.V4_rs_ratio = 0.794270833333333;
    L.V4_sr_ratio = 0.205729166666667;
    L.V4_t_max = 0.52216;
    L.V4_t_max_loc = 346;
    L.V5_r_wave = 1.42984;
    L.V5_s_wave = -0.23912;
    L.V5_rs_wave = 1.66896;
    L.V5_rs_ratio = 0.85672514619883;
    L.V5_sr_ratio = 0.14327485380117;
    L.V5_t_max = 0.49776;
    L.V5_t_max_loc = 348;
    L.V6_r_wave = 1.23952;
    L.V6_s_wave = -0.17568;
    L.V6_rs_wave = 1.4152;
    L.V6_rs_ratio = 0.875862068965517;
    L.V6_sr_ratio = 0.124137931034483;
    L.V6_t_max = 0.45872;
    L.V6_t_max_loc = 344;
    L.X_r_wave = 1.3867984;
    L.X_s_wave = -0.2026664;
    L.X_rs_wave = 1.5894648;
    L.X_rs_ratio = 0.872493936323724;
    L.X_sr_ratio = 0.127506063676276;
    L.X_t_max = 0.4907816;
    L.X_t_max_loc = 346;
    L.Y_r_wave = 0.9234424;
    L.Y_s_wave = -0.270596;
    L.Y_rs_wave = 1.1940384;
    L.Y_rs_ratio = 0.773377472617296;
    L.Y_sr_ratio = 0.226622527382704;
    L.Y_t_max = 0.393572;
    L.Y_t_max_loc = 346;
    L.Z_r_wave = 0.6848104;
    L.Z_s_wave = -0.1445944;
    L.Z_rs_wave = 0.8294048;
    L.Z_rs_ratio = 0.825664862320546;
    L.Z_sr_ratio = 0.174335137679454;
    L.Z_t_max = -0.2140368;
    L.Z_t_max_loc = 338;
    L.VM_r_wave = 1.6672895285488;
    L.VM_s_wave = 0;
    L.VM_rs_wave = 1.6672895285488;
    L.VM_rs_ratio = 1;
    L.VM_sr_ratio = 0;
    L.VM_t_max = 0.664034878922124;
    L.VM_t_max_loc = 346;
    L.cornell_lvh_mv = 1.1956;
    L.sokolow_lvh_mv = 2.50344;
fnL = fieldnames(L);

for i = 1:length(fnL)
    testCase.verifyEqual(lead_morph.(fnL{i}),L.(fnL{i}),"AbsTol",1e-7)
end

end



%% Check output of VCG_Morphology in example1.xml with no filtering/baseline correction
% NOTE that this results in outliers being removed
function test_braveheart_ex1_vcg_morph_nofiltering(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Annoparams
ap = aparam(); 
ap.lowpass = 0;
ap.highpass = 0;
ap.baseline_correct_flag = 0;

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, ~, ~, medianvcg1, ~, median_12L, ~, medianbeat, ...
    ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, 'example1.xml', []);

% Calculate results
[~, ~, vcg_morph] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Verified results will be put into a structure because cant add to a
% VCG_Calc class (read only)

V = struct;
    V.TCRT = 0.659761705295642;
    V.TCRT_angle = 48.7182983841376;
    V.tloop_residual = 0.00284759678434361;
    V.tloop_rmse = 0.00420558397237745;
    V.tloop_roundness = 13.7201501587119;
    V.tloop_area = 0.0241183897465577;
    V.tloop_perimeter = 1.73963157835309;
    V.qrsloop_residual = 0.0534945695188998;
    V.qrsloop_rmse = 0.0333836816170777;
    V.qrsloop_roundness = 2.37944547815966;
    V.qrsloop_area = 1.08159670431966;
    V.qrsloop_perimeter = 4.78655439567685;
    V.qrs_S1 = 4.34365465947669;
    V.qrs_S2 = 1.82549030828654;
    V.qrs_S3 = 0.231288930817927;
    V.t_S1 = 3.32075030892347;
    V.t_S2 = 0.242034545577833;
    V.t_S3 = 0.053362878336383;
    V.qrs_var_s1_total = 84.7846487140875;
    V.qrs_var_s2_total = 14.9749613160376;
    V.qrs_var_s3_total = 0.240389969874839;
    V.t_var_s1_total = 99.4460333176144;
    V.t_var_s2_total = 0.528286771331644;
    V.t_var_s3_total = 0.0256799110539539;
    V.qrs_loop_normal = [0.551521123022741; -0.808550176831406; -0.205112316562505];
    V.t_loop_normal = [0.571456874162924; -0.812131862729187; -0.117808652109943];
    V.qrst_dihedral_ang = 5.13671109545711;
fnV = fieldnames(V);


for i = 1:length(fnV)
    testCase.verifyEqual(vcg_morph.(fnV{i}),V.(fnV{i}),"AbsTol",1e-7)
end

end



%% Check output of example2.xml with default Annoparams and PVC removal on
function test_braveheart_ex2_standard_annoparams(testCase)

% Removes 1 PVC giving 9 beats remaining

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example2.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam();

% Standard Qualparams
qp = qparam();

% Process ECG
[hr, ~, beats, ~, corr, medianvcg1, ~, median_12L, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Calculate results
[geh, lead_morph, vcg_morph] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Check various parameters
testCase.verifyEqual(length(beats.Q),9)
testCase.verifyEqual(hr,65.0289017341041,"AbsTol",1e-7)

% Verified beat fiducial point results
% Individual
Q = [187 663 1143 1634 2112 2595 3087 3583 4076];
R = [211 691 1168 1655 2133 2618 3112 3607 4099];
S = [238 716 1195 1680 2163 2645 3136 3631 4128];
Tend = [380 867 1336 1818 2300 2780 3280 3789 4247];

% Median
mQ = 24;
mR = 47;
mS = 73;
mT = 178;
mTend = 214;

% Test (no tolerance given integer values)
testCase.verifyEqual(beats.Q',Q);
testCase.verifyEqual(beats.QRS',R);
testCase.verifyEqual(beats.S',S);
testCase.verifyEqual(beats.Tend',Tend);

testCase.verifyEqual(medianbeat.Q,mQ);
testCase.verifyEqual(medianbeat.QRS,mR);
testCase.verifyEqual(medianbeat.S,mS);
testCase.verifyEqual(medianbeat.T,mT);
testCase.verifyEqual(medianbeat.Tend,mTend);

G = struct;
    G.svg_x = 10.3035028744086;
    G.svg_y = 2.68545652456826;
    G.svg_z = 27.9261832099368;
    G.sai_x = 50.9631590029939;
    G.sai_y = 25.1774729865321;
    G.sai_z = 73.1217238531444;
    G.sai_vm = 103.315417940135;
    G.sai_qrst = 149.26235584267;
    G.q_peak_mag = 1.51574638863042;
    G.q_peak_az = 55.9499538491065;
    G.q_peak_el = 73.5290187445335;
    G.t_peak_mag = 0.202683772667223;
    G.t_peak_az = -95.390914186526;
    G.t_peak_el = 95.0934674279708;
    G.svg_peak_mag = 1.3446594709189;
    G.svg_peak_az = 51.6120058260453;
    G.svg_peak_el = 72.1682854910041;
    G.q_area_mag = 56.1960940774084;
    G.q_area_az = 64.7881271738814;
    G.q_area_el = 81.4826265461393;
    G.t_area_mag = 26.6520032202791;
    G.t_area_az = -120.881980504178;
    G.t_area_el = 102.212049598292;
    G.svg_area_mag = 29.8872139367866;
    G.svg_area_az = 69.7482122385375;
    G.svg_area_el = 84.8448483225431;
    G.peak_qrst_ratio = 7.47838057622432;
    G.area_qrst_ratio = 2.10851295540328;
    G.svg_qrs_angle_area = 5.96245904948624;
    G.svg_qrs_angle_peak = 4.36247210280862;
    G.svg_t_angle_area = 167.348190901298;
    G.svg_t_angle_peak = 145.329916283109;
    G.svg_svg_angle = 21.7944837899608;
    G.svg_area_qrs_peak_angle = 17.6364323932566;
    G.qrst_angle_peak_frontal = 164.343541749682;
    G.qrst_angle_area_frontal = 176.507230779007;
    G.qrst_angle_area = 173.310649950784;
    G.qrst_angle_peak = 149.692388385918;
    G.X_mid = 0;
    G.Y_mid = 0;
    G.Z_mid = 0;
    G.XQ_area = 23.6736606870195;
    G.YQ_area = 8.32316402440138;
    G.ZQ_area = 50.2820417232208;
    G.XT_area = -13.3701578126109;
    G.YT_area = -5.63770749983312;
    G.ZT_area = -22.355858513284;
    G.XQ_peak = 0.81386453099707;
    G.YQ_peak = 0.429759107231149;
    G.ZQ_peak = 1.20433332162777;
    G.XT_peak = -0.0189670352631283;
    G.YT_peak = -0.0179944138591722;
    G.ZT_peak = -0.200990458345193;
    G.speed_max = 0.130862306828911;
    G.speed_min = 0.000338034131972517;
    G.speed_med = 0.00220956147471452;
    G.time_speed_max = 51;
    G.time_speed_min = 129;
    G.speed_qrs_max = 0.130862306828911;
    G.speed_qrs_min = 0.00245118331620867;
    G.speed_qrs_med = 0.0505003582888626;
    G.time_speed_qrs_max = 51;
    G.time_speed_qrs_min = 3;
    G.speed_t_max = 0.00599628203778781;
    G.speed_t_min = 0.000338034131972517;
    G.speed_t_med = 0.0017904974379205;
    G.time_speed_t_max = 357;
    G.time_speed_t_min = 129;
    G.qrst_distance_area = 82.7249356211182;
    G.qrst_distance_peak = 1.69382010850199;
    G.vcg_length_qrst = 5.24929732454109;
    G.vcg_length_qrs = 4.68003919517905;
    G.vcg_length_t = 0.569258129362032;
    G.vm_tpeak_time = 308;
    G.vm_tpeak_tend_abs_diff = 72;
    G.vm_tpeak_tend_ratio = 0.810526315789474;
    G.vm_tpeak_tend_jt_ratio = 0.694915254237288;
    G.qrs_int = 98;
    G.qt_int = 380;
    G.baseline = 0.0376450087922345;
fnG = fieldnames(G);

L = struct;
    L.L1_r_wave = 0.96030844772583;
    L.L1_s_wave = -0.0738958983811039;
    L.L1_rs_wave = 1.03420434610693;
    L.L1_rs_ratio = 0.928548068223392;
    L.L1_sr_ratio = 0.0714519317766078;
    L.L1_t_max = 0.10014074951604;
    L.L1_t_max_loc = 340;
    L.L2_r_wave = 0.551547148316949;
    L.L2_s_wave = -0.275246958737756;
    L.L2_rs_wave = 0.826794107054705;
    L.L2_rs_ratio = 0.667091291061241;
    L.L2_sr_ratio = 0.332908708938759;
    L.L2_t_max = -0.00825398307007288;
    L.L2_t_max_loc = 308;
    L.L3_r_wave = 0.0159697871929945;
    L.L3_s_wave = -0.439607762592477;
    L.L3_rs_wave = 0.455577549785472;
    L.L3_rs_ratio = 0.0350539380189268;
    L.L3_sr_ratio = 0.964946061981073;
    L.L3_t_max = -0.0944427593236442;
    L.L3_t_max_loc = 330;
    L.avF_r_wave = 0.145615873766241;
    L.avF_s_wave = -0.251935945148654;
    L.avF_rs_wave = 0.397551818914895;
    L.avF_rs_ratio = 0.366281492972903;
    L.avF_sr_ratio = 0.633718507027097;
    L.avF_t_max = -0.049415035272834;
    L.avF_t_max_loc = 330;
    L.avL_r_wave = 0.697394572586298;
    L.avL_s_wave = -0.0406459264716829;
    L.avL_rs_wave = 0.738040499057981;
    L.avL_rs_ratio = 0.944927241088311;
    L.avL_sr_ratio = 0.0550727589116891;
    L.avL_t_max = 0.0950268668553614;
    L.avL_t_max_loc = 330;
    L.avR_r_wave = 0.156645123014894;
    L.avR_s_wave = -0.737442446835309;
    L.avR_rs_wave = 0.894087569850203;
    L.avR_rs_ratio = 0.1752010969587;
    L.avR_sr_ratio = 0.8247989030413;
    L.avR_t_max = -0.0620692898727534;
    L.avR_t_max_loc = 362;
    L.V1_r_wave = 0.00726333569295347;
    L.V1_s_wave = -1.46409808090589;
    L.V1_rs_wave = 1.47136141659884;
    L.V1_rs_ratio = 0.00493647285501288;
    L.V1_sr_ratio = 0.995063527144987;
    L.V1_t_max = 0.181933851925408;
    L.V1_t_max_loc = 308;
    L.V2_r_wave = 0.0077629599303605;
    L.V2_s_wave = -1.96612147713843;
    L.V2_rs_wave = 1.97388443706879;
    L.V2_rs_ratio = 0.00393283405278197;
    L.V2_sr_ratio = 0.996067165947218;
    L.V2_t_max = 0.303790168511626;
    L.V2_t_max_loc = 312;
    L.V3_r_wave = 0.20009438062867;
    L.V3_s_wave = -1.99697477235281;
    L.V3_rs_wave = 2.19706915298148;
    L.V3_rs_ratio = 0.0910733193614487;
    L.V3_sr_ratio = 0.908926680638551;
    L.V3_t_max = 0.357257666308882;
    L.V3_t_max_loc = 320;
    L.V4_r_wave = 0.742332382958804;
    L.V4_s_wave = -1.61031288116323;
    L.V4_rs_wave = 2.35264526412204;
    L.V4_rs_ratio = 0.315530944796231;
    L.V4_sr_ratio = 0.684469055203769;
    L.V4_t_max = 0.265429733774057;
    L.V4_t_max_loc = 318;
    L.V5_r_wave = 0.805381871917325;
    L.V5_s_wave = -0.585862270465919;
    L.V5_rs_wave = 1.39124414238324;
    L.V5_rs_ratio = 0.578893270693439;
    L.V5_sr_ratio = 0.421106729306561;
    L.V5_t_max = -0.0243768716867454;
    L.V5_t_max_loc = 308;
    L.V6_r_wave = 1.13261450310196;
    L.V6_s_wave = -0.249974624789887;
    L.V6_rs_wave = 1.38258912789184;
    L.V6_rs_ratio = 0.819198184227699;
    L.V6_sr_ratio = 0.180801815772301;
    L.V6_t_max = -0.0884922966670911;
    L.V6_t_max_loc = 308;
    L.X_r_wave = 1.07751513105583;
    L.X_s_wave = -0.246101751618555;
    L.X_rs_wave = 1.32361688267439;
    L.X_rs_ratio = 0.814068742368031;
    L.X_sr_ratio = 0.185931257631969;
    L.X_t_max = -0.0189670352631283;
    L.X_t_max_loc = 308;
    L.Y_r_wave = 0.484008204623565;
    L.Y_s_wave = -0.225459814152223;
    L.Y_rs_wave = 0.709468018775788;
    L.Y_rs_ratio = 0.682212857823723;
    L.Y_sr_ratio = 0.317787142176277;
    L.Y_t_max = -0.0179944138591722;
    L.Y_t_max_loc = 308;
    L.Z_r_wave = 1.46162511419838;
    L.Z_s_wave = 0;
    L.Z_rs_wave = 1.46162511419838;
    L.Z_rs_ratio = 1;
    L.Z_sr_ratio = 0;
    L.Z_t_max = -0.200990458345193;
    L.Z_t_max_loc = 308;
    L.VM_r_wave = 1.51574638863042;
    L.VM_s_wave = 0;
    L.VM_rs_wave = 1.51574638863042;
    L.VM_rs_ratio = 1;
    L.VM_sr_ratio = 0;
    L.VM_t_max = 0.202683772667223;
    L.VM_t_max_loc = 308;
    L.cornell_lvh_mv = 2.69436934493911;
    L.sokolow_lvh_mv = 2.59671258400784;
fnL = fieldnames(L);

V=struct;
    V.TCRT = -0.816291852176477;
    V.TCRT_angle = 144.715298290859;
    V.tloop_residual = 0.00539778991720823;
    V.tloop_rmse = 0.00616543632282113;
    V.tloop_roundness = 2.25694207827829;
    V.tloop_area = 0.018106924558348;
    V.tloop_perimeter = 0.624177373642936;
    V.qrsloop_residual = 0.0626638311081301;
    V.qrsloop_rmse = 0.035401647167365;
    V.qrsloop_roundness = 1.3151348092123;
    V.qrsloop_area = 1.61458922802037;
    V.qrsloop_perimeter = 4.67187689214965;
    V.qrs_S1 = 3.96972064458352;
    V.qrs_S2 = 3.01848952424974;
    V.qrs_S3 = 0.250327447772173;
    V.t_S1 = 0.882242415973282;
    V.t_S2 = 0.390901664896205;
    V.t_S3 = 0.0734696530358503;
    V.qrs_var_s1_total = 63.2050660539297;
    V.qrs_var_s2_total = 36.5436012784412;
    V.qrs_var_s3_total = 0.251332667629108;
    V.t_var_s1_total = 83.1080778971787;
    V.t_var_s2_total = 16.3155760164361;
    V.t_var_s3_total = 0.576346086385209;
    V.qrs_loop_normal = [0.432345158618008; -0.900856309358753; 0.0391863969777214];
    V.t_loop_normal = [-0.473778119161415;  0.878416307319583; -0.0626025945061276];
    V.qrst_dihedral_ang = 3.01508727534999;
fnV = fieldnames(V);


% Loop through Structures and compare to same field name in geh
% This way if add additional parameters in future it wont break the test
for i = 1:length(fnG)
    testCase.verifyEqual(geh.(fnG{i}),G.(fnG{i}),"AbsTol",1e-7)
end

for i = 1:length(fnL)
    testCase.verifyEqual(lead_morph.(fnL{i}),L.(fnL{i}),"AbsTol",1e-7)
end

for i = 1:length(fnV)
    testCase.verifyEqual(vcg_morph.(fnV{i}),V.(fnV{i}),"AbsTol",1e-7)
end

% Correlation
testCase.verifyEqual(corr.X,0.994);
testCase.verifyEqual(corr.Y,0.98);
testCase.verifyEqual(corr.Z,0.994);

end


%% Check output of example2.xml with default Annoparams and PVC removal OFF
function test_braveheart_ex2_pvc_off(testCase)

% 10 beats

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example2.xml'), 'muse_xml');

ap = aparam();
% Disable PVC AND outlier removal or PVC will be removed
ap.pvc_removal = 0;
ap.outlier_removal = 0;

% Standard Qualparams
qp = qparam();

% Process ECG
[hr, ~, beats, ~, corr, medianvcg1, ~, median_12L, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Calculate results
[geh, lead_morph, vcg_morph] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Check various parameters
testCase.verifyEqual(length(beats.Q),10)
testCase.verifyEqual(hr,65.0289017341041,"AbsTol",1e-7)

% Verified beat fiducial point results
% Individual
Q = [187 663 1143 1634 2112 2595 3087 3583 4076 4312];
R = [211 691 1168 1655 2133 2618 3112 3607 4099 4363];
S = [238 716 1195 1680 2163 2645 3136 3631 4128 4386];
Tend = [380 867 1336 1818 2300 2780 3280 3789 4247 4587];

% Median
mQ = 41;
mR = 66;
mS = 94;
mT = 201;
mTend = 232;

% Test (no tolerance given integer values)
testCase.verifyEqual(beats.Q',Q);
testCase.verifyEqual(beats.QRS',R);
testCase.verifyEqual(beats.S',S);
testCase.verifyEqual(beats.Tend',Tend);

testCase.verifyEqual(medianbeat.Q,mQ);
testCase.verifyEqual(medianbeat.QRS,mR);
testCase.verifyEqual(medianbeat.S,mS);
testCase.verifyEqual(medianbeat.T,mT);
testCase.verifyEqual(medianbeat.Tend,mTend);

G = struct;
    G.svg_x = 9.84135593194044;
    G.svg_y = 2.40870754117796;
    G.svg_z = 27.5920043160413;
    G.sai_x = 51.5429121103217;
    G.sai_y = 25.4504967167569;
    G.sai_z = 70.8460872340353;
    G.sai_vm = 102.334475217474;
    G.sai_qrst = 147.839496061114;
    G.q_peak_mag = 1.52238590173659;
    G.q_peak_az = 55.0503449500122;
    G.q_peak_el = 72.9823040018439;
    G.t_peak_mag = 0.199717592287738;
    G.t_peak_az = -91.7241729597239;
    G.t_peak_el = 94.9491471000304;
    G.svg_peak_mag = 1.36293622567767;
    G.svg_peak_az = 50.2167971749383;
    G.svg_peak_el = 71.6835919529187;
    G.q_area_mag = 55.1366526340173;
    G.q_area_az = 64.2289724478794;
    G.q_area_el = 80.9642135139217;
    G.t_area_mag = 26.2734793887608;
    G.t_area_az = -122.824898357105;
    G.t_area_el = 103.762891780413;
    G.svg_area_mag = 29.3934152621724;
    G.svg_area_az = 70.3699942339681;
    G.svg_area_el = 85.2995013930808;
    G.peak_qrst_ratio = 7.62269304520378;
    G.area_qrst_ratio = 2.09856684066;
    G.svg_qrs_angle_area = 7.47987589310901;
    G.svg_qrs_angle_peak = 4.78494175824403;
    G.svg_t_angle_area = 164.145991121689;
    G.svg_t_angle_peak = 140.516635733601;
    G.svg_svg_angle = 23.940425830295;
    G.svg_area_qrs_peak_angle = 19.4179460655749;
    G.qrst_angle_peak_frontal = 137.275124653554;
    G.qrst_angle_area_frontal = 175.774710707854;
    G.qrst_angle_area = 171.625867014798;
    G.qrst_angle_peak = 145.301577491845;
    G.X_mid = 0;
    G.Y_mid = 0;
    G.Z_mid = 0;
    G.XQ_area = 23.6745984217133;
    G.YQ_area = 8.65928499910505;
    G.ZQ_area = 49.0365234958513;
    G.XT_area = -13.8332424897728;
    G.YT_area = -6.25057745792709;
    G.ZT_area = -21.44451917981;
    G.XQ_peak = 0.833922777596758;
    G.YQ_peak = 0.445552188964712;
    G.ZQ_peak = 1.193195240403;
    G.XT_peak = -0.00598668968586809;
    G.YT_peak = -0.0172299433319668;
    G.ZT_peak = -0.198882893353334;
    G.speed_max = 0.12810555869637;
    G.speed_min = 0.00022195145420247;
    G.speed_med = 0.00218403070160562;
    G.time_speed_max = 55;
    G.time_speed_min = 131;
    G.speed_qrs_max = 0.12810555869637;
    G.speed_qrs_min = 0.00227158284266926;
    G.speed_qrs_med = 0.0505391857079788;
    G.time_speed_qrs_max = 55;
    G.time_speed_qrs_min = 103;
    G.speed_t_max = 0.00751824274296733;
    G.speed_t_min = 0.00022195145420247;
    G.speed_t_med = 0.00155253920498448;
    G.time_speed_t_max = 105;
    G.time_speed_t_min = 131;
    G.qrst_distance_area = 81.220191485722;
    G.qrst_distance_peak = 1.69041318785869;
    G.vcg_length_qrst = 5.20992326976135;
    G.vcg_length_qrs = 4.68315038662014;
    G.vcg_length_t = 0.526772883141216;
    G.vm_tpeak_time = 320;
    G.vm_tpeak_tend_abs_diff = 62;
    G.vm_tpeak_tend_ratio = 0.837696335078534;
    G.vm_tpeak_tend_jt_ratio = 0.683673469387755;
    G.qrs_int = 106;
    G.qt_int = 382;
    G.baseline = 0.0369406786492704;
fnG = fieldnames(G);

L = struct;
    L.L1_r_wave = 0.929840133091332;
    L.L1_s_wave = -0.074417012237767;
    L.L1_rs_wave = 1.0042571453291;
    L.L1_rs_ratio = 0.925898448834656;
    L.L1_sr_ratio = 0.0741015511653445;
    L.L1_t_max = 0.101327407626422;
    L.L1_t_max_loc = 344;
    L.L2_r_wave = 0.563009506280742;
    L.L2_s_wave = -0.272440063448553;
    L.L2_rs_wave = 0.835449569729295;
    L.L2_rs_ratio = 0.673900049362848;
    L.L2_sr_ratio = 0.326099950637152;
    L.L2_t_max = -0.00768400355932999;
    L.L2_t_max_loc = 320;
    L.L3_r_wave = 0.0210358451008164;
    L.L3_s_wave = -0.435327115093519;
    L.L3_rs_wave = 0.456362960194335;
    L.L3_rs_ratio = 0.0460945495924092;
    L.L3_sr_ratio = 0.953905450407591;
    L.L3_t_max = -0.0956680753002816;
    L.L3_t_max_loc = 334;
    L.avF_r_wave = 0.149011037114484;
    L.avF_s_wave = -0.251517058602806;
    L.avF_rs_wave = 0.40052809571729;
    L.avF_rs_ratio = 0.372036415691703;
    L.avF_sr_ratio = 0.627963584308297;
    L.avF_t_max = -0.0494163109630158;
    L.avF_t_max_loc = 334;
    L.avL_r_wave = 0.685748565708682;
    L.avL_s_wave = -0.0429475251831255;
    L.avL_rs_wave = 0.728696090891807;
    L.avL_rs_ratio = 0.94106250092468;
    L.avL_sr_ratio = 0.0589374990753204;
    L.avL_t_max = 0.0963656362241506;
    L.avL_t_max_loc = 344;
    L.avR_r_wave = 0.154804386576625;
    L.avR_s_wave = -0.745209834344165;
    L.avR_rs_wave = 0.900014220920791;
    L.avR_rs_ratio = 0.172002156163985;
    L.avR_sr_ratio = 0.827997843836015;
    L.avR_t_max = -0.0578163176140377;
    L.avR_t_max_loc = 366;
    L.V1_r_wave = 0.0156685991293416;
    L.V1_s_wave = -1.42237671598358;
    L.V1_rs_wave = 1.43804531511293;
    L.V1_rs_ratio = 0.0108957617431626;
    L.V1_sr_ratio = 0.989104238256837;
    L.V1_t_max = 0.169042359154822;
    L.V1_t_max_loc = 314;
    L.V2_r_wave = 0.00864458377430902;
    L.V2_s_wave = -1.92988271905015;
    L.V2_rs_wave = 1.93852730282446;
    L.V2_rs_ratio = 0.00445935621423219;
    L.V2_sr_ratio = 0.995540643785768;
    L.V2_t_max = 0.301326917338578;
    L.V2_t_max_loc = 318;
    L.V3_r_wave = 0.206690447955633;
    L.V3_s_wave = -1.97799921804768;
    L.V3_rs_wave = 2.18468966600331;
    L.V3_rs_ratio = 0.0946086078823974;
    L.V3_sr_ratio = 0.905391392117603;
    L.V3_t_max = 0.348448823282859;
    L.V3_t_max_loc = 326;
    L.V4_r_wave = 0.757995960419321;
    L.V4_s_wave = -1.55826564921786;
    L.V4_rs_wave = 2.31626160963718;
    L.V4_rs_ratio = 0.327249718799274;
    L.V4_sr_ratio = 0.672750281200726;
    L.V4_t_max = 0.254617383568307;
    L.V4_t_max_loc = 322;
    L.V5_r_wave = 0.807041213540711;
    L.V5_s_wave = -0.578427123158494;
    L.V5_rs_wave = 1.3854683366992;
    L.V5_rs_ratio = 0.582504263838637;
    L.V5_sr_ratio = 0.417495736161363;
    L.V5_t_max = -0.0371561981669734;
    L.V5_t_max_loc = 336;
    L.V6_r_wave = 1.134098436251;
    L.V6_s_wave = -0.24492384535945;
    L.V6_rs_wave = 1.37902228161045;
    L.V6_rs_ratio = 0.822393119657629;
    L.V6_sr_ratio = 0.177606880342371;
    L.V6_t_max = -0.0924002277341018;
    L.V6_t_max_loc = 310;
    L.X_r_wave = 1.06765780741808;
    L.X_s_wave = -0.24365263192611;
    L.X_rs_wave = 1.31131043934419;
    L.X_rs_ratio = 0.814191495304526;
    L.X_sr_ratio = 0.185808504695474;
    L.X_t_max = -0.00598668968586809;
    L.X_t_max_loc = 320;
    L.Y_r_wave = 0.491596720642026;
    L.Y_s_wave = -0.22445307063886;
    L.Y_rs_wave = 0.716049791280886;
    L.Y_rs_ratio = 0.68653985606594;
    L.Y_sr_ratio = 0.31346014393406;
    L.Y_t_max = -0.0172299433319668;
    L.Y_t_max_loc = 320;
    L.Z_r_wave = 1.4329819320258;
    L.Z_s_wave = -0.00335226274534446;
    L.Z_rs_wave = 1.43633419477114;
    L.Z_rs_ratio = 0.997666098351242;
    L.Z_sr_ratio = 0.00233390164875841;
    L.Z_t_max = -0.198882893353334;
    L.Z_t_max_loc = 320;
    L.VM_r_wave = 1.52238590173659;
    L.VM_s_wave = 0;
    L.VM_rs_wave = 1.52238590173659;
    L.VM_rs_ratio = 1;
    L.VM_sr_ratio = 0;
    L.VM_t_max = 0.199717592287738;
    L.VM_t_max_loc = 320;
    L.cornell_lvh_mv = 2.66374778375636;
    L.sokolow_lvh_mv = 2.55647515223458;
fnL = fieldnames(L);

V=struct;
    V.TCRT = -0.818456637633067;
    V.TCRT_angle = 144.930594357545;
    V.tloop_residual = 0.00428055104785014;
    V.tloop_rmse = 0.00554935413174339;
    V.tloop_roundness = 2.40488147179763;
    V.tloop_area = 0.0168248415287265;
    V.tloop_perimeter = 0.597155731335133;
    V.qrsloop_residual = 0.0653631711319302;
    V.qrsloop_rmse = 0.0347912215226161;
    V.qrsloop_roundness = 1.37020764568717;
    V.qrsloop_area = 1.59921221984921;
    V.qrsloop_perimeter = 4.6906176362916;
    V.qrs_S1 = 4.10668435125973;
    V.qrs_S2 = 2.99712555552133;
    V.qrs_S3 = 0.255662220775636;
    V.t_S1 = 0.869615456813092;
    V.t_S2 = 0.361604289862595;
    V.t_S3 = 0.0654259203057179;
    V.qrs_var_s1_total = 65.0826559779207;
    V.qrs_var_s2_total = 34.6651029896402;
    V.qrs_var_s3_total = 0.252241032439069;
    V.t_var_s1_total = 84.8487746489625;
    V.t_var_s2_total = 14.6709494952328;
    V.t_var_s3_total = 0.480275855804739;
    V.qrs_loop_normal = [0.434927690845598; -0.899938757513714; 0.0307918245706357];
    V.t_loop_normal = [-0.437452537579758; 0.897457395589386; -0.056617139339121];
    V.qrst_dihedral_ang = 1.49356082331016;
fnV = fieldnames(V);


% Loop through Structures and compare to same field name in geh
% This way if add additional parameters in future it wont break the test
for i = 1:length(fnG)
    testCase.verifyEqual(geh.(fnG{i}),G.(fnG{i}),"AbsTol",1e-7)
end

for i = 1:length(fnL)
    testCase.verifyEqual(lead_morph.(fnL{i}),L.(fnL{i}),"AbsTol",1e-7)
end

for i = 1:length(fnV)
    testCase.verifyEqual(vcg_morph.(fnV{i}),V.(fnV{i}),"AbsTol",1e-7)
end

% Correlation
testCase.verifyEqual(corr.X,0.916);
testCase.verifyEqual(corr.Y,0.869);
testCase.verifyEqual(corr.Z,0.623);

end



%% Check output of example2.xml with default Annoparams and PVC removal OFF then manually remove PVC
function test_braveheart_ex2_manually_remove_pvc(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example2.xml'), 'muse_xml');

ap = aparam();
% Disable PVC AND outlier removal or PVC will be removed
ap.pvc_removal = 0;
ap.outlier_removal = 0;

% Standard Qualparams
qp = qparam();

% Process ECG
[hr, ~, beats, ~, corr, medianvcg1, ~, median_12L, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Remove beat # 10 = PVC
ovrbeats = beats.delete(10);

% Process again with overbeats 
[hr, ~, beats, ~, corr, medianvcg1, ~, median_12L, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, ovrbeats, [], [], [], [], ap, qp, 0, '', []);

% Should get same results as if processed with PVC removal on:

% Calculate results
[geh, lead_morph, vcg_morph] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Check various parameters
testCase.verifyEqual(length(beats.Q),9)
testCase.verifyEqual(hr,65.0289017341041,"AbsTol",1e-7)

% Verified beat fiducial point results
% Individual
Q = [187 663 1143 1634 2112 2595 3087 3583 4076];
R = [211 691 1168 1655 2133 2618 3112 3607 4099];
S = [238 716 1195 1680 2163 2645 3136 3631 4128];
Tend = [380 867 1336 1818 2300 2780 3280 3789 4247];

% Median
mQ = 24;
mR = 47;
mS = 73;
mT = 178;
mTend = 214;

% Test (no tolerance given integer values)
testCase.verifyEqual(beats.Q',Q);
testCase.verifyEqual(beats.QRS',R);
testCase.verifyEqual(beats.S',S);
testCase.verifyEqual(beats.Tend',Tend);

testCase.verifyEqual(medianbeat.Q,mQ);
testCase.verifyEqual(medianbeat.QRS,mR);
testCase.verifyEqual(medianbeat.S,mS);
testCase.verifyEqual(medianbeat.T,mT);
testCase.verifyEqual(medianbeat.Tend,mTend);

G = struct;
    G.svg_x = 10.3035028744086;
    G.svg_y = 2.68545652456826;
    G.svg_z = 27.9261832099368;
    G.sai_x = 50.9631590029939;
    G.sai_y = 25.1774729865321;
    G.sai_z = 73.1217238531444;
    G.sai_vm = 103.315417940135;
    G.sai_qrst = 149.26235584267;
    G.q_peak_mag = 1.51574638863042;
    G.q_peak_az = 55.9499538491065;
    G.q_peak_el = 73.5290187445335;
    G.t_peak_mag = 0.202683772667223;
    G.t_peak_az = -95.390914186526;
    G.t_peak_el = 95.0934674279708;
    G.svg_peak_mag = 1.3446594709189;
    G.svg_peak_az = 51.6120058260453;
    G.svg_peak_el = 72.1682854910041;
    G.q_area_mag = 56.1960940774084;
    G.q_area_az = 64.7881271738814;
    G.q_area_el = 81.4826265461393;
    G.t_area_mag = 26.6520032202791;
    G.t_area_az = -120.881980504178;
    G.t_area_el = 102.212049598292;
    G.svg_area_mag = 29.8872139367866;
    G.svg_area_az = 69.7482122385375;
    G.svg_area_el = 84.8448483225431;
    G.peak_qrst_ratio = 7.47838057622432;
    G.area_qrst_ratio = 2.10851295540328;
    G.svg_qrs_angle_area = 5.96245904948624;
    G.svg_qrs_angle_peak = 4.36247210280862;
    G.svg_t_angle_area = 167.348190901298;
    G.svg_t_angle_peak = 145.329916283109;
    G.svg_svg_angle = 21.7944837899608;
    G.svg_area_qrs_peak_angle = 17.6364323932566;
    G.qrst_angle_peak_frontal = 164.343541749682;
    G.qrst_angle_area_frontal = 176.507230779007;
    G.qrst_angle_area = 173.310649950784;
    G.qrst_angle_peak = 149.692388385918;
    G.X_mid = 0;
    G.Y_mid = 0;
    G.Z_mid = 0;
    G.XQ_area = 23.6736606870195;
    G.YQ_area = 8.32316402440138;
    G.ZQ_area = 50.2820417232208;
    G.XT_area = -13.3701578126109;
    G.YT_area = -5.63770749983312;
    G.ZT_area = -22.355858513284;
    G.XQ_peak = 0.81386453099707;
    G.YQ_peak = 0.429759107231149;
    G.ZQ_peak = 1.20433332162777;
    G.XT_peak = -0.0189670352631283;
    G.YT_peak = -0.0179944138591722;
    G.ZT_peak = -0.200990458345193;
    G.speed_max = 0.130862306828911;
    G.speed_min = 0.000338034131972517;
    G.speed_med = 0.00220956147471452;
    G.time_speed_max = 51;
    G.time_speed_min = 129;
    G.speed_qrs_max = 0.130862306828911;
    G.speed_qrs_min = 0.00245118331620867;
    G.speed_qrs_med = 0.0505003582888626;
    G.time_speed_qrs_max = 51;
    G.time_speed_qrs_min = 3;
    G.speed_t_max = 0.00599628203778781;
    G.speed_t_min = 0.000338034131972517;
    G.speed_t_med = 0.0017904974379205;
    G.time_speed_t_max = 357;
    G.time_speed_t_min = 129;
    G.qrst_distance_area = 82.7249356211182;
    G.qrst_distance_peak = 1.69382010850199;
    G.vcg_length_qrst = 5.24929732454109;
    G.vcg_length_qrs = 4.68003919517905;
    G.vcg_length_t = 0.569258129362032;
    G.vm_tpeak_time = 308;
    G.vm_tpeak_tend_abs_diff = 72;
    G.vm_tpeak_tend_ratio = 0.810526315789474;
    G.vm_tpeak_tend_jt_ratio = 0.694915254237288;
    G.qrs_int = 98;
    G.qt_int = 380;
    G.baseline = 0.0376450087922345;
fnG = fieldnames(G);

L = struct;
    L.L1_r_wave = 0.96030844772583;
    L.L1_s_wave = -0.0738958983811039;
    L.L1_rs_wave = 1.03420434610693;
    L.L1_rs_ratio = 0.928548068223392;
    L.L1_sr_ratio = 0.0714519317766078;
    L.L1_t_max = 0.10014074951604;
    L.L1_t_max_loc = 340;
    L.L2_r_wave = 0.551547148316949;
    L.L2_s_wave = -0.275246958737756;
    L.L2_rs_wave = 0.826794107054705;
    L.L2_rs_ratio = 0.667091291061241;
    L.L2_sr_ratio = 0.332908708938759;
    L.L2_t_max = -0.00825398307007288;
    L.L2_t_max_loc = 308;
    L.L3_r_wave = 0.0159697871929945;
    L.L3_s_wave = -0.439607762592477;
    L.L3_rs_wave = 0.455577549785472;
    L.L3_rs_ratio = 0.0350539380189268;
    L.L3_sr_ratio = 0.964946061981073;
    L.L3_t_max = -0.0944427593236442;
    L.L3_t_max_loc = 330;
    L.avF_r_wave = 0.145615873766241;
    L.avF_s_wave = -0.251935945148654;
    L.avF_rs_wave = 0.397551818914895;
    L.avF_rs_ratio = 0.366281492972903;
    L.avF_sr_ratio = 0.633718507027097;
    L.avF_t_max = -0.049415035272834;
    L.avF_t_max_loc = 330;
    L.avL_r_wave = 0.697394572586298;
    L.avL_s_wave = -0.0406459264716829;
    L.avL_rs_wave = 0.738040499057981;
    L.avL_rs_ratio = 0.944927241088311;
    L.avL_sr_ratio = 0.0550727589116891;
    L.avL_t_max = 0.0950268668553614;
    L.avL_t_max_loc = 330;
    L.avR_r_wave = 0.156645123014894;
    L.avR_s_wave = -0.737442446835309;
    L.avR_rs_wave = 0.894087569850203;
    L.avR_rs_ratio = 0.1752010969587;
    L.avR_sr_ratio = 0.8247989030413;
    L.avR_t_max = -0.0620692898727534;
    L.avR_t_max_loc = 362;
    L.V1_r_wave = 0.00726333569295347;
    L.V1_s_wave = -1.46409808090589;
    L.V1_rs_wave = 1.47136141659884;
    L.V1_rs_ratio = 0.00493647285501288;
    L.V1_sr_ratio = 0.995063527144987;
    L.V1_t_max = 0.181933851925408;
    L.V1_t_max_loc = 308;
    L.V2_r_wave = 0.0077629599303605;
    L.V2_s_wave = -1.96612147713843;
    L.V2_rs_wave = 1.97388443706879;
    L.V2_rs_ratio = 0.00393283405278197;
    L.V2_sr_ratio = 0.996067165947218;
    L.V2_t_max = 0.303790168511626;
    L.V2_t_max_loc = 312;
    L.V3_r_wave = 0.20009438062867;
    L.V3_s_wave = -1.99697477235281;
    L.V3_rs_wave = 2.19706915298148;
    L.V3_rs_ratio = 0.0910733193614487;
    L.V3_sr_ratio = 0.908926680638551;
    L.V3_t_max = 0.357257666308882;
    L.V3_t_max_loc = 320;
    L.V4_r_wave = 0.742332382958804;
    L.V4_s_wave = -1.61031288116323;
    L.V4_rs_wave = 2.35264526412204;
    L.V4_rs_ratio = 0.315530944796231;
    L.V4_sr_ratio = 0.684469055203769;
    L.V4_t_max = 0.265429733774057;
    L.V4_t_max_loc = 318;
    L.V5_r_wave = 0.805381871917325;
    L.V5_s_wave = -0.585862270465919;
    L.V5_rs_wave = 1.39124414238324;
    L.V5_rs_ratio = 0.578893270693439;
    L.V5_sr_ratio = 0.421106729306561;
    L.V5_t_max = -0.0243768716867454;
    L.V5_t_max_loc = 308;
    L.V6_r_wave = 1.13261450310196;
    L.V6_s_wave = -0.249974624789887;
    L.V6_rs_wave = 1.38258912789184;
    L.V6_rs_ratio = 0.819198184227699;
    L.V6_sr_ratio = 0.180801815772301;
    L.V6_t_max = -0.0884922966670911;
    L.V6_t_max_loc = 308;
    L.X_r_wave = 1.07751513105583;
    L.X_s_wave = -0.246101751618555;
    L.X_rs_wave = 1.32361688267439;
    L.X_rs_ratio = 0.814068742368031;
    L.X_sr_ratio = 0.185931257631969;
    L.X_t_max = -0.0189670352631283;
    L.X_t_max_loc = 308;
    L.Y_r_wave = 0.484008204623565;
    L.Y_s_wave = -0.225459814152223;
    L.Y_rs_wave = 0.709468018775788;
    L.Y_rs_ratio = 0.682212857823723;
    L.Y_sr_ratio = 0.317787142176277;
    L.Y_t_max = -0.0179944138591722;
    L.Y_t_max_loc = 308;
    L.Z_r_wave = 1.46162511419838;
    L.Z_s_wave = 0;
    L.Z_rs_wave = 1.46162511419838;
    L.Z_rs_ratio = 1;
    L.Z_sr_ratio = 0;
    L.Z_t_max = -0.200990458345193;
    L.Z_t_max_loc = 308;
    L.VM_r_wave = 1.51574638863042;
    L.VM_s_wave = 0;
    L.VM_rs_wave = 1.51574638863042;
    L.VM_rs_ratio = 1;
    L.VM_sr_ratio = 0;
    L.VM_t_max = 0.202683772667223;
    L.VM_t_max_loc = 308;
    L.cornell_lvh_mv = 2.69436934493911;
    L.sokolow_lvh_mv = 2.59671258400784;
fnL = fieldnames(L);

V=struct;
    V.TCRT = -0.816291852176477;
    V.TCRT_angle = 144.715298290859;
    V.tloop_residual = 0.00539778991720823;
    V.tloop_rmse = 0.00616543632282113;
    V.tloop_roundness = 2.25694207827829;
    V.tloop_area = 0.018106924558348;
    V.tloop_perimeter = 0.624177373642936;
    V.qrsloop_residual = 0.0626638311081301;
    V.qrsloop_rmse = 0.035401647167365;
    V.qrsloop_roundness = 1.3151348092123;
    V.qrsloop_area = 1.61458922802037;
    V.qrsloop_perimeter = 4.67187689214965;
    V.qrs_S1 = 3.96972064458352;
    V.qrs_S2 = 3.01848952424974;
    V.qrs_S3 = 0.250327447772173;
    V.t_S1 = 0.882242415973282;
    V.t_S2 = 0.390901664896205;
    V.t_S3 = 0.0734696530358503;
    V.qrs_var_s1_total = 63.2050660539297;
    V.qrs_var_s2_total = 36.5436012784412;
    V.qrs_var_s3_total = 0.251332667629108;
    V.t_var_s1_total = 83.1080778971787;
    V.t_var_s2_total = 16.3155760164361;
    V.t_var_s3_total = 0.576346086385209;
    V.qrs_loop_normal = [0.432345158618008; -0.900856309358753; 0.0391863969777214];
    V.t_loop_normal = [-0.473778119161415;  0.878416307319583; -0.0626025945061276];
    V.qrst_dihedral_ang = 3.01508727534999;
fnV = fieldnames(V);


% Loop through Structures and compare to same field name in geh
% This way if add additional parameters in future it wont break the test
for i = 1:length(fnG)
    testCase.verifyEqual(geh.(fnG{i}),G.(fnG{i}),"AbsTol",1e-7)
end

for i = 1:length(fnL)
    testCase.verifyEqual(lead_morph.(fnL{i}),L.(fnL{i}),"AbsTol",1e-7)
end

for i = 1:length(fnV)
    testCase.verifyEqual(vcg_morph.(fnV{i}),V.(fnV{i}),"AbsTol",1e-7)
end

% Correlation
testCase.verifyEqual(corr.X,0.994);
testCase.verifyEqual(corr.Y,0.98);
testCase.verifyEqual(corr.Z,0.994);


end



%% Check output of example2.xml with manually removing beat 4 with auto PVC removal
function test_braveheart_ex2_manually_remove_beat4(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example2.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam();

% Standard Qualparams
qp = qparam();

% Process ECG
[hr, ~, beats, ~, corr, medianvcg1, ~, median_12L, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

% Remove beat # 
ovrbeats = beats.delete(4);

% Process again with overbeats 
[hr, ~, beats, ~, corr, medianvcg1, ~, median_12L, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, ovrbeats, [], [], [], [], ap, qp, 0, '', []);

% Calculate results
[geh, lead_morph, vcg_morph] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Check various parameters
testCase.verifyEqual(length(beats.Q),8)
testCase.verifyEqual(hr,65.0289017341041,"AbsTol",1e-7)

% Verified beat fiducial point results
% Individual
Q = [187 663 1143 2112 2595 3087 3583 4076];
R = [211 691 1168 2133 2618 3112 3607 4099];
S = [238 716 1195 2163 2645 3136 3631 4128];
Tend = [380 867 1336 2300 2780 3280 3789 4247];

% Median
mQ = 24;
mR = 47;
mS = 73;
mT = 181;
mTend = 213;

% Test (no tolerance given integer values)
testCase.verifyEqual(beats.Q',Q);
testCase.verifyEqual(beats.QRS',R);
testCase.verifyEqual(beats.S',S);
testCase.verifyEqual(beats.Tend',Tend);

testCase.verifyEqual(medianbeat.Q,mQ);
testCase.verifyEqual(medianbeat.QRS,mR);
testCase.verifyEqual(medianbeat.S,mS);
testCase.verifyEqual(medianbeat.T,mT);
testCase.verifyEqual(medianbeat.Tend,mTend);

G = struct;
    G.svg_x = 11.1442220597536;
    G.svg_y = 1.93219953411276;
    G.svg_z = 25.4707770260973;
    G.sai_x = 50.7189069368143;
    G.sai_y = 25.6760812444425;
    G.sai_z = 72.4637746328317;
    G.sai_vm = 102.722338191608;
    G.sai_qrst = 148.858762814088;
    G.q_peak_mag = 1.52238590173659;
    G.q_peak_az = 55.0503449500122;
    G.q_peak_el = 72.9823040018439;
    G.t_peak_mag = 0.202358070859939;
    G.t_peak_az = -92.639859278894;
    G.t_peak_el = 94.9034225662924;
    G.svg_peak_mag = 1.35907289555154;
    G.svg_peak_az = 50.257779203384;
    G.svg_peak_el = 71.6326395911293;
    G.q_area_mag = 55.2877116322224;
    G.q_area_az = 63.5825737602922;
    G.q_area_el = 81.3019660134008;
    G.t_area_mag = 27.6737136439606;
    G.t_area_az = -119.295786913649;
    G.t_area_el = 103.432916439192;
    G.svg_area_mag = 27.8691148526445;
    G.svg_area_az = 66.3691927985515;
    G.svg_area_el = 86.0244247889012;
    G.peak_qrst_ratio = 7.52322798525936;
    G.area_qrst_ratio = 1.99784215243147;
    G.svg_qrs_angle_area = 5.4742801167681;
    G.svg_qrs_angle_peak = 4.76093452715161;
    G.svg_t_angle_area = 169.012667135487;
    G.svg_t_angle_peak = 141.360675439958;
    G.svg_svg_angle = 21.3406476030472;
    G.svg_area_qrs_peak_angle = 17.1276599357274;
    G.qrst_angle_peak_frontal = 146.344736702466;
    G.qrst_angle_area_frontal = 172.958666957496;
    G.qrst_angle_area = 174.486947252256;
    G.qrst_angle_peak = 146.12160996711;
    G.X_mid = 0;
    G.Y_mid = 0;
    G.Z_mid = 0;
    G.XQ_area = 24.3150234457995;
    G.YQ_area = 8.36098932476799;
    G.ZQ_area = 48.9449134218165;
    G.XT_area = -13.1708013860459;
    G.YT_area = -6.42878979065523;
    G.ZT_area = -23.4741363957192;
    G.XQ_peak = 0.833922777596758;
    G.YQ_peak = 0.445552188964712;
    G.ZQ_peak = 1.193195240403;
    G.XT_peak = -0.00928608507364845;
    G.YT_peak = -0.0172968474460567;
    G.ZT_peak = -0.201403516688733;
    G.speed_max = 0.12810555869637;
    G.speed_min = 0.000140016463084938;
    G.speed_med = 0.00201702678541775;
    G.time_speed_max = 51;
    G.time_speed_min = 127;
    G.speed_qrs_max = 0.12810555869637;
    G.speed_qrs_min = 0.00292795341144312;
    G.speed_qrs_med = 0.0510602278594639;
    G.time_speed_qrs_max = 51;
    G.time_speed_qrs_min = 1;
    G.speed_t_max = 0.00543837015111692;
    G.speed_t_min = 0.000140016463084938;
    G.speed_t_med = 0.0015267777929065;
    G.time_speed_t_max = 355;
    G.time_speed_t_min = 127;
    G.qrst_distance_area = 82.8760725787699;
    G.qrst_distance_peak = 1.69414760569264;
    G.vcg_length_qrst = 5.17877972568067;
    G.vcg_length_qrs = 4.67423241093197;
    G.vcg_length_t = 0.504547314748709;
    G.vm_tpeak_time = 314;
    G.vm_tpeak_tend_abs_diff = 64;
    G.vm_tpeak_tend_ratio = 0.830687830687831;
    G.vm_tpeak_tend_jt_ratio = 0.726495726495726;
    G.qrs_int = 98;
    G.qt_int = 378;
    G.baseline = 0.0342082748581784;
fnG = fieldnames(G);

L = struct;
    L.L1_r_wave = 0.96474109045406;
    L.L1_s_wave = -0.074417012237767;
    L.L1_rs_wave = 1.03915810269183;
    L.L1_rs_ratio = 0.928387208794314;
    L.L1_sr_ratio = 0.0716127912056864;
    L.L1_t_max = 0.0976402389254987;
    L.L1_t_max_loc = 340;
    L.L2_r_wave = 0.563009506280742;
    L.L2_s_wave = -0.272440063448553;
    L.L2_rs_wave = 0.835449569729295;
    L.L2_rs_ratio = 0.673900049362848;
    L.L2_sr_ratio = 0.326099950637152;
    L.L2_t_max = -0.00682332222287047;
    L.L2_t_max_loc = 314;
    L.L3_r_wave = 0.0175233867993905;
    L.L3_s_wave = -0.435327115093519;
    L.L3_rs_wave = 0.452850501892909;
    L.L3_rs_ratio = 0.0386957433549107;
    L.L3_sr_ratio = 0.961304256645089;
    L.L3_t_max = -0.0936040874253579;
    L.L3_t_max_loc = 330;
    L.avF_r_wave = 0.149011037114484;
    L.avF_s_wave = -0.252204802179057;
    L.avF_rs_wave = 0.401215839293541;
    L.avF_rs_ratio = 0.37139868998408;
    L.avF_sr_ratio = 0.62860131001592;
    L.avF_t_max = -0.0494163109630158;
    L.avF_t_max_loc = 330;
    L.avL_r_wave = 0.699434585457573;
    L.avL_s_wave = -0.042899626371801;
    L.avL_rs_wave = 0.742334211829374;
    L.avL_rs_ratio = 0.942209821818556;
    L.avL_sr_ratio = 0.0577901781814436;
    L.avL_t_max = 0.0935267037324443;
    L.avL_t_max_loc = 330;
    L.avR_r_wave = 0.154993263918053;
    L.avR_s_wave = -0.745209834344165;
    L.avR_rs_wave = 0.900203098262218;
    L.avR_rs_ratio = 0.172175883661428;
    L.avR_sr_ratio = 0.827824116338572;
    L.avR_t_max = -0.0578163176140377;
    L.avR_t_max_loc = 362;
    L.V1_r_wave = 0.00889387134298459;
    L.V1_s_wave = -1.42237671598358;
    L.V1_rs_wave = 1.43127058732657;
    L.V1_rs_ratio = 0.00621396919753463;
    L.V1_sr_ratio = 0.993786030802465;
    L.V1_t_max = 0.170405842267307;
    L.V1_t_max_loc = 304;
    L.V2_r_wave = 0.00864458377430902;
    L.V2_s_wave = -1.92988271905015;
    L.V2_rs_wave = 1.93852730282446;
    L.V2_rs_ratio = 0.00445935621423219;
    L.V2_sr_ratio = 0.995540643785768;
    L.V2_t_max = 0.306312004459805;
    L.V2_t_max_loc = 314;
    L.V3_r_wave = 0.206690447955633;
    L.V3_s_wave = -1.97799921804768;
    L.V3_rs_wave = 2.18468966600331;
    L.V3_rs_ratio = 0.0946086078823974;
    L.V3_sr_ratio = 0.905391392117603;
    L.V3_t_max = 0.351211661269315;
    L.V3_t_max_loc = 314;
    L.V4_r_wave = 0.757995960419321;
    L.V4_s_wave = -1.55826564921786;
    L.V4_rs_wave = 2.31626160963718;
    L.V4_rs_ratio = 0.327249718799274;
    L.V4_sr_ratio = 0.672750281200726;
    L.V4_t_max = 0.266588467369355;
    L.V4_t_max_loc = 320;
    L.V5_r_wave = 0.807041213540711;
    L.V5_s_wave = -0.578427123158494;
    L.V5_rs_wave = 1.3854683366992;
    L.V5_rs_ratio = 0.582504263838637;
    L.V5_sr_ratio = 0.417495736161363;
    L.V5_t_max = -0.0371561981669734;
    L.V5_t_max_loc = 332;
    L.V6_r_wave = 1.134098436251;
    L.V6_s_wave = -0.252410278532168;
    L.V6_rs_wave = 1.38650871478317;
    L.V6_rs_ratio = 0.817952620246139;
    L.V6_sr_ratio = 0.182047379753861;
    L.V6_t_max = -0.0880212987054369;
    L.V6_t_max_loc = 306;
    L.X_r_wave = 1.08241859250273;
    L.X_s_wave = -0.24365263192611;
    L.X_rs_wave = 1.32607122442884;
    L.X_rs_ratio = 0.816259769884491;
    L.X_sr_ratio = 0.183740230115509;
    L.X_t_max = -0.00928608507364845;
    L.X_t_max_loc = 314;
    L.Y_r_wave = 0.491596720642026;
    L.Y_s_wave = -0.226106934370725;
    L.Y_rs_wave = 0.717703655012751;
    L.Y_rs_ratio = 0.684957805646527;
    L.Y_sr_ratio = 0.315042194353473;
    L.Y_t_max = -0.0172968474460567;
    L.Y_t_max_loc = 314;
    L.Z_r_wave = 1.4329819320258;
    L.Z_s_wave = -0.00335226274534446;
    L.Z_rs_wave = 1.43633419477114;
    L.Z_rs_ratio = 0.997666098351242;
    L.Z_sr_ratio = 0.00233390164875841;
    L.Z_t_max = -0.201403516688733;
    L.Z_t_max_loc = 314;
    L.VM_r_wave = 1.52238590173659;
    L.VM_s_wave = 0;
    L.VM_rs_wave = 1.52238590173659;
    L.VM_rs_ratio = 1;
    L.VM_sr_ratio = 0;
    L.VM_t_max = 0.202358070859939;
    L.VM_t_max_loc = 314;
    L.cornell_lvh_mv = 2.67743380350525;
    L.sokolow_lvh_mv = 2.55647515223458;
fnL = fieldnames(L);

V=struct;
    V.TCRT = -0.814873764616041;
    V.TCRT_angle = 144.57488193325;
    V.tloop_residual = 0.00455086251335821;
    V.tloop_rmse = 0.00568116367147743;
    V.tloop_roundness = 2.34412944726038;
    V.tloop_area = 0.015860565547208;
    V.tloop_perimeter = 0.569720051086555;
    V.qrsloop_residual = 0.0597775959469295;
    V.qrsloop_rmse = 0.0345767540254806;
    V.qrsloop_roundness = 1.32885286518566;
    V.qrsloop_area = 1.61583688255214;
    V.qrsloop_perimeter = 4.67439120132099;
    V.qrs_S1 = 3.98602355685922;
    V.qrs_S2 = 2.99959736799176;
    V.qrs_S3 = 0.244494572428366;
    V.t_S1 = 0.839258033317779;
    V.t_S2 = 0.358025464122143;
    V.t_S3 = 0.0674600808875754;
    V.qrs_var_s1_total = 63.6917570936571;
    V.qrs_var_s2_total = 36.0686124839148;
    V.qrs_var_s3_total = 0.239630422428006;
    V.t_var_s1_total = 84.1434554636471;
    V.t_var_s2_total = 15.3128899650148;
    V.t_var_s3_total = 0.543654571338123;
    V.qrs_loop_normal = [0.435840082621661; -0.898979875369246; 0.043342889398825];
    V.t_loop_normal = [-0.450444697232518; 0.891756404196244; -0.0432445408125806];
    V.qrst_dihedral_ang = 0.93356760976329;
fnV = fieldnames(V);


% Loop through Structures and compare to same field name in geh
% This way if add additional parameters in future it wont break the test
for i = 1:length(fnG)
    testCase.verifyEqual(geh.(fnG{i}),G.(fnG{i}),"AbsTol",1e-7)
end

for i = 1:length(fnL)
    testCase.verifyEqual(lead_morph.(fnL{i}),L.(fnL{i}),"AbsTol",1e-7)
end

for i = 1:length(fnV)
    testCase.verifyEqual(vcg_morph.(fnV{i}),V.(fnV{i}),"AbsTol",1e-7)
end

% Correlation
testCase.verifyEqual(corr.X,0.993);
testCase.verifyEqual(corr.Y,0.98);
testCase.verifyEqual(corr.Z,0.994);


end


%% Shifting median beat fiducial points
function test_braveheart_ex1_shift_median_fidpts(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam();

% Standard Qualparams
qp = qparam();

% Process ECG
[hr, ~, beats, ~, corr, medianvcg1, ~, median_12L, ~, medianbeat, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

[geh_orig, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Shift and check results

medianbeat_orig = medianbeat;

%Tend+10
medianbeat = medianbeat.shift_tend(10);
testCase.verifyEqual(medianbeat.Tend, medianbeat_orig.Tend+10);
[geh_tplus10, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

%T-10 - back to original
medianbeat = medianbeat.shift_tend(-10);
testCase.verifyEqual(medianbeat.Tend, medianbeat_orig.Tend);
[geh_orig2, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

%Q-3 
medianbeat = medianbeat.shift_q(-3);
testCase.verifyEqual(medianbeat.Q, medianbeat_orig.Q-3);
[geh_qminus3, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

%Q+3 - back to original
medianbeat = medianbeat.shift_q(3);
testCase.verifyEqual(medianbeat.Tend, medianbeat_orig.Tend);
testCase.verifyEqual(medianbeat.Q, medianbeat_orig.Q);
[geh_orig3, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

%S+5 
medianbeat = medianbeat.shift_s(5);
testCase.verifyEqual(medianbeat.Tend, medianbeat_orig.Tend);
testCase.verifyEqual(medianbeat.Q, medianbeat_orig.Q);
testCase.verifyEqual(medianbeat.S, medianbeat_orig.S+5);
[geh_splus5, ~, ~] = module_output(median_12L, medianvcg1, medianbeat, ap, flags);

% Test
testCase.verifyEqual(geh_orig2, geh_orig);
testCase.verifyEqual(geh_orig3, geh_orig);

testCase.verifyEqual(geh_tplus10.svg_x, 100.317366090089,"AbsTol",1e-7);
testCase.verifyEqual(geh_qminus3.svg_x, 100.048908835856,"AbsTol",1e-7);
testCase.verifyEqual(geh_splus5.svg_x, 100.15159835004,"AbsTol",1e-7);

% Moving S on median should have no effect on SVG
testCase.verifyEqual(geh_splus5.svg_x, geh_orig.svg_x,"AbsTol",1e-12);
testCase.verifyEqual(geh_splus5.svg_y, geh_orig.svg_y,"AbsTol",1e-12);
testCase.verifyEqual(geh_splus5.svg_z, geh_orig.svg_z,"AbsTol",1e-12);

% Make sure shifted beats are changed from original
testCase.verifyNotEqual(geh_qminus3, geh_orig);
testCase.verifyNotEqual(geh_splus5, geh_orig);
testCase.verifyNotEqual(geh_tplus10, geh_orig);

end




%% Shifting all individual beat fiducial points
function test_braveheart_ex2_shift_individual_fidpts(testCase)

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam();

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, beats, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

beats_orig = beats;

% Shift and check results

%T+10
ovrbeats = beats.shift_tend(10);
[~, ~, beats_new, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, ovrbeats, [], [], [], [], ap, qp, 0, '', []);

% Should only shift Tend +10 in all beats
testCase.verifyEqual(ovrbeats.Q, beats_orig.Q);
testCase.verifyEqual(ovrbeats.QRS, beats_orig.QRS);
testCase.verifyEqual(ovrbeats.S, beats_orig.S);
testCase.verifyEqual(ovrbeats.Tend, beats_orig.Tend + 10);
testCase.verifyEqual(ovrbeats, beats_new);

% Keep shifting ovrbeats so continue to change from beats_orig
%Q-6
ovrbeats = ovrbeats.shift_q(-6);
[~, ~, beats_new, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, ovrbeats, [], [], [], [], ap, qp, 0, '', []);

% Should only shift Q -10 in all beats
testCase.verifyEqual(ovrbeats.Q, beats_orig.Q-6);
testCase.verifyEqual(ovrbeats.QRS, beats_orig.QRS);
testCase.verifyEqual(ovrbeats.S, beats_orig.S);
testCase.verifyEqual(ovrbeats.Tend, beats_orig.Tend+10);
testCase.verifyEqual(ovrbeats, beats_new);


%S+2
ovrbeats = ovrbeats.shift_s(2);
[~, ~, beats_new, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, ovrbeats, [], [], [], [], ap, qp, 0, '', []);

% Should only shift Q -10 in all beats
testCase.verifyEqual(ovrbeats.Q, beats_orig.Q-6);
testCase.verifyEqual(ovrbeats.QRS, beats_orig.QRS);
testCase.verifyEqual(ovrbeats.S, beats_orig.S+2);
testCase.verifyEqual(ovrbeats.Tend, beats_orig.Tend+10);
testCase.verifyEqual(ovrbeats, beats_new);

end


%% Check pacemaker spike removal works
function test_braveheart_ex4_pacemaker_spike_detection(testCase)

ecg = ECG12(char('Example ECGs/example4.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam();

% Standard Qualparams
qp = qparam();

% Process ECG with spike detection on
[~, ~, beats_orig, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

testCase.verifyEqual(beats_orig.QRS',[441 933 1422 1914 2413 2904 3398 3897 4384]);

end


%% Check Outlier Detection Works
function test_braveheart_ex3_outlier_detection(testCase)

ecg = ECG12(char('Example ECGs/example3.xml'), 'muse_xml');

ap = aparam();
% default z-score cutoff = 4 -- baseline

% Standard Qualparams
qp = qparam();

% Process ECG 
[~, ~, beats_orig, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

testCase.verifyEqual(beats_orig.QRS',[316 819 1322 1832 2347 3361 3870 4391]);


% Increase mod z-score cutoff to 10 -- shouldn't detect any outliers
ap.modz_cutoff = 10;

% Process ECG 
[~, ~, beats_10, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

testCase.verifyEqual(beats_10.QRS',[316 819 1322 1832 2347 2856 3361 3870 4391]);


% Decrease mod z-score cutoff to 0.5 -- LOTS of outliers now
ap.modz_cutoff = 0.5;

% Process ECG 
[~, ~, beats_05, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

testCase.verifyEqual(beats_05.QRS',[316 1832]);

end


%% Check for necessary extenal files
function test_braveheart_external_files_present(testCase)

testCase.verifyEqual(double(isfile('ecg_formats.csv')),1);
testCase.verifyEqual(double(isfile('Qualparams.csv')),1);
testCase.verifyEqual(double(isfile('search_presets.csv')),1);
testCase.verifyEqual(double(isfile('transform_mats.csv')),1);
testCase.verifyEqual(double(isfile('batch_settings.csv')),1);
testCase.verifyEqual(double(isfile('Annoparams.csv')),1);

testCase.verifyEqual(double(isfile('braveheart_variables.pdf')),1);
testCase.verifyEqual(double(isfile('braveheart_equations.pdf')),1);
testCase.verifyEqual(double(isfile('braveheart_userguide.pdf')),1);
testCase.verifyEqual(double(isfile('braveheart_firstpass.pdf')),1);
testCase.verifyEqual(double(isfile('anglesfig.pdf')),1);
testCase.verifyEqual(double(isfile('logo_t.bmp')),1);

end


%% Check for necessary internal files (eg files needed to run BRAVEHEART GUI)
function test_braveheart_internal_files_present_gui(testCase)

[F,~] = matlab.codetools.requiredFilesAndProducts('braveheart_gui.m');

for i = 1:length(F)
    [~,file,ext]=fileparts(F{i});
    fname = strcat(file,ext);
    testCase.verifyEqual(double(isfile(fname)),1);
end

end

%% Check for necessary internal files (eg files needed to run BRAVEHEART Batch)
function test_braveheart_internal_files_present_batch(testCase)

[F,~] = matlab.codetools.requiredFilesAndProducts('braveheart_batch.m');

for i = 1:length(F)
    [~,file,ext]=fileparts(F{i});
    fname = strcat(file,ext);
    testCase.verifyEqual(double(isfile(fname)),1);
end

end


%% Check for Quality testing working correctly
function test_braveheart_quality_1(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam();

% Standard Qualparams
qp = qparam();

% Process ECG
[~, ~, ~, quality, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

Q = struct;
    Q.qt = 0;
    Q.qrs = 0;
    Q.tpqt = 0;
    Q.t_mag = 0;
    Q.hr = 0;
    Q.num_beats = 0;
    Q.pct_beats_removed = 0;
    Q.corr = 0;
    Q.baseline = 0;
    Q.hf_noise = 0;
    Q.lf_noise = 0;
    Q.prob = 0;
    Q.missing_lead = 0;
    Q.prob_value = 0.9999;
    Q.nnet_flag = 0;
    Q.nnet_nan = 0;
fnQ = fieldnames(Q);

for i = 1:length(fnQ)
    testCase.verifyEqual(double(quality.(fnQ{i})),Q.(fnQ{i}),"AbsTol",1e-4)
end

end


%% Check for Quality testing working correctly
function test_braveheart_quality_2(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

ecg = ECG12(char('Example ECGs/example1.xml'), 'muse_xml');

% Standard Annoparams
ap = aparam();

% Standard Qualparams
qp = qparam();

% Flag all parameters
    qp.qrs = [0, 0];                  
    qp.qt = [0, 0];                  
    qp.tpqt = [0, 0];                
    qp.t_mag = [0, 0];              
    qp.hr = [0, 0];                  
    qp.num_beats = [0, 0];             
    qp.pct_beats_removed = [-1, -1];   
    qp.corr = [0, 0];                   
    qp.baseline = [0, 0];            
    qp.hf_noise = [0, 0];             
    qp.prob = [0, 0];                 
    qp.lf_noise = [0, 0]; 

% Process ECG
[~, ~, ~, quality, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

Q = struct;
    Q.qt = 1;
    Q.qrs = 1;
    Q.tpqt = 1;
    Q.t_mag = 1;
    Q.hr = 1;
    Q.num_beats = 1;
    Q.pct_beats_removed = 1;
    Q.corr = 1;
    Q.baseline = 1;
    Q.hf_noise = 1;
    Q.lf_noise = 1;
    Q.prob = 1;
fnQ = fieldnames(Q);

for i = 1:length(fnQ)
    testCase.verifyEqual(double(quality.(fnQ{i})),Q.(fnQ{i}),"AbsTol",1e-4)
end

end


%% Check for Quality testing working correctly
function test_braveheart_quality_regression(testCase)

flags = struct;
flags.vcg_calc_flag = 1;
flags.lead_morph_flag = 1;
flags.vcg_morph_flag = 1;

% Standard Annoparams
ap = aparam();

% Disable PVC AND outlier removal or PVC will be removed
ap.pvc_removal = 0;
ap.outlier_removal = 0;

% Standard Qualparams
qp = qparam();

% Process ECG
ecg = ECG12(char('Example ECGs/example3.xml'), 'muse_xml');
[~, ~, ~, q1, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

testCase.verifyEqual(double(q1.prob_value), 0.9978, "AbsTol", 1e-4)
testCase.verifyEqual(double(q1.prob), 0, "AbsTol", 1e-7)

% Change Annoparams
ap.lowpass = 0;
ap.highpass = 0;

% Change Qualparams
qp.prob = [0.05, 1];

% Process ECG
ecg = ECG12(char('Example ECGs/example2.xml'), 'muse_xml');
[~, ~, ~, q1, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

testCase.verifyEqual(double(q1.prob_value), 0.0420, "AbsTol", 1e-4)
testCase.verifyEqual(double(q1.prob), 1, "AbsTol", 1e-7)


% Change Qualparams
qp.prob = [0.03, 1];

% Process ECG
ecg = ECG12(char('Example ECGs/example2.xml'), 'muse_xml');
[~, ~, ~, q1, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
    batch_calc(ecg, [], [], [], [], [], ap, qp, 0, '', []);

testCase.verifyEqual(double(q1.prob), 0, "AbsTol", 1e-7)


end