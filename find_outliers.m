%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% find_outliers.m -- Find outlier beats
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

function [outlier_matrix, modz_matrix, outlier_legend] = find_outliers(beats, lead, hz, cutpt)

% load in fiducial points from annotated beat listbox

Q = beats(:,1);
QRS = beats(:,2);
S = beats(:,3);
Tend = beats(:,4);

% define QR, RS, JT, and QT intervals
QR_int = QRS-Q;
RS_int = S-QRS;
JT_int = Tend-S;
RT_int = Tend-QRS;
QT_int = Tend-Q;


% find area (integral) for each beat - does not account for sample time

area = zeros(1,length(Q));

for i=1:length(Q)
   if isnan(Tend(i)) || isnan(Q(i))
       area(i) = NaN;
       continue;
   end
   lead_segment = lead(Q(i):Tend(i));
   area(i) = round(trapz(lead_segment)); 
end
area=area';

% Preallocate
qr_outlier = zeros(1,length(Q));
rt_outlier = zeros(1,length(Q));
rs_outlier = zeros(1,length(Q));
jt_outlier = zeros(1,length(Q));
qt_outlier = zeros(1,length(Q));
svg_outlier = zeros(1,length(Q));

qr_modz = zeros(1,length(Q));
rt_modz = zeros(1,length(Q));
rs_modz = zeros(1,length(Q));
jt_modz = zeros(1,length(Q));
qt_modz = zeros(1,length(Q));
svg_modz = zeros(1,length(Q));

qr_outlier(find(mod_z_score(QR_int, hz)>cutpt)) = 1;
rt_outlier(find(mod_z_score(RT_int, hz)>cutpt)) = 1;

qr_modz = mod_z_score(QR_int, hz)';
rt_modz = mod_z_score(RT_int, hz)';

rs_outlier(find(mod_z_score(RS_int, hz)>cutpt)) = 1;
jt_outlier(find(mod_z_score(JT_int, hz)>cutpt)) = 1;
qt_outlier(find(mod_z_score(QT_int, hz)>cutpt)) = 1;

rs_modz = mod_z_score(RS_int, hz)';
jt_modz = mod_z_score(JT_int, hz)';
qt_modz = mod_z_score(QT_int, hz)';

svg_outlier(find(mod_z_score(area, hz)>cutpt)) = 1;
svg_modz = mod_z_score(area, hz)';

% outlier is defined as any beat with any of the 5 parameters classified as
% an outlier

outlier_matrix = [qr_outlier; rs_outlier; jt_outlier; rt_outlier; qt_outlier; svg_outlier];

modz_matrix = [qr_modz; rs_modz; jt_modz; rt_modz; qt_modz; svg_modz];


for i=1:length(Q)
    if any(isnan(beats(i,:)))
        outlier_matrix(:, i) = 1;
    end
end

% Outliers matrix legend
% Row 1 - QR interval **
% Row 2 - RS interval
% Row 3 - JT interval
% Row 4 - RT interval **
% Row 5 - QT interval
% Row 6 - SVG

outlier_legend = ["QR Interval";"RS Interval";"JT Interval";"RT Interval";"QT Interval";"SVG/Area"];
end