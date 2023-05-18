%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% energyoff.m -- Find End of T wave based on method described in:
% Lars Johannesen, Jose Vicente, Meisam Hosseini, David G. Strauss
% Automated Algorithm for J-Tpeak and Tpeak-Tend Assessment of Drug-Induced Proarrhythmia Risk
% PLOS ONE | DOI:10.1371/journal.pone.0166925 December 30, 2016
%
% Copyright 2016-2023 Hans F. Stabenau and Jonathan W. Waks
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

function off = energyoff(fs, fsprime, T, endw, R, RR, debug)
% off = energyoff(fs, fsprime, T, endw, R, RR)
% compute T-end a la
% Lars Johannesen1*, Jose Vicente1,2, Meisam Hosseini1, David G. Strauss1*
% Automated Algorithm for J-Tpeak and Tpeak-Tend Assessment of Drug-Induced Proarrhythmia Risk
% PLOS ONE | DOI:10.1371/journal.pone.0166925 December 30, 2016 5 /

energydebug=false;

fsl = fs(T:endw);
fspl = fsprime(T:endw);

N = endw-T+1;
% energy of lastCandidToff_segment: higher amplitude has less energy
energy = zeros(N,1);
%toff candidates: index of local minima of energy signal
energy(1) = fs(T);
indexlocalMinimaEnergy = [];
flagmaxima = true;
for i=2:N
    switch sign(fspl(i))
        case -1    % negative derivative: decreases energy
            energy(i) = energy(i-1) - fsl(i);
            if flagmaxima; indexlocalMinimaEnergy(end+1) = i; end
            indexlocalMinimaEnergy(end) = i;
            flagmaxima = false;
        case 1 % positive derivative: increases energy
            energy(i) = energy(i-1) + fsl(i);
            flagmaxima = true;
        otherwise % zero derivative: preserves energy
            energy(i) = energy(i-1);
    end
end
%normalize energy between [0-100] due to current lastCandidToff
% Higher amount of energy has higher amplitude
energyNormal = (energy-min(energy))/(max(energy)-min(energy));

derivativeEnergy = deriv5(energyNormal, 'T');
if debug && energydebug
    plot(T:endw, energyNormal*5);
    text(indexlocalMinimaEnergy+T-1, energyNormal(indexlocalMinimaEnergy)*5, 'M');
    plot(T:endw, 10*derivativeEnergy);
end

% energy(0) should have highest value if lastCandid (tpeak) is chosen appropriately
%     startEnergy = 1;
% 	for i=1:N
% 		if energyNormal(i) > energyNormal(i+1)
% 				startEnergy = i;
% 				break;
%         end
%     end

% re-adjust the index of toff candidates (indexlocalMinimaEnergy)
% based on derivative of energy.
% The greatest localmaxima will be a new toff of each candidate
NminE = numel(indexlocalMinimaEnergy);
indexNewToffCandidates = zeros(NminE,1);
j=1; % j=point after T-wave peak or local minimum of energy
for i=1:NminE
    toff_index2 = indexlocalMinimaEnergy(i);
    % indexMin = local minimum of derivative
    [~,indexMin] = min(fspl(j:toff_index2));
    toff_index1 = indexMin + j-1;
    % now: toff_index1 = local minimum of the derivative (steepest
    % negative slope) - NB I don't know how this works for negative
    % T-waves, but we don't care if using VM lead
    % toff_index2 = local minimum of the energy
    
    % adjust toff_index1 and toff_index2
    if (toff_index1 > toff_index2)
        error('Shouldn''t get here 1 in energyoff');
%         tmp = toff_index1;
%         toff_index1 = toff_index2;
%         toff_index2 = tmp;
    end
    
    if(toff_index1 == toff_index2); toff_index1=toff_index1-1; end
    
    % derivative of current toff candidate
    derivativeEnergyCandidate = derivativeEnergy(toff_index1:toff_index2);
    Nd = numel(derivativeEnergyCandidate);
    
    falingFlag = false;
    indexToffCandidate = 1;
    
    % this section sets indexToffCandidate to the last local maximum of
    % the derivative of the energy
    for k=2:Nd
        if derivativeEnergyCandidate(k-1) < derivativeEnergyCandidate(k)
            falingFlag = false;
        end
        
        % find local maxima of the derivative of the energy
        if derivativeEnergyCandidate(k-1) > derivativeEnergyCandidate(k)
            if (falingFlag == false)
                falingFlag = true;
                % it is a local maximum
                if debug && energydebug; text(k+toff_index1-1+T-1, 5*energyNormal(k+toff_index1-1), '&'); end
                if (derivativeEnergyCandidate(k) > ...
                        derivativeEnergyCandidate(indexToffCandidate))
                    % set indexToffCandidate to the 
                    indexToffCandidate = k;
                end
            end
        end
    end
    
    % if derivativeEnergy has not any local maxima, use the energy minimum
    % as the Toff candidate instead
    if indexToffCandidate == 1
        indexToffCandidate = Nd;
    end
    
    indexNewToffCandidates(i) = indexToffCandidate + toff_index1-1;
    j = indexlocalMinimaEnergy(i);
end %i=1:numel(indexlocalminimaenergy)

% chooses one of the new toff candidates for re-adjusted toff based on cost function
a = T - R;
%b = lastCandid + indexNewToffCandidates - rpeak;
x = indexNewToffCandidates;
y = RR - a;
D = x/y;

% energy parameter of cost function
E = energyNormal(indexNewToffCandidates);

% cost function
costFunc = E + 1.5*D;

% new toff obtains by minimizing cost function
[~,indexCandid] = min(costFunc);

try
    off = indexNewToffCandidates(indexCandid(1)) + T-1; % final toff candidate
catch
    off = [];
    return;
end


end

