%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% polar_figures.m -- Part of BRAVEHEART GUI - Figure showing SVG orientation
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


function polar_figures(geh, nval, filename)

% nval = structure of normal values

% Limits for mag, el, az, qrst angle
lim_mag1 = nval.svg_area_mag(1);
lim_mag2 = nval.svg_area_mag(2);

lim_el_a = nval.svg_area_el(1);
lim_el_b = nval.svg_area_el(2);

lim_az_a = nval.svg_area_az(1);
lim_az_b = nval.svg_area_az(2);

lim_qrst_area = nval.qrst_angle_area(2); % area
lim_qrst_peak = nval.qrst_angle_peak(2); % peak

%%%%%%%%%%


figure('name','GEH Polar Plots','numbertitle','off');

% Frontal plane
subplot(1,4,1)

svg = polarplot([0 deg2rad(geh.svg_area_el)],[0 geh.svg_area_mag],'linewidth',5,'color','[0 0.7 0]','displayname','SVG Peak');
hold on
qrs = polarplot([0 deg2rad(geh.q_area_el)],[0 geh.q_area_mag],'linewidth',1.5,'color','b','displayname','QRS Peak');
t = polarplot([0 deg2rad(geh.t_area_el)],[0 geh.t_area_mag],'linewidth',1.5,'color','r','displayname','T Peak');
title('Frontal Plane (XY)');
pax = gca;
pax.ThetaZeroLocation = 'bottom';
pax.Layer = 'top';

%rticklabels({});
thetalim([0 180]);
thetaticks(0:15:345);
%legend([pk_qrs pk_t pk_svg])

% rr = rlim;
% rr(2)
% polarplot([0 deg2rad(lim_a)],[0 rr(2)],'linewidth',1.5,'color','[0.91 0.41 0.17]','linestyle',':');
% 
% polarplot([0 deg2rad(lim_b)],[0 rr(2)],'linewidth',1.5,'color','[0.91 0.41 0.17]','linestyle',':');
% hold off

rr = rlim;
rr(2);

if rr(2) < 50
     rlim([0 50]);
     rr(2) = 50;
 end

for i = lim_el_a:0.5:lim_el_b    
    polarplot([0 deg2rad(i)],[0 rr(2)],'linewidth',1.5,'color','[1 1 .6902]'); 
    polarplot([0 deg2rad(i)],[0 lim_mag1],'linewidth',1.5,'color','[1 1 1]');
    
    if lim_mag2 < rr(2)
        polarplot([deg2rad(i) deg2rad(i)],[lim_mag2 rr(2)],'linewidth',1.5,'color','[1 1 1]');
    end
end



comp = [qrs t svg];
uistack(comp,'up',500);
annotation('textbox', [0.13, 0.008, 0.1, 0.1], 'String', "Feet", 'linestyle','none','fontweight','bold');
annotation('textbox', [0.13, 0.858, 0.1, 0.1], 'String', "Head", 'linestyle','none','fontweight','bold');


% Transverse plane
subplot(1,4,2)

svg = polarplot([0 deg2rad(geh.svg_area_az)],[0 geh.svg_area_mag],'linewidth',5,'color','[0 0.7 0]','displayname','SVG Peak');
hold on
qrs = polarplot([0 deg2rad(geh.q_area_az)],[0 geh.q_area_mag],'linewidth',1.5,'color','b','displayname','QRS Peak');
t = polarplot([0 deg2rad(geh.t_area_az)],[0 geh.t_area_mag],'linewidth',1.5,'color','r','displayname','T Peak');
title('Transverse Plane (XZ)');
pax = gca;
pax.ThetaZeroLocation = 'right';
pax.ThetaLim = [-180 180];
%rticklabels({});
thetaticks(-180:15:180);
pax.ThetaDir = 'clockwise';
pax.Layer = 'top';

rr = rlim;
rr(2);
 
if rr(2) < 50
     rlim([0 50]);
     rr(2) = 50;
 end
 

for i = lim_az_a:0.5:lim_az_b    
    polarplot([0 deg2rad(i)],[0 rr(2)],'linewidth',1.5,'color','[1 1 .6902]'); 
    polarplot([0 deg2rad(i)],[0 lim_mag1],'linewidth',1.5,'color','[1 1 1]');

    if lim_mag2 < rr(2)
        polarplot([deg2rad(i) deg2rad(i)],[lim_mag2 rr(2)],'linewidth',1.5,'color','[1 1 1]');
    end
    
end

comp = [qrs t svg];
uistack(comp,'up',500);

