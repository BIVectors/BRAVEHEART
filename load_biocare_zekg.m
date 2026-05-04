%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% load_biocare_zekg.m -- Load Biocare iE12A .zekg format ECGs
% Copyright 2016-2026 Hans F. Stabenau and Jonathan W. Waks
% This function authored by John Roberts (https://github.com/jlrjr)
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

function [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_biocare_zekg(filename)
%
% Authored by John Roberts (https://github.com/jlrjr)
%
% Usage:
%   [hz, I, II, III, avR, avF, avL, V1, V2, V3, V4, V5, V6] = load_zekg(filename)
%
% Input:
%   filename  - Full path to a .zekg file from a Biocare iE12A ECG machine
%
% Outputs:
%   hz        - Sampling frequency in Hz (typically 1000)
%   I..V6     - Lead voltage data in mV (column vectors, length = n_samples)
%
% File format (reverse-engineered from Biocare iE12A firmware VA2.04.0003 / V3.1.3):
%
%   Bytes 0-3   : 4-byte file header (magic: 00 6F 23 B0)
%   Bytes 4-end : zlib-compressed data block (zlib magic: 78 9C at offset 4)
%
%   Decompressed layout:
%     0x0000  : Magic signature FF EE EE FF
%     0x0008  : Filename string (null-padded)
%     0x0088  : Manufacturer string ("Biocare", null-padded)
%     0x0098  : Device model string ("ECGS12A", null-padded)
%     0x00A8  : Serial number string (null-padded)
%     0x00E8  : Recording timestamp 1 (day, month, year LE uint16, sec, min, hour bytes)
%     0x00F0  : Recording timestamp 2 (day, month, year LE uint16, sec, min, hour bytes)
%     0x0138  : Sampling frequency Hz (uint32 LE)
%     0x013C  : Total recording duration in seconds (uint32 LE)
%     0x01B8  : Section offset table (series of uint32 LE values, 0-indexed)
%       Table index  3 (at 0x01C4): offset to recording parameters section
%       Table index 17 (at 0x01FC): offset to waveform section header
%       Table index 18 (at 0x0200): waveform section header size in bytes
%                                   (= byte offset from section 17 start to waveform data)
%       Table index 19 (at 0x0204): direct offset to waveform data (= index 17 + index 18)
%       Table index 20 (at 0x0208): pre-allocated waveform data block size in bytes
%
%   Recording parameters section (at offset from table index 3):
%     +0  (uint32): ADC gain denominator; 1 ADC unit = (1000 / denominator) uV
%     +4  (uint16): bits per sample (16)
%     +6  (uint16): sample rate in Hz
%     +32 (uint32): number of leads (12)
%     +36 (uint32): number of samples per lead (n_samples)
%
%   Waveform section header (at offset from table index 17):
%     - Sparse event/annotation marker table (2 ms resolution over full recording)
%     - Non-zero entries mark R-peak and pacing spike events
%     - Size = table index 18 value in bytes (typically 30,000 bytes)
%
%   Waveform data (at offset from table index 17 + table index 18 bytes):
%     - 12 leads stored SEQUENTIALLY: I, II, III, aVR, aVL, aVF, V1-V6
%     - Each lead: n_samples contiguous signed 16-bit integers (little-endian)
%     - No run-length encoding; zeros represent genuine isoelectric baseline
%     - Units: ADC_value * (1000 / gain_denominator) uV
%     - Block is pre-allocated; only the first n_samples per lead contain ECG data
%
% Notes:
%   - ADC gain is device-specific and stored in the recording parameters section.
%     For iE12A firmware VA2.04.0003, gain_denominator = 873 => 1.145 uV per ADC unit.
%   - Pacing spike events are recorded in the waveform section header marker table,
%     not as special values within the waveform data itself.
%   - The total recording duration (0x013C) reflects the maximum recording window;
%     n_samples per lead is the actual count of valid samples in the waveform block.
%
% Tested on: Biocare iE12A firmware VA2.04.0003 / V3.1.3, 1000 Hz recordings

% --- Read raw file ---
fid = fopen(filename, 'rb');
if fid < 0
    error('load_zekg: cannot open file: %s', filename);
end
raw = fread(fid, inf, 'uint8=>uint8');
fclose(fid);

% --- Verify file header and zlib magic ---
if length(raw) < 8
    error('load_zekg: file too small to be a valid .zekg file');
end
% Bytes 0-3: file magic (00 6F 23 B0); bytes 4-5: zlib header (78 9C)
if raw(5) ~= 0x78 || raw(6) ~= 0x9C
    error('load_zekg: zlib magic bytes not found at offset 4 (expected 78 9C, got %02X %02X)', ...
        raw(5), raw(6));
end

% --- Decompress zlib block (starts at byte index 5, i.e., offset 4) ---
compressed = raw(5:end);
import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;
import java.io.*;
import java.util.zip.*;

try
    input_stream    = ByteArrayInputStream(compressed);
    inflater_stream = InflaterInputStream(input_stream);
    copier          = InterruptibleStreamCopier.getInterruptibleStreamCopier();
    output_stream   = ByteArrayOutputStream();
    copier.copyStream(inflater_stream, output_stream);
    d = typecast(output_stream.toByteArray(), 'uint8')';
catch ME
    error('load_zekg: zlib decompression failed: %s', ME.message);
end

% --- Verify decompressed magic ---
if length(d) < 0x0220
    error('load_zekg: decompressed data too small (%d bytes)', length(d));
end
if ~isequal(d(1:4), uint8([0xFF 0xEE 0xEE 0xFF]))
    warning('load_zekg: unexpected decompressed magic bytes (file may be corrupt or wrong version)');
end

% --- Read main header fields ---
% Sample rate and duration are in the main header
hz = double(typecast(d(0x0139:0x013C), 'uint32'));  % 0-indexed 0x0138, 1-indexed 0x0139

% --- Read recording parameters from section 3 ---
% Section table index 3 (0-indexed byte offset 0x01C4, MATLAB 1-indexed 0x01C5)
% contains the 0-indexed offset to the recording parameters block.
off3 = double(typecast(d(0x01C5:0x01C8), 'uint32'));  % 0-indexed offset of section 3

% Recording parameters block fields (all 0-indexed from off3):
%   +0  uint32: ADC gain denominator
%   +4  uint16: bits per sample
%   +6  uint16: sample rate (redundant with 0x0138)
%   +32 uint32: number of leads
%   +36 uint32: number of samples per lead
if length(d) < off3 + 40
    error('load_zekg: decompressed data too small to contain recording parameters section');
end

gain_denom = double(typecast(d(off3+1  : off3+4),  'uint32'));  % e.g. 873
n_leads    = double(typecast(d(off3+33 : off3+36), 'uint32'));  % should be 12
n_samples  = double(typecast(d(off3+37 : off3+40), 'uint32'));  % samples per lead

if n_leads ~= 12
    error('load_zekg: expected 12 leads but recording parameters report %d', n_leads);
end

% ADC scale: 1 ADC unit = (1000 / gain_denom) uV = (1000 / gain_denom) / 1000 mV
gain_mV = (1000.0 / gain_denom) / 1000.0;

% --- Locate waveform data ---
% The waveform section consists of two parts:
%   1. A sparse event marker header (section 17, size = index 18 bytes)
%   2. The actual sequential waveform data (starting immediately after the header)
%
% Table index 17 (0-indexed offset 0x01FC, MATLAB 0x01FD): section 17 start offset
% Table index 18 (0-indexed offset 0x0200, MATLAB 0x0201): header byte size
% Waveform data 0-indexed offset = index_17_value + index_18_value

off17       = double(typecast(d(0x01FD:0x0200), 'uint32'));  % section 17 start (0-indexed)
header_size = double(typecast(d(0x0201:0x0204), 'uint32'));  % waveform header bytes (e.g. 30000)

waveform_offset_0indexed = off17 + header_size;          % 0-indexed start of waveform data
waveform_matlab          = waveform_offset_0indexed + 1; % MATLAB 1-indexed

% Sanity check: waveform fits in decompressed data
waveform_size_bytes = n_leads * n_samples * 2;  % 12 leads * n_samples * 2 bytes/sample
if waveform_matlab + waveform_size_bytes - 1 > length(d)
    error('load_zekg: waveform data (%d bytes) extends beyond decompressed block (%d bytes)', ...
        waveform_size_bytes, length(d));
end

% --- Read waveform data ---
% 12 leads stored sequentially: [I_s0..I_sN, II_s0..II_sN, ..., V6_s0..V6_sN]
% Each value is a signed 16-bit integer, little-endian
waveform_raw = double(typecast( ...
    d(waveform_matlab : waveform_matlab + waveform_size_bytes - 1), 'int16'));

% --- Extract individual leads as column vectors in mV ---
% Lead order: I, II, III, aVR, aVL, aVF, V1, V2, V3, V4, V5, V6
I   = (waveform_raw(0*n_samples+1 : 1*n_samples)' ) * gain_mV;
II  = (waveform_raw(1*n_samples+1 : 2*n_samples)' ) * gain_mV;
III = (waveform_raw(2*n_samples+1 : 3*n_samples)' ) * gain_mV;
avR = (waveform_raw(3*n_samples+1 : 4*n_samples)' ) * gain_mV;
avL = (waveform_raw(4*n_samples+1 : 5*n_samples)' ) * gain_mV;
avF = (waveform_raw(5*n_samples+1 : 6*n_samples)' ) * gain_mV;
V1  = (waveform_raw(6*n_samples+1 : 7*n_samples)' ) * gain_mV;
V2  = (waveform_raw(7*n_samples+1 : 8*n_samples)' ) * gain_mV;
V3  = (waveform_raw(8*n_samples+1 : 9*n_samples)' ) * gain_mV;
V4  = (waveform_raw(9*n_samples+1 : 10*n_samples)') * gain_mV;
V5  = (waveform_raw(10*n_samples+1: 11*n_samples)') * gain_mV;
V6  = (waveform_raw(11*n_samples+1: 12*n_samples)') * gain_mV;

end  % function load_zekg
