%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% GEH_calculations.m -- Performs multiple ECG/VCG calculations
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


function [svg_x, svg_y, svg_z, svg_area_mag, sai_x, sai_y, sai_z, sai_qrst, svg_qrs_angle_area, ...
    svg_qrs_angle_peak, svg_t_angle_area, svg_t_angle_peak, svg_area_el, svg_area_az, ...
    svg_peak_el, svg_peak_az, q_peak_el, t_peak_el, q_peak_az, t_peak_az, ...
    q_area_el, t_area_el, q_area_az, t_area_az, qrst_angle_peak_frontal, qrst_angle_area_frontal, ...
    qrst_angle_area, qrst_angle_peak, sai_vm, q_peak_mag, t_peak_mag, q_area_mag, t_area_mag, svg_peak_mag,...
    X_mid, Y_mid, Z_mid, XQ_area, YQ_area, ZQ_area, XT_area, YT_area, ZT_area,...
    XQ_peak, YQ_peak, ZQ_peak, XT_peak, YT_peak, ZT_peak, svg_svg_angle,...
    speed_max, speed_min, speed_med, time_speed_max, time_speed_min,...
    speed_qrs_max, speed_qrs_min, speed_qrs_med, time_speed_qrs_max, time_speed_qrs_min,...
    speed_t_max, speed_t_min, speed_t_med, time_speed_t_max, time_speed_t_min, svg_area_qrs_peak_angle,...
    qrst_distance_area, qrst_distance_peak, VMQ_area, VMT_area, sti_qrst, sti_qrs, sti_t...
    ] = GEH_calculations(x, y, z, vm, sample_time, qend, aps)

baseline_flag = aps.baseline_flag; 
blanking_window_q = round(aps.blanking_window_q/sample_time);     % Convert ms to samples
blanking_window_t = round(aps.blanking_window_t/sample_time);     % Convert ms to samples
origin_flag = aps.origin_flag;

% SAI QRST
% Need to use x, y, z BEFORE shifted to origin
[sai_x, sai_y, sai_z, sai_vm] = saiqrst(x, y, z, vm, sample_time, baseline_flag);
sai_qrst = sai_x + sai_y + sai_z;

% SVG
[XQ_area, XT_area, YQ_area, YT_area, ZQ_area, ZT_area] = mean_vector(x, y, z, sample_time, qend, baseline_flag);
svg_x = XQ_area+XT_area;
svg_y = YQ_area+YT_area;
svg_z = ZQ_area+ZT_area;
svg_area_mag = sqrt(svg_x.^2 + svg_y.^2 + svg_z.^2);
VectorQmean = [XQ_area,YQ_area,ZQ_area];
VectorTmean = [XT_area,YT_area,ZT_area];
q_area_mag = sqrt(XQ_area.^2 + YQ_area.^2 + ZQ_area.^2);
t_area_mag = sqrt(XT_area.^2 + YT_area.^2 + ZT_area.^2);

%Shift X,Y,Z to origin at (0,0,0)
[X_mid, Y_mid, Z_mid, x, y, z, x_orig, y_orig, z_orig, x_shift, y_shift, z_shift] = shift_xyz(x, y, z, origin_flag);


% Creates max QRS and T vectors
[XQ_peak, YQ_peak, ZQ_peak, XT_peak, YT_peak, ZT_peak] = max_vector(x, y, z, 0, 0, 0, sample_time, qend);
VectorQmax = [XQ_peak,YQ_peak,ZQ_peak];
VectorTmax = [XT_peak,YT_peak,ZT_peak];


q_peak_mag = sqrt(XQ_peak.^2 + YQ_peak.^2 + ZQ_peak.^2);
t_peak_mag = sqrt(XT_peak.^2 + YT_peak.^2 + ZT_peak.^2);
svg_peak_mag = sqrt((XQ_peak+XT_peak).^2 + (YQ_peak+YT_peak).^2 + (ZQ_peak+ZT_peak).^2);


