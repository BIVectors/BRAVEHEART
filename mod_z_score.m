%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% mod_z_score.m -- Calculate Modified Z Score
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


function z = mod_z_score(x, ~)
    
    z = zeros(1,length(x));
    x_median = median(x,'omitnan');
    x_mad = median_abs_dev(x);  % MEDIAN absolute deviation

    if x_mad ~= 0

            z = abs((0.6745* (x - x_median)) / x_mad);   

    else

        % if MAD = 0 set instead to smallest unit change.  Will set to 2 ms as this will be good for most ECGs

        % For discussion see Water 2019, 11, 951; doi:10.3390/w11050951
        % Bae et al "Outlier Detection and Smoothing Process for Water Level Data Measured by Ultrasonic Sensor in Stream Flows"

%         delta = round(1000/hz,1);       % In future will pass in Hz so can get unit change specific for ECG frequency
%         x_mad = delta;
        
        % MEAN absolute deviation if MEDIAN absolute deviation = 0
        x_mad = mean_abs_dev(x);

            %z(i) = abs((x(i) - x_median) / (1.253314 * x_mad));   
            z = abs((0.7979* (x - x_median)) / x_mad);  

    end


end
    

%%% 
%(X-MED)/(1.253314*MeanAD).  meanAD = mean absolute deviation