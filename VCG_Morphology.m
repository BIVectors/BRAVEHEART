%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% VCG_Morphology.m -- VCG_Morphology Results Class
% Copyright 2016-2024 Hans F. Stabenau and Jonathan W. Waks
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


classdef VCG_Morphology
% Various VCG measurements based on morphology of the VCG loops
    
properties (SetAccess=private)
        
        TCRT                    % Total Cosine R to T
        TCRT_angle              % Angle from TCRT = acos(TCRT)

        tloop_residual          % SVD residual from fitting T loop to a plane (0 = perfect fit) = (t_S3)^2
        tloop_rmse              % RMSE for fit of T loop to best fit plane (0 = perfect fit)
        tloop_roundness         % How round the T loop is.  1 = circle, larger values are elliptical
        tloop_area              % Area of T loop
        tloop_perimeter         % Length of T loop

        qrsloop_residual        % SVD residual from fitting QRS loop to a plane (0 = perfect fit) = (qrs_S3)^2
        qrsloop_rmse            % RMSE for fit of QRS loop to best fit plane (0 = perfect fit)
        qrsloop_roundness       % How round the QRS loop is.  1 = circle, larger values are elliptical
        qrsloop_area            % Area of QRS loop
        qrsloop_perimeter       % Length of QRS loop
        
        qrs_S1                  % QRS loop 1st singular value
        qrs_S2                  % QRS loop 2nd singular value
        qrs_S3                  % QRS loop 3rd singular value
        
        t_S1                    % T loop 1st singular value
        t_S2                    % T loop 2nd singular value
        t_S3                    % T loop 3rd singular value
        
        qrs_var_s1_total        % Pct of total variance made up by 1st QRS singular value
        qrs_var_s2_total        % Pct of total variance made up by 2nd QRS singular value
        qrs_var_s3_total        % Pct of total variance made up by 3rd QRS singular value
        
        t_var_s1_total          % Pct of total variance made up by 1st T singular value
        t_var_s2_total          % Pct of total variance made up by 2nd T singular value
        t_var_s3_total          % Pct of total variance made up by 3rd T singular value
        
        qrs_loop_normal         % Vector normal to best fit QRS loop plane
        t_loop_normal           % Vector normal to best fit T loop plane
        qrst_dihedral_ang       % Dihedral angle between best fit QRS loop and T loop planes

        TMD                     % T-Wave Morphology Dispersion (deg)
        TWR_abs                 % Absolute T-wave residuum (mv2)
        TWR_rel                 % Relative T-wave residuum (%)
end
    
    
methods
        
    function obj = VCG_Morphology(varargin)        % varagin: ECG12, VCG, Beats
        if nargin == 0; return; end
        if nargin ~= 3
            error('VCG_Morphology: expected 3 args in constructor, got %d', nargin);
        end

        assert(isa(varargin{1}, 'ECG12'), 'First argument is not a ECG12 class');
        assert(isa(varargin{2}, 'VCG'), 'Second argument is not a VCG class');
        assert(isa(varargin{3}, 'Beats'), 'Third argument is not a Beats class');

        ecg = varargin{1}; vcg = varargin{2}; fidpts = varargin{3}.beatmatrix();
    
        % TCRT
        [obj.TCRT, obj.TCRT_angle] = tcrt(ecg, vcg, fidpts, 0.7, 0);

        % Loop morphology
        [obj.t_loop_normal, ~, ~, ~, obj.tloop_residual, obj.tloop_rmse, obj.t_var_s1_total,  obj.t_var_s2_total,obj.t_var_s3_total, obj.t_S1, obj.t_S2, obj.t_S3, ~, obj.tloop_roundness, ~, ~, ~, obj.tloop_area, obj.tloop_perimeter] = ...
            plane_svd(vcg.X(fidpts(3):fidpts(4)), vcg.Y(fidpts(3):fidpts(4)), vcg.Z(fidpts(3):fidpts(4)), 0);

        [obj.qrs_loop_normal, ~, ~, ~, obj.qrsloop_residual, obj.qrsloop_rmse, obj.qrs_var_s1_total,  obj.qrs_var_s2_total,  obj.qrs_var_s3_total, obj.qrs_S1, obj.qrs_S2, obj.qrs_S3, ~, obj.qrsloop_roundness, ~, ~, ~, obj.qrsloop_area, obj.qrsloop_perimeter] = ...
            plane_svd(vcg.X(fidpts(1):fidpts(3)), vcg.Y(fidpts(1):fidpts(3)), vcg.Z(fidpts(1):fidpts(3)), 0);

        % Dihedral angle between QRS and T loop planes
        obj.qrst_dihedral_ang = dihedral(obj.t_loop_normal, obj.qrs_loop_normal);

        % TMD/TWR
        [obj.TMD, obj.TWR_abs, obj.TWR_rel] = svd_twave(ecg,fidpts);

           
    end     % End main VCG_Morphology methods 
    
    
%     function values = values(obj)
%     txt_labels = properties(obj);
% 
%     values = zeros(1, length(txt_labels));
%     for i = 1:length(txt_labels)
%         if ~isempty(obj.(txt_labels{i}))
%             values(i) = obj.(txt_labels{i});
%         else
%             values(i) = NaN;
%         end
%     end
%     end
    
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
               
end     % End methods
    
    
methods(Static)
    
    % Display lead header for export purposes
    function labels = labels()
        obj = VCG_Morphology();
        labels = properties(obj)';
    end
    
    % Length of class members
    function l = length(); g = VCG_Morphology(); l = length(properties(g)); end
        
    % Set to all nan if error
    function a = allnan()
        a = VCG_Morphology();
        p = properties(a);
        for i = 1:length(p)
            a.(p{i}) = nan;
        end
    end
    


    

end     % End methods

end     % End class


