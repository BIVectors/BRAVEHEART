function view_vcgloops(vcg, fp, filename, save_folder, save_flag)

% fp = fiducial points of median beat

vcgloop_fig = figure('name','Median VCG Loops','numbertitle','off');
set(gcf, 'Position', [0, 0, 1000 800])  % set figure size
set(vcgloop_fig,'PaperSize',[8.5 11]); %set the paper size to what you want  
sgtitle('Median VCG Loops','fontweight','bold')

dx = 3;
dy = 2;
gr = 0.25;  % Grid size

X = vcg.X(fp.Q:fp.Tend);
Y = vcg.Y(fp.Q:fp.Tend);
Z = vcg.Z(fp.Q:fp.Tend);

subplot(dy,dx,1)
hold on
%scatter3(vcg.X, vcg.Y, vcg.Z, 14, 'filled')
plot3(X, Y, Z,'-o','Color','#0072BD','MarkerSize',3,'MarkerFaceColor','#0072BD', 'linewidth',1.75)
plot3(X(1),Y(1),Z(1),'-o','Color','k','MarkerSize',5,'MarkerFaceColor','k', 'linewidth',1.75)
plot3(X(end),Y(end),Z(end),'-o','Color','r','MarkerSize',5,'MarkerFaceColor','r', 'linewidth',1.75)
plot3(X(fp.S-fp.Q),Y(fp.S-fp.Q),Z(fp.S-fp.Q),'-o','Color','[0 0.702 0]','MarkerSize',5,'MarkerFaceColor','[0 0.702 0]', 'linewidth',1.75)
view ([0 0 1]); % XY
xlabel('X (mV)','FontWeight','bold','FontSize',9);
ylabel('Y (mV)','FontWeight','bold','FontSize',9);
set (gca,'Ydir','reverse');
title('Frontal')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'xtick',[(floor(min(X)*2)/2):gr:(ceil(max(X)*4)/4)])
set(gca,'ytick',[(floor(min(Y)*2)/2):gr:(ceil(max(Y)*4)/4)])
xlim([(floor(min(X)*4)/4) (ceil(max(X)*4)/4)])
ylim([(floor(min(Y)*4)/4) (ceil(max(Y)*4)/4)])
grid on
hold off


subplot(dy,dx,2)
hold on
plot3(X, Y, Z,'-o','Color','#0072BD','MarkerSize',3,'MarkerFaceColor','#0072BD', 'linewidth',1.75)
plot3(X(1),Y(1),Z(1),'-o','Color','k','MarkerSize',5,'MarkerFaceColor','k', 'linewidth',1.75)
plot3(X(end),Y(end),Z(end),'-o','Color','r','MarkerSize',5,'MarkerFaceColor','r', 'linewidth',1.75)
plot3(X(fp.S-fp.Q),Y(fp.S-fp.Q),Z(fp.S-fp.Q),'-o','Color','[0 0.702 0]','MarkerSize',5,'MarkerFaceColor','[0 0.702 0]', 'linewidth',1.75)
view ([0 -1 0]); % XZ
xlabel('X (mV)','FontWeight','bold','FontSize',9);
zlabel('Z (mV)','FontWeight','bold','FontSize',9);
title('Transverse')
set (gca,'Zdir','reverse');
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'xtick',[(floor(min(X)*2)/2):gr:(ceil(max(X)*4)/4)])
set(gca,'ztick',[(floor(min(Z)*2)/2):gr:(ceil(max(Z)*4)/4)])
xlim([(floor(min(X)*4)/4) (ceil(max(X)*4)/4)])
zlim([(floor(min(Z)*4)/4) (ceil(max(Z)*4)/4)])
grid on
hold off


