 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_mfer.m -- Loads .mwf MFER format ECG files 
% Copyright 2016-2025 Hans F. Stabenau and Jonathan W. Waks
%
% Code adapted from: https://cardiocurves.sourceforge.net/
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_mfer(filename)
   
% Initialize outputs
ecg_data = struct();
metadata = struct();
verbose = 0;    % Some text output if want to debug
    
% Check if file exists
if ~exist(filename, 'file')
    error('MFER file %s not found', filename);
end
    
% Open file for binary reading
fid = fopen(filename, 'rb', 'ieee-be'); % Start with big-endian
if fid == -1
    error('Cannot open MFER file %s', filename);
end
    
try

% Parse the MFER file
[tags, waveform_data, file_lead_names, lead_codes] = parse_mfer_file(fid);

% Extract metadata and calculate sampling rate
[metadata, sampling_rate] = extract_metadata(tags);
        
% Store lead names and lead codes
metadata.lead_names = file_lead_names;
metadata.lead_codes = lead_codes;
        
% Process waveform data
ecg_matrix = process_waveform_data(waveform_data, metadata);
        
% Create structure with individual leads
ecg_data = struct();
num_leads = size(ecg_matrix, 1);

% Create time vector
ecg_data.time = (0:size(ecg_matrix, 2)-1) / sampling_rate;
ecg_data.sampling_rate = sampling_rate;
ecg_data.duration = length(ecg_data.time) / sampling_rate;
ecg_data.num_leads = num_leads;

% Store individual leads with sequential numbering only
ECG12LeadsCodes = cell(100, 1);
ECG12LeadsCodes(1:8) = {'I','II','V1','V2','V3','V4','V5','V6'};
ECG12LeadsCodes(11:15) = {'V3R','V4R','V5R','V6R','V7R'};
ECG12LeadsCodes(61:64) = {'III','aVR','aVL','aVF'};
ECG12LeadsCodes(66:69) = {'V8','V9','V8R','V9R'};
        
lead_names_actual = {};

for i = 1:num_leads
    % Store as leadN for consistent access
    field_name = sprintf('lead%d', i);
    ecg_data.(ECG12LeadsCodes{metadata.lead_codes(i)}) = ecg_matrix(i, :);
    
    % Determine actual lead name for metadata only
    if i <= length(lead_codes) && lead_codes(i) > 0 && ...
       lead_codes(i) <= length(ECG12LeadsCodes) && ...
       ~isempty(ECG12LeadsCodes{lead_codes(i)})
        lead_name = ECG12LeadsCodes{lead_codes(i)};
    else
        lead_name = sprintf('Lead_%d', i);
    end
    lead_names_actual{i} = lead_name;
end
        
% Store lead name information
ecg_data.lead_names = lead_names_actual;
ecg_data.lead_codes = lead_codes;

% Assert that we have standard 8-lead format with codes 1-8
assert(length(lead_codes) == 8, ...
       'Expected 8 leads, but found %d leads', length(lead_codes));
assert(isequal(sort(lead_codes), 1:8), ...
       'Expected lead codes 1-8, but found: %s', mat2str(lead_codes));

if verbose
    fprintf('Successfully read MFER file:\n');
    fprintf('  Leads: %d\n', num_leads);
    fprintf('  Samples per lead: %d\n', size(ecg_matrix, 2));
    fprintf('  Sampling rate: %d Hz\n', sampling_rate);
    fprintf('  Duration: %.2f seconds\n', ecg_data.duration);
    fprintf('  Lead names: %s\n', strjoin(lead_names_actual, ', '));
end
        
catch ME
    fclose(fid);
    rethrow(ME);
end

fclose(fid);

% Now get output in correct format and do some error checking to make sure
% the correct leads are in the correct order.

hz = ecg_data.sampling_rate;

% Generate 4 other leads
III = -ecg_data.I + ecg_data.II;
avF = ecg_data.II - 0.5*ecg_data.I;
avR = -0.5*ecg_data.I - 0.5*ecg_data.II;
avL = ecg_data.I - 0.5*ecg_data.II;

% Make 8 other leads in correct output format - can't call data within a
% structure as a function output.  For consistency with other format load
% functions will output the indiidual leads and not a structure containing 
% the leads
I = ecg_data.I;
II = ecg_data.II;
V1 = ecg_data.V1;
V2 = ecg_data.V2;
V3 = ecg_data.V3;
V4 = ecg_data.V4;
V5 = ecg_data.V5;
V6 = ecg_data.V6;

