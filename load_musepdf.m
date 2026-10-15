%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  
%
% *** PDF2ECG: Convert MUSE Encoded PDF ECG with Vector Graphics into bit-exact waveforms 
%              and certify that waveform reconstruction is bit-exact
%
% Copyright 2026: Jonathan W. Waks
% Source code available at: https://github.com/BIVectors/pdf2ecg
% Contact: braveheart.ecg@gmail.com
% 
% pdf2ecg is free software: you can redistribute it and/or modify it under the terms of the GNU 
% General Public License as published by the Free Software Foundation, either version 3 of the License, 
% or (at your option) any later version.
%
% pdf2ecg is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <https://www.gnu.org/licenses/>.
%
% This software is for research purposes only and is not intended to diagnose or treat any disease.
%
%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  
% 
% Adobe PDF specification is available at: https://opensource.adobe.com/dc-acrobat-sdk-docs/standards/pdfstandards/pdf/PDF32000_2008.pdf
%
% INPUTS:
% 1st input must be the filename of the .pdf as a string
%
% Options to include as strings after filename include:
%
% 'verbose' :: will print information on signal parsing/results/signal clipping when the function runs.  
%        Default: If this string is not specified the function returns no text information.
% 
% 'pdfleads' :: Extract all leads directly from the .pdf file
% 
% 'calcleads' :: Extract leads I, II, and V1-V6 from the .pdf file, but calculate leads III, aVR, aVL, and aVF 
%       from the extracted values of leads I and II. 
%
% If 'pdfleads', 'calcleads', is not specified, the default is to use 'calcleads' 
%
% 'adu' :: Data is output in ADU values and not physical units of mV
%
% 'exportfile' :: will export the data from the .pdf into a .csv with the filename 'basename_digitized.csv'
%       if output is in mV or 'basename_digitized_adu.csv' if output is in ADU units. 
%       Default: If this string is not specified the file is not exported to .csv
%
%
% OUTPUTS:
% signals :: a structure containing the lead data in mV (signals.I, signals.V1, etc), the total number of clipped 
%       points in the full ECG (signals.totalClipping), sampling frequency (hz), any rhythm strips if not in a 12 
%       rhythm strip format (rhythm), and if any rhythm strips have clipping (totalClippingRhythm)
%
%       signals.rhythm contains any rhythm strips included with a 4x2.5s or 2x5s format (signals.rhythm.II,
%               signals.rhythm.V1, etc)
%
% info :: a structure containing additional information on how lead were extracted/calculated (leadsMode), ECG layout 
%       format (ecgFormat), leadOrder (lead order in .pdf), lead names of any rhythm strips (rhythmStripLeads), 
%       number of polylines extracted (nPolylines), conversion between units and mV (unitsPerMv), conversion between 
%       units and time (unitsPerSec), number of streams extracted (nStreams), and a structure with additional 
%       information on clipping (clipping)
%
%       info.clipping contains the number of clipped samples in each lead (info.clipped.I, info.clipped_V1, etc) 
%               and the samples that were clipped (info.clipped_I_clipsamples,info.clipped_V1_clipsamples, etc),
%               and the total number of clipped points in the full ECG (info.totalClipping)
%
% *NOTE*: this function as currently only been tested and verified using GE MUSE format .pdf files with sweep 
% speeds are 25 mm/sec.  Variable voltage gains (5 mm/mV, 10 mm/mV, and 20 mm/mV) have been tested/validated.  
% 12 rhythm strips, 3x4 2.5 sec with 0-3 rhythm strups, and 6x2 5 sec with 0-3 rhythm strips are supported,
% but only the 12 rhythm strip format will allow all beats to temporally align in time.  This temporal alignment 
% is CRITICAL for accurate median beat generation.  
%
% This function also assumes data is compressed using FlateDecode and it uses java.util.zip.Inflater.
%
%
% EXAMPLE USAGE:
%  [pdfSig, pdfInfo] = load_musepdf('example.pdf', 'verbose', 'calcleads')
%
%  Leads aVR, aVL, and aVF will be calculated from leads I and II
%  streams found: 1 
%  Decompressed content: 801612 chars
%  Tokens parsed: 183288
%  Polylines: 423 total, 1 calibration, 409 gridlines, 100 unit grid spacing, 12 long, 12 long+black (ECG leads)
%  Alpha = 4.88 stream/ADU
%  Alpha = 122/25 stream/ADU in fractional form
%  PDF data format: 12 rhythm strips
%  Lead I: 5000 samples
%  Lead II: 5000 samples
%  Lead III: 5000 samples
%  Lead aVR: 5000 samples
%  Lead aVL: 5000 samples
%  Lead aVF: 5000 samples
%  Lead V1: 5000 samples
%  Lead V2: 5000 samples
%  Lead V3: 5000 samples
%  Lead V4: 5000 samples
%  Lead V5: 5000 samples
%  Lead V6: 5000 samples
%     Calculated Lead III Certification Passed
%     Calculated Lead aVR Certification Passed
%     Calculated Lead aVL Certification Passed
%     Calculated Lead aVF Certification Passed
%  Sampling frequency = 500 Hz
%
%  *ECG Certification Passed!*
%
%    To load lead II ->  pdfSig.II
%    To check if passed certification -> pdfSig.certified
%
%
%  [pdfSig, pdfInfo] = load_musepdf('example.pdf', 'pdfleads', 'adu')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [signals, info] = load_musepdf(pdfFile, varargin)

% SET UP INPUTS

% Set up default inputs
arguments
    pdfFile (1,:) char
end

arguments (Repeating)
    varargin (1,:) char {mustBeMember(varargin, {'exportfile','verbose','calcleads','pdfleads','adu'})}
end

% Defaults
exportfile = false;
verbose = false;
outputadu = false;
leadsMode  = 'calc';   % 'calc' | 'pdf'

% Parse varargin
for k = 1:numel(varargin)
    switch lower(varargin{k})
        case 'exportfile'
            exportfile = true;
        case 'verbose'
            verbose = true;
        case 'calcleads'
            leadsMode = 'calc';  
        case 'pdfleads'
            leadsMode = 'pdf';
        case 'adu'
            outputadu = true;
    end
end

% Info on what is being output based on input parameters
if outputadu && verbose
    fprintf('Output in ADU units\n') 
end

% Information on lead calculation/extraction for III, aVR, aVL, and aVF
if verbose
    switch leadsMode
        case 'calc'
           fprintf('\nLeads aVR, aVL, and aVF will be calculated from leads I and II\n')
        case 'pdf'
            fprintf('\nAll Leads will be extracted from .pdf file\n') 
    end
end

% Error if input file missing
if  ~isfile(pdfFile)
    error('load_musepdf: PDF file not found: %s', pdfFile);
end

%  Read PDF file
fid = fopen(pdfFile, 'rb');
if fid < 0
    error('load_musepdf: Cannot open file: %s', pdfFile);
end

% Read in uint8 as exact bytes
raw = fread(fid, Inf, '*uint8');
fclose(fid);

% Error if file does not open correctly.
if isempty(raw)
    error('load_musepdf: File read as empty (0 bytes).');
end

% Convert raw data into a row vector 
raw = raw(:)'; 

