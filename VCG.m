%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% VCG.m -- VCG Object Class
% Copyright 2016-2025 Hans F. Stabenau and Jonathan W. Waks
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


classdef VCG
    properties (SetAccess=protected)
        hz
        units
        X
        Y
        Z
        VM
        endspikes
    end
    methods
        function obj = VCG(varargin)
            if nargin == 0; return; end
            if nargin == 2
                if isa(varargin{1}, 'ECG12') && isa(varargin{2}, 'Annoparams')
                    e = varargin{1}; a = varargin{2};
                    obj.hz = e.hz; obj.units = e.units;
                    [obj.X, obj.Y, obj.Z, obj.VM] = ...
                        ecgtransform(e.I, e.II, e.V1, e.V2, e.V3, e.V4, e.V5, e.V6, a.transform_matrix_str);
                elseif ischar(varargin{1}) && ischar(varargin{2})
                    filename=varargin{1};
                    format=varargin{2};
                    switch format
                        case 'muse_xml'
                            tree = xmlread(filename);
                            wlist = tree.getElementsByTagName('Waveform');
                            waveform=[];
                            for k=0:wlist.getLength-1 % find the "rhythm" strip (not the median beat)
                                wtype = elget(wlist.item(k), 'WaveformType');
                                if strcmp(wtype, 'Rhythm'); waveform=wlist.item(k); break; end
                            end
                            obj.hz = elgetn(waveform, 'SampleBase');
                            exp = elgetn(waveform, 'SampleExponent');
                            assert(exp == 0, '%s: nonzero sample exponent %f', filename, exp);
                            leads = waveform.getElementsByTagName('LeadData');
                            for k=0:leads.getLength-1
                                l = leads.item(k);
                                gain = elgetn(l, 'LeadAmplitudeUnitsPerBit');
                                unit = elget(l, 'LeadAmplitudeUnits');
                                assert(strcmp(unit, 'MICROVOLTS'), '%s: expected MICROVOLTS but found %s', filename, unit);
                                
                                offset = elgetn(l, 'LeadOffsetFirstSample');
                                assert(offset==0, '%s: lead %d with %d bytes of invalid data', filename, k, offset);
                                baseline = elgetn(l, 'FirstSampleBaseline');
                                bytespersamp = elgetn(l, 'LeadSampleSize');
                                assert(bytespersamp == 2, '%s: expected 2 bytes per sample but found %f', filename, bytespersamp);
                                
                                w64 = char(elget(l, 'WaveFormData'));
                                % data is little-endian per MUSE spec
                                intsignal = double(typecast(matlab.net.base64decode(w64), 'int16'));
                                intsignal = intsignal + baseline;
                                signal = intsignal * gain / 1000;
                                obj.units='mV';
                                
                                switch char(elget(l, 'LeadID'))
                                    case 'X'
                                        obj.X = signal;
                                    case 'Y'
                                        obj.Y = signal;
                                    case 'Z'
                                        obj.Z = signal;
                                end
                            end
                        otherwise
                            error('unknown format %s', format);
                    end
                else
                    error('Argument parse error in VCG/constructor');
                end
                
            elseif nargin==5
                obj.hz = varargin{1};
                obj.units = varargin{2};
                obj.X = varargin{3};
                obj.Y = varargin{4};
                obj.Z = varargin{5};
                assert(length(obj.X) == length(obj.Y) && length(obj.Z) == length(obj.X));
            else
                error('VCG: expected 2 or 5 arguments, got %d', nargin);
            end
            obj.VM = sqrt(obj.X.^2 + obj.Y.^2 + obj.Z.^2);
            if isrow(obj.X); obj.X = obj.X'; end
            if isrow(obj.Y); obj.Y = obj.Y'; end
            if isrow(obj.Z); obj.Z = obj.Z'; end
            if isrow(obj.VM); obj.VM = obj.VM'; end
        end
        
        function l = length(obj); l = length(obj.VM); end
        
        function QRS = peaks(obj,a); QRS = findpeaksecg(obj.VM, a.maxBPM, obj.hz, a.pkthresh, a.pkfilter); end
                
        function e = ecg(obj, transform_matrix)
            switch transform_matrix
                case 'Kors'
                    M = korsmatrix();
                case 'Dower'
                    M = dowermatrix();
                otherwise
                    error('Unknown transform matrix %s', transform_matrix);
            end
            
            v = [obj.X , obj.Y , obj.Z]';
            %ecgcols = M\v;
            ecgcols = pinv(M)*v;
            V1 = ecgcols(1,:);
            V2 = ecgcols(2,:);
            V3 = ecgcols(3,:);
            V4 = ecgcols(4,:);
            V5 = ecgcols(5,:);
            V6 = ecgcols(6,:);
            L1 = ecgcols(7,:);
            L2 = ecgcols(8,:);
            e = ECG12(obj.hz, obj.units, L1, L2, V1, V2, V3, V4, V5, V6);
        end
        
        function [medbeat, beatsig_vcg] = medianbeat(obj, startb, endb) % not sure how to return or store beatsig atm
            [medbeatX, beatsigX] = medianbeat(obj.X, startb, endb);
            [medbeatY, beatsigY] = medianbeat(obj.Y, startb, endb);
            [medbeatZ, beatsigZ] = medianbeat(obj.Z, startb, endb);
            medbeat = VCG(obj.hz, obj.units, medbeatX, medbeatY, medbeatZ);
            beatsig_vcg = VCG(obj.hz, obj.units, beatsigX, beatsigY, beatsigZ);
        end

        
        function medbeat_stretched = stretch_x(obj, stretch_factor)
            delta = 1/stretch_factor;
            interp_t = 1:delta:length(obj.X);
            stretched_X = interp1(obj.X,interp_t,'spline');
            stretched_Y = interp1(obj.Y,interp_t,'spline');
            stretched_Z = interp1(obj.Z,interp_t,'spline');
            medbeat_stretched = VCG(obj.hz, obj.units, stretched_X, stretched_Y, stretched_Z);
        end
        
        
        function medbeat_stretched = stretch_y(obj, stretch_factor)
            stretched_X = obj.X * stretch_factor; 
            stretched_Y = obj.Y * stretch_factor; 
            stretched_Z = obj.Z * stretch_factor; 
            medbeat_stretched = VCG(obj.hz, obj.units, stretched_X, stretched_Y, stretched_Z);
        end
        
        function [spikeless, obj] = remove_pacer_spikes(obj, QRS, ap)
            spikeless = obj;
            [obj.endspikes, spikeless.VM] = ...
                pacer_spike_removal(obj.VM, QRS, ap.pacer_thresh, ...
                ap.pacer_spike_width_samp(obj.hz), ap.pacer_mf_samp(obj.hz));
            spikeless.endspikes = obj.endspikes;
            spikeless.X(isnan(spikeless.VM)) = NaN;
            spikeless.Y(isnan(spikeless.VM)) = NaN;
            spikeless.Z(isnan(spikeless.VM)) = NaN;
            
            % use splines to fill in Nan values
            spikeless.X = fillmissing(spikeless.X,'linear');
            spikeless.Y = fillmissing(spikeless.Y,'linear');
            spikeless.Z = fillmissing(spikeless.Z,'linear');
            spikeless.VM = fillmissing(spikeless.VM,'linear');
        end
        
        function obj = find_pacer_spikes(obj, QRS, ap)
            obj.endspikes = ...
                pacer_spike_removal(obj.VM, QRS, ap.pacer_thresh, ...
                ap.pacer_spike_width_samp(obj.hz), ap.pacer_mf_samp(obj.hz));
        end            
            
        function obj = mask_pvcs(obj, beats)
            for i=1:length(beats.QRS)
                if beats.pvc(i)
                    if isnan(beats.Tend(i))
                        obj.VM(beats.Q(i):beats.S(i)) = NaN;
                        obj.X(beats.Q(i):beats.S(i)) = NaN;
                        obj.Y(beats.Q(i):beats.S(i)) = NaN;
                        obj.Z(beats.Q(i):beats.S(i)) = NaN;
                    else
                        obj.VM(beats.Q(i):beats.Tend(i)) = NaN;
                        obj.X(beats.Q(i):beats.Tend(i)) = NaN;
                        obj.Y(beats.Q(i):beats.Tend(i)) = NaN;
                        obj.Z(beats.Q(i):beats.Tend(i)) = NaN;
                    end
                end
            end
        end
        
        
        function obj = mask_outliers(obj, beats)
            for i=1:length(beats.QRS)
                if beats.outlier(i)
                    if isnan(beats.Tend(i))
                        obj.VM(beats.Q(i):beats.S(i)) = NaN;
                        obj.X(beats.Q(i):beats.S(i)) = NaN;
                        obj.Y(beats.Q(i):beats.S(i)) = NaN;
                        obj.Z(beats.Q(i):beats.S(i)) = NaN;
                    else
                        obj.VM(beats.Q(i):beats.Tend(i)) = NaN;
                        obj.X(beats.Q(i):beats.Tend(i)) = NaN;
                        obj.Y(beats.Q(i):beats.Tend(i)) = NaN;
                        obj.Z(beats.Q(i):beats.Tend(i)) = NaN;
                    end
                end
            end
        end
        
        
