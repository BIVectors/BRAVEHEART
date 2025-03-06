
function save_fig_from_button(src, event, save_filename)
F = gcf;

% Want to keep dark background if in dark mode, but use a white background
% if in light mode

% As of now do not have a way to query handles directly, so will look at
% the color of the figure being saved, and if it is "light" will change
% background to white temporarily before save.

% if RGB values are >= 0.7 will call it light

existing_color = F.Color;
if existing_color(1) >= 0.7 && existing_color(2) >= 0.7 && existing_color(3) >= 0.7
    colorswap = 1;
else
    colorswap = 0;
end

% Hide buttons, save, then show buttons
B = findobj(allchild(F), 'flat', 'Type', 'uicontrol');

for i = 1:length(B)
    set(B(i),'Visible','off');
end

if colorswap == 1
    F.Color = [1 1 1];
    print(gcf,'-dpng',[save_filename],'-r600');
    F.Color = existing_color;
else
    print(gcf,'-dpng',[save_filename],'-r600');
end

for i = 1:length(B)
    set(B(i),'Visible','on');
end
end