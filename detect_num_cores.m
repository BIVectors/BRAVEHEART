%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% detect_num_cores.m -- Detect number of available CPU cores
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

function [num_cores, hpc] = detect_num_cores()
    % Detect number of cores across different environments
    % Checks multiple HPC schedulers and falls back to local detection
    
    % Try SLURM (most common)
    num_cores = try_env_var('SLURM_CPUS_PER_TASK', 'SLURM');
    if num_cores > 0
       hpc = 1; 
       return; 
    end
    
    % Try PBS/Torque
    num_cores = try_env_var('PBS_NUM_PPN', 'PBS');
    if num_cores > 0
       hpc = 1; 
       return; 
    end
    
    num_cores = try_env_var('NCPUS', 'PBS/Torque');
    if num_cores > 0
       hpc = 1; 
       return; 
    end
    
    % Try LSF
    num_cores = try_env_var('LSB_DJOB_NUMPROC', 'LSF');
    if num_cores > 0
       hpc = 1; 
       return; 
    end
    
    % Try SGE
    num_cores = try_env_var('NSLOTS', 'SGE');
    if num_cores > 0
       hpc = 1; 
       return; 
    end
    
    % No scheduler detected - running locally
    num_cores = maxNumCompThreads;
    hpc = 0;
end

function num_cores = try_env_var(var_name, scheduler_name)
    %TRY_ENV_VAR Try to read a scheduler environment variable
    
    val = getenv(var_name);
    if ~isempty(val)
        num_cores = str2num(val);
        if num_cores > 0
            %fprintf('Detected %s scheduler: %d cores allocated (%s=%d)\n', scheduler_name, num_cores, var_name, num_cores);
            return;
        end
    end
    num_cores = 0;  % Not found
end