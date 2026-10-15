function cString = identify_clipped_leads(pdfinfo)

p = pdfinfo.clipping;
cString = '';

if p.I > 0
    cString = sprintf('%s, %s',cString,'I');
end

if p.II > 0
    cString = sprintf('%s, %s',cString,'II');
end

if p.III > 0
    cString = sprintf('%s, %s',cString,'III');
end


if p.aVR > 0
    cString = sprintf('%s, %s',cString,'aVR');
end

if p.aVL > 0
    cString = sprintf('%s, %s',cString,'aVL');
end

if p.aVF > 0
    cString = sprintf('%s, %s',cString,'aVF');
end


if p.V1 > 0
    cString = sprintf('%s, %s',cString,'V1');
end

if p.V2 > 0
    cString = sprintf('%s, %s',cString,'V2');
end

if p.V3 > 0
    cString = sprintf('%s, %s',cString,'V3');
end

if p.V4 > 0
    cString = sprintf('%s, %s',cString,'V4');
end

if p.V5 > 0
    cString = sprintf('%s, %s',cString,'V5');
end

if p.V6 > 0
    cString = sprintf('%s, %s',cString,'V6');
end

% Remove leading ', '
if strcmp(cString(1:2),', ')
    cString = cString(3:end);
end
