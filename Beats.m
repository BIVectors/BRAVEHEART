%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% Beats.m -- Class for storing beat annotations
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

classdef Beats
% Each instance of the Beats is an annotation of a VCG
% This is stored in the properties as arrays with the same dimension that store the indices of the sample in the VCG
% so if the start of QRS are at sample 100, 200, and 300, while the S waves are at 150, 250, and 350, then you would have
% Q = [100 200 300 ...]
% S = [150 250 350 ...]
% The annotation is computed via calling the constructor with a VCG. Nothing about the VCG itself is stored in this class.

    properties (SetAccess=private)
        Q
        QRS
        S
        T
        Tend
        outlier         % logical flags for beats: is outlier beat?
        pvc             % logical flags for beats: is PVC?
        nnet_flag       % problem with nnet annotation?
        nnet_nan        % NNet can't find a fiducial point in the median beat
        QRS_rem_pvc     % List of beats that were removed as PVCs
        QRS_rem_outlier % List of beats that were removed as outliers
        QRS_rem_manual  % List of beats that were manually removed
        QRS_rem_bad     % List of beats that were removed due to other issues (too close to start/end of recording)
        
    end
    
    methods
        function obj = Beats(varargin)
            switch nargin
                              
                case 5
                    [Q, QRS, S, T, Tend] = varargin{:};
                    if length(QRS) == length(Q) && length(QRS) == length(S) && length(QRS) == length(T) && ...
                            length(QRS) == length(Tend)
                        obj.QRS = QRS;
                        obj.Q = Q;
                        obj.S = S;
                        obj.T = T;
                        obj.Tend = Tend;
                    else
                        error('Vectors different length in Beats constructor');
                    end
                case 4
                    [Q, QRS, S, Tend] = varargin{:};
                    if length(QRS) == length(Q) && length(QRS) == length(S) && ...
                            length(QRS) == length(Tend)
                        obj.QRS = QRS;
                        obj.Q = Q;
                        obj.S = S;
                        obj.Tend = Tend;
                    else
                        error('Vectors different length in Beats constructor');
                    end
                    
                case 3
                    [vcg, QRS, aps] = varargin{:};
                    hz = vcg.hz;
                    % if aps.debug; figure; plot(vcg.VM); hold on; end
                    if length(QRS) ~= 1
                        RR = diff(QRS); RR(end+1) = round(mean(RR));
                        STendsamp = aps.STendsamp(RR);
                    else
                        STendsamp = aps.STend;
                    end
                    
                    % If using regular annotation for median reanno
                    if strcmp(aps.median_reanno_method,'Std') || length(QRS) ~= 1
                        
                        [obj.Q, obj.QRS, obj.S, obj.T, obj.Tend] = ...
                            autoMFannotate(vcg.VM, QRS, aps.QRsamp(hz), vcg.endspikes, ...
                            aps.RSsamp(hz), aps.STstartsamp(hz), STendsamp, aps.Tendstr, ...
                            aps.autoMF, aps.MF_width_samp(hz), aps.autoMF_thresh, hz, aps.debug); 
                    end
                    
                    % Add to "bad" beats if anno didnt like a beat too
                    % close to start or end of the signal (eg they were cut
                    % off and were only included in the HR calculation).

                    if length(QRS) > length(obj.QRS) && length(QRS) ~= 1
                        C = setxor(QRS,obj.QRS);
                        obj.QRS_rem_bad = vertcat(obj.QRS_rem_bad, C);
                        % If end up with a 0x1 double vector make this empty
                            if isempty(obj.QRS_rem_bad)
                                obj.QRS_rem_bad = [];
                            end
                        % Sort in ascending order
                        obj.QRS_rem_bad = sort(obj.QRS_rem_bad);
                    end


                    
                    % If using nnet for median reanno
                    if strcmp(aps.median_reanno_method,'NNet') && length(QRS) == 1
                        
                        [obj.Q, obj.S, obj.T, obj.Tend, obj.nnet_flag, obj.nnet_nan] = nnet_median_annotate(vcg, aps.debug);
                        obj.QRS = QRS;
                    end
                    
                    
                    
                    % check for overlapping beats
                    for i=1:length(obj.QRS)-1
                        if obj.Tend(i) > obj.Q(i+1); obj.Tend(i) = NaN; end
                    end
                    
                case 0
                otherwise
                    error('Beats:constructor', 'got %d args', nargin);
            end
        end
        
        function b = septum(obj, vcg, window, aps) %#ok<INUSD>
           b.Q = obj.Q;
           [~, b.QRS] = findpeaks(vcg.VM, 'NPeaks', 1);
           b.Tend = obj.Q+window;
           b.S = waveEndPk(vcg.VM, b.QRS, b.Tend);
           b.S = b.S + b.Q - 1;
        end        
        
        function [startb, endb, qonb, qoffb, toffb] = medianloc(obj, vcg, ap)
	  % given a stack of Q, R, S, and T, compute the indices of the start and end indices which encompass them,
	  % assuming the QRS complexes are lined up on their peaks or centers of mass
            R = com_or_rpeak(obj.QRS, vcg.VM, vcg.hz, ap);
            [qonb, toffb, qoffb] = medianloc(obj.Q, R, obj.S, obj.Tend);
            startb = qonb + ap.shiftq_samp(vcg.hz);
            endb = toffb + ap.shiftt_samp(vcg.hz);
        end
        
        function q = qend(obj); q = obj.S-(obj.Q-1); end
        
        function l = length(obj); l = length(obj.QRS); end
        
        function b = beatmatrix(obj); b = [obj.Q obj.QRS obj.S obj.Tend]; end
        
        
        
        function b = fixTend(obj, ap)
            % Try to salvage beats by guessing Tend when the heuristic annotator failed

            N = obj.length();

            Tendnan = isnan(obj.Tend);
            overlapped = obj.Tend(1:N-1) > obj.Q(2:N); overlapped(N) = false;
            badind = Tendnan | overlapped;
            bad = badind==1;

            b = obj;
            rr = obj.RRint();
            endw = ap.STend;
            %endw = ap.STend*1.5;
            %if endw > 75; endw = 75; end

            % if the last beat is bad, just delete it
            if bad(N); deleteLast = true; else; deleteLast = false; end

            bad = bad(1:N-1);
            b.Tend(bad) = round(b.S(bad) + rr(bad)*endw/100);

            if deleteLast; b = b.delete(N, "bad"); end
            
        end
           
        
        function obj = find_pvcs(obj, vcg, ap)
	  
            
            % PVC detector, works by computing a cross correlation and RMSE of each beat with the median beat
	  
            R = com_or_rpeak(obj.QRS, vcg.VM, vcg.hz, ap);
            [~, ~, ~, px, ~] = pvc_stats(ap.pvcthresh, ap.rmse_pvcthresh, ap.keep_pvc, [obj.Q R obj.S obj.Tend], vcg.X);
            [~, ~, ~, py, ~] = pvc_stats(ap.pvcthresh, ap.rmse_pvcthresh, ap.keep_pvc, [obj.Q R obj.S obj.Tend], vcg.Y);
            [~, ~, ~, pz, ~] = pvc_stats(ap.pvcthresh, ap.rmse_pvcthresh, ap.keep_pvc, [obj.Q R obj.S obj.Tend], vcg.Z);
            
            P = px + py + pz;
            P(P<2) = 0;
            P(P>=2) = 1;
           
             
