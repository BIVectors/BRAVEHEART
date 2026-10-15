function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6, info] = load_musepdf_wrapper(filename)

% Extract leads and Hz
[ecgsig, pdfinfo] = load_musepdf(filename,'calcleads');
I = ecgsig.I; II = ecgsig.II; III = ecgsig.III;
avR = ecgsig.aVR; avL = ecgsig.aVL; avF = ecgsig.aVF;
V1 = ecgsig.V1; V2 = ecgsig.V2; V3 = ecgsig.V3;
V4 = ecgsig.V4; V5 = ecgsig.V5; V6 = ecgsig.V6;

hz = ecgsig.hz;
units = ecgsig.units;

% Can currently only process 12x1 PDFs, so will
% error if another format is loaded
if ~strcmp(pdfinfo.ecgFormat,'12LRhythm')
    error('BRAVEHEART only supports 12x1 format MUSE PDF ECGs, you loaded %s',pdfinfo.ecgFormat);
end

% Need to flag if the reconstructed PDF has
% clipping or if it failed certification
info = '';

if ecgsig.totalClipping > 0
   cString = identify_clipped_leads(pdfinfo);
   info = sprintf('PDF clipped (Leads %s)',cString);
end

if ecgsig.certified ~= 1 || isnan(ecgsig.certified)
    if strcmp(info,'')
        info = 'PDF not certified';
    else
        cString = identify_clipped_leads(pdfinfo);
        info = sprintf('PDF clipped (Leads %s) and PDF not certified', cString);
    end
end