%%% QRST Angle
qrst_angle_peak = atan2d(norm(cross(VectorQmax,VectorTmax)),dot(VectorQmax,VectorTmax));
qrst_angle_area = atan2d(norm(cross(VectorQmean,VectorTmean)),dot(VectorQmean,VectorTmean));


%%% SPATIAL ANGLES
SVG_Mean_Vector = [svg_x, svg_y, svg_z];
SVG_Max_Vector = [XQ_peak+XT_peak, YQ_peak+YT_peak, ZQ_peak+ZT_peak];
Yd = [0, 1, 0];


svg_area_el = atan2d(norm(cross(SVG_Mean_Vector,Yd)),dot(SVG_Mean_Vector,Yd));
svg_area_az = atan2d(svg_z, svg_x);

svg_peak_el = atan2d(norm(cross(SVG_Max_Vector,Yd)),dot(SVG_Max_Vector,Yd));
svg_peak_az = atan2d((ZQ_peak+ZT_peak),(XQ_peak+XT_peak));

q_peak_el = atan2d(norm(cross(VectorQmax,Yd)),dot(VectorQmax,Yd));
t_peak_el = atan2d(norm(cross(VectorTmax,Yd)),dot(VectorTmax,Yd));

q_peak_az = atan2d(ZQ_peak,XQ_peak);
t_peak_az = atan2d(ZT_peak,XT_peak);

q_area_el = atan2d(norm(cross(VectorQmean,Yd)),dot(VectorQmean,Yd));
t_area_el = atan2d(norm(cross(VectorTmean,Yd)),dot(VectorTmean,Yd));

q_area_az = atan2d(ZQ_area,XQ_area);
t_area_az = atan2d(ZT_area,XT_area);


%%% SPATIAL SVG ANGLES
svg_qrs_angle_area = rad2deg(atan2(norm(cross(SVG_Mean_Vector,VectorQmean)),dot(SVG_Mean_Vector,VectorQmean)));
svg_qrs_angle_peak = rad2deg(atan2(norm(cross(SVG_Max_Vector,VectorQmax)),dot(SVG_Max_Vector,VectorQmax)));
svg_t_angle_area = rad2deg(atan2(norm(cross(SVG_Mean_Vector,VectorTmean)),dot(SVG_Mean_Vector,VectorTmean)));
svg_t_angle_peak = rad2deg(atan2(norm(cross(SVG_Max_Vector,VectorTmax)),dot(SVG_Max_Vector,VectorTmax)));
svg_area_qrs_peak_angle = rad2deg(atan2(norm(cross(SVG_Mean_Vector,VectorQmax)),dot(SVG_Mean_Vector,VectorQmax)));


%%% Distance between tips of QRS and T vectors in 3D space

qrst_distance_area =  norm(VectorQmean-VectorTmean);
qrst_distance_peak = norm(VectorQmax-VectorTmax);

%%% FRONTAL PLANE QRST ANGLES
VectorQmax_frontal = [XQ_peak,YQ_peak,0];
VectorTmax_frontal = [XT_peak,YT_peak,0];
VectorQmean_frontal = [XQ_area,YQ_area,0];
VectorTmean_frontal = [XT_area,YT_area,0];

qrst_angle_peak_frontal = rad2deg(atan2(norm(cross(VectorQmax_frontal,VectorTmax_frontal)),dot(VectorQmax_frontal,VectorTmax_frontal)));
qrst_angle_area_frontal = rad2deg(atan2(norm(cross(VectorQmean_frontal,VectorTmean_frontal)),dot(VectorQmean_frontal,VectorTmean_frontal)));


% Find 3d angle between mean SVG (calculated by area), and peak SVG
% (defined by main axis of QRS and T loops)
% Define this as SVG-SVG angle

svg_svg_angle = rad2deg(atan2(norm(cross(SVG_Mean_Vector,SVG_Max_Vector)),dot(SVG_Mean_Vector,SVG_Max_Vector)));


%%%% SPEEDS of entire QRST, QRS loop, and T loop

