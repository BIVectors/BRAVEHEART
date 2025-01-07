%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% ecgtransform.m -- Transform ECG into VCG
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


function [X, Y, Z, VM] = ecgtransform(L1, L2, V1, V2, V3, V4, V5, V6, transform_matrix)

% Create matrix of leads V1, V2, V3, V4, V5, V6, I, II = Matrix E
E = [ V1, V2, V3, V4, V5, V6, L1, L2 ];

% Choose transformation matrix

switch transform_matrix
    case 'Dower'
        M = dowermatrix();
    case 'Kors'
        M = korsmatrix();       
    otherwise
        error('Unknown transform_matrix: %s', transform_matrix);
end

VCG_matrix=M*E';

% Extract X, Y, Z coordinates from VCG_matrix
X=VCG_matrix(1 , :)';
Y=VCG_matrix(2 , :)';
Z=VCG_matrix(3 , :)';

% Vector magnitude lead
VM = sqrt(X.^2+Y.^2+Z.^2);

end