annotation('textbox', [0.13, 0.008, 0.1, 0.1], 'String', "Feet", 'linestyle','none','fontweight','bold');
annotation('textbox', [0.13, 0.858, 0.1, 0.1], 'String', "Head", 'linestyle','none','fontweight','bold');


hold off

annotation('textbox', [0.47, 0.008, 0.1, 0.1], 'String', "Posterior", 'linestyle','none','fontweight','bold');
annotation('textbox', [0.47, 0.858, 0.1, 0.1], 'String', "Anterior", 'linestyle','none','fontweight','bold');



% QRST Angle
subplot(1,4,3)

polarplot([0 deg2rad(lim_qrst_area)],[0 1],'linewidth',1.5,'color','[0.91 0.41 0.17]');
hold on
polarplot([0 deg2rad(lim_qrst_peak)],[0 1],'linewidth',1.5,'color','[0.91 0.41 0.17]','linestyle',':');


qrst_area = polarplot([0 deg2rad(geh.qrst_angle_area)],[0 1],'linewidth',3,'color','k','displayname','Area QRST Angle');
hold on
qrst_peak = polarplot([0 deg2rad(geh.qrst_angle_peak)],[0 1],'linewidth',3,'linestyle',':','color','k','displayname','Peak QRST Angle');
title('3D QRST Angles');
pax = gca;
pax.ThetaZeroLocation = 'right';
pax.ThetaLim = [0 180];
rticklabels({});
thetaticks(0:15:180);
hold off

subplot(1,4,4)
a = line([0 0],[0 0],'linewidth',5,'color','[0 0.7 0]');
b = line([0 0],[0 0],'linewidth',1.5,'color','b');
c = line([0 0],[0 0],'linewidth',1.5,'color','r');
d = line([0 0],[0 0],'linewidth',3,'color','k');
e = line([0 0],[0 0],'linewidth',3,'color','k','linestyle',':');
f = line([0 0],[0 0],'linewidth',10,'color','[1 1 .6902]');
g = line([0 0],[0 0],'linewidth',2,'color','[0.91 0.41 0.17]');
h = line([0 0],[0 0],'linewidth',2,'color','[0.91 0.41 0.17]','linestyle',':');

axis off
legend([a b c d e f g h],{'Area SVG', 'Area QRS', 'Area T', 'Area QRST Angle', 'Peak QRST Angle', 'Normal Range - SVG', 'Normal Limit - Area QRST Angle', 'Normal Limit - Peak QRST Angle'},'fontsize',11,'location','westoutside');


annotation('textbox', [0.745, 0.858, 0.1, 0.1], 'String', filename, 'linestyle','none','fontweight','bold', 'fontsize', 12, 'Interpreter', 'none');

if geh.svg_area_mag < lim_mag1 |  geh.svg_area_mag > lim_mag2
    annotation('textbox', [0.745, 0.79, 0.1, 0.1], 'String', sprintf("SVG Magnitude = %1.1f mv*ms", geh.svg_area_mag), 'linestyle','none','fontweight','bold', 'color', 'r');
else
    annotation('textbox', [0.745, 0.79, 0.1, 0.1], 'String', sprintf("SVG Magnitude = %1.1f mv*ms", geh.svg_area_mag), 'linestyle','none','fontweight','bold', 'color', 'k');

end
    
    
if geh.svg_area_az < lim_az_a |  geh.svg_area_az > lim_az_b
    annotation('textbox', [0.745, 0.74, 0.1, 0.1], 'String', sprintf("SVG Azimuth = %1.1f deg", geh.svg_area_az), 'linestyle','none','fontweight','bold', 'color', 'r');
else
    annotation('textbox', [0.745, 0.74, 0.1, 0.1], 'String', sprintf("SVG Azimuth = %1.1f deg", geh.svg_area_az), 'linestyle','none','fontweight','bold', 'color', 'k');
end


if geh.svg_area_el < lim_el_a |  geh.svg_area_el > lim_el_b
    annotation('textbox', [0.745, 0.69, 0.1, 0.1], 'String', sprintf("SVG Elevation = %1.1f deg", geh.svg_area_el), 'linestyle','none','fontweight','bold', 'color', 'r');
else
    annotation('textbox', [0.745, 0.69, 0.1, 0.1], 'String', sprintf("SVG Elevation = %1.1f deg", geh.svg_area_el), 'linestyle','none','fontweight','bold', 'color', 'k');
end


set(gcf, 'Position', [100, 100, 2100, 400])  % set figure size


% Increase font size on mac due to pc/mac font differences
if ismac
    fontsize(gcf,scale=1.25)
end