%speed defined as the speed going to point n (eg distance of pt n minues pt n-1
%Therefore point 1 will have no speed (because no point 0).  This
%prevents the last point from having speed undefined -- but it is a matter
%of convention.  Because speed_3d(n) is the speed between point n-1 going
%to point n, we define the "time" of this point as sample (n + (n-1))/2, or
%the time between these 2 points.  eg, speed_3d(2) is the speed between
%points 1 -> 2.  Because times starts at 0 but samples start at 1, the
%timing assigned to speed_3d(n) is the average of TIME n-2 and n-1.
%Therefore, if freq is 500 Hz and each sample is 2 ms, then speed(2) is the
%speed between time 0 ms (sample 1) and time 2 ms (sample 2) = 1 ms.  If
%Freq is 1000 hz, then speed_3d(3) is the speed between sample 2 (time
%point 1 = 1 ms) and sample 3 (time point 2 = 2 ms) and is equal to 1.5 ms.

speed_3d=zeros(1,length(x));

  for i=1:length(speed_3d)-1
        speed_3d(i+1)= sqrt((x(i+1)-x(i)).^2+(y(i+1)-y(i)).^2+(z(i+1)-z(i)).^2)/sample_time; 
  end

speed_3d(1)=nan; %sample 1 is meaningless and is always 0

% Get speed data using new function and save to structures
[speed_qrst_max_struct, speed_qrst_min_struct, speed_qrst_median_struct] = min_max_locs(speed_3d, 1, length(speed_3d), blanking_window_q, 1000/sample_time);  
[speed_qrs_max_struct, speed_qrs_min_struct, speed_qrs_median_struct] = min_max_locs(speed_3d, 1, qend, blanking_window_q, 1000/sample_time);  
[speed_t_max_struct, speed_t_min_struct, speed_t_median_struct] = min_max_locs(speed_3d, qend, length(speed_3d), blanking_window_t, 1000/sample_time); 

speed_max = speed_qrst_max_struct.val;
speed_min = speed_qrst_min_struct.val;
speed_med = speed_qrst_median_struct;

speed_qrs_max = speed_qrs_max_struct.val;
speed_qrs_min = speed_qrs_min_struct.val;
speed_qrs_med = speed_qrs_median_struct;

speed_t_max = speed_t_max_struct.val;
speed_t_min = speed_t_min_struct.val;
speed_t_med = speed_t_median_struct;

time_speed_max = speed_qrst_max_struct.loc_time;
time_speed_min = speed_qrst_min_struct.loc_time;

time_speed_qrs_max = speed_qrs_max_struct.loc_time;
time_speed_qrs_min = speed_qrs_min_struct.loc_time;

time_speed_t_max = speed_t_max_struct.loc_time;
time_speed_t_min = speed_t_min_struct.loc_time;


  % Speed-time integral (STI) -- Area under speed_3d -- Have to ignore sample 1 because its a NaN.
  % Voltage-time integral (VTI) -- Area under VM
  % Note: speed_3d was already corrected for sample_time when it was created

  % Divide into QRS and T wave
  speed_qrst = speed_3d;
  speed_qrs = speed_3d(1:qend);
  speed_t = speed_3d(qend:end);

  % Remove NaN from speed (sample 1)
  speed_qrst = speed_qrst(~isnan(speed_qrst));
  speed_qrs = speed_qrs(~isnan(speed_qrs));
  speed_t = speed_t(~isnan(speed_t));


  % Calculate areas
  % Speed does not need to account for sample_time because was already done
  % when speed_3d was created above, but VTI's do need to be multiplied by
  % sample_time.  Using same naming convention for VTIs as with SVG
  % components
 
  sti_qrst = trapz(speed_qrst);
  sti_qrs = trapz(speed_qrs);
  sti_t = trapz(speed_t);

  % VM Voltage-time Integrals
  % VM_area is the same as sai_vm since VM is always positive
  [~, VMQ_area, VMT_area] = vm_integral(vm, qend, sample_time, baseline_flag);