%                 % DEBUG CODE TO CALC ACCURACY OF PVC DETECTOR   
%                 % % open your file for writing
%                 cc=num2cell(double(P),2);
%                 C=num2str(cc{1});
%                
%                 fid = fopen(strcat('R:\PVC database\__FINAL_PVCS\_', num2str(100*ap.pvcthresh),'_',num2str(10*ap.rmse_pvcthresh),'.csv'),'a+');
%                 % write the matrix
%                 if fid > 0
%                      fprintf(fid,'%s,\n',C');
%                      fclose(fid);
%                 end
  
        if ap.keep_pvc == 0
            obj.pvc = logical(P);
        else
                obj.pvc = logical(~P);
        end
        end
        
        function obj = delete(obj, ind, flag)

            % If don't supply a flag it is manual
            if nargin == 2 && isnumeric(ind)
                flag = 'manual';
            end
            
            obj_old = obj;
            
            obj.Q(ind) = [];
            obj.QRS(ind) = [];
            obj.S(ind) = [];
            if ~isempty(obj.T); obj.T(ind) = []; end
            obj.Tend(ind) = [];
            if ~isempty(obj.outlier); obj.outlier(ind) = []; end
            if ~isempty(obj.pvc); obj.pvc(ind) = []; end
            
            % If end up with 0 beats left over dont remove anything!!!
             if isempty(obj.Q)
                 % Reset to prior to deletion 
                 obj = obj_old; 
             end

             % Moved deleted beat to 'deleted' field 

             if strcmp(flag,"pvc")
                    obj.QRS_rem_pvc = vertcat(obj.QRS_rem_pvc, obj_old.QRS(ind));
                    % If end up with a 0x1 double vector make this empty
                        if isempty(obj.QRS_rem_pvc)
                            obj.QRS_rem_pvc = [];
                        end
                    % Sort in ascending order
                    obj.QRS_rem_pvc = sort(obj.QRS_rem_pvc);

             elseif strcmp(flag,"outlier")
                    obj.QRS_rem_outlier = vertcat(obj.QRS_rem_outlier, obj_old.QRS(ind));
                    % If end up with a 0x1 double vector make this empty
                        if isempty(obj.QRS_rem_outlier)
                            obj.QRS_rem_outlier = [];
                        end
                    % Sort in ascending order
                    obj.QRS_rem_outlier = sort(obj.QRS_rem_outlier);
             
             elseif strcmp(flag,"bad")
                    obj.QRS_rem_bad = vertcat(obj.QRS_rem_bad, obj_old.QRS(ind));
                    % If end up with a 0x1 double vector make this empty
                        if isempty(obj.QRS_rem_bad)
                            obj.QRS_rem_bad = [];
                        end
                    % Sort in ascending order
                    obj.QRS_rem_bad = sort(obj.QRS_rem_bad);
             
             else
                    obj.QRS_rem_manual = vertcat(obj.QRS_rem_manual, obj_old.QRS(ind));
                    % If end up with a 0x1 double vector make this empty
                        if isempty(obj.QRS_rem_manual)
                            obj.QRS_rem_manual = [];
                        end
                    % Sort in ascending order
                    obj.QRS_rem_manual = sort(obj.QRS_rem_manual);

             end
 
        end
        
        function obj = change(obj, ind, newbeat)
            if length(newbeat) == 4
                newQ = newbeat(1);
                newQRS = newbeat(2);
                newS = newbeat(3);
                newTend = newbeat(4);
            else
                error('New beat is 4 points long - do NOT include Tpeak');
            end
            obj.Q(ind) = newQ;
            obj.QRS(ind) = newQRS;
            obj.S(ind) = newS;
            % copy over Tpeak
            obj.Tend(ind) = newTend;
        end
        
        function b = add(obj, newbeat)
            if length(newbeat) == 4
                newQ = newbeat(1);
                newQRS = newbeat(2);
                newS = newbeat(3);
                newT = 0;   % Zero for T since not used
                newTend = newbeat(4);
            else
                error('New beat is 4 points long - do NOT include Tpeak');
            end
            b = obj;
            len = obj.length();
            ind = len + 1;
            b.Q(ind) = newQ;
            b.QRS(ind) = newQRS;
            b.S(ind) = newS;
            b.T(ind) = newT;
            b.Tend(ind) = newTend;
        end
        
        
        
        function b = shift_q(obj, shift)
            b = obj;
            b.Q = b.Q+shift;
        end
        
        function b = shift_r(obj, shift)
            b = obj;
            b.QRS = b.QRS+shift;
        end
        
        function b = shift_s(obj, shift)
            b = obj;
            b.S = b.S+shift;
        end
        
        function b = shift_t(obj, shift)
            b = obj;
            b.T = b.T+shift;
        end
        
        function b = shift_tend(obj, shift)
            b = obj;
            b.Tend = b.Tend+shift;
        end
        
        function d = QRSdur(obj); d = obj.S-obj.Q; end
        function d = RRint(obj); N=obj.length(); d = obj.QRS(2:N) - obj.QRS(1:N-1); end
        
        function obj = find_outliers(obj, vcg, ap)
            cutpt = ap.modz_cutoff;
            
            % dynamic cutpt based on number of beats?
            length(obj.Q);
            
            [outlier_matrix, ~] = find_outliers([obj.Q obj.QRS obj.S obj.Tend], vcg.VM, vcg.hz, cutpt); % careful! definition of beatmatrix different
            o = outlier_matrix(4,:) + outlier_matrix(1,:);
            obj.outlier = (o>=1)';
        end
        
        
        function v = cells(obj)
            
            lab = obj.labels();
            v = cell(1, length(lab));
            for i = 1:length(lab)
                
                v{i} = mat2str(obj.(lab{i})');
                T = v{i};
                T(T=='[') = [];
                T(T==']') = [];
                v{i} = T;
                
            end
            
        end
        
        
        function labels = labels(obj)
            
            labels_long = properties(obj)';
            
            
            delete_names = [{'T'} {'outlier'} {'pvc'} {'nnet_flag'} {'nnet_nan'}];
            
            for k = 1:length(delete_names)
                idx(k) = find(strcmp(labels_long,delete_names{k}));
            end
            labels_long(idx)=[];
            labels = labels_long;
            
            
            
        end
        
        
    end
    % default copy, assignment, destructor
    
end