%         function correlation_test = median_fit(obj, startb, endb, ap)
%             correlation_test  = median_fit( startb, endb, obj.VM, ap.align_flag);
%         end

        function obj = crop(obj, Q, Tend)
            obj.X = obj.X(Q:Tend);
            obj.Y = obj.Y(Q:Tend);
            obj.Z = obj.Z(Q:Tend);
            obj.VM = obj.VM(Q:Tend);
        end
        
        function obj = crop2d(obj, Q, Tend)
            obj.X = obj.X(:,Q:Tend);
            obj.Y = obj.Y(:,Q:Tend);
            obj.Z = obj.Z(:,Q:Tend);
            obj.VM = obj.VM(:,Q:Tend); 
        end
        
        function v = baseline_shift(obj, ap)
            qrs = obj.peaks(ap);
            vx = shift_onelead(obj.X, qrs);
            vy = shift_onelead(obj.Y, qrs);
            vz = shift_onelead(obj.Z, qrs);
            v = VCG(obj.hz, obj.units, vx, vy, vz);
        end    
        
        function t = sample_time(obj); t = 1000/obj.hz; end
        
        % default copy, destructor, assignment
    end
    
    
end


% utility functions
function r = elget(l, name)
r = l.getElementsByTagName(name).item(0).getFirstChild.getNodeValue;
end
function r = elgetn(l, name)
r = str2double(elget(l, name));
end

function x = shift_onelead(signal_orig, qrs)
signal = signal_orig(qrs(1):qrs(end));
N = length(signal_orig);
NQRS = length(qrs);
framelen=round(0.1*N/NQRS); if mod(framelen, 2)==0; framelen=framelen+1; end
order=4;
[~,g] = sgolay(order, framelen);
dx = abs(conv(signal, -g(:,2), 'same'));
seg = signal;
dseg = dx;
% find indices where slope and slope2 are both minimal  (less than 10th% ile)
small = max(dseg)/50;
ind = dseg < small;
median_shift = median(seg(ind));
x = signal_orig-median_shift;
end