% Convert into a character vector to read metadata
rawStr = char(raw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK NUMBER OF PAGES

% Check that MUSE was used to generate the PDF because the code may not work for other manufacturers
isMuse = ~isempty(regexp(rawStr, '/(?:Producer|Creator)\s*\(MUSE', 'once'));

if ~isMuse
    error('load_musepdf: PDF does not appeart be be from MUSE.')
end

% Count number of pages in the PDF.  In general we only want to parse
% single page PDFs as this is standard, and anything on the second page
% would be non-standard leads.  The exceptions to this are standard 12-lead
% ECGs with a very long physician interpretation, where a second "blank"
% page with no signals and the rest of the physician interpretation can be
% present, and if a 12-lead rhythm strip ECG is at 50 mm/s where 2 pages
% are needed to show the full 10 seconds.  We will support the 2 pages
% where no signals are on the second page, but will NOT support ECGs at 
% 50 mm/s because this is very rare and adds significant complexity to
% parsing the leads over 2 pages.  If needed may add this functionality in
% a future release.

% We therefore allow 1 or 2 page PDFs.  MUSE uses PDF 1.5 compressed object 
% streams, so "N 0 obj" headers aren't reliably present as plain text and we 
% can't trace streams back to objects that way.  Instead we use byte position:
% in MUSE PDFs each page's content stream sits immediately after its page
% dictionary, so we cut off at the start of page 2's dictionary.

% Count number of pages
nPages = numel(regexp(rawStr, '/Type\s*/Page(?![a-zA-Z])', 'match'));
if nPages < 1 || nPages > 2
    error('load_musepdf: PDF has %d pages. Only 1- or 2-page ECG PDFs are supported.', nPages);
end

% streamCutoff is either the end of the first page.  This allows us to only
% scan the first page to avoid encountering anything on page 2 which could
% complicate parsing.
streamCutoff = numel(raw);   % 1 page: scan the whole file

if nPages == 2
    pageStarts   = regexp(rawStr, '/Type\s*/Page(?![a-zA-Z])', 'start');
    % Stop at the start of page 2
    streamCutoff = pageStarts(2);
    if verbose
        fprintf('2-page PDF: parsing only bytes before page 2 (byte %d)\n', streamCutoff);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT CONTENT STREAM ON PAGE 1

% Initialize content string
content = '';

% Initialize position in raw data
pos = 1;

% We are looking for the words 'stream' and 'endstream' to define the
% data stream which contains the data used to draw the ECG tracings 
% (although we dont use 'endstream' directly to find the end of the stream)

% # streams found counter
nStreams = 0;

% Loop through length of raw data -6 since 'stream' is 6 characters
while pos < streamCutoff - 6

    % Find next 'stream' that's NOT preceded by 'end'
    % start at index 'pos' 
    % first run is index 1:end since pos = 1 at the start
    % subsequent runs are 'pos':end
    % Find the RELATIVE index here
    relIdx = strfind(char(raw(pos:end)), 'stream');
    
    % If 'stream' is not found, break out of function
    if isempty(relIdx), break; end
    
    % Convert to absolute index
    % Take first relaitive index - 1
    sIdx = pos + relIdx(1) - 1;

    % Break out if past streamCutoff so dont find page 2 streams
    if sIdx >= streamCutoff, break; end
    
    % Skip if this is 'endstream'
    % looks at 3 characters prior to 'stream' at sIdx to make sure they are not 'end'
    if sIdx > 3 && all(raw(sIdx-3:sIdx-1) == uint8('end'))
        % If it is an 'endstream' then advance 'pos' to 6 characters past
        % that index so the search can continue
        pos = sIdx + 6;
        continue;
    end

    % Look backward up to 500 bytes for the object dictionary to ensure FlateDecode
        hdrStart = max(1, sIdx - 500);
        hdr = char(raw(hdrStart : sIdx - 1));

    % Check if hdr contains FlateDecode
        if ~contains(hdr, '/FlateDecode')
            if verbose
                fprintf('Skipping non-FlateDecode stream at byte %d\n', sIdx);
            end
        pos = sIdx + 6;
        continue;
    end
    
    % Skip past 'stream' keyword + line ending:
    % The PDF spec requires that the stream keyword be followed by exactly one line ending — either a 
    % single \n (LF, byte value 10) or the pair \r\n (CRLF, bytes 13 then 10) — before the binary stream 
    % data begins. This is just a separator, so we need to step past it to land on the first actual 
    % byte of compressed content.

    % Index to start after 'stream' characters are complete
    dataStart = sIdx + 6;

    % Keep advancing until past the bytes for line ending separator
    while dataStart <= numel(raw) && (raw(dataStart) == 13 || raw(dataStart) == 10)
        dataStart = dataStart + 1;
    end
    
    % Extract /Length from the stream dictionary per PDF spec.  Don't search for 'endstream' or trim 
    % trailing bytes - both can corrupt compressed binary data as we have seen!
    lengthTok = regexp(hdr, '/Length\s+(\d+)(?!\s+\d+\s+R)', 'tokens', 'once');
    if isempty(lengthTok)
        % Indirect /Length reference (/Length N M R) - not supported here
        if verbose
            fprintf('Skipping stream at byte %d: indirect /Length\n', sIdx);
        end
        pos = sIdx + 6;
        continue;
    end

    % Extract the actual length of the stream rather than trying to find 'endstream'
    streamLen = str2double(lengthTok{1});
    
    % Index of end of stream
    dataEnd = dataStart + streamLen - 1;
    
    % Error if stream is too long
    if dataEnd > numel(raw)
        if verbose
            fprintf('Skipping stream at byte %d: /Length exceeds file size\n', sIdx);
        end
        pos = sIdx + 6;
        continue;
    end

    % Decompress with Java's Inflater
    streamBytes = raw(dataStart:dataEnd);
    decompressed = inflateBytes(streamBytes);
    
    % Add decompressed stream data to content variable
    if ~isempty(decompressed)
        content = [content, char(decompressed)]; %#ok<AGROW>
        nStreams = nStreams + 1;
    end
    
    % 'pos' move past index of 'endstream'
    pos = dataEnd + 9;  
end

% Now all the data is extracted and decompressed!

% If no data in content, throw error
if isempty(content)
    error('load_musepdf: No decompressible content streams found.');
end

% Diagnostic info
if verbose
    fprintf('# streams found: %d \n', nStreams);
    fprintf('Decompressed content: %d chars\n', numel(content));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT GAINS FROM CONTENT STREAM

% Verify standard ECG calibration by scanning text in the content stream.  
% PDF text shown with the Tj operator appears as (string)Tj or [(string)(string)...]TJ.  
% Just look for the calibration substrings anywhere in the stream.

% Require that sweep speed is 25 mm/s
% Program does not support 50 mm/s (which is barely used) or 12.5 mm/s
% which cannot be used to print a MUSE PDF (although can be used for
% display on computer)
speed25 = ~isempty(regexp(content, '25\s*mm/s',  'once'));
if ~speed25
    foundCal = regexp(content, '\d+(\.\d+)?\s*mm/s', 'match');
    error('load_musepdf: Expected 25 mm/s calibration. Found: %s', strjoin(foundCal, ', '));
end

% Can allow variable gain for voltage, BUT all gains must be the same for
% the full ECG - function does not support different gains for limb and
% precordial leads which can theoretically show up.  MUSE indicates
% different gains for limb and precordial leads by 5,10 mm/s, so to detect
% an ECG with mixed gains we search for #,# mm/s
mixedGain = ~isempty(regexp(content, '\d+\s*,\s*\d+\s*mm/mV', 'once'));
if mixedGain
    error('load_musepdf: PDF has mixed gain for limb and precordial leads.  Only single gain is supported');
end

% Extract the voltage gain in mm/mV from PDF 
% Supports all standard gains of 5, 10, 20 mm/mV
gain_pdf = regexp(content, '(\d+(?:\.\d+)?)\s*mm/mV', 'tokens');
if isempty(gain_pdf)
    error('load_musepdf: No gain calibration found in PDF content stream');
end

% Extract LPF frequency from PDF.  
lpf_freq = str2double(regexp(content, 'Td \((\d+)Hz\) Tj ET', 'tokens', 'once'));

% Extracted gain in mm/mV
mm_per_mv = str2double(gain_pdf{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARSE PDF CONTENT STREAM INTO POLYLINES

% PDF path operators:
%  x y m       - moveto (start subpath)
%  x y l       - lineto (extend subpath)
%  S           - stroke and end path

% Legacy operators that are not currently used but remain for possible use
% in the future
%  r g b RG    - set stroke RGB color
%  g G         - set stroke gray
%  cm          - cm Matrix

% Split on whitespace into cell array 'tokens'
tokens = strsplit(content);

% Remove any empty strings from cell array 'tokens'
tokens = tokens(~cellfun('isempty', tokens));

if verbose
    fprintf('Tokens parsed: %d\n', numel(tokens));
end

% Initialize data parser for polyline data extraction

% All completed polylines so far
polylines = {};

% Colors of completed polylines so far
plColors  = {};

% Polyline being built right now
% 2-column matrix that accumulates [x, y] points as moveto/lineto operators arrive
currentPL = zeros(0, 2);

% Current stroke RGB color
strokeR = 0; 
strokeG = 0; 
strokeB = 0;

% Stack of pending numeric operands
% Row vector that grows or shrinks as numbers are pushed or operators consume them
opStack = zeros(1, 0);

% cm matrix for conversion between pdf units and physical units
cmMatrix = NaN(1,6);

% Number of tokens
nTokens = numel(tokens);

% Before the loop: classify and parse all numbers in ONE vectorized pass
% This cut down processing time dramatically
firstChars = cellfun(@(t) t(1), tokens);
isNum = (firstChars >= '0' & firstChars <= '9') | firstChars=='-' | firstChars=='.' | firstChars=='+';

nums = nan(1, nTokens);
nums(isNum) = str2double(tokens(isNum)); 

for i = 1:nTokens
    
    % For each token, if it's a number (nums is not NaN) then it's an operand -> push it into opStack and move on. 
    % If it is not a number (nums is NaN) then it must be an operator.

    t = tokens{i};

    if ~isnan(nums(i))
        opStack(end+1) = nums(i); %#ok<AGROW>
    else
        switch t

            case 'm'
            % moveto means start drawing somewhere new:
            % Pull the last two operands from the stack — that's the new (x, y) coordinate.
            
            % Delete any polyline that was already in progress. PDF lets a path contain multiple 
            % disjoint subpaths within a single stroke, but for our purposes each moveto marks 
            % a logical break, and we want each subpath as its own polyline.  If currentPL has 
            % at least 2 points (a real polyline, not just an unfinished move), save it to 
            % polylines along with the current color.
            
            % Start a fresh currentPL containing just this one new point.
            
            % Clear 'opStack'.

                if numel(opStack) >= 2
    
                    % Take most recent (x,y) which is last in opStack
                    x = opStack(end-1); 
                    y = opStack(end);
    
                    if size(currentPL, 1) >= 2
                        polylines{end+1} = currentPL; %#ok<AGROW>
                        plColors{end+1}  = [strokeR strokeG strokeB]; %#ok<AGROW>
                    end
    
                    currentPL = [x, y];
                end
    
                % Reset opStack
                opStack = zeros(1, 0);
            
            
            case 'l'
            % lineto: extend the current subpath:
            % Append a new [x, y] row to the current polyline. This is how the waveforms accumulate --
            % an ECG trace is a moveto followed by 5000 linetos.

                if numel(opStack) >= 2
                    % Take most recent (x,y) which is last in opStack
                    x = opStack(end-1); 
                    y = opStack(end);
                    currentPL(end+1, :) = [x, y]; %#ok<AGROW>
                end
    
                % Reset opStack
                opStack = zeros(1, 0);


            case 'S'
            % stroke: end of path:
            % The polyline is complete, save it, Flush currentPL to polylines, reset to empty, clear the stack.

                if size(currentPL, 1) >= 2
                    polylines{end+1} = currentPL; %#ok<AGROW>
                    plColors{end+1}  = [strokeR strokeG strokeB]; %#ok<AGROW>
                end

                currentPL = zeros(0, 2);

                % Reset opStack
                opStack = zeros(1, 0);


            % 'RG' and 'G' set stroke color
            case 'RG'
                if numel(opStack) >= 3
                    strokeR = opStack(end-2);
                    strokeG = opStack(end-1);
                    strokeB = opStack(end);
                end

                % Reset opStack
                opStack = zeros(1, 0);

            
            case 'G'
                % If grayscale, assign same value to RGB
                if numel(opStack) >= 1
                    g = opStack(end);
                    strokeR = g; 
                    strokeG = g; 
                    strokeB = g;
                end
    
                % Reset opStack
                opStack = zeros(1, 0);

            % Get matrix converting units to physical units    
            case 'cm'

            if numel(opStack) >= 6
                cmMatrix = opStack(end-5:end);   % [a b c d e f]

                if cmMatrix(1) ~= 0 || cmMatrix(4) ~= 0 || abs(cmMatrix(2)) ~= abs(cmMatrix(3))
                    error('load_musepdf: Unexpected cm matrix: [%s]. Expected MUSE-style rotated transform with a=d=0 and |b|=|c|.', sprintf('%g',cmMatrix));
                end

            end
            
            % Reset opStack
            opStack = zeros(1, 0);

            otherwise
            % Anything else
                % Reset opStack
                opStack = zeros(1, 0);
        end
    end
end


%  For safety, after the loop, check whether currentPL still contains a valid polyline (at least 2 points) and, if so, save it.
if size(currentPL, 1) >= 2
    polylines{end+1} = currentPL; %#ok<AGROW>
    plColors{end+1}  = [strokeR strokeG strokeB]; %#ok<AGROW>
end

% Confirm we extracted cmMatrix
if any(isnan(cmMatrix)) || numel(cmMatrix) ~= 6
    error('load_musepdf: No valid cm transform found in PDF content stream');
    % Placeholder for default for other formats that don't use cmMatrix
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PULL ECG LEADS and CALIBRATION PULSES OUT OF SET OF POLYLINES

% Verify lead ordering is expected:
lead_order = {'I','II','III','aVR','aVL','aVF', 'V1','V2','V3','V4','V5','V6'};
textCoords = nan(numel(lead_order), 2);   % column 1 = x, column 2 = y
rhythmTextCoords = []; % Dont know number of rhythm strups yet so will push in rather than preallocate
rhythmLead = {};

for k = 1:numel(lead_order)
    % Escape parens in the lead name aren't needed since leads are alphanumeric,
    % but we escape the literal parens around the lead in the stream.
%     pattern = ['BT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+Td\s+\(' ...
%                lead_order{k} '\)\s+Tj\s+ET'];
    pattern = ['BT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+Td\s+\(' ...
               lead_order{k} '\s*\)\s+Tj\s+ET'];
%     leadTok = regexp(content, pattern, 'tokens', 'once');
    leadTok = regexp(content, pattern, 'tokens');
    if ~isempty(leadTok)
        textCoords(k, :) = [str2double(leadTok{1}{1}), str2double(leadTok{1}{2})];

        % If found a second label for a rhythm strip
        if size(leadTok,2) == 2
            rhythmTextCoords = [rhythmTextCoords ; str2double(leadTok{2}{1}), str2double(leadTok{2}{2})];
            rhythmLead{end+1} = lead_order{k};
        end
    end
end

% Sort the textCoords - should be in the order of 1 through 12.  If not
% then something is non-standard about the PDF and throw error
[~, sortIdx] = sortrows([textCoords(:,1), textCoords(:,2)], [1 -2]);

% We use the textCoords to verify the difference between cal signals/baselines
% as well, as the difference between textCoords should be the same as difference
% between cal pulses (except for 12x1 where we have to use the textCoords
% as the way to find where the missing cal pulses would be located.  We
% take the diff of textCoords and get the diffY that is associated with
% diffX = 0 (same column)

diffTC = diff(textCoords);
diffTC_idx = find(diffTC(:,1) == 0);
calDelta = diffTC(diffTC_idx,:);
calDelta = abs(unique(calDelta(:,2)));

if numel(calDelta) > 1
    error('load_musepdf: Calibration of lead name locations is not consistent');
end

if ~isequal(sortIdx',[1 2 3 4 5 6 7 8 9 10 11 12])
    error('load_musepdf: Extraction of lead order from PDF text does not match expected lead orders');
end

% Sort the rhythm strip labels depending on format
if ~isempty(rhythmTextCoords)
    [~, sortIdx] = sortrows([rhythmTextCoords(:,1), rhythmTextCoords(:,2)], [1 -2]);
    rhythmLead = rhythmLead(sortIdx);
end

% Find the ECG waveforms (long black polylines)

% After the parser runs, polylines contains everything the PDF drew with stroked paths — 
% typically MANY entries: the 12 waveforms we care about, calibration pulses, grid lines, and 
% other lines. Two characteristics reliably distinguish waveforms from everything else: 
% they are long (lots of points) and black (or near-black). The Grid is short - only 2 
% points.  Calibration signals are 60 points

% nPts is a numeric vector the same length as polylines, with each entry being the point count of the 
% corresponding polyline. In general there are lots of very short polylines, and then there should 
% be 12 polylines that are long (>500 pts at 500 Hz) which are the 12 ECG leads
nPts = cellfun(@(p) size(p, 1), polylines);

% Each entry in plColors is a RGB triple. Checks whether the maximum of those three components is below 0.3 — 
% simple "is this color reasonably dark" test so it wont fail if the ECG is not perfect black.  
% This removes any pink grid lines (not color filtering anymore - just using length)
isBlack = cellfun(@(c) max(c) < 0.3, plColors);

% Emperically chose 500 samples as a minimum length as this can be used for 12 lead rhythm strips and 
% other formats like 4x3 with shorter leads
% Find indices where polyline is black AND has more than 500 points.
candIdx = find(isBlack & nPts > 500);
numExtractedLeads = numel(candIdx);

% Count how many long polylines (leads) there are
if numExtractedLeads < 12
    error('load_musepdf: Expected at least 12 long black polylines corresponding to lead data but only found %d.', numExtractedLeads);
end

% Get lead lengths
polyline_len = cellfun(@(c) length(c), polylines(candIdx));

% Want to choose the 12 leads that are the same length as this works for 12
% lead rhythm strips or 4x3 format (will ignore the rhythm strips until later)
keepIdx = find(polyline_len == mode(polyline_len));

% For each candidate polyline, compute the horizontal range -- max x minus min x.
% Column 1 of p is the x-coordinate (time axis in stream units).
% Column 2 of p is the y-coordinate (voltage axis in stream units).
% Sort(xExt, 'descend') returns the indices in descending order of extent.
% cand(ord(1:12)) takes the 12 widest, which are necessarily the 12 actual waveforms.

xExt = zeros(numel(candIdx), 1);
xStart = zeros(numel(candIdx), 1);
for k = 1:numel(candIdx)
    p = polylines{candIdx(k)};
    xExt(k) = max(p(:,1)) - min(p(:,1));
    xStart(k) = min(p(:,1));
end

% candIdx is the index of all extracted polylines that are the ECG leads
% This will be 12 for a rhythm strip ECG and 13-15 for a 4x3 ECG with 1-3
% rhythm strip leads at the bottom

% At this point we have 12-15 waveform polylines but in arbitrary order which is
% the order they happened to be drawn in the PDF, which isn't necessarily top-to-bottom on the page.
% The waveforms could be in any sequence (although usually not). We need to sort them by vertical position.

% For 12 lead rhythm strips:
% higher stream-y values correspond to higher positions on the displayed page. So lead I (top of the printout)
% has the highest median y, lead V6 (bottom) has the lowest. Sorting descending puts I first, V6 last

% However, for the 4x3 leads we also need to sort by horizontal position and vertical position

% Remove long rhythm strips in 4x3 - this has no effect for 12 rhythm strips
candIdx12 = candIdx(keepIdx);
numLeads12 = numel(candIdx12);
numRhythm = numel(candIdx) - numLeads12;
rhythmIdx = candIdx(polyline_len ~= mode(polyline_len));

% For voltage (vertical) position use the median of the lead voltage values as less affected by extremes
% For horizontal position use the location of the first sample
xBaseline = zeros(numLeads12, 1);
yBaseline = zeros(numLeads12, 1);
for k = 1:numLeads12
    p = polylines{candIdx12(k)};
    xBaseline(k) = p(1, 1);
    yBaseline(k) = median(p(:, 2));
end

% Sort by X and then Y within X for 12 leads
[~, sortIdx] = sortrows([xBaseline, yBaseline], [1 -2]);
% xBaseline = xBaseline(sortIdx);
% yBaseline = yBaseline(sortIdx);
candIdx12 = candIdx12(sortIdx);

if numel(candIdx12) < 12
    error('load_musepdf: Expected at least 12 ECG leads of same legnth but only found %d.', numel(candIdx12));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT CALIBRATION SIGNALS AND OFFSETS

% Count number of calibration pulses which are 60 samples long and get indices
% Also get baseline values and number of stream units in the cal signal height
calIdx = find(nPts == 60);
nCal = numel(calIdx);
calSig = cell(1,nCal);
calBaseline = zeros(1,nCal);
calMinMax = zeros(1,nCal);

% Pull out cal signal polylines and confirm these are cal signals: 
% should have 2 values with start and end the same. This is also a backup
% way to catch ECGs with different gains for different sets of leads
% Also extract the baseline stream values (first sample)
for k = 1:nCal
    calSig{k} = polylines{calIdx(k)};
    calBaseline(k) = calSig{k}(1,2);
    calMinMax(k) = max(calSig{k}(:,2)) - min(calSig{k}(:,2));
    if numel(unique(calSig{k}(:,2))) ~= 2 || (calSig{k}(1,2) ~= calSig{k}(end,2)) || numel(unique(calMinMax(k))) > 1
        error('load_musepdf: Calibration signals are misformed.');
    end
end

% Sort the baselines in reverse order to get the baselines in order of top to bottom
sortedBaseline = flip(sort(unique(calBaseline)));

% Validate cal signals and lead names have the same difference between
% leads as a check for all formats except 12x1.
if numel(sortedBaseline) > 1
    if calDelta ~= abs(unique(diff(sortedBaseline)))
        error('load_musepdf: Calibration signals and lead name labels are not consistently spaced.');
    end

else
% If in 12x1 format we don't have multiuple baselines, so we use the single
% calibration pulse (for lead I) and then use calDelta to get the rest
    sortedBaseline = sortedBaseline - (0:11) * calDelta;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT GRID VALUES

% Because the cal pulses and grid are themselves quantized twice, we can't
% completely rely on single cal pulse to define what 1 mV is in stream
% units.  As we found, the cal pulse is 1000 stream units at 10 mm/mV, 500
% stream units at 5 mm/mV, and 2001 stream units at 20 mm/mV.  So rounding
% can take the real value and push it to a different stream integer.  It is
% better to use the grid which is many doubly quantized values at a clear
% interval.  If there is any drift in the number of stream units per mV,
% this would show up as differences in the number of samples between grid
% lines in the Y axis.

% Each Y grid delta = 1 mm

xmin = cellfun(@(p) min(p(:,1)), polylines);
xmax = cellfun(@(p) max(p(:,1)), polylines);
ymin = cellfun(@(p) min(p(:,2)), polylines);
ymax = cellfun(@(p) max(p(:,2)), polylines);

isGrid  = nPts == 2;
isHorz = isGrid & (ymin == ymax) & (xmax > xmin);   % Constant Y

% Have to filter out the very short vertical lines that mark when a lead
% changes in a row.  Extract the legnth of the lines not just the points
% for the time grid.  No such lines exist for the voltage grid so this does
% not have to be done for voltage
ylen = cellfun(@(p) max(p(:,2)) - min(p(:,2)), polylines);
isVert = isGrid & (xmin == xmax) & (ymax > ymin) & (ylen > 0.8*max(ylen(isGrid)));

hy = sort(unique(cellfun(@(p) p(1,2), polylines(isHorz))));
hx = sort(unique(cellfun(@(p) p(1,1), polylines(isVert))));

units_per_mm = unique(diff(hy));
units_per_mm_sec = unique(diff(hx));

% Error if grid spacing is not equal
if numel(units_per_mm) > 1 || numel(units_per_mm_sec) > 1
    error('load_musepdf: Grid is misformed.');
end

if verbose
    fprintf('Polylines: %d total, %d calibration, %d gridlines, %d unit grid spacing, %d long, %d long+black (ECG leads)\n', ...
        numel(polylines), nCal, sum(isGrid), units_per_mm, sum(nPts>1000), sum(isBlack & nPts>1000));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE UNITS/SEC AND UNITS/MV

% Stream units/mV is based on the grid spacing and the mm/mV gain extracted from the PDF. 

% Hard code microvolts per LSB (from XML)
muV_per_LSB = 4.88;

% Calculate units per mV and units per sec from grid and gain
units_per_mv = units_per_mm * mm_per_mv;
units_per_sec = units_per_mm_sec * 25;       % Required to be 25 mm/sec

alpha = units_per_mm * mm_per_mv * (muV_per_LSB/1000);

% Need to get alpha in fractonal form for later certification tests
% Find fractional representation of muV_per_LSB because this will have
% fewer decimal places and just makes evrything easier
[s_num, s_den] = rat(muV_per_LSB, 1e-12);     

% alpha = units_per_mm * mm_per_mv * (muV_per_LSB/1000), so we have to
% multiply the numerator by units_per_mm * mm_per_mv and multiply the
% demoninator by 1000
numer = s_num * units_per_mm * mm_per_mv;        
denom = s_den * 1000;   

% We need the fraction in lowest terms so gcd(ap,aq) = 1
gcd_alpha   = gcd(numer, denom);
ap = numer/gcd_alpha;
aq = denom/gcd_alpha;

if ap <= aq
    error('load_musepdf: alpha <= 1, encoding is not reversible');
end

if verbose
    fprintf('Alpha = %.15g stream/ADU\n', alpha);
    fprintf('Alpha = %d/%d stream/ADU in fractional form\n',ap,aq);
end

% Calculate sampling frequency fs using the first ECG lead
p = polylines{candIdx12(1)};
streamX = p(:, 1);

% Set time to start at t=0 by subtracting the first streamX
t = (streamX - min(streamX)) / units_per_sec;

% Make sure uniform samples and calculate the sampling frequency to use later
dt = diff(t);

% Each delta time is not perfectly exact due to this floating point tolerance
% The tolerance is on the order of 1x-12, but we will impose a tighter
% tolerance just to be sure there are no issues
tol = 1 / units_per_sec;   % 1 stream unit = 0.4 ms for MUSE
    if max(abs(dt - median(dt))) > tol
        error('load_musepdf: Time samples are not uniformly spaced and exceed 1 stream unit of jitter');
    end

% Calculate the sampling freq
% round just in case some sneaky floating point issue returns
fs = round((length(t) - 1) / (t(end) - t(1)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE ECG LAYOUT

% Shorten variable name
SB = sortedBaseline;

% Determine ECG layout here so we can use the correct lead offsets for the specific ECG layout
% offsets variable includes the offset values in ADU units for the 12 main leads in standard order
lead_len = polyline_len(1:12);

% Signal length should be fs * duration in sec
% 12L rhythm strip should be 10 sec.  Set at 9 sec in case some missing
% samples or issues with rounding freq etc
if unique(lead_len) > fs * 9 
    ecg_format_string = '12 rhythm strips';
    ecg_format_id = '12LRhythm';

    offsets = SB;
    rhythmOffsets = [];

% 6x2 5 sec format has no rhythm strips but due to lead switching each non rhythm 
% strip lead is 12 samples shorter than would be expected   So the length will be longer 
% than 2.5 sec but shorter than 5 sec.  This format never has a rhythm strip.    
elseif unique(lead_len) > fs * 2.5 && unique(lead_len) <= fs * 5
    ecg_format_string = sprintf('6x2 5s and %d rhythm strips',numRhythm);
    ecg_format_id = '6x2';

    offsets = repmat([SB(1) SB(2) SB(3) SB(4) SB(5) SB(6)], 1, 2);
    rhythmOffsets = [];


% Everything else should be 4x3 2.5 sec with 0 or 3 rhythm strips
else
    switch numRhythm
        case 0 
            ecg_format_string = sprintf('4x3 2.5s and %d rhythm strips',numRhythm);
            ecg_format_id = '4x3+0';

            offsets = repmat([SB(1) SB(2) SB(3)], 1, 4);
            rhythmOffsets = [];

        case 1
            ecg_format_string = sprintf('4x3 2.5s and %d rhythm strips',numRhythm);
            ecg_format_id = '4x3+1';

            offsets = repmat([SB(1) SB(2) SB(3)], 1, 4);
            rhythmOffsets = [SB(4)];

        case 3
            ecg_format_string = sprintf('4x3 2.5s and %d rhythm strips',numRhythm);
            ecg_format_id = '4x3+3';

            offsets = repmat([SB(1) SB(2) SB(3)], 1, 4);
            rhythmOffsets = [SB(4) SB(5) SB(6)];


        otherwise
            error('load_musepdf: Number of rhythm strips (%d) is not supported', numRhythm);
    end
end 

% Show format if verbose
if verbose
    fprintf('PDF data format: %s\n',ecg_format_string)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVERT SIGNALS TO ADU UNITS

% Structure for storing extracted signals
signals = struct();
clipData = struct();
totalClipping = 0;
hiClip = zeros(1,12);
loClip = zeros(1,12);

% Convert the 12L polylines into numeric signals (this does not include
% rhythm strips on 4x3 format ECGs
for k = 1:12

    % Pull out the ECG lead polylines (indices are in wfIdx)
    p = polylines{candIdx12(k)};
    streamY = p(:, 2);

    % Clipping detection on raw stream based on max (21150) and min (450) stream values using min of 1 sample
    % If any lead (although its usually lead I) equal to or exceeds 21150 units the lead is clipped at this value
    % If any lead (although its usually lead V6) is equal to or below 450 units the lead is clipped at this value
    % We use 1 sample as indicating clipping because we can't tell if the 1 sample just reached max/min or if it 
    % was signifcantly larger, and even single point peak clipping can introduce errors. Will let user decide how 
    % to proceed if clipping is detected, as ANY clipping can reduce accuracy of the signal extraction.
    clipMask = detectClipping(streamY, 1);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Now use double quantization features to recover ADU units exactly.
    % See comments in function stream2adu()

    [adu, d] = stream2adu(streamY, alpha, ap, aq, offsets, k);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Assign signal to structure
    signals.(lead_order{k}) = adu;

    % Assign diagnostics to structure for debug purposes
        diagnostics.certified.(lead_order{k}) = d.certified;
        diagnostics.W.(lead_order{k}) = d.W;
        diagnostics.WMargin.(lead_order{k}) = d.Wmargin;
        diagnostics.passWLimit.(lead_order{k}) = d.pass_W_limit;
        diagnostics.passW.(lead_order{k}) = d.pass_W;
        diagnostics.GCD.(lead_order{k}) = d.gcd;
        diagnostics.numD.(lead_order{k}) = d.numD;
        diagnostics.passGCD.(lead_order{k}) = d.pass_gcd;
        diagnostics.BOut.(lead_order{k}) = d.B_out;
        diagnostics.BOutClasses.(lead_order{k}) = d.B_out_classes;
        diagnostics.passB.(lead_order{k}) = d.pass_B;


    % Save clipping data into structure
    clipData.(lead_order{k}) = sum(clipMask);
    clipData.([lead_order{k} '_clipsamples']) = find(clipMask == 1);
    totalClipping = totalClipping + numel(clipData.([lead_order{k} '_clipsamples']));

    if verbose
        fprintf('Lead %s: %d samples\n', lead_order{k}, length(adu));
            if diagnostics.certified.(lead_order{k}) == 0
                fprintf('   Lead %s Certification Failed!\n',lead_order{k});
            end
            
            if isnan(diagnostics.certified.(lead_order{k}))
                fprintf('   Lead %s Certification Indeterminant!\n',lead_order{k});
            end
    end

    % How far above/below baseline the clip ceiling sits (in mV)
    hiClip(k) = max(streamY);
    loClip(k) = min(streamY);
        
    if verbose && any(clipMask)  
        fprintf('   Lead %s: %d clipped samples (%.2f%%); data clipped to range ~[%d, %d] units\n', ...
            lead_order{k}, sum(clipMask), 100*sum(clipMask)/numel(clipMask), ...
            loClip(k), hiClip(k));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Decide which derived leads to reconstruct from I and II.
%   'pdf'  :: keep all PDF-extracted values
%   'calc' :: reconstruct leads III, aVR, aVL, aVF 

switch leadsMode
    case 'pdf', leadsToCalc = {};
    case 'calc', leadsToCalc = {'III','aVR','aVL','aVF'};
end

% If some leads need to be calculated
if ~isempty(leadsToCalc)
    formulas = struct( ...
        'III', @(s) -s.I + s.II, ...
        'aVF', @(s) (s.II - 0.5*s.I), ...
        'aVR', @(s) (-0.5*s.I - 0.5*s.II), ...
        'aVL', @(s) (s.I - 0.5*s.II));

    % Any reconstructed lead inherits clipped samples from its two source leads
    sharedClip = unique([clipData.I_clipsamples; clipData.II_clipsamples]);
    
    for k = 1:numel(leadsToCalc)
        ld = leadsToCalc{k};
        signals.(ld) = formulas.(ld)(signals);
        clipData.([ld '_clipsamples']) = sharedClip;
        clipData.(ld) = numel(sharedClip);
    end

    % Recalculate totalClipping
    totalClipping = 0;
    
    for k = 1:12
        totalClipping = totalClipping + numel(clipData.([lead_order{k} '_clipsamples'])); 
    end

    % Also have to redo the certification of the calculated leads, because
    % a lead could clip/fail certification using the waveforms extracted
    % from the PDF, but then be "rescued" by using lead I and II which are
    % not clipped and pass certification.  We can't just pass the
    % calculated leads through the certification tests because aVR, aVL,
    % and aVF do not exist in the original stream units (due to division by 2), 
    % and the tests therefore do not apply.  We will have the calculated
    % leads inheret the certification of leads I and II. If leads I and II
    % are certified bit exact then any derivation from them is also
    % guarenteed to be bit exact.  If lead I or II fails certification, then the
    % calculated leads fail certificatoin.  If Lead I or II is indeterminant (NaN), 
    % then the calculated leads are also indeterminant (NaN).  We also do
    % not pass along the numeric values of W etc because they may not apply

    % Get lead I and II certification
    leadIandIICerts = [diagnostics.certified.I diagnostics.certified.II];
    if any(leadIandIICerts == 0)
        calcLeadsCert = 0;
    elseif any(isnan(leadIandIICerts))
        calcLeadsCert = nan;
    elseif all(leadIandIICerts == 1)
        calcLeadsCert = 1;
    else
        error('load_musepdf: Unable to assign calculated lead certification')
    end

    % Assign the appropriate certification from leads I and II to diagnostics, and 
    % then save the orignal certification data to diagnostics.calcleadsOriginal
    for k = 1:numel(leadsToCalc)

        % Save the original diagnostics into diagnostics.calcleadsOriginal
        diagnostics.calcleadsOriginal.certified.(leadsToCalc{k}) = diagnostics.certified.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.W.(leadsToCalc{k}) =  diagnostics.W.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.WMargin.(leadsToCalc{k}) = diagnostics.WMargin.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.passWLimit.(leadsToCalc{k}) = diagnostics.passWLimit.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.passW.(leadsToCalc{k}) = diagnostics.passW.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.GCD.(leadsToCalc{k}) = diagnostics.GCD.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.numD.(leadsToCalc{k}) = diagnostics.numD.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.passGCD.(leadsToCalc{k}) = diagnostics.passGCD.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.BOut.(leadsToCalc{k}) = diagnostics.BOut.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.BOutClasses.(leadsToCalc{k}) = diagnostics.BOutClasses.(leadsToCalc{k});
        diagnostics.calcleadsOriginal.passB.(leadsToCalc{k}) = diagnostics.passB.(leadsToCalc{k});

        % Assign the lead I and II certification to the calculated leads
        % Everything except certified is NaN
        diagnostics.certified.(leadsToCalc{k}) = calcLeadsCert;
        diagnostics.W.(leadsToCalc{k}) = nan;
        diagnostics.WMargin.(leadsToCalc{k}) = nan;
        diagnostics.passWLimit.(leadsToCalc{k}) = nan;
        diagnostics.passW.(leadsToCalc{k}) = nan;
        diagnostics.GCD.(leadsToCalc{k}) = nan;
        diagnostics.numD.(leadsToCalc{k}) = nan;
        diagnostics.passGCD.(leadsToCalc{k}) = nan;
        diagnostics.BOut.(leadsToCalc{k}) = nan;
        diagnostics.BOutClasses.(leadsToCalc{k}) = nan;
        diagnostics.passB.(leadsToCalc{k}) = nan;

        if verbose
            if calcLeadsCert == 1
                calcLeadsCertStr = 'Passed';
            else
                calcLeadsCertStr = 'Failed!';
            end
            fprintf('   Calculated Lead %s Certification %s\n',leadsToCalc{k},calcLeadsCertStr);
        end

    end
end

% Verify all leads are the same legnth:
leadLengths = structfun(@length, signals);
if any(leadLengths ~= leadLengths(1))
    error('load_musepdf: Inconsistent lead lengths: [%s]', sprintf('%d ', leadLengths));
end


% Now deal with rhythm strips
% This only applies to 4x3 with 1-3 rhythm strips

if numRhythm > 0
    totalClippingRhythm = 0;

    for k = 1:numRhythm
        R = polylines{rhythmIdx(k)}(:,2);

        % Clipping detection on raw stream based on max (21150) and min (450) stream values using min of 2 samples
        % If any lead (although its usually lead I) exceeds 21150 units the lead is clipped at this value
        % If any lead (although its usually lead V6) is below 450 units the lead is clipped at this value
        clipMask = detectClipping(R, 1);
    
        % R currently is in stream units, so will convert to adu and subtract the position offset to zero signal as 
        % done for the individual leads
    
        [adu, d] = stream2adu(R, alpha, ap, aq, rhythmOffsets, k);
    
        % Write output to signals.rhythm while we are here
        % signals.rhythm does not show up for 12 lead rhythm strips (if numRhythm = 0)
        signals.rhythm.(rhythmLead{k}) = adu;

        % Assign diagnostics to structure for debug purposes
        diagnostics.rhythm.certified.(rhythmLead{k}) = d.certified;
        diagnostics.rhythm.W.(rhythmLead{k}) = d.W;
        diagnostics.rhythm.WMargin.(rhythmLead{k}) = d.Wmargin;
        diagnostics.rhythm.passWLimit.(rhythmLead{k}) = d.pass_W_limit;
        diagnostics.rhythm.passW.(rhythmLead{k}) = d.pass_W;
        diagnostics.rhythm.GCD.(rhythmLead{k}) = d.gcd;
        diagnostics.rhythm.numD.(rhythmLead{k}) = d.numD;
        diagnostics.rhythm.passGCD.(rhythmLead{k}) = d.pass_gcd;
        diagnostics.rhythm.BOut.(rhythmLead{k}) = d.B_out;
        diagnostics.rhythm.BOutClasses.(rhythmLead{k}) = d.B_out_classes;
        diagnostics.rhythm.passB.(rhythmLead{k}) = d.pass_B;

        % Save clipping data into structure
        clipData.rhythm.(rhythmLead{k}) = sum(clipMask);
        clipData.rhythm.([rhythmLead{k} '_clipsamples']) = find(clipMask == 1);
        totalClippingRhythm = totalClippingRhythm + numel(clipData.rhythm.([rhythmLead{k} '_clipsamples']));
    
        if verbose
            fprintf('Rhythm strip %s: %d samples\n', rhythmLead{k}, length(adu));
            if diagnostics.rhythm.certified.(rhythmLead{k}) == 0
                fprintf('   Rhythm Strip %s Certification Failed!\n',rhythmLead{k});
            end

            if isnan(diagnostics.rhythm.certified.(rhythmLead{k}))
                fprintf('   Rhythm Strip %s Certification Indeterminant!\n',lead_order{k});
            end
        end

        if verbose && any(clipMask)     
            % How far above/below baseline the clip ceiling sits (in mV)
            hiClip = max(R);
            loClip = min(R);
            
            fprintf('   Rhythm Strip %s: %d clipped samples (%.2f%%); Data clipped to range ~[%d, %d] units\n', ...
                rhythmLead{k}, sum(clipMask), 100*sum(clipMask)/numel(clipMask), ...
                loClip, hiClip);
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVERT UNITS IF NEEDED
% If outputting to mV (nominal) now convert ADU units to mV (1 ADU = 4.88 microvolts)

if ~outputadu
    % Convert ADU to mV
    signals.units = 'mV';

    for k = 1:12
        signals.(lead_order{k}) = signals.(lead_order{k}) * muV_per_LSB/1000;
    end

    for k = 1:numRhythm
        signals.rhythm.(rhythmLead{k}) = signals.rhythm.(rhythmLead{k}) * muV_per_LSB/1000;
    end

% If output ADU units
else
    signals.units = 'ADU';
end


% Export total number of clipped points - put in signals and info
clipData.totalClipping = totalClipping;
signals.totalClipping = totalClipping;

% Export total number of clipped points in rhythm strips for 4x2 format - put in signals and info
if numRhythm > 0
    clipData.totalClippingRhythm = totalClippingRhythm;
    signals.totalClippingRhythm = totalClippingRhythm;
end

% Write freq to signals
signals.hz = fs;

% Display sampling frequency
if verbose
    fprintf('Sampling frequency = %d Hz\n', fs);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OVERALL CERTIFICATION

% Make a single flag for if any of the validation test failed
% If any lead certification is 0 then the ECG fails
ECG_certified = 1;
fn = fieldnames(diagnostics.certified);

for k = 1:length(fn)
    if diagnostics.certified.(fn{k}) == 0
        ECG_certified = 0;
        break;
    end
end

if isfield(diagnostics,'rhythm') && ECG_certified == 1
    fnR = fieldnames(diagnostics.rhythm.certified);

    for k = 1:length(fnR)
        if diagnostics.rhythm.certified.(fnR{k}) == 0 
            ECG_certified = 0;
            break;
        end
    end
end

% If ECG_certified = 0 here then we are done and the ECG failed
% certification.  If ECG_certified still = 1 then have to check for any NaNs
for k = 1:length(fn)
    if isnan(diagnostics.certified.(fn{k}))
        ECG_certified = nan;
        break;
    end
end

if isfield(diagnostics,'rhythm') && ECG_certified == 1
    for k = 1:length(fnR)
        if isnan(diagnostics.rhythm.certified.(fnR{k}))
            ECG_certified = nan;
            break;
        end
    end
end


if verbose
    if ECG_certified == 1
        fprintf('\n*ECG Certification Passed!*\n');
    elseif ECG_certified == 0
        fprintf('\n*ECG Certification Failed!*\n');
    else
        fprintf('\n*ECG Certification Indeterminant!*\n');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE EXTRA DATA TO INFO

info = struct( ...
    'hz', fs, ...
    'leadOrder', {lead_order}, ...
    'leadsMode', leadsMode, ...
    'ecgFormat', ecg_format_id, ...
    'ecgFormatStr', ecg_format_string, ...
    'numPolylines',   numel(polylines), ...
    'numLeadsDetected', sum(isBlack & nPts>1000), ...
    'cmMatrix', cmMatrix, ...
    'cm2',cmMatrix(2), ...
    'certified', ECG_certified, ...
    'diagnostics', diagnostics, ...
    'XMLmicrovoltsLSB', muV_per_LSB, ...
    'lowPassFreq', lpf_freq, ...
    'unitsPerSec', units_per_sec, ...
    'unitsPerMv', units_per_mv, ...
    'mmPerMv', mm_per_mv, ...
    'mmPerSec', 25, ...
    'alpha', alpha, ...
    'offsets', SB, ...
    'numPages', nPages, ...
    'numStreams', nStreams, ...
    'clipping', clipData, ...
    'maxStreamUnits', hiClip, ...
    'minStreamUnits', loClip);

% Add rhythm strip info for 4x3 format
if numRhythm > 0
    info.rhythmStripLeads = rhythmLead';
end

% Add certification to signals structure too
signals.certified = ECG_certified;

% Export as csv
if exportfile
    exportFileName = pdfsig2csv(signals,pdfFile,outputadu);

    if verbose
        fprintf('\nExported %s to %s\n\n',pdfFile, exportFileName);
    end
end

end   % End function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Helper functions

function out = inflateBytes(deflated)
% zlib-inflate a uint8 vector using Java streams.
% Streams the bytes Java->Java the whole time so MATLAB's Java type
% bridge doesn't lose modifications to a MATLAB byte buffer.

    import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;
    bytesIn = typecast(deflated(:)', 'int8');
    bais = java.io.ByteArrayInputStream(bytesIn);
    iis = java.util.zip.InflaterInputStream(bais);
    baos = java.io.ByteArrayOutputStream();
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
        try
            isc.copyStream(iis, baos);
        catch ME
            warning('load_musepdf:inflate', 'Inflate failed: %s', ME.message);
            out = uint8([]);
            return;
        end
        iis.close();
        out = typecast(baos.toByteArray(), 'uint8')';
end


function filename = pdfsig2csv(signals, pdfFile, adu)
% Write leads to a .csv file with _digitized appended at the end so it is
% known that this file was a digitized PDF

% Does NOT write rhythm strips for 4x2.5 sec and 2x5 sec formats

    E = [signals.I signals.II signals.III signals.aVR signals.aVL signals.aVF ...
        signals.V1 signals.V2 signals.V3 signals.V4 signals.V5 signals.V6];

    if adu 
        filename = strcat(pdfFile(1:end-4),'_digitized_adu.csv');
    else
        filename = strcat(pdfFile(1:end-4),'_digitized.csv');
    end
    
    writematrix(E, filename);

end


function clipMask = detectClipping(stream, minRunLen)
% Flag clipped samples in a polyline.  A clipped sample is one inside a
% run of >= minRunLen consecutive identical stream values at either the
% max or min of the polyline.  This produces bit-exact plateaus which should
% not happen with real data.

    % Values that wre determined by inspection of ECGs
    min_clip_val = 450;
    max_clip_val = 21150;

    if nargin < 2
        minRunLen = 1;
    end

    clipMask = false(size(stream));

    n = numel(stream);
    if n < minRunLen
        return; 
    end

    maxY = max(stream);
    minY = min(stream);

    if maxY == minY 
        return;
    end

    if maxY >= max_clip_val || minY <= min_clip_val
        % clipMask is either all false or the values of clipping at stream values that are out of bounds
        clipMask = clipMask | findPlateaus(stream, max_clip_val, minRunLen);
        clipMask = clipMask | findPlateaus(stream, min_clip_val, minRunLen);
    end
end


function mask = findPlateaus(y, clipVal, minRunLen)
% Gives areas of clipping

    n = numel(y);
    mask = false(size(y));

    i = 1;
    while i <= n
        if y(i) == clipVal
            j = i;
            while j <= n && y(j) == clipVal
                j = j + 1;
            end
            
            if (j - i) >= minRunLen
                mask(i:j-1) = true;
            end

            % Jump to end of clipped segment
            i = j;
        else
            i = i + 1;
        end
    end
end


function [adu, diagnostics] = stream2adu(streamY, alpha, p, q, offsets, leadIdx)

    adu = round((streamY - offsets(leadIdx)) ./ alpha);

    % Validation of bit exactness
    % 1) Residue arc width: catches if alpha is correct (other than submultiple -- see GCD test)
    
    % By definition of mod: S mod(p/q) = qS mod(p).
    % and we have alpha = p/q
    % Therefore S mod(alpha) = qS mod(p) which is an integer between 0 and p-1
    % To avoid floating point issues we prefer to use mod(p) since p is an
    % integer but alpha is not
    
    R = mod(q*streamY, p);
    Ru = unique(R(:));
    
    % Sort the gaps
    Rgaps = [diff(Ru); Ru(1) + p - Ru(end)];
    
    % Number of ticks in W = qW, so W = # ticks/q
    Wticks = p - max(Rgaps);   
    W = Wticks/q;
    diagnostics.W = W;
    
    % Similar to passing when W <= (q-1)/q, using Wticks we get passing when Wticks <= q-1
    % If q is odd this works fine, if q is even theoretically have to know
    % about the rounding convention for values that are exactly half units,
    % so use the slightly looser cenvention of W < 1 (or Wticks < q)
    qLim = (q-1) + (mod(q,2)==0);
    diagnostics.pass_W = Wticks <= qLim;
    diagnostics.pass_W_limit = qLim/q;            % back in stream units as easier to compare 
    diagnostics.Wmargin   = (qLim - Wticks)/q;    % In stream units: negative values are outside bound (W fails)

    % Deal with degenerate cases of flat leads or integer alpha  with q = 1
    if q == 1
         % Integer alpha: no spread to measure.  This never shows up in
         % MUSE, but if it did at some point would likely want to remove
         % the W test from the certification.  This note is to mention this
         % possibility for furture MUSE or if this code is adapted for
         % another PDF manufacturer who uses integer alpha
        diagnostics.pass_W = nan;     
    elseif numel(Ru) < 2
        % Flat lead: insufficient evidence
        % The actual cutoff used here might warrant change at some point
        diagnostics.pass_W = nan;      
    end
    

    % 2) GCD: catches if alpha is an integer submultiple of the true alpha 
    % (missed by arc width since it just wraps around mod alpha)
    % Take non-zero values of A_n+1 - A_n
    d = abs(diff(adu)); 
    d = d(d~=0);
    diagnostics.numD = numel(d);

    if isempty(d) || numel(d) < 50   % Not assessable: no non-zero differences like a disconntected or flat lead
        diagnostics.pass_gcd = nan;      
        diagnostics.gcd = nan;
    else
        g = 0; 
        
        for v = d(:)'
            g = gcd(g,v); 
            if g==1, break; end
        end
        diagnostics.gcd = g;
        diagnostics.pass_gcd = (g == 1);
    end
    
    % If alpha is wrong, then it does not make sense to calculate the test of
    % if the offset (B) is correct, becuase if alpha is wrong then this will always show
    % B is wrong.  Additionally, if alpha is wrong, the correct window that
    % the residues need to live in is also not clearly defined - best to just
    % not calculate it as the ECG will be flagged by failing W anyway
    if diagnostics.pass_W == 0
        diagnostics.pass_B = NaN;            
        diagnostics.B_out = NaN;
        diagnostics.B_out_classes = NaN;
    else


    %3) Offset (B): Residues q*S mod p: exact integer arithmetic, independent of B
    R = mod(q*streamY, p);

    % Window is (q*B - q/2, q*B + q/2]; floor(x)+1 gives the first integer
    % strictly above the lower bound, guaranteeing exactly q ticks
    % Have to add +1 if q is even

    nwin = q + (mod(q,2)==0);              % odd q: q ticks.  even q: q+1
    n_lo = floor(q*offsets(leadIdx) - q/2) + 1 - (mod(q,2)==0);   % extend the lower edge
    BWindowModa = mod(n_lo + (0:nwin-1), p);

    B_out = sum(~ismember(R, BWindowModa));
    diagnostics.B_out  = B_out;
    diagnostics.B_out_classes = numel(unique(R(~ismember(R, BWindowModa))));    % residue classes, <= q
    diagnostics.pass_B   = (B_out == 0);

    end

    % If any test fails, certification fails.  Certification is only
    % possible if all 3 tests pass.  If one test is uninterpretable  but
    % others pass, then result is also uninterpretable and reports as nan
    tests = [diagnostics.pass_W, diagnostics.pass_gcd, diagnostics.pass_B];
    
    if(numel(tests) ~= 3)
        error('load_musepdf: expected 3 test results, got %d', numel(tests));
    end

    if any(tests == 0)
        diagnostics.certified = 0;
    elseif any(isnan(tests))
        diagnostics.certified = nan;
    elseif all(tests == 1)
        diagnostics.certified = 1;
    else
        error('load_musepdf: Unable to assign lead certification')
    end

end