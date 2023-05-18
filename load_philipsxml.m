%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_philipsxml.m -- Load Philips XML format ECGs
% Copyright 2016-2023 Hans F. Stabenau and Jonathan W. Waks
%
% Code adapted from: github.com/sixlettervariables/sierra-ecg-tools
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

function [hz, I, II, V1, V2, V3, V4, V5, V6] = load_philipsxml(filename)
% Philips XML format


% Deal with parsing issues with xmlread
% Create Document Builder
builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;
% Disable dtd validation
% builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

tree = xmlread(filename, builder);

% Verify some details about the file
hz = elgetn(tree, 'samplingrate');
assert(hz==500);

% get the mv per unit
gain = elgetn(tree, 'resolution');
assert(gain==5);    % Assume 5 uV/unit = 0.005 mV/unit
gain = gain/1000;

% convert from java string array
data = char(elget(tree, 'parsedwaveforms'));

% following code courtesy of
% https://github.com/sixlettervariables/sierra-ecg-tools/blob/master/examples/matlab/sierra_ecg.m

data(strfind(data,newline)) = []; %Remove newlines

% Decode from Base64
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: Use Octave's base64decode
decoded = uint8(matlab.net.base64decode(data));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract each of the 12 leads
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
leads = {};
leadOffset = 0;
for n = 1:12

    % Extract chunk header
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The header is the first 64 bits of each chunk.
    header = decoded(leadOffset+1:leadOffset+8);

    % The size of the ECG data following it is coded in the first 32 bits.
    datasize = typecast(header(1:4), 'uint32');

    % The second part of the header is a 16bit integer of unknown purpose.
    codeone = typecast(header(5:6), 'uint16'); % That integer converted from binary.

    % The last part of the header is a signed 16bit integer that we will use later (delta code #1).
    delta = typecast(header(7:8), 'int16');

    % Now we use datasize above to read the appropriate number of bytes
    % beyond the header. This is encoded ECG data.
    block = uint8(decoded(leadOffset+9:leadOffset+9+datasize-1));
    % assert(datasize == length(block));

    % Convert 8-bit bytes into 10-bit codes (stored in 16-bit ints)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % number of 10-bit codes
    codecount = floor((datasize*8)/10);
    codes = zeros(1, codecount, 'uint16');

    offset = 1;
    bitsRead = 0;
    buffer = uint32(0);
    done = false;
    for code = 1:codecount
        % adapted from libsierraecg
        while bitsRead <= 24
          if offset > datasize
              done = true;
              break;
          else
              buffer = bitor(buffer, bitshift(uint32(block(offset)), 24 - bitsRead));
              offset = offset + 1;
              bitsRead = bitsRead + 8;
          end
        end

        if done
            break;
        else
            % 32 - codeSize = 22
            codes(code) = uint16(bitand(bitshift(buffer, -22), 65535));
            buffer = bitshift(buffer, 10);
            bitsRead = bitsRead - 10;
        end
    end

    % LZW Decompression
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Data is compressed with 10-bit LZW codes (last 2 codes are padding)
    [decomp, ~] = lzw2norm(codes(1:length(codes)-2));

    %If the array length is not a multiple of 2, tack on a zero.
    if mod(length(decomp),2)~=0
        decomp = [decomp 0]; %#ok<AGROW> 
    end

    % Deinterleave into signed 16-bit integers
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The decompressed data is stored [HIWORDS...LOWORDS]
    half = length(decomp)/2;
    output = reshape([decomp(half+1:length(decomp));decomp(1:half)],1,[]);
    output = typecast(output, 'int16');

    % The 16bit ints are delta codes. We now use the delta decoding scheme
    % outlined by Watford to reconstitute the original signal.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    first = delta;
    prev = first;
    x = output(1);
    y = output(2);
    z = zeros(length(output),1);
    z(1) = x;
    z(2) = y;
    for m = 3:length(output)
        z(m) = (2*y)-x-prev;
        prev = output(m) - 64;
        x = y;
        y = z(m);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    leads = [leads z];

    % move to the next lead (8 byte header + datasize bytes of payload)
    leadOffset = leadOffset + 8 + datasize;
end

% Convert leads cell array to numeric matrix
leads = cell2mat(leads);
% assume fixed size
assert(size(leads, 1)==5500);
% crop calibration spike
leads = leads(1:5000,:);

% Multiply leads by gain
leads = gain * leads;

I = leads(:,1);
II = leads(:, 2);
V1 = leads(:, 7);
V2 = leads(:, 8);
V3 = leads(:, 9);
V4 = leads(:, 10);
V5 = leads(:, 11);
V6 = leads(:, 12);



end

% utility functions
function r = elget(l, name)
r = l.getElementsByTagName(name).item(0).getFirstChild.getNodeValue;
end
function r = elgetn(l, name)
r = str2double(elget(l, name));
end