subplot(dy,dx,3)
hold on
plot3(vcg.X, vcg.Z, vcg.Y,'-o','Color','#0072BD','MarkerSize',3,'MarkerFaceColor','#0072BD', 'linewidth',1.75) % Swap Y and Z
plot3(X(1),Z(1),Y(1),'-o','Color','k','MarkerSize',5,'MarkerFaceColor','k', 'linewidth',1.75)
plot3(X(end),Z(end),Y(end),'-o','Color','r','MarkerSize',5,'MarkerFaceColor','r', 'linewidth',1.75)
plot3(X(fp.S-fp.Q),Z(fp.S-fp.Q),Y(fp.S-fp.Q),'-o','Color','[0 0.702 0]','MarkerSize',5,'MarkerFaceColor','[0 0.702 0]', 'linewidth',1.75)
ylabel('Z (mV)','FontWeight','bold','FontSize',9);
zlabel('Y (mV)','FontWeight','bold','FontSize',9);
xlabel('X (mV)','FontWeight','bold','FontSize',9);
title('Left Sagital');
set (gca,'Zdir','reverse');
set (gca,'Ydir','reverse');
view ([-1 0 0])
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'ytick',[(floor(min(Z)*2)/2):gr:(ceil(max(Z)*4)/4)]) % Swap Y and Z
set(gca,'ztick',[(floor(min(Y)*2)/2):gr:(ceil(max(Y)*4)/4)]) % Swap Y and Z
ylim([(floor(min(Z)*4)/4) (ceil(max(Z)*4)/4)]) % Swap Y and Z
zlim([(floor(min(Y)*4)/4) (ceil(max(Y)*4)/4)]) % Swap Y and Z
grid on
hold off

subplot(dy,dx,4)
plot(vcg.X,'linewidth',1.75)
title('Median X');
hold on
scatter(fp.Q, vcg.X(fp.Q),'k','filled')
scatter(fp.S, vcg.X(fp.S),'MarkerEdgeColor',[0 0.702 0],'MarkerFaceColor',[0 0.702 0])
scatter(fp.Tend, vcg.X(fp.Tend),'r','filled')
xlim([0 length(vcg.X)])
ylim([min([min(vcg.X) min(vcg.Y) min(vcg.Z)]) max([max(vcg.X) max(vcg.Y) max(vcg.Z)])])
hold off

subplot(dy,dx,5)
plot(vcg.Y,'linewidth',1.75)
title('Median Y');
hold on
scatter(fp.Q, vcg.Y(fp.Q),'k','filled')
scatter(fp.S, vcg.Y(fp.S),'MarkerEdgeColor',[0 0.702 0],'MarkerFaceColor',[0 0.702 0])
scatter(fp.Tend, vcg.Y(fp.Tend),'r','filled')
xlim([0 length(vcg.X)])
ylim([min([min(vcg.X) min(vcg.Y) min(vcg.Z)]) max([max(vcg.X) max(vcg.Y) max(vcg.Z)])])
hold off

subplot(dy,dx,6)
plot(vcg.Z,'linewidth',1.75)
title('Median Z');
hold on
q = scatter(fp.Q, vcg.Z(fp.Q),'k','filled');
s = scatter(fp.S, vcg.Z(fp.S),'MarkerEdgeColor',[0 0.702 0],'MarkerFaceColor',[0 0.702 0]);
t = scatter(fp.Tend, vcg.Z(fp.Tend),'r','filled');
legend([q s t],{'QRSon','QRSoff','Toff'}, 'location','northeast')
legend('boxoff')
xlim([0 length(vcg.X)])
ylim([min([min(vcg.X) min(vcg.Y) min(vcg.Z)]) max([max(vcg.X) max(vcg.Y) max(vcg.Z)])])
hold off


h=gcf;
h.PaperPositionMode = 'manual';
orient(h,'landscape')


InSet = get(gca, 'TightInset');
InSet(4) = InSet(4)+0.015;
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);


% Increase font size on mac due to pc/mac font differences
if ismac
    fontsize(gcf,scale=1.25)
end


% Save figure as .png if save checkbox selected
if save_flag == 1
filename_short = strcat(filename(1:end-4),'_medianvcgloops.png');
full_filename = fullfile(save_folder,filename_short);

print(gcf,'-dpng',[full_filename],'-r600');

else
end