end  % end main function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tags, waveform_data, lead_names, lead_codes] = parse_mfer_file(fid)
    % Parse MFER file and extract tags, waveform data, and lead information
    
    tags = [];
    waveform_data = [];
    tag_count = 0;
    
    % Also track lead names and channel-specific info
    lead_names = {};
    lead_codes = [];
    
    % MFER tag definitions
    MWF_IVL = hex2dec('0B'); % Sampling interval
    MWF_SEN = hex2dec('0C'); % Sampling resolution
    MWF_BLK = hex2dec('04'); % Block length
    MWF_CHN = hex2dec('05'); % Number of channels
    MWF_SEQ = hex2dec('06'); % Number of sequences
    MWF_WFM = hex2dec('08'); % Waveform type
    MWF_LDN = hex2dec('09'); % Lead name
    MWF_WAV = hex2dec('1E'); % Waveform data
    MWF_BLE = hex2dec('01'); % Byte order
    MWF_ATT = hex2dec('3F'); % Channel attributes
    
    while ~feof(fid)
        % Read tag
        tag_byte = fread(fid, 1, 'uint8');
        if isempty(tag_byte)
            break;
        end
        
        % Handle channel attributes (extract lead information)
        if tag_byte == MWF_ATT
            channel_byte = fread(fid, 1, 'uint8');
            
            % Read length
            length_byte = fread(fid, 1, 'uint8');
            if bitand(length_byte, 128)
                num_octets = bitand(length_byte, 127);
                data_length = 0;
                for i = 1:min(4, num_octets)
                    byte_val = fread(fid, 1, 'uint8');
                    data_length = bitor(bitshift(data_length, 8), byte_val);
                end
            else
                data_length = length_byte;
            end
            
            % Extract lead information from channel-specific data
            if data_length > 0
                channel_data = fread(fid, data_length, 'uint8');
                
                % Parse inner tags for lead name (tag 9)
                data_pos = 1;
                while data_pos <= length(channel_data) - 1
                    inner_tag = channel_data(data_pos);
                    inner_len = channel_data(data_pos + 1);
                    data_pos = data_pos + 2;
                    
                    if inner_tag == 9 && inner_len == 1  % Lead name tag
                        lead_code = channel_data(data_pos);
                        lead_codes(end+1) = lead_code;
                        
                        % Map to standard ECG lead names
                        ECG12LeadsCodes = cell(100, 1);
                        ECG12LeadsCodes(1:8) = {'I','II','V1','V2','V3','V4','V5','V6'};
                        ECG12LeadsCodes(11:15) = {'V3R','V4R','V5R','V6R','V7R'};
                        ECG12LeadsCodes(61:64) = {'III','aVR','aVL','aVF'};
                        ECG12LeadsCodes(66:69) = {'V8','V9','V8R','V9R'};
                        
                        if lead_code > 0 && lead_code <= length(ECG12LeadsCodes) && ...
                           ~isempty(ECG12LeadsCodes{lead_code})
                            lead_names{end+1} = ECG12LeadsCodes{lead_code};
                        else
                            lead_names{end+1} = sprintf('Lead_%d', lead_code);
                        end
                    end
                    
                    data_pos = data_pos + inner_len;
                end
            end
            continue;
        end
        
        % Read length for other tags
        length_byte = fread(fid, 1, 'uint8');
        if isempty(length_byte)
            break;
        end
        
        % Parse length (can be multi-byte)
        if bitand(length_byte, 128) % bit 7 set
            num_octets = bitand(length_byte, 127);
            num_octets = min(4, num_octets); % limit to 4 bytes
            
            data_length = 0;
            for i = 1:num_octets
                byte_val = fread(fid, 1, 'uint8');
                data_length = bitor(bitshift(data_length, 8), byte_val);
            end
        else
            data_length = length_byte;
        end
        
        % Read tag data
        if tag_byte == MWF_WAV
            % Special handling for waveform data
            waveform_data = fread(fid, data_length, 'uint8');
        elseif tag_byte == MWF_LDN
            % Lead name data
            tag_data = fread(fid, data_length, 'uint8');
            if data_length > 2
                % String description - convert to string
                lead_name = char(tag_data(tag_data > 0)'); % Remove null bytes
                lead_names{end+1} = strtrim(lead_name);
            end
            
            % Store tag information
            tag_count = tag_count + 1;
            tags(tag_count).type = tag_byte;
            tags(tag_count).length = data_length;
            tags(tag_count).data = tag_data;
        else
            % Regular tag data
            tag_data = fread(fid, data_length, 'uint8');
            
            % Store tag information
            tag_count = tag_count + 1;
            tags(tag_count).type = tag_byte;
            tags(tag_count).length = data_length;
            tags(tag_count).data = tag_data;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [metadata, sampling_rate] = extract_metadata(tags)

    % Extract metadata from parsed tags
    metadata = struct();
    metadata.numberOfChannels = [];
    metadata.numberOfSequences = [];
    metadata.dataBlockLength = [];
    metadata.samplingRateMantissa = [];
    metadata.samplingRateExponent = [];
    metadata.samplingResolutionMantissa = [];
    metadata.samplingResolutionExponent = [];
    metadata.byteOrder = 'big-endian';
    metadata.waveformType = 0;
    
    % MFER tag definitions
    MWF_IVL = hex2dec('0B');
    MWF_SEN = hex2dec('0C');
    MWF_BLK = hex2dec('04');
    MWF_CHN = hex2dec('05');
    MWF_SEQ = hex2dec('06');
    MWF_WFM = hex2dec('08');
    MWF_BLE = hex2dec('01');
    
    for i = 1:length(tags)
        tag = tags(i);
        
        switch tag.type
            case MWF_IVL % Sampling interval
                if tag.length >= 2
                    metadata.samplingRateUnit = tag.data(1);
                    metadata.samplingRateExponent = typecast(uint8(tag.data(2)), 'int8');
                    
                    if tag.length > 2
                        % Read mantissa (little-endian in data)
                        mantissa_bytes = tag.data(3:end);
                        metadata.samplingRateMantissa = bytes_to_int(mantissa_bytes, metadata.byteOrder);
                    end
                end
                
            case MWF_SEN % Sampling resolution
                if tag.length >= 2
                    metadata.samplingResolutionUnit = tag.data(1);
                    metadata.samplingResolutionExponent = typecast(uint8(tag.data(2)), 'int8');
                    
                    if tag.length > 2
                        res_bytes = tag.data(3:end);
                        metadata.samplingResolutionMantissa = bytes_to_int(res_bytes, metadata.byteOrder);
                    end
                end
                
            case MWF_BLK % Block length
                metadata.dataBlockLength = bytes_to_int(tag.data, metadata.byteOrder);
                
            case MWF_CHN % Number of channels
                metadata.numberOfChannels = bytes_to_int(tag.data, metadata.byteOrder);
                
            case MWF_SEQ % Number of sequences
                metadata.numberOfSequences = bytes_to_int(tag.data, metadata.byteOrder);
                
            case MWF_WFM % Waveform type
                if tag.length <= 2
                    metadata.waveformType = bytes_to_int(tag.data, metadata.byteOrder);
                end
                
            case MWF_BLE % Byte order
                if tag.data(1) == 0
                    metadata.byteOrder = 'big-endian';
                else
                    metadata.byteOrder = 'little-endian';
                end
        end
    end
    
    % Calculate sampling rate
    exp_val = abs(metadata.samplingRateExponent);
    res = 10.0^double(exp_val);
    sampling_rate = res / metadata.samplingRateMantissa;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = bytes_to_int(bytes, byte_order)
    % Convert byte array to integer based on byte order
    
    if isempty(bytes)
        result = 0;
        return;
    end
    
    if strcmp(byte_order, 'little-endian')
        % Little-endian: least significant byte first
        result = 0;
        for i = length(bytes):-1:1
            result = result * 256 + double(bytes(i));
        end
    else
        % Big-endian: most significant byte first
        result = 0;
        for i = 1:length(bytes)
            result = result * 256 + double(bytes(i));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ecg_data = process_waveform_data(waveform_data, metadata)
    % Process raw waveform data into ECG signals
    
    if isempty(waveform_data)
        ecg_data = [];
        return;
    end
    
    % Convert bytes to 16-bit signed integers
    if strcmp(metadata.byteOrder, 'little-endian')
        % Little-endian
        data_16bit = typecast(uint8(waveform_data), 'int16');
    else
        % Big-endian - need to swap bytes
        if mod(length(waveform_data), 2) ~= 0
            waveform_data = [waveform_data; 0]; % Pad if odd length
        end
        
        % Reshape and swap byte pairs
        reshaped = reshape(waveform_data, 2, []);
        swapped = [reshaped(2,:); reshaped(1,:)];
        data_16bit = typecast(uint8(swapped(:)), 'int16');
    end
    
    if metadata.numberOfChannels > 1
        % Interleaved: [Ch1_S1, Ch2_S1, ..., Ch8_S1, Ch1_S2, Ch2_S2, ...]
        % Sequential: [Ch1_S1, Ch1_S2, ..., Ch1_SN, Ch2_S1, Ch2_S2, ...]
        % It appears as if the data is stored SEQUENTIALLY
        
%         samples_per_channel = floor(total_samples / metadata.numberOfChannels);
        ecg_data = reshape(data_16bit, metadata.dataBlockLength, metadata.numberOfChannels)';

        % Apply scaling factor (convert to mV)
        sampling_res = metadata.samplingResolutionMantissa * ...
                       (10.0^double(metadata.samplingResolutionExponent));
        ecg_data = double(ecg_data) * sampling_res * 1000; % Convert to mV     
        
    else
        error("Not enough leads in MFER file")
    end
end
