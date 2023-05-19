%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% normal_range_figure.m -- Part of BRAVEHEART GUI - Figure assessing normal ranges
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

function normal_range_figure(hObject, eventdata, handles)

geh = handles.geh;

% Pull out normal values based on demographics
if get(handles.gender_checkbox, 'Value')
    gender = 'FEMALE';
else
    gender = 'MALE';
end

nml = NormalVals(str2num(get(handles.age_txt,'String')), gender, get(handles.white_checkbox,'Value'), str2num(get(handles.bmi_txt,'String')), handles.hr);

fields = nml.labels();

start = 6;  % Index to start counting

angleplot = [7 8 14 15];    % Indices within NormalVals class that are angles

textlabels = [{'SVG Magnitude'},{'SVG Azimuth'}, {'SVG Elevation'}, {'SAI VM'}, {'SAI QRST'}, {'SVG X'}, {'SVG Y'}, {'SVG Z'}, {'Area QRST Angle'}, {'Peak QRST Angle'}];

race = 'Not White';
if get(handles.white_checkbox,'Value')
    race = 'White';   
end    

gender_short = gender(1);

figure   
sgtitle(sprintf('Selected Normal Ranges: %s%s, BMI = %s, Race = %s',...
    get(handles.age_txt,'String'), gender_short, get(handles.bmi_txt,'String'), race),...
    'fontsize',14,'fontweight','bold');

for i = start:nml.length()
    
subplot(2,5,i+1-start)

color = 'k';

if geh.(fields{i}) < nml.(fields{i})(1) || geh.(fields{i}) > nml.(fields{i})(2)
   color = 'r'; 
end    
    
%%%%%%%%%%%%%%%

if ismember(i, angleplot) && ~strcmp('svg_area_az',(fields{i}))  % If value is an angle and not Az (so runs 0-180 deg)
    
polarplot([0 deg2rad(nml.(fields{i})(1))],[0 1],'linewidth',1.5,'color','[1 1 .6902]');
hold on
polarplot([0 deg2rad(nml.(fields{i})(2))],[0 1],'linewidth',1.5,'color','[1 1 .6902]');

% Shade normal area in
for j = nml.(fields{i})(1):0.5:nml.(fields{i})(2)  
    polarplot([0 deg2rad(j)],[0 1],'linewidth',1.5,'color','[1 1 .6902]'); 
    polarplot([0 deg2rad(j)],[0 1],'linewidth',1.5,'color','[1 1 .6902]');
end

polarplot([0 deg2rad(geh.(fields{i}))],[0 1],'linewidth',3,'color',color);
hold on
title(textlabels(i-5));
pax = gca;
pax.ThetaZeroLocation = 'right';
pax.ThetaLim = [0 180];
rticks([])
rticklabels({});
thetaticks(0:15:180);
thetaticklabels({'0','','30','','60','','90','','120','','150','','180'});
pax.Layer = 'top';

text(deg2rad(270),0.1,num2str(round(geh.(fields{i}),1)),'color',color,'HorizontalAlignment','center', 'fontweight','bold');

text(deg2rad(nml.(fields{i})(1)-10),0.8,num2str(round(nml.(fields{i})(1),1)),'color','[0.4 0.4 0.4]','HorizontalAlignment','center');
text(deg2rad(nml.(fields{i})(2)+10),0.8,num2str(round(nml.(fields{i})(2),1)),'color','[0.4 0.4 0.4]','HorizontalAlignment','center');

polarplot([deg2rad(nml.(fields{i})(1)) deg2rad(nml.(fields{i})(1))],[0.8 1],'linewidth',0.7,'color','[0.4 0.4 0.4]');
polarplot([deg2rad(nml.(fields{i})(2)) deg2rad(nml.(fields{i})(2))],[0.8 1],'linewidth',0.7,'color','[0.4 0.4 0.4]');


%%%%%%%%%%%%%%

elseif ismember(i, angleplot) && strcmp('svg_area_az',(fields{i}))  % SVG Az that runs -180 to +180 deg
    
polarplot([0 deg2rad(nml.(fields{i})(1))],[0 1],'linewidth',1.5,'color','[1 1 .6902]');
hold on
polarplot([0 deg2rad(nml.(fields{i})(2))],[0 1],'linewidth',1.5,'color','[1 1 .6902]');

