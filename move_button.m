function move_button(src, event)
F = gcf;
Fpos = get(F, 'Position');

% Find buttons
B = findobj(allchild(F), 'flat', 'Type', 'uicontrol');

% Move to correct rescaled coordinates
if ~isempty(B)
    for i = 1:length(B)
        Bpos = get(B(i), 'Position');
        set(B(i), 'Position',[Fpos(3)-100 Fpos(4)-40-(40*(i-1)) Bpos(3) Bpos(4)]);
    end
end

end