% Shade normal area in
for j = nml.(fields{i})(1):0.5:nml.(fields{i})(2)  
    polarplot([0 deg2rad(j)],[0 1],'linewidth',1.5,'color','[1 1 .6902]'); 
    polarplot([0 deg2rad(j)],[0 1],'linewidth',1.5,'color','[1 1 .6902]');
end


polarplot([0 deg2rad(geh.(fields{i}))],[0 1],'linewidth',3,'color',color);
hold on
title(textlabels(i-5));
pax = gca;
pax.Layer = 'top';
rticks([])
rticklabels({});
pax.ThetaZeroLocation = 'right';
pax.ThetaLim = [-180 180];
%rticklabels({});
thetaticks(-180:30:180);
pax.ThetaDir = 'clockwise';

text(deg2rad(nml.(fields{i})(1)-10),0.8,num2str(round(nml.(fields{i})(1),1)),'color','[0.4 0.4 0.4]','HorizontalAlignment','center');
text(deg2rad(nml.(fields{i})(2)+10),0.8,num2str(round(nml.(fields{i})(2),1)),'color','[0.4 0.4 0.4]','HorizontalAlignment','center');

polarplot([deg2rad(nml.(fields{i})(1)) deg2rad(nml.(fields{i})(1))],[0.8 1],'linewidth',0.7,'color','[0.4 0.4 0.4]');
polarplot([deg2rad(nml.(fields{i})(2)) deg2rad(nml.(fields{i})(2))],[0.8 1],'linewidth',0.7,'color','[0.4 0.4 0.4]');

% Put value in correct place in polar plot - oppsoite to the angle
text(deg2rad(-geh.(fields{i})),-0.3,num2str(round(geh.(fields{i}),1)),'color',color,'HorizontalAlignment','center', 'fontweight','bold');

%%%%%%%%%%%%%
   
else  % Linear
xl = nml.(fields{i})(1);
xh = nml.(fields{i})(2);
pad = 0.1;

xpad = ceil(max([abs(pad*xl) abs(pad*xh) 20])/10)*10;

title(textlabels(i-5));
hold on
ylim([0 1]);

x_min = min([xl geh.(fields{i})]);
x_max = max([xh geh.(fields{i})]);
xlim([(x_min - xpad) (x_max + xpad)]);

% Ticks
xt = 20;
xx = xlim;

if xx(1) < 0
    xt1 = round(floor(xx(1)/10))*10;
else
    xt1 = round(ceil(xx(1)/10))*10;
end

if xx(2) < 0
    xt2 = round(floor(xx(2)/10))*10;
else
    xt2 = round(ceil(xx(2)/10))*10;
end
    
num_ticks = xx(2)-xx(1);
if num_ticks > 140
   xt = 30; 
end

xticks([(xt1 - xpad):xt:(xt2 + xpad)]);

set(gca,'ytick',[]);
rectangle('Position',[xl 0.4 xh-xl 0.2], 'FaceColor','[1 1 .6902]','EdgeColor','none', 'LineWidth',3);

%scatter(geh.(fields{i}),0.5,30,color,'filled');
line([geh.(fields{i}) geh.(fields{i})],[0.3 0.7],'linewidth',3,'color',color);
line([xl xl],[0.3 0.7],'linewidth',0.7,'color','[0.4 0.4 0.4]'); 
line([xh xh],[0.3 0.7],'linewidth',0.7,'color','[0.4 0.4 0.4]'); 

text(geh.(fields{i}),0.77,num2str(round(geh.(fields{i}),1)),'fontweight','bold','color',color,'HorizontalAlignment','center');
text(xl,0.25,num2str(round(xl,1)),'color','[0.4 0.4 0.4]','HorizontalAlignment','center');
text(xh,0.25,num2str(round(xh,1)),'color','[0.4 0.4 0.4]','HorizontalAlignment','center');

ax = gca;
ax.XGrid = 'on';
ax.Layer = 'top';
end

set(gcf, 'Position', [100, 100, 1500, 500]);  % set figure size


end

% Increase font size on mac due to pc/mac font differences
if ismac
    fontsize(gcf,scale=1.25)
end


end  % End function

